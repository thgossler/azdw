# SPM Playbook: question → azdw approach

Maps common Strategic / Lean Portfolio Management questions to a concrete azdw
approach or an explicitly-labeled limitation + workaround. For full end-to-end
runs, see [portfolio-workflows.md](portfolio-workflows.md). For concept names, read
[portfolio-mapping.md](portfolio-mapping.md).

## General rules (apply to every entry)

- **Only real commands.** Every azdw command/flag below appears in the repo's
  `docs/CLI-Help-Overview.md`. If you need a capability not listed there, treat it
  as a gap (see [capability-gaps.md](capability-gaps.md)), not a command to invent.
- **MCP-first.** Prefer the `azdw_`-prefixed MCP tools; CLI (`--json`) is the
  fallback. Workaround scripts post-process MCP-retrieved JSON locally.
- **Names from the mapping.** Use type/state/field names from
  [portfolio-mapping.md](portfolio-mapping.md); confirm/discover unmapped names with
  the user or `azdw metadata` before running commands.
- **Confirm before writes; bound large output; label approximations.** Composite
  scores and derived progress are approximations, never tool-provided metrics.

## Strategy-to-execution alignment

**Q: Which strategic items have no delivery work linked?**
Approach: Resolve each portfolio item's hierarchy with `relationship find-closure
-i <ids> -c <connection>` (or the MCP closure tool) and flag items whose closure has
no child delivery items. For a connection-wide sweep of unlinked items, use
`relationship find-orphans -c <connections>` filtered to the portfolio type.

**Q: Trace this initiative down to the features/stories delivering it.**
Approach: `relationship find-closure -i <id> -c <connection> --json` (cross-connection
enabled by default). See journey P3.

## Value-flow visibility

**Q: Show the portfolio funnel / state distribution.**
Approach: Query the portfolio item type (`query -t <type> --format json` or the MCP
query tool), then group by funnel state. Native aggregation is **not** available →
`[GAP-001]` with `scripts/Get-PortfolioFunnel.ps1`.

**Q: Which items are stalled / aging in a funnel state?**
Approach: `query -t <type> -s <state> --modified-before <date> --format json` to list
items unchanged since a cutoff, then summarize counts per state via `[GAP-001]`.

## Investment-allocation visibility

**Q: How is investment spread across horizons / value streams?**
Approach: Query the portfolio items including the Investment Horizon / Value Stream
field plus the financial field, then group by that field. Grouping/summing is
**not** native → `[GAP-001]` with `scripts/Get-PortfolioFunnel.ps1 -GroupByField
<field>` for counts, and add `-SumField <financialField>` to roll up the stored
revenue/investment values per group. Note: the sum is a **local rollup** of the
field values already in the azdw output (only as complete as that field's data) —
not a finance-system figure.

**Q: Is our portfolio balanced across investment horizons?**
Approach: Same grouping as above on the Investment Horizon field; present the
distribution and call out imbalance. Labeled approximation (count-based).

## Roadmap & horizon planning

**Q: Show a Now / Next / Later (or H1/H2/H3) roadmap.**
Approach: Query portfolio items including the Investment Horizon and Target Date
fields (`query -t <type> --field <horizon> --field <targetDate> --format json`),
then group items into the horizon buckets. Grouping is a gap → `[GAP-001]` with
`scripts/Get-PortfolioFunnel.ps1 -GroupByField <horizon>` for the bucket counts;
sort within each bucket by Stack Rank for a Now/Next/Later list.

**Q: Render a time-scaled roadmap (Gantt) or a Kanban board.**
Approach: This **is** native — `visualize graph` emits both, from the work items'
own fields:
- Gantt (uses Start / Target dates):
  `azdw visualize graph -i <id> -c "<connection>" -f mermaid-gantt --exclude-weekends -o roadmap.mmd`
- Kanban (groups by state):
  `azdw visualize graph -i <id> -c "<connection>" -f mermaid-kanban --kanban-state-order "New,Active,Resolved,Closed" -o board.mmd`

Both also accept `--from-closure` / `--from-file` to render a closure you already
retrieved. The Gantt needs Start/Target dates
(`Microsoft.VSTS.Scheduling.StartDate` / `.TargetDate`); those fields are standard
but **often unfilled**. When a date is missing, do **not** silently drop the item —
infer a **best-guess** window from surrounding information and label it an estimate:
- inherit / clip to the **parent** item's Start/Target dates;
- use the item's (or its children's) **iteration / sprint** dates;
- derive timing from the **Investment Horizon** (e.g. H1 ≈ current/next quarter, H2
  ≈ 2–4 quarters out, H3 ≈ beyond) via a user-confirmed horizon→date mapping;
- bound by **sibling cadence** (neighbouring items in the same area path / stack
  rank) or the earliest/latest child dates from a `relationship find-closure`.
State plainly which dates are real vs inferred (e.g. an "(est.)" suffix or an
assumptions note beneath the chart), and offer to write inferred dates back only on
explicit confirmation. A roadmap built partly on inferred dates is a **labeled
approximation**, not a committed plan.

**Q: Organize the roadmap by quarterly themes / OKRs.**
Approach: A theme = a tag, area path, or parent Epic; an OKR = the OKR field from
the mapping. Group by that field (`[GAP-001]`). For OKR alignment coverage, reuse
"Strategy-to-execution alignment" to flag objectives with no linked delivery.

## Portfolio balance & bet discipline

**Q: Is the portfolio balanced across horizons / risk classes?**
Approach: Group portfolio items by Investment Horizon and by Portfolio Impact /
Risk Class (`[GAP-001]`), then compare the distribution to a **target mix** (e.g.
70/20/10 core/adjacent/transformational, or ~50-60% H1 / 25-30% H2 / 15-20% H3).
Call out imbalance (>70% in H1 = no future; >30% transformational = too risky). The
target mix is an **organizational policy input**, not an azdw default — ask for it.
For a value/effort rollup per horizon use `[GAP-001]` `-SumField` (a local rollup of
a financial or effort field already in the azdw output — not a finance-system
figure); azdw has no native aggregation.

**Q: Are our bets sized and sequenced sensibly?**
Approach: Bet "size" ≈ the Effort/Job-Size field; "impact" ≈ Business Value (or a
DVFC score). List candidates with both fields and flag (a) all-large portfolios
(no quick wins) and (b) demand vs supply per team/value-stream/horizon via the
native `azdw capacity analyze` command (see "Demand-vs-supply load analysis"
below) — it computes a load table and flags over-allocated, at-risk, and
idle-supply groups against a capacity-supply file. Resolve sequencing dependencies
with `relationship find-closure` / `find-circular`.

**Q: Demand-vs-supply load analysis (native)**
Approach: When the question is "do we have enough capacity for the demand?", use
`azdw capacity analyze`. It sums a numeric demand field across in-scope items and
compares it to declared supply from a capacity-supply file:

```
azdw capacity analyze \
  --capacity-file <path>            # optional; defaults to ~/.azdw/config/capacity-supply.jsonc
  --demand-field <REF>              # required unless 'capacityDemandField' is set in defaults.jsonc; e.g. Microsoft.VSTS.Scheduling.Effort
  --demand-unit <UNIT>             # optional; must match the capacity-file unit (default personWeeks)
  --group-by <DIMS>                # REQUIRED; subset of team,valueStream,horizon,areaPath,period
  # in-scope items (exactly one of the following):
  --query "<WIQL|IDS>" | --closure <ID>          # live retrieval (single connection)
  --closure-file <path> | --query-file <path>    # persisted output of find-closure/query (cross-connection; --connection ignored)
  --force-refresh                  # file sources only: re-query servers by work item ID for fresh demand values
  --ai-estimate                    # use configured AI to estimate demand for in-scope items lacking a value (fails early if no AI configured)
  --threshold-under <PCT> --threshold-overallocated <PCT>   # optional policy overrides
  --target-load <PCT>              # optional; enables drill-down (contributors + deferral-to-target)
  --json                            # machine-readable LoadAnalysisResult
```

Each row is classified (under-utilised, healthy, at-risk, over-allocated) with
uncovered-demand and idle-supply called out. This **supersedes** the old
`[GAP-001]` `-SumField` "effort sum vs stated capacity ceiling" workaround — azdw
now has a native capacity-supply model.

**Q: Which bets lack exit / scale criteria or are stuck past a stage gate?**
Approach: Exit/scale criteria live in a description or custom field. Flag items
missing those fields via `[GAP-004]` with `scripts/Test-PrioritizationData.ps1`.
Flag items aging in a gate/review state with
`query -s <gate-state> --modified-before <date> --format json`.

## Outcome & benefit realization

**Q: Are we realizing the business outcomes we committed to (output vs outcome)?**
Approach: azdw tracks **delivery** (states, links) — that is *output*, not realized
*outcome*. From the portfolio items' own fields you can derive two honest signals:
1. **Expected benefit at the realization stage** — for items in a Done / realized
   state, surface expected value (`Microsoft.VSTS.Common.BusinessValue`) against
   effort / investment (`Microsoft.VSTS.Scheduling.Effort`) for an expected
   value-per-effort view, and compare the expected value that *reached* Done to the
   total committed (a value-weighted realization funnel). Use `[GAP-005]`
   `scripts/Get-OutcomeRealization.ps1`.
2. **Realized actuals** — only if the process captures an *actual / realized* value
   field (add a custom field; not standard). If one exists, pass it via
   `-ActualValueField` to compute realization % = actual ÷ expected.

The script's defaults (`Microsoft.VSTS.Common.BusinessValue`,
`Microsoft.VSTS.Scheduling.Effort`) are **standard** fields, so it runs out of the
box, but they are **often unpopulated** and **process-dependent** (`Effort` is a
Scrum field; Agile Epics/Features may not have it). The script does **not** error on
missing data — it contributes 0, leaves the ratio blank, and reports how many items
lacked a value. If the defaults are empty for your process, point `-ValueFields` /
`-InvestmentField` at the fields you actually use (e.g. a custom value or cost
field). An expected-benefit view is only meaningful where those fields are filled.

Be explicit: reaching a Done state and the **expected** value are leading proxies,
**not** an independently verified outcome — that needs realized-benefit data entered
after go-live. Labeled `[GAP-005]` approximation.

## Prioritization

**Q: Rank these initiatives using WSJF.**
Approach: Gather candidates with their WSJF input fields (Business Value, Time
Criticality, RR/OE, Job Size) via `query --format json`, then compute
`WSJF = (Value + TimeCriticality + RR/OE) / JobSize`. WSJF is **not** native →
`[GAP-002]` with `scripts/Get-PrioritizationRanking.ps1 -Method WSJF`. State the
formula and weights explicitly; mark scores as approximations.

**Q: Compute a DVFC opportunity score.**
Approach: DVFC is the four-lens score **Desirability / Viability / Feasibility /
Contextuality** (do customers want it / does the business case hold / can we build
it / does it fit strategy & portfolio) — **not** a Demand/Value/Flow/Cost composite.
Gather one rollup field per lens via `query --format json`, then compute
`DVFC = (Desirability + Viability + Feasibility + Contextuality) / 4`. DVFC is
**not** native → `[GAP-002]` with
`scripts/Get-PrioritizationRanking.ps1 -Method DVFC`.

**Q: Rank using RICE or ICE.**
Approach: Gather the framework inputs (RICE: Reach, Impact, Confidence, Effort;
ICE: Impact, Confidence, Ease) via `query --format json`, then compute via
`[GAP-002]` with `scripts/Get-PrioritizationRanking.ps1 -Method RICE` (or `ICE`).
`RICE = (Reach × Impact × Confidence) / Effort`; `ICE = Impact × Confidence × Ease`.
No standard ADO fields exist for these inputs — confirm the mapped fields first;
state the formula and mark scores as approximations.

**Q: Classify with MoSCoW or a Value-vs-Effort matrix.**
Approach: These are **classifications**, not scores. For MoSCoW, read the Priority
field (or a tag) and bucket items into Must / Should / Could / Won't. For
Value-vs-Effort, read the value and effort fields and bucket into quick-wins (high
value / low effort), big-bets (high / high), fill-ins (low / low), and money-pits
(low value / high effort). Grouping is **not** native → `[GAP-001]` with
`scripts/Get-PortfolioFunnel.ps1 -GroupByField <field>` for counts; describe the
2×2 placement narratively. Labeled approximation.

**Q: Stack-rank our backlog by value vs. effort / check stack-rank hygiene.**
Approach: Query items with the Stack Rank and value/effort fields; review ordering.
Flag duplicate stack ranks and missing scores separately via `[GAP-004]` with
`scripts/Test-PrioritizationData.ps1` — keep data-quality findings distinct from the
ranking result.

## Adaptability / scenario support (change impact)

**Q: If we deprioritize initiative X, what's affected and how far along is it?**
Approach: `relationship find-closure -i <id> -c <connection> --json` for the impact
set; derive an **approximate** completion % from child states via `[GAP-003]` with
`scripts/Get-ProgressRollup.ps1`; list dependencies and at-risk work. Optionally
`visualize graph` for stakeholders. See journey P3.

## Dependency classification & change impact

**Q: What does this initiative depend on, and which dependencies are risky?**
Approach: Resolve the hierarchy with `relationship find-closure -i <id>
-c <connection> --json`; read the External Dependencies field from the mapping.
Classify each dependency as technical / team / external / knowledge / sequential,
and flag cross-team and external ones as highest-risk (single points of failure).
Detect dependency cycles with `relationship find-circular`. Record an owner and a
"need-by" date per dependency (conventions, not azdw fields). See journey P3.

## Business-risk register (delivery & portfolio risk)

**Q: What are the top portfolio / business risks right now?**
Approach: Build a lightweight register over **existing data** — do not invent a risk
framework. Sources: the categorical Risk field from the mapping; At-Risk / Blocked
items (state); overdue items (Target Date past, via `query` + date filter); aging
items (`--modified-before`); dependency hotspots (`find-circular` / external deps).
Present as identify → assess (likelihood × impact, using the Risk field where set)
→ mitigate (owner + action) → monitor (re-check cadence). This is **business /
delivery** risk — not ISO-14971 medical-device or cybersecurity risk management.

## Communicating portfolio changes

**Q: How do I present a reprioritization / roadmap change?**
Approach (formatting guidance, no new commands): acknowledge what changed → explain
why → show the trade-off (what comes off — roadmaps are zero-sum) → state the new
plan → note the stakeholder impact. Avoid "roadmap whiplash": batch changes at a
regular cadence rather than reacting item-by-item. Shape output per audience —
executive summary (themes, horizons, top risks) vs engineering detail (items, deps,
states) vs customer-facing (committed vs exploratory). Lead with "what changed since
last review" using closure/query deltas.

## Outcome-vs-output awareness

**Q: What business outcomes has this portfolio delivered?**
Approach: Be honest about scope — azdw tracks **work-item lifecycle (output)**, not
realized business value (outcome). Report state-based progress as output and
recommend outcome-tracking conventions (e.g., a dedicated outcome field/type) rather
than implying azdw measures outcomes. No fabricated capability.

## Portfolio transparency / reporting

**Q: Produce a shareable portfolio report / visualization.**
Approach: For visualizations use `visualize graph -i <ids> -c <connection>
-f mermaid-flowchart` (or other supported formats). For template-based reports use
`report generate -id <template-id>`. Only use template IDs that exist
(`report template list`).
