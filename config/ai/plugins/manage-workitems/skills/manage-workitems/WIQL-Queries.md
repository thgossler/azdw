# WIQL Query Reference

Complete reference for Azure DevOps Work Item Query Language (WIQL) syntax,
operators, macros, and examples for use with `azdw query`, `azdw wiql`, and
the `azdw_ExecuteWiql` MCP tool.

> **Note**: This reference is optimized for the `azdw` tool and includes
> extensions that go beyond standard Azure DevOps WIQL. For example,
> `SELECT TOP N` is handled by `azdw` internally but is **not supported** by
> the Azure DevOps REST API or other tools. When writing WIQL for use outside
> `azdw`, verify syntax against the
> [official WIQL reference](https://learn.microsoft.com/en-us/azure/devops/boards/queries/wiql-syntax).

---

## Query Structure

```sql
SELECT [field1], [field2], ...
FROM WorkItems | WorkItemLinks
WHERE [conditions]
ORDER BY [field] ASC|DESC
ASOF 'date-time'
```

Use `SELECT TOP N` to limit results: `SELECT TOP 10 [System.Id], [System.Title] ...`

---

## Common Fields

Always include `[System.Id]` and `[System.Title]` in SELECT.

### Core Fields

| Field | Description |
| ----- | ----------- |
| `[System.Id]` | Work item ID |
| `[System.Title]` | Title |
| `[System.State]` | Current state (New, Active, Closed, etc.) |
| `[System.AssignedTo]` | Assigned user |
| `[System.WorkItemType]` | Type (Bug, Task, User Story, etc.) |
| `[System.AreaPath]` | Area path (organizational hierarchy) |
| `[System.IterationPath]` | Iteration/sprint path |
| `[System.Tags]` | Tags |
| `[System.Description]` | Description (plain text field) |
| `[System.TeamProject]` | Team project name |

### Date Fields

| Field | Description |
| ----- | ----------- |
| `[System.CreatedDate]` | When the item was created |
| `[System.ChangedDate]` | Last modification date |
| `[System.CreatedBy]` | Who created the item |
| `[System.ChangedBy]` | Who last changed the item |
| `[Microsoft.VSTS.Common.ClosedDate]` | When the item was closed |
| `[Microsoft.VSTS.Common.ResolvedDate]` | When the item was resolved |

### Scheduling Fields

| Field | Description |
| ----- | ----------- |
| `[Microsoft.VSTS.Scheduling.TargetDate]` | Target completion date |
| `[Microsoft.VSTS.Scheduling.StartDate]` | Planned start date |
| `[Microsoft.VSTS.Scheduling.FinishDate]` | Actual/planned finish date |
| `[Microsoft.VSTS.Scheduling.StoryPoints]` | Story points |

### Priority and Severity

| Field | Description |
| ----- | ----------- |
| `[Microsoft.VSTS.Common.Priority]` | Priority (1=Critical, 2=High, 3=Medium, 4=Low) |
| `[Microsoft.VSTS.Common.Severity]` | Severity level |

### Custom Fields

Custom fields use the `Custom.` prefix: `[Custom.MyField]`, `[Custom.RequestType]`

---

## FROM Clause

| Source | When to use |
| ------ | ----------- |
| `FROM WorkItems` | Query individual work items (most common) |
| `FROM WorkItemLinks` | Query relationships between work items (hierarchy/link queries) |

---

## WHERE Clause Operators

### By Field Type

| Field Type | Operators |
| ---------- | --------- |
| Comparison | `=`, `<>`, `>`, `<`, `>=`, `<=` |
| String | `=`, `<>`, `Contains`, `Not Contains`, `In`, `Not In`, `Was Ever` |
| Identity | `=`, `<>`, `Contains`, `In`, `In Group`, `Not In Group`, `Was Ever` |
| DateTime | `=`, `<>`, `>`, `<`, `>=`, `<=`, `In`, `Was Ever` |
| TreePath | `=`, `<>`, `Under`, `Not Under`, `In`, `Not In` |
| PlainText | `Contains Words`, `Not Contains Words`, `Is Empty`, `Is Not Empty` |
| Tags | `[System.Tags] CONTAINS 'tagname'` |

### Logical Operators

- `AND`, `OR`, `NOT`
- Use parentheses for grouping: `(condition1 OR condition2) AND condition3`

### Special Operators

| Operator | Usage | Example |
| -------- | ----- | ------- |
| `IN` | Match any value in list | `[System.State] IN ('Active', 'New')` |
| `UNDER` | Area/iteration path hierarchy | `[System.AreaPath] UNDER 'Project\Team1'` |
| `EVER` | Field ever had value | `EVER [System.AssignedTo] = 'John'` |
| `CONTAINS` | String contains substring | `[System.Title] CONTAINS 'critical'` |
| `Contains Words` | Full-text search (PlainText fields) | `[System.Description] Contains Words 'crash'` |
| `In Group` | Identity is member of group | `[System.AssignedTo] In Group '[Project]\Contributors'` |

---

## Macros and Variables

Use these instead of literal values for dynamic queries.

### User and Project

| Macro | Description |
| ----- | ----------- |
| `@Me` | Current user (for AssignedTo, CreatedBy, etc.) |
| `@Project` | Current project name |
| `@CurrentIteration` | Current sprint/iteration for the team |

### Date Macros

| Macro | Description |
| ----- | ----------- |
| `@Today` | Current date at midnight |
| `@Today-N` | N days ago (e.g., `@Today-7` for last week) |
| `@Today+N` | N days in future |
| `@StartOfDay` | Midnight of current day |
| `@StartOfWeek` | Start of current week |
| `@StartOfMonth` | First day of current month |
| `@StartOfYear` | First day of current year |

**Offset syntax**: `@StartOfMonth-3` (3 months ago), `@StartOfWeek('+1w')` (next week)

**Offset units**: `y`=year, `M`=month, `w`=week, `d`=day, `h`=hour, `m`=minute

---

## ORDER BY Clause

```sql
ORDER BY [field] ASC           -- Ascending (default)
ORDER BY [field] DESC          -- Descending
ORDER BY [field1] ASC, [field2] DESC  -- Multiple sort fields
```

---

## ASOF Clause (Historical Queries)

Returns work items as they were at a specific point in time.

```sql
SELECT ... FROM WorkItems WHERE ... ASOF '2025-01-01'
```

**Note**: ASOF is NOT compatible with tree/link queries (`FROM WorkItemLinks` with `MODE Recursive`).

---

## Link Queries (FROM WorkItemLinks)

For querying parent-child, related, or dependency relationships.

```sql
SELECT ... FROM WorkItemLinks
WHERE ([Source].[field] = value)
  AND ([System.Links.LinkType] = 'linktype')
  AND ([Target].[field] = value)
MODE (MustContain | MayContain | DoesNotContain | Recursive)
```

### Link Types

| Link Type | Description |
| --------- | ----------- |
| `System.LinkTypes.Hierarchy-Forward` | Parent → Child |
| `System.LinkTypes.Hierarchy-Reverse` | Child → Parent |
| `System.LinkTypes.Related` | Related items |
| `System.LinkTypes.Dependency-Forward` | Predecessor → Successor |
| `System.LinkTypes.Dependency-Reverse` | Successor → Predecessor |

### MODE Options

| Mode | Description |
| ---- | ----------- |
| `MustContain` | (Default) Source, link, and target criteria must all match |
| `MayContain` | Returns sources even if no matching targets |
| `DoesNotContain` | Returns sources only if NO targets match |
| `Recursive` | For tree hierarchies (requires Hierarchy-Forward link type) |

---

## Common Work Item Types

**Standard**: Bug, Task, User Story, Feature, Epic, Issue, Test Case, Product Backlog Item

**Custom types**: Use as-is (e.g., TechDebt, Spike, Requirement)

**Common states**: New, Active, Resolved, Closed, Removed, Done, In Progress, Approved, Committed

---

## Critical Rules for Writing WIQL

1. Always include `[System.Id]` and `[System.Title]` in SELECT
2. Include criteria-relevant fields in SELECT — if a field is used in WHERE,
   also include it in SELECT so it appears in output
3. Field order in SELECT: `[System.Id]`, `[System.Title]`,
   `[System.WorkItemType]`, `[System.State]` first, then additional fields
4. Add `[System.State] <> 'Removed'` to every query unless the user explicitly
   asks for removed items
5. Do NOT add other implicit filters — if user says "work items", include ALL
   types
6. For "open" or "active" items, use:
   `[System.State] NOT IN ('Closed', 'Resolved', 'Removed', 'Done')`
7. Use `@Me` for "assigned to me" or "my" queries
8. Use `@Today-N` for relative dates (e.g., "last week" = `@Today-7`)
9. Use `CONTAINS` for tag searches, `Contains Words` for description search
10. Use `UNDER` for area/iteration path hierarchies
11. Connection filtering is done externally by azdw, NOT in WIQL

---

## Examples

### Basic Queries

```sql
-- All bugs
SELECT [System.Id], [System.Title], [System.WorkItemType], [System.State]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [System.State] <> 'Removed'

-- Most recently changed 10 items
SELECT TOP 10 [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [System.ChangedDate]
FROM WorkItems
WHERE [System.State] <> 'Removed'
ORDER BY [System.ChangedDate] DESC

-- Open bugs assigned to me
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [System.AssignedTo]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [System.AssignedTo] = @Me
  AND [System.State] NOT IN ('Closed', 'Resolved', 'Removed', 'Done')
```

### Date and Scheduling Queries

```sql
-- Tasks changed in the last 30 days
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [System.ChangedDate]
FROM WorkItems
WHERE [System.WorkItemType] = 'Task'
  AND [System.ChangedDate] >= @Today-30
  AND [System.State] <> 'Removed'
ORDER BY [System.ChangedDate] DESC

-- Features created this week
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [System.CreatedDate]
FROM WorkItems
WHERE [System.WorkItemType] = 'Feature'
  AND [System.CreatedDate] >= @StartOfWeek
  AND [System.State] <> 'Removed'

-- Epics due in the next 90 days
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [Microsoft.VSTS.Scheduling.TargetDate]
FROM WorkItems
WHERE [System.WorkItemType] = 'Epic'
  AND [Microsoft.VSTS.Scheduling.TargetDate] >= @Today
  AND [Microsoft.VSTS.Scheduling.TargetDate] <= @Today+90
  AND [System.State] <> 'Removed'
ORDER BY [Microsoft.VSTS.Scheduling.TargetDate] ASC

-- Overdue items (target date in the past, still open)
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [Microsoft.VSTS.Scheduling.TargetDate]
FROM WorkItems
WHERE [Microsoft.VSTS.Scheduling.TargetDate] < @Today
  AND [System.State] NOT IN ('Closed', 'Resolved', 'Removed', 'Done')
ORDER BY [Microsoft.VSTS.Scheduling.TargetDate] ASC

-- Features without a target date
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [Microsoft.VSTS.Scheduling.TargetDate]
FROM WorkItems
WHERE [System.WorkItemType] = 'Feature'
  AND [Microsoft.VSTS.Scheduling.TargetDate] = ''
  AND [System.State] <> 'Removed'

-- Features with target dates in Q1 2026
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [Microsoft.VSTS.Scheduling.TargetDate]
FROM WorkItems
WHERE [System.WorkItemType] = 'Feature'
  AND [Microsoft.VSTS.Scheduling.TargetDate] >= '2026-01-01'
  AND [Microsoft.VSTS.Scheduling.TargetDate] <= '2026-03-31'
  AND [System.State] <> 'Removed'
ORDER BY [Microsoft.VSTS.Scheduling.TargetDate] ASC
```

### Priority, Tags, and Text Search

```sql
-- High priority bugs (priority 1 or 2)
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [Microsoft.VSTS.Common.Priority]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [Microsoft.VSTS.Common.Priority] IN (1, 2)
  AND [System.State] <> 'Removed'
ORDER BY [Microsoft.VSTS.Common.Priority] ASC

-- Items tagged with 'security'
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [System.Tags]
FROM WorkItems
WHERE [System.Tags] CONTAINS 'security'
  AND [System.State] <> 'Removed'

-- Bugs with 'crash' in the description
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [System.Description] Contains Words 'crash'
  AND [System.State] <> 'Removed'
```

### Area/Iteration Path and Group Queries

```sql
-- User stories under area path 'MyProject/TeamA'
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State]
FROM WorkItems
WHERE [System.WorkItemType] = 'User Story'
  AND [System.AreaPath] UNDER 'MyProject\TeamA'
  AND [System.State] <> 'Removed'

-- Items assigned to anyone in the Web Team
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [System.AssignedTo]
FROM WorkItems
WHERE [System.AssignedTo] In Group '[MyProject]\Web Team'
  AND [System.State] <> 'Removed'

-- Items ever assigned to John
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [System.AssignedTo]
FROM WorkItems
WHERE EVER [System.AssignedTo] = 'John'
  AND [System.State] <> 'Removed'
```

### Historical and Link Queries

```sql
-- State of bug 12345 on January 1st 2025
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State]
FROM WorkItems
WHERE [System.Id] = 12345
ASOF '2025-01-01'

-- All Epics and their child Features (hierarchy)
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State]
FROM WorkItemLinks
WHERE ([Source].[System.WorkItemType] = 'Epic')
  AND ([System.Links.LinkType] = 'System.LinkTypes.Hierarchy-Forward')
  AND ([Target].[System.WorkItemType] = 'Feature'
       AND [Target].[System.State] <> 'Removed')
MODE (Recursive)

-- Bugs resolved in the last 3 months
SELECT [System.Id], [System.Title], [System.WorkItemType],
  [System.State], [Microsoft.VSTS.Common.ResolvedDate]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [Microsoft.VSTS.Common.ResolvedDate] >= @StartOfMonth-3
```
