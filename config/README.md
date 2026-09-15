# Configuration Guide

This directory contains configuration files for the Azure DevOps Work Item Handler library, including field mappings, templates, URL mappings, and sample configurations.

## Directory Structure

```
config/
├── field-mappings/            # Process template field mappings
│   ├── agile-default.jsonc
│   └── (custom mappings)
├── templates/                 # Report and visualization templates
│   ├── sprint-report-md.json
│   ├── team-dashboard-html.json
│   ├── release-notes-md.json
│   └── work-items-export-csv.json
├── theme-dark.css              # DaisyUI oklch theme for dark terminals (shipped default)
├── theme-light.css             # DaisyUI oklch theme for light terminals (shipped default)
├── file-relationship-config.jsonc  # File hyperlink to fake work item patterns
├── glossary.jsonc              # Domain glossary for AI analysis
├── hyperlink-mappings.jsonc    # Hyperlink relationship type mappings
├── relationship-policy.jsonc   # Relationship policy configuration
├── mcp-example.jsonc            # MCP endpoint configuration example
├── mcp-config-schema.json       # MCP configuration schema
├── url-mappings.jsonc          # URL domain mapping configuration
├── capacity-supply.jsonc       # Capacity-supply input for demand-vs-supply load analysis
├── global-stack-rank.jsonc     # Named cross-org/cross-provider global stack rank profiles
└── visualization-config.jsonc  # Visualization config
```

## Color Themes

`azdw` supports DaisyUI oklch-based CSS theme files for customizing colors in the terminal UI. Two shipped theme files are provided: `theme-dark.css` (for dark terminals) and `theme-light.css` (for light terminals).

### Theme File Format

Theme files use the [DaisyUI theme generator](https://daisyui.com/theme-generator/) format — you can copy the generated CSS directly and use it as your theme file without modification:

```css
@plugin "daisyui/theme" {
    name: "my-theme";
    prefersdark: true;
    color-scheme: dark;

    --color-primary: oklch(62% 0.18 52);
    --color-accent: oklch(75% 0.20 75);
    --color-neutral: oklch(55% 0.02 200);
    --color-neutral-content: oklch(90% 0.01 200);
    --color-info: oklch(65% 0.15 220);
    --color-info-content: oklch(80% 0.10 220);
    --color-success: oklch(65% 0.20 140);
    --color-warning: oklch(75% 0.18 88);
    --color-warning-content: oklch(30% 0.10 88);
    --color-error: oklch(60% 0.22 25);
    --color-base-200: oklch(25% 0.01 200);
    --color-base-content: oklch(90% 0.01 200);
}
```

### Required Color Variables

The following variables are required and must be present for the theme to load:

| Variable | Role |
| ------ | ------ |
| `--color-primary` | Primary brand color (headers, borders, progress spinners) |
| `--color-accent` | Accent color (links, highlights) |
| `--color-neutral` | Neutral/muted text |
| `--color-neutral-content` | H1 headings, high-contrast text |
| `--color-info` | Info messages |
| `--color-info-content` | H2 headings |
| `--color-success` | Success messages |
| `--color-warning` | Warning messages |
| `--color-warning-content` | H3 headings |
| `--color-error` | Error messages |
| `--color-base-200` | Background surface (input-highlight, selection bars) |
| `--color-base-content` | Default foreground text |

Non-color properties such as `--radius-*`, `--border`, `--depth`, `--noise`, and `--animation-*` are silently ignored.

### Theme Resolution Order

When loading a theme, `azdw` checks locations in this order (first found wins):

1. **User override**: `~/.azdw/config/theme-{dark|light}.css`
2. **Shipped default**: `<install-dir>/config/theme-{dark|light}.css`

### Color Mode Selection

Use the `--color-mode` option to control which theme file is loaded:

| Mode | Behavior |
| ------ | ------ |
| `auto` (default) | Detects terminal background via OSC 11 query, falls back to `COLORFGBG` env var, then defaults to dark |
| `dark` | Always loads `theme-dark.css` |
| `light` | Always loads `theme-light.css` |

```
azdw --color-mode light query ...
```

### Copy-Paste Workflow from DaisyUI Generator

1. Visit [https://daisyui.com/theme-generator/](https://daisyui.com/theme-generator/)
2. Design your theme and click **Copy CSS**
3. Save the output to `~/.azdw/config/theme-dark.css` (or `theme-light.css`)
4. Launch `azdw` — colors are applied automatically

Client teams can also ship branded themes by placing theme files in `clients/<ClientName>/config/` — these are automatically included in client distribution packages.

## Field Mappings

Field mappings translate logical field names to process template-specific field names, allowing you to work with consistent field names across different Azure DevOps process templates (Agile, Scrum, CMMI).

### Location

Field mapping files are stored in `config/field-mappings/` as JSONC files.

### Default Mapping

The default mapping is `agile-default.jsonc`, which provides field mappings for the Agile process template.

### Field Mapping Structure

```jsonc
{
  // Process template identifier
  "processTemplate": "Agile",
  
  // Work item type mappings (logical → template-specific)
  "workItemTypes": {
    "Epic": "Epic",
    "Feature": "Feature",
    "UserStory": "User Story",
    "Task": "Task",
    "Bug": "Bug"
  },
  
  // Field mappings (logical name → Azure DevOps field reference name)
  "fields": {
    // System fields
    "Title": "System.Title",
    "State": "System.State",
    "AssignedTo": "System.AssignedTo",
    "CreatedBy": "System.CreatedBy",
    "CreatedDate": "System.CreatedDate",
    "ChangedBy": "System.ChangedBy",
    "ChangedDate": "System.ChangedDate",
    "AreaPath": "System.AreaPath",
    "IterationPath": "System.IterationPath",
    "Tags": "System.Tags",
    
    // Common fields
    "Priority": "Microsoft.VSTS.Common.Priority",
    "Severity": "Microsoft.VSTS.Common.Severity",
    "ValueArea": "Microsoft.VSTS.Common.ValueArea",
    "Risk": "Microsoft.VSTS.Common.Risk",
    
    // Agile-specific fields
    "StoryPoints": "Microsoft.VSTS.Scheduling.StoryPoints",
    "AcceptanceCriteria": "Microsoft.VSTS.Common.AcceptanceCriteria",
    "Description": "System.Description",
    
    // Planning fields
    "OriginalEstimate": "Microsoft.VSTS.Scheduling.OriginalEstimate",
    "RemainingWork": "Microsoft.VSTS.Scheduling.RemainingWork",
    "CompletedWork": "Microsoft.VSTS.Scheduling.CompletedWork",
    "Activity": "Microsoft.VSTS.Common.Activity"
  }
}
```

### Creating Custom Mappings

1. **Copy the default mapping:**
   ```bash
   cp config/field-mappings/agile-default.jsonc config/field-mappings/my-custom.jsonc
   ```

2. **Edit the mapping:**
   Update the `processTemplate` name and modify field mappings as needed.

3. **Use the custom mapping:**
   
   **CLI:**
   ```bash
   azdw connection add \
     --name MyOrg \
     --url https://dev.azure.com/myorg \
     --auth-type pat \
     --field-mapping my-custom
   ```
   
   **Library:**
   ```csharp
   var connection = new Connection
   {
       Name = "MyOrg",
       Url = "https://dev.azure.com/myorg",
       FieldMappingProfile = "my-custom"
   };
   ```

### Process Template Examples

#### Scrum Process Template

```jsonc
{
  "processTemplate": "Scrum",
  "workItemTypes": {
    "Epic": "Epic",
    "Feature": "Feature",
    "UserStory": "Product Backlog Item",  // Note: different from Agile
    "Task": "Task",
    "Bug": "Bug"
  },
  "fields": {
    "Title": "System.Title",
    "State": "System.State",
    "Priority": "Microsoft.VSTS.Common.Priority",
    "Effort": "Microsoft.VSTS.Scheduling.Effort",  // Instead of StoryPoints
    "BusinessValue": "Microsoft.VSTS.Common.BusinessValue"
  }
}
```

#### CMMI Process Template

```jsonc
{
  "processTemplate": "CMMI",
  "workItemTypes": {
    "Epic": "Epic",
    "Feature": "Feature",
    "UserStory": "Requirement",  // Note: different from Agile
    "Task": "Task",
    "Bug": "Bug"
  },
  "fields": {
    "Title": "System.Title",
    "State": "System.State",
    "Priority": "Microsoft.VSTS.Common.Priority",
    "Size": "Microsoft.VSTS.Scheduling.Size",
    "Impact": "Microsoft.VSTS.CMMI.Impact"
  }
}
```

### Auto-Detection

The library can automatically detect process templates and generate mappings:

```csharp
var fieldMappingService = serviceProvider.GetRequiredService<IFieldMappingService>();
var mapping = await fieldMappingService.DetectAndGenerateMappingAsync("MyOrg");
await configManager.SaveConfigAsync(
    $"config/field-mappings/{mapping.ProcessTemplate}.jsonc", 
    mapping
);
```

## Templates

Templates define how work item data is rendered into reports, visualizations, and exports. Templates use the [Scriban](https://github.com/scriban/scriban) template engine.

### Location

Template files are stored in `config/templates/` as JSON files.

See [templates/README.md](templates/README.md) for detailed template documentation.

### Template Structure

```json
{
  "id": "sprint-report-md",
  "name": "Sprint Report (Markdown)",
  "description": "Comprehensive sprint report in Markdown format",
  "category": "Sprint Reports",
  "tags": ["sprint", "markdown", "report"],
  "outputFormat": "markdown",
  "parameters": {
    "sprint": {
      "type": "string",
      "description": "Sprint name or identifier",
      "required": true
    },
    "team": {
      "type": "string",
      "description": "Team name",
      "required": false
    }
  },
  "template": "# Sprint Report: {{ sprint }}\n\n..."
}
```

### Available Templates

| Template ID | Description | Output Format |
| ----------- | ----------- | ------------- |
| `sprint-report-md` | Sprint summary with metrics | Markdown |
| `team-dashboard-html` | Interactive team dashboard | HTML |
| `release-notes-md` | Release notes generator | Markdown |
| `work-items-export-csv` | Work items export | CSV |

### Using Templates

**CLI:**
```bash
azdw report generate \
  --template-id sprint-report-md \
  --query query.json \
  --output-file report.md \
  --parameters sprint=Sprint-42 team=Platform
```

**Library:**
```csharp
var templateService = new TemplateService(configManager);
var scribanRenderer = new ScribanRenderer();

var template = await templateService.GetTemplateAsync("sprint-report-md");
var output = await scribanRenderer.RenderAsync(template.Content, data);
```

### Creating Custom Templates

1. **Create a new template file:**
   ```json
   {
     "id": "my-custom-report",
     "name": "My Custom Report",
     "description": "A custom report template",
     "category": "Reports",
     "tags": ["custom"],
     "outputFormat": "markdown",
     "parameters": {},
     "template": "# My Report\n\n{{ for item in work_items }}\n- {{ item.title }}\n{{ end }}"
   }
   ```

2. **Save to templates directory:**
   ```bash
   save as config/templates/my-custom-report.json
   ```

3. **Use the template:**
   ```bash
   azdw report generate --template my-custom-report --query query.json
   ```

### Scriban Template Syntax

Scriban templates support:

- **Variables**: `{{ variable_name }}`
- **Loops**: `{{ for item in items }} ... {{ end }}`
- **Conditionals**: `{{ if condition }} ... {{ else }} ... {{ end }}`
- **Functions**: `{{ item.title | upcase }}`
- **Filters**: `{{ date | date.to_string "%Y-%m-%d" }}`

**Example:**
```scriban
# Work Items Report

{{ for item in work_items }}
## [{{ item.id }}] {{ item.title }}

- **Type**: {{ item.work_item_type }}
- **State**: {{ item.state }}
- **Assigned To**: {{ item.assigned_to ?? "Unassigned" }}
- **Tags**: {{ item.tags | array.join ", " }}

{{ if item.description }}
{{ item.description }}
{{ end }}

---
{{ end }}

**Total**: {{ work_items | array.size }} items
```

For complete Scriban syntax, see: https://github.com/scriban/scriban/blob/master/doc/language.md

## Sample Configurations

The `config/samples/` directory contains example configuration files demonstrating common scenarios.

### Connection Configuration Example

```jsonc
{
  // List of Azure DevOps connections
  "connections": [
    {
      "name": "MainOrg",
      "url": "https://dev.azure.com/mycompany",
      "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
      "authType": "PAT",
      "fieldMappingProfile": "agile-default"
    },
    {
      "name": "PartnerOrg",
      "url": "https://dev.azure.com/partner",
      "tenantId": "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy",
      "authType": "DeviceCode",
      "fieldMappingProfile": "scrum-custom"
    }
  ]
}
```

### Cache Configuration Example

```jsonc
{
  // Cache configuration
  "cache": {
    "enabled": true,
    "provider": "LiteDB",  // or "CosmosDB"
    "connectionString": "Filename=./cache.db",
    "defaultTTL": "24:00:00",  // 24 hours
    "refreshOnDemand": true
  }
}
```

### Rate Limiting Configuration Example

```jsonc
{
  // Rate limiting configuration
  "rateLimiting": {
    "maxRequestsPerMinute": 300,
    "failFast": true,
    "throttleWindow": "00:01:00"  // 1 minute
  }
}
```

### Complete Configuration Example

```jsonc
{
  "connections": [
    {
      "name": "MyOrg",
      "url": "https://dev.azure.com/myorg",
      "tenantId": "tenant-guid",
      "authType": "PAT",
      "fieldMappingProfile": "agile-default"
    }
  ],
  "cache": {
    "enabled": true,
    "provider": "LiteDB",
    "connectionString": "Filename=./cache.db",
    "defaultTTL": "24:00:00"
  },
  "rateLimiting": {
    "maxRequestsPerMinute": 300,
    "failFast": true
  },
  "credentialStorage": {
    "provider": "EncryptedFile",  // or "KeyVault"
    "keyVaultUrl": null
  },
  "logging": {
    "level": "Information",
    "outputToFile": false,
    "filePath": null
  }
}
```

## Configuration File Locations

The library looks for configuration files in the following locations (in order of precedence):

1. **Explicit path** (specified in code or CLI)
2. **Current directory**: `./config/`
3. **User config directory**:
   - Linux/macOS: `~/.config/azdw/`
   - Windows: `%APPDATA%\azdw\`
4. **System config directory**:
   - Linux: `/etc/azdw/`
   - macOS: `/Library/Application Support/azdw/`
   - Windows: `%PROGRAMDATA%\azdw\`

## Environment Variables

You can override configuration paths using environment variables:

- `AZDO_WI_CONFIG_DIR`: Override configuration directory
- `AZDO_WI_CACHE_DIR`: Override cache directory
- `AZDO_WI_LOG_LEVEL`: Set logging level (Debug, Info, Warning, Error)

**Example:**
```bash
export AZDO_WI_CONFIG_DIR=/path/to/custom/config
azdw query --connection MyConn --type Epic
```

## Configuration Validation

### Validate Configuration via CLI

```bash
azdw config show --section all
```

### Validate Configuration in Code

```csharp
var configManager = serviceProvider.GetRequiredService<IConfigurationManager>();
var isValid = await configManager.ValidateConfigAsync<AppConfiguration>("config/app.jsonc");

if (!isValid)
{
    Console.WriteLine("Configuration validation failed");
}
```

## Best Practices

1. **Use JSONC format**: Comments help document configuration choices
2. **Version control**: Keep field mappings and templates in version control
3. **Separate credentials**: Never commit credentials; use secure storage
4. **Environment-specific configs**: Use different configs for dev/test/prod
5. **Test mappings**: Validate field mappings against your process templates
6. **Template versioning**: Include version in template IDs when making breaking changes
7. **Cache configuration**: Enable caching for better performance, use Cosmos DB in production

## Troubleshooting

### Field Mapping Issues

**Problem**: Field not found errors

**Solution**: Verify field reference names using Azure DevOps Process Template Editor or the Azure DevOps REST API:

```bash
# Get available fields
curl https://dev.azure.com/myorg/_apis/wit/fields?api-version=7.0 \
  -u :${PAT_TOKEN}
```

### Template Rendering Issues

**Problem**: Template syntax errors

**Solution**: Test templates with sample data:

```bash
azdw report generate \
  --template my-template \
  --query sample-data.json \
  --output test-output.md
```

### Configuration Not Found

**Problem**: Configuration file not loaded

**Solution**: Check search paths and verify file permissions:

```bash
# Show current configuration
azdw config show

# Set custom config directory
export AZDO_WI_CONFIG_DIR=/path/to/config
```

## URL Domain Mappings

URL domain mappings handle TFS/Azure DevOps server domain name changes by automatically transforming old hyperlink URLs to new URLs during relationship resolution and display.

### Configuration File

The URL mapping configuration is stored at `~/.azdw/config/url-mappings.jsonc` by default. An example file is provided at `config/url-mappings-example.jsonc`.

### Structure

```json
{
  "enabled": true,
  "domainMappings": [
    {
      "oldUrlPrefix": "https://old-tfs-server.company.com:8090/tfs/",
      "newUrlPrefix": "https://new-tfs-server.company.com/tfs/",
      "description": "TFS server migration from old to new server"
    },
    {
      "oldUrlPrefix": "http://internal-tfs.local/",
      "newUrlPrefix": "https://external-devops.company.com/",
      "description": "HTTP to HTTPS and internal to external domain migration"
    }
  ]
}
```

## Hyperlink Relationship Mappings

Hyperlink relationship mappings allow you to define how hyperlinks between work item types should be interpreted. By default, hyperlinks are treated according to the `--hyperlinks-as` CLI parameter, but you can create type-specific rules that override this behavior.

### Configuration File

The hyperlink mapping configuration is stored at:
- `~/.azdw/config/hyperlink-mappings.jsonc` (user-specific)
- `./config/hyperlink-mappings.jsonc` (workspace-specific)

An example file is provided at `config/hyperlink-mappings-example.jsonc`.

### Structure

```json
{
  "description": "Hyperlink relationship mappings for work item type pairs",
  "defaultBehavior": "Dependency",
  "mappings": [
    {
      "sourceType": "ProductBacklogItem",
      "targetType": "ProductBacklogItem",
      "relationship": "Dependency",
      "description": "PBI-to-PBI hyperlinks represent dependencies"
    },
    {
      "sourceType": "*",
      "targetType": "Epic",
      "relationship": "Related",
      "description": "Wildcard: Any work item type linking to an Epic is considered related"
    }
  ]
}
```

### Properties

- **description**: Human-readable description of the configuration
- **defaultBehavior**: Default relationship type when no mapping matches and no CLI override is provided
  - Valid values: `Parent`, `Child`, `Dependency`, `Related`
- **mappings**: Array of type-specific mapping rules
  - **sourceType**: Source work item type (use `*` as wildcard to match any type)
  - **targetType**: Target work item type (use `*` as wildcard to match any type)
  - **relationship**: Relationship type for this hyperlink pair
  - **description**: Optional explanation of the mapping rule

### Precedence Rules

When determining the relationship type for a hyperlink, the following precedence applies (highest to lowest):

1. **CLI parameter override**: `--hyperlinks-as Parent` on command line
2. **Specific type-to-type mapping**: Both sourceType and targetType match exactly
3. **Wildcard mapping**: One or both types use `*` wildcard (more specific matches win)
4. **Default behavior**: `defaultBehavior` from configuration
5. **No relationship**: Hyperlink is skipped (requires explicit CLI parameter)

### Wildcard Support

Use `*` as a wildcard to match any work item type:

- `"sourceType": "*", "targetType": "Epic"` - Matches any source type linking to Epic
- `"sourceType": "Task", "targetType": "*"` - Matches Task linking to any target type
- `"sourceType": "*", "targetType": "*"` - Matches any hyperlink (acts as catch-all)

### Specificity Scoring

When multiple mappings match, the most specific one wins:

- Both types match exactly: Specificity = 3
- One type matches exactly, one wildcard: Specificity = 2
- Both types are wildcards: Specificity = 1

### Usage Examples

#### Example 1: Directional Parent-Child Relationships

```json
{
  "description": "Portfolio hierarchy with directional relationships",
  "mappings": [
    {
      "sourceType": "Feature",
      "targetType": "Epic",
      "relationship": "Parent",
      "description": "Features point up to their parent Epics"
    }
  ]
}
```

#### Example 2: Cross-Team Dependencies

```json
{
  "description": "Cross-team dependency management",
  "defaultBehavior": "Related",
  "mappings": [
    {
      "sourceType": "ProductBacklogItem",
      "targetType": "ProductBacklogItem",
      "relationship": "Dependency",
      "description": "PBI-to-PBI links are dependencies"
    },
    {
      "sourceType": "Bug",
      "targetType": "ProductBacklogItem",
      "relationship": "Dependency",
      "description": "Bugs can depend on PBIs"
    },
    {
      "sourceType": "*",
      "targetType": "*",
      "relationship": "Related",
      "description": "All other hyperlinks are related items"
    }
  ]
}
```

#### Example 3: Mixed Process Templates

```json
{
  "description": "Handle mixed Agile and Scrum process templates",
  "mappings": [
    {
      "sourceType": "User Story",
      "targetType": "Epic",
      "relationship": "Parent",
      "description": "Agile User Stories link to Epics"
    },
    {
      "sourceType": "Product Backlog Item",
      "targetType": "Epic",
      "relationship": "Parent",
      "description": "Scrum PBIs link to Epics"
    }
  ]
}
```

### Command Line Interaction

The hyperlink mapping configuration works seamlessly with CLI parameters:

```bash
# Use mappings from config file
azdw relationship closure --id 12345 --target-type BusinessOpportunity

# Override all mappings with CLI parameter
azdw relationship closure --id 12345 --target-type BusinessOpportunity --hyperlinks-as Parent

# Let config determine relationship per type-pair
azdw relationship closure --id 12345 --target-type BusinessOpportunity --include-hyperlinks
```

### Validation

The configuration is validated on load:

- All relationship types must be one of: `Parent`, `Child`, `Dependency`, `Related`
- At least one mapping must be defined if `defaultBehavior` is not set
- Source and target types cannot both be empty (but can be `*`)

Validation errors are logged and the configuration will not be loaded if invalid.

### Properties

- **enabled**: Boolean flag to enable/disable URL mapping globally
- **domainMappings**: Array of URL mapping rules applied in order (first match wins)
  - **oldUrlPrefix**: The old URL prefix to match (case-insensitive)
  - **newUrlPrefix**: The new URL prefix to replace with
  - **description**: Optional description of the mapping rule

### Usage

The URL mapping service automatically transforms URLs during:
- Relationship resolution
- Work item display
- Report generation
- Visualization rendering

### MCP Server Commands

When using the MCP server integration, you can manage URL mappings via CLI commands:

```bash
# List current URL mappings
azdw config url-mappings list

# Add a new mapping
azdw config url-mappings add \
  --old-url "https://old.company.com/" \
  --new-url "https://new.company.com/" \
  --description "Company domain migration"

# Remove a mapping by index
azdw config url-mappings remove --index 0

# Clear all mappings
azdw config url-mappings clear

# Enable/disable URL mapping
azdw config url-mappings set-enabled --enabled true
```

### Client-Specific Mappings

For distribution packages, client-specific URL mappings can be pre-configured:

1. Create a file at `clients/<ClientName>/config/url-mappings.jsonc`
2. Configure the client-specific mappings
3. Run `create-dist-package.ps1` with the appropriate client name

The distribution package will include the pre-configured URL mappings, which will be copied to each platform's config directory.

## File Relationship Configuration

File relationship configuration enables you to convert hyperlinks to file artifacts (such as Architecture Decision Records, RFCs, or design documents) into "fake" work items that appear in relationship queries and visualizations.

### Use Cases

- **Architecture Decision Records (ADRs)**: Link work items to ADR documents and see them in relationship graphs
- **RFCs (Request for Comments)**: Track which work items implement specific RFCs
- **Design Documents**: Connect implementation work items to their design specifications
- **External Documentation**: Include links to wikis, Confluence pages, or other documentation systems
- **External OSS GitHub Issues & Docs**: Track dependencies on third-party open-source projects by linking to their GitHub issues, pull requests, or documentation

### Configuration File

The file relationship configuration is stored at:
- `~/.azdw/config/file-relationship-config.jsonc` (user-specific)
- `./config/file-relationship-config.jsonc` (workspace-specific)

Example and schema files are provided:
- `config/file-relationship-config-example.jsonc`
- `config/file-relationship-config-schema.json`

### Structure

```json
{
  "$schema": "./file-relationship-config-schema.json",
  "description": "File relationship patterns for ADRs and design docs",
  "patterns": [
    {
      "name": "GitHub-ADR",
      "urlPattern": "https://github\\.com/(?<Org>[^/]+)/(?<Repo>[^/]+)/blob/(?<Branch>[^/]+)/docs/adr/(?<Id>\\d+)-(?<FileName>[^.]+)\\.md",
      "workItemType": "ADR",
      "relationshipType": "ImplementedBy",
      "startWorkItemId": 2000000,
      "fieldMappings": {
        "Title": "ADR-${Id}: ${FileName}",
        "AreaPath": "${Org}/${Repo}",
        "State": "Approved",
        "Tags": "ADR,Architecture,${Branch}"
      }
    },
    {
      "name": "Confluence-RFC",
      "urlPattern": "https://(?<Domain>[^/]+)/wiki/spaces/(?<Space>[^/]+)/pages/(?<PageId>\\d+)/RFC-(?<RfcNumber>\\d+)",
      "workItemType": "RFC",
      "relationshipType": "Implements",
      "startWorkItemId": 3000000,
      "fieldMappings": {
        "Title": "RFC-${RfcNumber}",
        "AreaPath": "${Space}",
        "State": "Published"
      }
    }
  ]
}
```

### Pattern Properties

| Property | Required | Description |
| -------- | -------- | ----------- |
| `name` | Yes | Unique identifier for this pattern |
| `urlPattern` | Yes | Regex pattern with named capture groups (e.g., `(?<Id>\\d+)`) |
| `workItemType` | Yes | Logical type for fake work items (e.g., "ADR", "RFC", "DesignDoc") |
| `relationshipType` | No | Relationship type (default: "Related"). Options: Parent, Child, Dependency, Related, ImplementedBy, Implements |
| `startWorkItemId` | No | Base ID for fake work items (default: 2000000). Combined with captured or hashed ID |
| `fieldMappings` | No | Map of field names to values with `${CaptureGroup}` substitution |

### Field Mapping Substitution

Field mappings support placeholder substitution using `${CaptureGroupName}`:

```json
{
  "fieldMappings": {
    "Title": "ADR-${Id}: ${FileName}",
    "AreaPath": "${Org}/${Repo}",
    "Tags": "ADR,${Branch}"
  }
}
```

Available placeholders are any named capture groups from your `urlPattern`.

### Fake Work Item IDs

IDs are assigned using one of two methods:

1. **Captured ID**: If your pattern has an `Id` capture group, the ID is computed as `startWorkItemId + captured_id`
2. **Hash-based ID**: If no `Id` group, a deterministic hash of the URL generates a stable ID within a 100,000 range

This ensures the same URL always produces the same fake work item ID across runs.

### Usage Examples

#### Query with File Relationships

```bash
# Resolve relationships including hyperlinks to ADRs
azdw relationship closure --id 12345 --include-hyperlinks --depth 2

# Output will include fake ADR work items like:
# 12345 (User Story) --ImplementedBy--> 2000001 (ADR) "ADR-001: Initial Architecture"
```

#### With File Content Extraction

When using `--resolve-file-content`, azdw can fetch the actual content of Git-hosted files and extract field values using regex patterns:

```bash
# Extract ADR status from file content (hyperlinks are resolved by default)
azdw relationship resolve --work-items 12345 --resolve-file-content
```

Configure content extraction patterns in `fieldMappings` with `contentPattern`:

```json
{
  "fieldMappings": {
    "State": {
      "default": "n/a",
      "contentPattern": "(?m)^[>*]\\s*[*_]*Status[*_]*\\s*[:]\\s*(?<State>\\w+)"
    }
  }
}
```

> **⚠️ Required PAT Permission:** To use `--resolve-file-content`, your PAT must include the **Code (Read)** scope.
> This is required to fetch Git file contents via the Azure DevOps REST API.
> See [Azure DevOps Permissions](../docs/Azure-DevOps-Permissions.md) for details.

#### Visualization with ADRs

```bash
# Generate GraphML including ADR relationships
azdw visualize closure --id 12345 --format graphml --include-hyperlinks --output graph.graphml
```

The fake ADR work items will appear as nodes in the graph with their configured work item type and title.

### Linking to External OSS GitHub Issues and Docs

> **💡 Tip:** File relationship patterns are not limited to internal documentation—they can also match external URLs such as GitHub issues, pull requests, or documentation pages from open-source projects you depend on.

This is useful when:
- Your work items reference upstream bugs or feature requests in third-party OSS libraries
- You want to track which work items are blocked by external issues
- You need to visualize dependencies on OSS projects in relationship graphs

#### Example: GitHub Issues Pattern

```json
{
  "name": "GitHub-Issue",
  "description": "External GitHub issues from OSS dependencies",
  "urlPattern": "https://github\.com/(?<Owner>[^/]+)/(?<Repo>[^/]+)/issues/(?<IssueNumber>\\d+)",
  "relationshipName": "Depends On",
  "workItemType": "GitHub Issue",
  "startWorkItemId": 5000000,
  "enabled": true,
  "fieldMappings": {
    "Title": "${Owner}/${Repo}#${IssueNumber}",
    "State": "Open",
    "Tags": "OSS, GitHub, External, Fake"
  }
}
```

With this pattern, a hyperlink like `https://github.com/mygithubid/myproject/issues/4711` will be recognized and displayed as a fake work item titled "mygithubid/myproject#4711".

#### Example: GitHub Pull Requests

```json
{
  "name": "GitHub-PR",
  "description": "External GitHub pull requests",
  "urlPattern": "https://github\.com/(?<Owner>[^/]+)/(?<Repo>[^/]+)/pull/(?<PrNumber>\\d+)",
  "relationshipName": "Related",
  "workItemType": "GitHub PR",
  "startWorkItemId": 5100000,
  "enabled": true,
  "fieldMappings": {
    "Title": "PR: ${Owner}/${Repo}#${PrNumber}",
    "State": "Open",
    "Tags": "OSS, GitHub, PR, External, Fake"
  }
}
```

#### Example: GitHub Repository Documentation

```json
{
  "name": "GitHub-Docs",
  "description": "GitHub repository documentation (README, docs folder)",
  "urlPattern": "https://github\.com/(?<Owner>[^/]+)/(?<Repo>[^/]+)/blob/(?<Branch>[^/]+)/(?<FilePath>.+\\.md)",
  "relationshipName": "References",
  "workItemType": "External Doc",
  "startWorkItemId": 5200000,
  "enabled": true,
  "fieldMappings": {
    "Title": "${Owner}/${Repo}: ${FilePath}",
    "State": "Published",
    "Tags": "OSS, GitHub, Documentation, External, Fake"
  }
}
```

These patterns allow you to include external GitHub resources in your relationship closures and visualizations, making it easier to understand how your internal work items relate to external open-source dependencies.

### Connection Auto-Detection

When configured connections have base URLs that match your file hyperlinks, the fake work items will automatically be assigned to the correct connection. For example:

- Connection: `https://github.com/myorg` → Matches ADR URLs like `https://github.com/myorg/myrepo/...`
- Connection: `https://confluence.company.com` → Matches RFC URLs

### Best Practices

1. **Use descriptive pattern names** for easier debugging and logging
2. **Set appropriate startWorkItemId ranges** to avoid collisions between pattern types
3. **Include capture groups for meaningful data** like document IDs, titles, and categories
4. **Use consistent relationshipType** that reflects the semantic meaning (ImplementedBy, Implements, etc.)
5. **Test patterns** with sample URLs before deploying

### Troubleshooting

Enable verbose logging to see pattern matching:

```bash
azdw relationship closure --id 12345 --include-hyperlinks --verbose
```

Look for log messages like:
- `Matched file hyperlink {url} as {type} with relationship {relation}`
- `Added file relationship from work item {id} to {type} '{title}'`

## Glossary Configuration

The glossary configuration provides domain-specific abbreviations and terminology to help AI models understand work item content. This is especially useful for `--ai-tell-story` and other AI analysis features.

### Location

The system looks for `glossary.jsonc` in this order:
1. `AZDW_CLIENT_CONFIG_DIR` environment variable path
2. `~/.azdw/config/glossary.jsonc` (user-specific)
3. `<executable>/config/glossary.jsonc` (application default)

### Configuration Structure

```json
{
  "abbreviations": {
    "PBI": "Product Backlog Item",
    "DI": "Dependency Injection",
    "CI": "Continuous Integration",
    "CD": "Continuous Deployment"
  },
  "terms": {
    "SignalR": "Real-time communication library for .NET applications",
    "Redis": "In-memory data structure store used for caching and messaging",
    "ServiceBus": "Azure Service Bus - cloud messaging service"
  },
  "projectContext": "This project involves developing software that processes data in cloud and edge environments."
}
```

### Properties

| Property | Type | Description |
| -------- | ----- | ---------- |
| `abbreviations` | Object | Key-value pairs where key is the abbreviation and value is its meaning |
| `terms` | Object | Key-value pairs where key is a domain term and value is its explanation |
| `projectContext` | String | Optional high-level description of the project domain |

### Example

See `glossary-example.jsonc` for a complete example with healthcare imaging terms.

### Usage

When AI features like `--ai-tell-story` are used, the glossary is automatically included in the AI prompt if configured. The AI will use these definitions to better understand:
- Technical abbreviations in work item titles and descriptions
- Domain-specific terminology
- Project context for more relevant analysis

### Client-Specific Override

For multi-client environments, set `AZDW_CLIENT_CONFIG_DIR`:

```bash
export AZDW_CLIENT_CONFIG_DIR=/path/to/client/config
```

This allows different clients to have their own glossaries with project-specific terminology.

## Global Stack Rank Profiles

`global-stack-rank.jsonc` defines named profiles that let a query return a single, normalized,
prioritized "virtual backlog" across multiple Azure DevOps organizations/projects and GitHub
repositories at once — even when each source uses a different stack rank field and value range.

### Profile Structure

Each profile has a unique `name` and one or more `sources`. A source selects a stable scope
(Azure DevOps organization + project, or GitHub organization/owner + repository), optionally
narrowed further by area path, iteration path, work item type, tags, or field criteria, and
defines how that source's raw ranking field is normalized:

```jsonc
{
  "profiles": [
    {
      "name": "PlatformValueStream",
      "sources": [
        {
          "name": "core-services",
          "provider": "AzureDevOps",
          "organization": "acmeflow",
          "project": "Core Services",
          "rankField": "Microsoft.VSTS.Common.StackRank",
          "sourceMin": 1,
          "sourceMax": 500,
          "direction": "LowerIsHigher",
          "priority": 10
        },
        {
          "name": "platform-oss",
          "provider": "GitHub",
          "organization": "acme-platform",
          "repository": "widgets",
          "rankField": "Priority",
          "sourceMin": 0,
          "sourceMax": 5,
          "direction": "HigherIsHigher"
        }
      ]
    }
  ]
}
```

- `direction: LowerIsHigher` means a lower raw value is higher priority (typical stack rank);
  `HigherIsHigher` means a higher raw value is higher priority (e.g. a business-value score).
- Each source's raw value is linearly mapped onto a shared 0-100 scale (0 = highest priority),
  so sources with different fields and ranges become directly comparable.
- When multiple sources in a profile match the same work item, the highest `priority` wins, then
  the more specific source (more configured constraints), then declaration order.
- Work items that don't match any source, or whose ranking field is missing/non-numeric, are
  still returned — placed after all ranked items, with a status/diagnostic explaining why.
- A failed or unavailable connection for one source does not fail the whole query; other sources
  still contribute, and the failure is reported as a source-level diagnostic.

### Activating a Profile

Global ranking is always explicit and never changes ordinary query behavior:

- CLI: `azdw query --global-stack-rank PlatformValueStream`
- MCP: pass `globalStackRankProfile` to `QueryWorkItems`
- REST/GraphQL: set `globalStackRankProfile` on the query filter/input

An active profile always controls the final order — it cannot be combined with an explicit
`--sort` (CLI) or non-default `sortBy` (MCP/REST/GraphQL); combining them is rejected. `MaxResults`
is applied as an exact global limit after normalization, not per source, so the true global top N
items are always returned even when sources have very different backlog sizes.

## See Also

- [Template Documentation](templates/README.md)
- [Core Library Documentation](../src/azdw.lib/README.md)
- [CLI Documentation](../src/azdw/README.md)
- [API Documentation](../src/azdw.service/README.md)
- [Scriban Documentation](https://github.com/scriban/scriban/blob/master/doc/language.md)
