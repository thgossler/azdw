# AGENTS.md — Example

> **File purpose**: This file provides **organization-specific** workspace context for AI agents
> and assistants (GitHub Copilot, Claude, azdw CLI/MCP, Gemini, etc.). Place a customized version
> at the root of your repository as `AGENTS.md`. The azdw MCP server and CLI discover it
> automatically and inject its contents into every AI chat session.
>
> Focus on information the AI **cannot** discover from azdw's built-in system messages
> (connections, tool usage, query syntax, WIQL macros, and generic Azure DevOps behavior are
> already handled). Instead, describe **your organization's specific** processes, conventions,
> and decision rules.

---

## Organization & Strategic Context

**Organization**: Contoso Digital Products
**Portfolio scope**: Strategic portfolio management, product management, and project delivery
**Teams**: Portfolio Office · Product Management · Delivery Teams (3 squads)

Our portfolio is aligned to three strategic themes — use these when the user asks about
priorities, roadmap alignment, or investment categories:

| Theme | Purpose | Typical Epics |
| ----- | ------- | ------------- |
| **Grow** | Expand market share through new customer-facing capabilities | New modules, integrations, market-entry features |
| **Run** | Operational excellence and reliability of existing products | SLA improvements, incident reduction, performance tuning |
| **Transform** | Platform modernization and technical debt reduction | Architecture migration, toolchain upgrades, API redesign |

Epics are tagged with `theme:grow`, `theme:run`, or `theme:transform`.

---

## Our Process Rules & Conventions

These rules are **specific to our organization** and override generic defaults:

### Portfolio Level (Epics)
- An Epic must have **Business Value** (1–100), **Effort** estimate, and a **Theme** tag before it can move to Active.
- Area Path must match the owning product area (see team table below).
- Never close an Epic while any child Feature is still Active or New — query children first.

### Product Level (Features)
- Every Feature must reference a parent Epic before leaving the New state.
- Acceptance Criteria (`Microsoft.VSTS.Common.AcceptanceCriteria`) must be populated.
- When asked to prioritize a backlog, sort by **Business Value desc**, then **Effort asc** (highest ROI first).

### Delivery Level (User Stories & Tasks)
- User Stories must have an **Iteration Path** assigned before moving to Active.
- Tasks must always have a parent User Story — never create orphan Tasks.
- Sprint reports should include: Stories completed, Stories carried over, Bugs opened, Bugs closed, Sprint velocity.

### Cross-Cutting
- For bulk updates (re-tagging, re-parenting, mass state changes), always **confirm scope** with the user before applying.
- When the user mentions a project name but not a connection alias, resolve the connection first.

---

## Team Ownership & Area Paths

| Area Path | Team | Focus |
| --------- | ---- | ----- |
| `Platform\Core` | Core Platform | Architecture, shared services, APIs |
| `Platform\Infrastructure` | Infra & Ops | CI/CD, monitoring, cloud resources |
| `CustomerPortal\UX` | UX & Frontend | UI components, accessibility, design system |
| `CustomerPortal\Backend` | Backend API | REST/GraphQL endpoints, data access |
| `DataInsights\Analytics` | Data & BI | Dashboards, ETL pipelines, reporting |

Use these mappings when the user asks "who owns…" or when creating work items that need an Area Path.

---

## Sprint Naming & Calendar

Sprints follow the pattern `YYYY\Sprint NN` (two-week cadence, Monday start).

| Sprint | Dates | Status |
| ------ | ----- | ------ |
| 2026\Sprint 07 | 2026-03-23 – 2026-04-05 | Completed |
| 2026\Sprint 08 | 2026-04-06 – 2026-04-19 | **Current** |
| 2026\Sprint 09 | 2026-04-20 – 2026-05-03 | Planning |
| 2026\Sprint 10 | 2026-05-04 – 2026-05-17 | Planning |

---

## Organization-Specific Terminology

Only terms that differ from standard Azure DevOps usage are listed here — the AI already
knows generic terms like "work item", "WIQL", "closure", and "connection".

| Term | Our Definition |
| ---- | -------------- |
| Theme | A strategic investment category tag on Epics: `theme:grow`, `theme:run`, `theme:transform` |
| Portfolio Backlog | The ranked list of Epics managed by the Portfolio Office (not a team backlog) |
| Business Value | A 1–100 score set by Product Management reflecting strategic alignment and customer impact |
| DoD | Our Definition of Done — acceptance criteria that must pass before any work item is closed |
| Squad | A cross-functional delivery team (4–8 people) aligned to one Area Path |
