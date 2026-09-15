---
title: Global Stack Rank
nav_order: 140
---

# Global Stack Rank

Global stack rank creates a comparable, ordered virtual backlog from work items whose native ranking fields use different scales. A named profile defines source scopes and maps each source's numeric rank onto a common 0-100 score. Sources can span Azure DevOps organizations and projects, GitHub repositories, and their on-premises or enterprise counterparts.

Ranking is computed for query results. It does not write ranks back to Azure DevOps or GitHub or change their native backlog ordering.

## Quick Start

1. Configure and enable the connections needed to read your backlog. A rank profile does not create connections or supply credentials.
2. Place your profile configuration in `~/.azdw/config/global-stack-rank.jsonc` for a normal local installation. Adapt the example below to your actual organizations, projects, and numeric fields.
3. Query with the profile name, using connection names from your own installation:

```bash
azdw query --connections "core-ado,platform-github" --global-stack-rank PlatformValueStream --limit 50
```

Use JSON for ranking diagnostics or select rank and score columns for a table:

```bash
azdw query --global-stack-rank PlatformValueStream --limit 50 --format json
azdw query --global-stack-rank PlatformValueStream --limit 50 --columns "GlobalRank,GlobalScore,ID,Title"
```

`GlobalRank` is the only ranking column shown by default. `GlobalScore`, `OriginalField` (the
matched source's `rankField` name), and `OriginalValue` (that field's raw, pre-normalization value)
are opt-in and only appear when named in `--columns`:

```bash
azdw query --global-stack-rank PlatformValueStream --limit 50 --columns "GlobalRank,OriginalField,OriginalValue,ID,Title"
```

These options are available in `azdw query --help`. Do not combine `--global-stack-rank` with `--sort`: the CLI rejects that combination. Leave out `--by-conn` and `--by-project` to see a single integrated backlog rather than grouped tables.

## Configuration

```json
{
	"version": "1.0",
	"profiles": [
		{
			"name": "PlatformValueStream",
			"displayName": "Platform Value Stream",
			"enabled": true,
			"sources": [
				{
					"name": "core-services",
					"provider": "AzureDevOps",
					"organization": "acmeflow",
					"project": "Core Services",
					"rankField": "Microsoft.VSTS.Common.StackRank",
					"sourceMin": 1,
					"sourceMax": 101,
					"direction": "LowerIsHigher",
					"priority": 10
				},
				{
					"name": "platform-oss",
					"provider": "GitHub",
					"organization": "acme-platform",
					"repository": "widgets",
					"rankField": "Priority",
					"sourceMin": 0,
					"sourceMax": 4,
					"direction": "HigherIsHigher",
					"priority": 5
				}
			]
		}
	]
}
```

The GitHub `Priority` field above is illustrative: it must exist as a numeric value in the work item's `Fields` dictionary. Labels or values such as `High` are not automatically converted to numbers. Choose the field name and direction that match your provider's actual data; see [GitHub-Integration.md](GitHub-Integration.md).

### Use Azure Boards Drag-and-Drop Order

To use the order maintained by dragging work items up or down in **Boards > Backlogs**, configure the source's `rankField` with the process's built-in ordering field. Azure Boards updates this field through a background process when you reorder items. The fields are normally hidden on work item forms but are available for querying; there is no need to add them to the form for azdw to read them.

The following mappings cover all four standard Azure DevOps processes:

| Standard Process | Product Backlog Item Type | Ordering Field | Configure `rankField` As | `direction` |
| --- | --- | --- | --- | --- |
| Basic | Issue | Stack Rank | `Microsoft.VSTS.Common.StackRank` | `LowerIsHigher` |
| Agile | User Story | Stack Rank | `Microsoft.VSTS.Common.StackRank` | `LowerIsHigher` |
| Scrum | Product Backlog Item | Backlog Priority | `Microsoft.VSTS.Common.BacklogPriority` | `LowerIsHigher` |
| CMMI | Requirement | Stack Rank | `Microsoft.VSTS.Common.StackRank` | `LowerIsHigher` |

Both ordering fields have the Azure DevOps data type **Double**. Lower values correspond to earlier, higher-priority positions. The same process-specific field is used for ordering at its other supported backlog levels, such as Features and Epics; it is not a single ordering across those levels. Basic has Issues and Epics by default, without a Feature level. Bug participation depends on the team's backlog configuration; Basic uses Issues rather than a separate standard Bug type.

**Do not use `Microsoft.VSTS.Common.Priority` to reproduce drag-and-drop order.** That field is the separate business-priority rating, typically 1-4, and does not encode an item's position in the backlog. Likewise, Story Points, Effort, Business Value, and a custom field named "Global Stack Rank" do not automatically reflect UI ordering. They can be deliberate alternative ranking inputs, but Azure Boards does not synchronize them with drag-and-drop just because they have a similar name.

For a standard Scrum project, a source entry could be:

```json
{
	"name": "scrum-backlog",
	"provider": "AzureDevOps",
	"organization": "acmeflow",
	"project": "Scrum Delivery",
	"rankField": "Microsoft.VSTS.Common.BacklogPriority",
	"sourceMin": 1000,
	"sourceMax": 1000000,
	"direction": "LowerIsHigher"
}
```

Add this entry to a profile's `sources`. For Basic, Agile, or CMMI, use `Microsoft.VSTS.Common.StackRank` instead and adjust the project identity. azdw does not automatically select an ordering field from the project's process template: configure each source explicitly.

The bounds in this entry, and `1-101` in the earlier example, are **illustrative, not standard Azure DevOps rank ranges**. Inspect actual numeric values for the intended source scope before choosing `sourceMin` and `sourceMax`. Ordering keys can have gaps and fractional values; do not interpret them as consecutive row numbers or set `sourceMax` to the number of backlog items. azdw normalizes the stored values, not their ordinal positions. Numeric distances between them do not measure business importance.

#### Scope and Verification

1. Identify the project's process and configure the matching field from the table. For inherited processes, start with the base process's mapping and verify the actual field. For customized XML processes, check the field mapped to `type="Order"` in `ProcessConfiguration` rather than assuming a standard mapping.
2. Match the intended backlog level and team scope with query filters and source selectors. Azure Boards applies team area/iteration settings, state visibility, and bug behavior; a broad azdw query does not automatically reproduce that view. Use separate profiles or deliberately scoped sources when comparing different levels or teams.
3. Reorder a few items vertically in the Azure Boards backlog and allow the background update to complete. Moving an item to a sprint or another parent is a different drag-and-drop operation and is not by itself evidence of reprioritization.
4. Fetch fresh work item data and inspect the configured field in `Fields`. For a CLI check, use `--no-caching` and JSON output; `--all-fields` makes the raw fields available even without activating a profile. Compare the values for those items in ascending order with the UI order.
5. Run the ranked query with `--global-stack-rank` and inspect `RawValue`, `Score`, `Clamped`, and `Status`. Missing values cannot reproduce a UI position and remain unranked. Revisit bounds when values fall outside the intended range or many items clamp to 0 or 100.

For distinct, in-range values within one source, `LowerIsHigher` preserves the source's relative order. It does **not** preserve literal UI row numbers, hierarchy, or absolute positions once other sources are interleaved. Independently managed projects and backlog levels do not share a business-priority scale merely because they use the same ordering field; your chosen normalization ranges determine how they interleave. Changes to Azure Boards' stored ordering values can therefore change normalized scores, and bounds may need recalibration.

Microsoft references (checked September 11, 2026):

- [Create queries based on rank and priority fields](https://learn.microsoft.com/en-us/azure/devops/boards/queries/planning-ranking-priorities?view=azure-devops): reference names, Double types, process mappings, and the distinction from business Priority.
- [Configure your backlog view](https://learn.microsoft.com/en-us/azure/devops/boards/backlogs/configure-your-backlog-view?view=azure-devops): drag-and-drop updates, Basic/Agile/CMMI versus Scrum, and separate ordering at each backlog level.
- [Use backlogs to manage projects](https://learn.microsoft.com/en-us/azure/devops/boards/backlogs/backlogs-overview?view=azure-devops): team scope, backlog visibility, and why bulk-assigning the same ordering value destroys relative order.

### Discovery and Validation

The service selects the first available configuration in this order; files are not merged:

1. An explicit configuration path supplied by a library caller.
2. `global-stack-rank.jsonc` under `AZDW_CLIENT_CONFIG_DIR`.
3. User-scoped `config/global-stack-rank.jsonc`, accessed through the host's user configuration service. For local storage this is under `~/.azdw/`; hosted installations may use a cloud-backed user configuration service.
4. Bundled `config/global-stack-rank.jsonc` beside the application.

The service loads configuration when constructed. Restart a long-running host after editing it. The example file is not activated simply by being present: the runtime filename is `global-stack-rank.jsonc`.

Profile names are case-insensitive and must be unique. Use the schema's name format: a letter followed by letters, digits, underscores, or hyphens. Profiles default to enabled and require at least one source. Nonempty source names must be unique within a profile. Invalid configuration produces a load/validation error; a missing, unknown, or disabled profile cannot be activated.

### Source Fields

| Setting | Meaning |
| --- | --- |
| `name` | Optional diagnostic label, not a connection name or match criterion. Naming sources makes summaries useful. |
| `provider` | `AzureDevOps` (default) or `GitHub`; each includes its server/enterprise variants. |
| `organization` | Required Azure DevOps organization or GitHub owner. Use the provider identity, not an azdw connection alias. |
| `project` | Required for Azure DevOps; ignored for GitHub. |
| `repository` | GitHub repository name; omit to match eligible repositories under the owner. Ignored for Azure DevOps. |
| `host` | Optional hostname, such as `ghe.example.com`, matched against the connection base URL. |
| `rankField` | Required field reference name. Ranking lookup tries the exact key, then a case-insensitive match. |
| `sourceMin`, `sourceMax` | Finite numeric bounds, with `sourceMin < sourceMax`. |
| `direction` | `LowerIsHigher` (default) or `HigherIsHigher`. |
| `priority` | Integer precedence, default 0; higher wins. It is not a multiplier or score weight. |
| `areaPath`, `iterationPath` | Optional Azure DevOps path criteria with `pattern` and `patternType` (`Glob`, the default, or `Regex`). Ignored for GitHub. |
| `workItemTypes` | Optional allow-list of logical work item types; any listed type can match, case-insensitively. |
| `tags` | Optional allow-list; at least one listed tag must match. |
| `fields` | Optional field criteria; all must match. Each specifies `fieldName`, `value`, an `operator`, and optional `caseSensitive`. |

Field-criterion operators are `Equals` (default), `NotEquals`, `Contains`, `StartsWith`, `EndsWith`, and `Matches`. Value matching defaults to case-insensitive. Supply actual field keys for these selectors; the ranking field's fallback lookup is separate.

For example, add these properties to an Azure DevOps source to narrow its applicability:

```json
{
	"areaPath": { "pattern": "**\\Platform\\**", "patternType": "Glob" },
	"workItemTypes": ["Feature", "UserStory"],
	"tags": ["Platform", "Shared"],
	"fields": [
		{ "fieldName": "Custom.ValueStream", "operator": "Equals", "value": "Platform" }
	]
}
```

All configured selector dimensions must match. When multiple sources match an item, selection uses highest `priority`, then greatest specificity, then first declaration order. Specificity counts `host`, `areaPath`, `iterationPath`, a nonempty type list, a nonempty tag list, and each field criterion. An explicit repository does not add specificity; use `priority` when a repository-specific rule must override an owner-wide rule.

## Query Scope and Limits

**A profile controls ranking, not query membership.** Normal connection selection and query filters determine which items are fetched. A profile neither discovers additional connections nor discards returned items outside its source rules: those receive `NoMatchingSource` and sort last. Restrict the query itself when only a particular backlog should be returned.

When a profile is active, the shared query service requests all fields, clears the per-query `MaxResults` before fetching candidates, applies ranking to the combined result, and then applies the requested limit. This avoids taking a separate top-N from each connection before normalization. It can also fetch substantially more data than an ordinary limited query.

`CandidateCount`, `RankedCount`, `UnrankedCount`, and `ClampedCount` describe the full candidate set before the final limit, not just the displayed rows. Provider-side constraints, query filters, unavailable connections, and access permissions still determine which candidates are available. Global ranks are query-scoped, not persistent positions across every item in every connected system.

## Scores and Positions

**Lower scores mean higher priority**, regardless of the source field's direction. A score of 0 is highest priority; 100 is lowest priority among ranked items.

For a raw value clamped to the configured range, normalization is:

```text
ratio = (clampedValue - sourceMin) / (sourceMax - sourceMin)
LowerIsHigher: score = 100 * ratio
HigherIsHigher: score = 100 * (1 - ratio)
```

The bounds are configured, not inferred from the current query results. Choose ranges that express comparable priorities across sources; normalization does not establish business equivalence automatically.

| Source | Range | Direction | Raw Value | Score |
| --- | --- | --- | --- | --- |
| Azure DevOps backlog | 1-101 | `LowerIsHigher` | 1 | 0 |
| Azure DevOps backlog | 1-101 | `LowerIsHigher` | 26 | 25 |
| GitHub numeric field | 0-4 | `HigherIsHigher` | 3 | 25 |
| GitHub numeric field | 0-4 | `HigherIsHigher` | 0 | 100 |

Values outside the configured range are clamped for scoring and marked `Clamped`; the original raw value is retained in the ranking metadata.

Ranked items are ordered by:

1. Normalized score, ascending.
2. Source `priority`, descending.
3. Original raw value in the source's priority direction.
4. Work item `GlobalId`, using ordinal string ordering.

Items without a usable rank are retained after ranked items, ordered by status and then `GlobalId`. Every item, including unranked items, receives a unique, one-based `Rank`. This position is distinct from its normalized `Score` and is relative to the candidate set being ranked.

## Results and Diagnostics

Each ranked query item carries `GlobalStackRank` metadata: `Profile`, `Rank`, `Score`, `SourceName`, `SourceField`, `RawValue`, `Clamped`, `Status`, and `Diagnostic`. Serialized property casing and projections depend on the output surface.

| Status | Meaning and Action |
| --- | --- |
| `Ranked` | A source matched and the field parsed numerically. Check `Clamped` to identify values outside the configured range. |
| `MissingField` | The ranking field is absent or null. Check the field reference name and provider data. |
| `InvalidValue` | The field exists but cannot be parsed as a number, including an empty or nonnumeric string. Use a numeric field or correct the source data. |
| `NoMatchingSource` | No source matched the item's connection identity and scope. Check provider, organization, project/repository, host, and selectors. |

Numeric CLR values, numeric strings parsed with invariant culture, and JSON numeric/string values are supported. Unranked items have no score. Their status ordering is `MissingField`, `InvalidValue`, then `NoMatchingSource`.

`QueryResult.GlobalStackRankSummary` contains the profile name, candidate/ranked/unranked/clamped counts, names of sources that contributed ranked items (`SuccessfulSources`), and correlated failed-connection diagnostics (`FailedSources`). Unnamed sources do not appear in `SuccessfulSources`. These lists are not a complete connection-health inventory: inspect the query's failed connections and warnings as well, especially when results are partial.

An unexpected order is often caused by an inverted `direction`, unsuitable fixed bounds, or a higher-priority overlapping source rule. Equal scores are expected: `Rank` remains unique because the deterministic tie-breakers still apply.

## Other Entry Points

| Surface | Activation and Output |
| --- | --- |
| .NET library | Set `QueryFilter.GlobalStackRankProfile` and query through `IWorkItemQueryService`. Read each item's `GlobalStackRank` and the result's `GlobalStackRankSummary`. |
| MCP | `ListGlobalStackRankProfiles` lists configured profiles. Pass `globalStackRankProfile` to `QueryWorkItems`; `sortBy` is ignored while ranking is active. Compact projections expose `globalRank` and `globalScore` plus the summary. |
| Report generation | `azdw report generate` accepts `--global-stack-rank` for its query path. The selected template determines how ranking metadata is displayed. |
| PowerShell | `Get-AzdwWorkItem -GlobalStackRank PlatformValueStream` forwards the profile to the CLI query. |
| REST service | Supply `globalStackRankProfile` in the query filter. Query responses include `globalStackRankSummary`. |
| GraphQL service | Set the query filter's `globalStackRankProfile`; request `globalRank`, `globalScore`, and `globalStackRankSummary` in the response selection. |

Omitting the profile leaves normal query behavior unchanged. Ranking requires a host configured with the global stack rank service and an enabled profile; selecting an unavailable profile fails rather than silently falling back to ordinary ordering.

## Related Documentation

The repository includes a commented, cross-provider [config/global-stack-rank-example.jsonc](../config/global-stack-rank-example.jsonc) and the [config/global-stack-rank-schema.json](../config/global-stack-rank-schema.json) schema.

- [Configuration-Discovery.md](Configuration-Discovery.md)
- [CLI-Help-Overview.md](CLI-Help-Overview.md)
- [Filtering-QueryResults.md](Filtering-QueryResults.md)
- [API-Documentation.md](API-Documentation.md)

## Implementation and Tests

- [src/azdw.lib/Services/GlobalStackRankService.cs](../src/azdw.lib/Services/GlobalStackRankService.cs): normalization, ordering, metadata, and configuration loading.
- [src/azdw.lib/Models/GlobalStackRankConfiguration.cs](../src/azdw.lib/Models/GlobalStackRankConfiguration.cs): profile validation and source matching.
- [tests/azdw.lib.tests/Services/GlobalStackRankServiceTests.cs](../tests/azdw.lib.tests/Services/GlobalStackRankServiceTests.cs): normalization, clamping, missing or invalid fields, deterministic ordering, mixed providers, and failed-source diagnostics.