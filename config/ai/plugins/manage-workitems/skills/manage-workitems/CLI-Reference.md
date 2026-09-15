# CLI Command Reference

Complete reference for `azdw` CLI commands. Use these when MCP tools are not available.

**Tip**: Always add `--json` for machine-readable output when parsing results programmatically.

---

## Table of Contents

- [query](#query)
- [wiql](#wiql)
- [workitem](#workitem)
- [connection](#connection)
- [credential](#credential)
- [relationship](#relationship)
- [report](#report)
- [visualize](#visualize)
- [metadata](#metadata)
- [cache](#cache)
- [config](#config)
- [mcp](#mcp)
- [ai-chat](#ai-chat)

---

## Global Options

These options apply to all commands:

| Option | Description |
| ------ | ----------- |
| `--json` | Machine-readable JSON output |
| `-v`, `--verbose` | Enable verbose logging output |
| `--silent` | Suppress informational messages, show only data output |
| `--decode-values` | Decode HTML entities in field values for readable output |
| `--remove-html-tags` | Remove HTML tags from field values for plain text output (implies `--decode-values`) |
| `--raw-markdown` | Output markdown as plain text instead of formatted console output (for AI-generated content) |
| `--use-display-names` | Use display names instead of short names for virtual types (e.g., "Customer Requirement" instead of "CR") |
| `--skip-update-check` | Skip checking for a newer version on startup |
| `--no-caching` | Disable all caching for the entire program runtime |
| `--no-plugins` | Disable policy/enforcement plugins (e.g., for bulk imports that set non-initial states; pair with `workitem create --bypass-rules`) |

**For AI agents**: Prefer `--json` and `--silent` to get clean, parseable output. Add `--remove-html-tags` when displaying field values to users.

---

## query

Query work items across Azure DevOps connections.

```
azdw query [options]
```

**Key Options**:
| Option | Description |
| ------ | ----------- |
| `--types <TYPES>` | Work item types (e.g., Bug, Task, "User Story") |
| `--states <STATES>` | States to filter (e.g., Active, New, Resolved) |
| `--states-exclude <STATES>` | States to exclude (e.g., Closed, Removed) |
| `--assigned-to <USERS>` | Filter by assigned user |
| `--area <PATHS>` | Filter by area path |
| `--iteration <PATHS>` | Filter by iteration path |
| `--tags <TAGS>` | Filter by tags |
| `--field <FILTERS>` | Custom field filter: "field:operator:value" |
| `--created-after <DATE>` | Items created after date (YYYY-MM-DD) |
| `--modified-after <DATE>` | Items modified after date |
| `--ids <IDS>` | Specific work item IDs |
| `--limit <COUNT>` | Maximum results |
| `--connection <NAMES>` | Specific connections (default: all) |
| `--sort <COLUMN[:ORDER]>` | Sort by column (e.g., "ChangedDate:desc") |
| `--relationships` | Include relationships in results |
| `--json` | Machine-readable JSON output |

**Examples**:
```bash
# List all active bugs
azdw query --types Bug --states Active --json

# Find items assigned to me, sorted by recent changes
azdw query --assigned-to "me@example.com" --sort "ChangedDate:desc" --json

# Query across specific connections
azdw query --types Task --states Active --connection org1,org2 --json

# Filter by area path and tags
azdw query --area "ProjectName/Team1" --tags "priority-1" --json

# Get last 5 recently changed items
azdw query --sort "ChangedDate:desc" --limit 5 --json

# Custom field filter
azdw query --field "priority:equals:1" --json
```

---

## wiql

Execute WIQL (Work Item Query Language) queries across connections.

```
azdw wiql <QUERY> [options]
```

**Key Options**:
| Option | Description |
| ------ | ----------- |
| `--connection <NAMES>` | Specific connections |
| `--limit <COUNT>` | Maximum results |
| `--json` | Machine-readable JSON output |

**Examples**:
```bash
# Basic WIQL query
azdw wiql "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.State] = 'Active'" --json

# WIQL with ordering
azdw wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.WorkItemType] = 'Bug' ORDER BY [System.ChangedDate] DESC" --json
```

---

## workitem

Create, update, and delete work items.

### workitem get

Get a work item by ID.

```
azdw workitem get [options]
```

| Option | Description |
| ------ | ----------- |
| `--id <ID>` | Work item ID |
| `--connection <NAME>` | Connection name |
| `--json` | JSON output |

**Example**:
```bash
azdw workitem get --id 12345 --json
```

### workitem create

Create a new work item.

```
azdw workitem create [options]
```

| Option | Description |
| ------ | ----------- |
| `--type <TYPE>` / `-t` | Work item type (Bug, Task, "User Story", etc.). Required unless `--from-file`. |
| `--title <TITLE>` | Work item title. Required unless `--from-file`. |
| `--connection <NAME>` / `-c` | Connection name (**required**) |
| `--project <NAME>` / `-p` | Project name (optional if the connection is project-scoped, required if org-scoped) |
| `--description <DESC>` / `-d` | Description |
| `--assigned-to <USER>` / `-a` | Assignee |
| `--state <STATE>` / `-s` | Initial state (defaults to New) |
| `--area <PATH>` | Area path |
| `--iteration <PATH>` / `-I` | Iteration path |
| `--tags <TAGS>` | Tags (comma-separated) |
| `--field <NAME:VALUE>` / `--fields` | Custom fields as `FieldName:Value` (comma-separated) |
| `--comment <TEXT>` | Add a Discussion comment when creating |
| `--from-file <PATH>` / `-f` | Path or URL to a JSON/JSONC work item spec file; `--type`/`--title` optional |
| `--no-update` | Always create new work items; skip upsert existence check |
| `--force` | Allow upsert matching against any work item regardless of the `azdw` tracking tag |
| `--bypass-rules` | Create items directly in non-initial states. Requires the *Bypass rules on work item updates* permission. |
| `--dry-run` | Preview (simulate) without creating — use when the user says *simulate*, *what-if*, or *dry run* |
| `--reconcile` / `-r` | Populate per-item reconciliation data (effective fields, resolved IDs, `LocalSyncStatus`). Requires `--from-file`. |
| `--json` | JSON output |

> For bulk imports that set non-initial states, combine `--bypass-rules` with
> the global `--no-plugins` (skips policy-enforcement plugins). Always
> `--dry-run` first.

**Example**:
```bash
azdw workitem create --type Bug --title "Login page timeout" --connection myorg --json
```

### workitem update

Update an existing work item.

```
azdw workitem update <ID> [options]
```

| Option | Description |
| ------ | ----------- |
| `--state <STATE>` / `-s` | New state |
| `--title <TITLE>` | New title |
| `--description <DESC>` / `-d` | New description |
| `--assigned-to <USER>` / `-a` | New assignee |
| `--area <PATH>` | New area path |
| `--iteration <PATH>` / `-I` | New iteration path |
| `--tags-add <TAGS>` | Tags to add (comma-separated) |
| `--tags-remove <TAGS>` | Tags to remove (comma-separated) |
| `--field <NAME:VALUE>` / `--fields` | Custom fields to update as `FieldName:Value` (comma-separated) |
| `--comment <TEXT>` | Add a Discussion comment (supplements field updates) |
| `--add-hyperlink <URL>` | Add a native Hyperlink to an arbitrary URL (e.g. an external GitHub issue). Repeatable. |
| `--remove-hyperlink <URL>` | Remove a Hyperlink matching the given URL. Repeatable. |
| `--hyperlink-comment <TEXT>` | Comment stored on hyperlinks added via `--add-hyperlink` |
| `--connection <NAME>` / `-c` | Connection name |
| `--from-file <PATH>` | Path or URL to a JSON/JSONC spec file (inline field options become overrides) |
| `--upsert` | Create items that do not yet exist when using `--from-file` (entries need type and title) |
| `--bypass-rules` | Bypass work item rules so the item can move directly to any state. Requires the *Bypass rules on work item updates* permission. |
| `--dry-run` | Preview (simulate) without updating — use when the user says *simulate*, *what-if*, or *dry run* |
| `--reconcile` / `-r` | Populate per-item reconciliation data. Requires `--from-file`. |
| `--json` | JSON output |

> A **relations-only** spec file (entries with `id` + `relations` and no
> `fields`) applied via `workitem update --from-file` is the efficient way to
> backfill relationships/hyperlinks on existing items. See
> [Relationships-and-Linking.md](Relationships-and-Linking.md).

**Example**:
```bash
azdw workitem update 12345 --state Active --json
```

### workitem delete

Delete a work item.

```
azdw workitem delete <ID> [options]
```

| Option | Description |
| ------ | ----------- |
| `--connection <NAME>` | Connection name |

**Example**:
```bash
azdw workitem delete 12345 --connection myorg
```

### workitem open-url

Open work item(s) in the default browser.

```
azdw workitem open-url [options]
```

| Option | Description |
| ------ | ----------- |
| `--id <ID>` | Work item ID |

---

## connection

Manage Azure DevOps connections.

### connection list

List all configured connections.

```
azdw connection list [options]
```

| Option | Description |
| ------ | ----------- |
| `--json` | JSON output |

**Example**:
```bash
azdw connection list --json
```

### connection add

Add a new Azure DevOps connection interactively.

```
azdw connection add
```

### connection remove

Remove a connection.

```
azdw connection remove <NAME>
```

### connection test

Test connection health and authentication.

```
azdw connection test [options]
```

| Option | Description |
| ------ | ----------- |
| `--connection <NAME>` | Specific connection (tests all if omitted) |

**Example**:
```bash
azdw connection test
```

---

## credential

Manage authentication credentials for connections.

### credential add-pat

Add a Personal Access Token for a connection.

```
azdw credential add-pat [options]
```

| Option | Description |
| ------ | ----------- |
| `--connection <NAME>` | Connection name |

### credential repair

Diagnose and repair corrupted credentials.

```
azdw credential repair
```

---

## relationship

Manage and analyze work item relationships across connections. Subcommands:
`find-closure`, `resolve`, `analyze`, `validate`, `find-orphans`,
`find-circular`.

> For creating relationships/hyperlinks, there is **no** `relationship add`
> command — create links via a spec file (`workitem create/update --from-file`)
> or the MCP relationship/hyperlink tools, or attach a hyperlink with
> `workitem update --add-hyperlink`. See
> [Relationships-and-Linking.md](Relationships-and-Linking.md).

### relationship find-closure

Find the complete hierarchy closure for one or more work items (Azure DevOps or
GitHub / GHE).

```
azdw relationship find-closure [options]
```

| Option | Description |
| ------ | ----------- |
| `--ids <ID>` / `--id` / `-i` | Work item ID(s), comma-separated (**required**) |
| `--connection <NAME>` / `-c` | Connection name (**required**) |
| `--top-type <TYPE>` / `-t` | Top-level type to traverse to (uses configured default) |
| `--no-siblings` | Exclude siblings at all levels |
| `--include-top-siblings` | Include siblings of top-level items (mutually exclusive with `--no-siblings`) |
| `--include-predecessors` | Include predecessor relationships |
| `--no-resolve-hyperlinks` | Disable hyperlink resolution (enabled by default) |
| `--resolve-field-refs` | Resolve work item refs from configured custom fields |
| `--resolve-file-content` | Extract field values from file content via configured regex patterns |
| `--hyperlinks-as <TYPE>` | Treat resolved hyperlinks as `Parent`, `Child`, `Dependency`, or `Related`. Use `Parent`/`Child` to expand the linked hierarchy. |
| `--no-bidirectional-hyperlinks` | Disable reverse (cross-connection) hyperlink discovery (enabled by default) |
| `--bidirectional-hyperlinks-github` | Enable **GitHub** reverse discovery: enumerate GitHub issues and scan bodies for links pointing to closure items (off by default; independent of `--no-bidirectional-hyperlinks`) |
| `--no-cross-conn` | Disable cross-connection relationship resolution (enabled by default) |
| `--limit-conns <NAME>` | Limit cross-connection resolution to specific connections |
| `--max-size <SIZE>` / `-m` | Maximum closure size, 1–10000 (default: 10000) |
| `--states-exclude <STATES>` | States to exclude (e.g. `Closed,Removed`) |
| `--exclude-disabled-types` | Exclude work item types disabled in the process template |
| `--format <FORMAT>` / `-f` | Output format: `json`, `table`, `csv` (default: table) |
| `--output <PATH>` / `-o` | Output file path |
| `--json` | JSON output |

**Example**:
```bash
azdw relationship find-closure --id 42 --connection myorg --json
# Expand linked GitHub issues into the hierarchy
azdw relationship find-closure -i 1 -c myGitHub --hyperlinks-as Child --json
```

### relationship resolve

Resolve relationships for work items with cross-connection support (does not
walk a full hierarchy like `find-closure`).

```
azdw relationship resolve [options]
```

| Option | Description |
| ------ | ----------- |
| `--ids <ID>` / `--id` / `-i` | Work item IDs (**required**) |
| `--connection <NAME>` / `-c` | Connection name (**required**) |
| `--max-depth <DEPTH>` / `-d` | Maximum relationship depth to traverse |
| `--relationship-types <TYPE>` / `-r` | Types to include (e.g. Hierarchy, Dependency, Related) |
| `--no-cross-conn` | Disable cross-connection relationships (enabled by default) |
| `--no-resolve-hyperlinks` | Disable hyperlink resolution (enabled by default) |
| `--hyperlinks-as <TYPE>` | Interpret hyperlinks as `Parent`, `Child`, `Related`, or `Dependency` |
| `--no-bidirectional-hyperlinks` | Disable bidirectional hyperlink search (enabled by default) |
| `--resolve-field-refs` | Resolve work item refs from configured custom fields |
| `--resolve-file-content` | Apply file content extraction patterns |
| `--limit-conns <NAMES>` | Limit resolution to specific connections |
| `--states-exclude <STATES>` | States to exclude |
| `--format <FORMAT>` / `-f` | Output format: `json`, `table`, `csv` (default: table) |
| `--output <PATH>` / `-o` | Output file path |

### relationship analyze

Analyze relationship patterns and metrics for a set of work items.

```
azdw relationship analyze [options]
```

### relationship validate

Validate work item relationships against configured relationship policies.

```
azdw relationship validate [options]
```

### relationship find-orphans

Find orphaned work items that have no relationships. Requires relationships to
be loaded internally — an item with none is reported as an orphan.

```
azdw relationship find-orphans [options]
```

| Option | Description |
| ------ | ----------- |
| `--connections <NAMES>` / `-c` | Connection names to search (**required**) |
| `--types <TYPES>` / `-t` | Filter by work item types |
| `--states <STATES>` / `-s` | Filter by work item states |
| `--limit <COUNT>` / `--max` | Maximum items to query (default: 1000) |
| `--output <PATH>` / `-o` | Output file path (JSON) |

### relationship find-circular

Find circular dependency chains in work item relationships.

```
azdw relationship find-circular [options]
```

| Option | Description |
| ------ | ----------- |
| `--connections <NAMES>` / `-c` | Connection names to search (**required**) |
| `--types <TYPES>` / `-t` | Filter by work item types |
| `--states <STATES>` / `-s` | Filter by work item states |
| `--limit <COUNT>` / `--max` | Maximum items to query (default: 1000) |
| `--filter-related` | Apply type/state filters to related items too |
| `--output <PATH>` / `-o` | Output file path (JSON) |

---

## report

Generate reports and visualizations from work item data.

```
azdw report [options]
```

| Option | Description |
| ------ | ----------- |
| `--template <NAME>` | Template name |
| `--connection <NAMES>` | Connections |
| `--format <FORMAT>` | Output format |
| `--json` | JSON output |

**Example**:
```bash
azdw report --template status-report --json
```

---

## visualize

Generate visualizations of work item relationships.

```
azdw visualize [options]
```

| Option | Description |
| ------ | ----------- |
| `--ids <IDS>` | Work item IDs |
| `--format <FORMAT>` | Format: mermaid, graphviz, graphml |
| `--connection <NAME>` | Connection name |

**Examples**:
```bash
# Mermaid flowchart
azdw visualize --ids 42 --format mermaid

# Graphviz DOT
azdw visualize --ids 42,43,44 --format graphviz
```

---

## metadata

Display work item metadata (types, fields, states).

```
azdw metadata [command] [options]
```

**Subcommands**: `types`, `fields`, `states`

**Example**:
```bash
azdw metadata types --connection myorg --json
```

---

## cache

Manage cache operations.

```
azdw cache [command]
```

**Subcommands**: `status`, `clear`, `refresh`

**Example**:
```bash
azdw cache status
```

---

## config

Manage configuration (field mappings, URL mappings, paths, shell completions, AI).

```
azdw config [command]
```

**Subcommands**: `field-map`, `url-map`, `paths`, `shell-completions`, `ai`

---

## mcp

Start MCP (Model Context Protocol) server for AI assistant integration.

```
azdw mcp [options]
```

| Option | Description |
| ------ | ----------- |
| `--client-approvals` | Enable client-side approval workflow (recommended) |

**Example**:
```bash
azdw mcp --client-approvals
```

---

## ai-chat

Interactive AI-powered chat for Azure DevOps work item management.

```
azdw ai-chat [options]
```

| Option | Description |
| ------ | ----------- |
| `--record` | Save transcript to ~/.azdw/chats/ |

**Example**:
```bash
azdw ai-chat
```
