<#
.SYNOPSIS
    [GAP-003 workaround] Derive an APPROXIMATE completion percentage from the child
    item states in an azdw relationship closure. azdw has no native progress/rollup
    metric.

.DESCRIPTION
    Gap ID:                       GAP-003 (progress rollup from a hierarchy)
    azdw command producing input: azdw relationship find-closure -i <id> -c "<conn>" --json
                                  (or the equivalent azdw_ MCP closure tool)
    Native replacement target:    a future azdw closure progress / rollup metric

    This script is bundled CONTENT of the manage-software-portfolio skill. It is
    executed by whichever agent harness loads the skill, NOT by a dedicated azdw
    MCP tool. It is READ-ONLY: it only reads JSON and never calls Azure DevOps.

    The completion percentage is an APPROXIMATION of output (state-based), clearly
    labeled as a [GAP-003] workaround. It is NOT realized business outcome and NOT
    a tool-provided metric.

.PARAMETER Path
    Path to a closure JSON file produced by azdw find-closure. If omitted, JSON is
    read from stdin.

.PARAMETER DoneStates
    Comma-separated state names considered "complete". Default:
    "Closed,Done,Completed,Resolved".

.PARAMETER ExcludeStates
    Comma-separated state names to exclude from the denominator (e.g., Removed).
    Default: "Removed".

.EXAMPLE
    azdw relationship find-closure -i 12345 -c "Portfolio" --json |
        pwsh Get-ProgressRollup.ps1 -DoneStates "Closed,Done"
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path,

    [Parameter()]
    [string] $DoneStates = 'Closed,Done,Completed,Resolved',

    [Parameter()]
    [string] $ExcludeStates = 'Removed'
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
    # Closure output may wrap items under several property names.
    foreach ($prop in 'items', 'workItems', 'closure', 'value', 'results', 'data', 'nodes') {
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
    Write-Output "[GAP-003 workaround] No work items found in closure input."
    return
}

$doneSet = @{}; ($DoneStates -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) | ForEach-Object { $doneSet[$_.ToLowerInvariant()] = $true }
$excludeSet = @{}; ($ExcludeStates -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) | ForEach-Object { $excludeSet[$_.ToLowerInvariant()] = $true }

$byType = @{}
$counted = 0
$done = 0

foreach ($item in $items) {
    $state = [string](Get-ItemField -Item $item -Reference 'System.State')
    $type = [string](Get-ItemField -Item $item -Reference 'System.WorkItemType')
    if ([string]::IsNullOrWhiteSpace($type)) { $type = '(unknown type)' }
    $stateKey = $state.ToLowerInvariant()

    if ($excludeSet.ContainsKey($stateKey)) { continue }

    $counted++
    $isDone = $doneSet.ContainsKey($stateKey)
    if ($isDone) { $done++ }

    if (-not $byType.ContainsKey($type)) { $byType[$type] = @{ Total = 0; Done = 0 } }
    $byType[$type].Total++
    if ($isDone) { $byType[$type].Done++ }
}

$pct = if ($counted -gt 0) { [math]::Round(($done / $counted) * 100, 1) } else { 0 }

Write-Output "[GAP-003 workaround] Approximate completion (state-based rollup of azdw closure output; APPROXIMATION, not a native azdw metric)"
Write-Output "Done states: $DoneStates   Excluded: $ExcludeStates"
Write-Output ("Overall: {0}/{1} items in a done state = ~{2}% complete (approximate)" -f $done, $counted, $pct)
Write-Output ''

$byType.GetEnumerator() |
    Sort-Object -Property Name |
    ForEach-Object {
        $t = $_.Value
        [pscustomobject]@{
            Type      = $_.Key
            Done      = $t.Done
            Total     = $t.Total
            ApproxPct = if ($t.Total -gt 0) { [math]::Round(($t.Done / $t.Total) * 100, 1) } else { 0 }
        }
    } | Format-Table -AutoSize | Out-String | Write-Output

Write-Output "Note: '% complete' counts items in a done state; it does not weight by effort and is not realized business outcome."
