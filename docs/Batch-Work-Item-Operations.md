---
title: Batch Work Item Operations
nav_order: 100
---

# Batch Work Item Operations

`azdw` supports creating and updating many work items in one pass from a
structured JSON/JSONC **spec file**. This is the recommended approach for
reproducible project bootstrapping, sprint provisioning, work item hierarchies,
and AI-assisted authoring workflows.

---

## Spec File Format

A spec file is a JSON/JSONC array of work item definitions:

```jsonc
[
  {
    "sourceRef": "epic-1",           // symbolic reference for intra-batch linking
    "workItemType": "Epic",
    "title": "Improve checkout flow",
    "description": "All work related to the new checkout experience.",
    "areaPath": "MyProject\\Checkout",
    "fields": {
      "Custom.BusinessValue": "High"
    }
  },
  {
    "sourceRef": "story-1",
    "workItemType": "User Story",
    "title": "Redesign payment step",
    "parent": "epic-1",              // resolves to the Epic created above
    "relations": [
      { "type": "Related", "target": "story-2" }
    ]
  },
  {
    "sourceRef": "story-2",
    "workItemType": "User Story",
    "title": "Add Apple Pay support",
    "parent": "epic-1"
  }
]
```

See [`config/workitem-spec-example.jsonc`](../config/workitem-spec-example.jsonc)
for a full annotated example, and
[`config/workitem-spec-schema.json`](../config/workitem-spec-schema.json) for
the complete JSON Schema.

### Key Fields

| Field | Description |
| ----- | ----------- |
| `sourceRef` | Symbolic name for this item within the batch. Used in `parent` and `relations[].target` of other items. |
| `workItemType` | Work item type (e.g. `"User Story"`, `"Bug"`, `"Epic"`). |
| `title` | Work item title. |
| `description` | Markdown description. |
| `parent` | `sourceRef` of the parent item **within this batch**, or an integer ID for an existing item. |
| `relations` | Array of `{ "type": string, "target": sourceRef | id }` objects. |
| `areaPath` | Area path. |
| `iterationPath` | Iteration path. |
| `state` | Initial state. |
| `assignedTo` | Assignee (email or display name). |
| `tags` | Comma-separated tags. |
| `fields` | Arbitrary key/value pairs for custom or system fields. |

---

## CLI Usage

### Create work items from a spec file

```bash
# Dry-run first — preview without writing anything
azdw workitem create --connection myorg --from-file workitem-spec.jsonc --dry-run

# Execute the batch upsert
azdw workitem create --connection myorg --from-file workitem-spec.jsonc

# Execute and get reconciliation data (useful for updating local source files)
azdw workitem create --connection myorg --from-file workitem-spec.jsonc --reconcile --json
```

### Update work items from a spec file

```bash
# Preview changes
azdw workitem update --connection myorg --from-file updates.jsonc --dry-run

# Update with upsert (create items that do not yet exist)
azdw workitem update --connection myorg --from-file updates.jsonc --upsert

# Update and get reconciliation data
azdw workitem update --connection myorg --from-file updates.jsonc --reconcile --json
```

### Key CLI options

| Option | Description |
| ------ | ----------- |
| `--from-file <PATH>` | Path or HTTPS URL to a `.json`/`.jsonc` spec file. |
| `--dry-run` | Preview (simulate) without writing. Use when the user asks to *simulate* or *what-if*. |
| `--reconcile` / `-r` | Include per-item reconciliation data in the response. |
| `--no-update` | Always create new items; skip upsert existence check. |
| `--force` | Allow upsert matching against any work item regardless of the `azdw` tracking tag. |
| `--upsert` | (update only) Create items that do not yet exist. |

---

## MCP Tool Usage

### Basic batch upsert

```json
{
  "tool": "azdw_UpsertWorkItemsBatch",
  "connection": "myorg",
  "fromFile": "workitem-spec.jsonc"
}
```

### Simulate / preview (dry-run)

When the user asks to *simulate*, *preview*, *what-if*, or *dry run* the
operation, set `dryRun=true`:

```json
{
  "tool": "azdw_UpsertWorkItemsBatch",
  "connection": "myorg",
  "fromFile": "workitem-spec.jsonc",
  "dryRun": true
}
```

### Two-phase preflight approval workflow

Use `preflightValidation=true` to run a dry-run, receive an approval token, and
only execute writes after explicit confirmation:

**Step 1 — Stage the batch**:
```json
{
  "tool": "azdw_UpsertWorkItemsBatch",
  "connection": "myorg",
  "specJson": "[{\"workItemType\":\"Bug\",\"title\":\"Fix login timeout\"}]",
  "preflightValidation": true
}
```

Returns:
```json
{
  "requiresConfirmation": true,
  "approvalToken": "3fa85f64-...",
  "summary": { "total": 1, "willCreate": 1, "willUpdate": 0 }
}
```

**Step 2 — Execute after user approval**:
```json
{
  "tool": "azdw_ConfirmWorkItemsBatch",
  "approvalToken": "3fa85f64-...",
  "reason": "User confirmed the batch after review"
}
```

### Get per-item reconciliation data

Set `reconcile=true` to receive a `WorkItemReconciliation` block for each
processed item. This is useful when AI agents need to update local spec files
with the newly assigned IDs and resolved field values:

```json
{
  "tool": "azdw_UpsertWorkItemsBatch",
  "connection": "myorg",
  "fromFile": "workitem-spec.jsonc",
  "reconcile": true
}
```

Each result item includes:
```json
{
  "sourceRef": "story-1",
  "workItemId": 4567,
  "reconciliation": {
    "assignedId": 4567,
    "effectiveFields": { "System.Title": "Redesign payment step", "..." : "..." },
    "resolvedRelations": [{ "type": "Parent", "targetId": 1234 }],
    "syncStatus": "Created"
  }
}
```

`syncStatus` values: `Created`, `Updated`, `Skipped`, `Failed`.

---

## Intra-Batch Symbolic References (Two-Pass Execution)

When items reference each other via `sourceRef` / `parent` / `relations[]`, the
batch engine runs in **two passes**:

1. **Pass 1** — Creates/upserts all items and builds a `sourceRef → workItemId` map.
2. **Pass 2** — Resolves all `parent` and `relations[].target` references using
   the map and writes the relationships.

This means you can define a full hierarchy (Epic → Feature → User Story) in a
single spec file without pre-knowing any IDs.

---

## Common Workflows

### AI agent creates a sprint work item hierarchy

1. Agent authors a `workitem-spec.jsonc` with `sourceRef`/`parent` links.
2. Agent calls `azdw_UpsertWorkItemsBatch` with `dryRun=true` to preview.
3. Agent presents summary to user and asks for confirmation.
4. Agent calls `azdw_UpsertWorkItemsBatch` with `reconcile=true` to execute and
   capture assigned IDs.
5. Agent updates local spec file with the returned IDs for future reference.

### Reproduce a project template

```bash
# Apply template to a new project
azdw workitem create --connection myorg --project "NewProject" \
  --from-file templates/sprint-template.jsonc --reconcile --json > created.json
```

### Bulk update from a planning spreadsheet

Export to JSONC, then:

```bash
azdw workitem update --connection myorg \
  --from-file planning-updates.jsonc --upsert --dry-run
# Review output, then run without --dry-run
```

---

## See Also

- [`config/workitem-spec-example.jsonc`](../config/workitem-spec-example.jsonc) — Annotated spec file example
- [`config/workitem-spec-schema.json`](../config/workitem-spec-schema.json) — JSON Schema for spec files
- [MCP-Tools.md](../config/ai/plugins/manage-workitems/skills/manage-workitems/MCP-Tools.md) — Full MCP tool reference including batch tools
- [CLI-Reference.md](../config/ai/plugins/manage-workitems/skills/manage-workitems/CLI-Reference.md) — Full CLI command reference
