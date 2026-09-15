---
name: manage-software-portfolio
description: Strategic and Lean Portfolio Management (SPM/LPM) over Azure DevOps work items using the azdw tool. Use for portfolio funnel and health overviews, investment-allocation and balanced-portfolio views, roadmap and horizon planning (Now/Next/Later, H1/H2/H3), prioritization (WSJF, RICE, ICE, DVFC four-lens, MoSCoW, value-vs-effort, stack-rank hygiene), bet/balance discipline, business-risk register, and strategy-to-execution traceability and change-impact analysis across initiatives. Trigger on phrases like portfolio health, portfolio funnel, investment horizon, value stream, prioritize initiatives, WSJF, RICE, ICE, DVFC, stack rank, roadmap balance, horizons, portfolio bets, strategy-to-execution, or downstream impact. Do NOT use for creating or updating a single work item (use manage-workitems) or for regulatory and compliance questions (use regulatory-compliance).
---

# Manage Software Portfolio with azdw

## 1. Purpose & scope

This skill helps an AI assistant support **Strategic Portfolio Management (SPM)**
and **Lean Portfolio Management (LPM)** over Azure DevOps work items using the
existing `azdw` CLI / MCP server. It teaches the agent to combine azdw's *existing*
capabilities — querying, relationship traversal/closure, dependency/health
analysis, visualization, reporting — into reliable portfolio workflows.

It does **not** add or change any azdw feature. Where azdw lacks a native
capability (aggregation, prioritization scoring, progress rollup), the skill uses a
clearly-labeled **workaround** referenced by Gap ID (see `capability-gaps.md`).

> One-line reminder: **prefer the azdw MCP tools; gather data MCP-first, then do
> any post-processing locally with the bundled workaround scripts.**

The three portfolio journeys this skill covers:

- **P1 — Portfolio funnel & health overview** ("How healthy is our portfolio and
  where are the bottlenecks?")
- **P2 — Prioritization support** ("Which initiatives should we fund next?")
- **P3 — Strategy-to-execution traceability & change impact** ("If we deprioritize
  this, what delivery work is affected and how far along is it?")

## 2. Check the mapping first

Before issuing any command that depends on a work item **type, state, or field
name**, read [portfolio-mapping.md](portfolio-mapping.md). It is the single source
of name customization for this skill. The rest of this skill refers to portfolio
concepts by name from that file — never assume a process-template-specific name.

The mapping ships **pre-filled with standard Azure DevOps defaults** (Basic, Agile,
Scrum, CMMI types/states/fields), so the skill works out of the box on a default
project. The top-level fundable unit is the **Epic**; multiple portfolio tiers are
modeled as **parent-child linked Epics** (the single standard `Epic` type used at
several levels). For a customized (inherited) process, override the affected rows.

If a needed concept has **no row** in the mapping file, do not guess: confirm the
real name with the user (optionally via `azdw metadata types|states|fields
-c <connection>`), then suggest adding a mapping row for reuse.

## 3. Interface decision rule (MCP-first)

**Always prefer the `azdw_`-prefixed MCP tools over the CLI.** Use the CLI only as
a fallback when the MCP server cannot be enabled. This mirrors the decision flow in
the sibling `manage-workitems` skill — see that skill's "Choose Your
Interface" section for full MCP setup steps rather than duplicating them here.

- If `azdw_`-prefixed tools are present → use them.
- If not → attempt MCP setup (per the sibling skill), then retry.
- Only if MCP cannot be enabled → use the CLI with `--json` for machine-readable
  output.

When a workaround script is needed, the data is still gathered **MCP-first**; the
script only post-processes the JSON the MCP tool (or CLI fallback) returned.

## 4. The three workflows at a glance

Full step-by-step runs (with expected output shapes and worked examples) live in
[portfolio-workflows.md](portfolio-workflows.md). Question-to-approach mappings live
in [spm-playbook.md](spm-playbook.md).

- **P1 — Portfolio funnel & health overview**: Query the portfolio item type, group
  by funnel state to show the distribution (aggregation is a gap → `[GAP-001]`,
  `scripts/Get-PortfolioFunnel.ps1`), then summarize dependency / orphan / circular
  risks via `relationship find-orphans`, `relationship find-circular`, and
  `relationship analyze`. End with a decision-oriented summary.
  See [portfolio-workflows.md](portfolio-workflows.md#journey-p1--portfolio-funnel--health-overview).
- **P2 — Prioritization support**: Gather candidates, pick a method (WSJF, RICE,
  ICE, the DVFC four-lens score, or stack-rank review; MoSCoW / value-vs-effort as
  classifications), compute the ranking (scoring is a gap → `[GAP-002]`,
  `scripts/Get-PrioritizationRanking.ps1`), state the formula/weights explicitly,
  and flag data-quality issues separately (`[GAP-004]`,
  `scripts/Test-PrioritizationData.ps1`).
  See [portfolio-workflows.md](portfolio-workflows.md#journey-p2--prioritization-support).
- **P3 — Strategy-to-execution traceability & change impact**: Traverse the
  hierarchy with `relationship find-closure` (request the connection name when
  required), derive an **approximate** completion measure from item states
  (rollup is a gap → `[GAP-003]`, `scripts/Get-ProgressRollup.ps1`), list affected
  work and dependencies, and optionally produce a `visualize graph`.
  See [portfolio-workflows.md](portfolio-workflows.md#journey-p3--strategy-to-execution-traceability--change-impact).

## 5. Capability honesty & safety rules

These rules apply to every response:

- **Never invent commands or flags.** Reference only commands present in the repo's
  `docs/CLI-Help-Overview.md`. Other docs may be outdated; that file is the
  authority.
- **Label gaps by Gap ID.** When asked for something azdw cannot do natively
  (aggregation, prioritization scoring, progress rollup, expected-benefit/outcome
  rollup), state the limitation plainly and offer the
  workaround named by its Gap ID. Gantt and Kanban rendering **are** native
  (`visualize graph -f mermaid-gantt|mermaid-kanban`); **demand-vs-supply load
  analysis is also native** via `azdw capacity analyze` (no gap). The full register
  is in [capability-gaps.md](capability-gaps.md).
- **Gather MCP-first, post-process locally.** Workaround scripts under `scripts/`
  read the JSON the agent already retrieved via azdw; they never call Azure DevOps
  write APIs.
- **Confirm before writes.** Confirm any write or bulk operation with the user
  first. This skill's journeys are read/analyze-only by default.
- **Confirm org-specific names.** Confirm or discover real type/state/field names
  via the mapping file or `azdw metadata`. **Connection names are user-local and not
  stable** — identify projects by Azure DevOps org + project name and resolve the
  local connection via `azdw connection list --json` before any name-dependent `-c`
  command. If the resolved connection is **org-scoped** (no project in its URL), also
  pass the project selector (`-p "<project>"` for `metadata`/`workitem create`, or a
  `[System.TeamProject] = '<project>'` filter in `wiql`).
- **Bound large output.** For large portfolios, bound traversal/output (e.g.,
  `--max-size`, `--max-depth`, `--limit`) and summarize into decision-oriented
  answers rather than dumping raw data.
- **Separate facts from approximations.** Clearly distinguish tool-verifiable facts
  (states, relationships) from derived values (progress %, composite scores), which
  must be labeled approximations.

## 6. Reference index

- [portfolio-mapping.md](portfolio-mapping.md) — the single customization file
  (concept → type / state / field). Read this first.
- [capability-gaps.md](capability-gaps.md) — the gap register and workaround
  scripts (Gap IDs, native replacement targets, removal workflow).
- [spm-playbook.md](spm-playbook.md) — SPM/LPM question → azdw approach (or labeled
  limitation).
- [portfolio-workflows.md](portfolio-workflows.md) — end-to-end runs of the three
  journeys with worked examples.
