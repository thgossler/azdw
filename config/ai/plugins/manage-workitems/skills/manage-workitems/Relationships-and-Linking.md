# Relationships & Linking

How to create, update, and bulk-backfill work item relationships and hyperlinks
with `azdw` — covering the spec-file format, friendly relationship-type names,
cross-connection and cross-provider (Azure DevOps ↔ GitHub) links, and the
gotchas that otherwise have to be rediscovered each time.

> **TL;DR**
> - One or two ad-hoc links → MCP `azdw_AddWorkItemRelationship` / `azdw_AddWorkItemHyperlink`, or CLI `workitem update --add-hyperlink`.
> - Many links / structured hierarchies → a **spec file** with `parent` + `relations[]`, applied via `azdw_UpsertWorkItemsBatch` or `workitem update --from-file`.
> - Use **friendly type names** (`Parent`, `Child`, `Related`, `Successor`, …), never the raw `System.LinkTypes.*` reference names.
> - To analyze relationships you must first **fetch them** (MCP `includeRelationships=true`, CLI `--relationships`).

---

## Relationship types (friendly names)

`azdw` accepts case-insensitive **friendly** type names everywhere a relationship
type is expected (spec files, `azdw_AddWorkItemRelationship`). Do **not** pass raw
Azure DevOps `System.LinkTypes.*` reference names — `azdw` maps them for you.

| Friendly name | Direction / meaning | Azure DevOps link (reference name) |
| ------------- | ------------------- | ---------------------------------- |
| `Parent` | This item's parent (one level up) | `System.LinkTypes.Hierarchy-Reverse` |
| `Child` | A child of this item (one level down) | `System.LinkTypes.Hierarchy-Forward` |
| `Related` | Non-hierarchical association (default) | `System.LinkTypes.Related` |
| `Successor` | Comes after (this → successor) | `System.LinkTypes.Dependency-Forward` |
| `Predecessor` | Comes before (this ← predecessor) | `System.LinkTypes.Dependency-Reverse` |
| `Duplicate` | This item duplicates another | `System.LinkTypes.Duplicate-Forward` |
| `DuplicateOf` | Another item duplicates this one | `System.LinkTypes.Duplicate-Reverse` |
| `Hyperlink` | Native link to an arbitrary **URL** (not a work item) | `Hyperlink` |

> **Symmetric storage**: `Parent`/`Child`, `Successor`/`Predecessor`, and
> `Related` are stored on **both** endpoints in Azure DevOps. Creating one link
> makes it visible from both items, and raw relationship **counts are roughly
> double** the number of logical links. Do not "add the reverse" yourself — it
> already exists.

---

## Creating one or two links (ad-hoc)

### Work-item-to-work-item link (MCP — preferred)

`azdw_AddWorkItemRelationship` (⚠️ approval) links two existing work items by ID:

| Parameter | Required | Notes |
| --------- | -------- | ----- |
| `sourceId` | Yes | Source work item ID |
| `targetId` | Yes | Target work item ID |
| `relationType` | Yes | Friendly name (`Parent`, `Child`, `Related`, `Successor`, …) |
| `sourceConnection` | Yes | Connection owning the source item |
| `targetConnection` | No | Connection owning the target item — **omit for same-connection**, set it for **cross-connection / cross-org** links |

`azdw_RemoveWorkItemRelationship` takes the same parameters and removes the link.

> **Cross-connection links**: pass a different `targetConnection` to link items
> that live in two different organizations/connections. This is how cross-org
> hierarchies and dependencies are established.

> **IDs only**: `azdw_AddWorkItemRelationship` links work items **by integer
> ID**. It cannot point at an arbitrary URL — to link to an external URL (e.g. a
> GitHub issue), use a hyperlink instead (below).

### Hyperlink to an arbitrary URL

Use a **hyperlink** to attach an external URL (e.g. an external GitHub issue, a
spec, a dashboard) as a native Azure DevOps `Hyperlink` relation.

- **MCP**: `azdw_AddWorkItemHyperlink` (⚠️ approval) — `sourceId`, `url`,
  `connection`, optional `comment`. Remove with `azdw_RemoveWorkItemHyperlink`
  (`sourceId`, `url`, `connection`).
- **CLI**: `azdw workitem update <id> --add-hyperlink <url>` (repeatable),
  `--remove-hyperlink <url>` (repeatable), and `--hyperlink-comment "<text>"`
  for a comment stored on the added hyperlink(s).

```bash
# Link ADO item 12345 to an external GitHub issue
azdw workitem update 12345 \
  --add-hyperlink "https://github.com/acme/repo/issues/42" \
  --hyperlink-comment "Tracking issue" --connection myorg
```

---

## Spec-file format (batch create + link)

For multiple items, hierarchies, or many links at once, use a JSON/JSONC **work
item spec file**. It is the canonical, low-overhead path — applied via:

- **MCP**: `azdw_UpsertWorkItemsBatch` (`fromFile` or inline `specJson`).
- **CLI**: `azdw workitem create --from-file <path>` (create/upsert) or
  `azdw workitem update --from-file <path>` (update existing / relations-only).

The full JSON schema is `config/workitem-spec-schema.json`. The relationship-
relevant fields of each item definition are:

| Field | Purpose |
| ----- | ------- |
| `id` | Existing work item ID — present for **update** entries (and required for relations-only backfill). |
| `sourceRef` | A **symbolic id** for this item *within the batch*. Other items reference it via `parent.targetRef` or `relations[].targetRef`. |
| `parent` | Object `{ "targetId": <id> }` or `{ "targetRef": "<sourceRef>" }` — sets the parent (hierarchy) link. |
| `relations[]` | Array of links: each `{ "type": <friendly>, "targetId" \| "targetRef" \| "targetUrl" }`. |

### Two-pass resolution

`azdw` applies a spec file in **two passes**:

1. **Pass 1** — create/upsert every item. Each `sourceRef` is mapped to the
   assigned work item ID.
2. **Pass 2** — resolve all `parent` and `relations[]` entries, substituting
   `targetRef` values with the IDs assigned in Pass 1.

This lets you create a whole hierarchy and its links in **one file**, even
before any ID exists, by referencing items symbolically with `sourceRef` /
`targetRef`.

### `relations[]` target forms (mutually exclusive)

Exactly one of these per relation entry:

| Target | Meaning |
| ------ | ------- |
| `targetId` | An **existing** absolute Azure DevOps work item ID. |
| `targetRef` | The `sourceRef` of **another item in the same batch** (resolved in Pass 2). |
| `targetUrl` | An **arbitrary URL** → creates a native `Hyperlink` relation. Implies `type: hyperlink` (you can also set `type: hyperlink` explicitly). |

### Example — hierarchy + dependency in one batch

```jsonc
{
  "workItems": [
    {
      "sourceRef": "epic-auth",
      "workItemType": "Epic",
      "fields": { "Title": "Authentication" }
    },
    {
      "sourceRef": "story-login",
      "workItemType": "User Story",
      "fields": { "Title": "Login flow" },
      "parent": { "targetRef": "epic-auth" }
    },
    {
      "sourceRef": "story-logout",
      "workItemType": "User Story",
      "fields": { "Title": "Logout flow" },
      "parent": { "targetRef": "epic-auth" },
      "relations": [
        // "story-logout" comes after "story-login"
        { "type": "predecessor", "targetRef": "story-login" },
        // link to an external GitHub issue (native Hyperlink)
        { "type": "hyperlink", "targetUrl": "https://github.com/acme/repo/issues/42" }
      ]
    }
  ]
}
```

---

## Bulk relationship backfill (relations-only update)

To add many links to **existing** items without touching their fields, use a
spec file where each entry has only an `id` and `relations` (and/or `parent`) —
**no `fields`**. This is the efficient way to backfill missing parent/child,
successor, or hyperlink links across a large set of items in one operation
(instead of one `azdw_AddWorkItemRelationship` call per link).

```jsonc
// backfill-links.jsonc — relations-only entries (no fields)
{
  "workItems": [
    { "id": 1001, "parent": { "targetId": 900 } },
    { "id": 1002, "parent": { "targetId": 900 },
      "relations": [ { "type": "successor", "targetId": 1003 } ] },
    { "id": 1003, "relations": [ { "type": "related", "targetId": 1001 } ] }
  ]
}
```

Apply it (preview first):

```bash
# Preview
azdw workitem update --from-file backfill-links.jsonc --dry-run --json
# Execute
azdw workitem update --from-file backfill-links.jsonc --json
```

Or via MCP: `azdw_UpsertWorkItemsBatch` with `fromFile="backfill-links.jsonc"`
(use `dryRun=true` to preview, or `preflightValidation=true` then
`azdw_ConfirmWorkItemsBatch`).

> A relations-only entry deliberately produces **no field changes** — `azdw`
> skips the field update and applies only the relationships. Do **not** add
> dummy field values to "make it work".

---

## Cross-provider linking (Azure DevOps ↔ GitHub)

Azure DevOps and GitHub issues do not share a native relationship system, so
cross-provider links are expressed as **hyperlinks / URLs**:

- **ADO → GitHub**: add a `Hyperlink` relation whose `targetUrl` is the GitHub
  issue URL (spec-file `relations[] type=hyperlink targetUrl`, or
  `azdw_AddWorkItemHyperlink`, or `workitem update --add-hyperlink`).
- **GitHub → ADO**: put the Azure DevOps work item URL in the GitHub issue
  **body** (GitHub issues have no structured relations). `find-closure` can then
  discover and resolve it.

See [GitHub-Issues.md](GitHub-Issues.md) for how GitHub links are discovered and
expanded (`--hyperlinks-as`, bidirectional discovery).

---

## Analyzing relationships — you must fetch them first

Relationship analysis only sees links that were **loaded**. If you query without
requesting relationships, every item looks orphaned / unlinked.

- **MCP**: set `includeRelationships=true` on `azdw_QueryWorkItems` /
  `azdw_GetWorkItem`. For closures, `azdw_FindClosure` loads them for you.
- **CLI**: add `--relationships` to `azdw query`, or use
  `azdw relationship find-closure` / `resolve`.

`azdw_FindOrphanedWorkItems` and `relationship find-orphans` rely on this — an
item with no loaded relationships is reported as an orphan.

---

## Gotchas (quick list)

- **Friendly names only** — pass `Successor`/`Predecessor`/`Parent`/…, never
  `System.LinkTypes.Dependency-Forward` etc.
- **Symmetric links double-count** — one logical link appears on both items;
  don't create the reverse, and expect counts ≈ 2× logical links.
- **Fetch before analyze** — `includeRelationships=true` / `--relationships` is
  required before orphan/closure/network analysis.
- **Relations-only updates are supported** — `id` + `relations` with no `fields`
  is the correct shape for backfill; it intentionally skips the field PATCH.
- **`AddWorkItemRelationship` is ID-only** — use a hyperlink (`targetUrl`) to
  point at any external URL.
- **Cross-connection** — set `targetConnection` (MCP) for links spanning
  organizations; spec files resolve cross-project IDs automatically.
- **Bulk import** — for large imports that set non-initial states, add
  `--bypass-rules` (needs the *Bypass rules on work item updates* permission);
  add the global `--no-plugins` to skip policy-enforcement plugins during bulk
  loads. Always `--dry-run` first.
