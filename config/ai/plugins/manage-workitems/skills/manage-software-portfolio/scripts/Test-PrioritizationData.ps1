<#
.SYNOPSIS
    [GAP-004 workaround] Flag prioritization data-quality issues (missing scores,
    duplicate stack ranks) in azdw work item JSON. azdw has no native validation
    of prioritization data.

.DESCRIPTION
    Gap ID:                       GAP-004 (prioritization data-quality checks)
    azdw command producing input: azdw query -t "<type>" --all-fields --format json
                                  (or the equivalent azdw_ MCP query tool)
    Native replacement target:    a future azdw validation / report capability

    This script is bundled CONTENT of the manage-software-portfolio skill. It is
    executed by whichever agent harness loads the skill, NOT by a dedicated azdw
    MCP tool. It is READ-ONLY: it only reads JSON and never calls Azure DevOps.

    Output is clearly labeled as a [GAP-004] workaround. Keep these findings
    SEPARATE from any ranking result.

.PARAMETER Path
    Path to a JSON file produced by azdw. If omitted, JSON is read from stdin.

.PARAMETER ScoreFields
    Comma-separated field reference names that should be populated for prioritization
    (e.g., "Microsoft.VSTS.Common.BusinessValue,Custom.JobSize"). Items missing any
    of these are flagged.

.PARAMETER StackRankField
    Field reference name holding the stack rank. Duplicate non-empty values are
    flagged. Default: Microsoft.VSTS.Common.StackRank.

.EXAMPLE
    azdw query -t "Epic" --all-fields --format json |
        pwsh Test-PrioritizationData.ps1 -ScoreFields "Microsoft.VSTS.Common.BusinessValue,Custom.JobSize"
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Path,

    [Parameter()]
    [string] $ScoreFields = 'Microsoft.VSTS.Common.BusinessValue',

    [Parameter()]
    [string] $StackRankField = 'Microsoft.VSTS.Common.StackRank'
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
    Write-Output "[GAP-004 workaround] No work items found in input."
    return
}

$scoreRefs = $ScoreFields -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }

$missingScores = New-Object System.Collections.Generic.List[object]
$stackRanks = @{}

foreach ($item in $items) {
    $id = Get-ItemId -Item $item

    $missingFor = @()
    foreach ($ref in $scoreRefs) {
        $v = Get-ItemField -Item $item -Reference $ref
        if ([string]::IsNullOrWhiteSpace([string]$v)) { $missingFor += $ref }
    }
    if ($missingFor.Count -gt 0) {
        $missingScores.Add([pscustomobject]@{ Id = $id; MissingFields = ($missingFor -join ', ') })
    }

    $sr = Get-ItemField -Item $item -Reference $StackRankField
    if (-not [string]::IsNullOrWhiteSpace([string]$sr)) {
        $key = [string]$sr
        if (-not $stackRanks.ContainsKey($key)) { $stackRanks[$key] = New-Object System.Collections.Generic.List[object] }
        $stackRanks[$key].Add($id)
    }
}

Write-Output "[GAP-004 workaround] Prioritization data-quality report (local check of azdw output; not a native azdw validation)"
Write-Output ("Items checked: {0}" -f $items.Count)
Write-Output ''

Write-Output "Missing prioritization scores ($($scoreRefs -join ', ')):"
if ($missingScores.Count -eq 0) {
    Write-Output '  none'
}
else {
    $missingScores | Format-Table -AutoSize | Out-String | Write-Output
}

Write-Output ''
$dupes = $stackRanks.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
Write-Output "Duplicate stack ranks ('$StackRankField'):"
if (-not $dupes) {
    Write-Output '  none'
}
else {
    $dupes |
        Sort-Object -Property Name |
        ForEach-Object {
            [pscustomobject]@{ StackRank = $_.Key; Count = $_.Value.Count; Ids = ($_.Value -join ', ') }
        } | Format-Table -AutoSize | Out-String | Write-Output
}
