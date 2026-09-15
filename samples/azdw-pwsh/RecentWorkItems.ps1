#Requires -Version 7.0

<# This sample imports the packaged PowerShell module and demonstrates a
    read-only workflow: discover connections, display them, and query the
    three most recently changed work items for each connection. #>
[CmdletBinding()]
param(
    # Accept a package directory or a direct module manifest. The environment
    # variable makes the same script convenient in CI and local terminals.
    [Parameter(Position = 0)]
    [string]$PackageRoot = $env:AZDW_PACKAGE_ROOT
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ModuleManifest {
    # Locate the module manifest inside supported client-package layouts. This
    # keeps the sample independent of the package extraction directory name.
    param(
        [Parameter(Mandatory)]
        [string]$Root
    )

    # A direct .psd1 argument is already the exact file PowerShell needs.
    $rootPath = (Resolve-Path -LiteralPath $Root).Path
    $candidates = if ($rootPath.EndsWith('.psd1', [System.StringComparison]::OrdinalIgnoreCase)) {
        @($rootPath)
    }
    else {
        @(
            (Join-Path $rootPath 'src/azdw.pwsh/azdw.psd1'),
            (Join-Path $rootPath 'powershell/Azdw/Azdw.psd1'),
            (Join-Path $rootPath 'powershell/azdw/azdw.psd1')
        )
    }

    foreach ($candidate in $candidates) {
        # Return the first packaged module that exists; the remaining candidates
        # are compatibility locations used by older package layouts.
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw "Could not find the packaged azdw PowerShell module under '$rootPath'."
}

function Get-PropertyValue {
    # The module can return either strongly shaped objects or objects that keep
    # Azure DevOps values under a Fields map. Normalize both forms for display.
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        [object]$Object,

        [Parameter(Mandatory)]
        [string[]]$Names
    )

    if ($null -eq $Object) {
        return $null
    }

    # Prefer top-level properties because they are the stable facade shape.
    foreach ($name in $Names) {
        $property = $Object.PSObject.Properties[$name]
        if ($null -ne $property) {
            return $property.Value
        }
    }

    # Fall back to the raw field bag used by work-item responses when a value is
    # not projected to the top level.
    $fields = $Object.PSObject.Properties['Fields']
    if ($null -ne $fields -and $null -ne $fields.Value) {
        foreach ($name in $Names) {
            if ($fields.Value -is [System.Collections.IDictionary] -and $fields.Value.Contains($name)) {
                return $fields.Value[$name]
            }

            $field = $fields.Value.PSObject.Properties[$name]
            if ($null -ne $field) {
                return $field.Value
            }
        }
    }

    return $null
}

<# Validate the input before resolving paths so the user gets a useful command
    example instead of a path-resolution exception. #>
if ([string]::IsNullOrWhiteSpace($PackageRoot)) {
    Write-Error 'Usage: pwsh -File samples/azdw-pwsh/RecentWorkItems.ps1 <extracted-azdw-package-or-module-manifest>'
    Write-Error 'Or set AZDW_PACKAGE_ROOT to the extracted package directory.'
    exit 2
}

try {
    # Import the module from the extracted package. The module itself locates
    # the azdw executable on PATH, so this sample does not invoke it directly.
    $moduleManifest = Resolve-ModuleManifest -Root $PackageRoot
    Import-Module -Name $moduleManifest -Force

    # Get-AzdwConnection reads the user's configured connections and credentials
    # through the packaged module's normal configuration path.
    $connections = @(Get-AzdwConnection)
    Write-Output 'Configured connections'

    if ($connections.Count -eq 0) {
        Write-Output '  No connections configured.'
        exit 0
    }

    # Project the connection objects into a compact table shape. Property names
    # vary slightly between provider versions, so the helper handles aliases.
    $connections |
        ForEach-Object {
            [PSCustomObject]@{
                Name = Get-PropertyValue -Object $_ -Names @('Name', 'ConnectionName')
                Provider = Get-PropertyValue -Object $_ -Names @('Provider')
                Status = Get-PropertyValue -Object $_ -Names @('ConnectionStatus', 'Status')
                BaseUrl = Get-PropertyValue -Object $_ -Names @('BaseUrl', 'Url')
            }
        } |
        Format-Table -AutoSize

    # Query each connection independently. This preserves the connection label
    # beside every result and prevents one provider's failure from hiding the
    # successful results from the other providers.
    Write-Output 'Most recently changed 3 work items per connection'
    foreach ($connection in $connections) {
        $connectionName = [string](Get-PropertyValue -Object $connection -Names @('Name', 'ConnectionName'))
        Write-Output "  $connectionName"

        # The packaged cmdlet performs the actual provider query. The ordering
        # field and limit make the output small enough to inspect at a glance.
        $workItems = @(
            Get-AzdwWorkItem `
                -Connections $connectionName `
                -MaxResults 3 `
                -Sort 'System.ChangedDate:desc' `
                -NoConfirm
        )

        if ($workItems.Count -eq 0) {
            Write-Output '    No work items returned.'
            continue
        }

        # Normalize common work-item property names before printing one readable
        # line per item, including values stored in the raw Fields dictionary.
        $workItems |
            ForEach-Object {
                $id = Get-PropertyValue -Object $_ -Names @('Id', 'System.Id')
                $type = Get-PropertyValue -Object $_ -Names @('Type', 'WorkItemType', 'System.WorkItemType')
                $title = Get-PropertyValue -Object $_ -Names @('Title', 'System.Title')
                $changedDate = Get-PropertyValue -Object $_ -Names @('ChangedDate', 'System.ChangedDate')
                Write-Output "    #$id | $type | $title | changed $changedDate"
            }
    }
}
catch {
    # Keep the sample script-friendly: emit one concise error and return a
    # non-zero exit code for automation.
    Write-Error "Sample failed: $($_.Exception.Message)"
    exit 1
}
