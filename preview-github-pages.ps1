#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [int]$Port = 4000
)

$ErrorActionPreference = "Stop"

function Get-PlatformName {
    if ($env:OS -eq "Windows_NT") {
        return "Windows"
    }

    if ($env:OSTYPE -like "darwin*" -or (Test-Path "/System/Library/CoreServices/SystemVersion.plist")) {
        return "macOS"
    }

    if ([Environment]::OSVersion.Platform -eq [PlatformID]::Unix) {
        return "Linux"
    }

    throw "Unsupported operating system. This script supports Windows, macOS, and Linux."
}

function Get-ToolPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $command) {
        return $null
    }

    if ($command.PSObject.Properties.Name -contains "Path" -and -not [string]::IsNullOrWhiteSpace([string]$command.Path)) {
        return [string]$command.Path
    }

    if ($command.PSObject.Properties.Name -contains "Source" -and -not [string]::IsNullOrWhiteSpace([string]$command.Source)) {
        return [string]$command.Source
    }

    return [string]$command.Definition
}

function Add-ToProcessPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return
    }

    $separator = [IO.Path]::PathSeparator
    $entries = @($env:PATH -split [Regex]::Escape($separator))
    if ($entries -notcontains $Path) {
        $env:PATH = "$Path$separator$env:PATH"
    }
}

function Refresh-WindowsPath {
    if ((Get-PlatformName) -ne "Windows") {
        return
    }

    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $paths = @($userPath, $machinePath, $env:PATH) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $env:PATH = $paths -join [IO.Path]::PathSeparator
}

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string[]]$Arguments = @()
    )

    & $Path @Arguments | Out-Host
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "Command failed with exit code $exitCode`: $Path $($Arguments -join ' ')"
    }
}

function Get-RubyVersion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RubyPath
    )

    $versionText = (& $RubyPath -e "print RUBY_VERSION" 2>$null | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($versionText)) {
        return $null
    }

    try {
        return [version]$versionText
    } catch {
        return $null
    }
}

function Invoke-LinuxPackageCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Tool,
        [string[]]$Arguments = @()
    )

    $sudo = Get-ToolPath "sudo"
    if ($null -ne $sudo) {
        Invoke-Checked $sudo (@($Tool) + $Arguments)
        return
    }

    if ([Environment]::UserName -eq "root") {
        Invoke-Checked $Tool $Arguments
        return
    }

    throw "The $Tool package manager requires sudo. Install Ruby manually or install sudo, then run this script again."
}

function Install-Ruby {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Platform
    )

    switch ($Platform) {
        "macOS" {
            $brew = Get-ToolPath "brew"
            if ($null -eq $brew) {
                throw "Ruby is missing and Homebrew is not installed. Install Homebrew from https://brew.sh, then run this script again."
            }

            Write-Host "Installing Ruby with Homebrew..."
            Invoke-Checked $brew @("install", "ruby")
            $rubyPrefix = (& $brew --prefix ruby 2>$null | Out-String).Trim()
            if (-not [string]::IsNullOrWhiteSpace($rubyPrefix)) {
                Add-ToProcessPath (Join-Path $rubyPrefix "bin")
            }
        }
        "Linux" {
            $apt = Get-ToolPath "apt-get"
            $dnf = Get-ToolPath "dnf"
            $pacman = Get-ToolPath "pacman"
            $zypper = Get-ToolPath "zypper"

            if ($null -ne $apt) {
                Write-Host "Installing Ruby with apt..."
                Invoke-LinuxPackageCommand $apt @("update")
                Invoke-LinuxPackageCommand $apt @("install", "-y", "ruby-full", "ruby-dev", "build-essential")
            } elseif ($null -ne $dnf) {
                Write-Host "Installing Ruby with dnf..."
                Invoke-LinuxPackageCommand $dnf @("install", "-y", "ruby", "ruby-devel", "gcc", "make")
            } elseif ($null -ne $pacman) {
                Write-Host "Installing Ruby with pacman..."
                Invoke-LinuxPackageCommand $pacman @("-Sy", "--needed", "--noconfirm", "ruby", "base-devel")
            } elseif ($null -ne $zypper) {
                Write-Host "Installing Ruby with zypper..."
                Invoke-LinuxPackageCommand $zypper @("install", "-y", "ruby", "ruby-devel", "gcc", "make")
            } else {
                throw "Ruby is missing and no supported Linux package manager was found. Install Ruby 2.7 or newer, then run this script again."
            }
        }
        "Windows" {
            $winget = Get-ToolPath "winget"
            $choco = Get-ToolPath "choco"
            $scoop = Get-ToolPath "scoop"

            if ($null -ne $winget) {
                Write-Host "Installing Ruby with WinGet..."
                Invoke-Checked $winget @(
                    "install",
                    "--id",
                    "RubyInstallerTeam.RubyWithDevkit.3.3",
                    "--exact",
                    "--source",
                    "winget",
                    "--accept-source-agreements",
                    "--accept-package-agreements"
                )
            } elseif ($null -ne $choco) {
                Write-Host "Installing Ruby with Chocolatey..."
                Invoke-Checked $choco @("install", "ruby", "-y")
            } elseif ($null -ne $scoop) {
                Write-Host "Installing Ruby with Scoop..."
                Invoke-Checked $scoop @("install", "ruby")
            } else {
                throw "Ruby is missing and no supported Windows package manager was found. Install RubyInstaller, WinGet, Chocolatey, or Scoop, then run this script again."
            }

            Refresh-WindowsPath
        }
    }
}

function Ensure-Ruby {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Platform
    )

    $ruby = Get-ToolPath "ruby"
    $rubyVersion = if ($null -ne $ruby) { Get-RubyVersion $ruby } else { $null }
    if ($null -ne $rubyVersion -and $rubyVersion -ge [version]"2.7.0") {
        return $ruby
    }

    if ($null -ne $rubyVersion) {
        Write-Host "Ruby $rubyVersion is too old; Ruby 2.7 or newer is required."
    } else {
        Write-Host "Ruby is not installed."
    }

    Install-Ruby $Platform
    $ruby = Get-ToolPath "ruby"
    $rubyVersion = if ($null -ne $ruby) { Get-RubyVersion $ruby } else { $null }
    if ($null -eq $ruby -or $null -eq $rubyVersion -or $rubyVersion -lt [version]"2.7.0") {
        throw "Ruby 2.7 or newer could not be found after installation. Start a new terminal and run this script again."
    }

    return $ruby
}

function Test-GemInstalled {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GemPath,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $output = (& $GemPath list --local --exact $Name 2>$null | Out-String)
    return $output -match ("(?m)^\s*" + [Regex]::Escape($Name) + "\s+\(")
}

function Get-UserGemBin {
    param(
        [Parameter(Mandatory = $true)]
        [string]$GemPath
    )

    $gemHome = (& $GemPath env user_gemhome 2>$null | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($gemHome)) {
        throw "RubyGems did not report a user gem directory."
    }

    return (Join-Path $gemHome "bin")
}

function Ensure-Jekyll {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RubyPath
    )

    $gem = Get-ToolPath "gem"
    if ($null -eq $gem) {
        throw "Ruby is installed but RubyGems was not found. Install RubyGems, then run this script again."
    }

    $gemBin = Get-UserGemBin $gem
    Add-ToProcessPath $gemBin

    $requiredGems = @(
        "jekyll",
        "jekyll-remote-theme",
        "jekyll-optional-front-matter",
        "jekyll-relative-links",
        "jekyll-seo-tag",
        "jekyll-include-cache"
    )
    $missingGems = @($requiredGems | Where-Object { -not (Test-GemInstalled $gem $_) })

    if ($missingGems.Count -gt 0) {
        Write-Host "Installing missing Jekyll gems for the current user: $($missingGems -join ', ')"
        Invoke-Checked $gem (@("install") + $missingGems + @("--user-install", "--no-document"))
        Add-ToProcessPath $gemBin
    }

    $jekyll = Get-ToolPath "jekyll"
    if ($null -eq $jekyll) {
        throw "Jekyll was installed but its executable is not on PATH. Add $gemBin to PATH, then run this script again."
    }

    return $jekyll
}

function ConvertTo-ProcessArgument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if ($Value -notmatch '[\s"]') {
        return $Value
    }

    return '"' + $Value.Replace('"', '\"') + '"'
}

function Test-LocalUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    $request = $null
    $response = $null
    try {
        $request = [Net.WebRequest]::Create($Url)
        $request.Timeout = 1000
        $response = $request.GetResponse()
        return $true
    } catch {
        return $false
    } finally {
        if ($null -ne $response) {
            $response.Close()
        }
    }
}

function Test-VsCodeTerminal {
    return $env:TERM_PROGRAM -eq "vscode" -or -not [string]::IsNullOrWhiteSpace($env:VSCODE_PID)
}

function Open-VsCodeBrowser {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    $arguments = ConvertTo-Json -InputObject @($Url) -Compress
    $commandUri = "vscode://command/simpleBrowser.show?$([Uri]::EscapeDataString($arguments))"
    $startInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $commandUri
    $startInfo.UseShellExecute = $true

    try {
        $process = [System.Diagnostics.Process]::Start($startInfo)
        if ($null -ne $process) {
            $process.Dispose()
        }
    } catch {
        throw "Could not open the VS Code integrated browser through ShellExecute. Ensure VS Code is installed and registered for vscode:// links. $($_.Exception.Message)"
    }
}

function Open-DefaultBrowser {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Platform,
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    switch ($Platform) {
        "Windows" {
            Open-VsCodeBrowser $Url
        }
        "macOS" {
            $open = Get-ToolPath "open"
            if ($null -eq $open) {
                throw "The macOS 'open' command was not found. Open $Url manually."
            }
            & $open $Url
        }
        "Linux" {
            if (Test-VsCodeTerminal) {
                Open-VsCodeBrowser $Url
                return
            }

            $opener = Get-ToolPath "xdg-open"
            if ($null -eq $opener) {
                $opener = Get-ToolPath "gio"
                if ($null -eq $opener) {
                    throw "Neither xdg-open nor gio was found. Open $Url manually."
                }
                & $opener open $Url
            } else {
                & $opener $Url
            }
        }
    }
}

if ($Port -lt 1 -or $Port -gt 65535) {
    throw "Port must be between 1 and 65535."
}

$platform = Get-PlatformName
$repoRoot = $PSScriptRoot
$docsPath = Join-Path $repoRoot "docs"
$configPath = Join-Path $docsPath "_config.yml"
if (-not (Test-Path $configPath)) {
    throw "The docs site was not found at $docsPath. Run this script from the repository checkout."
}

$rubyPath = Ensure-Ruby $platform
$jekyllPath = Ensure-Jekyll $rubyPath
$previewUrl = "http://127.0.0.1:$Port/"
$temporaryRoot = Join-Path $repoRoot "tmp/github-pages-preview"
$destinationPath = $temporaryRoot
$outputLog = Join-Path $temporaryRoot "jekyll.out.log"
$errorLog = Join-Path $temporaryRoot "jekyll.err.log"
$server = $null

try {
    if (Test-Path $temporaryRoot) {
        Remove-Item $temporaryRoot -Recurse -Force
    }

    New-Item -ItemType Directory -Path $temporaryRoot -Force | Out-Null
    $jekyllArguments = @(
        "serve",
        "--source=$docsPath",
        "--destination=$destinationPath",
        "--baseurl=",
        "--host=127.0.0.1",
        "--port=$Port",
        "--watch"
    )
    $argumentString = ($jekyllArguments | ForEach-Object { ConvertTo-ProcessArgument $_ }) -join " "

    Write-Host "Starting Jekyll at $previewUrl"
    $server = Start-Process `
        -FilePath $jekyllPath `
        -ArgumentList $argumentString `
        -WorkingDirectory $repoRoot `
        -RedirectStandardOutput $outputLog `
        -RedirectStandardError $errorLog `
        -PassThru

    $ready = $false
    for ($attempt = 0; $attempt -lt 120; $attempt++) {
        if ($server.HasExited) {
            $details = @(
                Get-Content $outputLog -ErrorAction SilentlyContinue
                Get-Content $errorLog -ErrorAction SilentlyContinue
            ) -join [Environment]::NewLine
            throw "Jekyll exited before the site became available. $details"
        }

        if (Test-LocalUrl $previewUrl) {
            $ready = $true
            break
        }

        Start-Sleep -Milliseconds 500
    }

    if (-not $ready) {
        throw "Jekyll did not become available at $previewUrl. Check $errorLog for details."
    }

    Open-DefaultBrowser $platform $previewUrl
    Write-Host "Preview is running at $previewUrl"
    Write-Host "Build output is in $destinationPath"
    Write-Host "Press Ctrl+C to stop the web host."
    Wait-Process -Id $server.Id
} finally {
    if ($null -ne $server -and -not $server.HasExited) {
        Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue
    }

}