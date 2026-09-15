#!/usr/bin/env pwsh

#Requires -Version 7.0

<#
.SYNOPSIS
    Starts the packaged azdw API service and opens the REST sample in a browser.

.DESCRIPTION
    This launcher is intended for an extracted azdw client package. It starts
    the platform-specific azdw.service executable from the package, serves the
    local sample HTML over HTTP, waits for both endpoints to respond, and opens
    the sample page in the operating system's default browser. The static page
    is served by a child PowerShell process using .NET HttpListener.

    Press Ctrl+C to stop the launcher. The child API and static-file processes
    are stopped automatically when this script exits.

.PARAMETER PackageRoot
    Extracted azdw client package directory. Defaults to AZDW_PACKAGE_ROOT.

.PARAMETER ApiPort
    Local port for azdw.service. Defaults to 5016.

.PARAMETER SamplePort
    Local port for the static sample server. Defaults to 8080.

.PARAMETER NoBrowser
    Start both servers but do not open the browser automatically.

.PARAMETER ServiceArguments
    Additional arguments forwarded to azdw.service after --urls.

.PARAMETER StaticServer
    Internal mode used by the launcher to host the sample page in a child
    PowerShell process. This parameter is not normally passed by users.

.PARAMETER StaticRoot
    Internal directory containing the sample page.

.EXAMPLE
    pwsh -File samples/rest-api/Start-RestApiSample.ps1 /path/to/azdw-package

.EXAMPLE
    pwsh -File samples/rest-api/Start-RestApiSample.ps1 `
        -PackageRoot /path/to/azdw-package -ApiPort 5017 -SamplePort 8081
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$PackageRoot = $env:AZDW_PACKAGE_ROOT,

    [ValidateRange(1, 65535)]
    [int]$ApiPort = 5016,

    [ValidateRange(1, 65535)]
    [int]$SamplePort = 8080,

    [switch]$NoBrowser,

    [switch]$StaticServer,

    [string]$StaticRoot,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ServiceArguments = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$serviceProcess = $null
$sampleProcess = $null

function Resolve-PackageRoot {
    param(
        [Parameter(Mandatory)]
        [string]$Root
    )

    if ([string]::IsNullOrWhiteSpace($Root)) {
        throw 'Package root is required. Pass an extracted client package directory or set AZDW_PACKAGE_ROOT.'
    }

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        throw "Package directory not found: $Root"
    }

    return (Resolve-Path -LiteralPath $Root).Path
}

function Get-PlatformRuntimeId {
    # The package stores each self-contained executable under dist/<runtime>/api.
    if ($IsWindows) {
        $osPrefix = 'win'
    }
    elseif ($IsMacOS) {
        $osPrefix = 'osx'
    }
    elseif ($IsLinux) {
        $osPrefix = 'linux'
    }
    else {
        throw 'Unsupported operating system. This sample supports Windows, macOS, and Linux.'
    }

    $architecture = switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture) {
        ([System.Runtime.InteropServices.Architecture]::X64) { 'x64'; break }
        ([System.Runtime.InteropServices.Architecture]::Arm64) { 'arm64'; break }
        default { throw 'Unsupported CPU architecture. This sample supports x64 and arm64.' }
    }

    return "$osPrefix-$architecture"
}

function Resolve-ServicePath {
    param(
        [Parameter(Mandatory)]
        [string]$Root,

        [Parameter(Mandatory)]
        [string]$RuntimeId
    )

    $serviceName = if ($IsWindows) { 'azdw.service.exe' } else { 'azdw.service' }
    $servicePath = Join-Path $Root "dist/$RuntimeId/api/$serviceName"

    if (-not (Test-Path -LiteralPath $servicePath -PathType Leaf)) {
        throw "Packaged API service executable not found for ${RuntimeId}: $servicePath"
    }

    return (Resolve-Path -LiteralPath $servicePath).Path
}

function Start-ChildProcess {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    # ArgumentList avoids shell quoting differences between Windows, macOS, and
    # Linux when package paths contain spaces.
    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $FilePath
    $startInfo.WorkingDirectory = $WorkingDirectory
    $startInfo.UseShellExecute = $false

    foreach ($argument in $Arguments) {
        [void]$startInfo.ArgumentList.Add($argument)
    }

    $process = [System.Diagnostics.Process]::Start($startInfo)
    if ($null -eq $process) {
        throw "Could not start process: $FilePath"
    }

    return $process
}

function Wait-ForHttpEndpoint {
    param(
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [System.Diagnostics.Process]$Process,

        [Parameter(Mandatory)]
        [string]$Description,

        [int]$TimeoutSeconds = 30
    )

    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    while ([DateTime]::UtcNow -lt $deadline) {
        if ($Process.HasExited) {
            throw "$Description exited before it became ready (exit code $($Process.ExitCode))."
        }

        try {
            # Any HTTP response proves that the listener is ready. The endpoint
            # can return a non-success status while still being operational.
            $response = Invoke-WebRequest -Uri $Uri -Method Get -TimeoutSec 2 -SkipHttpErrorCheck
            if ($response.StatusCode -ge 100) {
                return
            }
        }
        catch {
            # Startup is asynchronous; retry until the deadline instead of
            # treating the initial connection refusal as a permanent failure.
        }

        Start-Sleep -Milliseconds 250
    }

    throw "$Description did not respond at $Uri within $TimeoutSeconds seconds."
}

function Get-PowerShellCommand {
    # The launcher already requires PowerShell 7. Start the static server in a
    # second instance so the parent can continue polling the API and own both
    # child-process lifetimes.
    $powerShell = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($null -eq $powerShell) {
        throw 'PowerShell 7 (pwsh) could not be found on PATH.'
    }

    return $powerShell.Source
}

function Start-StaticFileServer {
    param(
        [Parameter(Mandatory)]
        [string]$Root,

        [Parameter(Mandatory)]
        [int]$Port
    )

    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        throw "Static sample directory not found: $Root"
    }

    $resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
    $indexPath = Join-Path $resolvedRoot 'index.html'
    if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) {
        throw "REST sample page not found: $indexPath"
    }

    # HttpListener is part of the .NET runtime available to PowerShell 7. It
    # provides the one small HTTP host this static, dependency-free sample needs.
    $listener = [System.Net.HttpListener]::new()
    $prefix = "http://127.0.0.1:$Port/"
    $listener.Prefixes.Add($prefix)

    try {
        $listener.Start()
        Write-Host "Serving REST sample from $resolvedRoot at $prefix"

        while ($listener.IsListening) {
            $context = $listener.GetContext()
            $response = $context.Response

            try {
                # Only expose the sample page. Avoid translating arbitrary URL
                # paths into filesystem paths, which also avoids traversal risk.
                $requestedPath = $context.Request.Url.AbsolutePath
                if ($requestedPath -eq '/' -or $requestedPath -eq '/index.html') {
                    $content = [System.IO.File]::ReadAllBytes($indexPath)
                    $response.StatusCode = 200
                    $response.ContentType = 'text/html; charset=utf-8'
                }
                else {
                    $content = [System.Text.Encoding]::UTF8.GetBytes('Not found')
                    $response.StatusCode = 404
                    $response.ContentType = 'text/plain; charset=utf-8'
                }

                $response.ContentLength64 = $content.Length
                $response.OutputStream.Write($content, 0, $content.Length)
            }
            finally {
                $response.Close()
            }
        }
    }
    finally {
        $listener.Stop()
        $listener.Close()
    }
}

function Open-DefaultBrowser {
    param(
        [Parameter(Mandatory)]
        [string]$Uri
    )

    if ($IsWindows) {
        Start-Process -FilePath $Uri | Out-Null
    }
    elseif ($IsMacOS) {
        & open $Uri
        if ($LASTEXITCODE -ne 0) {
            throw "Could not open the default browser for $Uri."
        }
    }
    elseif ($IsLinux) {
        & xdg-open $Uri
        if ($LASTEXITCODE -ne 0) {
            throw "Could not open the default browser for $Uri."
        }
    }
    else {
        Start-Process -FilePath $Uri | Out-Null
    }
}

function Stop-ChildProcess {
    param(
        [AllowNull()]
        [System.Diagnostics.Process]$Process
    )

    if ($null -eq $Process) {
        return
    }

    try {
        if (-not $Process.HasExited) {
            Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue
        }
    }
    finally {
        $Process.Dispose()
    }
}

# The parent launcher starts this private mode in a child PowerShell process so
# HttpListener can block on requests without blocking API startup and browser
# orchestration in the parent process.
if ($StaticServer) {
    try {
        Start-StaticFileServer -Root $StaticRoot -Port $SamplePort
        exit 0
    }
    catch {
        Write-Error "Static sample server failed: $($_.Exception.Message)"
        exit 1
    }
}

try {
    $resolvedPackageRoot = Resolve-PackageRoot -Root $PackageRoot
    $runtimeId = Get-PlatformRuntimeId
    $servicePath = Resolve-ServicePath -Root $resolvedPackageRoot -RuntimeId $runtimeId
    $apiUri = "http://127.0.0.1:$ApiPort"
    $sampleUri = "http://127.0.0.1:$SamplePort/index.html"

    # Unix package extraction can lose the executable bit. Restore it before
    # launching the self-contained service; Windows does not need this step.
    if (-not $IsWindows) {
        $serviceItem = Get-Item -LiteralPath $servicePath
        if ($serviceItem.Mode -notmatch 'x') {
            & chmod +x $servicePath
            if ($LASTEXITCODE -ne 0) {
                throw "Could not make the packaged API service executable: $servicePath"
            }
        }
    }

    Write-Host "Starting azdw API service for $runtimeId..."
    $serviceArguments = @('--urls', $apiUri) + $ServiceArguments
    $serviceProcess = Start-ChildProcess `
        -FilePath $servicePath `
        -WorkingDirectory $resolvedPackageRoot `
        -Arguments $serviceArguments

    Write-Host "Starting the REST sample server on $sampleUri..."
    $powerShellPath = Get-PowerShellCommand
    $sampleProcess = Start-ChildProcess `
        -FilePath $powerShellPath `
        -WorkingDirectory $PSScriptRoot `
        -Arguments @(
            '-NoProfile',
            '-File',
            $PSCommandPath,
            '-StaticServer',
            '-StaticRoot',
            $PSScriptRoot,
            '-SamplePort',
            $SamplePort.ToString()
        )

    Wait-ForHttpEndpoint -Uri "$apiUri/api/v1/health" -Process $serviceProcess -Description 'azdw API service'
    Wait-ForHttpEndpoint -Uri $sampleUri -Process $sampleProcess -Description 'REST sample server'

    if (-not $NoBrowser) {
        Write-Host "Opening $sampleUri in the default browser..."
        Open-DefaultBrowser -Uri $sampleUri
    }
    else {
        Write-Host "Browser launch skipped (-NoBrowser)."
    }

    Write-Host "The REST sample is ready at $sampleUri"
    Write-Host 'Press Ctrl+C to stop both child processes.'

    while (-not $serviceProcess.HasExited) {
        Start-Sleep -Seconds 1
    }

    if ($serviceProcess.ExitCode -ne 0) {
        throw "azdw API service stopped with exit code $($serviceProcess.ExitCode)."
    }
}
catch {
    Write-Error "REST sample failed: $($_.Exception.Message)"
    exit 1
}
finally {
    Stop-ChildProcess -Process $sampleProcess
    Stop-ChildProcess -Process $serviceProcess
}
