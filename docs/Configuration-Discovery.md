---
title: Configuration Discovery
nav_order: 40
---

# Configuration Discovery

## Overview

The `azdw` tool uses a **simple two-tier priority system** for discovering configuration files. This ensures flexibility while maintaining a clear hierarchy for configuration precedence.

AI workspace assets add a project/workspace tier for azdw-owned AI sessions. Skills, prompt files, MCP configuration, and `AGENTS.md` have additional workspace discovery rules under `.agents/`, `.github/`, and `.claude/`. See [Workspace Context and AI Discovery](Workspace-Context-and-AI-Discovery.md) for those AI-specific paths. The general configuration rules below remain the reference for non-workspace configuration files.

## Discovery Priority Order

Configuration files are discovered in the following priority order (highest to lowest):

1. **User Directory** (`~/.azdw/config/`)
   - **Purpose**: User-specific customizations and overrides
   - **Priority**: Highest (always checked first)
   - **Typical Use**: Production, personal configurations, custom settings

2. **Shipped Defaults** (`{executable-directory}/config/`)
   - **Purpose**: Factory default configurations shipped with the application
   - **Priority**: Fallback (used only if user config doesn't exist)
   - **Typical Use**: Out-of-box experience, reference defaults

## Read vs Write Behavior

### Reading Configuration

When reading a configuration file:
1. Check `~/.azdw/config/` first (user overrides)
2. If not found, fall back to `{exe-dir}/config/` (factory defaults)
3. If neither exists, use built-in defaults

### Writing Configuration

**All user modifications are always written to `~/.azdw/config/`** (user directory).

This ensures:
- Factory defaults in `{exe-dir}/config/` remain unchanged
- User customizations are isolated and portable
- Clean separation between shipped defaults and user overrides

### Visual Discovery Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Configuration Request                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
         ┌────────────────────────────┐
         │ 1. Check User Directory    │
         │    ~/.azdw/config/         │
         └────────────┬───────────────┘
                      │
                      ├─── Found? ──────► Use User Config ✓
                      │
                      ▼ Not Found
         ┌────────────────────────────┐
         │ 2. Check Shipped Defaults  │
         │    {exe-dir}/config/       │
         └────────────┬───────────────┘
                      │
                      ├─── Found? ──────► Use Factory Config ✓
                      │
                      ▼ Not Found
         ┌────────────────────────────┐
         │   Use Built-in Defaults    │
         │   (and create user config  │
         │    on first modification)  │
         └────────────────────────────┘
```

## Configuration Types

### 1. Field Mappings

**Purpose**: Map Azure DevOps fields across different process templates (Agile, Scrum, CMMI) to unified logical field names.

**Discovery Paths**:
1. `~/.azdw/config/field-mappings/`
2. `{exe-dir}/config/field-mappings/`

**File Pattern**: `*.json`, `*.jsonc`

**Example Files**:
- `bug-agile.jsonc`
- `userstory-agile.jsonc`
- `epic-agile.jsonc`

**Command to View**:
```bash
azdw config fieldmap list
```

**Import Shipped Mapping to User Directory**:
```bash
azdw config fieldmap import --source bug-agile.jsonc
```

### 2. Report Templates

**Purpose**: Scriban-based templates for rendering work item reports in various formats (Markdown, HTML, CSV).

**Discovery Paths**:
1. `~/.azdw/templates/`
2. `{exe-dir}/config/templates/`

**File Pattern**: `*.json`

**Example Files**:
- `sprint-report-md.json`
- `epic-status-html.json`
- `bug-list-csv.json`

**Command to View**:
```bash
azdw report template list
```

**Import Shipped Template to User Directory**:
```bash
azdw report template import --source sprint-report-md.json
```

### 3. Other Configuration Files

**Discovery Paths**:
1. `~/.azdw/config/`
2. `{exe-dir}/config/`

**Files**:
- `relationship-policy.jsonc` - Work item relationship validation rules
- `visualization-config.jsonc` - Graph visualization settings
- `tool-categories.jsonc` - AI chat tool category selection
- `mcp.jsonc` - External MCP server configuration

### 4. Connection Configuration

**Purpose**: Azure DevOps organization connections and authentication credentials.

**Location**: `~/.azdw/connections.json` (user directory only)

**Command to Manage**:
```bash
azdw connection list
azdw connection add
azdw connection test
```

### 5. Credentials

**Purpose**: Secure storage for PAT tokens and OAuth tokens.

**Location**: Platform-specific secure storage (Keychain on macOS, Credential Manager on Windows, Secret Service on Linux)

**Command to Manage**:
```bash
azdw credential store
azdw credential list
azdw credential remove
```

## Platform-Specific Paths

### macOS / Linux

| Priority | Path |
| ------- | ----- |
| User Directory | `~/.azdw/config/` |
| Shipped Defaults | `{exe-dir}/config/` |

**Example**:
```bash
# User directory (overrides - checked first)
~/.azdw/config/field-mappings/bug-agile.jsonc
~/.azdw/config/tool-categories.jsonc
~/.azdw/templates/sprint-report-md.json

# Shipped defaults (factory defaults - fallback)
/usr/local/bin/azdw-osx-arm64/config/field-mappings/bug-agile.jsonc
/usr/local/bin/azdw-osx-arm64/config/templates/sprint-report-md.json
```

### Windows

| Priority | Path |
| ------- | ----- |
| User Directory | `%USERPROFILE%\.azdw\config\` |
| Shipped Defaults | `{exe-dir}\config\` |

**Example**:
```powershell
# User directory (overrides - checked first)
C:\Users\JohnDoe\.azdw\config\field-mappings\bug-agile.jsonc
C:\Users\JohnDoe\.azdw\config\tool-categories.jsonc
C:\Users\JohnDoe\.azdw\templates\sprint-report-md.json

# Shipped defaults (factory defaults - fallback)
C:\Program Files\azdw\win-x64\config\field-mappings\bug-agile.jsonc
C:\Program Files\azdw\win-x64\config\templates\sprint-report-md.json
```

## Usage Scenarios

### Scenario 1: Fresh Installation (Production)

**Initial State**: User installs `azdw` for the first time.

**Discovery Behavior**:
1. User directory (`~/.azdw/`) doesn't exist
2. Shipped defaults found in `{exe-dir}/config/`
3. Tool uses shipped defaults automatically
4. On first customization (import/create), user directory is created

**Example**:
```bash
# List templates (uses shipped defaults)
$ azdw report template list
Available templates:
  - sprint-report-md (Shipped)
  - epic-status-html (Shipped)

# Import to user directory for customization
$ azdw report template import --source sprint-report-md.json
Template imported to: ~/.azdw/templates/sprint-report-md.json

# Now user version takes precedence
$ azdw report template list
Available templates:
  - sprint-report-md (User) ← Takes precedence
  - sprint-report-md (Shipped)
  - epic-status-html (Shipped)
```

### Scenario 2: Development Mode

**Initial State**: Developer runs `azdw` from source code checkout.

**Discovery Behavior**:
1. User directory (`~/.azdw/config/`) checked first (may not exist in fresh dev environment)
2. Falls back to shipped defaults in output directory (`bin/Debug/config/`)
3. After build, config files are copied to output directory

**Example**:
```bash
# Build project first to copy config to output
$ cd ~/Dev/azdw
$ dotnet build

# Run from output directory
$ bin/Debug/net10.0/azdw report template list
Available templates:
  - sprint-report-md (Shipped) ← From output directory config/
  - epic-status-html (Shipped)

# Create user override
$ azdw report template import --source sprint-report-md.json
Imported: ~/.azdw/templates/sprint-report-md.json

# Now user version takes precedence
$ bin/Debug/net10.0/azdw report template list
Available templates:
  - sprint-report-md (User) ← Takes precedence
  - epic-status-html (Shipped)
```

### Scenario 3: Testing Custom Configurations

**Initial State**: User wants to test modifications without affecting production configs.

**Strategy**: Modify files in `~/.azdw/config/` (user directory). Factory defaults in `{exe-dir}/config/` are never modified.

**Example**:
```bash
# Create user config to override factory defaults
$ mkdir -p ~/.azdw/config
$ cp /path/to/test-config.jsonc ~/.azdw/config/tool-categories.jsonc

# Test with user config
$ azdw ai-chat
# Uses ~/.azdw/config/tool-categories.jsonc

# Remove user config to revert to factory defaults
$ rm ~/.azdw/config/tool-categories.jsonc
$ azdw ai-chat
# Uses {exe-dir}/config/tool-categories.jsonc
```

### Scenario 4: Multi-Platform Distribution

**Initial State**: Building self-contained packages for different platforms.

**Discovery Behavior**:
1. Each platform folder (`dist/osx-arm64/`, `dist/linux-x64/`, `dist/win-x64/`) is self-contained
2. Each contains its own `config/` directory with shipped defaults
3. Executable can run from any location without installation

**Package Structure**:
```
dist/
├── osx-arm64/
│   ├── azdw                    ← Executable
│   ├── config/                 ← Shipped defaults (self-contained)
│   │   ├── field-mappings/
│   │   └── templates/
│   └── plugins/
├── linux-x64/
│   ├── azdw
│   ├── config/                 ← Shipped defaults (self-contained)
│   └── plugins/
└── win-x64/
    ├── azdw.exe
    ├── config/                 ← Shipped defaults (self-contained)
    └── plugins/
```

**Usage**:
```bash
# Run directly from platform folder
$ ./dist/osx-arm64/azdw report template list
Available templates:
  - sprint-report-md (Shipped) ← From ./dist/osx-arm64/config/

# Or copy entire platform folder to installation directory
$ cp -r dist/osx-arm64 /usr/local/bin/azdw
$ /usr/local/bin/azdw/azdw report template list
```

## Viewing Configuration Paths

Use the `config paths` command to see all discovered configuration paths:

```bash
$ azdw config paths

Configuration Paths:
====================

Field Mappings:
  User:       ~/.azdw/config/field-mappings/ (5 files)
  Shipped:    /usr/local/bin/azdw/config/field-mappings/ (8 files)

Templates:
  User:       ~/.azdw/templates/ (2 files)
  Shipped:    /usr/local/bin/azdw/config/templates/ (6 files)

Other Config:
  User:       ~/.azdw/config/ (3 files)
  Shipped:    /usr/local/bin/azdw/config/ (4 files)

Connections:
  ~/.azdw/connections.json (exists)

Priority Order:
  1. User directory (highest - checked first)
  2. Shipped defaults (fallback)
```

## Importing and Exporting Configurations

### Import Shipped Configuration to User Directory

**Field Mappings**:
```bash
# Import single mapping
$ azdw config fieldmap import --source bug-agile.jsonc
Imported: ~/.azdw/config/field-mappings/bug-agile.jsonc

# Import with merge strategy (combine with existing)
$ azdw config fieldmap import --source bug-agile.jsonc --merge
Merged into: ~/.azdw/config/field-mappings/bug-agile.jsonc
```

**Report Templates**:
```bash
# Import single template
$ azdw report template import --source sprint-report-md.json
Imported: ~/.azdw/templates/sprint-report-md.json

# Import from external file
$ azdw report template import --file /path/to/custom-template.json
Imported: ~/.azdw/templates/custom-template.json
```

### Export Configuration to File

**Field Mappings**:
```bash
# Export user mapping
$ azdw config fieldmap export bug-agile.jsonc --output /backup/bug-agile.jsonc
Exported: /backup/bug-agile.jsonc

# Export shipped mapping
$ azdw config fieldmap export bug-agile.jsonc --source shipped --output /backup/bug-agile-shipped.jsonc
Exported: /backup/bug-agile-shipped.jsonc
```

**Report Templates**:
```bash
# Export user template
$ azdw report template export sprint-report-md.json --output /backup/sprint-report-md.json
Exported: /backup/sprint-report-md.json
```

## Troubleshooting

### Issue: Configuration Not Found

**Symptoms**: Tool reports "Configuration not found" or uses unexpected defaults.

**Diagnosis**:
```bash
# Check configuration paths
$ azdw config paths

# List available configurations
$ azdw config fieldmap list
$ azdw report template list
```

**Solutions**:
1. **Verify file exists**: Check if configuration file exists in user or shipped directories
2. **Check file permissions**: Ensure read permissions on configuration files
3. **Import shipped defaults**: If user directory is empty, import shipped configurations
   ```bash
   $ azdw config fieldmap import --source bug-agile.jsonc
   $ azdw report template import --source sprint-report-md.json
   ```
4. **Rebuild executable**: If shipped defaults missing, rebuild with proper config copy
   ```bash
   $ dotnet publish src/azdw/azdw.csproj -c Release --self-contained -o publish/
   ```

### Issue: Wrong Configuration Priority

**Symptoms**: User configuration not taking precedence over shipped defaults.

**Diagnosis**:
```bash
# Check which configuration is being used
$ azdw config fieldmap list --verbose
$ azdw report template list --verbose
```

**Solutions**:
1. **Verify user directory exists**: Ensure `~/.azdw/config/` or `~/.azdw/templates/` exists
2. **Check file names match**: User config must have same name as shipped config to override
3. **Import to correct location**: Use import command to ensure proper user directory placement
   ```bash
   $ azdw config fieldmap import --source bug-agile.jsonc
   ```

### Issue: Multi-Platform Package Missing Config

**Symptoms**: Platform-specific executable in `dist/{platform}/` can't find shipped defaults.

**Diagnosis**:
```bash
# Check if config/ exists in platform folder
$ ls -la dist/osx-arm64/config/

# Verify config files present
$ ls -la dist/osx-arm64/config/field-mappings/
$ ls -la dist/osx-arm64/config/templates/
```

**Solutions**:
1. **Rebuild distribution package**: Run `scripts/build-cli-all-platforms.ps1` and `scripts/create-dist-package.ps1`
2. **Manually copy config**: Copy config folder to each platform directory
   ```bash
   $ cp -r config/ dist/osx-arm64/
   $ cp -r config/ dist/linux-x64/
   $ cp -r config/ dist/win-x64/
   ```
3. **Verify .csproj settings**: Ensure `azdw.csproj` includes config copy directive:
   ```xml
   <ItemGroup>
     <Content Include="../../config/**/*">
       <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
     </Content>
   </ItemGroup>
   ```

### Issue: Permission Denied on User Directory

**Symptoms**: Can't create or write to `~/.azdw/` directory.

**Solutions**:
1. **Check directory permissions**:
   ```bash
   $ ls -la ~/
   $ chmod 755 ~/.azdw/
   ```
2. **Check parent directory permissions**: Ensure home directory is accessible
3. **Check disk space**: Verify sufficient disk space available
   ```bash
   $ df -h ~
   ```

## Best Practices

### Development

1. **Use shipped defaults as reference**: Don't modify project root `config/` for personal preferences
2. **Test with user directory**: Test customizations in `~/.azdw/` to simulate production
3. **Version control shipped defaults**: Keep `config/` in git for shipped defaults only
4. **Build before testing**: Run `dotnet build` to ensure shipped defaults copied to output

### Production

1. **Import before customizing**: Use `import` command to copy shipped configs to user directory
2. **Backup user configs**: Export and backup customized configurations regularly
   ```bash
   $ azdw config fieldmap export bug-agile.jsonc --output /backup/
   $ azdw report template export sprint-report-md.json --output /backup/
   ```
3. **Document customizations**: Add comments to explain custom configurations
4. **Test in isolation**: Test configuration changes in separate user directory before production

### Distribution

1. **Include config in all platforms**: Ensure `config/` copied to each platform folder in distribution packages
2. **Document config discovery**: Include this guide or link in distribution README
3. **Provide examples**: Include example configurations in `config/` directory
4. **Version shipped defaults**: Update version number or timestamp in shipped configs

## Configuration File Format

All configuration files support JSON and JSONC (JSON with comments) formats.

**Example Field Mapping** (`bug-agile.jsonc`):
```jsonc
{
  "workItemType": "Bug",
  "processTemplate": "Agile",
  "fields": {
    // Logical name -> Azure DevOps field mapping
    "title": "System.Title",
    "state": "System.State",
    "priority": "Microsoft.VSTS.Common.Priority",
    "severity": "Microsoft.VSTS.Common.Severity"
  }
}
```

**Example Report Template** (`sprint-report-md.json`):
```json
{
  "name": "sprint-report-md",
  "description": "Sprint summary report in Markdown format",
  "format": "markdown",
  "template": "# Sprint {{ sprint.name }}\n\n..."
}
```

## See Also

- [CLI Help Overview](CLI-Help-Overview.md)
- [Configuration README](../config/README.md)
- [Plugin Development Guide](Plugin-Development-Guide.md)
