# Mission & Vision — Example Configuration
#
# PURPOSE:
#   This example file documents how to create a custom mission-vision.md for your
#   organization. Copy this file to ~/.azdw/config/mission-vision.md and replace
#   the placeholder content with your organization's actual mission and context.
#
# HOW IT WORKS:
#   - If ~/.azdw/config/mission-vision.md exists and is non-empty, it overrides
#     the default file shipped with azdw.
#   - If the file is empty, it acts as an opt-out (no content is injected).
#   - The content is included automatically in all AI-powered interactions
#     (ai chat, ai query, MCP server) to provide organizational context.
#
# QUICKSTART:
#   1. Copy: cp <azdw-install>/config/mission-vision-example.md ~/.azdw/config/mission-vision.md
#   2. Edit: $EDITOR ~/.azdw/config/mission-vision.md
#   3. Verify: azdw config paths
#
# SIZE GUIDANCE:
#   - Aim for 200–500 words for best results
#   - Files larger than ~32 KB trigger a warning log (content still loads)
#   - Focus on strategic context, not implementation details
#
# ─────────────────────────────────────────────────────────────────────────────

# Organizational Context - Mission & Vision

## Our Mission

[Replace with your organization's mission statement — one or two sentences that
describe what you do and who you do it for.]

Example:
> We deliver innovative software solutions that improve user outcomes through
> AI-assisted functionality and streamlined workflows.

## Our Vision

[Replace with your long-term aspiration — where you want to be in 3–5 years.]

Example:
> To become the most trusted partner for clients worldwide, enabling valuable
> outcomes through intelligent, cloud-native software.

## Strategic Priorities

[List 3–6 key organizational priorities that should guide work item
prioritization. These help the AI understand what "important" means in your
context.]

- [Priority 1, e.g., User safety and regulatory compliance (GDPR, ISO27001,
  SOC2, C5)]
- [Priority 2, e.g., Cloud-native platform migration to Azure]
- [Priority 3, e.g., Cross-client collaboration and knowledge sharing]
- [Priority 4, e.g., AI-assisted business workflow integration]

## Domain Context

[Describe your domain vocabulary and how your Azure DevOps hierarchy maps to
your organization's concepts. This helps the AI correctly interpret work item
types, states, and relationships.]

Example:
> Our Azure DevOps backlogs track software development under IEC 62304 lifecycle
> processes. Epics represent regulatory submissions, Features represent
> capabilities, and User Stories or Product Backlog Items represent workflow
> steps. The "QR" area path prefix indicates quarterly release scopes requiring
> traceability documentation.

## Work Item Conventions

[Optional: Describe naming conventions, tagging standards, or field usage
patterns specific to your organization.]

Example:
> - Tags: Use "security", "compliance", "performance", "debt" for cross-cutting
>   concerns
> - Priority 1 = Must ship this quarter (release-gating); Priority 2 = Target
>   this half-year
> - "Blocked" state means waiting on an external dependency (vendor, API, spec)
> - Items with "regulatory" tag require sign-off from the compliance team
