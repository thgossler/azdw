# MCP Tools Reference

Complete catalog of all 82 MCP tools exposed by the `azdw` MCP server, organized by category.

**Usage**: These tools are accessed via MCP protocol. Tool names use the `azdw_` prefix.

**Approval**: Tools marked with ⚠️ require user approval before execution.

---

## Table of Contents

- [Core](#core)
- [Query & Search](#query--search)
- [Create & Modify](#create--modify)
- [Relationships](#relationships)
- [Analysis & Insights](#analysis--insights)
- [Visualization & Reports](#visualization--reports)
- [Approvals](#approvals)
- [Templates](#templates)
- [Configuration & Admin](#configuration--admin)
- [File System & Rendering](#file-system--rendering)

---

## Core

These tools are always available and cannot be disabled.

### `azdw_InitializeConversation`

**CRITICAL**: Call this tool FIRST once at the start of EVERY conversation before any other azdw tool.

Returns essential Azure DevOps context and instructions needed for accurate assistance: available connections, user identity status, relationship guidance, and response formatting rules.

**Parameters**: None

**Returns**: Connection list, user identity, formatting rules, relationship guidance

---

### `azdw_ListConnections`

List configured Azure DevOps connections with URLs, projects, and auth status.

**Parameters**: None

**Returns**: Array of connections with name, URL, project, auth type, and status

---

### `azdw_ListToolCategories`

List tool categories and tools in each. Only shows currently enabled tools.

**Parameters**: None

**Returns**: Categories with their tools and enabled status

---

### `azdw_SelectToolCategories`

Enable or disable tool categories to focus on specific tools and reduce context overhead.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `categories` | string | Yes | Comma-separated list of categories to enable |

**Available categories**: Query, Modify, Relationships, Analysis, Visualization, Configuration, Approval, Templates, FileSystem. Core is always enabled.

---

## Query & Search

Primary tools for finding and retrieving work items.

### `azdw_QueryWorkItems`

**PRIMARY TOOL** for work items. Use for: list, show, find, get, query, last N, recent items.

**IMPORTANT**: For "last N" or "recent" requests, ALWAYS set `sortBy='System.ChangedDate:desc'`.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connections` | string | No | Comma-separated connection names (default: all) |
| `types` | string | No | Work item types to filter (e.g., "Bug,Task") |
| `states` | string | No | States to filter (e.g., "Active,New") |
| `statesExclude` | string | No | States to exclude (e.g., "Closed,Removed") |
| `assignedTo` | string | No | User email or display name |
| `areaPaths` | string | No | Area paths to filter by |
| `iterationPaths` | string | No | Iteration paths to filter by |
| `tags` | string | No | Tags to filter by |
| `ids` | string | No | Specific work item IDs |
| `maxResults` | integer | No | Maximum results to return |
| `sortBy` | string | No | Sort field and order (e.g., "System.ChangedDate:desc") |
| `includeRelationships` | boolean | No | Include work item relationships. For hierarchy, dependency, traceability, and linked-item requests this is often needed. Required for cross-connection and hyperlink expansion unless file relationships are requested. |
| `followExternalRelationships` | boolean | No | When `includeRelationships` is true, follow cross-connection relationships (default: `true`). Has no effect otherwise. |
| `resolveHyperlinks` | boolean | No | When `includeRelationships` is true, resolve hyperlinks to work items (default: `true`). Has no effect otherwise. |
| `hyperlinksAs` | string | No | When resolving hyperlinks, how to treat them: `Parent`, `Child`, or `Related`. |

---

### `azdw_GetWorkItem`

Get a work item by ID. Searches all connections if connection not specified.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id` | integer | Yes | Work item ID |
| `connection` | string | No | Connection name (searches all if omitted) |

---

### `azdw_ExecuteWiql`

**ADVANCED**: Execute raw WIQL (SQL-like) queries. Only use when user explicitly provides WIQL syntax. Prefer `azdw_QueryWorkItems` for normal requests.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `query` | string | Yes | WIQL query string |
| `connections` | string | No | Comma-separated connection names |
| `maxResults` | integer | No | Maximum results |

---

### `azdw_GetAreaPaths`

Get area paths (organizational hierarchy).

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `project` | string | No | Project name (optional) |
| `depth` | integer | No | Maximum depth |

---

### `azdw_GetConnectionSchema`

Get complete schema: work item types, fields, area/iteration paths.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |

---

### `azdw_GetFieldAllowedValues`

Get allowed values for a field (e.g., priority, severity).

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `field` | string | Yes | Field reference name or display name |

---

### `azdw_GetIterationPaths`

Get iteration paths (sprints, releases).

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `project` | string | No | Project name |
| `depth` | integer | No | Maximum depth |

---

### `azdw_GetWorkItemFields`

Get fields for a work item type.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `workItemType` | string | Yes | Work item type name |
| `project` | string | No | Project name (needed for org-scoped connections) |

---

### `azdw_GetWorkItemStates`

Get valid states for a work item type.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `workItemType` | string | Yes | Work item type name |
| `project` | string | No | Project name (needed for org-scoped connections) |

---

### `azdw_GetWorkItemTypeFields`

Get fields for a work item type including names, types, and allowed values.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `workItemType` | string | Yes | Work item type name |

> Note: this tool has **no** `project` parameter. For an org-scoped connection,
> use `azdw_GetWorkItemFields` (which accepts `project`) instead.

---

### `azdw_GetWorkItemTypes`

Get work item types with metadata.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `project` | string | No | Project name (needed for org-scoped connections) |

---

### `azdw_ListAreaPaths`

List area paths for a connection/project.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `project` | string | No | Project name |

---

### `azdw_ListIterationPaths`

List iteration paths (sprints) for a connection/project.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `project` | string | No | Project name |

---

### `azdw_ListStates`

List valid states for a work item type.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `workItemType` | string | Yes | Work item type name |

---

### `azdw_ListWorkItemTypes`

List work item types (Epic, Feature, Bug, etc.) for a connection.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |

---

## Create & Modify

Tools for creating, updating, and deleting work items. All require approval.

### `azdw_CreateWorkItem` ⚠️

Create a work item. Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `project` | string | Yes | Project name |
| `type` | string | Yes | Work item type (e.g., "Bug", "User Story") |
| `title` | string | Yes | Work item title |
| `description` | string | No | Work item description |
| `assignedTo` | string | No | User to assign to |
| `areaPath` | string | No | Area path |
| `iterationPath` | string | No | Iteration path |
| `state` | string | No | Initial state |
| `tags` | string | No | Comma-separated tags |
| `fields` | object | No | Additional fields as key-value pairs |

---

### `azdw_UpdateWorkItem` ⚠️

Update work item (title, state, assignee, tags). Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id` | integer | Yes | Work item ID |
| `connection` | string | No | Connection name |
| `title` | string | No | New title |
| `state` | string | No | New state |
| `assignedTo` | string | No | New assignee |
| `tags` | string | No | New tags |
| `fields` | object | No | Additional fields to update |

---

### `azdw_DeleteWorkItem` ⚠️

Delete a work item. Requires approval. Shows relationships first.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id` | integer | Yes | Work item ID |
| `connection` | string | No | Connection name |

---

## Relationships

Tools for managing work item relationships (parent-child, related, etc.). Supports cross-organization relationships.

### `azdw_GetWorkItemRelationships`

Get work item relationships (parent-child, related). Supports cross-org.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id` | integer | Yes | Work item ID |
| `connection` | string | No | Connection name |

---

### `azdw_AddWorkItemRelationship` ⚠️

Add a relationship between two work items **by ID**. Requires approval. Use
friendly type names (`Parent`, `Child`, `Related`, `Successor`, `Predecessor`,
`Duplicate`, `DuplicateOf`) — never raw `System.LinkTypes.*` names. To link to
an arbitrary **URL** (not a work item) use `azdw_AddWorkItemHyperlink` instead.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `sourceId` | integer | Yes | Source work item ID |
| `targetId` | integer | Yes | Target work item ID |
| `relationType` | string | Yes | Friendly relationship type (e.g., "Parent", "Child", "Related", "Successor") |
| `sourceConnection` | string | Yes | Connection owning the source work item |
| `targetConnection` | string | No | Connection owning the target work item — omit for same-connection; set for **cross-connection / cross-org** links |

---

### `azdw_RemoveWorkItemRelationship` ⚠️

Remove a relationship between two work items. Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `sourceId` | integer | Yes | Source work item ID |
| `targetId` | integer | Yes | Target work item ID |
| `relationType` | string | Yes | Friendly relationship type |
| `sourceConnection` | string | Yes | Connection owning the source work item |
| `targetConnection` | string | No | Connection owning the target work item (omit for same-connection) |

---

### `azdw_AddWorkItemHyperlink` ⚠️

Add a native **Hyperlink** relation from a work item to an arbitrary URL (e.g.,
an external GitHub issue). Requires approval. Use this — not
`azdw_AddWorkItemRelationship` — whenever the target is a URL rather than a work
item ID.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `sourceId` | integer | Yes | Source work item ID |
| `url` | string | Yes | Absolute URL the hyperlink points to |
| `connection` | string | Yes | Connection owning the source work item |
| `comment` | string | No | Optional comment stored on the hyperlink |

---

### `azdw_RemoveWorkItemHyperlink` ⚠️

Remove a native Hyperlink relation matching the given URL from a work item.
Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `sourceId` | integer | Yes | Source work item ID |
| `url` | string | Yes | Absolute URL of the hyperlink to remove |
| `connection` | string | Yes | Connection owning the source work item |

> **Batch / spec-file linking**: to create many relationships or hyperlinks at
> once, use `azdw_UpsertWorkItemsBatch` with a spec file (`parent`, `relations[]`
> with `targetId`/`targetRef`/`targetUrl`). See
> [Relationships-and-Linking.md](Relationships-and-Linking.md).

---

## Analysis & Insights

Tools for analyzing work item relationships and patterns.

### `azdw_FindClosure`

Find the complete hierarchy closure for work items. Traverses up to a top-level type (e.g., Epic) and includes all related items. Use this to understand the full context of work items. Use `outputFile` to save the closure for a subsequent `azdw_VisualizeClosureGraph` call.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `workItemIds` | string | Yes | Work item ID(s), comma-separated |
| `connection` | string | Yes | Connection name (Azure DevOps **or** GitHub / GHE) |
| `topType` | string | No | Top-level type to traverse to (uses configured default if omitted) |
| `noSiblings` | boolean | No | Exclude siblings at all levels |
| `includeTopSiblings` | boolean | No | Include siblings of top-level items (mutually exclusive with `noSiblings`) |
| `includePredecessors` | boolean | No | Include predecessor relationships |
| `resolveHyperlinks` | boolean | No | Resolve hyperlinks in descriptions as relationships (default: `true`) |
| `resolveFieldReferences` | boolean | No | Resolve work item refs from configured custom fields (default: `false`) |
| `hyperlinksAs` | string | No | How to treat resolved hyperlinks: `Parent`, `Child`, `Dependency`, or `Related`. Use `Parent`/`Child` to expand the linked hierarchy. |
| `bidirectionalHyperlinks` | boolean | No | Also find work items in **other connections** that hyperlink **to** closure items (default: `true`) |
| `bidirectionalHyperlinksGitHub` | boolean | No | Reverse discovery for **GitHub**: enumerate GitHub issues and scan bodies for links pointing to closure items (default: `false`; independent of `bidirectionalHyperlinks`) |
| `crossConnection` | boolean | No | Enable cross-connection relationship resolution (default: `true`) |
| `limitConnections` | string | No | Limit cross-connection resolution to specific connections (comma-separated) |
| `maxSize` | integer | No | Maximum closure size, 1–10000 [default: 500] |
| `statesExclude` | string | No | States to exclude (comma-separated, e.g. `Closed,Removed`) |
| `outputFile` | string | No | Save closure to this filename in work directory (e.g., 'closure-1976.json'). Enables `azdw_VisualizeClosureGraph`. |

---

### `azdw_AnalyzeRelationships`

Analyze work item relationships and get insights.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `workItemIds` | string | Yes | Comma-separated work item IDs |
| `connections` | string | No | Comma-separated connection names |

---

### `azdw_AnalyzeRelationshipNetwork`

Analyze relationship network metrics across connections.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connections` | string | Yes | Comma-separated connection names |
| `workItemTypes` | string | No | Types to filter |
| `states` | string | No | States to filter |

---

### `azdw_FindCircularDependencies`

Detect circular dependency chains in relationships.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connections` | string | Yes | Comma-separated connections |
| `workItemTypes` | string | No | Types to filter |
| `states` | string | No | States to filter |
| `maxResults` | integer | No | Maximum results (default: 1000) |

---

### `azdw_FindOrphanedWorkItems`

Find work items with no parent/child relationships.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connections` | string | Yes | Comma-separated connection names |
| `workItemTypes` | string | No | Types to filter |
| `states` | string | No | States to filter |

---

### `azdw_FindRelationshipPatterns`

Find work items matching relationship patterns.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connections` | string | Yes | Comma-separated connection names |
| `pattern` | string | Yes | Pattern to match |

---

### `azdw_GenerateClosureStory`

Generate an AI-powered story narrative from a work item closure. Analyzes the hierarchy, evaluates against INVEST/SMART frameworks, and produces clarifying questions. Requires AI to be configured.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `workItemId` | integer | Yes | Work item ID to analyze |
| `connection` | string | Yes | Connection name |
| `topType` | string | No | Top-level type (default: configured) |
| `maxWorkItems` | integer | No | Maximum items (default: 50) |
| `includePii` | boolean | No | Include PII fields (default: false) |

---

### `azdw_GetRelationshipInsights`

Get relationship statistics and health insights.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connections` | string | Yes | Comma-separated connection names |

---

### `azdw_ValidatePolicies`

Validate work items against configured relationship and timing policies. Returns violations (errors) and warnings for non-compliant items.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connections` | string | Yes | Comma-separated connection names |
| `workItemTypes` | string | No | Types to filter |
| `states` | string | No | States to filter |

---

## Visualization & Reports

Tools for generating visual representations and reports of work item data.

### `azdw_GenerateReport`

Generate reports using templates (Markdown, HTML, CSV, JSON output).

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `templateName` | string | Yes | Template name to use |
| `connections` | string | No | Connections to include |
| `outputFormat` | string | No | Output format |

---

### `azdw_GenerateAndSaveHierarchy`

Generate hierarchy visualization and save to file. Use this instead of manually writing DOT files.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `workItemIds` | string | Yes | Comma-separated work item IDs |
| `connectionName` | string | No | Connection name |
| `fileName` | string | No | Output file name |

---

### `azdw_GenerateAndSaveNetwork`

Generate network visualization and save to file. Use this instead of manually writing DOT files.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connections` | string | Yes | Comma-separated connections |
| `fileName` | string | No | Output file name |

---

### `azdw_VisualizeClosureGraph`

Visualize a closure saved by `azdw_FindClosure` (outputFile param). Call `azdw_FindClosure` first with `outputFile` set, then pass the returned `closureFile.relativePath` here. Uses azdw-specific rendering with work item type colors, state labels, and relationship-type styling — much richer than calling the dot tool directly.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `closureFile` | string | Yes | Relative path to the closure JSON file in the work directory (value of `closureFile.relativePath` from `FindClosure`) |
| `outputFilename` | string | Yes | Output filename without extension (e.g., 'closure-1976') |
| `renderFormat` | string | No | Render to image: png, svg, pdf, or 'none' for DOT only [default: png] |
| `layout` | string | No | Layout: graph (default), tree (hierarchical), network (large graphs) |
| `title` | string | No | Optional diagram title |

---

### `azdw_GenerateGraphvizVisualization`

Generate Graphviz DOT for work item diagrams.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `workItemIds` | string | Yes | Comma-separated work item IDs |
| `connectionName` | string | No | Connection name |

---

### `azdw_GenerateHierarchyVisualization`

Generate hierarchy tree in Graphviz DOT format.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `workItemIds` | string | Yes | Comma-separated work item IDs |
| `connectionName` | string | No | Connection name |

---

### `azdw_GenerateNetworkVisualization`

Generate D3.js/Gephi network graph JSON.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connections` | string | Yes | Comma-separated connections |

---

### `azdw_GenerateGraphMLVisualization`

Generate GraphML for yEd and graph analysis tools.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `workItemIds` | string | Yes | Comma-separated work item IDs |
| `connectionName` | string | No | Connection name |

---

### `azdw_GenerateMermaidErDiagram`

Generate Mermaid ER diagram for work item type relationships.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connectionName` | string | Yes | Connection name |

---

### `azdw_GenerateMermaidFlowchart`

Generate Mermaid flowchart for work item relationships.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `workItemIds` | string | Yes | Comma-separated work item IDs |
| `connectionName` | string | No | Connection name |

---

### `azdw_GenerateMermaidGantt`

Generate Mermaid Gantt chart for work item timelines.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `workItemIds` | string | Yes | Comma-separated work item IDs |
| `connectionName` | string | No | Connection name |

---

### `azdw_GenerateMermaidKanban`

Generate Mermaid Kanban board for work item states.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connections` | string | Yes | Comma-separated connections |
| `workItemTypes` | string | No | Types to filter |

---

### `azdw_GenerateMermaidRequirementDiagram`

Generate Mermaid requirement diagram for traceability.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `workItemIds` | string | Yes | Comma-separated work item IDs |
| `connectionName` | string | Yes | Connection name |
| `title` | string | No | Diagram title |

---

## Approvals

Tools for managing the approval workflow for write operations.

### `azdw_ApproveOperation`

Approve a pending operation using its approval token.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `approvalToken` | string | Yes | Approval token from the pending request |

---

### `azdw_RejectOperation`

Reject a pending operation using its approval token.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `approvalToken` | string | Yes | Approval token from the pending request |
| `reason` | string | No | Reason for rejection |

---

### `azdw_GetApprovalDetails`

Get detailed information about a specific approval request.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `approvalToken` | string | Yes | Approval token |

---

### `azdw_ListPendingApprovals`

List all pending approval requests that require user decision.

**Parameters**: None

---

## Templates

Tools for managing report templates.

### `azdw_ListTemplates`

List available report templates (Markdown, HTML, CSV, JSON output).

**Parameters**: None

---

### `azdw_GetTemplateInfo`

Get template details including parameters and usage.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `templateName` | string | Yes | Template name |

---

### `azdw_ExportTemplate`

Export template content for backup or sharing.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `templateName` | string | Yes | Template name |

---

### `azdw_ValidateTemplate`

Validate template syntax and configuration.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `templateName` | string | Yes | Template name |

---

### `azdw_ReportTemplateCreate` ⚠️

Create custom template (Scriban syntax). Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `name` | string | Yes | Template name |
| `content` | string | Yes | Template content (Scriban syntax) |
| `description` | string | No | Template description |

---

### `azdw_ReportTemplateImport` ⚠️

Import template from JSON. Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `json` | string | Yes | Template JSON |

---

### `azdw_ReportTemplateUpdate` ⚠️

Update custom template. Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `name` | string | Yes | Template name |
| `content` | string | Yes | New template content |

---

### `azdw_ReportTemplateRemove` ⚠️

Delete custom template. Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `name` | string | Yes | Template name |

---

## Configuration & Admin

Tools for managing connections, credentials, cache, user identity, and URL mappings.

### `azdw_AddConnection` ⚠️

Add Azure DevOps connection. Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `name` | string | Yes | Connection name |
| `url` | string | Yes | Azure DevOps organization URL |
| `project` | string | Yes | Project name |
| `authType` | string | No | Authentication type |

---

### `azdw_RemoveConnection` ⚠️

Remove a connection. Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `name` | string | Yes | Connection name |

---

### `azdw_TestConnection`

Test connection and credentials.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | No | Connection name (tests all if omitted) |

---

### `azdw_RefreshConnections`

Refresh connection status for all or specific connections (non-interactive — tests existing credentials without prompting). Use this when connections report errors or queries fail unexpectedly.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connectionNames` | string | No | Comma-separated connection names to refresh (all if omitted) |

---

### `azdw_ClearAllConnections` ⚠️

Clear all connections and credentials. Requires approval.

**Parameters**: None

---

### `azdw_ClearAllCredentials`

Clear ALL stored credentials (destructive).

**Parameters**: None

---

### `azdw_ClearCache` ⚠️

Clear cache. Requires approval.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | No | Connection (all if omitted) |
| `expiredOnly` | boolean | No | Only clear expired entries |

---

### `azdw_RefreshCache`

Refresh cache for connection(s).

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | No | Connection name |

---

### `azdw_GetCacheStatistics`

Get cache statistics: hit rate, entries, evictions.

**Parameters**: None

---

### `azdw_GetCacheStatus`

Get cache status and hit rates.

**Parameters**: None

---

### `azdw_RepairCredentials`

Diagnose and repair corrupted credentials.

**Parameters**: None

---

### `azdw_GetCurrentUserIdentity`

Get the current user's identity (email address) for work item filtering. Use this when the user says "my", "me", "I" (e.g., "show my work items", "assigned to me"). Returns the user's email for each configured connection. If email is unknown, the result will indicate that user input is needed.

**Parameters**: None

---

### `azdw_SetUserIdentity`

Set the user's email address for a specific Azure DevOps connection. Use this after the user provides their email in response to `GetCurrentUserIdentity`. The email will be persisted for future sessions.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `email` | string | Yes | User's email address |

---

### `azdw_GetCurrentDateTime`

Get current date and time. Returns localized time for the MCP server.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `format` | string | No | Format: "iso8601" (default), "rfc1123", "short", "long", or custom |
| `timeZoneId` | string | No | IANA/Windows timezone ID (default: local) |

---

### `azdw_GetFieldMapping`

Get field mapping for a work item type.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `workItemType` | string | Yes | Work item type |

---

### `azdw_ListFieldMappings`

List field mappings for work item types.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | No | Connection name |

---

### `azdw_GetMcpHelp`

Get help on tools. Topics: connections, queries, templates, credentials, field-mappings, troubleshooting.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `topic` | string | Yes | Help topic name |

---

### `azdw_ListPlugins`

List loaded plugins: transforms, renderers, filters.

**Parameters**: None

---

### `azdw_AddUrlMapping`

Add URL mapping for old-to-new domain transform.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `oldUrl` | string | Yes | Old URL pattern |
| `newUrl` | string | Yes | New URL pattern |

---

### `azdw_RemoveUrlMapping`

Remove a URL mapping by index or old URL.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `identifier` | string | Yes | Index or old URL |

---

### `azdw_ClearUrlMappings`

Clear ALL URL mappings (destructive).

**Parameters**: None

---

### `azdw_ListUrlMappings`

List URL domain mappings for old-to-new URL transforms.

**Parameters**: None

---

### `azdw_GetUrlMappingConfiguration`

Get complete URL mapping configuration.

**Parameters**: None

---

### `azdw_SetUrlMappingEnabled`

Enable or disable URL mapping feature.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `enabled` | boolean | Yes | True to enable, false to disable |

---

## File System & Rendering

Tools for managing files in the sandboxed work directory and rendering visualizations.

### `azdw_GetWorkDirectory`

Get the sandboxed work directory path where files can be read/written.

**Parameters**: None

---

### `azdw_ListFiles`

List files in the sandboxed work directory.

**Parameters**: None

---

### `azdw_ReadFile`

Read content from a file in the sandboxed work directory.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `fileName` | string | Yes | File name to read |

---

### `azdw_WriteFile`

Write content to a file in the sandboxed work directory. Use for saving DOT files, reports, etc.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `fileName` | string | Yes | File name to write |
| `content` | string | Yes | Content to write |

---

### `azdw_DeleteFile`

Delete a file from the sandboxed work directory.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `fileName` | string | Yes | File name to delete |

---

### `azdw_CheckGraphvizInstalled`

Check if GraphViz "dot" tool is installed for rendering DOT files to images.

**Parameters**: None

---

### `azdw_RenderGraphviz`

Render a GraphViz DOT file to an image (PNG, SVG, PDF). The DOT file must exist in the work directory.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `fileName` | string | Yes | DOT file name in work directory |
| `outputFormat` | string | No | Output format: "png", "svg", "pdf" (default: "png") |

---

## Batch Upsert

Tools for creating or updating multiple work items from a structured spec. Support preflight validation and per-item reconciliation.

### `azdw_UpsertWorkItemsBatch` ⚠️

Batch-create or upsert work items from a JSON/JSONC work item spec. Provide the spec either as inline `specJson` or as a `fromFile` path/URL. CLI-style field overrides (`project`, `type`, `title`, `description`, `area`, `tags`, `customFields`, `comment`) apply on top of the spec.

Use `preflightValidation=true` to first do a dry-run and obtain an **approval token** — then call `azdw_ConfirmWorkItemsBatch` to execute. Use `reconcile=true` to get a `WorkItemReconciliation` block per result, containing the assigned ID, effective fields, resolved relations, and a `LocalSyncStatus`.

> **Simulate / What-If**: When the user asks to *simulate*, *preview*, *test run*, *rehearsal*, *what-if*, or *dry run* the batch, set `dryRun=true`. No work items will be written to Azure DevOps.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `connection` | string | Yes | Connection name |
| `specJson` | string | No | Inline JSON/JSONC spec content. Provide either `specJson` or `fromFile`. |
| `fromFile` | string | No | Local path or HTTPS URL to a `.json`/`.jsonc` spec file. Provide either `specJson` or `fromFile`. |
| `project` | string | No | Default project for items that omit the project field |
| `type` | string | No | Default work item type for items that omit `workItemType` |
| `title` | string | No | Title override (applies to all items) |
| `description` | string | No | Description override (applies to all items) |
| `area` | string | No | Area path override |
| `tags` | string | No | Comma-separated tags to add (merged with spec tags) |
| `customFields` | object | No | Custom field overrides as a JSON object, e.g. `{"Custom.MyField": "value"}` |
| `comment` | string | No | Discussion comment to post on each work item |
| `noUpdate` | bool | No | Always create new items; skip upsert existence check (default: `false`) |
| `force` | bool | No | Allow upsert matching against any work item regardless of the `azdw` tracking tag (default: `false`) |
| `dryRun` | bool | No | Preview (simulate) operations without executing; no remote writes. Use when the user says *simulate*, *what-if*, *test run*, *rehearsal*, or *dry run* (default: `false`) |
| `preflightValidation` | bool | No | Run a dry-run, store the spec, and return an `approvalToken` for `azdw_ConfirmWorkItemsBatch` (default: `false`) |
| `reconcile` | bool | No | Populate the per-item `Reconciliation` block with effective fields, resolved IDs, and `LocalSyncStatus` (default: `false`) |

**Returns**: JSON with `success`, `summary` (total/created/updated/failed/skipped/results) or, when `preflightValidation=true`, `requiresConfirmation: true` and `approvalToken`.

> **Spec-file relationships**: each item in the spec can declare a `parent`
> object and a `relations[]` array (`type` + `targetId`/`targetRef`/`targetUrl`),
> with intra-batch `sourceRef`/`targetRef` symbolic linking resolved in a second
> pass. A relations-only entry (`id` + `relations`, no `fields`) backfills links
> on existing items. See
> [Relationships-and-Linking.md](Relationships-and-Linking.md) for the full
> format.

---

### `azdw_ConfirmWorkItemsBatch` ⚠️

Execute a batch upsert previously staged by `azdw_UpsertWorkItemsBatch` with `preflightValidation=true`. Supply the `approvalToken` from that call. Each token is single-use.

**Parameters**:
| Parameter | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `approvalToken` | string | Yes | Token returned by `azdw_UpsertWorkItemsBatch` with `preflightValidation=true` |
| `reason` | string | No | Optional human-readable reason recorded for audit purposes |

**Returns**: JSON with `success` and `summary` (same shape as `azdw_UpsertWorkItemsBatch`).
