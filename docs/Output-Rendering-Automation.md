# Output Rendering and Automation

This document explains how to use the azdw CLI's powerful output rendering capabilities to generate human-readable documents and automate report generation workflows.

## Table of Contents

- [Overview](#overview)
  - [Cross-Organization Power](#cross-organization-power)
- [Template-Based Rendering](#template-based-rendering)
  - [Built-in Templates](#built-in-templates)
  - [Using Templates](#using-templates)
  - [Custom Templates](#custom-templates)
- [Output Formats](#output-formats)
  - [Markdown Reports](#markdown-reports)
  - [Self-Contained HTML](#self-contained-html)
  - [GraphViz Visualizations](#graphviz-visualizations)
  - [Mermaid Visualizations](#mermaid-visualizations)
  - [CSV Data Export](#csv-data-export)
  - [Excel Export with ImportExcel Module](#excel-export-with-importexcel-module)
- [Automation Workflows](#automation-workflows)
  - [Example: Daily Work Item Report](#example-daily-work-item-report)
  - [Scheduling with Cron (macOS/Linux)](#scheduling-with-cron-macoslinux)
  - [Scheduling with launchd (macOS)](#scheduling-with-launchd-macos)
  - [Scheduling with Task Scheduler (Windows)](#scheduling-with-task-scheduler-windows)
- [Advanced Use Cases](#advanced-use-cases)
  - [Weekly Sprint Retrospective](#weekly-sprint-retrospective)
  - [Release Notes Generation](#release-notes-generation)
  - [Team Dashboard Auto-Refresh](#team-dashboard-auto-refresh)
  - [Multi-Tenant Cross-Organization Report](#multi-tenant-cross-organization-report)
- [Best Practices](#best-practices)
  - [1. Use Version Control for Templates](#1-use-version-control-for-templates)
  - [2. Parameterize Your Scripts](#2-parameterize-your-scripts)
  - [3. Handle Errors Gracefully](#3-handle-errors-gracefully)
  - [4. Log Automation Runs](#4-log-automation-runs)
  - [5. Use JSON for Piping](#5-use-json-for-piping)
  - [6. Secure Credentials](#6-secure-credentials)
- [Troubleshooting](#troubleshooting)
  - [Report Generation Fails](#report-generation-fails)
  - [Browser Doesn't Open](#browser-doesnt-open)
  - [Cron Job Not Running](#cron-job-not-running)
- [See Also](#see-also)

## Overview

The azdw CLI provides flexible output rendering using the **Scriban templating engine**, allowing you to transform work item data into various formats including:

- **Markdown** - Documentation, reports, release notes
- **HTML** - Interactive dashboards, self-contained web pages with embedded CSS and JavaScript
- **CSV** - Data exports for spreadsheet analysis
- **GraphViz DOT** - Hierarchical visualizations and dependency graphs
- **Custom formats** - Any text-based output format you can template

### Cross-Organization Power

**A key strength of azdw** is its ability to query and report across multiple Azure DevOps organizations simultaneously - even across different Entra ID tenants. This makes it uniquely powerful for:

- **Consultants and contractors** working with multiple client organizations
- **Enterprise teams** with work spread across business units, subsidiaries, or acquisitions
- **Platform teams** supporting multiple product organizations
- **Portfolio managers** tracking initiatives across organizational boundaries
- **Distributed teams** collaborating across company boundaries

When you query without specifying an organization, azdw automatically:
- Queries **all configured connections** in parallel
- Unifies results in a single view with **Organization and Project columns**
- Handles partial failures gracefully (continues even if one org is unavailable)
- Supports **mixed authentication types** (PAT, OAuth Device Code, Interactive Browser)

All the automation examples in this document leverage this cross-organization capability to provide unified visibility across your entire work landscape.

## Template-Based Rendering

### Offline Work Item Analysis

Generate a review report from an existing `azdw.work-item-analysis` schema `1.0` document:

```bash
azdw report generate --template-id work-item-analysis-html --data analysis.json --output review.html
azdw visualize graph --from-file analysis.json --format graph --output analysis-graph.json
azdw visualize graph --from-file analysis.json --format graphml --output analysis-graph.graphml
```

Open the generated HTML directly in a browser. It includes summary counts, coverage warnings,
pair comparisons, evidence, relationship and consolidation proposals, clusters, and captured
configuration, glossary and guidance. Filter review entries by search text, classification,
review status, logical work item type or connection. Presentation and print modes use the same snapshot.

Accepted, rejected and deferred decisions and notes remain in page memory only. Export decisions
before closing or reloading the page. Import replaces the current annotations only after validating
the analysis ID, document fingerprint, decision schema, known entry IDs, statuses and notes.
These annotations are not authenticated audit records and never mutate work items or authorize writes.
There are no network requests, CDN dependencies or browser persistent storage.

The factory template is the real, editable [work-item-analysis-html.json](../config/templates/work-item-analysis-html.json)
file, with all HTML, CSS and JavaScript in its `content` string. Build and publish copy it with the
configuration files. An edited template can be supplied explicitly through `--template-id /path/to/template.json`;
custom templates with the same ID override the factory template. Retain the `offline` tag to suppress
automatic branding/font and signature injection. Do not add the `interactive` tag: that selects a different renderer.

Custom Scriban templates receive the full document as `analysis` (for example,
`analysis.pair_assessments` and `analysis.effective_configuration`), `analysis_json` containing
HTML-safe serialized JSON, and `analysis_fingerprint`. The factory template parses the safe JSON
and inserts snapshot text using DOM `textContent`, never raw HTML.

Existing item-list templates also receive `items`, preserving original numeric IDs, qualified `key`
identities and titles; `work_item_type` is the captured logical type. Uncaptured `assigned_to` and
`priority` values are null. Original snapshots remain available as `work_items`. All document sections
are also exposed at the root in snake_case: `scope`, `effective_configuration`, `coverage`, `warnings`,
`errors`, `observed_relationships`, `pair_assessments`, `relationship_proposals`, `consolidation_proposals`,
`clusters`, `evidence` and `policy_findings`.

Graph import checks the analysis discriminator before legacy query or closure shapes. `graph` JSON
and basic `graphml` preserve isolated nodes, distinct observed/assessment/proposed edges, unresolved
observations and cluster membership metadata. Synthetic graph IDs do not replace original qualified
keys or numeric work item IDs in the captured metadata. Clusters are not converted into parent links.
The existing `graphviz`, `mermaid-flowchart`, `mermaid-er`, `mermaid-requirement`, `mermaid-kanban`
and `mermaid-gantt` renderers also accept analysis input, with their existing format-specific limitations.
Use JSON or GraphML when full metadata matters. Cluster hull interaction and yEd-specific styling
are not provided for analysis GraphML. Legacy query and closure import paths remain available.

### Built-in Templates

The azdw CLI includes several built-in templates located in `config/templates/`:

| Template ID | Format | Description |
| ---------- | ------- | ----------- |
| `sprint-report-md` | Markdown | Comprehensive sprint report with completed, in-progress, and remaining work |
| `release-notes-md` | Markdown | Release notes categorized by features, bug fixes, and improvements |
| `team-dashboard-html` | HTML | Interactive dashboard with Chart.js visualizations and metrics |
| `work-items-export-csv` | CSV | Flexible data export with customizable columns |

### Using Templates

Generate reports using the `report generate` command:

```bash
# Generate a sprint report
azdw report generate \
  --template-id sprint-report-md \
  --output sprint-report.md \
  --param sprint_name="Sprint 2024.Q4" \
  --param avg_completion_days=3.5

# Generate an interactive HTML dashboard
azdw report generate \
  --template-id team-dashboard-html \
  --output dashboard.html \
  --param team_name="Platform Team"

# Export to CSV for analysis
azdw report generate \
  --template-id work-items-export-csv \
  --output work-items.csv \
  --param columns="id,title,state,assigned_to,priority"
```

### Custom Templates

Create your own templates by defining a JSON file with:

```json
{
  "id": "my-custom-report",
  "name": "My Custom Report",
  "description": "Custom report template",
  "engineType": "scriban",
  "content": "# {{ parameters.title }}\n\n{{~ for item in items ~}}\n- [{{ item.id }}]({{ item.url }}): {{ item.title }}\n{{~ end ~}}",
  "outputFormat": "markdown",
  "mimeType": "text/markdown",
  "fileExtension": ".md",
  "category": "Reports",
  "tags": ["custom", "report"],
  "parameters": {
    "title": {
      "name": "title",
      "displayName": "Report Title",
      "description": "Title for the report",
      "dataType": "string",
      "isRequired": true
    }
  },
  "defaultValues": {
    "title": "Work Items Report"
  },
  "isEnabled": true,
  "version": "1.0.0",
  "supportedDataTypes": ["WorkItem[]"]
}
```

> _**Note**: The Visual Studio Code extension [Escape Buster](https://marketplace.visualstudio.com/items?itemName=deng-wt.escape-buster) is very useful to review and edit the content string value._

Place your custom template in `config/templates/` and use it:

```bash
azdw report generate \
  --template-id my-custom-report \
  --output my-report.md \
  --param title="Weekly Status Report"
```

#### Importing Custom Templates

To create custom templates, use the `azdw report template import` command which supports both JSON metadata files and raw template content files (Markdown, HTML, etc.) with automatic detection:

**Basic Usage:**

```bash
# Import a template file with interactive prompts for metadata
azdw report template import --file ./my-report.md

# Import with all metadata specified (non-interactive)
azdw report template import --file ./my-dashboard.html \
  --template-id "custom-dashboard" \
  --template-name "Custom Team Dashboard" \
  --description "Interactive dashboard showing team metrics and progress" \
  --category "Dashboards" \
  --tags "dashboard,html,metrics,team" \
  --non-interactive
```

**What the Import Command Does:**

1. **Reads your template content** from any text file (Markdown, HTML, CSV template, etc.)
2. **Auto-detects file type** - JSON metadata file or raw template content
3. **Escapes content for JSON** - automatically handles:
   - Single backslashes → double backslashes (`\` → `\\`)
   - Double quotes → escaped quotes (`"` → `\"`)
   - Newlines → escaped newlines (`\n`)
   - Tab characters → escaped tabs (`\t`)
4. **Generates JSON metadata** in `config/templates/` with the proper structure
5. **Auto-detects settings** from file extension and filename
6. **Prompts for missing metadata** (or accepts command-line parameters)

**Command-Line Parameters:**

- **`--file`** (required): Path to your template file (JSON metadata or raw content)
- **`--template-id`**: Unique identifier (auto-generated from filename if omitted)
- **`--template-name`**: Display name (auto-generated from filename if omitted)
- **`--description`**: What the template generates (prompted if omitted)
- **`--category`**: Template category like "Dashboards", "Reports", "Release Management"
- **`--tags`**: Comma-separated tags for searching/filtering
- **`--author`**: Template author (defaults to "Azure DevOps Work Item Handler Library")
- **`--version`**: Template version (defaults to "1.0.0")
- **`--overwrite`** / **`-w`**: Overwrite existing template with same ID
- **`--non-interactive`**: Fail if metadata is missing instead of prompting (useful for CI/CD)
- **`-Force`**: Overwrite existing JSON file without prompting
- **`-Interactive`**: Run in interactive mode, prompting for all metadata

**Example Workflow:**

```bash
# 1. Create your Scriban template content in a .md file
cat > my-release-notes.md << 'EOF'
# Release {{ parameters.version }}

Released: {{ parameters.date }}

## Features
{{~ for item in items | where 'work_item_type == "Feature"' ~}}
- {{ item.title }} (#{{ item.id }})
{{~ end ~}}

## Bug Fixes
{{~ for item in items | where 'work_item_type == "Bug"' ~}}
- {{ item.title }} (#{{ item.id }})
{{~ end ~}}
EOF

# 2. Import the template
azdw report template import --file ./my-release-notes.md \
  --description "Generate release notes with features and bug fixes" \
  --category "Release Management" \
  --tags "release,notes,markdown" \
  --non-interactive

# 3. The command creates: config/templates/my-release-notes.json
# 4. You can now edit it to add parameter definitions

# 5. Use your new template
azdw report generate \
  --template-id my-release-notes \
  --param version="2.1.0" \
  --param date="2025-11-20" \
  --output release-2.1.0.md
```

**Why Use the Converter?**

- **Avoids manual JSON escaping errors** - no more fighting with backslashes and quotes
- **Faster template creation** - focus on template content, not JSON structure
- **Consistent metadata format** - ensures templates follow azdw conventions
- **Reduces errors** - automatic validation and proper JSON formatting
- **Simplifies iteration** - easy to modify template content and regenerate

**After Conversion:**

The generated JSON file will have the template content properly escaped and ready to use. You may want to:

1. **Add parameter definitions** to the `parameters` object for user inputs
2. **Set default values** in the `defaultValues` object
3. **Add sample input** describing the expected work item structure
4. **Test the template** with `azdw report generate --template-id <id> --help`

## Output Formats

### Markdown Reports

Perfect for documentation that can be committed to Git, rendered on GitHub/Azure DevOps, or converted to other formats:

```bash
# Sprint report with links and tables
# Query across ALL configured organizations - no --connection needed!
azdw query \
  --assigned-to "@me" \
  --state Active Resolved \
  | azdw report generate \
      --template-id sprint-report-md \
      --output sprint-report.md
```

**Example Output:**
```markdown
# Sprint Report

**Sprint:** Sprint 2024.Q4
**Generated:** 2025-10-23 08:00:00 UTC
**Total Items:** 15

## Sprint Summary

- **Completed:** 8 items
- **In Progress:** 5 items
- **Not Started:** 2 items

## Completed Work

| ID | Title | Type | Assignee |
|----|-------|------|----------|
| [1234](https://dev.azure.com/...) | Implement OAuth2 | User Story | John Doe |
```

### Self-Contained HTML

Generate fully self-contained HTML files with embedded CSS and JavaScript for interactive dashboards. This example showcases querying across multiple organizations and tenants:

```bash
# Query across ALL configured organizations and tenants
# Results are automatically unified with Org/Project columns
azdw query \
  --state Active,"In Progress",Resolved \
  | azdw report generate \
      --template-id team-dashboard-html \
      --output dashboard.html \
      --param team_name="Cross-Organization Dashboard"

# Or query specific organizations if needed (comma-separated)
azdw query \
  --connections CompanyA,CompanyB,ClientX \
  --state Active \
  | azdw report generate \
      --template-id team-dashboard-html \
      --output multi-org-dashboard.html \
      --param team_name="Multi-Org Platform Team"
```

**Features:**
- Embedded Chart.js for interactive visualizations (pie charts, bar charts)
- Responsive design that works on desktop and mobile
- No external dependencies - can be opened directly in any browser
- Real-time filtering and sorting capabilities via JavaScript

**Example Dashboard Elements:**
- Total items, completed items, in-progress items
- Completion rate percentage
- Work items by state (pie chart)
- Work items by type (bar chart)
- Recent activity table with links to Azure DevOps

### GraphViz Visualizations

Generate hierarchy and dependency visualizations using the GraphViz DOT format (`.dot` files) or D3.js JSON format (`.json` files). This is especially powerful when visualizing work items that span **multiple organizations**, showing the complete picture of cross-organizational dependencies.

#### DOT Format Visualization (.dot files)

DOT files can be rendered as images using GraphViz:

```bash
# First, query across ALL organizations to find your work items
azdw query \
  --assigned-to "@me" \
  --types Epic Feature \
  --json > my-work-items.json

# Extract work item IDs from the cross-org query results
WORK_ITEM_IDS=$(jq -r '.workItems[].id' my-work-items.json | head -5 | tr '\n' ' ')

# Generate work item hierarchy visualization (tree layout) with depth control
# This will show relationships even across organizational boundaries
azdw visualize graph \
  --ids ${WORK_ITEM_IDS} \
  --connection MyPrimaryOrg \
  --format graphviz \
  --layout tree \
  --max-depth 3 \
  --show-legend \
  --output hierarchy.dot

# Convert to PNG using GraphViz
dot -Tpng hierarchy.dot -o hierarchy.png

# Or generate SVG for web embedding (ideal for documentation)
dot -Tsvg hierarchy.dot -o hierarchy.svg

# For cross-organizational network visualization with grouping
# Note: Cross-connection relationship resolution is enabled by default
azdw visualize graph \
  --ids ${WORK_ITEM_IDS} \
  --connection MyPrimaryOrg \
  --format graphviz \
  --layout network \
  --max-depth 2 \
  --by-conn \
  --output network.dot

# Render network visualization
dot -Tpng network.dot -o network.png
```

**Cross-Organization Visualization Example:**
```bash
#!/bin/bash
# visualize-cross-org-dependencies.sh

# Query all organizations for your active work
echo "Querying across all organizations..."
azdw query \
  --assigned-to "@me" \
  --types Epic Feature "User Story" \
  --states Active "In Progress" \
  --json > all-orgs-work.json

# Get the top 10 work items to visualize
ITEM_IDS=$(jq -r '.workItems | sort_by(.priority) | .[0:10] | .[].id' all-orgs-work.json | tr '\n' ' ')

echo "Generating visualization for items: ${ITEM_IDS}"

# Create hierarchy visualization with advanced options
# Note: Cross-connection relationship resolution is enabled by default
azdw visualize graph \
  --ids ${ITEM_IDS} \
  --connection MyPrimaryOrg \
  --format graphviz \
  --layout tree \
  --max-depth 2 \
  --show-legend \
  --title "Cross-Organization Work Item Dependencies" \
  --output cross-org-hierarchy.dot

# Render to multiple formats
dot -Tpng cross-org-hierarchy.dot -o cross-org-hierarchy.png
dot -Tsvg cross-org-hierarchy.dot -o cross-org-hierarchy.svg
dot -Tpdf cross-org-hierarchy.dot -o cross-org-hierarchy.pdf

echo "Visualizations generated:"
echo "  - cross-org-hierarchy.png (for presentations)"
echo "  - cross-org-hierarchy.svg (for web/documentation)"
echo "  - cross-org-hierarchy.pdf (for reports)"

# Automatically open the PNG
open cross-org-hierarchy.png  # macOS
```

#### JSON Format Visualization (.json files)

JSON files are designed for web-based visualization tools like D3.js, Gephi, or other graph visualization libraries. Unlike DOT files, JSON files are **not auto-rendered** to images by azdw - they must be used with visualization tools or web applications.

```bash
# Generate JSON graph for D3.js visualization
# Note: Cross-connection relationship resolution is enabled by default
azdw visualize graph \
  --ids ${WORK_ITEM_IDS} \
  --connection MyPrimaryOrg \
  --format graph \
  --by-conn \
  --output network.json

# The JSON output includes:
# - nodes: Array of work items with id, name, type, group, metadata
# - links: Array of relationships with source, target, type, metadata

# Use this JSON file with D3.js force-directed graphs, Gephi, or custom web apps
```

**JSON Structure:**
```json
{
  "nodes": [
    {
      "id": "12345",
      "name": "Epic: Platform Migration",
      "type": "Epic",
      "group": 0,
      "metadata": {
        "state": "Active",
        "assignedTo": "user@example.com",
        "project": "MyProject",
        "organization": "MyOrg",
        "webUrl": "https://dev.azure.com/..."
      }
    }
  ],
  "links": [
    {
      "source": "12345",
      "target": "12346",
      "type": "Parent",
      "value": 1,
      "metadata": {
        "isCrossConnection": false,
        "sourceOrg": "MyOrg",
        "targetOrg": "MyOrg"
      }
    }
  ]
}
```

**Query-Based Visualization:**

You can also generate visualizations directly from query filters without needing to specify work item IDs:

```bash
# Visualize all active bugs in a tree layout
azdw visualize graph \
  --types Bug \
  --states Active \
  --format graphviz \
  --layout tree \
  --output bugs-tree.dot

# Render to PNG
dot -Tpng bugs-tree.dot -o bugs-tree.png

# Visualize all epics and features in JSON format
# Note: Cross-connection relationship resolution is enabled by default
azdw visualize graph \
  --types Epic Feature \
  --states Active \
  --format graph \
  --by-conn \
  --output epics-features.json
```

#### GraphML Format Visualization (.graphml files)

GraphML is an XML-based format designed for professional graph visualization and analysis tools. It provides excellent compatibility with tools like **yEd Graph Editor**, **Gephi**, **Cytoscape**, and other graph analysis software. GraphML supports rich metadata, node grouping, and when using the `--optimize-for-yed` option, includes yEd-specific styling for immediate visual impact.

```bash
# Generate GraphML for yEd Graph Editor
# Note: Cross-connection relationship resolution is enabled by default
azdw visualize graph \
  --ids ${WORK_ITEM_IDS} \
  --connection MyPrimaryOrg \
  --format graphml \
  --optimize-for-yed \
  --by-conn \
  --output dependencies.graphml

# Open in yEd Graph Editor (macOS/Windows/Linux)
# Apply hierarchical layout for best results with dependency graphs
```

**Standard GraphML (without yEd optimization):**
```bash
# Generate standard GraphML for any compatible tool
# Note: Cross-connection relationship resolution is enabled by default
azdw visualize graph \
  --ids ${WORK_ITEM_IDS} \
  --format graphml \
  --output network.graphml

# Compatible with Gephi, Cytoscape, NetworkX, and other tools
```

**GraphML Structure:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"
         xmlns:y="http://www.yworks.com/xml/graphml">
  <!-- Attribute definitions for nodes and edges -->
  <key id="d0" for="node" attr.name="label" attr.type="string"/>
  <key id="d1" for="node" attr.name="workItemType" attr.type="string"/>
  <key id="d2" for="edge" attr.name="relationshipType" attr.type="string"/>
  
  <graph id="G" edgedefault="directed">
    <node id="n12345">
      <data key="d0">Epic: Platform Migration</data>
      <data key="d1">Epic</data>
      <!-- yEd-specific styling when --optimize-for-yed is used -->
      <data key="d6">
        <y:ShapeNode>
          <y:Geometry height="40" width="200"/>
          <y:Fill color="#773B93"/>
          <y:NodeLabel>Epic: Platform Migration</y:NodeLabel>
          <y:Shape type="roundrectangle"/>
        </y:ShapeNode>
      </data>
    </node>
    <edge id="e1" source="n12345" target="n12346">
      <data key="d2">Child</data>
    </edge>
  </graph>
</graphml>
```

**Key Features:**
- **XML-based format**: Human-readable and easily parseable
- **Rich metadata**: Work item type, state, assigned user, organization, and URLs
- **Node grouping**: Related work items grouped by organization/project
- **yEd optimization**: Color-coded work item types with professional styling
- **Bidirectional edges**: Collapsed for cleaner visualizations
- **Cross-organization support**: Full metadata for external relationships

**yEd Graph Editor Workflow:**
1. Generate GraphML with `--optimize-for-yed` for pre-styled nodes
2. Open the `.graphml` file in yEd
3. Apply a layout algorithm (Layout → Hierarchical or Organic)
4. Adjust as needed and export to PNG/SVG/PDF

#### Format Comparison

Choose the right visualization format based on your use case:

| Feature | GraphViz (DOT) | D3/Gephi (JSON) | GraphML |
| -------- | ------------- | --------------- | ------- |
| **File Extension** | `.dot` | `.json` | `.graphml` |
| **Format Type** | Text | JSON | XML |
| **Image Rendering** | ✅ Direct (via `dot`) | ❌ Web tools only | ❌ Via yEd/Gephi |
| **Interactive Web** | ❌ Static images | ✅ D3.js, web apps | ⚠️ Limited |
| **Professional Tools** | ⚠️ GraphViz only | ✅ Gephi, custom | ✅ yEd, Gephi, Cytoscape |
| **Rich Metadata** | ⚠️ Labels only | ✅ Full JSON | ✅ Full XML attributes |
| **Styled Output** | ⚠️ Basic colors | ❌ Style in app | ✅ yEd optimization |
| **Node Grouping** | ⚠️ Subgraphs | ⚠️ Manual | ✅ Native support |
| **Best For** | Quick diagrams, CI/CD | Web dashboards | Professional analysis |

**Recommended Workflows:**

| Goal | Recommended Format | Reason |
| ----- | ---------------- | ------- |
| Quick PNG/SVG for docs | `graphviz` | Direct rendering with `dot` command |
| Interactive web dashboard | `graph` (JSON) | Native D3.js compatibility |
| Detailed analysis in yEd | `graphml --optimize-for-yed` | Pre-styled, professional output |
| Import into Gephi | `graphml` or `graph` | Both supported, GraphML has better metadata |
| Network analysis tools | `graphml` | Standard format, rich attributes |
| Automated CI/CD reports | `graphviz` | Simple pipeline integration |

#### Summary

The generated files can be used as follows:

**DOT files (`.dot`)**:
- Rendered to images (PNG, SVG, PDF) using GraphViz
- Embedded in documentation (SVG works great in Markdown)
- Viewed in GraphViz-compatible tools
- Shared in reports to visualize cross-organizational dependencies
- Best for: **Quick diagrams, CI/CD pipelines, automated reports**

**JSON files (`.json`)**:
- Loaded into D3.js for interactive web visualizations
- Imported into Gephi for network analysis
- Used with custom web applications
- Processed with graph analysis tools
- **Not auto-rendered** - requires visualization tools
- Best for: **Web dashboards, interactive exploration**

**GraphML files (`.graphml`)**:
- Opened in yEd Graph Editor for professional diagram editing
- Imported into Gephi for advanced network analysis
- Used with Cytoscape for biological/network research
- Processed with NetworkX (Python) for programmatic analysis
- Supports rich metadata and node grouping
- When using `--optimize-for-yed`: color-coded, styled output ready for presentation
- Best for: **Professional analysis, detailed editing, publication-quality diagrams**

### Mermaid Visualizations

Generate Mermaid diagram syntax that can be rendered in GitHub, GitLab, documentation tools, and any Mermaid-compatible viewer. Mermaid is particularly powerful for embedding diagrams directly in Markdown documentation.

#### Flowchart Diagrams

Visualize work item hierarchies and relationships as Mermaid flowcharts:

```bash
# Generate flowchart showing work item hierarchy
azdw visualize graph \
  --ids 12345 67890 \
  --connection MyOrg \
  --format mermaid \
  --direction TB \
  --show-legend \
  --title "Sprint Work Items" \
  --output hierarchy.mmd

# The output is Mermaid syntax that can be embedded in Markdown:
# ```mermaid
# ---
# title: Sprint Work Items
# ---
# flowchart TB
#     WI12345["[Epic] Implement feature..."]
#     WI67890["[Feature] Add API..."]
#     WI12345 -->|Child| WI67890
# ```
```

**Flowchart Options:**
- `--direction`: Layout direction (`TB` top-bottom, `LR` left-right, `BT`, `RL`)
- `--show-legend`: Include a legend subgraph with work item type styling

#### Entity-Relationship Diagrams

Visualize work item relationships as ER diagrams:

```bash
# Generate ER diagram showing relationships between work items
azdw visualize graph \
  --ids 12345 67890 \
  --connection MyOrg \
  --format mermaid-er \
  --title "Work Item Relationships" \
  --output relationships.mmd

# Output:
# erDiagram
#     EPIC_12345 {
#         string title "Implement feature..."
#         string state "Active"
#     }
#     FEATURE_67890 {
#         string title "Add API..."
#         string state "New"
#     }
#     EPIC_12345 ||--o{ FEATURE_67890 : "child"
```

#### Requirement Diagrams

Visualize traceability between requirements, tests, and design elements:

```bash
# Generate requirement diagram showing traceability
azdw visualize graph \
  --ids 12345 \
  --connection MyOrg \
  --format mermaid-requirement \
  --max-depth 3 \
  --title "Traceability Matrix" \
  --output traceability.mmd

# Output:
# requirementDiagram
#     requirement EPIC_12345 {
#         id: 12345
#         text: Implement feature...
#         risk: low
#         verifymethod: analysis
#     }
#     functionalRequirement FEATURE_67890 {
#         id: 67890
#         text: Add API endpoint
#     }
#     EPIC_12345 - derives -> FEATURE_67890
```

#### Embedding in Documentation

Mermaid diagrams integrate seamlessly with documentation platforms:

**GitHub/GitLab Markdown:**
```markdown
# Architecture Overview

Below is the current work item hierarchy:

​```mermaid
flowchart TB
    WI12345["[Epic] Platform Modernization"]
    WI67890["[Feature] API Gateway"]
    WI12345 -->|Child| WI67890
​```
```

**Automated Documentation Pipeline:**
```bash
#!/bin/bash
# update-architecture-docs.sh

# Generate current hierarchy diagram
azdw visualize graph \
  --connection MyOrg \
  --type Epic Feature \
  --states Active \
  --format mermaid \
  --title "Active Architecture Work" \
  > docs/diagrams/architecture-current.mmd

# Embed in documentation (requires preprocessing or Mermaid CLI)
# For static sites, use mermaid-cli to pre-render to SVG:
mmdc -i docs/diagrams/architecture-current.mmd -o docs/images/architecture.svg
```

### CSV Data Export

Export structured data for analysis in Excel, Google Sheets, or data analysis tools. The cross-organization capability makes this especially powerful for portfolio management:

```bash
# Export all active bugs across ALL organizations
# Perfect for enterprise-wide bug tracking and reporting
azdw query \
  --type Bug \
  --state Active \
  --output csv \
  > bugs-active-all-orgs.csv

# The CSV includes Organization and Project columns automatically
# Great for pivot tables and cross-org analysis

# Or use a template for more control over columns
azdw query \
  --assigned-to "@me" \
  --json \
| azdw report generate \
  --template-id work-items-export-csv \
  --output my-work-all-orgs.csv \
  --param columns="organization,project,id,title,state,priority,assigned_to,created_date"
```

### Excel Export with ImportExcel Module

For advanced Excel reporting with formatted worksheets, charts, and pivot tables, you can combine the Azdw PowerShell module with the **ImportExcel** module. This is especially powerful for cross-organization work item analysis and executive reporting.

#### Prerequisites

First, install the ImportExcel module (if not already installed):

```powershell
# Install ImportExcel module from PowerShell Gallery
Install-Module -Name ImportExcel -Scope CurrentUser -Force

# Import both modules
Import-Module azdw.pwsh
Import-Module ImportExcel
```

#### Basic Excel Export

Export query results to a formatted Excel workbook:

```powershell
# Query work items across all organizations and export to Excel
Get-AzdwWorkItem -AssignedTo "@me" -State Active, "In Progress" |
  Export-Excel -Path "my-work-items.xlsx" `
    -AutoSize `
    -TableName "WorkItems" `
    -TableStyle Medium2 `
    -Show

# Query specific organizations with custom properties
Get-AzdwWorkItem -Connection "CompanyA", "CompanyB" `
  -Type Bug, Task `
  -State Active |
  Select-Object Organization, Project, Id, Title, State, AssignedTo, Priority, CreatedDate |
  Export-Excel -Path "cross-org-bugs-tasks.xlsx" `
    -WorksheetName "Active Items" `
    -AutoSize `
    -FreezeTopRow `
    -BoldTopRow `
    -Show
```

#### Multi-Sheet Workbooks

Create workbooks with multiple worksheets for different views:

```powershell
# Create a comprehensive cross-organization workbook
$excelPath = "cross-org-analysis-$(Get-Date -Format 'yyyy-MM-dd').xlsx"

# Sheet 1: All active work items across all organizations
Get-AzdwWorkItem -State Active |
  Select-Object Organization, Project, Id, Title, WorkItemType, State, AssignedTo, Priority |
  Export-Excel -Path $excelPath `
    -WorksheetName "All Active Items" `
    -AutoSize `
    -TableStyle Medium6

# Sheet 2: High priority items only
Get-AzdwWorkItem -State Active, "In Progress" |
  Where-Object { $_.Priority -le 2 } |
  Select-Object Organization, Project, Id, Title, State, AssignedTo, Priority, CreatedDate |
  Export-Excel -Path $excelPath `
    -WorksheetName "High Priority" `
    -AutoSize `
    -TableStyle Medium9 `
    -ConditionalText $(
      New-ConditionalText -Text "1" -Range "G:G" -BackgroundColor Red -ConditionalTextColor White
      New-ConditionalText -Text "2" -Range "G:G" -BackgroundColor Orange
    )

# Sheet 3: Bugs grouped by organization
Get-AzdwWorkItem -Type Bug -State Active, New |
  Select-Object Organization, Project, Id, Title, State, Severity, AssignedTo |
  Export-Excel -Path $excelPath `
    -WorksheetName "Active Bugs" `
    -AutoSize `
    -TableStyle Light11

# Sheet 4: Summary statistics
$allItems = Get-AzdwWorkItem -State Active, "In Progress", Resolved
$summary = $allItems | Group-Object Organization | Select-Object @{
  Name='Organization'; Expression={$_.Name}
}, @{
  Name='TotalItems'; Expression={$_.Count}
}, @{
  Name='ActiveItems'; Expression={($_.Group | Where-Object State -eq 'Active').Count}
}, @{
  Name='InProgress'; Expression={($_.Group | Where-Object State -eq 'In Progress').Count}
}, @{
  Name='Resolved'; Expression={($_.Group | Where-Object State -eq 'Resolved').Count}
}

$summary | Export-Excel -Path $excelPath `
  -WorksheetName "Summary by Org" `
  -AutoSize `
  -TableStyle Medium15 `
  -Show  # Open the workbook when complete
```

#### Advanced Formatting with Charts

Create Excel reports with embedded charts and conditional formatting:

```powershell
# Generate executive dashboard with charts
$excelPath = "executive-dashboard-$(Get-Date -Format 'yyyy-MM-dd').xlsx"

# Get cross-organization work items
$workItems = Get-AzdwWorkItem -State Active, "In Progress", Resolved, Closed `
  | Select-Object Organization, Project, WorkItemType, State, Priority, AssignedTo

# Export with chart
$workItems | Export-Excel -Path $excelPath `
  -WorksheetName "Work Items" `
  -AutoSize `
  -TableStyle Medium2 `
  -IncludePivotTable `
  -PivotTableName "OrgStatePivot" `
  -PivotRows Organization, State `
  -PivotData @{State='Count'} `
  -IncludePivotChart `
  -ChartType ColumnClustered `
  -ChartTitle "Work Items by Organization and State" `
  -Show

# Alternative: Create custom chart with more control
$chartDef = New-ExcelChartDefinition `
  -XRange "WorkItems[Organization]" `
  -YRange "WorkItems[State]" `
  -ChartType BarClustered `
  -Title "Cross-Organization Work Distribution" `
  -Column 10 `
  -Row 2 `
  -Width 600 `
  -Height 400

$workItems | Export-Excel -Path "detailed-chart.xlsx" `
  -WorksheetName "WorkItems" `
  -AutoSize `
  -TableName "WorkItems" `
  -ExcelChartDefinition $chartDef `
  -Show
```

#### Cross-Connection Report Script

Here's a complete script for generating a comprehensive cross-organization Excel report:

```powershell
#!/usr/bin/env pwsh
# generate-cross-org-excel-report.ps1

param(
    [string]$OutputPath = "work-item-report-$(Get-Date -Format 'yyyy-MM-dd').xlsx",
    [string[]]$Connections = @(),  # Empty = all connections
    [switch]$OpenWhenComplete
)

# Import required modules
Import-Module azdw.pwsh -ErrorAction Stop
Import-Module ImportExcel -ErrorAction Stop

Write-Host "Generating cross-organization work item report..." -ForegroundColor Cyan

# Build query parameters
$queryParams = @{
    State = @('Active', 'In Progress', 'Resolved')
}

if ($Connections.Count -gt 0) {
    $queryParams['Connection'] = $Connections
    Write-Host "Querying connections: $($Connections -join ', ')" -ForegroundColor Yellow
} else {
    Write-Host "Querying ALL configured connections" -ForegroundColor Yellow
}

# Fetch work items
Write-Host "Fetching work items..." -ForegroundColor Gray
$allWorkItems = Get-AzdwWorkItem @queryParams

# Sheet 1: All work items
Write-Host "Creating 'All Items' worksheet..." -ForegroundColor Gray
$allWorkItems |
  Select-Object Organization, Project, Id, Title, WorkItemType, State, `
                AssignedTo, Priority, CreatedDate, ChangedDate |
  Export-Excel -Path $OutputPath `
    -WorksheetName "All Items" `
    -AutoSize `
    -FreezeTopRow `
    -BoldTopRow `
    -TableStyle Medium2

# Sheet 2: By organization summary
Write-Host "Creating 'By Organization' worksheet..." -ForegroundColor Gray
$orgSummary = $allWorkItems | Group-Object Organization | ForEach-Object {
    [PSCustomObject]@{
        Organization = $_.Name
        TotalItems = $_.Count
        Active = ($_.Group | Where-Object State -eq 'Active').Count
        InProgress = ($_.Group | Where-Object State -eq 'In Progress').Count
        Resolved = ($_.Group | Where-Object State -eq 'Resolved').Count
        Bugs = ($_.Group | Where-Object WorkItemType -eq 'Bug').Count
        Tasks = ($_.Group | Where-Object WorkItemType -eq 'Task').Count
        UserStories = ($_.Group | Where-Object WorkItemType -eq 'User Story').Count
    }
}

$orgSummary | Export-Excel -Path $OutputPath `
    -WorksheetName "By Organization" `
    -AutoSize `
    -TableStyle Medium6 `
    -ConditionalText $(
        New-ConditionalText -Range "F:F" -ConditionalType GreaterThan 0 `
          -BackgroundColor LightPink
    )

# Sheet 3: High priority items
Write-Host "Creating 'High Priority' worksheet..." -ForegroundColor Gray
$allWorkItems |
  Where-Object { $_.Priority -le 2 } |
  Select-Object Organization, Project, Id, Title, WorkItemType, State, Priority, AssignedTo |
  Export-Excel -Path $OutputPath `
    -WorksheetName "High Priority" `
    -AutoSize `
    -TableStyle Medium9 `
    -ConditionalText $(
        New-ConditionalText -Text "1" -Range "G:G" `
          -BackgroundColor Red -ConditionalTextColor White
        New-ConditionalText -Text "2" -Range "G:G" `
          -BackgroundColor Orange
    )

# Sheet 4: Bugs only
Write-Host "Creating 'Bugs' worksheet..." -ForegroundColor Gray
$allWorkItems |
  Where-Object WorkItemType -eq 'Bug' |
  Select-Object Organization, Project, Id, Title, State, Severity, AssignedTo, CreatedDate |
  Export-Excel -Path $OutputPath `
    -WorksheetName "Bugs" `
    -AutoSize `
    -TableStyle Light11

Write-Host "Report generated: $OutputPath" -ForegroundColor Green
Write-Host "Total work items: $($allWorkItems.Count)" -ForegroundColor Cyan

if ($OpenWhenComplete) {
    Write-Host "Opening workbook..." -ForegroundColor Gray
    Invoke-Item $OutputPath
}
```

**Usage examples:**

```powershell
# Generate report for all organizations and open it
./generate-cross-org-excel-report.ps1 -OpenWhenComplete

# Generate report for specific organizations
./generate-cross-org-excel-report.ps1 `
  -Connections "CompanyA", "ClientB", "PartnerC" `
  -OutputPath "multi-tenant-report.xlsx" `
  -OpenWhenComplete

# Schedule daily report generation (add to Task Scheduler or cron)
./generate-cross-org-excel-report.ps1 `
  -OutputPath "C:\Reports\daily-$(Get-Date -Format 'yyyy-MM-dd').xlsx"
```

#### Tips and Best Practices

1. **Use `-AutoSize`** for readable columns, but test with large datasets as it can slow down generation
2. **Apply `-FreezeTopRow` and `-BoldTopRow`** for better navigation in large datasets
3. **Use `-TableStyle`** for professional-looking tables (options: Light1-21, Medium1-28, Dark1-11)
4. **Leverage `-ConditionalText`** to highlight critical items (high priority, bugs, overdue)
5. **Create pivot tables** with `-IncludePivotTable` for executive summaries
6. **Use `-IncludePivotChart`** for visual dashboards
7. **Test with `-Show`** during development to immediately see results
8. **Schedule** regular report generation using Task Scheduler (Windows) or cron (macOS/Linux)

#### See Also

- [ImportExcel Module Documentation](https://github.com/dfinke/ImportExcel)
- [Azdw PowerShell Module](../src/azdw.pwsh/README.md)
- [CSV Data Export](#csv-data-export) - For simpler exports without Excel dependency

## Automation Workflows

### Example: Daily Work Item Report

Create a shell script that generates and opens a daily report automatically. This example demonstrates the power of **cross-organization querying** - a key strength of azdw that allows you to see all your work items across multiple Azure DevOps organizations in a single unified view.

**Script: `daily-report.sh`**
```bash
#!/bin/bash
set -e

# Configuration
REPORT_DATE=$(date +%Y-%m-%d)
REPORT_FILE="$HOME/work-reports/daily-report-${REPORT_DATE}.html"
TEAM_NAME="My Work Across All Organizations"

# Create reports directory if it doesn't exist
mkdir -p "$HOME/work-reports"

# Generate the daily report
echo "Generating daily work item report for ${REPORT_DATE}..."
echo "Querying across all configured organizations..."

# Query across ALL organizations - this is the power of azdw!
# No need to specify --connection, it queries all by default
# Results include Organization and Project columns for easy identification
azdw query \
  --assigned-to "@me" \
  --changed-date "$(date -v-1d +%Y-%m-%d)..${REPORT_DATE}" \
  --json \
| azdw report generate \
  --template-id team-dashboard-html \
  --param team_name="${TEAM_NAME}" \
  --output "${REPORT_FILE}"

# Open the report in the default browser
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  open "${REPORT_FILE}"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  xdg-open "${REPORT_FILE}"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
  # Windows (Git Bash, Cygwin)
  start "${REPORT_FILE}"
fi

echo "Report generated: ${REPORT_FILE}"
echo "Dashboard includes work items from all your Azure DevOps organizations!"
```

**Make the script executable:**
```bash
chmod +x daily-report.sh
```

### Scheduling with Cron (macOS/Linux)

Configure the script to run automatically at 8 AM every weekday:

```bash
# Open crontab editor
crontab -e

# Add this line to run at 8 AM Monday-Friday
0 8 * * 1-5 /path/to/daily-report.sh >> /tmp/daily-report.log 2>&1
```

**Cron Schedule Syntax:**
```
* * * * * command
│ │ │ │ │
│ │ │ │ └─── Day of week (0-7, Sun=0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

**Common Schedules:**
- `0 8 * * *` - Daily at 8 AM
- `0 8 * * 1-5` - Weekdays at 8 AM
- `0 9,17 * * 1-5` - Weekdays at 9 AM and 5 PM
- `0 8 * * 1` - Every Monday at 8 AM

### Scheduling with launchd (macOS)

For more reliable scheduling on macOS, use launchd:

**Create: `~/Library/LaunchAgents/com.mycompany.daily-report.plist`**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mycompany.daily-report</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/daily-report.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>8</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/daily-report.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/daily-report.err</string>
</dict>
</plist>
```

**Load the launch agent:**
```bash
launchctl load ~/Library/LaunchAgents/com.mycompany.daily-report.plist
```

### Scheduling with Task Scheduler (Windows)

**PowerShell Script: `daily-report.ps1`**
```powershell
$ReportDate = Get-Date -Format "yyyy-MM-dd"
$ReportFile = "$env:USERPROFILE\work-reports\daily-report-$ReportDate.html"
$TeamName = "Platform Team"

# Create reports directory
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\work-reports" | Out-Null

# Generate report
Write-Host "Generating daily work item report for $ReportDate..."

azdw query `
  --connection "MyOrg" `
  --project "MyProject" `
  --assigned-to "@me" `
  --json `
| azdw report generate `
  --template-id team-dashboard-html `
  --param team_name="$TeamName" `
  --output "$ReportFile"

# Open in default browser
Start-Process "$ReportFile"

Write-Host "Report generated: $ReportFile"
```

**Create scheduled task:**
```powershell
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File `"C:\path\to\daily-report.ps1`""
$Trigger = New-ScheduledTaskTrigger -Daily -At 8:00AM
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
Register-ScheduledTask -TaskName "DailyWorkItemReport" -Action $Action -Trigger $Trigger -Settings $Settings
```

## Advanced Use Cases

### Weekly Sprint Retrospective

Generate a comprehensive sprint report every Friday across all your organizations:

```bash
#!/bin/bash
# weekly-sprint-report.sh

SPRINT_NAME="Sprint $(date +%Y.W%V)"
REPORT_FILE="sprint-retrospective-$(date +%Y-W%V).md"

# Query across ALL organizations for sprint work
# Useful when you work on multiple teams/orgs simultaneously
azdw query \
  --assigned-to "@me" \
  --changed-date "$(date -v-7d +%Y-%m-%d)..$(date +%Y-%m-%d)" \
  --json \
| azdw report generate \
  --template-id sprint-report-md \
  --param sprint_name="${SPRINT_NAME}" \
  --output "${REPORT_FILE}"

# Optionally commit to Git
git add "${REPORT_FILE}"
git commit -m "Sprint retrospective: ${SPRINT_NAME} (across all organizations)"
git push
```

### Release Notes Generation

Automatically generate release notes when tagging a release. This is especially powerful when your release spans work items across multiple Azure DevOps organizations:

```bash
#!/bin/bash
# generate-release-notes.sh

VERSION="${1:-v1.0.0}"
RELEASE_DATE=$(date +%Y-%m-%d)

# Query across all organizations for release-tagged items
# Perfect for releases that involve work from multiple teams/orgs
azdw query \
  --tag "release:${VERSION}" \
  --json \
| azdw report generate \
  --template-id release-notes-md \
  --param version="${VERSION}" \
  --param release_date="${RELEASE_DATE}" \
  --output "RELEASE-NOTES-${VERSION}.md"

echo "Release notes generated for ${VERSION}"
echo "Includes work items from all configured organizations"
```

### Team Dashboard Auto-Refresh

Create a dashboard that updates every hour during work hours, showing work across all organizations:

```bash
#!/bin/bash
# hourly-dashboard-refresh.sh

DASHBOARD_FILE="/var/www/html/team-dashboard.html"

# Query ALL organizations - great for teams working across
# multiple Azure DevOps instances, clients, or business units
azdw query \
  --state New Active "In Progress" Resolved \
  --json \
| azdw report generate \
  --template-id team-dashboard-html \
  --param team_name="Enterprise Platform Team (All Orgs)" \
  --output "${DASHBOARD_FILE}"

# Cron: 0 9-18 * * 1-5 /path/to/hourly-dashboard-refresh.sh
# Dashboard automatically shows Organization and Project columns
```

### Multi-Tenant Cross-Organization Report

Aggregate work items across multiple organizations and even different Entra ID tenants - this showcases azdw's unique ability to unify work across organizational boundaries:

```bash
#!/bin/bash
# multi-tenant-report.sh

REPORT_FILE="cross-tenant-report-$(date +%Y-%m-%d).html"

echo "Querying across all organizations and tenants..."
echo "This may include:"
echo "  - Your company's internal Azure DevOps"
echo "  - Client organizations"
echo "  - Partner/vendor organizations"
echo "  - Different Entra ID tenants"

# Query returns integrated view by default
# Each work item shows its Organization and Project for easy identification
# Works across PAT, OAuth Device Code, and Interactive Browser auth
azdw query \
  --assigned-to "@me" \
  --state Active "In Progress" Resolved \
  --json \
| azdw report generate \
  --template-id team-dashboard-html \
  --param team_name="Multi-Tenant Cross-Organization View" \
  --output "${REPORT_FILE}"

open "${REPORT_FILE}"

echo "Report generated with work items from all configured connections!"
echo "Dashboard includes Organization and Project columns for context."
```

## Best Practices

### 1. Use Version Control for Templates

Store your custom templates in Git to track changes and share with your team:

```bash
git add config/templates/my-custom-report.json
git commit -m "Add custom weekly report template"
```

### 2. Parameterize Your Scripts

Make scripts reusable with parameters. Take advantage of azdw's ability to query all orgs by default, or specific ones when needed:

```bash
#!/bin/bash
# Optional: specify organizations, or leave empty to query all
ORGANIZATIONS="${1:-}"  # Empty means query all configured orgs
TEAM_NAME="${2:-Cross-Organization Team}"

if [ -z "${ORGANIZATIONS}" ]; then
  echo "Querying ALL configured organizations..."
  azdw query --assigned-to "@me" --json
else
  echo "Querying specific organizations: ${ORGANIZATIONS}"
  azdw query \
    --connection "${ORGANIZATIONS}" \
    --assigned-to "@me" \
    --json
fi | azdw report generate \
  --template-id team-dashboard-html \
  --param team_name="${TEAM_NAME}" \
  --output report.html
```

### 3. Handle Errors Gracefully

Add error handling to automation scripts:

```bash
#!/bin/bash
set -e  # Exit on error

# Trap errors
trap 'echo "Error generating report"; exit 1' ERR

azdw query ... || {
  echo "Query failed"
  exit 1
}
```

### 4. Log Automation Runs

Keep logs for troubleshooting:

```bash
LOG_FILE="/var/log/azdw-reports.log"

{
  echo "$(date): Starting report generation"
  azdw report generate ...
  echo "$(date): Report completed"
} >> "${LOG_FILE}" 2>&1
```

### 5. Use JSON for Piping

When chaining commands, use JSON format for reliable data flow:

```bash
azdw query --json \
| jq '.[] | select(.priority == "1")' \
| azdw report generate --template-id high-priority-report
```

### 6. Secure Credentials

Never hardcode credentials in scripts. Use the azdw credential management for all your connections:

```bash
# Add credentials for multiple organizations
azdw credential add --connection MyCompanyOrg
azdw credential add --connection ClientAOrg
azdw credential add --connection ClientBOrg

# For OAuth across tenants, specify auth type
azdw credential add --connection MultiTenantOrg --auth-type interactive

# Scripts use stored credentials automatically
# Query across all organizations without specifying credentials
azdw query --assigned-to "@me"
```

## Troubleshooting

### Report Generation Fails

```bash
# Enable verbose logging
azdw report generate --template-id my-template --verbose

# Check template syntax
azdw report template validate --template-id my-template
```

### Browser Doesn't Open

```bash
# Test file permissions
ls -la "${REPORT_FILE}"

# Manually open
open "${REPORT_FILE}"  # macOS
xdg-open "${REPORT_FILE}"  # Linux
```

### Cron Job Not Running

```bash
# Check cron logs
grep CRON /var/log/syslog  # Linux
log show --predicate 'process == "cron"' --last 1h  # macOS

# Verify crontab
crontab -l

# Test script manually
/path/to/daily-report.sh
```

## See Also

- [CLI Use Cases](CLI-Use-Cases.md) - More CLI examples and patterns
- [CLI Help Overview](CLI-Help-Overview.md) - Complete command reference
- [Filtering & Query Results](Filtering-QueryResults.md) - Advanced query techniques
- [config/templates/README.md](../config/templates/README.md) - Template documentation
- [Scriban Documentation](https://github.com/scriban/scriban/blob/master/doc/language.md) - Template syntax reference
