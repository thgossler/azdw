---
title: Custom Node Fields in Visualizations
nav_order: 150
---

# Custom Node Fields in Visualizations

## Overview

The `--node-fields` option allows you to specify additional Azure DevOps work item fields to display in visualization nodes. This provides richer context directly in the diagram without needing to open Azure DevOps.

## Usage

```bash
azdw visualize graph --ids <id> --connection <name> --node-fields <field1> <field2> ...
```

## Common Fields

### System Fields

- `System.State` - Current work item state (e.g., "Active", "Resolved", "Closed")
- `System.AssignedTo` - Person assigned to work item (displays as "Last, First")
- `System.AreaPath` - Area path hierarchy
- `System.IterationPath` - Sprint/iteration assignment
- `System.CreatedBy` - Person who created work item
- `System.ChangedDate` - Last modification date
- `System.Tags` - Work item tags
- `System.Priority` - Priority value
- `Microsoft.VSTS.Common.Severity` - Severity level (Bug)
- `Microsoft.VSTS.Scheduling.StoryPoints` - Story points estimate

### Custom Fields

Custom fields follow the pattern `Custom.FieldName` or `YourOrg.FieldName` depending on your organization's field naming convention.

## Examples

### Display State and Assignee

```bash
azdw visualize graph --ids 2161 --connection Portfolio \
  --node-fields System.State System.AssignedTo \
  --output relationships.dot
```

**Result:** Each node shows:
```
#2161
Feature
Improve order processing
contoso-portfolio/Delivery
State: Active
AssignedTo: Alex Smith
```

### Multiple Fields

```bash
azdw visualize graph --ids 2161 --connection Portfolio \
  --node-fields System.State System.AssignedTo System.AreaPath System.Priority \
  --output detailed-view.dot
```

### Custom Organization Fields

```bash
azdw visualize graph --ids 123 --connection MyOrg \
  --node-fields System.State Custom.RiskLevel Custom.ComplianceStatus \
  --output compliance-view.dot
```

## Field Value Display

### Simple Values

String, number, and boolean fields display directly:
- `State: Active`
- `Priority: 2`

### Complex Objects

For fields containing JSON objects (like `AssignedTo`), the tool extracts the `displayName` property:
- `AssignedTo: {"displayName": "Smith, John", ...}` → `AssignedTo: Smith, John`

### Truncation

Field values are truncated at 40 characters to maintain readable node sizes:
- `AreaPath: Delivery\Product Management\Order Processing\...`

### Field Name Display

The field name is extracted from the full path:
- `System.State` → displays as `State: Active`
- `Custom.RiskLevel` → displays as `RiskLevel: High`

## Behavior

### Missing Fields

Non-existent or empty fields are silently skipped. No error is reported.

### Source vs Target Fields

Custom fields are extracted from both source and target work items in relationships. If a field is missing from a target work item (e.g., not queried by Azure DevOps), it won't appear.

### Performance

Field extraction adds minimal overhead since fields are retrieved as part of the standard work item query.

## Integration with Other Features

### Color Maps

Custom node fields work seamlessly with `--color-map`:

```bash
azdw visualize graph --ids 2161 --connection Portfolio \
  --color-map config/my-colors.json \
  --node-fields System.State System.AssignedTo \
  --output styled-detailed.dot
```

### Layout Options

Custom fields display correctly with all layout options:

```bash
azdw visualize graph --ids 2161 --connection Portfolio \
  --layout tree --direction lr \
  --node-fields System.State System.Priority \
  --output tree-view.dot
```

### Output Formats

Currently, custom node fields are supported in GraphViz DOT format. Future versions may extend support to JSON visualization formats.

## Field Discovery

To discover available fields in your work items:

1. Query a work item in Azure DevOps
2. View the JSON representation (Developer Tools → Network → API response)
3. Look for field names in the `fields` property
4. Use the full field name (e.g., `System.State`, not just `State`)

## Best Practices

1. **Start with essential fields** - Too many fields make nodes cluttered
2. **Use 2-4 fields** - Good balance between detail and readability
3. **Consider your audience** - Technical fields for dev teams, business fields for stakeholders
4. **Test field names** - Ensure fields exist in your work item types before large queries
5. **Combine with filters** - Use `--target-types` and `--node-fields` together for focused views

## Limitations

- Maximum 40 characters displayed per field value
- Complex nested objects only show `displayName` property
- Date fields display in ISO format (not formatted)
- HTML field values display raw HTML (not rendered)
- Field availability depends on Azure DevOps query results

## Related Documentation

- [CLI Help Overview](CLI-Help-Overview.md) - All CLI options
- [Custom Color Maps](../config/colormap-example.jsonc) - Color customization examples
