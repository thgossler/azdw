# Portfolio Workflows

End-to-end runs of the three portfolio journeys. Each is **MCP-first** (CLI shown as
fallback), uses concept names from [portfolio-mapping.md](portfolio-mapping.md), and
cites capability gaps by Gap ID (see [capability-gaps.md](capability-gaps.md)).

Conventions used below:

- `<portfolio-type>`, `<funnel states>`, `<connection>`, `<...field>` come from the
  mapping file — confirm/discover unmapped names before running commands.
- **`<connection>` is user-local.** Identify projects by their stable Azure DevOps
  org + project name and resolve the local connection name once per session via
  `azdw connection list --json` (match on `url` / `projectName`). See *Projects &
  connection resolution* in the mapping file. If the resolved connection is
  **org-scoped** (no project in its URL), also pass the project selector — `-p
  "<project>"` for `metadata` / `workitem create`, or `AND [System.TeamProject] =
  '<project>'` in `wiql` (`find-closure`/`analyze` are ID-based and need none).
- MCP: prefer `azdw_`-prefixed tools. CLI lines (with `--json`) are the fallback.
- Workaround scripts post-process the JSON the MCP tool / CLI returned; run them with
  the harness's own script execution (e.g., `pwsh scripts/<Name>.ps1`).

---

## Journey P1 — Portfolio funnel & health overview

**Goal**: Answer "How healthy is our portfolio and where are the bottlenecks?" with a
funnel/state distribution plus a dependency / orphan / circular-risk health summary.

### Steps

1. **Confirm names.** Read the mapping file for `<portfolio-type>`, the funnel
   states, and the portfolio `<connection>`. If missing, confirm with the user or
   run `azdw metadata types -c <connection>` / `azdw metadata states -t <type>
   -c <connection>`.
2. **Gather portfolio items (MCP-first).** Use the MCP query tool for
   `<portfolio-type>`; CLI fallback:
   ```bash
   azdw query -t "<portfolio-type>" --format json > items.json
   ```
3. **Funnel / state distribution** — aggregation is a gap (`[GAP-001]`):
   ```bash
   pwsh scripts/Get-PortfolioFunnel.ps1 -Path items.json -GroupByField System.State
   ```
   Output is a per-state count distribution labeled as a `[GAP-001]` workaround.
4. **Dependency / orphan / circular health.**
   ```bash
   azdw relationship find-orphans  -c "<connection>" -t "<portfolio-type>" --json
   azdw relationship find-circular -c "<connection>" --json
   azdw relationship analyze       -i <portfolio-ids> -c "<connection>" --json
   ```
   (Prefer the equivalent MCP relationship tools when available.)
5. **Summarize for decisions.** Report the funnel shape (where items pile up), the
   count of orphans and circular chains, and 2–3 concrete next questions. Do **not**
   dump raw item lists; summarize and offer to drill in.

### Expected output shape

- A funnel table: funnel state → count (and % of total).
- A health summary: # orphans, # circular chains, notable dependency hotspots.
- A short decision-oriented narrative ("Most items are stuck in the *Reviewing*
  stage; 3 orphaned Epics need linking; one circular dependency to resolve.").

### Notes

- Aggregation, investment-allocation grouping, and any "portfolio health" rollup are
  **not** native — all handled via `[GAP-001]`. State counts are facts; any derived
  ratios are approximations.

---

## Journey P2 — Prioritization support

**Goal**: Answer "Which initiatives should we fund next?" with a transparent ranking
(WSJF, RICE, ICE, the DVFC four-lens score, or stack-rank review), explicit
method/assumptions, and separate data-quality flags.

### Steps

1. **Confirm names & method.** From the mapping file, identify the scoring fields
   (WSJF inputs Value / Time Criticality / RR-OE / Job Size; RICE inputs Reach /
   Impact / Confidence / Effort; ICE inputs Impact / Confidence / Ease; the four
   DVFC lens fields; or Stack Rank). Pick the method the available fields support;
   if scoring fields are absent, say so and offer stack-rank review or a MoSCoW /
   value-vs-effort classification.
2. **Gather candidates (MCP-first).** CLI fallback:
   ```bash
   azdw query -t "<portfolio-type>" -s "<active funnel states>" --all-fields --format json > candidates.json
   ```
3. **Data-quality first** — separate from the ranking (`[GAP-004]`):
   ```bash
   pwsh scripts/Test-PrioritizationData.ps1 -Path candidates.json \
       -ScoreFields "<value-field>,<cost-field>" -StackRankField Microsoft.VSTS.Common.StackRank
   ```
   Reports items missing scores and duplicate stack ranks.
4. **Compute the ranking** — scoring is a gap (`[GAP-002]`):
   ```bash
   # WSJF: (BusinessValue + TimeCriticality + RiskReduction) / JobSize
   pwsh scripts/Get-PrioritizationRanking.ps1 -Path candidates.json -Method WSJF \
       -ValueField "<value>" -TimeCriticalityField "<tc>" -RiskReductionField "<rroe>" -JobSizeField "<cost>"

   # RICE: (Reach * Impact * Confidence) / Effort
   pwsh scripts/Get-PrioritizationRanking.ps1 -Path candidates.json -Method RICE \
       -ReachField "<r>" -ImpactField "<i>" -ConfidenceField "<c>" -EffortField "<e>"

   # ICE: Impact * Confidence * Ease
   pwsh scripts/Get-PrioritizationRanking.ps1 -Path candidates.json -Method ICE \
       -ImpactField "<i>" -ConfidenceField "<c>" -EaseField "<ease>"

   # DVFC: (Desirability + Viability + Feasibility + Contextuality) / 4  (four-lens score)
   pwsh scripts/Get-PrioritizationRanking.ps1 -Path candidates.json -Method DVFC \
       -DesirabilityField "<d>" -ViabilityField "<v>" -FeasibilityField "<f>" -ContextualityField "<c>"
   ```
5. **Present transparently.** Show the ranked list **with the formula and weights
   stated**, mark the composite scores as approximations (`[GAP-002]`), and present
   the data-quality flags from step 3 as a **separate** section.

### Expected output shape

- A ranked table: rank, item, component inputs, computed score (labeled
  approximate).
- An explicit "Method & assumptions" note (formula, weights, tie-breaking).
- A separate "Data-quality flags" list (missing scores, duplicate stack ranks).

### Notes

- azdw has **no** native prioritization-scoring calculation — never imply otherwise;
  the numbers come from the `[GAP-002]` workaround on MCP-retrieved data.

---

## Journey P3 — Strategy-to-execution traceability & change impact

**Goal**: Answer "If we deprioritize initiative X, what delivery work is affected and
how far along is it?" via relationship closure, state-derived progress
approximation, dependency/at-risk listing, and optional visualization.

### Steps

1. **Confirm the connection.** Closure is connection-scoped — obtain `<connection>`
   from the mapping file or `azdw connection list`. Do not proceed without it.
2. **Compute the closure (MCP-first).** CLI fallback (bounded for large portfolios):
   ```bash
   azdw relationship find-closure -i <id> -c "<connection>" \
       -t "<portfolio-type>" --max-size 2000 --json > closure.json
   ```
   Cross-connection resolution is on by default, so delivery work in other
   connections is included.
3. **Derive approximate progress** — rollup is a gap (`[GAP-003]`):
   ```bash
   pwsh scripts/Get-ProgressRollup.ps1 -Path closure.json \
       -DoneStates "Closed,Done,Completed,Resolved"
   ```
   Output is an **approximate** completion % from child states, labeled `[GAP-003]`.
4. **List impact & dependencies.** From the closure, list affected delivery items,
   cross-initiative dependencies, and at-risk work (e.g., blocked or stalled
   states). Bound the output and summarize.
5. **Optional visualization.**
   ```bash
   azdw visualize graph -i <id> -c "<connection>" -f mermaid-flowchart -o impact.mmd
   # or feed the closure directly:
   azdw visualize graph --from-closure -o impact.mmd
   ```

### Expected output shape

- An impact list: affected items grouped by type/state, plus dependencies.
- An approximate completion % (clearly labeled `[GAP-003]` approximation, not a
  tool metric).
- An optional Mermaid/Graphviz visualization for stakeholders.

### Notes

- Progress derived from states is an **approximation** of output, not realized
  business outcome. Separate verifiable facts (states, links) from the derived %.
- For very large hierarchies, use `--max-size` and `--max-depth` to bound the
  closure and summarize rather than dumping it.
