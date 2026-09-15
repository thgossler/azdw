<#
.SYNOPSIS
    [GAP-001 workaround] Aggregate azdw work item JSON into a funnel / state (or
    any-field) distribution. azdw has no native aggregation/grouping.

.DESCRIPTION
    Gap ID:                   GAP-001 (aggregation / grouping)
    azdw command producing input: azdw query -t "<type>" --format json
                                  (or the equivalent azdw_ MCP query tool)
    Native replacement target: a future azdw `query` aggregation / `--group-by` flag

    This script is bundled CONTENT of the manage-software-portfolio skill. It is
    executed by whichever agent harness loads the skill, NOT by a dedicated azdw
    MCP tool. It is READ-ONLY: it only reads JSON and never calls Azure DevOps.

    Output is clearly labeled as a [GAP-001] workaround so it is never mistaken
    for native azdw output.

.PARAMETER Path
    Path to a JSON file produced by azdw (query/wiql --format json). If omitted,
    JSON is read from stdin.

.PARAMETER GroupByField
    Field reference name to group by (e.g., System.State, or an Investment Horizon
    / Value Stream custom field reference name from portfolio-mapping.md).
    Default: System.State.

.PARAMETER SumField
    Optional numeric field reference name to total per group (e.g., an estimated
    revenue / investment field for investment-allocation rollups, or an effort /
    job-size field for planned-load rollups). When set, the output adds Sum and
    SumPercent columns plus a grand total. The sum is a LOCAL rollup of values
    already present in the azdw output — not a financial-system figure — and is only
    as complete as that field's data. azdw has no native sum aggregation.

.EXAMPLE
    azdw query -t "Epic" --format json > items.json
    pwsh Get-PortfolioFunnel.ps1 -Path items.json -GroupByField System.State

.EXAMPLE
    azdw query -t "Epic" --all-fields --format json |
        pwsh Get-PortfolioFunnel.ps1 -GroupByField Custom.InvestmentHorizon
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path,

    [Parameter()]
    [string] $GroupByField = 'System.State',

    [Parameter()]
    [string] $SumField
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
    # Wrapper object: unwrap a common items property if present.
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

# ------------------------------------------------------------------------------

$items = @(Get-AzdwJson -Path $Path)

if ($items.Count -eq 0) {
    Write-Output "[GAP-001 workaround] No work items found in input."
    return
}

$haveSum = -not [string]::IsNullOrWhiteSpace($SumField)
$groups = @{}
$missing = 0
$sumMissing = 0
$grandSum = 0.0
foreach ($item in $items) {
    $value = Get-ItemField -Item $item -Reference $GroupByField
    if ([string]::IsNullOrWhiteSpace([string]$value)) {
        $missing++
        $value = '(unset)'
    }
    $key = [string]$value
    if (-not $groups.ContainsKey($key)) { $groups[$key] = @{ Count = 0; Sum = 0.0 } }
    $groups[$key].Count++
    if ($haveSum) {
        $raw = Get-ItemField -Item $item -Reference $SumField
        $num = 0.0
        if ([double]::TryParse([string]$raw, [ref] $num)) {
            $groups[$key].Sum += $num
            $grandSum += $num
        }
        else {
            $sumMissing++
        }
    }
}

$total = $items.Count

$heading = if ($haveSum) {
    "[GAP-001 workaround] Distribution by '$GroupByField' with sum of '$SumField' (local aggregation of azdw output; not a native azdw metric)"
}
else {
    "[GAP-001 workaround] Distribution by '$GroupByField' (local aggregation of azdw output; not a native azdw metric)"
}
Write-Output $heading
Write-Output ("Total items: {0}" -f $total)
if ($haveSum) { Write-Output ("Total '{0}': {1}" -f $SumField, [math]::Round($grandSum, 2)) }
Write-Output ''

$rows = $groups.GetEnumerator() |
    Sort-Object -Property { $_.Value.Count } -Descending |
    ForEach-Object {
        $row = [ordered]@{
            Value   = $_.Key
            Count   = $_.Value.Count
            Percent = if ($total -gt 0) { [math]::Round(($_.Value.Count / $total) * 100, 1) } else { 0 }
        }
        if ($haveSum) {
            $row.Sum = [math]::Round($_.Value.Sum, 2)
            $row.SumPercent = if ($grandSum -ne 0) { [math]::Round(($_.Value.Sum / $grandSum) * 100, 1) } else { 0 }
        }
        [pscustomobject]$row
    }

$rows | Format-Table -AutoSize | Out-String | Write-Output

if ($missing -gt 0) {
    Write-Output "Note: $missing item(s) had no value for '$GroupByField' (shown as '(unset)')."
}
if ($haveSum -and $sumMissing -gt 0) {
    Write-Output "Note: $sumMissing item(s) had no numeric '$SumField' value and contributed 0 to the sum."
}
if ($haveSum) {
    Write-Output "Note: the sum totals the per-item '$SumField' values already present in the azdw output; it is a local rollup, not a financial-system figure, and is only as complete as that field's data."
}
