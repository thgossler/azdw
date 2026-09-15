# GitHub & GitHub Enterprise Issues

`azdw` treats **GitHub** and **GitHub Enterprise (GHE)** as first-class work
item providers alongside Azure DevOps. A GitHub connection's **issues are work
items**, so the same query/get/create/update/delete and `find-closure` tools and
CLI commands work against them — routing is automatic based on the connection.

> **How routing works**: any connection where the URL is a GitHub/GHE host is
> handled by the GitHub provider. You do **not** call different tools — call the
> normal `azdw_QueryWorkItems`, `azdw_GetWorkItem`, `azdw_CreateWorkItem`,
> `azdw_UpdateWorkItem`, `azdw_FindClosure`, etc. with a GitHub connection name.

---

## What works on GitHub connections

| Capability | MCP / CLI | Notes |
| ---------- | --------- | ----- |
| Query / list issues | `azdw_QueryWorkItems` / `azdw query` | Filters that have a GitHub equivalent apply (type→label, state, assignee, tags→labels). |
| Get a single issue | `azdw_GetWorkItem` / `azdw workitem get` | Accepts a numeric id, a GitHub issue URL, or `owner/repo#N`. |
| Create an issue | `azdw_CreateWorkItem` / `azdw workitem create` | See field mapping below. |
| Update an issue | `azdw_UpdateWorkItem` / `azdw workitem update` | Title, body, state (open/closed), labels. |
| Delete / close | `azdw_DeleteWorkItem` / `azdw workitem delete` | |
| Closure traversal | `azdw_FindClosure` / `relationship find-closure` | Can **start from a GitHub issue**; resolves issue-to-issue links. |
| Batch create/upsert | `azdw_UpsertWorkItemsBatch` / `workitem create --from-file` | Spec files work; see import gotchas. |

---

## Field mapping (unified model ↔ GitHub)

| Unified work item | GitHub issue |
| ----------------- | ------------ |
| **Type** (`Bug`, `Feature`/`Enhancement`, `Epic`, `Task`) | A **label** (per `github-mapping.jsonc` `typeMapping`). Every unified type used must have a mapping rule, or the write fails. |
| **State** | Open / closed. `New`/`Active`/`Reopened` → `open`; `Closed`/`Removed` → `closed`. State **is honored on create** (passed as `System.State`). |
| **Tags** | **Labels** (in addition to the type-derived label). |
| **Title / Description** | Issue title / body. |
| Area path, iteration path, discussion comments | **Ignored** — no GitHub equivalent. |

> The mapping is configurable in `github-mapping.jsonc`. The defaults cover
> `bug→Bug`, `enhancement`/`feature→Feature`, `epic→Epic`, `task→Task`, and
> `New→open`.

---

## Azure-DevOps-only features (gracefully gated, not bugs)

These have **no GitHub equivalent** and are intentionally Azure-DevOps-only.
On a GitHub connection they raise a clear "not supported" error or silently
no-op — do **not** treat them as failures or try to work around them:

- **WIQL** (`azdw_ExecuteWiql` / `azdw wiql`) — ADO query language only.
- **Metadata**: work item types, fields, area paths, iteration paths
  (`azdw_GetWorkItemTypes`, `azdw_GetWorkItemFields`, `azdw_GetAreaPaths`, …).
- **Area / iteration query filters** — silently no-op on GitHub.
- **Capacity / load analysis** — groups by area path (ADO concept).
- **Org-wide project enumeration**.

For mixed estates, use WIQL/metadata against ADO connections and the
provider-neutral query/get/closure tools against GitHub connections.

> `azdw query --ai` can target a GitHub connection: it generates and runs the
> ADO WIQL and the GitHub query **in parallel** and merges the results.

---

## Relationships on GitHub issues

GitHub issues have **no structured/native relationships** (no parent/child or
dependency links). Cross-references live in the issue **body** as:

- absolute URLs (to other GitHub issues, or to Azure DevOps work items), and
- same-repo `#N` references.

`azdw` surfaces these as `Hyperlink` relationships when relationships are
requested:

- `azdw_FindClosure` / `relationship find-closure` extracts body URLs and `#N`
  refs into `Hyperlink` relations and resolves them to work items.
- **`--hyperlinks-as` / `hyperlinksAs`** controls how a resolved hyperlink is
  treated when building the closure: `Related` (default, treated as a leaf),
  `Parent`, `Child`, or `Dependency`. Use `Child`/`Parent` to **expand** the
  linked hierarchy instead of stopping at the link.
- Forward GitHub→GitHub link resolution is **always on** when hyperlink
  resolution is enabled (it is by default).

### Reverse discovery (who links TO this?)

By default a closure follows links **outward** from its items. To also find
GitHub issues that point **back** at closure items, enable reverse discovery:

- **CLI**: `relationship find-closure … --bidirectional-hyperlinks-github`
- **MCP**: `azdw_FindClosure` with `bidirectionalHyperlinksGitHub=true`

When enabled, `azdw` enumerates GitHub issues and scans their bodies for links
pointing to items already in the closure, pulling those issues in. This is
**off by default** (it enumerates issues, which is more expensive) and is
independent of the Azure DevOps reverse setting (`--no-bidirectional-hyperlinks`
/ `bidirectionalHyperlinks`).

---

## Caching

GitHub issue content fetched during closure/relationship resolution is **cached
locally** (LiteDB at `~/.azdw/cache/`) so repeat scans are fast and stay within
GitHub API rate limits. Caching is best-effort and never blocks an operation.

- For a guaranteed **fresh** read, pass `--no-caching`, or clear with
  `azdw cache clear`.
- The cache is two files (`cache.db` + `cache-log.db`); `azdw cache clear`
  removes both.

---

## Import gotchas

- **GitHub never reuses issue numbers.** A spec file that hard-codes sequential
  issue numbers and body cross-refs (e.g. `Part of #1`) will break if any item
  fails to create, because all later numbers shift. **Always `--dry-run`
  first** to confirm the full count, and import into a **freshly created /
  emptied repo**.
- **Type/state mapping must exist.** Every unified type/state used in the spec
  must have a rule in `github-mapping.jsonc` (or fall under the defaults), or
  the write throws.
- Use `azdw_AddWorkItemHyperlink` / `--add-hyperlink` (or a spec `hyperlink`
  relation) to create explicit ADO→GitHub links rather than relying solely on
  body text.

See [Relationships-and-Linking.md](Relationships-and-Linking.md) for the full
hyperlink / spec-file linking reference.
