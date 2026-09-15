<#
.SYNOPSIS
    [GAP-002 workaround] Compute a WSJF, RICE, ICE, or DVFC composite
    prioritization ranking from azdw work item JSON. azdw has no native
    prioritization-scoring calculation.

.DESCRIPTION
    Gap ID:                       GAP-002 (WSJF / RICE / ICE / DVFC composite scoring)
    azdw command producing input: azdw query -t "<type>" --all-fields --format json
                                  (or the equivalent azdw_ MCP query tool)
    Native replacement target:    a future azdw `--calculate-<method>` option

    This script is bundled CONTENT of the manage-software-portfolio skill. It is
    executed by whichever agent harness loads the skill, NOT by a dedicated azdw
    MCP tool. It is READ-ONLY: it only reads JSON and never calls Azure DevOps.

    The computed scores are APPROXIMATIONS produced locally, clearly labeled as a
    [GAP-002] workaround, never a native azdw metric.

      WSJF = (Value + TimeCriticality + RiskReduction) / JobSize
      RICE = (Reach * Impact * Confidence) / Effort
      ICE  = Impact * Confidence * Ease
      DVFC = (Desirability + Viability + Feasibility + Contextuality) / 4

    NOTE on DVFC: this is the classic four-lens opportunity score
    Desirability / Viability / Feasibility / Contextuality (do customers want it,
    does the business case hold, can we build it, does it fit strategy/portfolio),
    NOT a Demand/Value/Flow/Cost composite. Supply one rollup field per lens via
    the *Field parameters (no standard ADO fields exist for these — map them in
    portfolio-mapping.md). Higher is better.

.PARAMETER Path
    Path to a JSON file produced by azdw. If omitted, JSON is read from stdin.

.PARAMETER Method
    WSJF, RICE, ICE, or DVFC. Determines which fields/formula are used.

.PARAMETER ValueField, TimeCriticalityField, RiskReductionField, JobSizeField
    WSJF input field reference names (from portfolio-mapping.md).

.PARAMETER ReachField, ImpactField, ConfidenceField, EffortField
    RICE input field reference names (Impact/Confidence shared with ICE).

.PARAMETER EaseField
    Additional ICE input field reference name.

.PARAMETER DesirabilityField, ViabilityField, FeasibilityField, ContextualityField
    DVFC four-lens input field reference names (from portfolio-mapping.md).

.PARAMETER TitleField
    Field reference name used for the display title. Default: System.Title.

.EXAMPLE
    azdw query -t "Epic" --all-fields --format json |
        pwsh Get-PrioritizationRanking.ps1 -Method WSJF `
            -ValueField Microsoft.VSTS.Common.BusinessValue `
            -TimeCriticalityField Microsoft.VSTS.Common.TimeCriticality `
            -RiskReductionField Custom.RiskReduction `
            -JobSizeField Microsoft.VSTS.Scheduling.Effort
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path,

    [Parameter()]
    [ValidateSet('WSJF', 'RICE', 'ICE', 'DVFC')]
    [string] $Method = 'WSJF',

    # WSJF inputs
    [string] $ValueField = 'Microsoft.VSTS.Common.BusinessValue',
    [string] $TimeCriticalityField = 'Microsoft.VSTS.Common.TimeCriticality',
    [string] $RiskReductionField = 'Custom.RiskReduction',
    [string] $JobSizeField = 'Microsoft.VSTS.Scheduling.Effort',

    # RICE inputs (Impact/Confidence shared with ICE)
    [string] $ReachField = 'Custom.Reach',
    [string] $ImpactField = 'Custom.Impact',
    [string] $ConfidenceField = 'Custom.Confidence',
    [string] $EffortField = 'Microsoft.VSTS.Scheduling.Effort',

    # ICE inputs
    [string] $EaseField = 'Custom.Ease',

    # DVFC four-lens inputs (Desirability / Viability / Feasibility / Contextuality)
    [string] $DesirabilityField = 'Custom.Desirability',
    [string] $ViabilityField = 'Custom.Viability',
    [string] $FeasibilityField = 'Custom.Feasibility',
    [string] $ContextualityField = 'Custom.Contextuality',

    [string] $TitleField = 'System.Title'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
# Render numbers with '.' decimal separator regardless of OS locale.
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture

# --- inlined read-only helpers (kept local so the script is self-contained) ---

function Get-AzdwJson {
    param([string] $Path)
    if ($Path) {
        if (-not (Test-Path -LiteralPath $Path)) { throw "Input file not found: $Path" }
        $raw = Get-Content -LiteralPath $Path -Raw
    }
    else {
        $raw = [Console]::In.ReadToEnd()
    }
    if ([string]::IsNullOrWhiteSpace($raw)) { return @() }
    $data = $raw | ConvertFrom-Json
    if ($null -eq $data) { return @() }
    if (($data -is [System.Collections.IEnumerable]) -and ($data -isnot [string])) { return @($data) }
    foreach ($prop in 'items', 'workItems', 'value', 'results', 'data') {
        $p = $data.PSObject.Properties[$prop]
        if ($p) { return @($p.Value) }
    }
    return @($data)
}

function Get-ItemField {
    param($Item, [string] $Reference)
    if ($null -eq $Item) { return $null }
    $fields = $Item.PSObject.Properties['fields']
    if ($fields -and $fields.Value) {
        $fp = $fields.Value.PSObject.Properties[$Reference]
        if ($fp) { return $fp.Value }
    }
    $direct = $Item.PSObject.Properties[$Reference]
    if ($direct) { return $direct.Value }
    $short = ($Reference -split '\.')[-1]
    $ds = $Item.PSObject.Properties[$short]
    if ($ds) { return $ds.Value }
    if ($fields -and $fields.Value) {
        $fs = $fields.Value.PSObject.Properties[$short]
        if ($fs) { return $fs.Value }
    }
    return $null
}

function Get-ItemNumber {
    param($Item, [string] $Reference)
    $raw = Get-ItemField -Item $Item -Reference $Reference
    $num = 0.0
    if ([double]::TryParse([string]$raw, [ref] $num)) { return $num }
    return $null
}

function Get-ItemId {
    param($Item)
    foreach ($ref in 'id', 'System.Id', 'Id') {
        $v = Get-ItemField -Item $Item -Reference $ref
        if ($null -ne $v) { return $v }
    }
    return '(no id)'
}

# ------------------------------------------------------------------------------

$items = @(Get-AzdwJson -Path $Path)
if ($items.Count -eq 0) {
    Write-Output "[GAP-002 workaround] No work items found in input."
    return
}

$ranked = New-Object System.Collections.Generic.List[object]
$incomplete = New-Object System.Collections.Generic.List[object]

foreach ($item in $items) {
    $id = Get-ItemId -Item $item
    $title = [string](Get-ItemField -Item $item -Reference $TitleField)

    if ($Method -eq 'WSJF') {
        $value = Get-ItemNumber -Item $item -Reference $ValueField
        $tc = Get-ItemNumber -Item $item -Reference $TimeCriticalityField
        $rr = Get-ItemNumber -Item $item -Reference $RiskReductionField
        $size = Get-ItemNumber -Item $item -Reference $JobSizeField
        $inputs = @{ Value = $value; TimeCriticality = $tc; RiskReduction = $rr; JobSize = $size }
        if (($null -eq $value) -or ($null -eq $tc) -or ($null -eq $rr) -or ($null -eq $size) -or ($size -eq 0)) {
            $incomplete.Add([pscustomobject]@{ Id = $id; Title = $title; Reason = 'missing/zero WSJF inputs' })
            continue
        }
        $score = [math]::Round((($value + $tc + $rr) / $size), 2)
    }
    elseif ($Method -eq 'RICE') {
        $reach = Get-ItemNumber -Item $item -Reference $ReachField
        $impact = Get-ItemNumber -Item $item -Reference $ImpactField
        $conf = Get-ItemNumber -Item $item -Reference $ConfidenceField
        $effort = Get-ItemNumber -Item $item -Reference $EffortField
        $inputs = @{ Reach = $reach; Impact = $impact; Confidence = $conf; Effort = $effort }
        if (($null -eq $reach) -or ($null -eq $impact) -or ($null -eq $conf) -or ($null -eq $effort) -or ($effort -eq 0)) {
            $incomplete.Add([pscustomobject]@{ Id = $id; Title = $title; Reason = 'missing/zero RICE inputs' })
            continue
        }
        $score = [math]::Round((($reach * $impact * $conf) / $effort), 2)
    }
    elseif ($Method -eq 'ICE') {
        $impact = Get-ItemNumber -Item $item -Reference $ImpactField
        $conf = Get-ItemNumber -Item $item -Reference $ConfidenceField
        $ease = Get-ItemNumber -Item $item -Reference $EaseField
        $inputs = @{ Impact = $impact; Confidence = $conf; Ease = $ease }
        if (($null -eq $impact) -or ($null -eq $conf) -or ($null -eq $ease)) {
            $incomplete.Add([pscustomobject]@{ Id = $id; Title = $title; Reason = 'missing ICE inputs' })
            continue
        }
        $score = [math]::Round(($impact * $conf * $ease), 2)
    }
    else {
        # DVFC = four-lens opportunity score (Desirability / Viability / Feasibility / Contextuality)
        $des = Get-ItemNumber -Item $item -Reference $DesirabilityField
        $via = Get-ItemNumber -Item $item -Reference $ViabilityField
        $fea = Get-ItemNumber -Item $item -Reference $FeasibilityField
        $ctx = Get-ItemNumber -Item $item -Reference $ContextualityField
        $inputs = @{ Desirability = $des; Viability = $via; Feasibility = $fea; Contextuality = $ctx }
        if (($null -eq $des) -or ($null -eq $via) -or ($null -eq $fea) -or ($null -eq $ctx)) {
            $incomplete.Add([pscustomobject]@{ Id = $id; Title = $title; Reason = 'missing DVFC inputs' })
            continue
        }
        $score = [math]::Round((($des + $via + $fea + $ctx) / 4), 2)
    }

    $ranked.Add([pscustomobject]@{
            Id     = $id
            Title  = $title
            Score  = $score
            Inputs = ($inputs.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join ' '
        })
}

$formula = if ($Method -eq 'WSJF') {
    '(Value + TimeCriticality + RiskReduction) / JobSize'
}
elseif ($Method -eq 'RICE') {
    '(Reach * Impact * Confidence) / Effort'
}
elseif ($Method -eq 'ICE') {
    'Impact * Confidence * Ease'
}
else {
    '(Desirability + Viability + Feasibility + Contextuality) / 4'
}

Write-Output "[GAP-002 workaround] $Method ranking (APPROXIMATION computed locally from azdw output; not a native azdw calculation)"
Write-Output "Formula: $Method = $formula   (all inputs weighted equally; adjust in this script if your model differs)"
Write-Output ''

$rank = 0
$ranked |
    Sort-Object -Property Score -Descending |
    ForEach-Object {
        $rank++
        [pscustomobject]@{ Rank = $rank; Id = $_.Id; Score = $_.Score; Title = $_.Title; Inputs = $_.Inputs }
    } | Format-Table -AutoSize | Out-String | Write-Output

if ($incomplete.Count -gt 0) {
    Write-Output ''
    Write-Output "[GAP-002 workaround] Excluded from ranking (data-quality; see also Test-PrioritizationData.ps1 / [GAP-004]):"
    $incomplete | Format-Table -AutoSize | Out-String | Write-Output
}
