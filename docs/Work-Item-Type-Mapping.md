---
title: Work Item Type Mapping Guide
nav_order: 110
---

# Work Item Type Mapping Guide

## Overview

The `azdw` tool provides a flexible mapping system that bridges the gap between Azure DevOps's physical work item types (which vary by process template and customization) and a unified logical data model. This guide explains how the mapping system works and how to customize it for your needs.

## Key Concepts

### Physical Work Item Types

These are the actual work item types defined in your Azure DevOps organization:

- **Standard Types**: Defined by base process templates (Agile, Scrum, CMMI, Basic)
  - **Agile**: User Story, Task, Bug, Epic, Feature
  - **Scrum**: Product Backlog Item, Task, Bug, Epic, Feature  
  - **CMMI**: Requirement, Task, Bug, Epic, Feature
  - **Basic**: Issue, Task, Epic

- **Custom Types**: Types added by your organization.

### Logical Work Item Types

Simplified, template-independent type names used for:
- Querying across multiple connections with different templates
- Creating a unified data model across your organization
- Simplifying user input (e.g., "UserStory" instead of "Product Backlog Item")

**Examples:**
- `UserStory` → Maps to "User Story" (Agile) or "Product Backlog Item" (Scrum) or "Requirement" (CMMI)
- `Task` → Maps to "Task" (all templates)
- `Bug` → Maps to "Bug" (all templates)

## How the Mapping System Works

### 1. Dynamic Process Template Detection

When you query a connection, `azdw` automatically detects which process template is in use:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Fetch work item types from Azure DevOps API              │
│    (requires standard Work Items - Read permission)         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       v
┌─────────────────────────────────────────────────────────────┐
│ 2. Analyze work item types using multiple strategies:       │
│    ✓ Reference name prefixes (e.g., "MyScrum-*")            │
│    ✓ Characteristic type names (e.g., "Product Backlog      │
│      Item" indicates Scrum)                                 │
│    ✓ State patterns (e.g., "Approved" + "Committed"         │
│      indicates Scrum)                                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       v
┌─────────────────────────────────────────────────────────────┐
│ 3. Infer base process template:                             │
│    → Scrum, Agile, CMMI, or Basic                           │
└─────────────────────────────────────────────────────────────┘
```

**Example:**
```bash
$ azdw metadata types --connection "PortfolioMgmt"

Found 33 work item type(s):
🔍 Inferred base process template: Scrum

📋 Product Backlog Item (disabled)
...
```

### 2. Static Field Mapping Files

Pre-defined mapping files in `config/field-mappings/` define how logical types map to physical types for each process template:

**File naming:** `{logicaltype}-{template}.jsonc`

**Examples:**
- `userstory-agile.jsonc` → Maps "UserStory" to "User Story" (Agile template)
- `userstory-scrum.jsonc` → Maps "UserStory" to "Product Backlog Item" (Scrum template)
- `task-agile.jsonc` → Maps "Task" to "Task" (Agile template)

**Sample mapping file structure:**
```jsonc
{
  "logicalType": "UserStory",
  "physicalType": "Product Backlog Item",
  "processTemplate": "Scrum",
  "logicalFields": {
    "id": "System.Id",
    "title": "System.Title",
    "description": "System.Description",
    "state": "System.State",
    "assignedTo": "System.AssignedTo"
    // ... more field mappings
  },
  "stateMapping": {
    "New": "New",
    "Active": "Approved",
    "Done": "Done"
  }
  // ... more mappings
}
```

### 3. Query Resolution Flow

When you execute a query, here's how type resolution works:

```
User Input:
  --types "UserStory"
         │
         v
┌─────────────────────────────────────────────────────────────┐
│ 1. Detect process template for connection                   │
│    → PortfolioMgmt uses Scrum                               │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       v
┌─────────────────────────────────────────────────────────────┐
│ 2. Look up mapping file: userstory-scrum.jsonc              │
│    LogicalType: "UserStory"                                 │
│    PhysicalType: "Product Backlog Item"                     │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       v
┌─────────────────────────────────────────────────────────────┐
│ 3. Execute WIQL query with physical type:                   │
│    [System.WorkItemType] = 'Product Backlog Item'           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       v
┌─────────────────────────────────────────────────────────────┐
│ 4. Results show actual Azure DevOps type:                   │
│    Type: "Product Backlog Item"                             │
└─────────────────────────────────────────────────────────────┘
```

### 4. Flexible Input Acceptance

The tool accepts **multiple input formats** for your convenience:

| User Input | PortfolioMgmt (Scrum) | Other (Agile) |
|------------|---------------------|-------------|
| `--types "UserStory"` | → Product Backlog Item | → User Story |
| `--types "ProductBacklogItem"` | → Product Backlog Item | → (no match) |
| `--types "Product Backlog Item"` | → Product Backlog Item | → (no match) |

All variations work seamlessly!

## Querying Across Connections

### Unified Logical Types

When querying **multiple connections** with different process templates, use logical types for consistent results:

```bash
# Query all connections for user stories
$ azdw query --types "UserStory" --state "Active"

Results:
- PortfolioMgmt (Scrum): Returns "Product Backlog Item" work items
- Other (Agile): Returns "User Story" work items
```

The output preserves the **actual work item type names** from each connection for clarity, while the query supports the unified logical type for convenience.

### Custom Work Item Types

For custom types unique to your organization:

```bash
# Query connection-specific types directly
$ azdw query --connections "PortfolioMgmt" --types "Epic" "Feature"

# Mix logical and custom types
$ azdw query --types "UserStory" "Feature" "Task"
```

Custom types are used as-is (no mapping applied).

## Logical Types Across All Interfaces

### Where Logical Types Work

Logical work item types (e.g., `"UserStory"`, `"ProductBacklogItem"`) are automatically resolved to actual physical types **everywhere** in the `azdw` tool:

✅ **CLI `query` Command**:
```bash
$ azdw query --types "UserStory" "Task" --state "Active"
# Resolves "UserStory" per connection's template before querying
```

✅ **Library API** (when using `azdw` as a NuGet package):
```csharp
var filter = new QueryFilter
{
    WorkItemTypes = new List<string> { "UserStory", "Bug" }
};
var result = await queryService.QueryWorkItemsAsync(filter);
// Logical types resolved automatically per connection
```

✅ **MCP Server** (Model Context Protocol):
```json
{
  "tool": "query_work_items",
  "parameters": {
    "workItemTypes": "UserStory,Bug",
    "states": "Active"
  }
}
// Logical types resolved automatically per connection
```

✅ **GraphQL/REST API** (when querying via library):
All queries go through the same `QueryWorkItemsAsync` method, which resolves logical types automatically.

### How Resolution Works

When you specify a work item type in a query:

```
Input: "UserStory"
   ↓
1. Detect connection's process template → "Scrum"
   ↓
2. Resolve logical type per template:
   - Scrum: "UserStory" → "Product Backlog Item"
   - Agile: "UserStory" → "User Story"
   - CMMI: "UserStory" → "Requirement"
   ↓
3. Build query with actual type name
   ↓
4. Send to Azure DevOps API
   ↓
Output: Work items with their actual type names preserved
```

### WIQL Limitations

⚠️ **Important**: Raw WIQL queries have different behavior depending on the `--resolve-logical-types` flag:

**Without `--resolve-logical-types` (default)** — Requires actual type names:
```bash
# ❌ Does NOT work - Azure DevOps WIQL doesn't understand logical types
$ azdw wiql "SELECT [ID] FROM WorkItems WHERE [Work Item Type] = 'UserStory'"

# ✅ Works - Use actual type name for the connection's template
$ azdw wiql "SELECT [ID] FROM WorkItems WHERE [Work Item Type] = 'Product Backlog Item'"
```

**With `--resolve-logical-types`** — Automatically rewrites logical types:
```bash
# ✅ Works - Logical types are automatically resolved per connection
$ azdw wiql "SELECT [ID] FROM WorkItems WHERE [Work Item Type] = 'UserStory'" --resolve-logical-types

# For Scrum connections: Rewritten to "Product Backlog Item"
# For Agile connections: Rewritten to "User Story"
```

**Why?** By default, WIQL queries are passed directly to Azure DevOps without modification. Azure DevOps only understands the actual work item types defined in your process template. When you enable `--resolve-logical-types`, the tool parses your WIQL query and replaces logical type names with the correct physical type names for each connection being queried.

**Recommendation**: For most queries, use `azdw query` instead of `azdw wiql`:
```bash
# Preferred - logical types work automatically, more user-friendly
$ azdw query --types "UserStory" --state "Active"

# Alternative - manual WIQL with actual types (for advanced queries)
$ azdw wiql "SELECT [ID] FROM WorkItems WHERE [Work Item Type] = 'Product Backlog Item'"

# Alternative - manual WIQL with automatic type resolution
$ azdw wiql "SELECT [ID] FROM WorkItems WHERE [Work Item Type] = 'UserStory'" --resolve-logical-types
```

### Best Practice Summary

| Interface | Logical Types Support | Notes |
|-----------|----------------------|-------|
| `azdw query` | ✅ Full support | Automatically resolves per connection |
| `azdw wiql` | ⚠️ Optional | Use `--resolve-logical-types` flag for automatic resolution |
| Library API (`QueryWorkItemsAsync`) | ✅ Full support | Automatic resolution |
| MCP Server | ✅ Full support | Automatic resolution |
| GraphQL/REST (via library) | ✅ Full support | Automatic resolution |

**Key Takeaway**: Always use the `query` command or `QueryWorkItemsAsync` method for the best experience with logical types. Use `wiql` for advanced scenarios where you need full WIQL control, and add `--resolve-logical-types` if your WIQL contains logical type names.

## Customizing Mappings

### Viewing Current Mappings

```bash
# List all available mappings for a connection
$ azdw config fieldmap list --connection "PortfolioMgmt"

# View specific mapping details
$ azdw config fieldmap show --connection "PortfolioMgmt" --logical-type "UserStory"
```

### Generating Mappings for Custom Types

1. **Generate mappings to preview**:
   ```bash
   $ azdw config fieldmap generate --connection "PortfolioMgmt" --template "Scrum"
   ```

2. **Backup existing mappings** before saving:
   ```bash
   $ cp -r config/field-mappings config/field-mappings.backup
   ```

3. **Use `--force` flag** to explicitly overwrite:
   ```bash
   $ azdw config fieldmap generate --connection "PortfolioMgmt" --force
   ```

#### What Gets Generated:

The tool generates basic mappings for common types:
- Standard process template types (Epic, Feature, UserStory, Task, Bug)
- Maps logical field names to System.* fields
- Basic state and priority mappings

**For custom types** (e.g., "MyFeature"), you'll need to:
1. Manually create a mapping file
2. Copy and modify an existing mapping as a template
3. Define custom field mappings specific to your type

### Creating Custom Mappings Manually

For connection-specific types, create mapping files manually:

**File**: `config/field-mappings/bizfeature-scrum.jsonc`

```jsonc
{
  "logicalType": "MyFeature",
  "physicalType": "Feature",
  "processTemplate": "Scrum",
  "description": "Business feature for portfolio management",
  "logicalFields": {
    "id": "System.Id",
    "title": "System.Title",
    "description": "System.Description",
    "state": "System.State",
    "assignedTo": "System.AssignedTo",
    "businessValue": "Microsoft.VSTS.Common.BusinessValue",
    "releaseName": "MyScrum.ProductReleasePicklist"
  },
  "stateMapping": {
    "New": "New",
    "Active": "Active",
    "Done": "Resolved"
  },
  "priorityMapping": {
    "1": "1",
    "2": "2",
    "3": "3"
  },
  "requiredFields": ["id", "title", "state"],
  "defaultValues": {
    "state": "New",
    "priority": "2"
  }
}
```

## Permission Requirements

### Standard Users (Work Items - Read)

✅ **Available:**
- Automatic process template detection via work item type inference
- Querying with logical and physical type names
- Viewing work item type metadata

❌ **Not Available:**
- Direct process template API access (requires Collection Admin)

### Collection Administrators

✅ **Additional Access:**
- Process template API for retrieving template hierarchy
- Full customization of process templates

**Note**: The tool works perfectly fine **without** Collection Admin permissions by using intelligent inference.

## Fallback Behavior

If process template detection fails (e.g., API issues, insufficient permissions):

```
1. Try to infer from work item types → USUALLY SUCCEEDS
   ↓ (if fails)
2. Check existing field mapping files → Use cached template
   ↓ (if fails)
3. Try all common templates → Scrum → CMMI → Basic → Agile
   ↓ (if fails)
4. Default to Agile template
```

You'll see log messages indicating which strategy succeeded:

```
[INFO] Process template detection based on 33 work item types resulted in: Scrum
```

## Troubleshooting

### Query Returns No Results

**Problem**: `--types "UserStory"` returns nothing in a Scrum organization

**Solution**: Verify the process template:
```bash
$ azdw metadata types --connection "MyConnection"
🔍 Inferred base process template: Scrum

# Scrum uses "Product Backlog Item", not "User Story"
# But "UserStory" logical type should still work!
```

If it still doesn't work, try the physical type directly:
```bash
$ azdw query --types "Product Backlog Item"
```

### Custom Type Not Recognized

**Problem**: Custom type like "MyFeature" doesn't map

**Solution**: Custom types are used as-is (no mapping needed). Query directly:
```bash
$ azdw query --types "MyFeature"
```

If you want a logical alias:
1. Create a custom mapping file: `myfeature-scrum.jsonc`
2. Define the logical type (e.g., "MyFeature" → "Feature")

### Wrong Process Template Detected

**Problem**: Tool detects "Agile" but organization uses Scrum

**Solution**: Manually specify the template:
```bash
$ azdw config generate --connection "MyConnection" --template "Scrum"
```

Then verify:
```bash
$ azdw config fieldmap list --connection "MyConnection"
```

## Best Practices

### 1. Use Logical Types for Cross-Connection Queries

✅ **Good:**
```bash
$ azdw query --types "UserStory" "Task" --state "Active"
```

⚠️ **Works but inefficient** (specifying both Scrum and Agile physical names):
```bash
$ azdw query --types "Product Backlog Item" "User Story"
```

**What happens:**
- Each connection resolves both type names
- Scrum connections: "Product Backlog Item" ✅ + "User Story" → resolves to "Product Backlog Item" ✅ (redundant)
- Agile connections: "Product Backlog Item" → resolves to "User Story" ✅ + "User Story" ✅ (redundant)
- **Result**: Works correctly but you're specifying the same logical concept twice

**Why use logical types instead:**
- More concise (`--types "UserStory"` instead of `--types "Product Backlog Item" "User Story"`)
- Clearer intent (you want user stories, not two different type names)
- Works consistently across all template variations

### 2. Backup Before Generating Mappings

Always backup before running `config generate`:
```bash
$ cp -r config/field-mappings config/field-mappings.$(date +%Y%m%d)
```

### 3. Customize Incrementally

Don't try to create all custom mappings at once:
1. Start with one custom type
2. Test thoroughly
3. Extend to other types

### 4. Document Custom Mappings

Add a README in your custom mapping directory:
```
config/field-mappings/
  README.md  ← Document your custom mappings
  bizfeature-scrum.jsonc
  userstory-scrum.jsonc
```

### 5. Use `metadata` Command for Discovery

Before creating custom mappings, explore what's available:
```bash
$ azdw metadata types --connection "MyConnection" --verbose
```

## Advanced Topics

### Unified Logical Model Across Organizations

Create a **consistent logical model** even when organizations use different physical types:

**Scenario**: 
- Organization A (Scrum): Uses "Product Backlog Item"
- Organization B (Agile): Uses "User Story"
- You want both to map to logical type "Requirement"

**Solution**:
1. Create `requirement-scrum.jsonc`:
   ```jsonc
   {
     "logicalType": "Requirement",
     "physicalType": "Product Backlog Item",
     "processTemplate": "Scrum",
     ...
   }
   ```

2. Create `requirement-agile.jsonc`:
   ```jsonc
   {
     "logicalType": "Requirement",
     "physicalType": "User Story",
     "processTemplate": "Agile",
     ...
   }
   ```

3. Query both with unified type:
   ```bash
   $ azdw query --types "Requirement"
   ```

### Field-Level Mapping Customization

Map logical field names to organization-specific custom fields:

```jsonc
{
  "logicalFields": {
    "id": "System.Id",
    "title": "System.Title",
    "releaseVersion": "MyScrum.ProductReleasePicklist",  // Custom field
    "localizationRequired": "MyScrum.LocalizationRequired"  // Custom field
  }
}
```

Now queries and outputs use logical field names across all connections!

## Summary

The `azdw` mapping system provides:

✅ **Automatic**: Process template detection without special permissions  
✅ **Flexible**: Accept logical, physical, or custom type names  
✅ **Unified**: Query across different process templates consistently  
✅ **Customizable**: Define your own logical model  
✅ **Transparent**: Always shows actual Azure DevOps work item types in output

**Key Principle**: 
- **Input**: Accept any format (logical, physical, custom)
- **Processing**: Resolve to correct physical types
- **Output**: Show actual Azure DevOps work item type names

This design gives you maximum flexibility while maintaining clarity about what's actually in your Azure DevOps organizations.
