# CLI Use Cases

This document provides comprehensive examples and use cases for the Azure DevOps Work Item (azdw) command-line interface.

## Table of Contents

1. [Global Options](#global-options)
2. [Connection Management](#connection-management)  
3. [Credential Management](#credential-management)
4. [Work Item Queries](#work-item-queries)
5. [WIQL Queries](#wiql-queries)
6. [Work Item Operations](#work-item-operations)
7. [Report Generation](#report-generation)
8. [Data Visualization](#data-visualization)
9. [Relationship Management](#relationship-management)
10. [Metadata](#metadata)
11. [Cache Management](#cache-management)
12. [Field Mappings](#field-mappings)
13. [MCP Server](#mcp-server)
14. [AI Chat](#ai-chat)

## Global Options

All commands support these global options:
- `-v, --verbose`: Enable verbose logging output
- `--silent`: Suppress informational messages, show only data output
- `--full-traces`: Enable detailed execution tracing with secure parameter logging
- `--json`: Output in machine-readable JSON format (overrides --format when specified)
- `--no-plugins`: Disable plugin loading (useful for testing and troubleshooting)
- `--skip-plugin-verification`: Skip plugin security verification (WARNING: security risk)
- `--allow-unsigned-plugins`: Allow loading plugins without valid Authenticode signatures
- `--info`: Display build and version information
- `-?, -h, --help`: Show help and usage information

**Examples:**
```bash
# Normal output with informational messages
azdw query --connections MyOrg --limit 10

# Silent mode - only data table
azdw query --connections MyOrg --limit 10 --silent

# Verbose mode - detailed logging
azdw query --connections MyOrg --limit 10 --verbose

# Full tracing - detailed execution tracing with secure parameter logging
azdw query --connections MyOrg --limit 10 --full-traces
```

The `--silent` option is particularly useful when:
- Piping output to other tools or scripts
- Focusing on data without status messages
- Automating queries in CI/CD pipelines

The `--verbose` and `--full-traces` options are useful for:
- Debugging connection or authentication issues
- Understanding detailed execution flow
- Troubleshooting unexpected behavior

## Connection Management

The connection management commands allow you to configure connections to Azure DevOps organizations and projects.

### List Connections

View all configured connections:
```bash
# List all connections with their status
azdw connection list

# Using short alias
azdw connection ls
```

### Add Connections

Add a new Azure DevOps connection (organization or project):
```bash
# Add connection with PAT authentication (default)
azdw connection add --name "MyCompany" --url "https://dev.azure.com/mycompany"

# Add project connection with PAT authentication
azdw connection add --name "MyProject" --url "https://dev.azure.com/mycompany/MyProject"

# Add connection with device code flow authentication  
azdw connection add --name "MyCompany" --url "https://dev.azure.com/mycompany" --auth-type code --tenant "mycompany.onmicrosoft.com"

# Add connection with interactive browser authentication
azdw connection add --name "MyCompany" --url "https://dev.azure.com/mycompany" --auth-type interactive --tenant "mycompany.onmicrosoft.com"

# Preview what would be added (dry run)
azdw connection add --name "MyCompany" --url "https://dev.azure.com/mycompany" --dry-run

# Get JSON output for automation
azdw connection add --name "MyCompany" --url "https://dev.azure.com/mycompany" --json
```

> **💡 Important:** You must set the chosen credential after adding a connection (see [Credential Management](#credential-management)).

### Remove Connections

Remove a connection configuration:
```bash
# Remove connection by name
azdw connection remove MyCompany

# Using aliases
azdw connection delete MyCompany
azdw connection rm MyCompany
```

### Test Connection

Verify connection connectivity:
```bash
# Test specific connection
azdw connection test --name MyCompany

# Test all connections
azdw connection test
```

## Credential Management

> **💡 Important:** You must add a connection first (see [Connection Management](#connection-management)) before configuring credentials. The authentication type you choose here must match what you specified when adding the connection (`pat`, `code`, or `interactive`).

### Interactive Credential Setup

Add credentials with interactive prompts:
```bash
# Add credentials for connection
azdw credential add --connection MyCompany

# Add specific authentication types
azdw credential add --connection MyCompany --auth-type pat
azdw credential add --connection MyCompany --auth-type code --tenant "mycompany.onmicrosoft.com"
azdw credential add --connection MyCompany --auth-type interactive --tenant "mycompany.onmicrosoft.com"

# Skip credential validation during setup
azdw credential add --connection MyCompany --auth-type pat --validate false
```

### Add Personal Access Token

Add PAT credentials directly:
```bash
# Add PAT credential
azdw credential add-pat --connection MyCompany --token "your-pat-token-here"

# With description and validation
azdw credential add-pat --connection MyCompany --token "your-pat-token" --description "Main development token" --validate
```

### Add OAuth Credentials

```bash
# Device Code Flow
azdw credential add-code --connection MyCompany --tenant "mycompany.onmicrosoft.com"

# Interactive Browser Flow
azdw credential add-interactive --connection MyCompany --tenant "mycompany.onmicrosoft.com"
```

### Manage Existing Credentials

```bash
# List all stored credentials
azdw credential list

# Remove credentials for specific connection
azdw credential remove --connection MyCompany

# Validate credential validity
azdw credential validate --connection MyCompany

# Validate specific connection
azdw credential validate --connection MyCompany

# Sign out from a connection
azdw credential signout --connection MyCompany

# Clear all stored credentials
azdw credential clear --confirm

# Repair corrupted credentials
azdw credential repair --backup
```

## Work Item Queries

Query work items across your configured connections with extensive filtering options.

### Basic Queries

```bash
# Query all work items with default settings
azdw query

# Query specific connections only (comma-separated)
azdw query --connections Org1,Org2

# Limit number of results
azdw query --limit 100
azdw query --limit 50

# Choose output format
azdw query --output table   # default
azdw query --json
azdw query --output csv
azdw query --output ids
```

### Querying All Work Items (No Filters)

When querying without filters, the CLI will prompt for confirmation to prevent accidentally querying all work items across all connections, which may take time and transfer large amounts of data.

```bash
# Interactive mode - shows confirmation prompt
azdw query
# WARNING: No filters specified. This will query ALL work items across all connections.
# This may take a long time and transfer a large amount of data.
# Do you want to continue? (y/N):

# Skip confirmation prompt with --yes flag
azdw query --yes
azdw query -y  # short form

# Non-interactive mode (piped/redirected) requires --yes
echo "" | azdw query
# Error: No filters specified.
# When running non-interactively, you must either:
#   - Specify filters (--types, --states, etc.)
#   - Use --yes flag to query all work items

# Automation/scripting - use --yes
azdw query --yes --json > all-work-items.json
```

**When to use `--yes`:**
- Automation and CI/CD pipelines
- Scripts that intentionally query all work items
- Non-interactive environments (cron jobs, scheduled tasks)
- When you've verified you want to query all items

**Best practices:**
- Always use filters when possible to limit the scope
- Use `--limit` to cap the number of results
- Combine with `--silent` in automation to reduce output noise
- Add specific `--connections` to limit the scope to relevant organizations

### Filtering Options

Filter work items by various criteria:
```bash
# Filter by work item type (comma-separated for multiple)
azdw query --work-item-types Bug,Task
azdw query --types "User Story"

# Filter by state
azdw query --states Active,New

# Filter by area path
azdw query --area-paths "MyProject\\Feature1"

# Filter by iteration path  
azdw query --iteration-paths "Sprint 1"

# Filter by assigned user
azdw query --assigned-to "john.doe@company.com"

# Filter by tags
azdw query --tags urgent,bug

# Project filtering
azdw query --projects "Project1,Project2"

# Priority filtering
azdw query --priority "1,2"

# Severity filtering
azdw query --severity "1 - Critical,2 - High"
```

### Date Range Filtering

```bash
# Filter by creation date
azdw query --created-after "2024-01-01"
azdw query --created-before "2024-12-31"

# Filter by modification date
azdw query --modified-after "2024-01-01"
azdw query --modified-before "2024-12-31"

# Combine date filters
azdw query --created-after "2024-01-01" --modified-after "2024-06-01"
```

### Relationship and Grouping Options

```bash
# Cross-connection relationship resolution is enabled by default
# Use --no-cross-conn to disable if needed
azdw query --types Epic --json

# Explicitly disable cross-connection relationships
azdw query --types Epic --no-cross-conn --json

# Group results by connection/organization
azdw query --types Feature --by-conn --json

# Group results by project
azdw query --types Feature --by-project --json

# Exclude disabled work item types from results
azdw query --types Bug,Task --exclude-disabled-types --json

# Combine relationship and grouping options (cross-conn is default)
azdw query --types Epic,Feature --by-conn --json
```

### Advanced Options

```bash
# Include work item relations in results
azdw query --relationships

# Specify additional fields to retrieve
azdw query --fields "System.Title,System.State,Microsoft.VSTS.Common.Priority"

# Include failed connection queries in output
azdw query --include-failed

# Output as JSON
azdw query --json

# Skip confirmation prompt (for automation)
azdw query --yes
azdw query -y  # short form

# Combine multiple filters
azdw query --types "Bug" --states "Active" --assigned-to "john.doe@company.com" --json

# Combine filters with specific connections (comma-separated)
azdw query -c Org1,Org2 --types "Bug" --states "Active" --relationships

# Full-featured query with all options (cross-connection is enabled by default)
azdw query \
  --connections Org1,Org2 \
  --types Epic,Feature \
  --states Active \
  --by-conn \
  --exclude-disabled-types \
  --relationships \
  --json

# Automation-friendly: silent mode with no confirmation
azdw query --silent --yes --json > all-items.json
```

## Work Item Operations

Create, retrieve, update, and delete individual work items.

### Get Work Item

Retrieve a work item by ID:
```bash
# Get work item by ID
azdw workitem get --id 12345

# Get work item with specific fields
azdw workitem get --id 12345 --fields "System.Title,System.State,System.AssignedTo"

# Get work item with all relations
azdw workitem get --id 12345 --expand relations

# Get work item in JSON format
azdw workitem get --id 12345 --format json

# Get work item from specific connection
azdw workitem get --id 12345 --connection MyOrg
```

### Create Work Item

Create a new work item:
```bash
# Create with inline fields
azdw workitem create \
  --connection MyOrg \
  --type Task \
  --title "Implement feature X" \
  --description "Add new functionality" \
  --tags "feature,backend"

# Create with area and iteration paths
azdw workitem create \
  --connection MyOrg \
  --type Bug \
  --title "Fix login issue" \
  --area "MyProject\\Frontend" \
  --iteration "Sprint 5"

# Create with custom fields (--field is repeatable)
azdw workitem create \
  --connection MyOrg \
  --type Task \
  --title "Code review" \
  --assigned-to "john.doe@company.com" \
  --field "Microsoft.VSTS.Common.Priority:1" \
  --field "System.Tags:review,backend"

# Create a single work item from a spec file (JSON/JSONC)
# workitem.jsonc:
# { "fields": { "Title": "My task", "Description": "...", "Priority": 2 }, "project": "MyProject" }
azdw workitem create \
  --connection MyOrg \
  --type Task \
  --from-file workitem.jsonc

# Batch-create multiple work items from a multi-item spec file
# batch.jsonc:
# { "workItems": [
#     { "workItemType": "Task", "fields": { "Title": "Task A" }, "project": "MyProject" },
#     { "workItemType": "Bug",  "fields": { "Title": "Bug B"  }, "project": "MyProject" }
#   ] }
azdw workitem create \
  --connection MyOrg \
  --from-file batch.jsonc

# Preview batch creation without creating anything
azdw workitem create \
  --connection MyOrg \
  --from-file batch.jsonc \
  --dry-run
```

### Update Work Item

Update an existing work item:
```bash
# Update work item fields (--field is repeatable)
azdw workitem update 12345 \
  --field "System.State:Active" \
  --field "System.AssignedTo:jane@company.com"

# Update title and state via dedicated options
azdw workitem update 12345 \
  --connection MyOrg \
  --title "Updated title" \
  --state Resolved

# Add / remove tags
azdw workitem update 12345 --tags-add "urgent,customer-reported"
azdw workitem update 12345 --tags-remove "in-progress"

# Update from a spec file (ID can come from the file or be supplied on the CLI)
azdw workitem update 12345 --connection MyOrg --from-file updates.jsonc

# Upsert from spec file — create the work item if it does not yet exist
# (requires the spec file entries to include workItemType and Title)
azdw workitem update \
  --connection MyOrg \
  --from-file sprint-items.jsonc \
  --upsert

# Preview changes without applying them
azdw workitem update 12345 --from-file updates.jsonc --dry-run
```

### Delete Work Item

Delete a work item:
```bash
# Delete work item (with confirmation)
azdw workitem delete 12345

# Using alias
azdw workitem remove 12345
azdw workitem rm 12345

# Delete from specific connection
azdw workitem delete 12345 --connection MyOrg

# Skip confirmation prompt
azdw workitem delete 12345 --yes

# Perform dry run (preview deletion)
azdw workitem delete 12345 --dry-run
```

## WIQL Queries

Execute Work Item Query Language (WIQL) queries for advanced work item retrieval.

For complete WIQL syntax reference, see the [Microsoft WIQL documentation](https://learn.microsoft.com/en-us/azure/devops/boards/queries/wiql-syntax).

### Getting WIQL from Existing Queries

If you have existing queries in Azure DevOps and want to use them with the CLI, you can easily retrieve their WIQL syntax using the [Wiql Editor](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.wiql-editor) extension:

1. **Install the Extension**: Add the "Wiql Editor" extension to your Azure DevOps organization from the Visual Studio Marketplace
2. **Navigate to Queries**: Go to the Queries view in your Azure DevOps project
3. **Access WIQL**: Select the dropdown menu (3 dots menu) next to any query
4. **View WIQL**: Select **"Edit query wiql"** from the menu

This opens the query in WIQL format, which you can copy and use directly with the `azdw wiql` command. This is particularly useful for:
- Converting existing saved queries to CLI commands
- Understanding the WIQL syntax for complex queries
- Migrating team queries to automated scripts
- Running the same query across multi organizations with this tool

**Example workflow:**
```bash
# 1. Copy WIQL from Azure DevOps using "Edit query wiql"
# 2. Execute with azdw CLI
azdw wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.State] = 'Active'"

# 3. Or save to file for reuse
echo "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.State] = 'Active'" > query.wiql
azdw wiql @query.wiql
```

### Basic WIQL Execution

```bash
# Execute WIQL query string
azdw wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.WorkItemType] = 'Bug'"

# Execute WIQL from file
azdw wiql @query.wiql

# Limit number of results  
azdw wiql "SELECT * FROM WorkItems" --first 50
```

### WIQL Target Connections

```bash
# Query all configured connections (default)
azdw wiql "SELECT * FROM WorkItems"

# Query specific connections only (comma-separated)
azdw wiql "SELECT * FROM WorkItems" --connections Org1,Org2
```

### WIQL Output Formats

```bash
# Table format (default)
azdw wiql "SELECT * FROM WorkItems" --output table

# JSON format
azdw wiql "SELECT * FROM WorkItems" --json

# CSV format
azdw wiql "SELECT * FROM WorkItems" --output csv

# IDs only format
azdw wiql "SELECT * FROM WorkItems" --output ids

# Pretty-printed JSON
azdw wiql "SELECT * FROM WorkItems" --json --pretty
```

### WIQL Validation and Debugging

```bash
# Validate WIQL syntax without executing
azdw wiql "SELECT * FROM WorkItems WHERE [Invalid.Field] = 'test'" --validate

# Show example WIQL queries
azdw wiql --examples

# Include details about failed connection queries
azdw wiql "SELECT * FROM WorkItems" --include-failed
```

### Example WIQL Queries

```bash
# Get all bugs created in the last 7 days
azdw wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.WorkItemType] = 'Bug' AND [System.CreatedDate] >= @Today - 7"

# Get high priority items assigned to specific user
azdw wiql "SELECT * FROM WorkItems WHERE [System.AssignedTo] = 'john.doe@company.com' AND [Microsoft.VSTS.Common.Priority] <= 2"

# Export recent work items to CSV
azdw wiql "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.ChangedDate] >= @Today - 30" --output csv > recent-changes.csv

# Query specific connections for active bugs
azdw wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.WorkItemType] = 'Bug' AND [System.State] = 'Active'" -c "MyOrg"
```

## Report Generation

Generate formatted reports from work item data across connections using templates.

### Overview

The `azdw report generate` command supports two workflows:
1. **Direct Query + Generate (New)**: Query and generate in one command
2. **Two-Step (Legacy)**: Query to JSON file, then generate from file

### Direct Query + Generate (Recommended)

Query work items and generate reports in a single command:

```bash
# Sprint report with active items
azdw report generate \
  --template-id sprint-report-md \
  --connections MyOrg \
  --states Active,"In Progress",Done \
  --parameters '{"sprint_name":"Sprint 2025.1"}' \
  --output sprint-report.md

# Query all work items with confirmation prompt
azdw report generate \
  --template-id team-dashboard-html \
  --parameters '{"team_name":"All Teams"}' \
  --output all-items-dashboard.html
# (Will prompt for confirmation if no filters specified)

# Skip confirmation for automation
azdw report generate \
  --template-id work-items-export-csv \
  --yes \
  --output all-items.csv

# Release notes for closed items
azdw report generate \
  --template-id release-notes-md \
  --states Closed,Done \
  --limit 100 \
  --parameters '{"version":"2.0.0","release_date":"2025-11-15"}' \
  --output release-notes.md

# Team dashboard for all connections
azdw report generate \
  --template-id team-dashboard-html \
  --limit 200 \
  --include-pii \
  --parameters '{"team_name":"Platform Team"}' \
  --output dashboard.html

# CSV export with filtered data
azdw report generate \
  --template-id work-items-export-csv \
  --types Bug,Task \
  --states Active,New \
  --assigned-to "john@example.com,jane@example.com" \
  --output bugs-and-tasks.csv

# Cross-connection report with relationships (cross-conn is enabled by default)
azdw report generate \
  --template-id sprint-report-md \
  --connections Org1,Org2,Org3 \
  --types Epic,Feature \
  --relationships \
  --parameters '{"sprint_name":"Q4 Planning"}' \
  --output cross-org-sprint.md
```

### Advanced Filtering

Use comprehensive query options to filter report data:

```bash
# Filter by date range
azdw report generate \
  --template-id release-notes-md \
  --created-after 2025-10-01 \
  --created-before 2025-10-31 \
  --states Closed \
  --parameters '{"version":"October Release"}' \
  --output october-release.md

# Filter by area and iteration
azdw report generate \
  --template-id team-dashboard-html \
  --area "Product\\Web" \
  --iteration "Release 2\\Sprint 3" \
  --parameters '{"team_name":"Web Team"}' \
  --output web-team-dashboard.html

# Filter by tags
azdw report generate \
  --template-id sprint-report-md \
  --tags-include security,performance \
  --tags-exclude "tech-debt" \
  --limit 50 \
  --output security-perf-items.md

# Specific work items by ID
azdw report generate \
  --template-id work-items-export-csv \
  --ids 1234,5678,9012 \
  --include-pii \
  --output selected-items.csv
```

### Two-Step Workflow (Legacy)

For backward compatibility or when you need to reuse query data:

```bash
# Step 1: Query and save to JSON
azdw query \
  --connections MyOrg \
  --types Bug,Task \
  --states Active \
  --json > work-items.json

# Step 2: Generate report from JSON file
azdw report generate \
  --template-id sprint-report-md \
  --data work-items.json \
  --parameters '{"sprint_name":"Current Sprint"}' \
  --output sprint-report.md

# Reuse the same data for multiple reports
azdw report generate --template-id team-dashboard-html --data work-items.json --output dashboard.html
azdw report generate --template-id work-items-export-csv --data work-items.json --output export.csv
```

### Workflow Comparison

#### Old Workflow (Two Steps)
```bash
# Step 1: Query
azdw query --types Bug --states Active --json > bugs.json

# Step 2: Generate
azdw report generate --template-id bug-report --data bugs.json --output bug-report.md
```

#### New Workflow (One Step)
```bash
# Single command
azdw report generate --template-id bug-report --types Bug --states Active --output bug-report.md
```

**Benefits of the new workflow:**
- Fewer commands to remember
- No intermediate JSON files to manage
- Consistent query syntax across all commands
- Automatic data refresh

**When to use the old workflow:**
- Need to reuse query data for multiple reports
- Have pre-existing JSON data files
- Want to inspect/modify data before reporting

### Interactive Parameter Mode

Use interactive mode for guided parameter entry:

```bash
# Interactive parameter prompts
azdw report generate \
  --template-id sprint-report-md \
  --types Epic,Feature,UserStory \
  --states Active,Done \
  --interactive \
  --output sprint.md

# The command will prompt for:
# - sprint_name: Sprint 2025.1
# - avg_completion_days: 5.2
# - (other template-specific parameters)
```

### Template Parameters

Pass template parameters as JSON:

```bash
# Inline JSON
azdw report generate \
  --template-id release-notes-md \
  --states Closed \
  --parameters '{"version":"2.0.0","release_date":"2025-11-15","overview":"Major update"}' \
  --output release.md

# From JSON file
echo '{"sprint_name":"Sprint 10","avg_completion_days":4.5}' > params.json
azdw report generate \
  --template-id sprint-report-md \
  --types Task,Bug \
  --parameters params.json \
  --output sprint.md
```

### Output to stdout

Omit `--output` to write to stdout for piping:

```bash
# Preview in terminal
azdw report generate \
  --template-id sprint-report-md \
  --types Epic,Feature \
  --states Done \
  --parameters '{"sprint_name":"Preview"}'

# Pipe to other tools
azdw report generate \
  --template-id work-items-export-csv \
  --types Bug \
  --states Active | \
  grep "Critical"

# Save with shell redirection
azdw report generate \
  --template-id release-notes-md \
  --states Closed \
  --parameters '{"version":"1.0"}' > release-notes.md
```

### Closure-Based Reports

Generate reports from work item closure files (output from `relationship find-closure`). This is ideal for creating feature hierarchy summaries with visualization support.

```bash
# Step 1: Find the closure for a feature
azdw relationship find-closure \
  --id 1976 \
  --connection MyConnection \
  --top-type Feature \
  --include-predecessors \
  --output feature-closure.json

# Step 2: Generate a summary report from the closure
azdw report generate \
  --template-id feature-closure-summary-md \
  --from-closure feature-closure.json \
  --output feature-summary.md

# Step 3: Generate a visualization
azdw visualize graph \
  --from-closure feature-closure.json \
  --format graphviz \
  --output feature-closure.dot

# Step 4: Convert to PNG using GraphViz (requires GraphViz to be installed)
dot -Tpng feature-closure.dot -o feature-closure.png
```

The closure file provides additional context for templates:
- `nodes`: Work items with inclusion reason and depth
- `topLevelWorkItems`: Top-level items in the hierarchy
- `startWorkItemId`: The starting work item ID
- `closureStatus`: Status of the closure query
- `totalCount`: Total number of items
- `traversalStats`: Performance metrics
- `warnings`: Any warnings encountered

### Template Management

List, view, and manage report templates:

```bash
# List available templates
azdw report template list

# Filter by category
azdw report template list --category "Sprint Reports"

# View template details
azdw report template info --template-id sprint-report-md

# Export a template
azdw report template export --template-id sprint-report-md --output my-template.json

# Import custom template
azdw report template import --file my-custom-template.json

# Validate template
azdw report template validate --file my-template.json
```

## Data Visualization

Create visual representations of work item relationships using the `visualize graph` command.

### Overview

The `visualize graph` command supports two modes:
- **ID-based mode**: Visualize specific work items by ID
- **Query-based mode**: Visualize work items matching filter criteria

Output formats:
- **graphviz** (DOT format): For generating diagrams with Graphviz tools
- **graph** (JSON format): D3.js-compatible network data
- **graphml** (XML format): For yEd, Gephi, and other graph analysis tools

### ID-Based Visualization (Specific Work Items)

```bash
# Basic GraphViz visualization for specific work items
azdw visualize graph \
  --ids 123,456 \
  --connection MyCompany \
  --format graphviz \
  --output relationships.dot

# With depth limit (cross-connection is enabled by default)
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --format graphviz \
  --max-depth 3 \
  --output relationships.dot

# Using short options
azdw visualize graph \
  -w 123,456 \
  -c MyCompany \
  -f graphviz \
  -d 3 \
  -o relationships.dot

# Tree layout for hierarchical relationships
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --format graphviz \
  --layout tree \
  --direction lr \
  --output hierarchy.dot

# Network layout with cross-connection clusters (cross-conn is enabled by default)
azdw visualize graph \
  --ids 100,200 \
  --connection MyCompany \
  --format graphviz \
  --layout network \
  --max-depth 2 \
  --by-conn \
  --show-legend \
  --output network.dot

# JSON format for D3.js (cross-connection is enabled by default)
azdw visualize graph \
  --ids 100,200,300 \
  --connection MyCompany \
  --format graph \
  --output network.json

# GraphML format for yEd, Gephi, Cytoscape (cross-connection is enabled by default)
azdw visualize graph \
  --ids 100,200,300 \
  --connection MyCompany \
  --format graphml \
  --output relationships.graphml

# yEd-optimized GraphML with colored shapes and groups
azdw visualize graph \
  --ids 100,200,300 \
  --connection MyCompany \
  --format graphml \
  --optimize-for-yed \
  --by-conn \
  --output yed-diagram.graphml
```

### Query-Based Visualization (Filter by Criteria)

```bash
# Visualize all active epics across all organizations (cross-conn is enabled by default)
azdw visualize graph \
  --types Epic \
  --states Active \
  --format graphviz \
  --by-conn \
  --output epics.dot

# Visualize ALL work items (with confirmation prompt in interactive mode)
azdw visualize graph \
  --format graphviz \
  --output all-items.dot
# (Will prompt for confirmation if no filters or work items specified)

# Skip confirmation for automation/scripting
azdw visualize graph \
  --yes \
  --format graphviz \
  --max-depth 2 \
  --output all-items.dot

# Visualize bugs assigned to specific users
azdw visualize graph \
  --types Bug \
  --assigned-to "John Doe,Jane Smith" \
  --states Active,New \
  --format graphviz \
  --output team-bugs.dot

# Sprint planning visualization with depth control
azdw visualize graph \
  --iteration "Sprint 42" \
  --types "Feature,User Story,Task" \
  --format graphviz \
  --layout tree \
  --max-depth 2 \
  --title "Sprint 42 Roadmap" \
  --show-legend \
  --output sprint-42.dot

# Filter by tags and custom fields
azdw visualize graph \
  --tags urgent,customer-facing \
  --field "Priority:equals:1" \
  --format graphviz \
  --by-project \
  --output high-priority.dot
```

### Relationship Filtering

```bash
# Show only hierarchical parent-child relationships
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --hierarchy-only \
  --format graphviz \
  --layout tree \
  --output hierarchy.dot

# Show only dependency relationships
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --dependencies-only \
  --format graphviz \
  --output dependencies.dot

# Show only Related links
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --related-only \
  --format graphviz \
  --output related.dot

# Show only cross-connection relationships
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --cross-conn-only \
  --format graphviz \
  --layout network \
  --output cross-connections.dot

# Filter by specific relationship types
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --relationship-types "Successor,Related" \
  --max-depth 3 \
  --format graphviz \
  --output custom-relationships.dot
```

### Grouping and Styling

```bash
# Group by connection/organization
azdw visualize graph \
  --types Epic,Feature \
  --format graphviz \
  --by-conn \
  --show-legend \
  --output grouped-by-org.dot

# Group by project
azdw visualize graph \
  --types Epic,Feature \
  --format graphviz \
  --by-project \
  --show-legend \
  --output grouped-by-project.dot

# Custom title and legend
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --format graphviz \
  --title "Product Roadmap Q4 2024" \
  --show-legend \
  --output roadmap.dot

# Layout direction options
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --format graphviz \
  --direction lr \
  --output left-right.dot

# Different directions: tb (top-bottom), lr (left-right), bt (bottom-top), rl (right-left)
```

### Custom Node Fields and PII Handling

```bash
# Display additional work item fields in nodes
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --format graphviz \
  --node-fields "System.State,System.Priority" \
  --output with-fields.dot

# Include personal information (AssignedTo, CreatedBy, etc.)
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --format graphviz \
  --node-fields "System.State,System.AssignedTo" \
  --include-pii \
  --output with-pii.dot

# Multiple custom fields
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --format graphviz \
  --node-fields "System.State,System.AssignedTo,System.AreaPath,System.Priority" \
  --include-pii \
  --output detailed-nodes.dot
```

### Color Customization

```bash
# Use custom color map for work item types and organizations
azdw visualize graph \
  --ids 123 \
  --connection MyCompany \
  --format graphviz \
  --color-map config/my-colors.json \
  --by-conn \
  --output custom-colors.dot
```

### Advanced Options

```bash
# Exclude disabled work item types from query-based visualizations
azdw visualize graph \
  --types Epic,Feature \
  --exclude-disabled-types \
  --format graphviz \
  --output active-types-only.dot

# Full-featured visualization combining multiple options (cross-conn is enabled by default)
azdw visualize graph \
  --types "Epic,Feature,User Story" \
  --states Active \
  --format graphviz \
  --layout network \
  --by-conn \
  --max-depth 3 \
  --title "Cross-Organization Feature Map" \
  --show-legend \
  --node-fields "System.State,System.AssignedTo" \
  --include-pii \
  --color-map config/colors.json \
  --output full-featured.dot

# JSON format with grouping for D3.js visualization (cross-conn is enabled by default)
azdw visualize graph \
  --types Epic,Feature \
  --format graph \
  --by-conn \
  --output network-grouped.json
```

### Rendering GraphViz Output

After generating DOT files, render them with Graphviz tools:

```bash
# Render to PNG
dot -Tpng relationships.dot -o relationships.png

# Render to SVG (scalable)
dot -Tsvg relationships.dot -o relationships.svg

# Render to PDF
dot -Tpdf relationships.dot -o relationships.pdf

# Use different layout engines
neato -Tpng network.dot -o network.png     # Spring model layout
fdp -Tpng network.dot -o network.png       # Force-directed placement
circo -Tpng network.dot -o network.png     # Circular layout
```

## Relationship Management

Manage and analyze work item relationships across connections.

### Resolve Relationships

Resolve work item relationships with cross-connection support:
```bash
# Resolve relationships for specific work items
azdw relationship resolve \
  --ids 123,456,789 \
  --connection MyOrg

# Resolve with depth limit
azdw relationship resolve \
  --ids 123 \
  --connection MyOrg \
  --max-depth 3

# Resolve specific relationship types
azdw relationship resolve \
  --ids 123 \
  --connection MyOrg \
  --relationship-types "Child,Predecessor,Successor"

# Include cross-connection relationships (enabled by default)
# Use --no-cross-conn to disable if needed
azdw relationship resolve \
  --ids 123 \
  --connection MyOrg

# Resolve hyperlinks to work items (enabled by default)
# Use --no-resolve-hyperlinks to disable if needed
azdw relationship resolve \
  --ids 123 \
  --connection MyOrg

# Limit resolution to specific connections
azdw relationship resolve \
  --ids 123 \
  --connection MyOrg \
  --limit-conns Org1,Org2

# Save results to file
azdw relationship resolve \
  --ids 123 \
  --connection MyOrg \
  --output relationships.json
```

### Validate Relationships

Validate work item relationships against policies:
```bash
# Validate relationships for specific work items
azdw relationship validate \
  --ids 123,456 \
  --connection MyOrg

# Validate with custom policy file
azdw relationship validate \
  --ids 123 \
  --connection MyOrg \
  --policy-file config/relationship-policy.jsonc

# Strict policy enforcement
azdw relationship validate \
  --ids 123 \
  --connection MyOrg \
  --strict

# Validate with depth limit
azdw relationship validate \
  --ids 123 \
  --connection MyOrg \
  --max-depth 2

# Save validation results
azdw relationship validate \
  --ids 123,456 \
  --connection MyOrg \
  --output validation-results.json
```

### Analyze Relationships  

Analyze work item relationship patterns and metrics:
```bash
# Analyze relationships for specific work items
azdw relationship analyze \
  --ids 123,456 \
  --connection MyOrg

# Include detailed metrics
azdw relationship analyze \
  --ids 123 \
  --connection MyOrg \
  --include-metrics

# Analyze with depth limit
azdw relationship analyze \
  --ids 123 \
  --connection MyOrg \
  --max-depth 3

# Save analysis results
azdw relationship analyze \
  --ids 100,200,300 \
  --connection MyOrg \
  --output analysis-results.json
```

### Find Orphaned Work Items

Find work items with no relationships. A work item is considered "orphaned" when it has **no relationships of any kind** - neither incoming nor outgoing links to other work items. This includes:
- No parent-child relationships (hierarchy)
- No dependency relationships
- No related links
- No cross-connection links
- Not being referenced by any other work item

Orphaned work items may indicate isolated work that should be integrated into the broader project structure or cleaned up.

```bash
# Find orphans across all connections
azdw relationship find-orphans \
  --connections MyOrg,OtherOrg

# Find orphans of specific types
azdw relationship find-orphans \
  --connections MyOrg \
  --types Bug,Task

# Find orphans in specific states
azdw relationship find-orphans \
  --connections MyOrg \
  --types "User Story" \
  --states Active,New

# Limit number of results
azdw relationship find-orphans \
  --connections MyOrg \
  --limit 500

# Save results to file
azdw relationship find-orphans \
  --connections MyOrg,OtherOrg \
  --output orphans.json
```

**Common use cases for finding orphaned work items:**
- **Data cleanup**: Identify work items that can be archived or deleted
- **Process compliance**: Ensure all work items are properly linked to parent features/epics
- **Sprint planning**: Find tasks that aren't associated with any user story
- **Quality assurance**: Verify all bugs are linked to the features they affect
- **Documentation**: Identify isolated documentation items that should be connected to work

### Find Circular Dependencies

Find circular dependency chains in work item relationships. A **circular dependency** (also called a dependency cycle) occurs when work items form a closed loop through their relationships, where following the chain of dependencies eventually leads back to the starting item.

**What constitutes a circular dependency:**
- **Direct cycle**: Work Item A depends on B, B depends on A (A → B → A)
- **Indirect cycle**: Work Item A depends on B, B depends on C, C depends on A (A → B → C → A)
- **Complex chains**: Longer cycles involving multiple work items (A → B → C → D → B)

**Why circular dependencies are problematic:**
- **Logical impossibility**: If A must be completed before B, and B before A, neither can start
- **Project deadlocks**: Teams cannot make progress as they wait on each other
- **Planning issues**: Sprint planning and dependency tracking become unreliable
- **Process violations**: Violates directed acyclic graph (DAG) principles of proper dependency management
- **Risk indicator**: Often indicates poorly defined work breakdown or unclear requirements

The command uses **depth-first search (DFS)** to traverse the relationship graph and detect cycles by tracking the recursion stack.

```bash
# Find circular dependencies across connections
azdw relationship find-circular \
  --connections MyOrg,OtherOrg

# Find circular dependencies for specific types
azdw relationship find-circular \
  --connections MyOrg \
  --types Epic,Feature

# Find circular dependencies in specific states
azdw relationship find-circular \
  --connections MyOrg \
  --types Feature \
  --states Active

# Limit number of work items to analyze
azdw relationship find-circular \
  --connections MyOrg \
  --limit 500

# Save results to file
azdw relationship find-circular \
  --connections MyOrg,OtherOrg \
  --output circular-deps.json
```

**Common use cases for finding circular dependencies:**
- **Project health checks**: Verify dependency structure before sprint planning
- **Release planning**: Ensure clear execution order for features and epics
- **Risk assessment**: Identify blocked work items that may delay releases
- **Process improvement**: Find and fix incorrect dependency definitions
- **Team coordination**: Resolve conflicts between teams working on interdependent items
- **Technical debt**: Identify areas where work breakdown needs improvement

**How to resolve circular dependencies:**
1. **Break the cycle**: Remove or reorder one or more relationships in the chain
2. **Split work items**: Divide items to remove the circular dependency
3. **Redefine dependencies**: Clarify what truly depends on what
4. **Add intermediate items**: Insert new work items to break the cycle
5. **Change work order**: Adjust the sequence of implementation

## Metadata

Display work item metadata for connections.

### List Work Item Types

List all work item types for a connection:
```bash
# List all work item types
azdw metadata types --connection MyOrg

# JSON output
azdw metadata types --connection MyOrg --format json

# Pretty-printed JSON
azdw metadata types --connection MyOrg --format json --pretty
```

### List Fields

List fields for a work item type:
```bash
# List fields for a specific work item type
azdw metadata fields --connection MyOrg --type Bug

# List all fields (no type filter)
azdw metadata fields --connection MyOrg

# JSON output
azdw metadata fields --connection MyOrg --type Task --format json
```

### List States

List valid states for a work item type:
```bash
# List states for a specific work item type
azdw metadata states --connection MyOrg --type Bug

# JSON output
azdw metadata states --connection MyOrg --type Task --format json
```

### List Area Paths

List area paths for a connection:
```bash
# List all area paths
azdw metadata areas --connection MyOrg

# Limit depth
azdw metadata areas --connection MyOrg --depth 2

# JSON output
azdw metadata areas --connection MyOrg --format json
```

### List Iteration Paths

List iteration paths for a connection:
```bash
# List all iteration paths
azdw metadata iterations --connection MyOrg

# Limit depth
azdw metadata iterations --connection MyOrg --depth 2

# JSON output
azdw metadata iterations --connection MyOrg --format json
```

## Cache Management

Manage cache operations for improved performance.

### Check Cache Status

Get current cache status:
```bash
# Get cache status
azdw cache status

# Verbose output
azdw cache status --verbose
```

### Get Cache Statistics

View detailed cache statistics:
```bash
# Get detailed cache statistics
azdw cache stats

# Verbose output with more details
azdw cache stats --verbose
```

### Clear Cache

Clear cache entries:
```bash
# Clear all cache entries
azdw cache clear

# Clear cache for specific connection
azdw cache clear --connection MyOrg

# Clear specific cache category
azdw cache clear --category metadata

# Skip confirmation prompt
azdw cache clear --yes
```

### Refresh Cache

Refresh cache entries approaching expiration:
```bash
# Refresh cache entries
azdw cache refresh

# Verbose output
azdw cache refresh --verbose
```

## Field Mappings

Manage field mapping configurations for connections.

### List Field Mappings

List available field mappings:
```bash
# List all field mappings
azdw config fieldmap list

# List mappings for specific connection
azdw config fieldmap list --connection MyOrg

# Using alias
azdw config fieldmap ls

# JSON output
azdw config fieldmap list --format json
```

### Show Mapping Details

Show detailed information about a field mapping:
```bash
# Show mapping details for connection
azdw config fieldmap show --connection MyOrg

# JSON output
azdw config fieldmap show --connection MyOrg --format json
```

### Detect Process Template

Detect the process template for a connection:
```bash
# Detect process template
azdw config fieldmap detect --connection MyOrg

# Verbose output
azdw config fieldmap detect --connection MyOrg --verbose
```

### Generate Field Mappings

Generate automatic field mappings:
```bash
# Generate field mappings for connection
azdw config fieldmap generate --connection MyOrg

# Force overwrite existing mappings
azdw config fieldmap generate --connection MyOrg --force
```

### Validate Field Mappings

Validate field mappings for a connection:
```bash
# Validate field mappings for all types
azdw config fieldmap validate --connection MyOrg

# Validate specific work item type
azdw config fieldmap validate --connection MyOrg --type UserStory
```

### Shell Integration

Install shell integration (tab-completions, PATH, PowerShell module auto-import) for the CLI:
```bash
# Install for current shell
azdw config shell-integration

# Install for all detected shells
azdw config shell-integration --all

# List detected shells and status
azdw config shell-integration --list

# Uninstall shell integration
azdw config shell-integration --uninstall
```

## MCP Server

Start the Model Context Protocol (MCP) server for AI assistant integration.

### Start MCP Server

```bash
# Start MCP server with default settings
azdw mcp

# Display version information
azdw mcp --info
```

The MCP server enables AI assistants and other tools to interact with your Azure DevOps work items through the standardized Model Context Protocol, providing programmatic access to work item data and operations.

## AI Chat

The `ai-chat` command provides an interactive AI-powered chat interface for Azure DevOps work item management. Use natural language to query, create, update, and analyze work items.

### Prerequisites

1. **Configure AI provider**: Run `azdw config ai set` to configure your LLM provider (OpenAI, Azure OpenAI, or Ollama). For local hosting, we recommend Ollama with `gemma4:12b` (requires >= 16K context window). If you use `./scripts/install-ollama.ps1`, it automatically selects a larger Gemma 4 variant such as `gemma4:26b` only when enough inference memory is available with headroom for normal workstation use.
2. **Set up connections**: Ensure at least one Azure DevOps connection is configured

### Start AI Chat Session

```bash
# Start interactive AI chat
azdw ai-chat

# Using the short alias
azdw chat

# Start with verbose logging
azdw ai-chat --verbose

# Record transcript to ~/.azdw/chats/ directory
azdw ai-chat --record

# Combine options
azdw ai-chat --verbose --record
```

### Example Chat Interactions

Once in the chat session, you can interact naturally:

```
> List 10 active bugs assigned to me
> Show all user stories in the current sprint
> What's the status of work item #12345?
> Create a new task: "Update API documentation" in area path Product/Backend
> Find all orphaned work items without a parent
> Show circular dependencies in the Feature backlog
> Generate a D3.js visualization of work items in Release 1
```

### Session Commands

Within the chat:
- Type `exit` or `quit` to end the session
- Press `Ctrl+D` to exit
- Press `Ctrl+C` to cancel the current operation and return to the prompt
- Press `Tab` (on an empty/plain input line) or type `/session` to open the session picker and switch to a different session
- Type `/newsession` to start a brand new session (not persisted until its first message)
- Type `/compact` to compact the conversation context window on demand

### Managing Multiple Sessions

Every non-ephemeral session is saved under `~/.azdw/sessions/`. After the first
exchange, the configured model generates a short topic description; the session
name remains the identifier used by the management commands. Sessions are
independent: each one keeps its own conversation history and last-used model,
and only one azdw process can open a session at a time.

Use the session catalog to choose, resume, and clean up conversations:

```bash
# List all sessions
azdw ai-chat session list

# Resume a specific session by name
azdw ai-chat --continue-session 20260805-143000-Deployment-issue

# Select a session for --continue-last-session, then resume it
azdw ai-chat session activate -n 20260805-143000-Deployment-issue
azdw ai-chat --continue-last-session

# Or choose the session interactively
azdw ai-chat session activate
azdw ai-chat --continue-last-session

# Delete a specific session without a confirmation prompt
azdw ai-chat session delete -n 20260701-091500-Old-topic --yes

# Delete every session (asks for confirmation once)
azdw ai-chat session delete --all

# Generate an AI description for a session that still shows the generic "Session" name
# (e.g. because it pre-dates auto-titling, or was migrated but never resumed since)
azdw ai-chat session refresh -n 20260701-091500-Session

# Do the same for every session still on the default name
azdw ai-chat session refresh --all
```

`--continue-session <NAME>` and `--continue-last-session` cannot be combined.
Use `--temporary-chat` for a one-off run that must not persist session state;
transcript recording with `--record` remains independent and writes to
`~/.azdw/chats/`.

### Transcript Recording

When using `--record`, transcripts are saved to:
- **Location**: `~/.azdw/chats/`
- **Filename**: `YYYY-MM-DD_HH-mm_azdw-chat.txt`

Useful for:
- Documenting decisions made during chat sessions
- Creating audit trails
- Training and reference

### Exit Codes

| Code | Description |
| ----- | ---------- |
| 0 | Success - session ended normally |
| 20 | AI configuration missing - run `azdw config ai set` |
| 21 | Failed to connect to LLM |
| 22 | MCP configuration error |
| 23 | Session already open in another process (`--continue-session`/`--continue-last-session`) |

## Common Workflow Patterns

### Automated Connection Setup (Fastest Way - MSAL + PAT API)

For rapid onboarding with multiple connections, use the fully automated MSAL-based setup:

```bash
# 1. Create connection configuration file
cp config/connection-setup-example.jsonc config/connection-setup.jsonc

# 2. Edit with your organizations and tenant IDs
# {
#   "connections": [
#     {
#       "name": "MyOrg",
#       "url": "https://dev.azure.com/myorganization",
#       "tenantId": "your-tenant-id.onmicrosoft.com",
#       "validityDays": 365
#     }
#   ]
# }

# 3. Run initialization with automated setup
./init.ps1 -SetupConnections

# This will automatically:
# ✅ Authenticate via MSAL (interactive browser)
# ✅ Create PAT tokens programmatically via Azure DevOps API
# ✅ Configure all connections with the generated PATs
# ✅ Verify connections
# ✅ Test queries
```

**How it works:**
1. **MSAL Authentication**: Opens browser for Microsoft/Entra ID sign-in
2. **PAT Token Creation**: Uses Azure DevOps REST API to create tokens programmatically
3. **Connection Setup**: Configures azdw with the generated PATs
4. **Verification**: Tests all connections automatically

**Benefits:**
- Fully automated - no manual token creation needed
- Set up multiple connections in minutes
- Uses Azure DevOps PAT Creation API (`POST https://vssps.dev.azure.com/{org}/_apis/tokens/pats`)
- Secure - tokens encrypted locally
- Perfect for team onboarding

See [Authentication Types - Automated Connection Setup](Authentication-Types.md#automated-connection-setup) for more details.

### Complete Connection Setup

```bash
# PAT Authentication Setup
# 1. Add connection with PAT auth type
azdw connection add --name "MyCompany" --url "https://dev.azure.com/mycompany" --auth-type pat

# 2. Configure PAT credentials  
azdw credential add-pat --connection "MyCompany" --token "your-pat-token-here" --validate

# 3. Test the connection
azdw connection test --name "MyCompany"

# 4. List to verify setup
azdw connection list
```

```bash
# Device Code Flow Setup
# 1. Add connection with device code flow
azdw connection add --name "MyCompany" --url "https://dev.azure.com/mycompany" --auth-type code --tenant "mycompany.onmicrosoft.com"

# 2. Configure OAuth credentials using device code flow
azdw credential add --connection "MyCompany" --auth-type code --tenant "mycompany.onmicrosoft.com"

# 3. Test the connection
azdw connection test --name "MyCompany"
```

```bash
# Interactive Browser Authentication Setup
# 1. Add connection with interactive browser authentication
azdw connection add --name "MyCompany" --url "https://dev.azure.com/mycompany" --auth-type interactive --tenant "mycompany.onmicrosoft.com"

# 2. Configure OAuth credentials using interactive browser flow
azdw credential add --connection "MyCompany" --auth-type interactive --tenant "mycompany.onmicrosoft.com"

# 3. Test the connection
azdw connection test --name "MyCompany"
```

### Multi-Connection Queries

```bash
# Check status of all connections
azdw connection list

# Query specific connections for bugs (comma-separated)
azdw query --connections Org1,Org2 --types "Bug" --states "Active" --json --pretty

# Generate cross-connection report
azdw report generate --connection "Org1" --output-format json

# Execute WIQL across multiple connections (comma-separated)
azdw wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.WorkItemType] = 'Task'" --connections Org1,Org2
```

### Data Export Workflows

```bash
# Export all active bugs to CSV
azdw query --types "Bug" --states "Active" --output csv > active-bugs.csv

# Export specific work item fields to JSON
azdw query --fields "System.Id,System.Title,System.State,System.AssignedTo" --json --pretty > work-items.json

# Export WIQL query results
azdw wiql "SELECT [System.Id], [System.Title], [System.CreatedDate] FROM WorkItems WHERE [System.CreatedDate] >= @Today - 7" --output csv > recent-items.csv

# Export from specific connections using short alias (comma-separated)
azdw query -c Org1,Org2 --types "Bug" --states "Active" --output csv > specific-bugs.csv

# Generate comprehensive report
azdw report generate --template-id my-template --connection "MyCompany" --format json --output "comprehensive-report.json"
```

### Authentication Management

```bash
# List all configured credentials
azdw credential list

# Test all connections
for conn in $(azdw connection list --json | jq -r '.[].name'); do
  echo "Testing $conn..."
  azdw connection test --name "$conn"
done

# Re-authenticate connection with device code flow
azdw credential remove --connection "MyCompany"
azdw credential add --connection "MyCompany" --auth-type code --tenant "mycompany.onmicrosoft.com"

# Re-authenticate connection with interactive browser flow
azdw credential remove --connection "MyCompany"
azdw credential add --connection "MyCompany" --auth-type interactive --tenant "mycompany.onmicrosoft.com"
```