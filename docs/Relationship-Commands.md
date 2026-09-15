# Relationship Commands - Comprehensive Guide

## Table of Contents

1. [Overview](#overview)
2. [Commands](#commands)
   - [relationship resolve](#relationship-resolve)
   - [relationship analyze](#relationship-analyze)
   - [relationship validate](#relationship-validate)
   - [relationship find-closure](#relationship-find-closure)
3. [Common Options](#common-options)
4. [Use Cases and Scenarios](#use-cases-and-scenarios)
5. [Advanced Examples](#advanced-examples)
6. [Output Processing](#output-processing)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)


## Overview

The `azdw relationship` commands provide powerful capabilities for working with work item relationships in Azure DevOps. These commands enable you to:

- **Resolve**: Discover and map all relationships for work items across connections
- **Analyze**: Get insights into relationship patterns, cross-organizational connections, and metrics
- **Validate**: Ensure relationships comply with organizational policies and best practices
- **Find-Closure**: Compute the complete transitive closure of work item hierarchies with automatic merging of related items

All relationship commands support:
- ✅ Cross-organizational relationship resolution
- ✅ Hyperlink-based work item references
- ✅ File-based relationship mapping (ADRs, Wiki pages, Git files)
- ✅ Multiple output formats (table, JSON)
- ✅ Configurable traversal depth
- ✅ Relationship type filtering
- ✅ Connection-scoped operations


## Commands

### relationship resolve

**Purpose**: Discover and resolve all relationships for specified work items, including cross-organizational connections.

#### Basic Syntax

```bash
azdw relationship resolve --ids <IDs> --connection <NAME> [OPTIONS]
```

#### Key Options

| Option                    | Short | Description            | Example        |
| ---------------------- | ---- | ---------------------------------- | ------ |
| `--ids`                   | `-w`  | Work item IDs (comma-separated) | `34130,34131` |
| `--connection`            | `-c`  | Source connection name  | `Portfolio`  |
| `--max-depth`             | `-d`  | Maximum relationship depth (default: 10) | `--max-depth 2` |
| `--no-cross-conn`         |       | Disable cross-connection traversal (enabled by default) | `--no-cross-conn` |
| `--limit-conns`           |       | Limit to specific connections | `--limit-conns TeamA,TeamB` |
| `--relationship-types`    | `-t`  | Filter by relationship types | `Hierarchy,Dependency` |
| `--no-resolve-hyperlinks` |       | Disable hyperlink resolution (enabled by default) | `--no-resolve-hyperlinks` |
| `--output`                | `-o`  | Save to file  | `--output results.json`  |
| `--json`                  |       | JSON output format         | `--json`    |
| `--verbose`               |       | Detailed logging       | `--verbose`     |
| `--silent`                |       | Minimal output         | `--silent`      |

#### Available Relationship Types

- `Hierarchy` - Parent/Child relationships
- `Dependency` - Predecessor/Successor relationships
- `Related` - Related links
- `Remote` - Remote Work Link Types (Remote-Related, Produces-For, Consumes-From) for cross-organizational relationships within the same Entra ID
- `All` - All relationship types (default)

#### Relationship Type Naming

All commands emit **logical** relationship type names, never the raw Azure DevOps link
reference names. The raw name of each resolved link remains available in the
`originalRelationshipType` field of the JSON output.

| Azure DevOps link reference name | Logical name emitted by azdw |
| --- | --- |
| `System.LinkTypes.Hierarchy-Forward` | `Child` |
| `System.LinkTypes.Hierarchy-Reverse` | `Parent` |
| `System.LinkTypes.Related` | `Related` |
| `System.LinkTypes.Dependency-Forward` | `Successor` |
| `System.LinkTypes.Dependency-Reverse` | `Predecessor` |
| `System.LinkTypes.Duplicate-Forward` | `Duplicate` |
| `System.LinkTypes.Duplicate-Reverse` | `DuplicateOf` |
| `System.LinkTypes.Remote.Related` | `Remote-Related` |
| `System.LinkTypes.Remote.Dependency-Forward` | `Produces-For` |
| `System.LinkTypes.Remote.Dependency-Reverse` | `Consumes-From` |

`--relationship-types` accepts either spelling, so existing scripts that pass
`System.LinkTypes.*` names keep working.

#### Examples

**Basic Resolution**
```bash
# Resolve relationships for a single work item
azdw relationship resolve --ids 34130 --connection Portfolio
```

**Limited Depth**
```bash
# Resolve only immediate relationships (depth 1)
azdw relationship resolve --ids 34130 --connection Portfolio --max-depth 1

# Resolve up to 2 levels deep
azdw relationship resolve --ids 34130 --connection Portfolio --max-depth 2
```

**Cross-Organizational Resolution**
```bash
# Cross-connection traversal is enabled by default
azdw relationship resolve --ids 34130 --connection Portfolio

# Limit to specific connections
azdw relationship resolve --ids 34130 --connection Portfolio \
  --limit-conns TeamA,TeamB
```

**Filtered by Relationship Type**
```bash
# Only hierarchy relationships
azdw relationship resolve --ids 34130 --connection Portfolio \
  --relationship-types Hierarchy

# Multiple relationship types
azdw relationship resolve --ids 34130 --connection Portfolio \
  --relationship-types Hierarchy,Dependency
```

**With Hyperlink Resolution**
```bash
# Hyperlink and cross-connection resolution are enabled by default
azdw relationship resolve --ids 34130 --connection Portfolio
```

**Save to File**
```bash
# Output to JSON file
azdw relationship resolve --ids 34130 --connection Portfolio \
  --output relationships.json

# JSON format with cross-connection support (enabled by default)
azdw relationship resolve --ids 34130 --connection Portfolio \
  --max-depth 2 --json --output relationships.json
```

#### Output Structure

**Table Format** (default):
```
=== Relationship Resolution Summary ===
Total relationships found: 99
Organizations involved: contoso-engineering, contoso-portfolio
Cross-connection relationships: 2
```

**JSON Format** (`--json` or file output):
```json
{
  "summary": {
    "totalRelationships": 99,
    "organizationsInvolved": 2,
    "crossOrgRelationships": 2,
    "processedAt": "2025-11-13T01:51:44.750547Z"
  },
  "organizations": [
    "contoso-engineering",
    "contoso-portfolio"
  ],
  "relationships": [
    {
      "relationType": "Child",
      "source": {
        "sourceOrganization": "contoso-engineering",
        "sourceProject": "Portfolio Management",
        "sourceWorkItemId": 34130,
        "sourceWorkItemType": "Initiative"
      },
      "target": {
        "targetOrganization": "contoso-engineering",
        "targetProject": "Portfolio Management",
        "targetWorkItemId": 142775,
        "targetWorkItemType": "Epic",
        "targetUrl": "https://dev.azure.com/..."
      },
      "isCrossConnection": false,
      "validationIssues": []
    }
  ]
}
```


### relationship analyze

**Purpose**: Analyze relationship patterns and provide insights about work item connections.

#### Basic Syntax

```bash
azdw relationship analyze --ids <IDs> --connection <NAME> [OPTIONS]
```

#### Key Options

| Option              | Short | Description                     | Example      |
| -------------------- | ----- | --------------------------------- | --------- |
| `--ids`             | `-w`  | Work item IDs (comma-separated) | `34130,34131` |
| `--connection`      | `-c`  | Source connection name          | `Portfolio` |
| `--max-depth`       | `-d`  | Maximum relationship depth      | `--max-depth 1` |
| `--include-metrics` |       | Include detailed metrics        | `--include-metrics` |
| `--output`          | `-o`  | Save to file                    | `--output analysis.json` |
| `--json`            |       | JSON output format              | `--json`     |

#### Examples

**Basic Analysis**
```bash
# Analyze relationships with limited depth
azdw relationship analyze --ids 34130 --connection Portfolio --max-depth 1
```

**With Metrics**
```bash
# Include detailed metrics
azdw relationship analyze --ids 34130 --connection Portfolio \
  --include-metrics --max-depth 1
```

**Save to File**
```bash
# Save analysis results to JSON
azdw relationship analyze --ids 34130 --connection Portfolio \
  --include-metrics --max-depth 2 --output analysis.json
```

**JSON Output**
```bash
# Direct JSON output
azdw relationship analyze --ids 34130 --connection Portfolio \
  --include-metrics --max-depth 1 --json
```

#### Output Structure

**Table Format** (default):
```
=== Relationship Analysis Summary ===
Total relationships: 99
Organizations: 2
Cross-connection: 2
Relationship types:
  Child: 66
  Related: 30
  Hyperlink-WorkItem: 2
  Parent: 1
```

**JSON Format** (with `--include-metrics`):
```json
{
  "analysis": {
    "overview": {
      "totalRelationships": 99,
      "crossOrganizationalCount": 2,
      "uniqueOrganizations": 2,
      "uniqueProjects": 3
    },
    "relationshipTypes": {
      "Child": {
        "count": 66,
        "crossOrgCount": 0
      },
      "Related": {
        "count": 30,
        "crossOrgCount": 0
      },
      "Hyperlink-WorkItem": {
        "count": 2,
        "crossOrgCount": 2
      }
    },
    "organizationBreakdown": {
      "contoso-engineering": {
        "sourceCount": 99,
        "targetCount": 97,
        "totalCount": 196
      },
      "contoso-portfolio": {
        "sourceCount": 0,
        "targetCount": 2,
        "totalCount": 2
      }
    },
  },
  "metrics": {
    "averageRelationshipsPerWorkItem": 99,
    "maxRelationshipsPerWorkItem": 99,
    "crossOrgPercentage": 2.02,
    "hierarchicalRelationships": 67,
    "dependencyRelationships": 0,
    "otherRelationships": 32
  }
}
```


### relationship validate

**Purpose**: Validate relationships against organizational policies and best practices.

#### Basic Syntax

```bash
azdw relationship validate --ids <IDs> --connection <NAME> --policy-file <PATH> [OPTIONS]
```

#### Key Options

| Option          | Short | Description                     | Example          |
| --------------- | ----- | -------------------------------- | --------------- |
| `--ids`         | `-w`  | Work item IDs (comma-separated) | `34130,34131`    |
| `--connection`  | `-c`  | Source connection name          | `Portfolio`    |
| `--policy-file` | `-p`  | Path to policy file             | `--policy-file policy.json` |
| `--max-depth`   | `-d`  | Maximum relationship depth      | `--max-depth 1`  |
| `--strict`      |       | Fail on any violation           | `--strict`       |
| `--output`      | `-o`  | Save to file                    | `--output validation.json` |
| `--json`        |       | JSON output format              | `--json`         |

#### Examples

**Basic Validation**
```bash
# Validate with default policy
azdw relationship validate --ids 34130 --connection Portfolio \
  --policy-file config/relationship-policy.jsonc --max-depth 1
```

**Strict Mode**
```bash
# Fail on any policy violation
azdw relationship validate --ids 34130 --connection Portfolio \
  --policy-file config/relationship-policy.jsonc --strict --max-depth 1
```

**Save Results**
```bash
# Save validation results to file
azdw relationship validate --ids 34130 --connection Portfolio \
  --policy-file config/relationship-policy.jsonc --max-depth 1 \
  --output validation-results.json
```

#### Output Structure

**Table Format** (default):
```
=== Validation Summary ===
Policy enforcement mode: Warn
Total relationships validated: 99
Policy violations found: 0
✅ Validation PASSED
```

**JSON Format**:
```json
{
  "summary": {
    "totalRelationships": 99,
    "validationErrors": 0,
    "policyMode": "Warn",
    "processedAt": "2025-11-13T01:54:00.037916Z"
  },
  "policyViolations": {},
  "relationshipViolations": []
}
```


### relationship find-closure

**Purpose**: Find the complete hierarchy closure for one or more work items, computing all ancestors (up to a specified top-level type) and all descendants.

#### Basic Syntax

```bash
azdw relationship find-closure --id <IDs> --connection <NAME> [OPTIONS]
```

#### Key Options

| Option                    | Short | Description            | Example        |
| ---------------------- | ---- | ---------------------------------- | ------ |
| `--id`                    | `-w`  | Work item ID(s) - comma-separated | `-w 100,200,300` |
| `--connection`            | `-c`  | Azure DevOps connection name | `--connection MyOrg` |
| `--top-type`              | `-t`  | Top-level work item type (default: Epic) | `-t "Initiative"` |
| `--include-top-siblings`  |       | Include siblings of top-level items | `--include-top-siblings` |
| `--include-predecessors`  |       | Include predecessor relationships | `--include-predecessors` |
| `--no-resolve-hyperlinks` |       | Disable hyperlink resolution (enabled by default) | `--no-resolve-hyperlinks` |
| `--hyperlinks-as`         |       | How to interpret hyperlinks (Parent, Child, Related, Dependency) | `--hyperlinks-as Parent` |
| `--no-cross-conn`         |       | Disable cross-connection resolution (enabled by default) | `--no-cross-conn` |
| `--limit-conns`           |       | Limit cross-connection to specific connections | `--limit-conns TeamA,TeamB` |
| `--max-size`              | `-m`  | Maximum closure size (1-10000, default: 10000) | `-m 500` |
| `--states-exclude`        |       | Work item states to exclude | `--states-exclude Closed,Removed` |
| `--output`                | `-o`  | Output file path   | `-o closure.json`   |
| `--format`                | `-f`  | Output format: json, table, or csv | `-f json` |

#### Multiple Work Item IDs

The `--id` option accepts multiple work item IDs as a comma-separated list:

```bash
# Comma-separated
azdw relationship find-closure -w 100,200,300 -c MyOrg
```

**Automatic Closure Merging**: When multiple work item IDs share relationships or common ancestors, their closures are automatically merged into a single closure. Unrelated work items produce separate closures.

#### Examples

**Single Work Item Closure**
```bash
# Find closure for a single work item with Epic as top-level type
azdw relationship find-closure -w 12345 -c MyOrg

# Specify a different top-level type
azdw relationship find-closure -w 12345 -c MyOrg -t "Initiative"
```

**Multiple Work Items with Merging**
```bash
# Find closures for multiple work items
# Related items are automatically merged
azdw relationship find-closure -w 100,200,300 -c MyOrg -t Feature

# Cross-connection and hyperlink resolution are enabled by default
azdw relationship find-closure -w 100,200,300 -c MyOrg
```

**Cross-Connection with Hyperlinks**
```bash
# Cross-connection and hyperlink resolution are enabled by default
azdw relationship find-closure -w 12345 -c MyOrg \
  -t "Initiative"
```

**Save to File**
```bash
# Output to JSON file
azdw relationship find-closure -w 100,200,300 -c MyOrg \
  -f json -o closures.json

# Output to CSV
azdw relationship find-closure -w 100,200,300 -c MyOrg \
  -f csv -o closures.csv
```

#### Output Structure

**Single Work Item** (returns `ClosureResult`):
```
Closure Status: Complete
Total Items: 15
Start Work Item: 12345
Top-Level Items: 100

Work Items (Hierarchical Order)
===============================
Depth  Connection ID     Type      State    Title                    Reason
---------------------------------------------------------------------------
-1     LPM        100    Epic      Active   Parent Epic              TopLevel
0      MyOrg      12345  Feature   Active   My Feature               StartItem
1      MyOrg      12346  UserStory Active   Child Story              Descendant
```

**Multiple Work Items** (returns `MultiClosureResult`):
```
=== Closure 1 of 2 [merged from IDs: 100, 200] ===
Closure Status: Complete
Total Items: 25
Merge Reason: Closures share common work items

Work Items (Hierarchical Order)
...

=== Closure 2 of 2 [ID: 300] ===
Closure Status: Complete
Total Items: 8

Work Items (Hierarchical Order)
...
```

**JSON Format** (multiple work items):
```json
{
  "closures": [
    {
      "sourceWorkItemIds": [100, 200],
      "isMerged": true,
      "mergeReason": "Closures share common work items",
      "closure": {
        "status": "Complete",
        "startWorkItemId": 100,
        "totalCount": 25,
        "nodes": [...]
      }
    },
    {
      "sourceWorkItemIds": [300],
      "isMerged": false,
      "mergeReason": null,
      "closure": {
        "status": "Complete",
        "startWorkItemId": 300,
        "totalCount": 8,
        "nodes": [...]
      }
    }
  ],
  "hasMergedClosures": true,
  "invalidWorkItemIds": [],
  "processingTimeMs": 1234
}
```

#### Inclusion Reasons

Each work item in the closure is tagged with an inclusion reason:

| Reason | Description |
| ------ | ----------- |
| `TopLevel` | Matches the specified top-level type (e.g., Epic) |
| `StartItem` | The work item ID specified in the request |
| `Ancestor` | Parent or grandparent of the start item |
| `Descendant` | Child or grandchild of the start/top-level item |
| `Sibling` | Sibling of a top-level item (when `--include-top-siblings` is used) |
| `Predecessor` | Predecessor relationship (when `--include-predecessors` is used) |
| `Hyperlink` | Discovered via hyperlink resolution |
| `RemoteLink` | Discovered via an Azure DevOps remote work link (`Produces-For`, `Consumes-From`, `Remote-Related`); requires cross-connection traversal, so it is skipped with `--no-cross-conn` |


## Common Options

### Performance Options

**Max Depth** (`--max-depth`, `-d`)
- Controls how deep the relationship tree is traversed
- **Default**: 10 levels
- **Recommended**: 1-2 for large work items to avoid timeouts
- **Use case**: Work items with extensive relationships can have hundreds or thousands of connections at depth 2+

```bash
# Quick scan - immediate relationships only
--max-depth 1

# Medium scan - 2 levels deep
--max-depth 2

# Deep scan - up to 5 levels
--max-depth 5
```

### Cross-Connection Options

**Cross-Connection Traversal** (enabled by default)
- Following relationships across different Azure DevOps organizations is enabled by default
- Use `--no-cross-conn` to disable this behavior
- Use `--limit-conns` to restrict to specific connections

```bash
# Cross-connection is enabled by default
# Limit to specific connections if needed
--limit-conns Connection1,Connection2

# Disable cross-connection if needed
--no-cross-conn
```

**Hyperlink Resolution** (enabled by default)
- Resolves hyperlinks that point to Azure DevOps work items
- Also maps file hyperlinks (Git files, Wiki pages, ADRs) to navigable relationships via `file-relationship-config.jsonc`
- Use `--no-resolve-hyperlinks` to disable this behavior

```bash
# Hyperlink resolution is enabled by default
# To disable:
--no-resolve-hyperlinks
```

**File Content Extraction** (`--resolve-file-content` / `-rfc`)

Since hyperlink resolution is enabled by default, this option fetches the actual content of Git-hosted files and extracts field values using regex patterns defined in `file-relationship-config.jsonc`. This enables:
- Extracting ADR status (e.g., "Accepted", "Deprecated") from markdown files
- Populating fake work item fields from file content

```bash
# Extract field values from file content (hyperlink resolution is on by default)
azdw relationship resolve --ids 12345 --resolve-file-content
```

> **⚠️ Required PAT Permission:** To use `--resolve-file-content`, your PAT must include the **Code (Read)** scope. 
> Without this permission, file content fetching will fail with HTTP 401.
> See [Azure DevOps Permissions](Azure-DevOps-Permissions.md) for details.

**File Relationship Configuration**

With hyperlink resolution enabled by default, hyperlinks that don't match Azure DevOps work item URLs are tested against patterns in `config/file-relationship-config.jsonc`. Matching URLs are converted to "fake" work items with:
- Synthetic IDs starting from 900000
- Work item types based on configuration (e.g., "Architecture Decision Record")
- Organization/project derived from URL captures

See [Cross-Org-Relationship-Handling.md](Cross-Org-Relationship-Handling.md#32-file-based-relationship-mapping) for configuration details.

### Output Options

**Output Format**
```bash
# Default table format
azdw relationship resolve --ids 34130 -c Portfolio

# JSON output to console
azdw relationship resolve --ids 34130 -c Portfolio --json

# Save to file (auto-detects JSON format)
azdw relationship resolve --ids 34130 -c Portfolio -o results.json
```

**Verbosity**
```bash
# Verbose - detailed logging
--verbose

# Silent - minimal output
--silent
```


## Use Cases and Scenarios

### 1. Impact Analysis

**Scenario**: Before making changes to a critical work item, understand all dependent work items.

```bash
#!/bin/bash
# impact-analysis.sh

WORK_ITEM="34130"
CONNECTION="Portfolio"
OUTPUT_FILE="impact-analysis-${WORK_ITEM}.json"

echo "Analyzing impact for work item ${WORK_ITEM}..."

# Resolve all relationships with depth 2
# Note: cross-conn and resolve-hyperlinks are enabled by default
azdw relationship resolve \
  --ids "${WORK_ITEM}" \
  --connection "${CONNECTION}" \
  --max-depth 2 \
  --output "${OUTPUT_FILE}"

# Analyze the results
azdw relationship analyze \
  --ids "${WORK_ITEM}" \
  --connection "${CONNECTION}" \
  --max-depth 2 \
  --include-metrics \
  --output "analysis-${WORK_ITEM}.json"

echo "Impact analysis complete. Check ${OUTPUT_FILE} and analysis-${WORK_ITEM}.json"
```

### 2. Cross-Organizational Dependency Tracking

**Scenario**: Track dependencies between teams in different Azure DevOps organizations.

```bash
#!/bin/bash
# cross-org-dependencies.sh

EPIC_ID="1234"
PRIMARY_CONN="TeamA"

echo "Tracking cross-organizational dependencies for Epic ${EPIC_ID}..."

# Resolve with cross-connection support (enabled by default)
azdw relationship resolve \
  --ids "${EPIC_ID}" \
  --connection "${PRIMARY_CONN}" \
  --max-depth 3 \
  --relationship-types Hierarchy,Dependency \
  --json \
  --output "cross-org-deps-${EPIC_ID}.json"

# Extract cross-org relationships using jq
jq '.relationships[] | select(.isCrossConnection == true) | {
  source: .source.sourceWorkItemId,
  target: .target.targetWorkItemId,
  sourceOrg: .source.sourceOrganization,
  targetOrg: .target.targetOrganization,
  type: .relationType
}' "cross-org-deps-${EPIC_ID}.json"
```

### 3. Relationship Health Check

**Scenario**: Regularly validate that relationships comply with organizational policies.

```bash
#!/bin/bash
# health-check.sh

WORK_ITEMS="34130,34131,34132"
CONNECTION="Portfolio"
POLICY_FILE="config/relationship-policy.jsonc"

echo "Running relationship health check..."

# Validate relationships
azdw relationship validate \
  --ids "${WORK_ITEMS}" \
  --connection "${CONNECTION}" \
  --policy-file "${POLICY_FILE}" \
  --max-depth 1 \
  --strict \
  --output "validation-report.json"

if [ $? -eq 0 ]; then
  echo "✅ Health check PASSED"
else
  echo "❌ Health check FAILED - see validation-report.json"
  exit 1
fi
```

### 4. Portfolio Rollup Analysis

**Scenario**: Analyze all work items under a portfolio epic to understand scope and dependencies.

```bash
#!/bin/bash
# portfolio-rollup.sh

PORTFOLIO_EPIC="5000"
CONNECTION="Portfolio"

echo "Analyzing portfolio epic ${PORTFOLIO_EPIC}..."

# Get all hierarchical relationships
azdw relationship resolve \
  --ids "${PORTFOLIO_EPIC}" \
  --connection "${CONNECTION}" \
  --relationship-types Hierarchy \
  --max-depth 5 \
  --output "portfolio-${PORTFOLIO_EPIC}-hierarchy.json"

# Analyze the portfolio
azdw relationship analyze \
  --ids "${PORTFOLIO_EPIC}" \
  --connection "${CONNECTION}" \
  --max-depth 5 \
  --include-metrics \
  --json | jq '{
    total: .analysis.overview.totalRelationships,
    organizations: .analysis.overview.uniqueOrganizations,
    projects: .analysis.overview.uniqueProjects,
    types: .analysis.workItemTypePatterns
  }'
```

### 5. Orphaned Work Item Detection

**Scenario**: Find work items with no parent relationships.

```bash
#!/bin/bash
# find-orphans.sh

CONNECTION="MyProject"
WORK_ITEMS="1000,1001,1002,1003,1004"

echo "Checking for orphaned work items..."

azdw relationship resolve \
  --ids "${WORK_ITEMS}" \
  --connection "${CONNECTION}" \
  --relationship-types Hierarchy \
  --max-depth 1 \
  --json \
  --output "hierarchy-check.json"

# Find work items with no Hierarchy-Reverse (no parent)
jq -r '.relationships | 
  group_by(.source.sourceWorkItemId) |
  map({
    id: .[0].source.sourceWorkItemId,
    hasParent: map(select(.relationType == "Parent")) | length > 0
  }) |
  map(select(.hasParent == false)) |
  .[].id' hierarchy-check.json
```


## Advanced Examples

### Multi-Connection Relationship Map

Create a comprehensive relationship map across multiple connections:

```bash
#!/bin/bash
# multi-connection-map.sh

WORK_ITEM="34130"
PRIMARY_CONN="Portfolio"
ALLOWED_CONNS="Portfolio,TeamA,TeamB"

echo "Creating multi-connection relationship map..."

# Resolve across all connections (cross-conn and resolve-hyperlinks enabled by default)
azdw relationship resolve \
  --ids "${WORK_ITEM}" \
  --connection "${PRIMARY_CONN}" \
  --limit-conns "${ALLOWED_CONNS}" \
  --max-depth 2 \
  --output "full-map.json"

# Extract connection statistics
echo "Connection Statistics:"
jq -r '.relationships | 
  group_by(.source.sourceOrganization, .target.targetOrganization) |
  map({
    from: .[0].source.sourceOrganization,
    to: .[0].target.targetOrganization,
    count: length
  })' full-map.json
```

### Relationship Type Distribution

Analyze the distribution of relationship types:

```bash
#!/bin/bash
# relationship-distribution.sh

WORK_ITEM="34130"
CONNECTION="Portfolio"

echo "Analyzing relationship type distribution..."

azdw relationship analyze \
  --ids "${WORK_ITEM}" \
  --connection "${CONNECTION}" \
  --include-metrics \
  --max-depth 2 \
  --json | jq -r '
    .analysis.relationshipTypes |
    to_entries |
    map("\(.key): \(.value.count) (cross-org: \(.value.crossOrgCount))") |
    .[]'
```

### Dependency Chain Visualization

Extract and visualize dependency chains:

```bash
#!/bin/bash
# dependency-chain.sh

WORK_ITEM="34130"
CONNECTION="Portfolio"

echo "Extracting dependency chain..."

azdw relationship resolve \
  --ids "${WORK_ITEM}" \
  --connection "${CONNECTION}" \
  --relationship-types Dependency \
  --max-depth 5 \
  --json \
  --output "dependencies.json"

# Create a simple dependency graph (DOT format)
echo "digraph Dependencies {" > dependencies.dot
jq -r '.relationships[] | 
  "\"\(.source.sourceWorkItemId)\" -> \"\(.target.targetWorkItemId)\" [label=\"\(.relationType)\"];"' \
  dependencies.json >> dependencies.dot
echo "}" >> dependencies.dot

# Convert to PNG (requires Graphviz)
if command -v dot &> /dev/null; then
  dot -Tpng dependencies.dot -o dependencies.png
  echo "Dependency graph saved to dependencies.png"
fi
```


## Output Processing

### Using jq for JSON Processing

#### Extract Specific Relationships

```bash
# Get all cross-connection relationships
azdw relationship resolve --ids 34130 -c Portfolio --json | \
  jq '.relationships[] | select(.isCrossConnection == true)'

# Get all hierarchy relationships
azdw relationship resolve --ids 34130 -c Portfolio --json | \
  jq '.relationships[] | select(.relationType | contains("Hierarchy"))'

# Get relationships to specific work item type
azdw relationship resolve --ids 34130 -c Portfolio --json | \
  jq '.relationships[] | select(.target.targetWorkItemType == "Feature")'
```

#### Generate Reports

```bash
# Count relationships by type
azdw relationship analyze --ids 34130 -c Portfolio --include-metrics --json | \
  jq '.analysis.relationshipTypes | to_entries | map({type: .key, count: .value.count})'

# List all unique work item types
azdw relationship resolve --ids 34130 -c Portfolio --json | \
  jq '[.relationships[].target.targetWorkItemType] | unique'

# Calculate cross-org percentage
azdw relationship analyze --ids 34130 -c Portfolio --include-metrics --json | \
  jq '.metrics.crossOrgPercentage'
```

### Using PowerShell for Processing

```powershell
# Process-Relationships.ps1

# Load relationship data
$data = azdw relationship resolve --ids 34130 -c Portfolio --json | ConvertFrom-Json

# Group by organization
$orgGroups = $data.relationships | Group-Object { $_.target.targetOrganization }

# Display summary
$orgGroups | ForEach-Object {
    [PSCustomObject]@{
        Organization = $_.Name
        Count = $_.Count
        Percentage = [math]::Round(($_.Count / $data.summary.totalRelationships) * 100, 2)
    }
} | Format-Table -AutoSize

# Find work items with most relationships
$data.relationships | 
    Group-Object { $_.target.targetWorkItemId } |
    Sort-Object Count -Descending |
    Select-Object -First 10 |
    ForEach-Object {
        [PSCustomObject]@{
            WorkItemId = $_.Name
            RelationshipCount = $_.Count
        }
    } | Format-Table -AutoSize
```

### Using Python for Analysis

```python
#!/usr/bin/env python3
# analyze-relationships.py

import json
import subprocess
from collections import defaultdict

def get_relationships(work_item, connection):
    """Fetch relationships using azdw CLI."""
    cmd = [
        'azdw', 'relationship', 'resolve',
        '--ids', work_item,
        '--connection', connection,
        '--json'
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return json.loads(result.stdout)

def analyze_relationship_depth(relationships):
    """Analyze the depth of relationship chains."""
    depth_map = defaultdict(list)
    
    for rel in relationships:
        source_id = rel['source']['sourceWorkItemId']
        target_id = rel['target']['targetWorkItemId']
        depth_map[source_id].append(target_id)
    
    return depth_map

def main():
    work_item = '34130'
    connection = 'Portfolio'
    
    print(f"Analyzing relationships for work item {work_item}...")
    
    data = get_relationships(work_item, connection)
    
    # Summary statistics
    summary = data['summary']
    print(f"\nSummary:")
    print(f"  Total relationships: {summary['totalRelationships']}")
    print(f"  Organizations: {summary['organizationsInvolved']}")
    print(f"  Cross-org: {summary['crossOrgRelationships']}")
    
    # Relationship type breakdown
    type_counts = defaultdict(int)
    for rel in data['relationships']:
        type_counts[rel['relationType']] += 1
    
    print(f"\nRelationship Types:")
    for rel_type, count in sorted(type_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"  {rel_type}: {count}")
    
    # Cross-org analysis
    cross_org = [r for r in data['relationships'] if r.get('isCrossConnection', False)]
    if cross_org:
        print(f"\nCross-Organizational Relationships: {len(cross_org)}")
        org_pairs = defaultdict(int)
        for rel in cross_org:
            pair = f"{rel['source']['sourceOrganization']} → {rel['target']['targetOrganization']}"
            org_pairs[pair] += 1
        
        for pair, count in org_pairs.items():
            print(f"  {pair}: {count}")

if __name__ == '__main__':
    main()
```


## Best Practices

### 1. Performance Optimization

**Use Appropriate Max Depth**
- Start with `--max-depth 1` for initial exploration
- Increase depth only when needed
- Large work items can have 100+ relationships at depth 1, 900+ at depth 2

```bash
# Good: Quick exploration
azdw relationship analyze -w 34130 -c Portfolio --max-depth 1

# Careful: Can be slow for highly connected work items
azdw relationship analyze -w 34130 -c Portfolio --max-depth 3
```

**Filter Relationship Types**
```bash
# Only get what you need
azdw relationship resolve -w 34130 -c Portfolio \
  --relationship-types Hierarchy --max-depth 2
```

### 2. Cross-Connection Best Practices

**Limit Connections When Possible**
```bash
# Specify which connections to traverse (cross-conn is enabled by default)
azdw relationship resolve -w 34130 -c Portfolio \
  --limit-conns Portfolio,TeamA
```

**Disable cross-connection/hyperlinks if needed**
```bash
# Only when you need to restrict to a single connection
azdw relationship resolve -w 34130 -c Portfolio \
  --no-cross-conn --no-resolve-hyperlinks
```

### 3. Output Management

**Always Save Important Results**
```bash
# Save to timestamped files
DATE=$(date +%Y%m%d-%H%M%S)
azdw relationship resolve -w 34130 -c Portfolio \
  --output "relationships-${DATE}.json"
```

**Use JSON for Processing**
```bash
# Pipe to jq for filtering
azdw relationship resolve -w 34130 -c Portfolio --json | \
  jq '.relationships[] | select(.isCrossConnection == true)'
```

### 4. Validation Strategy

**Regular Health Checks**
```bash
# Weekly validation in CI/CD
azdw relationship validate -w "${CRITICAL_WORK_ITEMS}" \
  -c "${CONNECTION}" \
  --policy-file policy.json \
  --strict \
  --max-depth 1
```

**Progressive Validation**
```bash
# Start with warnings, move to strict
# Phase 1: Gather violations
azdw relationship validate -w 34130 -c Portfolio \
  --policy-file policy.json -o violations.json

# Phase 2: After fixing, enforce strictly
azdw relationship validate -w 34130 -c Portfolio \
  --policy-file policy.json --strict
```

### 5. Batch Processing

**Process Multiple Work Items**
```bash
#!/bin/bash
# batch-analysis.sh

WORK_ITEMS=("34130" "34131" "34132" "34133")
CONNECTION="Portfolio"

for WI in "${WORK_ITEMS[@]}"; do
  echo "Processing work item ${WI}..."
  
  azdw relationship analyze \
    --ids "${WI}" \
    --connection "${CONNECTION}" \
    --max-depth 1 \
    --include-metrics \
    --output "analysis-${WI}.json"
  
  echo "✓ Completed ${WI}"
done

echo "All work items processed!"
```


## Troubleshooting

### Common Issues

#### 1. Command Takes Too Long

**Problem**: Relationship resolution times out or takes 5+ minutes.

**Solution**: Reduce max-depth or filter relationship types.

```bash
# Instead of this (too deep)
azdw relationship resolve -w 34130 -c Portfolio --max-depth 5

# Use this
azdw relationship resolve -w 34130 -c Portfolio --max-depth 1

# Or filter types
azdw relationship resolve -w 34130 -c Portfolio \
  --relationship-types Hierarchy --max-depth 2
```

#### 2. Authentication Failures

**Problem**: Cross-connection resolution fails with auth errors.

**Solution**: Ensure all connections are authenticated.

```bash
# Test each connection first
azdw connection test --name Portfolio
azdw connection test --name LPM
azdw connection test --name TeamB

# Then run cross-connection resolution (enabled by default)
azdw relationship resolve -w 34130 -c Portfolio
```

#### 3. Missing Cross-Org Relationships

**Problem**: Expected cross-organizational relationships not found.

**Solution**: Ensure connections are configured and authenticated.

```bash
# Cross-connection and hyperlink resolution are enabled by default
# Make sure connections are properly configured:
azdw connection list
azdw connection test --all
```

#### 4. Too Much Output

**Problem**: JSON output is too large to process.

**Solution**: Use filters and limited depth.

```bash
# Limit depth
azdw relationship resolve -w 34130 -c Portfolio \
  --max-depth 1 --output limited.json

# Filter during extraction
azdw relationship resolve -w 34130 -c Portfolio --json | \
  jq '.relationships[0:50]' > first-50.json
```

#### 5. Policy Validation Errors

**Problem**: Validation fails with unclear errors.

**Solution**: Use verbose mode to see details.

```bash
# Add verbose flag
azdw relationship validate -w 34130 -c Portfolio \
  --policy-file policy.json \
  --verbose

# Check policy file syntax
cat policy.json | jq .
```

### Performance Tips

1. **Start Small**: Always test with `--max-depth 1` first
2. **Use Filters**: Apply relationship type filters when possible
3. **Limit Connections**: Specify `--limit-conns` for cross-org resolution
4. **Save Results**: Cache relationship data to avoid re-fetching
5. **Batch Smartly**: Process related work items together

### Debugging

**Enable Verbose Logging**
```bash
azdw relationship resolve -w 34130 -c Portfolio --verbose
```

**Check Connection Status**
```bash
azdw connection list
azdw connection test --all
```

**Validate Policy File**
```bash
# Check JSON syntax
jq . < config/relationship-policy.jsonc

# Test with single work item
azdw relationship validate -w 34130 -c Portfolio \
  --policy-file config/relationship-policy.jsonc \
  --max-depth 1
```


## Additional Resources

- [Cross-Org Relationship Handling](./Cross-Org-Relationship-Handling.md) - Detailed cross-organizational relationship documentation
- [CLI Use Cases](./CLI-Use-Cases.md) - General CLI usage scenarios
- [Output Rendering Automation](./Output-Rendering-Automation.md) - Advanced output processing
- [Filtering Query Results](./Filtering-QueryResults.md) - Query and filter techniques


## Summary

The `azdw relationship` commands provide powerful capabilities for understanding and managing work item relationships across Azure DevOps organizations. Key takeaways:

✅ **Three main commands**: resolve, analyze, validate  
✅ **Performance**: Use `--max-depth` to control traversal depth  
✅ **Cross-org**: Enabled by default; use `--no-cross-conn` and `--no-resolve-hyperlinks` to disable  
✅ **Filtering**: Use relationship type filters to reduce scope  
✅ **Output**: JSON format enables powerful post-processing  
✅ **Automation**: Combine with scripts for health checks and reporting  

Start with basic commands and progressively add options as needed. Always consider performance when working with highly connected work items.
