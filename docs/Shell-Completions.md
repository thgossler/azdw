# Shell Integration

The `azdw` CLI provides comprehensive shell integration for enhanced productivity. Shell integration enables intelligent tab-completion for commands, subcommands, options, and arguments across multiple shell environments, and also installs the `azdw` PowerShell module for PowerShell sessions.

## Overview

Shell completions provide:
- **Command name completion**: Auto-complete main commands (`connection`, `query`, `config`, etc.)
- **Subcommand completion**: Complete subcommands for each command (`add`, `list`, `remove`, etc.)
- **Option completion**: Suggest available options and flags (`--connection`, `--verbose`, etc.)
- **Context-aware suggestions**: Intelligent completion based on command context
- **Self-contained**: No external tools required - uses System.CommandLine's built-in `[suggest]` directive

## Supported Shells

The `azdw` CLI supports shell completions for the following environments:

### macOS / Linux
- **Bash** - GNU Bourne Again Shell
- **Zsh** - Z Shell (default on macOS)
- **Fish** - Friendly Interactive Shell
- **Nushell** - Modern shell written in Rust
- **Sh** - POSIX Shell

### Windows
- **PowerShell 7+** - Cross-platform PowerShell
- **Nushell** - Modern shell written in Rust (cross-platform)
- **Clink** - Bash-like completion for Windows cmd.exe

## Quick Start

### Install Shell Integration for Current Shell

The simplest way to enable shell integration:

```bash
azdw config shell-integration
```

This command:
1. Detects your current shell
2. Generates appropriate completion scripts (and PowerShell module import for PowerShell)
3. Installs them in the correct location
4. Configures your shell to load completions

After installation, restart your shell or source your configuration file as instructed.

### Install for All Detected Shells

To install shell integration for all shells available on your system:

```bash
azdw config shell-integration --all
```

This is useful if you use multiple shells or want to ensure completions work regardless of which shell you're using.

## Command Reference

### Basic Usage

```bash
azdw config shell-integration [options]
```

### Options

| Option | Alias | Description |
| ------ | ------ | ---------- |
| `--all` | `-a` | Install for all detected shells (default: current shell only) |
| `--uninstall` | `-u` | Uninstall shell integration |
| `--list` | `-l` | List detected shells and their integration status |

### Examples

#### List Available Shells

See which shells are detected on your system:

```bash
azdw config shell-integration --list
```

Example output:
```
Shell Detection Results:
========================

Current Shell: Zsh (Zsh)
  Path: /bin/zsh

Available Shells (3):
  PowerShell (PowerShell)
    Path: /usr/local/bin/pwsh
    Version: 7.5.3
    Config: /Users/user/.config/powershell/Microsoft.PowerShell_profile.ps1
  Bash (Bash)
    Path: /bin/bash
    Config: /Users/user/.bashrc
    Completions: /Users/user/.bash_completion
→ Zsh (Zsh)
    Path: /opt/homebrew/bin/zsh
    Config: /Users/user/.zshrc
    Completions: /Users/user/.zsh/completions
```

#### Uninstall Shell Integration

Remove shell integration from the current shell:

```bash
azdw config shell-integration --uninstall
```

Remove shell integration from all shells:

```bash
azdw config shell-integration --uninstall --all
```

## Installation Details

### Zsh

**Location**: `~/.zsh/completions/_azdw`

The installer:
1. Creates the completion directory if needed
2. Generates the `_azdw` completion function
3. Updates `~/.zshrc` to add the executable directory to PATH persistently (via export statement)
4. Updates `~/.zshrc` to add the completion directory to `fpath`
5. Configures autoload for compinit

**Activation**: Restart zsh or run:
```zsh
source ~/.zshrc
```

### Bash

**Location**: `~/.bash_completion.d/azdw`

The installer:
1. Creates the completion directory if needed
2. Generates the bash completion script
3. Updates `~/.bashrc` to add the executable directory to PATH persistently (via export statement)
4. Updates `~/.bashrc` to source completion scripts

**Activation**: Restart bash or run:
```bash
source ~/.bashrc
```

### PowerShell 7+

**Location**: PowerShell profile script (typically `~/.config/powershell/Microsoft.PowerShell_profile.ps1`)

The installer:
1. Creates the profile file if needed
2. Adds the executable directory to PATH persistently (on Windows: updates user PATH environment variable; on macOS/Linux: adds export to profile)
3. Adds ArgumentCompleter registration for `azdw`
4. Implements tab-completion logic

**Activation**: Restart PowerShell or run:
```powershell
. $PROFILE
```

**PATH Configuration**: On Windows, the installer uses `[Environment]::SetEnvironmentVariable()` to add the executable directory to the user's PATH permanently. On macOS/Linux, it adds an export statement to the profile.

### Fish

**Location**: `~/.config/fish/completions/azdw.fish`

The installer:
1. Creates the completions directory if needed
2. Generates the fish completion script
3. Adds the executable directory to PATH persistently using Fish's universal variables (`set -Ux fish_user_paths`)

**Activation**: Completions are loaded automatically; no restart needed.

**PATH Configuration**: Fish uses universal variables (`fish_user_paths`) which persist across all Fish sessions automatically.

### Clink (Windows cmd.exe)

**Location**: Clink completions directory (auto-detected from Clink installation)

The installer:
1. Detects Clink installation directory
2. Creates the `azdw.lua` completion script
3. Installs it in the appropriate location

**Activation**: Restart cmd.exe to reload completions.

### Nushell

**Location**: Nushell config file
- Linux/macOS: `~/.config/nushell/config.nu`
- Windows: `%APPDATA%\nushell\config.nu`

The installer:
1. Detects Nushell configuration directory
2. Adds external completer configuration to `config.nu`
3. Configures the `[suggest]` directive integration

**Activation**: Restart Nushell or run:
```nushell
source ~/.config/nushell/config.nu
```

**Note**: Nushell uses an "external completer" pattern where completions for external commands are handled by a closure. The installer configures this automatically.

## How It Works

### Detection

The shell completion service uses multiple detection strategies:

1. **Environment Variables**: Checks `SHELL`, `PSModulePath`, `CLINK_DIR`
2. **Process Information**: Examines parent process names
3. **File System**: Searches for shell executables in standard locations
4. **Configuration Files**: Detects shell configuration file locations

### The `[suggest]` Directive - Modern Completion Approach

`azdw` uses **System.CommandLine 2.0+'s built-in `[suggest]` directive** for shell completions. This is the recommended modern approach for .NET 10+ CLI applications.

#### How the `[suggest]` Directive Works

When tab completion is triggered, the shell script calls the CLI directly with a special syntax:

```bash
azdw "[suggest:POSITION]" "COMMANDLINE"
```

Where:
- `POSITION` is the cursor position (0-based index) in the command line
- `COMMANDLINE` is the full command line text being completed

**Example:**
```bash
# User types: azdw config <TAB>
# Shell invokes:
azdw "[suggest:12]" "azdw config "

# CLI returns (one per line):
ai
fieldmap
paths
shell-integration
urlmap
--help
--verbose
...
```

The CLI parses the command line, determines what completions are valid at the cursor position, and outputs them (one per line) to stdout. The shell script captures this output and presents it to the user.

#### Why `[suggest]` is the Best Modern Approach

> **⚠️ Design Decision Reference**: This section documents why the direct `[suggest]` approach was chosen. 
> Internet searches may show older approaches like `dotnet-suggest` or `dotnet complete`. 
> **Do not revert to those approaches** - they have significant drawbacks explained below.

**Advantages of the direct `[suggest]` approach:**

| Benefit | Description |
| ------- | ----------- |
| **Self-contained** | No external tools required - the CLI handles its own completions |
| **No installation complexity** | No `dotnet tool install -g dotnet-suggest` needed |
| **No DOTNET_ROOT issues** | Works regardless of .NET SDK installation location |
| **No registration files** | No `~/.dotnet-suggest-registration.txt` management |
| **No broker process** | Direct invocation - no intermediary process overhead |
| **Runtime-only** | Works with just .NET Runtime (no SDK required on user machines) |
| **Cross-platform reliable** | No macOS code signing workarounds needed |
| **Simpler debugging** | Can test directly: `azdw "[suggest:12]" "azdw config "` |

#### Approaches to Avoid (and Why)

**❌ `dotnet-suggest` global tool** (deprecated approach):
- Requires `dotnet tool install -g dotnet-suggest`
- Requires proper `DOTNET_ROOT` configuration (source of many issues)
- Requires app registration with `dotnet-suggest register`
- Acts as broker between shell and CLI (extra process, extra failure modes)
- Suffers from CoreCLR initialization issues on some systems
- Not needed with System.CommandLine 2.0+ which has built-in `[suggest]`

**❌ `dotnet complete` / `dotnet completions script`** (not for apps):
- These are for the **dotnet CLI itself**, not for apps built with System.CommandLine
- Running `dotnet completions script zsh` generates completions for `dotnet`, not for your app
- Common source of confusion - produces German/localized dotnet commands, not app commands

**❌ Static completion scripts** (limited):
- Pre-generated completion lists become stale
- Cannot adapt to dynamic command structures
- Cannot provide context-aware completions

#### Shell Script Implementation

Each shell uses a script that:
1. Captures the current command line and cursor position
2. Invokes `azdw "[suggest:POSITION]" "COMMANDLINE"`
3. Parses the output (newline-separated suggestions)
4. Presents suggestions to the user

**Zsh example** (simplified):
```zsh
_azdw_completions() {
    local commandline="$words"
    local position=$((CURSOR))
    
    # Call CLI with [suggest] directive
    local completions=$(azdw "[suggest:$position]" "$commandline" 2>/dev/null)
    
    # Present to zsh
    local -a suggestions
    suggestions=(${(f)completions})
    _describe 'suggestions' suggestions
}
compdef _azdw_completions azdw
```

**PowerShell example** (simplified):
```powershell
Register-ArgumentCompleter -Native -CommandName azdw -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    
    $commandLine = $commandAst.ToString()
    & azdw "[suggest:$cursorPosition]" "$commandLine" 2>$null | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
```

**Nushell example** (simplified):
```nushell
# Define external completer for azdw
let azdw_completer = {|spans|
    let cmd = ($spans | str join " ")
    let position = ($cmd | str length)
    azdw $"[suggest:($position)]" $cmd | lines | where {|it| $it != ""}
}

# Configure external completions
$env.config.completions.external = {
    enable: true
    completer: {|spans|
        if ($spans.0 == "azdw") {
            do $azdw_completer $spans
        } else {
            null  # Fall back to default
        }
    }
}
```

### System.CommandLine Integration

The `[suggest]` directive is a built-in feature of System.CommandLine 2.0+:

1. **Automatic handling**: System.CommandLine recognizes the `[suggest:N]` pattern
2. **Context-aware**: Analyzes the command tree to determine valid completions
3. **Option awareness**: Suggests options, their values, and subcommands appropriately
4. **Description support**: Can include descriptions for richer shell completion UIs

When System.CommandLine sees `[suggest:N]` as the first argument:
- It does **not** execute the normal command
- It parses the second argument as the command line to complete
- It outputs valid completions to stdout
- It exits with code 0

### Generation

Completions are generated dynamically based on the actual CLI command structure:

1. Introspects all commands, subcommands, and options at runtime
2. Outputs shell-agnostic completion candidates
3. Shell scripts format suggestions for their specific completion system
4. Includes help text and descriptions where available in the command model

### Installation

The installer:

1. Detects appropriate installation paths based on shell conventions
2. Creates necessary directories with proper permissions
3. Generates shell-specific completion scripts that use the `[suggest]` directive
4. Adds completion configuration to shell profile
5. Provides rollback capability via uninstall
6. Automatically migrates from old `dotnet-suggest` configuration if present

## Troubleshooting

### Completions Not Working After Installation

**Zsh**:
```zsh
# Ensure fpath includes completions directory
echo $fpath | grep zsh/completions

# Rebuild completion cache
rm -f ~/.zcompdump
compinit
```

**Bash**:
```bash
# Check if completion script is sourced
grep -r "bash_completion.d" ~/.bashrc

# Manually source completions
source ~/.bash_completion.d/azdw
```

**PowerShell**:
```powershell
# Check if profile is loaded
Test-Path $PROFILE

# Verify completion is registered
Get-ArgumentCompleter -Native | Where-Object { $_.CommandName -like '*azdw*' }

# Manually reload profile
. $PROFILE

# Test the [suggest] directive directly
azdw '[suggest:12]' 'azdw config '

# Should output completions like:
# ai
# fieldmap
# shell-integration
# ...
```

**Important PowerShell Limitation**: Tab completion only works when invoking the command by its base name (`azdw`, `azdw.exe`) **after** the executable directory is in your PATH. The installer automatically adds the directory to PATH **persistently** in your profile (and on Windows, also updates the user's PATH environment variable). Tab completion will **not** work with arbitrary relative/absolute paths like `.\publish\azdw.exe` or `C:\tools\azdw.exe` because PowerShell's native argument completer requires exact command name matches and cannot use pattern matching.

**Workaround**: The installer automatically adds the `azdw` executable directory to your PATH persistently. After installation and restarting your shell, you can invoke `azdw` or `azdw.exe` from any directory with full tab completion support.

### Permission Errors

If installation fails due to permissions:

```bash
# Check permissions on config files
ls -la ~/.zshrc ~/.bashrc

# Ensure directories exist with correct ownership
mkdir -p ~/.zsh/completions
chmod 755 ~/.zsh/completions
```

### Multiple Shell Versions

If you have multiple versions of a shell installed, the completion may install for a different version than you're using. Check:

```bash
# See which shell is actually running
echo $SHELL
ps -p $$

# List all installed shells
cat /etc/shells
```

## Advanced Usage

### Custom Installation Path

The completion installer uses standard paths, but you can manually move completion files:

**Zsh**:
```zsh
# Move to custom location
mv ~/.zsh/completions/_azdw /custom/path/_azdw

# Update fpath in .zshrc
fpath=(/custom/path $fpath)
```

**Bash**:
```bash
# Move and source from custom location
mv ~/.bash_completion.d/azdw /custom/path/azdw
echo "source /custom/path/azdw" >> ~/.bashrc
```

### Completion Cache

Some shells cache completions for performance:

**Zsh**:
```zsh
# Clear cache after updating azdw
rm -f ~/.zcompdump
compinit
```

## Integration with CI/CD

While shell integration is primarily for interactive use, you can include installation in setup scripts:

```bash
#!/bin/bash
# setup-dev-environment.sh

# Install azdw
curl -L https://example.com/azdw-installer.sh | bash

# Setup shell integration for all shells
azdw config shell-integration --all

echo "Development environment ready!"
```

## Related Commands

- `azdw config` - Manage all azdw configuration
- `azdw --help` - View complete CLI documentation
- `azdw --version` - Check azdw version

## See Also

- [CLI Help Overview](CLI-Help-Overview.md)
- [CLI Use Cases](CLI-Use-Cases.md)
- [Authentication Types](Authentication-Types.md)
