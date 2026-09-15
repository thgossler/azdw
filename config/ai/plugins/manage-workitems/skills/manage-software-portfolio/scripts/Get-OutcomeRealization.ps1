<#
.SYNOPSIS
    [GAP-005 workaround] Roll up expected business-case benefit and realization-stage
    coverage from azdw work item JSON. azdw has no native outcome/benefit metric.

.DESCRIPTION
    Gap ID:                       GAP-005 (outcome / benefit-realization rollup)
    azdw command producing input: azdw query -t "<portfolio-type>" --all-fields --format json
                                  (or the equivalent azdw_ MCP query tool)
    Native replacement target:    a future azdw outcome / benefit metric on query/report

    This script is bundled CONTENT of the manage-software-portfolio skill, executed by
    whichever agent harness loads the skill (NOT a dedicated azdw MCP tool). It is
    READ-ONLY: it only reads JSON and never calls Azure DevOps.

    Per item it computes an EXPECTED business-case value (sum of one or more value
    fields), an investment figure, and an expected return ratio; flags whether the
    item has reached a realization state; and, when an actual/realized value field is
    supplied, a realization % (actual / expected). It then aggregates the expected
    value that reached realization vs the total committed (a value-weighted
    realization funnel).

    IMPORTANT: "reached a realization state" and the "expected" business case are
    LEADING PROXIES for outcome, not an independently verified realized outcome.
    Output is labeled [GAP-005] so it is never mistaken for native azdw output or for
    audited financials.

.PARAMETER Path
    Path to a JSON file produced by azdw. If omitted, JSON is read from stdin.

.PARAMETER ValueFields
    Comma-separated numeric field reference names whose sum is the EXPECTED value per
    item. Default: Microsoft.VSTS.Common.BusinessValue.

.PARAMETER InvestmentField
    Numeric field reference name used as the investment / cost denominator for the
    expected-return ratio. Default: Microsoft.VSTS.Scheduling.Effort.

.PARAMETER StateField
    State field reference name. Default: System.State.

.PARAMETER RealizedStates
    Comma-separated state values that count as "reached realization".
    Default: 'Closed,Done'.

.PARAMETER ActualValueField
    Optional numeric field reference name holding the ACTUAL / realized value. When
    set, the script computes realization % = actual / expected per item and overall.

.PARAMETER IdField
    Field used as the item identifier in output. Default: System.Id.

.PARAMETER TitleField
    Field used as the item title in output. Default: System.Title.

.EXAMPLE
    azdw query -t "Epic" --all-fields --format json |
        pwsh Get-OutcomeRealization.ps1

.EXAMPLE
    azdw query -t "Epic" --all-fields --format json |
        pwsh Get-OutcomeRealization.ps1 -ActualValueField Custom.RealizedValue
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path,

    [Parameter()]
    [string] $ValueFields = 'Microsoft.VSTS.Common.BusinessValue',

    [Parameter()]
    [string] $InvestmentField = 'Microsoft.VSTS.Scheduling.Effort',

    [Parameter()]
    [string] $StateField = 'System.State',

    [Parameter()]
    [string] $RealizedStates = 'Closed,Done',

    [Parameter()]
    [string] $ActualValueField,

    [Parameter()]
    [string] $IdField = 'System.Id',

    [Parameter()]
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

function ConvertTo-Number {
    param($Raw)
    $n = 0.0
    if ([double]::TryParse([string]$Raw, [ref] $n)) { return $n }
    return $null
}

# ------------------------------------------------------------------------------

$items = @(Get-AzdwJson -Path $Path)

if ($items.Count -eq 0) {
    Write-Output "[GAP-005 workaround] No work items found in input."
    return
}

$valueFieldList = @($ValueFields -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$realizedSet = @($RealizedStates -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$haveActual = -not [string]::IsNullOrWhiteSpace($ActualValueField)

$rows = New-Object System.Collections.Generic.List[object]
$totalExpected = 0.0
$realizedExpected = 0.0
$totalActual = 0.0
$realizedCount = 0
$missingValueCount = 0

foreach ($item in $items) {
    $expected = 0.0
    $anyValue = $false
    foreach ($vf in $valueFieldList) {
        $num = ConvertTo-Number (Get-ItemField -Item $item -Reference $vf)
        if ($null -ne $num) { $expected += $num; $anyValue = $true }
    }
    if (-not $anyValue) { $missingValueCount++ }

    $investment = ConvertTo-Number (Get-ItemField -Item $item -Reference $InvestmentField)
    $roi = if (($null -ne $investment) -and ($investment -ne 0)) { [math]::Round($expected / $investment, 2) } else { $null }

    $state = [string](Get-ItemField -Item $item -Reference $StateField)
    $isRealized = $realizedSet -contains $state

    $actual = $null
    $realizationPct = $null
    if ($haveActual) {
        $actual = ConvertTo-Number (Get-ItemField -Item $item -Reference $ActualValueField)
        if ($null -ne $actual) {
            if ($expected -ne 0) { $realizationPct = [math]::Round(($actual / $expected) * 100, 1) }
            $totalActual += $actual
        }
    }

    $totalExpected += $expected
    if ($isRealized) { $realizedExpected += $expected; $realizedCount++ }

    $row = [ordered]@{
        Id            = [string](Get-ItemField -Item $item -Reference $IdField)
        Title         = [string](Get-ItemField -Item $item -Reference $TitleField)
        State         = $state
        Realized      = if ($isRealized) { 'yes' } else { 'no' }
        ExpectedValue = [math]::Round($expected, 2)
        Investment    = if ($null -ne $investment) { [math]::Round($investment, 2) } else { '' }
        ExpReturn     = if ($null -ne $roi) { $roi } else { '' }
    }
    if ($haveActual) {
        $row.ActualValue = if ($null -ne $actual) { [math]::Round($actual, 2) } else { '' }
        $row.Realization = if ($null -ne $realizationPct) { "$realizationPct%" } else { '' }
    }
    $rows.Add([pscustomobject]$row)
}

$total = $items.Count
$valRealPct = if ($totalExpected -ne 0) { [math]::Round(($realizedExpected / $totalExpected) * 100, 1) } else { 0 }

Write-Output "[GAP-005 workaround] Outcome / benefit realization (local rollup of azdw output; EXPECTED business case + realization stage, NOT an audited or independently verified outcome)"
Write-Output ("Items: {0}  |  Reached a realization state [{1}]: {2}" -f $total, $RealizedStates, $realizedCount)
Write-Output ("Expected value (total committed): {0}" -f [math]::Round($totalExpected, 2))
Write-Output ("Expected value that reached realization: {0}" -f [math]::Round($realizedExpected, 2))
Write-Output ("Value-weighted realization: {0}% of expected value has reached a realization state" -f $valRealPct)
if ($haveActual) {
    $totRealPct = if ($totalExpected -ne 0) { [math]::Round(($totalActual / $totalExpected) * 100, 1) } else { 0 }
    Write-Output ("Actual value (where '{0}' is populated): {1}" -f $ActualValueField, [math]::Round($totalActual, 2))
    Write-Output ("Overall realization %: {0}% (actual / expected)" -f $totRealPct)
}
Write-Output ''

$rows | Format-Table -AutoSize | Out-String | Write-Output

if ($missingValueCount -gt 0) {
    Write-Output "Note: $missingValueCount item(s) had no numeric value in any of [$ValueFields] and contributed 0 expected value."
}
Write-Output "Note: 'reached a realization state' (state in [$RealizedStates]) and the EXPECTED business case are leading proxies for outcome, not independently verified realized benefit."
if (-not $haveActual) {
    Write-Output "Note: no -ActualValueField supplied, so realization % is not computed. Provide a realized/actual value field to compare actual vs expected."
}
Write-Output "Note: all figures are a local rollup of values already present in the azdw output (labeled [GAP-005]); they are only as complete as those fields' data and are not audited financials."
