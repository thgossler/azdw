---
name: manage-workitems
description: >
  Manages Azure DevOps work items across multiple organizations using the azdw
  tool. Supports querying, creating, updating, visualizing, and creating reports
  for work items via MCP server tools or CLI commands. Use when the user
  mentions Azure DevOps, connections, work items, bugs, user stories, tasks,
  features, epics, backlog, sprint, iteration, WIQL, or 
  cross-organization/connection work item relationships.
---

# Azure DevOps Work Item Management with azdw

## Overview

`azdw` is a cross-platform CLI tool and MCP server for managing Azure DevOps
work items across multiple organizations and connections. Use this skill
whenever the user asks about:

- Azure DevOps work items (bugs, user stories, tasks, features, epics, etc.)
- Querying, creating, updating, or deleting work items
- Work item relationships and hierarchies across organizations
- Backlog management, sprint planning, iteration paths
- WIQL (Work Item Query Language) queries
- Work item visualization (Mermaid, Graphviz, GraphML)
- Reports and templates for work item data
- Azure DevOps connections and authentication

**Key capability**: `azdw` supports cross-organization relationship resolution —
it can traverse work item hierarchies that span multiple Azure DevOps
organizations.

## Choose Your Interface

**Always prefer MCP over CLI.** When `azdw_`-prefixed MCP tools are available in
your tool list, use them — they provide the richest integration. Fall back to
the CLI only when MCP tools are unavailable, and always add `--json` for
machine-readable output.

<!-- azdw:external-only:begin -->
**MANDATORY**: Always prefer MCP over CLI. **Do NOT use CLI commands if MCP can
be enabled.** Follow this decision tree strictly — do not skip steps:

```
STEP 1: Check for azdw_-prefixed tools in your tool list.
  → If found: Use MCP tools (see "Core Operations (MCP)" below). DONE.

STEP 2: No MCP tools found. Check if azdw CLI is installed:
  $ which azdw   (Linux/macOS)
  $ where.exe azdw   (Windows cmd)
  $ Get-Command azdw   (PowerShell)
  → If not found: Follow "First-Time Setup" to install azdw. STOP.

STEP 3: azdw is installed but MCP tools are missing.
  *** YOU MUST RUN MCP SETUP NOW — do NOT skip to CLI. ***
  → Run: azdw mcp init <your-client> --apply
    (see "Enabling the MCP Server" below for details)
  → Tell the user to restart/reload their AI client.
  → STOP HERE. Do NOT proceed with CLI commands.
  → After the user restarts, MCP tools will be available. Go to STEP 1.

STEP 4: ONLY if MCP setup in STEP 3 fails (command errors out or user declines):
  → Fall back to CLI (see "Core Operations (CLI Fallback)" below).
  → Always add --json for machine-readable output.
```

**MCP (preferred)**: Look for `azdw_`-prefixed tools in your available tool
list. If you see tools like `azdw_InitializeConversation`,
`azdw_QueryWorkItems`, etc., use MCP — it provides the richest integration.

**CLI (last resort only)**: Use CLI commands via bash **only after** MCP setup
has been attempted and failed. Always add `--json` for machine-readable output.

> **Note for GitHub Copilot CLI users**: If you installed this plugin via
> `copilot plugin install`, the MCP server should already be configured
> automatically (the plugin bundles `.mcp.json`). If `azdw_`-prefixed tools
> are still missing, restart Copilot CLI. If they are still missing after
> restart, run `azdw mcp init github-copilot-cli --apply` and restart again.

### Enabling the MCP Server

If `azdw` is installed but no `azdw_`-prefixed MCP tools are in your tool list,
**you must run MCP setup before doing anything else.** This is a one-time setup
that the user only needs to accept once.

1. **Detect your client**: Determine which AI client you are running in. Use the
   appropriate client identifier:
   - VS Code Copilot Chat → `github-copilot-vscode`
   - GitHub Copilot CLI → `github-copilot-cli`
   - Visual Studio Copilot → `github-copilot-vs`
   - Claude Desktop → `claude-desktop`
   - Cursor → `cursor`
   - Zed → `zed`
   - Goose → `goose`
   - Other → `generic` (or run `azdw mcp init --list` for all options)

2. **Apply the configuration** (creates a backup of the existing config file):
   ```bash
   azdw mcp init <client> --apply
   ```
   For example:
   ```bash
   azdw mcp init github-copilot-cli --apply
   ```
   If `--apply` fails because the config file is not at the default location,
   ask the user where their MCP client configuration file resides, then use
   `--path` to specify the location explicitly:
   ```bash
   azdw mcp init github-copilot-cli --apply --path "/path/to/mcp-config.json"
   ```

3. **Tell the user to reload**: After applying, the user must **restart their
   AI client / reload the window** so it picks up the new MCP server
   configuration. **STOP here — do NOT proceed with CLI commands. Wait for
   the user to restart.**

4. Once the MCP server is active, `azdw_`-prefixed tools will appear in your
   tool list. **Switch to the MCP workflow from that point on.**

> **Important**: Only fall back to CLI commands if `azdw mcp init --apply`
> fails or the user explicitly declines MCP setup. CLI is slower (spawns a
> process per command) and returns less structured data than MCP.

## First-Time Setup

The `azdw` CLI tool is **not bundled** with this plugin and must be installed
separately.

### Installation

1. **Check availability**: Run `which azdw` (Linux/macOS), `where.exe azdw`
   (Windows cmd), or `Get-Command azdw` (PowerShell)
2. **If not found**: Install `azdw` from one of these sources:
   - **GitHub releases**: Download from
     <https://github.com/thgossler/azdw/releases> (if exists)
   - **Client-specific download URL**: If provided by your organization, use the
     mentioned installer download URL (also shown by a previous installation's 
     `azdw --info --json` output field `downloadUrl`)
3. **Verify**: In a new shell run `azdw --version` to confirm the tool is in
   PATH

### Updating

Run `azdw update` to check for and install the latest version.

This skill was previously distributed under the longer name
`manage-azure-devops-workitems`. If an older skill folder with that name still
exists (e.g. `.github/skills/manage-azure-devops-workitems`,
`.claude/skills/manage-azure-devops-workitems`, or a corresponding plugin
registration), it MUST be removed so the skill is not discovered and loaded
twice with potentially deviating content. Running
`azdw config ai skills install` performs this cleanup automatically (prompting
for approval, or use `--force`); otherwise delete the stale long-name folder
manually.

### Post-Installation Configuration

1. **Check connections**: Run `azdw connection list` — if empty, run
   `azdw connection add` to configure at least one Azure DevOps connection using
   interactive browser sign-in to get started quickly, but tell the user they
   should change the connection config so that it uses PAT tokens to avoid
   repeated logins.
2. **Test**: Run `azdw connection test` to verify authentication works
<!-- azdw:external-only:end -->

## Important Constraints

- **Prefer MCP, fall back to CLI only when necessary**: If a task can be
  accomplished with the `azdw_`-prefixed MCP tools, you MUST use them. Only fall
  back to the `azdw` CLI (via bash) when the required functionality is genuinely
  unavailable as an MCP tool. Do not use the CLI merely for convenience or habit
  when an equivalent MCP tool exists.
- **Return results inline**: Prefer returning query and analysis results inline
  in the conversation rather than writing them to files. Don't write data to a
  file just to read it straight back.
- **The sandbox IS the workspace**: The azdw file tools operate within a
  sandboxed work directory that defaults to the current working directory (your
  workspace). It is NOT a separate hidden location. Use `azdw_GetWorkDirectory`
  if you need to know its absolute path.
- **Temp files are fine — inside the workspace only**: If creating a temporary
  file improves efficiency (e.g., writing a large result set to a file so you
  can `grep`/search it instead of holding it all in context), that is
  encouraged — but ONLY within the sandboxed work directory. Always pass a plain
  relative filename (e.g., `closure-1234.json`, `results.txt`) to
  `azdw_WriteFile`/`azdw_ReadFile`. Never write to, or read from, the system
  temp directory or any absolute path outside the workspace.
- **Never read externally-produced paths**: Do NOT pass `azdw_ReadFile` an
  absolute path, a system temp path, or any path produced by tooling you did not
  invoke (e.g., AI-framework temp files such as `copilot-tool-output-*.txt`).
  Reading such files triggers an out-of-sandbox approval prompt and is almost
  never what the user wants.

## Core Operations (MCP)

When MCP tools are available, always start every conversation by calling
`azdw_InitializeConversation` first. This returns essential context including
available connections, user identity, and formatting rules.

### Essential workflow

1. **Initialize**: Call `azdw_InitializeConversation` — do this FIRST, every
   time
2. **Query**: Call `azdw_QueryWorkItems` with filters (types, states,
   assignedTo, etc.)
3. **Get details**: Call `azdw_GetWorkItem` with a specific work item ID
4. **Advanced queries**: Call `azdw_ExecuteWiql` only when the user provides
   explicit WIQL syntax (see [WIQL-Queries.md](WIQL-Queries.md) for syntax)

### Key MCP tools for querying

| Tool | When to use |
| ---- | ----------- |
| `azdw_InitializeConversation` | FIRST call in every conversation — returns connections, identity, rules |
| `azdw_QueryWorkItems` | Primary query tool — list, find, filter work items |
| `azdw_GetWorkItem` | Get a single work item by ID |
| `azdw_ExecuteWiql` | Only when user provides raw WIQL syntax |
| `azdw_GetCurrentUserIdentity` | When user says "my", "me", "assigned to me" |

### Key MCP tools for creating and modifying

| Tool | When to use | Approval |
| ---- | ----------- | -------- |
| `azdw_CreateWorkItem` | Create a new work item | Required |
| `azdw_UpdateWorkItem` | Update title, state, assignee, tags | Required |
| `azdw_DeleteWorkItem` | Delete a work item (shows relationships first) | Required |
| `azdw_UpsertWorkItemsBatch` | Batch-create or upsert work items from a JSON/JSONC spec file; supports `dryRun` (simulate), `preflightValidation` (staged approval), and `reconcile` | Required (or use `preflightValidation`) |
| `azdw_ConfirmWorkItemsBatch` | Execute a batch upsert staged by `azdw_UpsertWorkItemsBatch` with `preflightValidation=true` | n/a (token already approved) |

### Key MCP tools for relationships and analysis

| Tool | When to use |
| ---- | ----------- |
| `azdw_FindClosure` | Find the complete hierarchy for a work item (traverses to Epic level) |
| `azdw_GetWorkItemRelationships` | Get parent/child/related relationships |
| `azdw_AnalyzeRelationships` | Analyze relationship patterns and get insights |
| `azdw_AddWorkItemRelationship` | Add a relationship between two work items by ID (requires approval). Takes `sourceConnection` + optional `targetConnection` for cross-connection links. |
| `azdw_RemoveWorkItemRelationship` | Remove a relationship between two work items (requires approval) |
| `azdw_AddWorkItemHyperlink` | Add a native Hyperlink to an arbitrary URL (e.g. an external GitHub issue) (requires approval) |
| `azdw_RemoveWorkItemHyperlink` | Remove a Hyperlink matching a URL (requires approval) |

> For the spec-file relationship/hyperlink format, friendly type names, bulk
> backfill, and cross-org/cross-provider linking, see
> [Relationships-and-Linking.md](Relationships-and-Linking.md).

### Key MCP tools for visualization

| Tool | When to use |
| ---- | ----------- |
| `azdw_GenerateReport` | Generate reports using templates (Markdown, HTML, CSV, JSON) |
| `azdw_GenerateMermaidFlowchart` | Create Mermaid flowchart of work item relationships |
| `azdw_GenerateMermaidGantt` | Create Mermaid Gantt chart of work item timelines |
| `azdw_GenerateMermaidKanban` | Create Mermaid Kanban board of work item states |
| `azdw_GenerateAndSaveHierarchy` | Save hierarchy visualization to a DOT file |
| `azdw_VisualizeClosureGraph` | Render a saved closure as a graph using azdw-specific styling (call after `azdw_FindClosure` with outputFile) |

**Important for queries**: For "last N" or "recent" requests, always set
`sortBy='System.ChangedDate:desc'` in `azdw_QueryWorkItems`.

> For the complete catalog of all 82 MCP tools with parameters, see
> [MCP-Tools.md](MCP-Tools.md).

## Core Operations (CLI Fallback)

When MCP tools are not available, use the `azdw` CLI via bash. Always include
`--json` for machine-parseable output.

### Query work items

```bash
# List active bugs
azdw query --types Bug --states Active --json

# Find items assigned to a user
azdw query --assigned-to "user@example.com" --json

# Get recent items sorted by change date
azdw query --sort "ChangedDate:desc" --limit 10 --json

# Filter by multiple types and states
azdw query --types Bug,Task --states Active,New --json

# With spaces
azdw query --types "User Story" --states Active,New --json

# Multi-value examples (one comma-separated string, or multiple strings)
azdw query --types "Bug,User Story" --states Active,New --json
azdw query --types "Bug" "User Story" --states Active New --json
```

### Get a single work item

```bash
azdw workitem get --id 12345 --json
```

### Execute WIQL queries

```bash
azdw wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.State] = 'Active'" --json
```

### Create a work item

```bash
azdw workitem create --type Bug --title "Login page timeout" --connection myorg --json
```

### Update a work item

```bash
azdw workitem update 12345 --state Active --json
```

### Manage relationships

```bash
# Find complete hierarchy
azdw relationship find-closure --id 42 --json

# Visualize relationships (see Visualizing-Results.md for all formats)
azdw visualize graph --ids 42 --format mermaid-flowchart
```

### Connection management

```bash
# List connections
azdw connection list --json

# Test connection health
azdw connection test

# Add a new connection
azdw connection add
```

> For the complete CLI command reference, see
> [CLI-Reference.md](CLI-Reference.md).

## Connections: scope and project targeting

**Connection names are user-local and not stable.** The same Azure DevOps project
may be named differently by each user, so never assume or hard-code a connection
name. Identify a project by its **stable identity** — the Azure DevOps organization
+ project name (its base URL `https://dev.azure.com/<org>/<project>`) — and resolve
the local connection name at runtime: call `azdw_ListConnections` (MCP) or
`azdw connection list --json` (CLI) and match each entry's `url` / `projectName`.
Do **not** infer anything about a project from its *name* — a name is just a label,
not a statement about the project's content.

A connection has one of two **scopes** (visible as `scope` in the connection list):

- **Project-scoped** — `scope` is `Project`, `url` ends in `/<org>/<project>`, and
  `projectName` is set. It is bound to that one project; specifying the connection
  alone is sufficient.
- **Organization-scoped** — `scope` is `Organization`, `url` is the org only
  (`https://dev.azure.com/<org>`), and `projectName` is `null`. It can reach **any**
  project in that organization, so it is a valid way to work with a project even
  though no project is named in the connection — but you must then tell azdw which
  project to use.

**Targeting a project on an org-scoped connection** (schema-optional, but necessary
when the connection is org-scoped):

| Operation | How to specify the project |
| --------- | -------------------------- |
| MCP metadata & path tools (`azdw_GetWorkItemTypes`, `azdw_GetWorkItemFields`, `azdw_GetWorkItemStates`, `azdw_GetAreaPaths`, `azdw_GetIterationPaths`, `azdw_ListAreaPaths`, `azdw_ListIterationPaths`) | Pass the stable project name in the `project` parameter (optional for project-scoped connections, needed for org-scoped). |
| MCP `azdw_CreateWorkItem` | `project` is a **required** parameter — always pass the target project. |
| MCP `azdw_GetWorkItemTypeFields` | Has **no** `project` parameter; on an org-scoped connection use `azdw_GetWorkItemFields` (with `project`) or the CLI `metadata fields -p` instead. |
| CLI `metadata` commands (`fields`, `states`, `types`) and `workitem create` | Pass `-p, --project "<project>"` (optional if the connection is project-scoped, required if org-scoped). |
| WIQL (`azdw_ExecuteWiql` / `azdw wiql`) | No project parameter — add `AND [System.TeamProject] = '<project>'` to the `WHERE` clause. |
| `azdw_QueryWorkItems` / `azdw query` | Spans all projects of an org-scoped connection — narrow with an area-path filter, or isolate per project (`--by-project` / org-project columns in CLI). |
| `azdw_FindClosure` / `azdw_AnalyzeRelationships` / `relationship find-closure` | Work-item-ID-based — the project is implied by the IDs and cross-project resolution is automatic; no project selector needed. |

If no connection (project- or org-scoped) matches a needed org/project, tell the
user what is missing and suggest `azdw connection add` — do **not** guess a name.

## Common Workflows

### Query and summarize active work

**MCP**: Call `azdw_InitializeConversation`, then `azdw_QueryWorkItems` with
`states: "Active"` and present results as a formatted summary.

**CLI**: `azdw query --states Active --json` then parse and summarize the JSON
output.

### Create a work item from a description

**MCP**: Call `azdw_CreateWorkItem` with `type`, `title`, and optional fields.
The tool will request approval before creating.

**CLI**: `azdw workitem create --type Bug --title "Description" --connection
myorg --json`

### Explore work item hierarchy

**MCP**: Call `azdw_FindClosure` with the work item ID. This traverses up to the
top-level type (e.g., Epic) and returns all related items in the hierarchy.

**CLI**: `azdw relationship find-closure --id 42 --json`

### Visualize closure as a graph

**MCP**: Use the two-step pattern:
1. Call `azdw_FindClosure` with the work item ID and `outputFile` (e.g., `closure-42.json`).
2. Call `azdw_VisualizeClosureGraph` with `closureFile` = the returned `closureFile.relativePath` and an `outputFilename`.

This uses azdw-specific rendering with type colors, state labels, and relationship-type styling. Do **not** write DOT manually or call `azdw_RenderGraphviz` directly on hand-crafted content — that bypasses all azdw styling.

**CLI**: `azdw relationship find-closure --id 42 --format json --output closure.json`
then `azdw visualize graph --from-closure closure.json --format graphviz --output closure.dot`

### Create relationships and hyperlinks

Use the right tool for the scale of the change:

- **One or two ad-hoc links** between existing items → MCP
  `azdw_AddWorkItemRelationship` (by ID; set `targetConnection` for
  cross-connection links). For a link to an external **URL** (e.g. a GitHub
  issue), use `azdw_AddWorkItemHyperlink` / `azdw workitem update <id>
  --add-hyperlink <url>` — `azdw_AddWorkItemRelationship` is **ID-only** and
  cannot target a URL.
- **Many links, hierarchies, or backfilling** → a **spec file** with `parent`
  and `relations[]`, applied via `azdw_UpsertWorkItemsBatch` (or `workitem
  create/update --from-file`). A relations-only update (entries with `id` +
  `relations` and **no `fields`**) is the efficient way to backfill links.
- Always use **friendly type names** (`Parent`, `Child`, `Related`,
  `Successor`, `Predecessor`, `Hyperlink`, …), never raw `System.LinkTypes.*`.

> Full details — spec-file format, two-pass `sourceRef`/`targetRef` resolution,
> friendly-name → Azure DevOps semantics, bulk backfill, and cross-org /
> cross-provider linking — are in
> [Relationships-and-Linking.md](Relationships-and-Linking.md).

### Work with GitHub / GitHub Enterprise issues

GitHub and GHE connections are first-class providers — their **issues are work
items**. Use the **same** tools (`azdw_QueryWorkItems`, `azdw_GetWorkItem`,
`azdw_CreateWorkItem`, `azdw_UpdateWorkItem`, `azdw_FindClosure`, …) with a
GitHub connection; routing is automatic.

- Field mapping: type → label, state → open/closed, tags → labels; area path /
  iteration path / discussion comments are ignored.
- GitHub issues have **no native relationships** — cross-links live as body URLs
  / `#N` refs. `find-closure` extracts them as `Hyperlink` relations; use
  `--hyperlinks-as` / `hyperlinksAs` (`Parent`/`Child`/`Dependency`/`Related`)
  to expand them.
- WIQL, metadata, area/iteration filters, and capacity analysis are
  Azure-DevOps-only and are gracefully gated on GitHub (not failures).

> See [GitHub-Issues.md](GitHub-Issues.md) for field mapping, supported vs
> ADO-only operations, reverse hyperlink discovery, caching, and import gotchas.

### Generate a visual report

**MCP**: Call `azdw_GenerateMermaidFlowchart` or `azdw_GenerateReport` with a
template name.

**CLI**: `azdw visualize graph --ids 42 --format mermaid-flowchart` or
`azdw report generate --template status-report`

> For all visualization formats (GraphViz, GraphML, Mermaid variants) and
> options, see [Visualizing-Results.md](Visualizing-Results.md).

> To create custom report templates (including AI-assisted generation), see
> [Create-Report-Template.md](Create-Report-Template.md).

> For more workflow examples, see [Examples.md](Examples.md).

## Simulate / Preview / What-If Requests

When the user asks to **"simulate"**, **"preview"**, **"test run"**,
**"rehearsal"**, **"what-if"**, or **"dry run"** an operation, interpret these
as a request to preview changes **without making any writes to Azure DevOps**:

| User intent | MCP | CLI |
| ----------- | --- | --- |
| Single item create/update | The approval flow itself acts as a preview — present what would be created/updated and wait for explicit user confirmation | `--dry-run` |
| Batch upsert via spec file | Set `dryRun=true` in `azdw_UpsertWorkItemsBatch` | `--dry-run` with `workitem create --from-file` |
| Staged batch approval | Set `preflightValidation=true` in `azdw_UpsertWorkItemsBatch` to get an approval token, then call `azdw_ConfirmWorkItemsBatch` to execute | n/a |

**Rule**: Never use `dryRun=false` (the default) when the user's phrasing indicates they
only want to *see* what would happen, not *commit* the changes.

## Safety & Approvals

Write operations (create, update, delete, add/remove relationships) require
approval. When using MCP with `--client-approvals`:

1. You call the tool (e.g., `azdw_CreateWorkItem`)
2. The server returns an approval request with a token
3. Present the details to the user and ask for confirmation
4. Call `azdw_ApproveOperation` or `azdw_RejectOperation` with the token

**High-risk operations** — always warn the user before proceeding:
- `azdw_DeleteWorkItem` — permanently removes a work item
- `azdw_ClearAllConnections` — removes all configured connections
- `azdw_ClearAllCredentials` — removes all stored credentials
- Any bulk update affecting multiple work items

**Best practice**: Before delete operations, call
`azdw_GetWorkItemRelationships` first to show the user what relationships will
be affected.

## Specialities & Gotchas

Quick reference for behaviors that are easy to get wrong:

- **Friendly relationship names only** — pass `Parent`, `Child`, `Related`,
  `Successor`, `Predecessor`, `Hyperlink`, … (case-insensitive). Never pass raw
  `System.LinkTypes.*` reference names.
- **Fetch relationships before analyzing** — set `includeRelationships=true`
  (MCP) / `--relationships` (CLI) before orphan, closure, or network analysis,
  or every item looks orphaned.
- **Symmetric links double-count** — `Parent`/`Child`, `Successor`/`Predecessor`
  and `Related` are stored on both items; don't add the reverse, and expect raw
  counts ≈ 2× the logical link count.
- **Bulk relationship backfill** — use a relations-only spec file (`id` +
  `relations`, **no `fields`**) via `azdw_UpsertWorkItemsBatch` /
  `workitem update --from-file`, not one `azdw_AddWorkItemRelationship` per link.
- **Hyperlinks vs relationships** — `azdw_AddWorkItemRelationship` links by
  **ID** only; to point at a **URL** use `azdw_AddWorkItemHyperlink` /
  `--add-hyperlink` / a spec `hyperlink` relation with `targetUrl`.
- **Cross-connection links** — pass `targetConnection` (MCP) to link items in
  different organizations.
- **Read-only credentials** — a connection's PAT may lack write permission.
  `azdw` tracks per-connection write capability (shown as `[write]` /
  `[read-only]` in connection listings) and prefers write-capable connections.
  If a write reports read-only, pick a write-capable connection for that
  org/project rather than retrying.
- **Bulk import flags** — `--bypass-rules` allows creating items directly in
  non-initial states (needs the *Bypass rules on work item updates*
  permission); the global `--no-plugins` skips policy-enforcement plugins.
  Always `--dry-run` first.
- **GitHub specifics** — issues have no native relationships (links live in the
  body); WIQL/metadata/capacity are Azure-DevOps-only; issue numbers are never
  reused. See [GitHub-Issues.md](GitHub-Issues.md).

## Error Handling

### No connections configured
If `azdw connection list` returns empty or `azdw_ListConnections` shows no
connections:
- Recommend running `pwsh -File init.ps1 -SetupConnections` from the azdw tool
  directory
- Or use `azdw connection add` manually

### Expired credentials
If you get authentication errors:
- Run `azdw connection test` to diagnose which connection has issues
- Use `azdw credential add-pat` to re-authenticate with a Personal Access Token
- For corrupted credentials, try `azdw credential repair`

### Rate limiting
Azure DevOps has API rate limits. If you hit limits:
- Reduce query scope (add filters, use `--limit`)
- Wait before retrying
- Check `azdw cache status` — caching reduces API calls

### Partial success
`azdw` supports querying multiple organizations. When some succeed and others
fail:
- Present the successful results to the user
- Report which connections failed and why
- Suggest testing failed connections with `azdw connection test`

## Detailed References

For comprehensive details beyond this overview:

- [MCP-Tools.md](MCP-Tools.md) — complete catalog of all 82 MCP tools with
  parameters and usage notes
- [CLI-Reference.md](CLI-Reference.md) — full CLI command reference with all
  options and examples
- [Relationships-and-Linking.md](Relationships-and-Linking.md) — spec-file
  relationship/hyperlink format, friendly type names, bulk backfill, and
  cross-org / cross-provider (Azure DevOps ↔ GitHub) linking
- [GitHub-Issues.md](GitHub-Issues.md) — GitHub / GitHub Enterprise issues as
  work items: field mapping, supported vs ADO-only operations, hyperlink
  discovery, caching, and import gotchas
- [WIQL-Queries.md](WIQL-Queries.md) — WIQL syntax reference with operators,
  macros, and query examples
- [Visualizing-Results.md](Visualizing-Results.md) — all visualization formats
  (GraphViz, GraphML, Mermaid), layouts, relationship filtering, and examples
- [Create-Report-Template.md](Create-Report-Template.md) — guide for creating
  Scriban report templates (data model, syntax, AI generation, import)
- [Examples.md](Examples.md) — step-by-step workflow examples for common
  scenarios
