---
title: Filtering/Processing Query Results
nav_order: 90
---

# Filtering/Processing Query Results

## CLI Tool-Based Filtering and Analysis

When using the `azdw` CLI tool, you can pipe JSON output to various specialized tools for powerful filtering, transformation, and interactive exploration. This section covers seven recommended tools for working with azdw JSON output.

### Quick Tool Selection Guide

| Need | Recommended Tool | Why |
|------|------------------|-----|
| **Script automation** | jq | Most powerful, widely supported |
| **Simple queries** | jp (JMESPath) | Easier syntax for basic filtering |
| **Quick viewing** | jless | Fast, intuitive navigation |
| **Find field paths** | gron | Makes JSON greppable |
| **Learn jq syntax** | jid | Interactive query building |
| **Deep exploration** | play | Multiple views, powerful search |
| **Data analysis** | VisiData | Spreadsheet-like, pivot tables |

### Getting JSON Output from azdw CLI

```bash
# Get JSON output with pretty printing
azdw wiql "SELECT [System.Id], [System.Title] FROM WorkItems" --json --pretty

# Get compact JSON (one line) - better for piping
azdw wiql "SELECT [System.Id], [System.Title] FROM WorkItems" --json

# Include failed organization details
azdw wiql "SELECT [System.Id], [System.Title] FROM WorkItems" \
  --json --include-failed --pretty
```

### JSON Output Structure

The CLI outputs JSON in two formats:

**Standard output** (without `--include-failed`):
```json
{
  "workItems": [...],
  "totalCount": 42
}
```

**Full output** (with `--include-failed`):
```json
{
  "workItems": [...],
  "relationships": [...],
  "successfulOrganizations": [...],
  "failedOrganizations": [...],
  "queryFilter": {...},
  "queryExecutedAt": "2025-10-22T10:30:00Z",
  "totalExecutionTime": "00:00:02.5",
  "warnings": [],
  "totalCount": 42,
  "successfulOrganizationCount": 3,
  "failedOrganizationCount": 0
}
```


## jq - Command-Line JSON Processor

**Website:** https://jqlang.org/  
**Installation:**
```bash
# macOS
brew install jq

# Linux (Ubuntu/Debian)
sudo apt-get install jq

# Windows (via Chocolatey)
choco install jq
```

**Overview:** jq is the most popular and mature command-line JSON processor. It provides a complete functional programming language for transforming JSON data with filters, pipes, and complex queries.

### jq Filtering Examples

#### Basic Work Item Filtering

```bash
# Get only bugs
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | select(.logicalType == "Bug")'

# Get high-priority items
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | select(.priority == "High" or .priority == "Critical")'

# Get active work items
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | select(.state == "Active")'
```

#### Field Selection

```bash
# Get only ID and title
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | {id, title}'

# Get ID, title, and type
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | {id, title, type: .logicalType}'

# Get work items with assigned user
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | {id, title, assignedTo: .assignedTo.displayName}'
```

#### Filtering by Organization

```bash
# Get work items from specific organization
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | select(.organization.baseUrl | contains("myorg"))'

# Group by organization
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq 'group_by(.organization.baseUrl) | 
      map({org: .[0].organization.baseUrl, count: length})'
```

#### Date-Based Filtering

```bash
# Get work items created in last 30 days
# Note: Date comparison in jq requires ISO format
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq --arg cutoff "$(date -u -v-30d +%Y-%m-%dT%H:%M:%SZ)" \
  '.workItems[] | select(.createdDate > $cutoff)'

# Get recently modified items (last 7 days)
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq --arg cutoff "$(date -u -v-7d +%Y-%m-%dT%H:%M:%SZ)" \
  '.workItems[] | select(.modifiedDate > $cutoff)'
```

#### Complex Multi-Criteria Filtering

```bash
# Get critical bugs that are not closed
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | 
      select(.logicalType == "Bug" and 
             .priority == "Critical" and 
             .state != "Closed")'

# Get unassigned high-priority work items
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | 
      select(.assignedTo == null and 
             (.priority == "High" or .priority == "Critical"))'
```

#### Grouping and Aggregation

```bash
# Count work items by type
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems | group_by(.logicalType) | 
      map({type: .[0].logicalType, count: length})'

# Count by state
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems | group_by(.state) | 
      map({state: .[0].state, count: length})'

# Complex grouping: by organization and type
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems | 
      group_by(.organization.baseUrl) | 
      map({
        organization: .[0].organization.baseUrl,
        types: (group_by(.logicalType) | 
                map({type: .[0].logicalType, count: length}))
      })'
```

#### Statistical Queries

```bash
# Get work item count summary
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '{
    total: .totalCount,
    bugs: [.workItems[] | select(.logicalType == "Bug")] | length,
    features: [.workItems[] | select(.logicalType == "Feature")] | length,
    tasks: [.workItems[] | select(.logicalType == "Task")] | length
  }'

# Calculate average age of work items (in days)
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems | 
      map((now - (.createdDate | fromdateiso8601)) / 86400) | 
      add / length'
```

#### Tag-Based Filtering

```bash
# Get work items with specific tag
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | select(.tags | contains(["urgent"]))'

# Get work items with any of multiple tags
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | 
      select(.tags | 
             any(. == "bug" or . == "hotfix" or . == "critical"))'
```

#### Custom Field Access

```bash
# Filter by custom field
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | 
      select(.fields["Custom.RiskLevel"] == "High")'

# Get work items with specific custom values
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | 
      select(.fields["Custom.Customer"] == "Contoso" and 
             .fields["Custom.Module"] == "Authentication")'
```

#### Formatted Output

```bash
# Create CSV-like output
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq -r '.workItems[] | 
         [.id, .logicalType, .title, .state] | 
         @csv'

# Create formatted table output
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq -r '.workItems[] | 
         "\(.id)\t\(.logicalType)\t\(.state)\t\(.title)"'

# Create markdown table
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq -r '["ID","Type","State","Title"], 
         ["---","---","---","---"],
         (.workItems[] | [.id, .logicalType, .state, .title]) | 
         @tsv'
```

#### andling Partial Success

```bash
# Check for failures
azdw wiql "SELECT * FROM WorkItems" -o json --include-failed | \
  jq '{
    successRate: .successRate,
    successful: .successfulOrganizationCount,
    failed: .failedOrganizationCount,
    failures: [.failedOrganizations[] | 
               {org: .organizationName, error: .errorMessage}]
  }'

# Get only work items from successful organizations
azdw wiql "SELECT * FROM WorkItems" -o json --include-failed | \
  jq --argjson successOrgs '.successfulOrganizations | map(.organizationUrl)' \
  '.workItems[] | 
   select([.organization.baseUrl] | inside($successOrgs))'
```

#### Sorting

```bash
# Sort by priority (custom order)
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems | 
      sort_by(
        if .priority == "Critical" then 0
        elif .priority == "High" then 1
        elif .priority == "Medium" then 2
        else 3 end
      )'

# Sort by creation date (newest first)
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems | sort_by(.createdDate) | reverse'

# Multi-level sort: priority then date
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems | 
      sort_by([
        (if .priority == "Critical" then 0
         elif .priority == "High" then 1
         elif .priority == "Medium" then 2
         else 3 end),
        .createdDate
      ])'
```


## jp - JMESPath Command-Line Tool

**Website:** https://github.com/jmespath/jp  
**Installation:**
```bash
# macOS
brew install jmespath/jmespath/jp

# Pre-built binaries available on GitHub
# https://github.com/jmespath/jp/releases
```

**Overview:** jp uses JMESPath query language, which offers a different syntax than jq that some users find more intuitive. It's particularly good for Python developers familiar with boto3's filtering.

### jp Examples

```bash
# Basic filtering - get bugs only
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jp 'workItems[?logicalType == `Bug`]'

# Get high-priority items
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jp 'workItems[?priority == `High` || priority == `Critical`]'

# Project specific fields
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jp 'workItems[*].{id: id, title: title, type: logicalType}'

# Count items by type
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jp 'length(workItems[?logicalType == `Bug`])'

# Get unassigned critical items
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jp 'workItems[?assignedTo == null && priority == `Critical`]'

# Sort by priority (requires transformation)
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jp 'reverse(sort_by(workItems, &priority))'

# Get items from specific organization
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jp 'workItems[?contains(organization.baseUrl, `myorg`)]'
```

**Advantages over jq:**
- Simpler syntax for basic queries
- Native support for complex object filtering
- Better for users coming from Python/boto3 background


## jless - Interactive JSON Viewer

**Website:** https://github.com/PaulJuliusMartinez/jless  
**Installation:**
```bash
# macOS
brew install jless

# Cargo (Rust)
cargo install jless

# Pre-built binaries available
# https://github.com/PaulJuliusMartinez/jless/releases
```

**Overview:** jless is a modern, interactive JSON viewer with vim-like keybindings, syntax highlighting, and collapsible tree views. Perfect for exploring large azdw query results interactively.

### jless Usage

```bash
# View query results interactively
azdw wiql "SELECT * FROM WorkItems" -o json --pretty | jless

# Save to file and explore
azdw wiql "SELECT * FROM WorkItems" -o json --pretty > results.json
jless results.json

# Pipe from file
cat results.json | jless

# View with include-failed information
azdw wiql "SELECT * FROM WorkItems" -o json --include-failed --pretty | jless
```

**Key Features:**
- **Syntax highlighting** - Color-coded JSON structure
- **Collapsible sections** - Press space/Enter to expand/collapse
- **Search** - Press `/` to search within JSON
- **Vim keybindings** - `j/k` for navigation, `gg/G` for top/bottom
- **Line numbers** - Easy reference to specific parts
- **Focus mode** - Press `f` to focus on selected element
- **Copy path** - Press `y` to copy JSONPath of current location

**Interactive Commands:**
- `Space/Enter` - Expand/collapse current node
- `/` - Search forward
- `?` - Search backward
- `n/N` - Next/previous search result
- `q` - Quit
- `h` - Help screen


## gron - Make JSON Greppable

**Website:** https://github.com/tomnomnom/gron  
**Installation:**
```bash
# macOS
brew install gron

# Go install
go install github.com/tomnomnom/gron@latest

# Pre-built binaries
# https://github.com/tomnomnom/gron/releases
```

**Overview:** gron transforms JSON into discrete assignments that are easy to grep, then transforms it back. This makes it trivial to find specific paths in complex JSON structures.

### gron Examples

```bash
# Make JSON greppable
azdw wiql "SELECT * FROM WorkItems" -o json | gron

# Output example:
# json.workItems[0].id = 123;
# json.workItems[0].title = "Fix login bug";
# json.workItems[0].logicalType = "Bug";
# json.workItems[0].state = "Active";

# Find all fields containing "priority"
azdw wiql "SELECT * FROM WorkItems" -o json | gron | grep priority

# Find work items with specific state
azdw wiql "SELECT * FROM WorkItems" -o json | gron | grep 'state = "Active"'

# Find custom fields
azdw wiql "SELECT * FROM WorkItems" -o json | gron | grep "fields\[" | grep "Custom"

# Transform back to JSON (ungron)
azdw wiql "SELECT * FROM WorkItems" -o json | gron | grep "Bug" | gron --ungron

# Find all date fields
azdw wiql "SELECT * FROM WorkItems" -o json | gron | grep -E "(created|modified)Date"

# Find organization URLs
azdw wiql "SELECT * FROM WorkItems" -o json | gron | grep "organization.baseUrl"

# Complex filtering: Find critical bugs and ungron
azdw wiql "SELECT * FROM WorkItems" -o json | gron | \
  grep 'logicalType = "Bug"' | gron --ungron | gron | \
  grep 'priority = "Critical"' | gron --ungron
```

**Use Cases:**
- **Discovery** - Find all field paths in complex nested JSON
- **Quick filtering** - Use familiar grep patterns
- **Path finding** - Identify correct jq/jp paths for complex queries
- **Debugging** - See all values at a glance


## jid - JSON Incremental Digger

**Website:** https://github.com/simeji/jid  
**Installation:**
```bash
# macOS
brew install jid

# Go install
go install github.com/simeji/jid/cmd/jid@latest
```

**Overview:** jid provides an interactive, incremental drill-down interface for JSON. As you type filter expressions, results update in real-time.

### jid Usage

```bash
# Interactive filtering
azdw wiql "SELECT * FROM WorkItems" -o json | jid

# Start with initial filter
azdw wiql "SELECT * FROM WorkItems" -o json | jid -q '.workItems[]'

# Save to file first for repeated exploration
azdw wiql "SELECT * FROM WorkItems" -o json --pretty > results.json
jid < results.json
```

**Interactive Features:**
- **Real-time filtering** - See results as you type jq-like expressions
- **Tab completion** - Autocomplete object keys and array indices
- **History** - Navigate previous queries with up/down arrows
- **Query building** - Incrementally build complex queries
- **Copy output** - Select and copy filtered results

**Typical Workflow:**
1. Pipe azdw output to jid
2. Start typing: `.workItems`
3. Tab to autocomplete and see available fields
4. Add filters: `.workItems[] | select(.priority == "High")`
5. See results update in real-time
6. Copy final query for use in scripts

**Example Session:**
```bash
$ azdw wiql "SELECT * FROM WorkItems" -o json | jid
# Type: .workItems
# See: Array of work items
# Type: .workItems[]
# See: Individual work items flattened
# Type: .workItems[] | select(.state == "Active")
# See: Only active items
# Type: .workItems[] | select(.state == "Active") | {id, title}
# See: Projected fields
# Press Enter to output result
```


## play - Interactive JSON Explorer

**Website:** https://github.com/paololazzari/play  
**Installation:**
```bash
# Cargo (Rust)
cargo install play-json

# Pre-built binaries
# https://github.com/paololazzari/play/releases
```

**Overview:** play is a modern, interactive JSON explorer with a TUI (Terminal User Interface) that provides multiple views and powerful navigation.

### play Usage

```bash
# Launch interactive explorer
azdw wiql "SELECT * FROM WorkItems" -o json --pretty | play

# Or from file
azdw wiql "SELECT * FROM WorkItems" -o json --pretty > results.json
play results.json
```

**Key Features:**
- **Tree view** - Navigate JSON hierarchy
- **Raw view** - See original JSON with syntax highlighting
- **Flat view** - Flatten nested structures
- **Search** - Multi-mode search (keys, values, paths)
- **Statistics** - Object/array sizes, depth analysis
- **Multiple buffers** - Compare different JSON files
- **Export** - Save filtered views

**Keyboard Shortcuts:**
- `Tab` - Switch between views (tree/raw/flat)
- `Ctrl+f` - Search mode
- `Ctrl+s` - Save current view
- `j/k` - Navigate up/down
- `h/l` - Collapse/expand nodes
- `g/G` - Go to top/bottom
- `:` - Command mode
- `q` - Quit

**Commands:**
```
:filter <expression>   - Apply jq filter
:expand <depth>        - Expand to depth
:collapse              - Collapse all
:stats                 - Show statistics
:export <file>         - Export current view
```


## VisiData - Spreadsheet-like JSON Interface

**Website:** https://www.visidata.org/  
**Installation:**
```bash
# macOS
brew install visidata

# Python pip
pip3 install visidata

# Linux
apt-get install visidata  # Ubuntu/Debian
```

**Overview:** VisiData is a terminal spreadsheet multitool that can open, explore, and manipulate JSON data in a familiar spreadsheet-like interface. Exceptionally powerful for analyzing work item data.

### VisiData Usage with azdw

```bash
# Open JSON directly in VisiData
azdw wiql "SELECT * FROM WorkItems" -o json | vd -f json

# Save to file first (recommended for large datasets)
azdw wiql "SELECT * FROM WorkItems" -o json --pretty > results.json
vd results.json

# Open with specific sheet (for nested JSON)
azdw wiql "SELECT * FROM WorkItems" -o json --include-failed | vd -f json

# Export filtered results to CSV after manipulation
vd results.json --output filtered-results.csv
```

**Key Features for Work Item Analysis:**

1. **Spreadsheet View** - Work items displayed in columns
2. **Sorting** - Click/press `[` or `]` to sort by column
3. **Filtering** - Press `"` to select/filter rows by expression
4. **Grouping** - Press `g` + `Shift+F` to group by column (frequency table)
5. **Pivot Tables** - Create pivot tables for cross-analysis
6. **Statistics** - Press `Shift+I` to see column statistics
7. **Export** - Save filtered/transformed data to multiple formats

**Common VisiData Commands for azdw Data:**

```bash
# After opening: vd results.json

# Navigate to workItems array (if viewing full output)
Enter on workItems row

# Sort by priority
Move to priority column, press [

# Filter to show only bugs
Move to logicalType column, press |, type: Bug, Enter

# Group by state and count
Move to state column, press Shift+F (creates frequency table)

# Create pivot table (state vs. priority)
Select state column, press !, select priority column, press !, press Shift+W

# Show only active critical items
Move to state column, press |, type: Active
Move to priority column, press |, type: Critical

# Export filtered results to CSV
Press Ctrl+S, enter filename, select csv format

# Show column statistics (mean, median, etc.)
Move to any numeric column, press Shift+I
```

**VisiData Workflow Example:**

```bash
# 1. Get data from multiple organizations
azdw wiql "SELECT * FROM WorkItems WHERE [System.State] = 'Active'" \
  -o json --pretty > active-items.json

# 2. Open in VisiData
vd active-items.json

# 3. In VisiData:
# - Navigate to workItems (Enter)
# - Sort by priority (move to priority column, press [)
# - Filter to bugs (move to logicalType, press |, type Bug)
# - Group by assignedTo (move to assignedTo.displayName, press Shift+F)
# - Export to CSV (press Ctrl+S, type report.csv)

# 4. Result: CSV report of active bugs grouped by assignee
```

**Advanced VisiData Features:**

```bash
# Join multiple query results
vd results1.json results2.json
# Press Shift+J to join sheets

# Create calculated columns
# Press = to create new column with Python expression
# Example: =createdDate-modifiedDate (date difference)

# Aggregate data
# Press Shift+F on column to create frequency table
# Press + to add aggregator (sum, avg, min, max)

# Regex filtering
# Press "g" + "/" for regex search
# Example: g/.*authentication.*/i (case-insensitive search)

# Save session for reproducibility
# Press Ctrl+D to save .vd script
# Replay with: vd -p session.vd results.json
```

**VisiData Keyboard Reference:**
- `q` - Quit current sheet
- `Enter` - Dive into cell (for nested objects/arrays)
- `[` / `]` - Sort ascending/descending
- `|` - Filter by current column value
- `"` - Filter by Python expression
- `Shift+F` - Frequency table (group by)
- `Shift+W` - Pivot table
- `!` - Make column a key column
- `Ctrl+S` - Save sheet to file
- `-` - Hide current column
- `Shift+I` - Describe sheet (statistics)
- `g` prefix - Apply command to all/multiple items

**VisiData Output Formats:**

VisiData can export to many formats directly:
- CSV, TSV
- JSON, JSONL
- HTML tables
- Markdown tables
- Excel (xlsx)
- SQL insert statements
- LaTeX tables

```bash
# Export to different formats
vd results.json -o report.csv      # CSV
vd results.json -o report.xlsx     # Excel
vd results.json -o report.md       # Markdown table
vd results.json -o report.html     # HTML table
```


## Tool Comparison Matrix

| Tool         | Use Case                   | Interactive | Learning Curve | Speed  | Best For                     |
|--------------|----------------------------|-------------|----------------|--------|------------------------------|
| **jq**       | Filtering & transformation | No          | Medium         | Fast   | Scripting, automation        |
| **jp**       | Filtering (JMESPath)       | No          | Low            | Fast   | Python devs, simple queries  |
| **jless**    | Viewing & exploring        | Yes         | Low            | Fast   | Quick exploration, reading   |
| **gron**     | Finding paths              | No          | Low            | Fast   | Discovery, debugging         |
| **jid**      | Building queries           | Yes         | Low            | Medium | Learning jq, query building  |
| **play**     | Multi-view exploration     | Yes         | Medium         | Medium | Deep exploration, comparison |
| **VisiData** | Analysis & reporting       | Yes         | High           | Medium | Data analysis, pivot tables  |


### Recommended Workflow

1. **Initial Exploration** - Use `jless` or `play` to understand data structure
2. **Path Discovery** - Use `gron` to find exact field paths
3. **Query Building** - Use `jid` to interactively build jq queries
4. **Automation** - Convert to `jq` or `jp` scripts
5. **Deep Analysis** - Use `VisiData` for aggregations and reporting
6. **Quick Filtering** - Use `jq` for fast command-line filtering

### Combining with Other Unix Tools

```bash
# Count work items
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems | length'

# Get only IDs for further processing
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq -r '.workItems[].id'

# Pipe to file for later analysis
azdw wiql "SELECT * FROM WorkItems" -o json --pretty | \
  tee results.json | \
  jq '.workItems | length'

# Search within results
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq -r '.workItems[] | "\(.id): \(.title)"' | \
  grep -i "authentication"

# Paginate results
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq -r '.workItems[] | "\(.id)\t\(.title)"' | \
  less

# Combine with fzf for interactive selection
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq -r '.workItems[] | "\(.id)\t\(.title)"' | \
  fzf

# Generate statistics with awk
azdw wiql "SELECT * FROM WorkItems" -o json | \
  gron | grep "state" | awk -F'"' '{print $2}' | sort | uniq -c

# Create quick visualizations with gnuplot
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq -r '.workItems[] | .logicalType' | sort | uniq -c | \
  gnuplot -e "set terminal dumb; plot '-' with boxes"
```

### Multi-Tool Workflows

#### Exploration to Automation

```bash
# Step 1: Explore with jless
azdw wiql "SELECT * FROM WorkItems" -o json --pretty | jless

# Step 2: Find paths with gron
azdw wiql "SELECT * FROM WorkItems" -o json | gron | grep "priority"

# Step 3: Build query with jid
azdw wiql "SELECT * FROM WorkItems" -o json | jid

# Step 4: Create automation script with jq
cat > filter-critical.sh << 'EOF'
#!/bin/bash
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | select(.priority == "Critical" and .state != "Closed")'
EOF
chmod +x filter-critical.sh
```

#### Analysis and Reporting

```bash
# Step 1: Get data
azdw wiql "SELECT * FROM WorkItems WHERE [System.State] = 'Active'" \
  -o json --pretty > active-items.json

# Step 2: Quick stats with jq
cat active-items.json | jq '{
  total: .totalCount,
  byType: (.workItems | group_by(.logicalType) | map({type: .[0].logicalType, count: length})),
  byPriority: (.workItems | group_by(.priority) | map({priority: .[0].priority, count: length}))
}'

# Step 3: Deep analysis with VisiData
vd active-items.json
# In VisiData: create pivot tables, frequency analysis, export reports

# Step 4: Generate final reports
vd active-items.json -o report.xlsx  # Excel report
vd active-items.json -o report.html  # HTML dashboard
```

#### Cross-Organization Consistency

```bash
# Step 1: Query all organizations
azdw wiql "SELECT * FROM WorkItems" -o json --include-failed > all-orgs.json

# Step 2: Check for failures with jq
cat all-orgs.json | jq '{
  failed: .failedOrganizationCount,
  failures: [.failedOrganizations[] | {org: .organizationName, error: .errorMessage}]
}'

# Step 3: Explore successful results with play
cat all-orgs.json | jq '.workItems' | play

# Step 4: Analyze consistency with VisiData
# Group by organization, compare distributions
jq '.workItems' all-orgs.json | vd -f json

# Step 5: Generate org comparison report
cat all-orgs.json | jq '.workItems | group_by(.organization.baseUrl) | 
  map({
    org: .[0].organization.baseUrl,
    total: length,
    bugs: [.[] | select(.logicalType == "Bug")] | length,
    features: [.[] | select(.logicalType == "Feature")] | length,
    avgAge: (map((now - (.createdDate | fromdateiso8601)) / 86400) | add / length | round)
  })' | vd -f json -o org-comparison.csv
```


## Common Filtering Scenarios

### Find Stale Work Items

**CLI:**
```bash
azdw wiql "SELECT * FROM WorkItems WHERE [System.State] = 'Active'" -o json | \
  jq --arg cutoff "$(date -u -v-30d +%Y-%m-%dT%H:%M:%SZ)" \
  '.workItems[] | select(.modifiedDate < $cutoff) | {id, title, modifiedDate}'
```

### Security Bug Analysis

**CLI:**
```bash
azdw wiql "SELECT * FROM WorkItems WHERE [System.WorkItemType] = 'Bug'" -o json | \
  jq '.workItems[] | 
      select(.state != "Closed" and 
             (.tags | any(. | ascii_downcase | contains("security"))))'
```

### Cross-Organization Consistency Check

**CLI:**
```bash
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems | group_by(.organization.baseUrl) | 
      map({
        organization: .[0].organization.baseUrl,
        totalItems: length,
        types: (group_by(.logicalType) | 
                map({type: .[0].logicalType, count: length})),
        avgAge: (map((now - (.createdDate | fromdateiso8601)) / 86400) | 
                 add / length)
      })'
```

### Unassigned Critical Work

**CLI:**
```bash
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '.workItems[] | 
      select(.assignedTo == null and 
             (.priority == "Critical" or .priority == "High") and 
             .state != "Closed") | 
      {id, title, priority, createdDate}'
```

### Sprint Summary Report

**CLI:**
```bash
azdw wiql "SELECT * FROM WorkItems" -o json | \
  jq '{
    totalItems: .totalCount,
    completed: [.workItems[] | select(.state == "Closed")] | length,
    inProgress: [.workItems[] | select(.state == "Active")] | length,
    notStarted: [.workItems[] | select(.state == "New")] | length,
    byType: (.workItems | group_by(.logicalType) | 
             map({type: .[0].logicalType, count: length})),
    highPriorityOpen: [.workItems[] | 
                       select((.priority == "Critical" or .priority == "High") 
                              and .state != "Closed")] | length
  }'
```


## Performance Considerations

### jq Performance

1. **Stream Processing**: jq processes JSON in streaming mode by default
2. **Avoid Unnecessary Sorting**: Sorting large datasets can be slow
3. **Use Compact JSON**: Omit `--pretty` when piping to jq for faster parsing
4. **Filter Early**: Apply filters before grouping or complex transformations

```bash
# ✅ Good: Filter then group
azdw wiql "..." -o json | \
  jq '.workItems[] | select(.state == "Active") | ...'

# ❌ Bad: Group everything then filter
azdw wiql "..." -o json | \
  jq '.workItems | group_by(...) | map(select(...)) | ...'
```

### CLI Output Formats

Choose the appropriate output format for your use case:

- **`--json`**: For programmatic processing with jq/scripting
- **`--output csv`**: For import into Excel or other tools
- **`--output ids`**: For piping to other `azdw` commands
- **`--output table`**: For human-readable console output

```bash
# Get IDs for further processing
azdw wiql "SELECT * FROM WorkItems WHERE [System.State] = 'Active'" \
  --output ids > active-ids.txt

# Export to CSV for Excel
azdw wiql "SELECT * FROM WorkItems" --output csv > report.csv

# Process with jq
azdw wiql "SELECT * FROM WorkItems" --json | jq '...'
```


## Additional Resources

### Documentation

- [Azure DevOps WIQL Reference](https://learn.microsoft.com/en-us/azure/devops/boards/queries/wiql-syntax)
- [azdw CLI Help](./CLI-Help-Overview.md)
- [azdw API Documentation](./API-Documentation.md)

### Tools

- **jq** - https://jqlang.org/
  - [jq Manual](https://jqlang.org/manual/)
  - [jq Playground](https://jqplay.org/)
  - [jq Cookbook](https://github.com/stedolan/jq/wiki/Cookbook)
- **jp (JMESPath)** - https://github.com/jmespath/jp
  - [JMESPath Tutorial](https://jmespath.org/tutorial.html)
  - [JMESPath Examples](https://jmespath.org/examples.html)
- **jless** - https://github.com/PaulJuliusMartinez/jless
  - [jless User Guide](https://jless.io/user-guide.html)
- **gron** - https://github.com/tomnomnom/gron
  - [gron Examples](https://github.com/tomnomnom/gron#examples)
- **jid** - https://github.com/simeji/jid
  - [jid Usage Guide](https://github.com/simeji/jid#usage)
- **play** - https://github.com/paololazzari/play
  - [play Documentation](https://github.com/paololazzari/play#readme)
- **VisiData** - https://www.visidata.org/
  - [VisiData Quick Reference](https://jsvine.github.io/intro-to-visidata/index.html)
  - [VisiData Documentation](https://www.visidata.org/docs/)
  - [VisiData Tutorial](https://jsvine.github.io/intro-to-visidata/)


## Examples Repository

Additional examples can be found in the `docs/samples/` directory:

- PowerShell integration examples: `docs/samples/powershell/`
- Python integration examples: `docs/samples/python/`
- Error handling patterns: `docs/samples/error-handling/`
