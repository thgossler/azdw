# Workflow Examples

Real-world Azure DevOps workflows using MCP tools or CLI commands.

---

## 1. Sprint Review: Gather Status

### MCP Approach

```
→ azdw_initialize_conversation
  (returns connections, user identity)

→ azdw_query_work_items
  connections: "myorg"
  workItemTypes: "User Story,Bug"
  states: "Active,Resolved"
  iterationPath: "MyProject\\Sprint 23"

→ azdw_generate_mermaid_kanban
  connectionName: "myorg"
  workItemIds: "101,102,103,104"
  title: "Sprint 23 Status"
```

### CLI Approach

```bash
azdw query --types "User Story",Bug --states Active,Resolved --iteration "MyProject\\Sprint 23" --connection myorg --json
azdw visualize --ids 101,102,103,104 --format mermaid
```

---

## 2. Bug Triage Workflow

### MCP Approach

```
→ azdw_initialize_conversation

→ azdw_query_work_items
  workItemTypes: "Bug"
  states: "New"
  connections: "myorg"

→ azdw_get_work_item
  workItemId: 5678
  connectionName: "myorg"
  (review details)

→ azdw_update_work_item          ⚠️ requires approval
  workItemId: 5678
  connectionName: "myorg"
  fieldUpdates: {"state": "Active", "assignedTo": "dev@example.com"}

→ azdw_approve_operation
  approvalToken: "<token>"
```

### CLI Approach

```bash
# List new bugs
azdw query --types Bug --states New --connection myorg --json

# Review a specific bug
azdw workitem get --id 5678 --json

# Update assignment and state
azdw workitem update 5678 --state Active --assigned-to "dev@example.com"
```

---

## 3. Create and Link Work Items

### MCP Approach

```
→ azdw_initialize_conversation

→ azdw_create_work_item          ⚠️ requires approval
  connectionName: "myorg"
  workItemType: "Task"
  title: "Implement caching layer"
  fields: {"description": "Add Redis caching", "assignedTo": "dev@example.com"}

→ azdw_approve_operation
  approvalToken: "<token>"
  (returns new work item ID 9001)

→ azdw_add_work_item_relationship  ⚠️ requires approval
  sourceWorkItemId: 9001
  targetWorkItemId: 8000
  connectionName: "myorg"
  relationshipType: "Child"

→ azdw_approve_operation
  approvalToken: "<token>"
```

### CLI Approach

```bash
# Create the task
azdw workitem create --type Task --title "Implement caching layer" --connection myorg --json

# Link child to parent (use the returned ID)
# (Use MCP for relationship management — stronger tooling)
```

---

## 4. Explore Work Item Hierarchy

### MCP Approach

```
→ azdw_initialize_conversation

→ azdw_find_work_item_closure
  workItemId: 42
  connectionName: "myorg"

→ azdw_generate_hierarchy_tree
  workItemIds: "42"
  connectionName: "myorg"
  (returns tree visualization)

→ azdw_generate_mermaid_gantt
  connectionName: "myorg"
  workItemIds: "42,43,44,45"
  title: "Epic 42 Timeline"
```

### CLI Approach

```bash
azdw relationship find-closure --id 42 --connection myorg --json
azdw visualize --ids 42 --format mermaid
```

---

## 5. Cross-Organization Query

### MCP Approach

```
→ azdw_initialize_conversation
  (verify multiple connections available)

→ azdw_query_work_items
  connections: "org1,org2,org3"
  workItemTypes: "Epic"
  states: "Active"

→ azdw_analyze_relationship_network
  connections: "org1,org2,org3"
  workItemTypes: "Epic"
```

### CLI Approach

```bash
azdw query --types Epic --states Active --connection org1,org2,org3 --json
```

---

## 6. Relationship Quality Check

### MCP Approach

```
→ azdw_initialize_conversation

→ azdw_find_orphan_work_items
  connections: "myorg"
  workItemTypes: "Task,Bug"

→ azdw_find_circular_dependencies
  connections: "myorg"

→ azdw_validate_relationship_policies
  connections: "myorg"
```

### CLI Approach

```bash
azdw relationship analyze --connection myorg --json
```

---

## 7. Generate a Status Report

### MCP Approach

```
→ azdw_initialize_conversation

→ azdw_query_work_items
  connections: "myorg"
  states: "Active,Resolved"
  modifiedAfter: "2025-01-01"

→ azdw_list_report_templates

→ azdw_generate_report
  templateName: "status-report"
  connectionName: "myorg"
  format: "markdown"
```

### CLI Approach

```bash
azdw query --states Active,Resolved --modified-after 2025-01-01 --connection myorg --json
azdw report --template status-report --format markdown
```

---

## 8. AI-Powered Work Item Analysis

### MCP Approach

```
→ azdw_initialize_conversation

→ azdw_generate_closure_story
  workItemId: 42
  connection: "myorg"
  (returns narrative analysis with INVEST/SMART evaluation)
```

### CLI Approach

```bash
azdw ai-chat
# Then interactively ask: "Analyze the closure of work item 42"
```

---

## Linking Work Items (Relationships & Hyperlinks)

> See [Relationships-and-Linking.md](Relationships-and-Linking.md) for the
> friendly type names and full spec-file format.

### Add a parent/child link between two existing items (MCP)

```
→ azdw_AddWorkItemRelationship
  sourceId: 105
  targetId: 42
  relationType: "Parent"      # 105's parent becomes 42
  sourceConnection: "myorg"
  (⚠️ requires approval)
```

### Link two items that live in different connections (cross-org)

```
→ azdw_AddWorkItemRelationship
  sourceId: 105
  targetId: 900
  relationType: "Related"
  sourceConnection: "orgA"
  targetConnection: "orgB"    # set targetConnection for cross-connection links
  (⚠️ requires approval)
```

### Attach an arbitrary URL (e.g. an external GitHub issue) as a hyperlink

```
→ azdw_AddWorkItemHyperlink
  sourceId: 42
  url: "https://github.com/acme/repo/issues/17"
  connection: "myorg"
  comment: "Tracking issue"
  (⚠️ requires approval)
```

CLI equivalent:

```bash
azdw workitem update 42 \
  --add-hyperlink "https://github.com/acme/repo/issues/17" \
  --hyperlink-comment "Tracking issue" \
  --connection myorg --json
```

### Bulk backfill relationships on existing items (relations-only spec file)

`links.jsonc` — note: no `fields`, only `id` + `relations`/`parent`:

```jsonc
{
  "workItems": [
    { "id": 105, "parent": { "targetId": 42 } },
    { "id": 106, "parent": { "targetId": 42 },
      "relations": [ { "type": "Successor", "targetId": 105 } ] }
  ]
}
```

```bash
azdw workitem update --from-file links.jsonc --connection myorg --dry-run --json
azdw workitem update --from-file links.jsonc --connection myorg --json
```

MCP equivalent:

```
→ azdw_UpsertWorkItemsBatch
  workItemsJson: "<contents of links.jsonc>"
  connection: "myorg"
  (⚠️ requires approval)
```

### Create a hierarchy in one batch with symbolic refs

`tree.jsonc` — `sourceRef`/`targetRef` link items created in the same batch:

```jsonc
{
  "workItems": [
    { "sourceRef": "epic", "workItemType": "Epic",
      "fields": { "System.Title": "Checkout revamp" } },
    { "sourceRef": "story", "workItemType": "User Story",
      "fields": { "System.Title": "Guest checkout" },
      "parent": { "targetRef": "epic" } },
    { "workItemType": "Task",
      "fields": { "System.Title": "Wire up API" },
      "parent": { "targetRef": "story" },
      "relations": [ { "type": "Successor", "targetRef": "story" } ] }
  ]
}
```

```bash
azdw workitem create --from-file tree.jsonc --connection myorg --json
```

---

## Working with GitHub / GitHub Enterprise Issues

> See [GitHub-Issues.md](GitHub-Issues.md) for provider routing, field mapping,
> and caching details.

### Create a GitHub issue (same tools, GitHub connection)

```
→ azdw_CreateWorkItem
  connection: "myGitHub"        # a GitHub/GHE connection
  workItemType: "Bug"           # mapped to a GitHub label
  title: "Login fails on Safari"
  description: "Steps to reproduce…"
  (⚠️ requires approval)
```

### Expand linked GitHub issues into an ADO closure

```
→ azdw_FindClosure
  workItemIds: "42"
  connection: "myorg"
  hyperlinksAs: "Child"                 # treat hyperlinked issues as children
  bidirectionalHyperlinksGitHub: true   # also discover GitHub issues linking back
  outputFile: "closure-42.json"
```

CLI equivalent:

```bash
azdw relationship find-closure --id 42 --connection myorg \
  --hyperlinks-as Child --bidirectional-hyperlinks-github --json
```

---

## Tips

- **Always initialize first**: Call `azdw_initialize_conversation` before any other MCP tool.
- **Use JSON output**: Add `--json` for CLI commands when parsing results programmatically.
- **Batch queries**: Use comma-separated IDs or connections to reduce round-trips.
- **Approval workflow**: Operations that modify data (create, update, delete, add/remove relationships) require explicit approval when using MCP with `--client-approvals`.
- **Cross-org support**: Most tools accept multiple connections for cross-organization queries.
