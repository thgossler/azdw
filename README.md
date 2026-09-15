# azdw

Generic documentation, configuration examples, demo output, and integration
samples for **azdw**, a CLI tool, MCP server, .NET library, and REST API service for
unified access to Azure DevOps and GitHub work items. It can be directly used
out-of-the-box with the provided tools, or integrated into custom tools.

## Cross-tenant work-item and portfolio intelligence for Azure DevOps and GitHub

Work is scattered across organizations, projects, repositories, and Entra ID
tenants. azdw brings it together in one queryable model, resolves the
relationships between items, and gives teams a reproducible path from raw
backlog data to portfolio insight. It is built for cross-tenant queries without
requiring a separate reporting warehouse for every organization.

[Visit the official azdw website](https://apps.thomas-gossler.de/azdw/) for the
product tour, screenshots, current availability, evaluation details, pricing,
and contact options.

> Connect. Resolve. Insight.

## Why azdw

azdw is designed for enterprise R&D, portfolio management, platform teams,
consultants, and distributed teams that need visibility across system
boundaries without building a separate reporting warehouse for every
organization.

- **Cross-tenant queries across every boundary**: Combine Azure DevOps Services, Azure
	DevOps Server/TFS, GitHub.com, and GitHub Enterprise Server across multiple
	organizations and tenants.
- **Relationships that survive the boundary**: Resolve hierarchy,
	dependencies, hyperlinks, and cross-organization references into a queryable
	closure and graph.
- **Deterministic by default**: Collect and shape work-item data without AI.
	Queries are repeatable, scriptable, auditable, and available as tables, JSON,
	CSV, Markdown, or HTML.
- **Optional AI**: Use configured hosted providers, GitHub Copilot,
	Azure or OpenAI-compatible endpoints, Anthropic, or local models through
	Ollama. Keep the deterministic data layer independent of the model.
- **Governed changes**: Mutating operations can use client-side confirmations
	or explicit two-phase approvals before anything is written upstream.
- **Built for automation**: Use the same data and rules from the CLI, Web UI,
	MCP, REST/GraphQL, PowerShell, or the .NET library.

## What you can do

### Query the whole portfolio

Filter by work-item type, state, tags, fields, project, or WIQL and combine
results from several connections in one result set. Every result can retain its
connection and project context, making cross-organization reporting practical
instead of a spreadsheet merge exercise.

```bash
azdw query \
	--connections ADO,GitHub \
	--columns Connection,Project,Id,Type,Title,State \
	--output table
```

For pipelines and scheduled jobs, use machine-readable output and stable exit
codes:

```bash
azdw query --connections ADO,GitHub --limit 100 --json \
	| jq '.[] | select(.State == "Active")'
```

### Resolve traceability and dependencies

Turn a work item into a cross-connection relationship closure, then inspect it
as a table or graph. This is useful for release readiness, dependency reviews,
impact analysis, audit evidence, and portfolio consolidation.

```bash
azdw relationship find-closure --ids 9 --top-type Epic
azdw visualize graph --ids 9 --format graphml --output closure.graphml
```

### Generate reports that can be rerun

Render work-item data into self-contained HTML dashboards, Markdown reports,
release notes, CSV exports, GraphViz diagrams, Mermaid diagrams, D3-compatible
JSON, or GraphML for tools such as yEd, Gephi, and Cytoscape. Templates and
parameters keep recurring reports versionable and schedulable.

```bash
azdw report generate \
	--template-id team-dashboard-interactive-html \
	--connections ADO \
	--relationships \
	--output dashboard.html
```

### Find duplicates before consolidation

The read-only reconciliation workflow identifies duplicate and related
candidates, consolidation proposals, missing relationship proposals, and
evidence-backed clusters across Azure DevOps and GitHub. Review the generated
HTML offline before deciding whether any upstream change is appropriate.

### Use AI on your terms

AI is optional. Use the deterministic CLI and reports with no model at all, or
add plain-language queries, closure narratives, terminal chat, Web UI chat, and
agent workflows when they are useful. Local model and agent endpoints allow
regulated or sensitive work-item data to remain inside your infrastructure.

```bash
azdw ai-chat --webui
azdw query --ai "Show high-risk active items without a release assignment"
```

## Use it where your team works

| Interface | Best for |
| --- | --- |
| CLI | Interactive investigation, CI jobs, scheduled reports, and shell pipelines |
| Web UI | Leaders and teams who want a zero-setup browser conversation |
| MCP server | VS Code Copilot, Claude Code, Claude Desktop, and other agent clients |
| REST and GraphQL | Applications, integrations, and service-to-service workflows |
| .NET library | Embedding provider-neutral work-item access in .NET applications |
| PowerShell | Windows automation and operational reporting |

Configure an MCP client with the built-in generator:

```bash
azdw mcp init github-copilot-vscode --apply
azdw mcp --client-approvals
```

Client-side confirmations or server-side two-phase approvals keep destructive
operations visible to the operator and the agent.

## Quick start

The normal path is install, connect, authenticate, query:

```bash
# Verify the installation
azdw --info

# Add a provider connection
azdw connection add \
	--name ADO \
	--url https://dev.azure.com/your-organization

# Choose PAT, device-code OAuth, or browser authentication
azdw credential add \
	--connection ADO \
	--auth-type interactive \
	--tenant your-tenant-id-or-name

# Run a first query
azdw query --connections ADO --types Epic --limit 5 --output table
```

See [Getting Started](docs/Getting-Started.md) for installation and
authentication details, or [CLI Use Cases](docs/CLI-Use-Cases.md) for a wider
set of commands.

## Platform and security posture

- .NET 10 LTS and a single-binary deployment model
- Linux, Windows, and macOS on x64 and ARM64
- PAT, OAuth 2.0 device code, and browser sign-in options
- Local encrypted credential storage under `~/.azdw/`
- Explicit connection and tool scoping for CLI, MCP, and AI workflows
- Optional local AI through Ollama or another OpenAI-compatible endpoint
- No work-item content required for deterministic, non-AI queries

Read [SECURITY.md](SECURITY.md) before connecting azdw to production systems,
exposing the REST or MCP services, or enabling AI features.

## Explore this repository

This repository is a public-facing companion containing selected generic
documentation, configuration examples, demo output, and integration samples.
It does not contain the private application source repository or client-specific
overlays.

- [Documentation index](docs/index.md)
- [Configuration examples](config/README.md)
- [.NET library sample](samples/azdw-lib/Program.cs)
- [REST API sample](samples/rest-api/index.html)
- [AcmeFlow cross-provider demo](demo-output/index.html)
- [Dependency SBOM](SBOM.json)
- [Security guidance](SECURITY.md)

The [SPDX 2.3 SBOM](SBOM.json) is a point-in-time dependency-graph export for
the source snapshot used to produce these materials.

## Documentation map

- [Getting Started](docs/Getting-Started.md)
- [Authentication Types](docs/Authentication-Types.md)
- [Filtering and query results](docs/Filtering-QueryResults.md)
- [Relationships and closure](docs/Relationship-Commands.md)
- [Reports and automation](docs/Output-Rendering-Automation.md)
- [AI features](docs/AI-Features-Overview.md)
- [MCP server setup](docs/MCP-Server-Setup.md)
- [API documentation](docs/API-Documentation.md)
- [Plugin development](docs/Plugin-Development-Guide.md)

For the product story, visual tour, licensing, and current release information,
see the [official azdw website](https://apps.thomas-gossler.de/azdw/).

## Documentation

The documentation is available in [`docs/`](docs/index.md) and is suitable for
publishing with GitHub Pages.

## Samples

- [`samples/azdw-lib/Program.cs`](samples/azdw-lib/Program.cs) is a .NET 10
	file-based C# sample that uses `azdw.lib` types. It references the adjacent
	source checkout for local validation because the package is not currently
	available from the configured NuGet feed.
- [`samples/rest-api/index.html`](samples/rest-api/index.html) is a
	self-contained browser sample for the local REST service.

## Demo Data

[`demo-output/`](demo-output/) contains fresh output generated only from the
fictitious AcmeFlow demo connections. It contains no client-specific data.

## Security

Read [`SECURITY.md`](SECURITY.md) before connecting azdw to real work-item
systems or exposing its REST/MCP services.

## Dependency SBOM

[`SBOM.json`](SBOM.json) is the SPDX 2.3 dependency-graph export captured for
the source snapshot used to produce these materials.
