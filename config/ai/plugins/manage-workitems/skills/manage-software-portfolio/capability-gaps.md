# Capability Gap Register

This is the **single catalogue** of portfolio capabilities that `azdw` does **not**
provide natively, the bundled PowerShell workaround that fills each gap, and the
future azdw capability that will let us **retire** the workaround cleanly.

The skill body, `spm-playbook.md`, and `portfolio-workflows.md` reference these
gaps **only by Gap ID** (e.g., `[GAP-001]`) so eliminating a gap in a future skill
version is a localized edit.

## Authoritative capability source

The only authoritative source of which azdw commands/flags exist is the repo's
`docs/CLI-Help-Overview.md` (generated from live `--help`). A "gap" is any
portfolio capability **not** expressible with a command/flag present in that file.
Never justify a command from secondary docs that is absent from the CLI help
overview.

## Execution model (how the scripts run)

The scripts under `scripts/` are **bundled content of this skill**, not azdw
features. Whichever **agent harness** loads the skill executes them with its own
script-execution capability (azdw `ai-chat`, or another harness such as VS Code or
Claude that consumes the azdw MCP server). There is **no dedicated azdw MCP tool**
that runs them. Input data is gathered **MCP-first**: the agent retrieves work item
JSON via the `azdw_`-prefixed MCP tools (CLI `azdw ... --json` only as fallback) and
pipes it to the script. The scripts do **local, read-only post-processing only** —
no new azdw feature and no azdw code change.

## Gap register

| Gap ID | Capability gap | azdw input used | Workaround script | Native replacement target | Status |
| ------ | -------------- | --------------- | ----------------- | ------------------------- | ------ |
| GAP-001 | Aggregation / grouping — count distribution **and numeric sum** (funnel state distribution; investment-allocation and effort-load rollups by horizon/value-stream) | `query` / `wiql --format json` | `scripts/Get-PortfolioFunnel.ps1` (`-GroupByField`, `-SumField`) | `query` aggregation / `--group-by` / `--aggregate-sum` | active |
| GAP-002 | WSJF / RICE / ICE / DVFC composite scoring | `query --format json` (scoring fields) | `scripts/Get-PrioritizationRanking.ps1` | `--calculate-<method>` | active |
| GAP-003 | Progress rollup from a hierarchy | `relationship find-closure --json` | `scripts/Get-ProgressRollup.ps1` | closure progress / rollup metric | active |
| GAP-004 | Prioritization data-quality checks (missing scores, duplicate stack ranks) | `query --format json` | `scripts/Test-PrioritizationData.ps1` | validation / report capability | active |
| GAP-005 | Outcome / benefit-realization rollup — expected business-case value vs realization-stage coverage (and vs realized actuals when an actuals field exists) | `query --all-fields --format json` (business-case + state fields) | `scripts/Get-OutcomeRealization.ps1` | outcome / benefit metric on `query` / `report` | active |

Gap IDs are **stable and never reused**. Every row has a non-empty *Native
replacement target* so each gap is retireable.

> **Native capability — demand-vs-supply load analysis.** Computing demand
> (a summed numeric field) against declared supply and classifying load
> (under-utilised / healthy / at-risk / over-allocated, plus uncovered-demand and
> idle-supply) is **native** via `azdw capacity analyze` (`--capacity-file`,
> `--demand-field`, `--group-by`, `--query`/`--closure`, `--target-load`,
> `--json`). Use it instead of the GAP-001 `-SumField` "effort sum vs stated
> capacity ceiling" workaround. GAP-001 remains active only for generic count/sum
> distributions that the native command does not cover.

## Removal workflow (retiring a gap in a future skill version)

When azdw gains a native capability that supersedes a workaround:

1. **Confirm** the native capability now exists in the repo's
   `docs/CLI-Help-Overview.md`.
2. **Delete** the workaround script under `scripts/`.
3. **Delete** the register row above (or set its `Status` to `superseded`).
4. **Replace** every `[GAP-00X]` reference in `spm-playbook.md` and
   `portfolio-workflows.md` with the now-native command.
