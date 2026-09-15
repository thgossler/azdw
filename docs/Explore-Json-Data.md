# Exploring and Analyzing JSON Data from azdw CLI

This comprehensive guide demonstrates how to explore, filter, and analyze JSON output from the `azdw` CLI tool using powerful command-line tools: `jq`, `json-tui`, `jiq`, `jqp`, and `VisiData`. Whether you're querying work items, analyzing relationships, or exploring metadata, this guide provides practical examples and patterns for common scenarios.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Understanding azdw JSON Output](#understanding-azdw-json-output)
3. [Getting Started with jq](#getting-started-with-jq)
4. [Interactive Exploration with json-tui](#interactive-exploration-with-json-tui)
5. [Interactive Query Building with jiq and jqp](#interactive-query-building-with-jiq-and-jqp)
6. [Common Query Patterns](#common-query-patterns)
7. [Work Item Analysis Scenarios](#work-item-analysis-scenarios)
8. [Relationship Analysis](#relationship-analysis)
9. [Cross-Organization Queries](#cross-organization-queries)
10. [Advanced jq Techniques](#advanced-jq-techniques)
11. [Performance Tips](#performance-tips)
12. [Real-World Examples](#real-world-examples)
13. [Quick Reference](#quick-reference)


## Prerequisites

### Install Required Tools

The easiest way to install all JSON exploration tools is to use the provided installation script:

**All Platforms (Windows, macOS, Linux):**
```bash
# From the repository root - interactive mode (prompts for each tool)
./scripts/install-json-tools.ps1

# Or install all tools without prompting
./scripts/install-json-tools.ps1 -NonInteractive
```

This script will install:
- **jq** - Command-line JSON processor (via package manager: Chocolatey/Homebrew/apt/yum/dnf)
- **json-tui** - Interactive terminal UI for browsing JSON data
- **jiq** - Interactive jq filter playground with live preview
- **jqp** - TUI jq playground with filter history and examples
- **VisiData** - Spreadsheet-like TUI for tabular data exploration

All tools are installed to `~/.local/bin` (or via system package managers) and your PATH is configured automatically.

#### Manual Installation

If you prefer to install the tools manually:

**jq:**
- **macOS:** `brew install jq`
- **Linux (Ubuntu/Debian):** `sudo apt-get install jq`
- **Windows:** `winget install jqlang.jq` or `choco install jq` or download from [jqlang.org](https://jqlang.org/download/)

**json-tui:**
- Download pre-built binaries from [GitHub releases](https://github.com/ArthurSonzogni/json-tui/releases)
- Or install via Rust: `cargo install json-tui`

**jiq:**
- Download pre-built binaries from [GitHub releases](https://github.com/fiatjaf/jiq/releases)
- Or install via Go: `brew install go && go install github.com/fiatjaf/jiq/cmd/jiq@latest`

**jqp:**
- Download pre-built binaries from [GitHub releases](https://github.com/noahgorstein/jqp/releases)
- Or install via Homebrew: `brew install noahgorstein/tap/jqp`
- Or install via Go: `go install github.com/noahgorstein/jqp@latest`

**VisiData:**
- **macOS:** `brew install visidata` or `pip3 install visidata`
- **Linux (Debian/Ubuntu):** `sudo apt-get install visidata` or `pip3 install --user visidata`
- **Linux (Fedora):** `sudo dnf install visidata`
- **Linux (Arch):** `sudo pacman -S visidata`
- **Windows:** `pip install visidata` (requires Python)
- **All platforms:** `pip3 install visidata`

### Verify Installations

```bash
# Check jq
jq --version
# Expected: jq-1.7 or later

# Check json-tui
json-tui --version

# Check jiq
jiq --version

# Check jqp
jqp --version

# Check VisiData
vd --version

# Build and check azdw (if working from source)
dotnet build azdw.sln
./publish/azdw --version
```


## Understanding azdw JSON Output

### Basic JSON Structure

The `azdw` CLI outputs JSON in different formats depending on the command. Here's the general structure:

#### Query Results

```bash
# Query for any one work item
./publish/azdw query --limit 1 --json

# Query for one specific work item ID including "Assigned To" user information
./publish/azdw query --ids 1234 -connection MyConn1 --include-pii --json
```

**Output Structure:**
```json
{
  "$id": "1",
  "workItems": {
    "$id": "2",
    "$values": [
      {
        "$id": "3",
        "id": 183,
        "logicalType": "Opportunity",
        "title": "Example Opportunity Title",
        "state": "Open",
        "assignedTo": { "displayName": "John Doe", "uniqueName": "john@example.com" },
        "organization": {
          "name": "MyOrg",
          "baseUrl": "https://dev.azure.com/myorg"
        },
        "tags": ["tag1", "tag2"],
        "relationships": []
      }
    ]
  },
  "totalCount": 1,
  "successfulOrganizations": [],
  "failedOrganizations": []
}
```

**Key Fields:**
- **workItems["$values"][]**: Array of work item objects
- **totalCount**: Total number of work items returned
- **successfulOrganizations**: List of successfully queried organizations
- **failedOrganizations**: List of organizations that failed to respond


## Getting Started with jq

### The Identity Filter - Your First jq Query

The simplest jq filter is `.` (dot), which outputs the input unchanged but pretty-printed:

```bash
# Pretty-print JSON output from azdw
./publish/azdw query --limit 5 --json | jq '.'
```

### Accessing Object Properties

Extract specific fields using dot notation:

```bash
# Get total count
./publish/azdw query --limit 10 --json | jq '.totalCount'
# Output: 10

# Get all work items
./publish/azdw query --limit 5 --json | jq '.workItems["$values"]'

# Get first work item
./publish/azdw query --limit 5 --json | jq '.workItems["$values"][0]'

# Get first work item's title
./publish/azdw query --limit 5 --json | jq '.workItems["$values"][0].title'
# Output: "Example Work Item Title"
```

### Array Operations

```bash
# Get all work item IDs
./publish/azdw query --limit 10 --json | jq '.workItems["$values"][].id'

# Get IDs as an array
./publish/azdw query --limit 10 --json | jq '[.workItems["$values"][].id]'

# Get array length
./publish/azdw query --limit 100 --json | jq '.workItems["$values"] | length'
```

### Working with Strings

```bash
# Extract titles as raw strings (no quotes)
./publish/azdw query --limit 5 --json | jq -r '.workItems["$values"][].title'

# Convert ID to string
./publish/azdw query --limit 1 --json | jq '.workItems["$values"][0].id | tostring'
```


## Interactive Exploration with json-tui

json-tui provides an interactive interface for exploring JSON data. It's perfect for:
- Quickly understanding data structure
- Navigating nested objects
- Testing jq filters interactively

### Basic Usage

```bash
# Explore query results interactively
./publish/azdw query --limit 50 --json | json-tui

# Save to file first for better performance with large datasets
./publish/azdw query --limit 500 --json > results.json
json-tui results.json
```

### Navigation in json-tui

Key bindings (use `json-tui --keybinding` to see full list):

- **Arrow Keys** or **h/j/k/l**: Navigate through the JSON tree
- **Enter** or **Mouse Click**: Expand/collapse objects and arrays
- **+/-**: Deep expand/collapse all children
- **gg/G**: Jump to top/bottom
- **Page Up/Down**: Navigate to first/last element
- **q** or **Escape**: Quit

> **Note**: json-tui is a **viewer only** and does not have built-in jq filtering. For interactive jq query building, use `jiq` or `jqp` instead (see next section).


## Interactive Query Building with jiq and jqp

While `jq` is powerful for scripting and automation, `jiq` and `jqp` provide interactive environments for building and testing jq queries with instant visual feedback. Both tools are excellent for learning jq syntax and experimenting with filters before using them in scripts.

### jiq - Interactive jq Filter Playground

`jiq` provides a simple, fast interface where you type jq filters and see results update in real-time.

**Basic Usage:**

```bash
# Pipe azdw output directly to jiq
./publish/azdw query --limit 50 --json | jiq

# Or use a saved file
./publish/azdw query --limit 200 --json > results.json
jiq < results.json
```

**How jiq Works:**

1. Launch jiq with JSON input
2. Type your jq filter in the query area at the top
3. Results update instantly as you type
4. Press `Ctrl+C` or `q` to quit and see the last query

**Example Session:**

```bash
./publish/azdw query --types Bug --json | jiq

# Try these filters interactively:
# .workItems["$values"]
# .workItems["$values"][]
# .workItems["$values"][] | select(.state == "Active")
# .workItems["$values"][] | select(.state == "Active") | {id, title, state}
# [.workItems["$values"][] | select(.assignedTo != null) | .assignedTo.displayName] | unique
```

**When to Use jiq:**

- ✅ Quick experimentation with jq filters
- ✅ Learning jq syntax with immediate feedback
- ✅ Testing filter expressions before using in scripts
- ✅ Rapid iteration on complex queries

### jqp - TUI jq Playground

`jqp` is a full-featured terminal UI playground with additional features like filter history, examples, and better error messages.

**Basic Usage:**

```bash
# Open jqp with azdw output
./publish/azdw query --limit 100 --json | jqp

# Or use a saved file
./publish/azdw query --json > results.json
jqp results.json
```

**Key Features:**

- **Filter History**: Navigate through previous queries with ↑/↓
- **Examples Library**: Built-in jq filter examples
- **Syntax Highlighting**: Color-coded output
- **Error Messages**: Clear error reporting with suggestions
- **Multiple Panes**: Input, output, and filter view

**Navigation:**

- `Tab`: Switch between panes
- `↑/↓`: Navigate history or results
- `Ctrl+C` or `Ctrl+D`: Quit
- `Ctrl+S`: Save current filter
- `/`: Search in output

**Example Workflow:**

```bash
# 1. Generate data
./publish/azdw query --limit 200 --json > bugs.json

# 2. Open in jqp
jqp bugs.json

# 3. Try filters interactively:
#    Start simple: .totalCount
#    Drill down: .workItems["$values"][0]
#    Filter: .workItems["$values"][] | select(.state == "Active")
#    Transform: [.workItems["$values"][] | {id, title, owner: .assignedTo.displayName}]
#    Group: [.workItems["$values"][] | .state] | group_by(.) | map({state: .[0], count: length})

# 4. Copy working filter to use in scripts
```

**When to Use jqp:**

- ✅ Building complex queries with multiple iterations
- ✅ Learning from built-in examples
- ✅ Need filter history for repeated queries
- ✅ Want better error messages and suggestions
- ✅ Exploring unfamiliar JSON structures

### VisiData - Spreadsheet-like Data Explorer

`VisiData` is a powerful terminal-based spreadsheet tool for exploring and analyzing tabular data, including JSON. It combines the familiarity of spreadsheets with the power of command-line tools.

**Basic Usage:**

```bash
# Open JSON file in VisiData
vd data.json

# Pipe azdw output to VisiData
./publish/azdw query --limit 100 --json > results.json
vd results.json

# Open directly (VisiData handles JSON parsing)
./publish/azdw query --limit 200 --json | vd -f json
```

**Key Features:**

- **Spreadsheet View**: Browse JSON as tables with columns and rows
- **Sorting & Filtering**: Sort by any column, filter rows interactively
- **Aggregations**: Group by columns, calculate sums, averages, counts
- **Graphing**: Create histograms, scatterplots, and frequency charts
- **Multiple Sheets**: Navigate between nested JSON structures as separate sheets
- **SQL Queries**: Execute SQL queries on your data
- **Data Export**: Save filtered/transformed data to CSV, JSON, etc.

**Navigation:**

- `↑/↓` or `j/k`: Navigate rows
- `←/→` or `h/l`: Navigate columns
- `Enter`: Dive into nested structures (opens new sheet)
- `q`: Quit current sheet
- `Shift+F`: Add frequency table for column
- `Shift+I`: Plot histogram
- `|` or `\`: Filter by column value
- `[` or `]`: Sort by column

**Example Workflow with azdw:**

```bash
# 1. Query and save data
./publish/azdw query --state Active --limit 500 --json > active-items.json

# 2. Open in VisiData
vd active-items.json

# 3. Navigate to workItems.$values sheet (press Enter on the row)
#    VisiData automatically expands nested JSON

# 4. Interactive analysis:
#    - Press 'Shift+F' on 'state' column → frequency distribution
#    - Press '|' on 'assignedTo' column → filter by assignee
#    - Press '[' on 'createdDate' → sort by date
#    - Press 'Shift+I' on numeric column → histogram

# 5. Export results: Ctrl+S → choose format (CSV, JSON, etc., see https://www.visidata.org/docs/formats/)
```

**When to Use VisiData:**

- ✅ Analyzing tabular aspects of JSON data (arrays of objects)
- ✅ Need spreadsheet-like sorting, filtering, and grouping
- ✅ Want to create quick visualizations (histograms, charts)
- ✅ Performing statistical analysis on data
- ✅ Exploring large datasets (millions of rows)
- ✅ Need to pivot or aggregate data interactively

**VisiData Quick Tips:**

```bash
# Open and immediately navigate to nested data
vd results.json
# Press 'Enter' on workItems row
# Press 'Enter' on $values row
# Now you see the work items as a table

# Filter active bugs assigned to you
vd results.json
# Navigate to work items table
# Press '|' on 'state' column, type: Active
# Press '|' on 'logicalType', type: Bug
# Press '|' on 'assignedTo.displayName', type: Your Name

# Create frequency chart of work item types
vd results.json
# Navigate to work items
# Move to 'logicalType' column
# Press 'Shift+F' → frequency table
# Press 'Shift+I' → histogram
```

### Comparison: All Tools

| Feature            | jq                  | jiq                | jqp                    | json-tui                | VisiData                    |
|--------------------|---------------------|--------------------|------------------------|-------------------------|-----------------------------|
| **Use Case**       | Scripts, automation | Quick experiments  | Complex query building | Structure browsing      | Tabular data analysis       |
| **Interface**      | Command-line        | Simple interactive | Full TUI               | Tree navigation         | Spreadsheet TUI             |
| **Live Preview**   | No                  | Yes                | Yes                    | No                      | Yes (interactive)           |
| **jq Filtering**   | Yes                 | Yes                | Yes                    | No                      | No (own filtering)          |
| **Filter History** | Shell history       | No                 | Yes                    | No                      | Yes (command log)           |
| **Examples**       | No                  | No                 | Yes                    | No                      | Yes (built-in help)         |
| **Sorting**        | Manual              | No                 | No                     | No                      | Yes (multi-column)          |
| **Graphing**       | No                  | No                 | No                     | No                      | Yes (histograms, scatter)   |
| **Best For**       | Production use      | Quick testing      | Learning jq            | Understanding structure | Data analysis & exploration |
| **Output**         | stdout              | Visual             | Visual + copyable      | Visual navigation       | Visual + export             |

### Recommended Workflow

For most azdw JSON exploration tasks, use this workflow:

1. **Start with json-tui** to understand the data structure
   ```bash
   ./publish/azdw query --limit 50 --json | json-tui
   ```

2. **Use VisiData** for tabular analysis and filtering
   ```bash
   ./publish/azdw query --limit 500 --json > results.json
   vd results.json  # Navigate to workItems.$values, then sort/filter/analyze
   ```

3. **Use jiq or jqp** to build jq filters interactively
   ```bash
   ./publish/azdw query --limit 100 --json | jiq
   # or
   ./publish/azdw query --limit 100 --json | jqp
   ```

4. **Copy the working filter to jq** for scripting
   ```bash
   ./publish/azdw query --limit 500 --json | jq '.workItems["$values"][] | select(.state == "Active") | {id, title}'
   ```

5. **Save to a script** for reuse
   ```bash
   #!/bin/bash
   ./publish/azdw query --types Bug --json | jq '[.workItems["$values"][] | select(.state == "Active")] | length'
   ```

> **Note**: All jq filter expressions work identically in jq, jiq, and jqp. VisiData uses its own filtering system but can import/export JSON for use with jq.


## Common Query Patterns

### Filter Work Items by State

```bash
# Get all active work items
./publish/azdw query --json | jq '.workItems["$values"][] | select(.state == "Active")'

# Multiple states
./publish/azdw query --json | jq '.workItems["$values"][] | select(.state == "Active" or .state == "New")'

# Using contains for partial matches
./publish/azdw query --json | jq '.workItems["$values"][] | select(.state | contains("Active"))'
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --limit 100 --json | jq '[.workItems["$values"][] | select(.state == "Active") | {id, title, state}]'
```

### Filter by Logical Type

```bash
# Get all bugs
./publish/azdw query --json | jq '.workItems["$values"][] | select(.logicalType == "Bug")'

# Get features and epics
./publish/azdw query --json | jq '.workItems["$values"][] | select(.logicalType == "Feature" or .logicalType == "Epic")'

# Count by type
./publish/azdw query --json | jq '[.workItems["$values"][] | .logicalType] | group_by(.) | map({type: .[0], count: length})'
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --limit 200 --json | jq '[.workItems["$values"][] | select(.logicalType == "Bug") | {id, title, state, assignedTo: .assignedTo.displayName}]'
```

### Filter by Organization

```bash
# Filter work items from specific organization
./publish/azdw query --json | jq '.workItems["$values"][] | select(.organization.name == "MyOrg")'

# Group by organization
./publish/azdw query --json | jq 'group_by(.organization.name) | map({org: .[0].organization.name, count: length})'
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --limit 300 --json | jq '[.workItems["$values"][] | {org: .organization.name, id, title}] | group_by(.org)'
```

### Filter by Tags

```bash
# Work items with specific tag
./publish/azdw query --json | jq '.workItems["$values"][] | select(.tags | contains(["production"]))'

# Work items with any of multiple tags
./publish/azdw query --json | jq '.workItems["$values"][] | select(.tags | map(. == "urgent" or . == "critical") | any)'

# Count work items by tag
./publish/azdw query --json | jq '[.workItems["$values"][].tags[]] | group_by(.) | map({tag: .[0], count: length}) | sort_by(-.count)'
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --tags production --json | jq '[.workItems["$values"][] | select(.tags | contains(["production"])) | {id, title, tags}]'
```


## Work Item Analysis Scenarios

### Scenario 1: Find Unassigned Critical Bugs

Find all unassigned bugs with high priority that need immediate attention.

**jq Query:**
```bash
./publish/azdw query --types Bug --json | jq '[
  .workItems["$values"][] 
  | select(.assignedTo == null and (.priority == "1" or .priority == "Critical"))
  | {
      id, 
      title, 
      state, 
      createdDate,
      organization: .organization.name,
      url: .webUrl
    }
]'
```

**With json-tui (structure browsing only):**
```bash
# Save results
./publish/azdw query --types Bug --state Active --json > bugs.json

# Browse structure interactively
json-tui bugs.json
```

**With jiq or jqp (interactive filtering):**
```bash
# Use jiq for quick filtering
./publish/azdw query --types Bug --state Active --json | jiq
# Then type: .workItems["$values"][] | select(.assignedTo == null)

# Or use jqp for full-featured playground
./publish/azdw query --types Bug --state Active --json | jqp
```

### Scenario 2: Team Workload Analysis

Analyze work distribution across team members.

**jq Query:**
```bash
./publish/azdw query --state 'In Work' --include-pii --json | jq '
  [.workItems["$values"][] | select(.assignedTo != null)]
  | group_by(.assignedTo.displayName)
  | map({
      name: .[0].assignedTo.displayName,
      totalItems: length,
      bugs: [.[] | select(.logicalType == "Bug")] | length,
      tasks: [.[] | select(.logicalType == "Task")] | length,
      features: [.[] | select(.logicalType == "Feature")] | length
    })
  | sort_by(-.totalItems)
'
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --state 'In Work' --limit 500 --include-pii --json | jq '[.workItems["$values"][] | select(.assignedTo != null)] | group_by(.assignedTo.displayName) | map({name: .[0].assignedTo.displayName, count: length}) | sort_by(-.count)'
```

### Scenario 3: Sprint Progress Dashboard

Get sprint status with completion metrics.

**jq Query:**
```bash
./publish/azdw query --iteration "Sprint 42" --json | jq '{
  total: .totalCount,
  byState: (
    [.workItems["$values"][] | .state] 
    | group_by(.) 
    | map({state: .[0], count: length})
  ),
  byType: (
    [.workItems["$values"][] | .logicalType] 
    | group_by(.) 
    | map({type: .[0], count: length})
  ),
  completionRate: (
    ([.workItems["$values"][] | select(.state == "Closed")] | length) / .totalCount * 100
  )
}'
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --iteration "Current" --json | jq '{total: .totalCount, completed: ([.workItems["$values"][] | select(.state == "Closed")] | length), active: ([.workItems["$values"][] | select(.state == "Active")] | length)}'
```

### Scenario 4: Stale Work Items Report

Find work items that haven't been updated in over 30 days.

**jq Query:**
```bash
./publish/azdw query --state Active --json | jq --arg cutoff_date "$(date -u -v-30d +%Y-%m-%dT%H:%M:%SZ)" '
  [.workItems["$values"][] 
   | select(.modifiedDate < $cutoff_date)
   | {
       id,
       title,
       state,
       assignedTo: .assignedTo.displayName // "Unassigned",
       lastModified: .modifiedDate,
       daysSinceUpdate: ((now - (.modifiedDate | fromdate)) / 86400 | floor),
       url: .webUrl
     }
  ]
  | sort_by(-.daysSinceUpdate)
'
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --state Active --json | jq --arg cutoff "$(date -u -v-30d +%Y-%m-%dT%H:%M:%SZ)" '[.workItems["$values"][] | select(.modifiedDate < $cutoff) | {id, title, lastModified: .modifiedDate}] | sort_by(.lastModified)'
```


## Relationship Analysis

### Finding Parent-Child Relationships

```bash
# Get all work items with their parent relationships
./publish/azdw query --relationships --json | jq '[
  .workItems["$values"][]
  | {
      id,
      title,
      type: .logicalType,
      parents: [.relationships[]? | select(.relationType == "Parent") | .targetId],
      children: [.relationships[]? | select(.relationType == "Child") | .targetId]
    }
]'
```

### Cross-Organization Dependencies

Identify work items that depend on items in other organizations.

```bash
./publish/azdw query --relationships --json | jq '[
  .workItems["$values"][]
  | select(.relationships[]? | .relationType == "Dependency")
  | {
      id,
      title,
      org: .organization.name,
      dependencies: [
        .relationships[]? 
        | select(.relationType == "Dependency")
        | {
            targetId,
            targetOrg: .targetOrganization // "Same Org",
            targetTitle: .targetTitle
          }
      ]
    }
  | select(.dependencies | length > 0)
]'
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --relationships --limit 100 --json | jq '[.workItems["$values"][] | select(.relationships | length > 0) | {id, title, relationshipCount: (.relationships | length)}]'
```

### Orphaned Work Items

Find work items with no relationships (neither parent nor child).

```bash
./publish/azdw query --json | jq '[
  .workItems["$values"][]
  | select((.relationships | length) == 0)
  | {id, title, type: .logicalType, state}
]'
```


## Cross-Organization Queries

### Scenario: Multi-Org Feature Tracking

Track features across multiple Azure DevOps organizations.

**jq Query:**
```bash
./publish/azdw query --types Feature --json | jq '
  group_by(.organization.name)
  | map({
      organization: .[0].organization.name,
      totalFeatures: length,
      byState: (
        group_by(.state) 
        | map({state: .[0].state, count: length})
      ),
      inProgress: [.[] | select(.state == "Active")] | length,
      completed: [.[] | select(.state == "Closed")] | length
    })
'
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --types Feature --limit 200 --json | jq 'group_by(.organization.name) | map({org: .[0].organization.name, count: length})'
```

### Scenario: Cross-Org Dependency Map

Generate a dependency map showing links between organizations.

```bash
./publish/azdw query --relationships --json | jq '[
  .. | objects 
  | select(has("sourceOrganization") and has("targetOrganization") and has("relationType"))
  | select(.sourceOrganization != null and .targetOrganization != null)
  | select(.sourceOrganization != .targetOrganization)
  | {
      source: {
        org: .sourceOrganization,
        id: .sourceWorkItemId,
        type: .sourceWorkItemType,
        project: .sourceProject
      },
      target: {
        org: .targetOrganization,
        id: .targetWorkItemId,
        type: .targetWorkItemType,
        project: .targetProject
      },
      relationType,
      isCrossOrganizational
    }
] | unique'
```


## Advanced jq Techniques

### Custom Functions

Define reusable jq functions:

```bash
# Define function to format work item
./publish/azdw query --json | jq '
  def formatWorkItem:
    {
      id,
      title,
      type: .logicalType,
      owner: .assignedTo.displayName // "Unassigned",
      status: .state,
      org: .organization.name
    };
  
  [.workItems["$values"][] | formatWorkItem]
'
```

### Recursive Processing

Navigate nested relationship hierarchies:

```bash
# Recursively find all child items
./publish/azdw query --relationships --json | jq '
  def getAllChildren(item):
    item
    | .relationships[]?
    | select(.relationType == "Child")
    | .targetId;
  
  [.workItems["$values"][] | {id, children: [getAllChildren(.)]}]
'
```

### Complex Aggregations

```bash
# Multi-level grouping and aggregation
./publish/azdw query --json | jq '
  [.workItems["$values"][]]
  | group_by(.organization.name)
  | map({
      org: .[0].organization.name,
      byType: (
        group_by(.logicalType)
        | map({
            type: .[0].logicalType,
            byState: (
              group_by(.state)
              | map({state: .[0].state, count: length})
            )
          })
      )
    })
'
```

### Date and Time Operations

```bash
# Calculate work item age in days
./publish/azdw query --json | jq '[
  .workItems["$values"][]
  | . + {
      ageInDays: ((now - (.createdDate | fromdate)) / 86400 | floor),
      modifiedAgo: ((now - (.modifiedDate | fromdate)) / 86400 | floor)
    }
  | select(.ageInDays > 90)
]'
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --state Active --limit 100 --json | jq '[.workItems["$values"][] | {id, title, ageInDays: ((now - (.createdDate | fromdate)) / 86400 | floor)}] | sort_by(-.ageInDays)'
```

### String Manipulation

```bash
# Extract email domain from assignee
./publish/azdw query --json | jq '[
  .workItems["$values"][]
  | select(.assignedTo != null)
  | {
      id,
      title,
      assignee: .assignedTo.displayName,
      domain: (.assignedTo.uniqueName | split("@")[1])
    }
]'

# Regex pattern matching
./publish/azdw query --json | jq '[
  .workItems["$values"][]
  | select(.title | test("\\[URGENT\\]"; "i"))
]'
```


## Performance Tips

### 1. Limit Data Early

Always use `--limit` when exploring data:

```bash
# Good: Limit at source
./publish/azdw query --limit 100 --json | jq '.workItems["$values"][] | select(.state == "Active")'

# Bad: No limit, processes all data
./publish/azdw query --json | jq '.workItems["$values"][] | select(.state == "Active")'
```

### 2. Use Compact Output for Piping

```bash
# Compact JSON for processing
./publish/azdw query --limit 50 --json | jq -c '.workItems["$values"][]' | grep "Bug"

# Stream processing with --stream for very large files
jq --stream 'select(.[0][1] == "title") | .[1]' large-result.json
```

### 3. Save and Reuse Results

```bash
# Save results once
./publish/azdw query --limit 1000 --json > all-items.json

# Reuse for multiple queries
cat all-items.json | jq '.workItems["$values"][] | select(.state == "Active")'
cat all-items.json | jq '.workItems["$values"][] | select(.logicalType == "Bug")'
cat all-items.json | json-tui
```

### 4. Use jq Filters Instead of Shell Pipes When Possible

```bash
# Faster: Single jq invocation
./publish/azdw query --json | jq '[.workItems["$values"][] | select(.state == "Active")] | length'

# Slower: Multiple shell commands
./publish/azdw query --json | jq '.workItems["$values"][] | select(.state == "Active")' | jq 'length'
```


## Real-World Examples

### Example 1: Release Planning Report

Generate a comprehensive release planning report with work distribution.

```bash
#!/bin/bash
# release-report.sh

OUTPUT_FILE="release-report.json"

# Fetch all work items for release
./publish/azdw query \
  --iteration "Release 2.0" \
  --include-pii \
  --json > "$OUTPUT_FILE"

# Generate report sections
echo "=== Release 2.0 Report ===" > report.txt

# Total counts
echo -e "\n## Overview" >> report.txt
jq '{
  total: .totalCount,
  byState: ([.workItems["$values"][] | .state] | group_by(.) | map({state: .[0], count: length})),
  completionPercentage: (([.workItems["$values"][] | select(.state == "Closed")] | length) / .totalCount * 100 | round)
}' "$OUTPUT_FILE" >> report.txt

# By Team Member
echo -e "\n## Team Workload" >> report.txt
jq -r '
  [.workItems["$values"][] | select(.assignedTo != null)]
  | group_by(.assignedTo.displayName)
  | map({
      name: .[0].assignedTo.displayName,
      total: length,
      completed: [.[] | select(.state == "Closed")] | length
    })
  | sort_by(-.total)
  | .[]
  | "\(.name): \(.completed)/\(.total) completed"
' "$OUTPUT_FILE" >> report.txt

# High-risk items
echo -e "\n## High-Risk Items" >> report.txt
jq -r '
  [.workItems["$values"][]
   | select(.state != "Closed" and (
       (.priority == "1") or 
       (.tags | contains(["blocking"])) or
       ((.modifiedDate | fromdate) < (now - 604800))
     ))
   | {id, title, state, assignedTo: .assignedTo.displayName // "Unassigned"}
  ]
  | .[]
  | "[\(.id)] \(.title) - \(.state) - \(.assignedTo)"
' "$OUTPUT_FILE" >> report.txt

cat report.txt
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --iteration "Current" --json | jq '{total: .totalCount, completed: ([.workItems["$values"][] | select(.state == "Closed")] | length), completion: (([.workItems["$values"][] | select(.state == "Closed")] | length) / .totalCount * 100 | round)}' > sprint-progress.json && cat sprint-progress.json
```

### Example 2: Bug Triage Dashboard

Create a bug triage dashboard showing priority distribution.

```bash
#!/bin/bash
# bug-triage.sh

./publish/azdw query --types Bug --state Active,New --json | jq '
{
  totalBugs: .totalCount,
  byPriority: (
    [.workItems["$values"][]]
    | group_by(.priority // "Not Set")
    | map({
        priority: .[0].priority // "Not Set",
        count: length,
        unassigned: [.[] | select(.assignedTo == null)] | length,
        oldest: (map(.createdDate) | min),
        newest: (map(.createdDate) | max)
      })
    | sort_by(.priority)
  ),
  unassignedCount: [.workItems["$values"][] | select(.assignedTo == null)] | length,
  needsAttention: [
    .workItems["$values"][]
    | select(
        (.priority == "1" or .priority == "Critical") and
        (.state == "New" or .assignedTo == null)
      )
  ] | length
}
' | json-tui
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --types Bug --state Active,New --limit 200 --json | jq '{total: .totalCount, unassigned: ([.workItems["$values"][] | select(.assignedTo == null)] | length), critical: ([.workItems["$values"][] | select(.priority == "1" or .priority == "Critical")] | length)}'
```

### Example 3: Cross-Organization Dependency Tracker

Track dependencies across multiple organizations.

```bash
#!/bin/bash
# cross-org-deps.sh

./publish/azdw query --relationships --json | jq '
  [.workItems["$values"][]
   | select(.relationships[]? | .relationType == "Dependency")
   | {
       id,
       title,
       org: .organization.name,
       project: .project,
       crossOrgDeps: [
         .relationships[]?
         | select(.relationType == "Dependency" and .targetOrganization != null)
         | {
             targetOrg: .targetOrganization,
             targetId,
             targetTitle
           }
       ]
     }
   | select(.crossOrgDeps | length > 0)
  ]
  | group_by(.org)
  | map({
      organization: .[0].org,
      itemsWithDeps: length,
      dependencies: [.[].crossOrgDeps[]]
    })
' > cross-org-deps.json

# Visualize in json-tui
json-tui cross-org-deps.json
```

**Copy & Paste Ready:**
```bash
./publish/azdw query --relationships --limit 300 --json | jq '[.workItems["$values"][] | select(.relationships | length > 0) | {id, title, org: .organization.name, depCount: ([.relationships[] | select(.relationType == "Dependency")] | length)}] | group_by(.org)'
```


## Quick Reference

### Essential jq Patterns

```bash
# Pretty-print
./publish/azdw query --json | jq '.'

# Get specific field
./publish/azdw query --json | jq '.totalCount'

# Array of work items
./publish/azdw query --json | jq '.workItems["$values"]'

# Filter by condition
./publish/azdw query --json | jq '.workItems["$values"][] | select(.state == "Active")'

# Map to new structure
./publish/azdw query --json | jq '[.workItems["$values"][] | {id, title}]'

# Group and count
./publish/azdw query --json | jq '[.workItems["$values"][] | .state] | group_by(.) | map({state: .[0], count: length})'

# Sort
./publish/azdw query --json | jq '[.workItems["$values"][]] | sort_by(.createdDate)'

# Raw output (no quotes)
./publish/azdw query --json | jq -r '.workItems["$values"][].title'

# Compact output
./publish/azdw query --json | jq -c '.workItems["$values"][]'

# Multiple filters
./publish/azdw query --json | jq '.workItems["$values"][] | select(.state == "Active" and .logicalType == "Bug")'
```

### Common jq Functions

| Function     | Description         | Example                         |                       |
|--------------|---------------------|---------------------------------|-----------------------|
| `select()`   | Filter items        | `select(.state == "Active")`    |                       |
| `map()`      | Transform array     | `map({id, title})`              |                       |
| `group_by()` | Group by field      | `group_by(.state)`              |                       |
| `sort_by()`  | Sort array          | `sort_by(.createdDate)`         |                       |
| `length`     | Array/string length | `.workItems["$values"] \        | length`               |
| `add`        | Sum numbers         | `[.workItems["$values"][].id] \ | add`                  |
| `contains()` | Check contains      | `.tags \                        | contains(["urgent"])` |
| `test()`     | Regex match         | `.title \                       | test("bug"; "i")`     |
| `tostring`   | Convert to string   | `.id \                          | tostring`             |
| `tonumber`   | Convert to number   | `.priority \                    | tonumber`             |

### json-tui Keyboard Shortcuts

| Key        | Action          |
|------------|-----------------|
| ↑/↓ or j/k | Navigate        |
| Enter      | Expand/collapse |

### json-tui Keyboard Shortcuts

| Key                  | Action              |
|----------------------|---------------------|
| ↑/↓ or j/k or h/l    | Navigate            |
| Enter or Mouse Click | Expand/collapse     |
| +                    | Deep expand         |
| -                    | Deep collapse       |
| gg                   | Jump to top         |
| G                    | Jump to bottom      |
| Page Up/Down         | Navigate first/last |
| Escape or q          | Quit                |

**Usage:**
```bash
./publish/azdw query --json | json-tui
# Navigate with arrow keys or vim keys
# Expand/collapse with Enter
# No jq filtering - use jiq/jqp for that
```

### jiq Keyboard Shortcuts

| Key         | Action                    |
|-------------|---------------------------|
| Type        | Enter jq filter           |
| Ctrl+C or q | Quit                      |
| ↑/↓         | Scroll results            |
| Tab         | Cycle through UI elements |

**Usage:**
```bash
./publish/azdw query --json | jiq
# Type filter: .workItems["$values"][] | select(.state == "Active")
# See live results as you type
```

### jqp Keyboard Shortcuts

| Key              | Action                   |
|------------------|--------------------------|
| Tab              | Switch between panes     |
| ↑/↓              | Navigate history/results |
| Ctrl+C or Ctrl+D | Quit                     |
| Ctrl+S           | Save filter              |
| /                | Search in output         |
| ?                | Help                     |

**Usage:**
```bash
./publish/azdw query --json | jqp
# Use Tab to switch panes
# ↑/↓ to browse filter history
# Type filters in query pane
```

### VisiData Keyboard Shortcuts

| Key               | Action                    |                 |
|-------------------|---------------------------|-----------------|
| ↑/↓ or j/k        | Navigate rows             |                 |
| ←/→ or h/l        | Navigate columns          |                 |
| Enter             | Open nested sheet         |                 |
| q                 | Quit/close sheet          |                 |
| Shift+F           | Frequency table           |                 |
| Shift+I           | Histogram                 |                 |
| \                 | or \\                     | Filter by value |
| [ or ]            | Sort ascending/descending |                 |
| g followed by ↑/↓ | Go to top/bottom          |                 |
| Ctrl+S            | Save sheet                |                 |
| Shift+O           | Options menu              |                 |

**Usage:**
```bash
vd results.json
# Navigate to workItems.$values (press Enter twice)
# Sort by column: press '[' or ']'
# Filter: press '|' and type value
# Frequency chart: press 'Shift+F'
# Histogram: press 'Shift+I'
```

### azdw JSON Output Formats

```bash
# Query results
./publish/azdw query --json

# With relationships
./publish/azdw query --relationships --json

# WIQL query
./publish/azdw wiql "SELECT [System.Id] FROM WorkItems" --json

# Connection list
./publish/azdw connection list --json

# Metadata
./publish/azdw metadata fields --json
```

### Tool Selection Guide

Choose the right tool for your task:

```bash
# Understanding structure → json-tui (viewer only, no filtering)
./publish/azdw query --json | json-tui

# Tabular analysis (sorting, filtering, stats) → VisiData
./publish/azdw query --json > results.json
vd results.json

# Building queries interactively → jiq (simple, fast)
./publish/azdw query --json | jiq

# Complex queries + examples → jqp (full-featured TUI)
./publish/azdw query --json | jqp

# Scripts & automation → jq (command-line)
./publish/azdw query --json | jq '.workItems["$values"][] | select(.state == "Active")'
```

**Workflow:**
1. Browse structure with `json-tui`
2. Analyze tabular data with `VisiData` (sort, filter, visualize)
3. Build jq filter with `jiq` or `jqp`
4. Use filter in `jq` for scripts


## Troubleshooting

### Issue: jq parse error

**Problem:**
```bash
./publish/azdw query --json | jq '.workItems'
# Error: jq: error (at <stdin>:1): Cannot index object with string "workItems"
```

**Solution:**
The JSON might contain `$values` wrapper. Try:
```bash
./publish/azdw query --json | jq '.workItems["$values"]'
```

### Issue: Empty results with select()

**Problem:**
```bash
./publish/azdw query --json | jq '.workItems["$values"][] | select(.assignedTo == "John")'
# No output
```

**Solution:**
Use `.displayName` or `.uniqueName`:
```bash
./publish/azdw query --json | jq '.workItems["$values"][] | select(.assignedTo.displayName == "John Doe")'
```

### Issue: Date comparison not working

**Problem:**
```bash
# Dates not comparing correctly
jq '.workItems["$values"][] | select(.createdDate > "2024-01-01")'
```

**Solution:**
Convert to Unix timestamp:
```bash
jq '.workItems["$values"][] | select((.createdDate | fromdate) > ("2024-01-01T00:00:00Z" | fromdate))'
```


## Additional Resources

### Official Documentation

- **jq Manual**: [https://jqlang.org/manual/](https://jqlang.org/manual/)
- **jq Tutorial**: [https://jqlang.org/tutorial/](https://jqlang.org/tutorial/)
- **json-tui GitHub**: [https://github.com/ArthurSonzogni/json-tui](https://github.com/ArthurSonzogni/json-tui)
- **jiq GitHub**: [https://github.com/fiatjaf/jiq](https://github.com/fiatjaf/jiq)
- **jqp GitHub**: [https://github.com/noahgorstein/jqp](https://github.com/noahgorstein/jqp)
- **VisiData**: [https://www.visidata.org/](https://www.visidata.org/)
- **VisiData Documentation**: [https://www.visidata.org/docs/](https://www.visidata.org/docs/)
- **VisiData Tutorial**: [Intro to VisiData](https://jsvine.github.io/intro-to-visidata/)
- **azdw Documentation**: [CLI-Help-Overview.md](CLI-Help-Overview.md)

### Interactive Tools & Learning

- **jq Play**: [https://jqplay.org/](https://jqplay.org/) - Test jq queries online
- **jq Cheat Sheet**: [Zendesk jq Reference](https://developer.zendesk.com/documentation/integration-services/developer-guide/jq-cheat-sheet/)
- **jiq** - Use locally for instant feedback while learning
- **jqp** - Explore built-in examples and filter history
- **VisiData** - Interactive spreadsheet-like exploration with built-in help (press `?`)

### Related Documentation

- [Filtering Query Results](Filtering-QueryResults.md)
- [CLI Use Cases](CLI-Use-Cases.md)
- [Cross-Org Relationship Handling](Cross-Org-Relationship-Handling.md)
- [Output Rendering & Automation](Output-Rendering-Automation.md)


## Contributing

Have useful jq patterns or json-tui workflows? Contribute to this guide:

1. Add your example to the appropriate section
2. Include copy-paste ready code blocks
3. Add sample output when helpful
4. Test with real azdw data


**Last Updated**: October 29, 2025  
**Version**: 1.0  
**Maintainer**: azdw Development Team
