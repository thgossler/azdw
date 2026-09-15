# Portfolio Mapping (standard Azure DevOps defaults — customize as needed)

This is the **single place** to adapt the `manage-software-portfolio` skill to your
organization's Azure DevOps process. The playbook (`spm-playbook.md`) and workflows
(`portfolio-workflows.md`) refer to portfolio concepts **by name from these tables**,
never by hard-coded work item type/state/field names.

These tables ship pre-filled with the **out-of-the-box** work item types, states, and
field reference names from the four standard processes — **Basic, Agile, Scrum, and
CMMI** — so the skill works **without customization** on a default project. The 
standard top-level fundable unit is the **Epic**.

How the agent uses this file:

- Read these tables **before** issuing any command that depends on a type, state, or
  field name.
- Pick the column / variant matching the connection's **process**. Discover the actual
  process, types, states, and fields with
  `azdw metadata types|states|fields -c <connection>` when unsure.
- If your project uses a **customized (inherited)** process, override the affected rows
  here with your custom type/state/field reference names and add any missing concepts.
- If a needed concept has **no row here**, do not guess — confirm the real name via
  `azdw metadata`, then add a row for future reuse.

> Use only Markdown tables here (no JSON/YAML). One row per concept.

## Multi-level Epics (portfolio tiers)

Azure DevOps ships a **single `Epic` work item type**. Model multiple portfolio tiers
as **parent-child linked Epics** (e.g. *Portfolio Epic → Program Epic → Solution
Epic*). The same `Epic` type therefore serves several purposes at different depths.

- Traverse the full multi-level Epic hierarchy with
  `azdw relationship find-closure -i <id> -c <connection> -t Epic`.
- Distinguish tiers with `System.Tags`, `Microsoft.VSTS.Common.ValueArea`, area path,
  or a custom "Portfolio Tier" field — record that choice in Table C.
- When the skill says "Epic", it means **any tier** unless a tier is named explicitly.

## Table A — Portfolio concept → work item type

| Portfolio concept | Work item type | Notes |
| ----------------- | -------------- | ----- |
| Strategy / Portfolio Epic (top tier) | `Epic` | Highest Epic in a multi-level **linked-Epic** hierarchy; the top-level fundable unit |
| Program / Solution Epic (lower tiers) | `Epic` | Child `Epic`(s) linked under a portfolio Epic via parent-child links |
| Feature | `Feature` | Agile, Scrum, CMMI. **Basic has no Feature** — use a child `Epic` or `Issue` instead |
| Requirement / Deliverable | `User Story` (Agile) · `Product Backlog Item` (Scrum) · `Issue` (Basic) · `Requirement` (CMMI) | Requirement-category type; the name depends on the process |
| Task | `Task` | Execution-level work under a requirement |
| Bug | `Bug` | Defect; tracked at requirement or task level per team configuration |

## Table B — Portfolio funnel state → work item state

State names differ per process. Pick the column for the connection's process. The
Removed/deleted state is excluded from backlogs.

| Portfolio funnel stage | Agile | Scrum | Basic | CMMI |
| ---------------------- | ----- | ----- | ----- | ---- |
| Funnel (new idea) | `New` | `New` | `To Do` | `Proposed` |
| Reviewing / Approved | `Active` | `Approved` | `Doing` | `Active` |
| Implementing | `Active` | `Committed` | `Doing` | `Active` |
| Verifying | `Resolved` | `Committed` | `Doing` | `Resolved` |
| Done | `Closed` | `Done` | `Done` | `Closed` |
| Removed | `Removed` | `Removed` | _(deleted)_ | `Removed` |

> Note: Agile and Scrum **Epic/Feature** workflows match the columns above. `Active`
> covers both "reviewing" and "implementing" in Agile/CMMI — distinguish those stages
> with an explicit board column or a date/owner field if you need finer funnel
> granularity.

## Table C — Portfolio attribute → field reference name

All rows below are **standard** fields except where noted as not modeled by default.

| Portfolio attribute | Field reference name | Notes |
| ------------------- | -------------------- | ----- |
| Business Value | `Microsoft.VSTS.Common.BusinessValue` | Standard; on Epic/Feature/requirement. WSJF "Value" term |
| Time Criticality | `Microsoft.VSTS.Common.TimeCriticality` | Standard on Epic/Feature (Agile, Scrum). WSJF term |
| Effort / Job Size | `Microsoft.VSTS.Scheduling.Effort` | Standard on Epic/Feature (Scrum) and PBI. WSJF denominator |
| Story Points | `Microsoft.VSTS.Scheduling.StoryPoints` | Agile User Story sizing (alternative job-size at story level) |
| Risk Reduction / Opportunity Enablement | `(no standard field — add a custom field)` | Not modeled by default; without it, WSJF numerator = Business Value + Time Criticality |
| Risk | `Microsoft.VSTS.Common.Risk` | Standard categorical risk (Agile, CMMI) |
| Value Area | `Microsoft.VSTS.Common.ValueArea` | `Business` / `Architectural`; useful to tag portfolio tiers |
| Priority | `Microsoft.VSTS.Common.Priority` | Standard 1–4 priority |
| Target Date | `Microsoft.VSTS.Scheduling.TargetDate` | Standard on Epic/Feature; roadmap timing |
| Stack Rank | `Microsoft.VSTS.Common.StackRank` | Default ordering field (Agile, Basic, CMMI) |
| Backlog Priority | `Microsoft.VSTS.Common.BacklogPriority` | Scrum ordering field (equivalent of Stack Rank) |
| Investment Horizon | `Microsoft.VSTS.Common.ValueArea` _(stand-in)_ | No dedicated standard field; use `Value Area`, `System.Tags`, or a custom "Horizon" field for H1/H2/H3 balance views |
| Portfolio Impact / Risk Class | `Microsoft.VSTS.Common.Risk` _(stand-in)_ | For core/adjacent/transformational balance; or use `Tags`/a custom field |
| Value Stream / Segmentation | `System.Tags` _(stand-in)_ | No dedicated standard field; use `Tags`, area path, or a custom field to segment funnel/allocation views |
| Reach (RICE) | `(no standard field — add a custom field)` | RICE input; how many users/customers affected per period |
| Impact (RICE / ICE) | `(no standard field — add a custom field)` | RICE/ICE input; per-item impact magnitude |
| Confidence (RICE / ICE) | `(no standard field — add a custom field)` | RICE/ICE input; confidence in the estimate (0–1 or %) |
| Ease (ICE) | `(no standard field — add a custom field)` | ICE input; inverse of effort/difficulty |
| Desirability / Viability / Feasibility / Contextuality (DVFC lenses) | `(no standard fields — add custom fields)` | Four-lens opportunity score; map one rollup field per lens if your org models DVFC |
| WSJF / RICE / ICE / DVFC score | `(computed via workaround)` | No native field; composites computed via `[GAP-002]` |

> WSJF out of the box: `WSJF = (Business Value + Time Criticality) ÷ Effort`. Add a
> custom Risk-Reduction/Opportunity-Enablement field to complete the classic SAFe
> Cost-of-Delay numerator. Alternative frameworks (all via `[GAP-002]`,
> `Get-PrioritizationRanking.ps1`): **RICE** = (Reach × Impact × Confidence) ÷ Effort;
> **ICE** = Impact × Confidence × Ease; **DVFC** = (Desirability + Viability +
> Feasibility + Contextuality) ÷ 4 — the four-lens opportunity score (do customers
> want it / does the business case hold / can we build it / does it fit strategy),
> *not* a Demand/Value/Flow/Cost composite. All need custom fields — map them above.

## Projects & connection resolution

**Connection names are user-local and NOT stable.** Each azdw user may name the same
Azure DevOps project differently, so a connection name is not a reliable identifier.
The stable identity of a project is its **Azure DevOps organization + project name**
(equivalently its base URL `https://dev.azure.com/<org>/<project>`). Identify your
portfolio and delivery projects by that stable identity, then resolve the local
connection name at runtime:

1. Run `azdw connection list --json`.
2. Match each `connections[].url` (or `organization` + `projectName`) to the project
   you mean. A match can be either:
   - **Project-scoped** — `scope` is `Project`, `url` ends in `/<org>/<project>`,
     `projectName` set. Bound to that one project; `-c <name>` alone is enough.
   - **Organization-scoped** — `scope` is `Organization`, `url` is the org only
     (`https://dev.azure.com/<org>`), `projectName` is `null`. It can reach **any**
     project in that org, so it is a valid way to use the project even though the
     project is not named in the connection — but you must then tell azdw which
     project to use (see below).
3. Use that entry's **`name`** as the `-c <connection>` value (prefer a project-scoped
   match when one exists). If no connection matches, tell the user which org/project
   is missing and suggest `azdw connection add` — do **not** guess a name.

**Selecting the project on an org-scoped connection.** When the resolved connection is
org-scoped, `-c <name>` targets the whole organization, so narrow to the project:

- **`metadata`** commands and **`workitem create`** accept `-p, --project "<project>"`
  (optional if the connection is project-scoped, required if org-scoped).
- **`wiql`** has no `--project` flag: add `AND [System.TeamProject] = '<project>'` to
  the `WHERE` clause.
- **`query`** spans all projects of an org-scoped connection; isolate one with
  `--by-project` or the org/project columns.
- **`relationship find-closure` / `analyze`** are work-item-ID-based; the project is
  implied by the IDs and cross-project resolution is automatic.

| Portfolio role | Stable identity (org / project) | Notes |
| -------------- | ------------------------------- | ----- |
| Portfolio (top-level items) | _your portfolio project's org + project name_ | Required by `find-orphans`, `find-circular`, `find-closure`, `metadata`. Resolve to a connection name via `azdw connection list --json`. |
| Delivery (Epics/Features/Stories) | _your delivery project's org + project name_ | Same project if portfolio and delivery share one; otherwise the delivery project's own identity for cross-connection traversal. |

> If exactly one connection is configured, the agent uses it automatically. If several
> exist, resolve by stable org/project identity (above) rather than guessing a name.
