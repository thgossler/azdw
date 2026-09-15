# AI Features Overview

This document provides a comprehensive overview of all AI-powered functionality available in the `azdw` CLI tool.

> **Alternative Usage**: Besides using AI directly via the CLI commands described here, all `azdw` functionality can be used in other MCP-compatible AI clients (GitHub Copilot, Claude Desktop, Cursor, etc.) through the built-in MCP server mode. See the [MCP Server Integration](#mcp-server-integration) section and [MCP Server Setup Guide](MCP-Server-Setup.md) for details.

## Table of Contents

- [Quick Start](#quick-start)
- [AI Configuration](#ai-configuration)
- [Workspace Context and AI Discovery](#workspace-context-and-ai-discovery)
- [Natural Language Queries](#natural-language-queries)
- [Interactive AI Chat](#interactive-ai-chat)
- [MCP Server Integration](#mcp-server-integration)
- [Agent Skills & Plugins for AI Assistants](#agent-skills--plugins-for-ai-assistants)
  - [What Is an Agent Skill?](#what-is-an-agent-skill)
  - [Why Agent Skills Matter](#why-agent-skills-matter)
  - [How the Discovery Mechanism Works](#how-the-discovery-mechanism-works)
  - [Skill Activation at Runtime](#skill-activation-at-runtime)
  - [Managing Agent Skills](#managing-agent-skills)
- [AGENTS.md — Workspace Context for AI Agents](#agentsmd--workspace-context-for-ai-agents)
- [AI-Powered Report Templates](#ai-powered-report-templates)
- [Supported AI Providers](#supported-ai-providers)

---

## Quick Start

1. **Configure an AI provider** (e.g., GitHub Copilot, or Ollama with ≥24 GB VRAM):
   ```bash
  azdw config ai set --approach github-copilot --model gpt-5.6-luna
   # --- or, if you have ≥24 GB GPU VRAM ---
  azdw config ai set --approach ollama --model gemma4:12b
   ```

2. **Test the configuration**:
   ```bash
   azdw config ai test
   ```

3. **Start using AI features**:
   ```bash
   # Natural language query
   azdw query --ai "show me all open bugs from last week"
   
   # Interactive chat
   azdw ai-chat
   ```

---

## AI Configuration

Manage AI provider settings with the `config ai` command group.

### Commands

| Command | Description |
| ------- | ----------- |
| `azdw config ai set` | Configure AI provider settings (provider, model, API key, endpoint) |
| `azdw config ai show` | Display current AI provider configuration |
| `azdw config ai clear` | Remove AI provider configuration and stored credentials |
| `azdw config ai test` | Test AI provider connectivity and model response |

### Configuration Examples

```bash
# GitHub Copilot (uses your subscription)
azdw config ai set --approach github-copilot --model gpt-5.6-luna

# Anthropic (direct)
azdw config ai set --approach anthropic --model claude-sonnet-5 --api-key <key>

# Anthropic via Azure Foundry
azdw config ai set --approach anthropic --provider microsoft-foundry \
  --model claude-sonnet-5 \
  --endpoint https://your-resource.services.ai.azure.com/anthropic/ \
  --api-key <key>

# Anthropic via AWS Bedrock
azdw config ai set --approach anthropic --provider aws-bedrock \
  --model anthropic.claude-sonnet-5 \
  --aws-region us-east-1

# OpenAI (direct)
azdw config ai set --approach openai --model gpt-5.6-luna --api-key <key>

# Azure OpenAI
azdw config ai set --approach openai --provider microsoft-foundry \
  --model gpt-5.6-luna \
  --endpoint https://your-resource.openai.azure.com \
  --deployment your-deployment-name \
  --api-key <key>

# Ollama (local — recommended for privacy)
azdw config ai set --approach ollama --model gemma4:12b
```

### View Current Configuration

```bash
azdw config ai show
azdw config ai show --json  # Machine-readable output
```

---

## Workspace Context and AI Discovery

`azdw` treats the current working directory, or the explicit `azdw ai-chat --workspace-root <DIR>` value where supported, as the workspace for azdw-owned AI sessions. Workspace assets take precedence over user-level assets, which take precedence over bundled install defaults.

Workspace discovery applies to skills, prompt files, MCP configuration, and `AGENTS.md` context. See [Workspace Context and AI Discovery](Workspace-Context-and-AI-Discovery.md) for the full path order and the implications for file input/output.

When `azdw` is used as an MCP server by an external coding agent such as GitHub Copilot Chat or Claude Code, that external host owns its own `.github`, `.claude`, and `.agents` discovery. The external `azdw mcp` server exposes operational Azure DevOps tools only and does not expose azdw's internal skill activation tools.

---

## AI Approaches

azdw supports four different approaches for AI-powered features. Choose the one that best fits your environment and licensing situation.

### Approach Comparison

| Feature | `github-copilot` | `anthropic` | `openai` | `ollama` |
| -------- | ---------------- | ----------- | -------- | ------- |
| **Setup** | GitHub Copilot subscription | Anthropic API key (or Azure/AWS) | OpenAI API key (or Azure/HTTP) | Local Ollama install |
| **Privacy** | GitHub-managed | Provider-managed (local with Bedrock) | Provider-managed | Fully local |
| **Cost** | Included in Copilot subscription | Pay-per-use | Pay-per-use | Free |
| **Providers** | Local (Copilot) | anthropic, microsoft-foundry, aws-bedrock | openai, microsoft-foundry, http | default |

### github-copilot

Uses your existing GitHub Copilot subscription.

```bash
azdw config ai set --approach github-copilot --model gpt-5.6-luna
```

> **Bundled Copilot CLI (default).** `azdw` ships its own GitHub Copilot CLI, pinned to the exact
> version its embedded SDK was built against, and uses it **exclusively** by default. You do **not**
> need to install `@github/copilot` globally, and any existing global install is left untouched and
> unused. This guarantees a compatible SDK ↔ CLI pair and avoids version-drift errors.
>
> To make `azdw` prefer a globally-installed copilot CLI instead (at your own risk regarding version
> compatibility), set the environment variable `AZDW_USE_GLOBAL_COPILOT=true` (accepted truthy
> values: `true` or `1`, case-insensitive). When this variable is set, `init` also installs and
> manages the global CLI via npm; when it is unset, `init` skips all global-CLI management.
>
> **Embedding `azdw.lib` in your own program?** If you build on top of the library and use the
> GitHub Copilot approach, you must add a direct `GitHub.Copilot.SDK` reference to **your**
> executable project and publish **platform-specific** (with a RID) so the Copilot CLI is bundled
> for the target platform. The library itself does not bundle it. See
> [azdw.lib README → GitHub Copilot AI Integration](../src/azdw.lib/README.md#github-copilot-ai-integration)
> for details, including the `AZDW_USE_GLOBAL_COPILOT` fallback (not recommended).

### anthropic

Uses Anthropic Claude models. Supports three providers:

```bash
# Direct Anthropic API
azdw config ai set --approach anthropic --model claude-sonnet-5 --api-key <key>

# Azure AI Foundry
azdw config ai set --approach anthropic --provider microsoft-foundry \
  --model claude-sonnet-5 \
  --endpoint https://your-resource.services.ai.azure.com/anthropic/ \
  --api-key <key>

# AWS Bedrock
azdw config ai set --approach anthropic --provider aws-bedrock \
  --model anthropic.claude-sonnet-5 \
  --aws-region us-east-1
```

### openai

Uses OpenAI-compatible APIs. Supports three providers:

```bash
# OpenAI direct
azdw config ai set --approach openai --model gpt-5.6-luna --api-key <key>

# Azure OpenAI
azdw config ai set --approach openai --provider microsoft-foundry \
  --model gpt-5.6-luna \
  --endpoint https://your-resource.openai.azure.com \
  --deployment your-deployment-name \
  --api-key <key>

# HTTP-compatible endpoint
azdw config ai set --approach openai --provider http \
  --model gpt-5.6-luna \
  --endpoint https://your-custom-api/v1 \
  --api-key <key>
```

### ollama

Runs models locally using Ollama. No API key required.

```bash
azdw config ai set --approach ollama --model gemma4:12b
```

**Requirements:**
- GitHub Copilot subscription (Individual, Business, or Enterprise)
- GitHub Copilot CLI installed and authenticated

**Installation:**

```bash
# All platforms (recommended) — requires Node.js >= 22
npm install -g @github/copilot
```

Install Node.js from https://nodejs.org if needed (v22 LTS or later).

**Authentication (Interactive):**

```bash
# Authenticate with GitHub (opens a browser for GitHub OAuth)
copilot login

# Authenticate with GitHub Enterprise (opens a browser for GitHub Enterprise OAuth)
copilot login --host https://example.ghe.com

# Verify by running a test
azdw config ai test
```

**Authentication (Headless/Server):**

For MCP servers, API services, or CI/CD pipelines where browser-based login isn't possible:

1. **Option A: Create a Personal Access Token (PAT)** (recommended):
   - Go to [GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens](https://github.com/settings/personal-access-tokens/new)
   - Create a new token with:
     - **Resource owner**: Your account or organization
     - **Expiration**: Set as needed
     - **Repository access**: No repositories needed
     - **Permissions**: None needed (Copilot access is automatic with subscription)
   - Set the token as an environment variable:
   ```bash
   export COPILOT_GITHUB_TOKEN="github_pat_..."
   # Or alternatively:
   export GITHUB_TOKEN="github_pat_..."
   ```

2. **Option B: Use GitHub CLI token** (if you already have [GitHub CLI](https://cli.github.com/) installed):
   ```bash
   # Get your GitHub token from gh CLI (requires gh to be installed and authenticated)
   export GH_TOKEN=$(gh auth token)
   ```
   > Note: `gh` (GitHub CLI) is a separate tool from `copilot` (GitHub Copilot CLI). Install it from https://cli.github.com/ if needed.

3. **Option C: Extract token from interactive login**:
   ```bash
   # After running 'copilot login', the token is cached at:
   # ~/.copilot/hosts.json (Linux/macOS)
   # %USERPROFILE%\.copilot\hosts.json (Windows)
   ```

**Configuration:**

```bash
# Switch to GitHub Copilot approach
azdw config ai set --approach github-copilot

# Select a model (optional, defaults to gpt-5.6-luna)
azdw config ai set --approach github-copilot --model gpt-5.6-luna

# Test the configuration
azdw config ai test
```

**Available Models:**
- Claude: `claude-sonnet-5`, `claude-opus-5`, `claude-haiku-4.5`
- GPT: `gpt-5.6-luna`, `gpt-5.6-terra`, `gpt-5.6-sol`, `gpt-6-astra`, `gpt-5-mini`
- Gemini: `gemini-3.8-flash`

**Benefits:**
- **Unified billing** - Uses your existing GitHub Copilot subscription
- **IDE integration** - Seamless experience when using GitHub Copilot in VS Code
- **Enterprise features** - Access to enterprise policies and content exclusions

**Switching Approaches:**

```bash
# Switch to GitHub Copilot
azdw config ai set --approach github-copilot

# Switch to Anthropic
azdw config ai set --approach anthropic --model claude-sonnet-5 --api-key <key>

# Switch to OpenAI
azdw config ai set --approach openai --model gpt-5.6-luna --api-key <key>

# Switch to local Ollama
azdw config ai set --approach ollama --model gemma4:12b
```

---

## Natural Language Queries

Transform natural language into WIQL (Work Item Query Language) queries using the `--ai` option.

### Commands Supporting `--ai`

| Command | Description |
| ------- | ----------- |
| `azdw query --ai "<text>"` | Query work items using natural language |
| `azdw visualize graph --ai "<text>"` | Generate visualizations from natural language queries |

### Usage

```bash
# Basic query
azdw query --ai "all bugs assigned to me"

# With confirmation skip
azdw query --ai "high priority features from project Alpha" --yes

# Query specific connections
azdw query --ai "open tasks" --connections myorg,devteam

# Visualization from natural language
azdw visualize graph --ai "all epics and their child features" --format mermaid-flowchart
```

### How It Works

1. Your natural language query is sent to the configured AI model
2. The AI translates it into a valid WIQL query
3. The generated WIQL is shown for confirmation (unless `--yes` is specified)
4. The query is executed against Azure DevOps
5. Results are displayed in the requested format

### Supported Query Types

The AI understands a wide range of natural language patterns:

- **Work item types**: "bugs", "features", "tasks", "user stories", "epics"
- **States**: "open", "active", "closed", "resolved", "removed"
- **Assignments**: "assigned to me", "unassigned", "assigned to John"
- **Time filters**: "last week", "this month", "created after January 1st"
- **Tags**: "tagged with security", "with tag 'high-priority'"
- **Connections**: "from myorg", "in devteam connection"
- **Sorting**: "sorted by priority", "ordered by created date descending"
- **Hierarchies**: "epics and their child features"

---

## Interactive AI Chat

An interactive chat interface for managing Azure DevOps work items through conversation.

Prompt-based slash commands are also supported. Client packages can ship reusable
`.prompt.md` templates under `config/ai/prompts/`, and users can override or add
their own prompts under `~/.azdw/config/ai/prompts/`. For the file format,
placeholders, and customization workflow, see [Prompt Files and Slash Commands](Prompt-Files.md).

### Command

```bash
azdw ai-chat
```

**Aliases**: `azdw chat`

### Options

| Option | Description |
| ------ | ----------- |
| `--record` | Record chat transcript to `~/.azdw/chats/` directory |
| `--show-thoughts` | Show LLM reasoning while processing |
| `--skip-model-checks` | Skip LLM capability verification at startup |
| `--persist` | Persist session state to disk. Mutually exclusive with `--temporary-chat`. |
| `--exit-chat` | Process one input and exit (for automation). Combine with `--temporary-chat` for an ephemeral single-turn run. |
| `--temporary-chat` | Start an ephemeral session: no history persistence. Mutually exclusive with `--persist`. |
| `--continue-last-session` | Continue from the most recently active session |
| `--continue-session <NAME>` | Continue a specific named session (see `azdw ai-chat session list`). Cannot be combined with `--continue-last-session`. |

By default, interactive and automation-mode chats persist their session state under
`~/.azdw/sessions/`. Use `--temporary-chat` when a run must not create or update
persistent chat history. `--record` is separate: it writes a transcript under
`~/.azdw/chats/` and does not select which session is resumed.

### Example Session

```
🤖 Azure DevOps AI Assistant

You: Show me all open bugs assigned to me
AI: I found 5 open bugs assigned to you:
    1. Bug #1234 - Login page not responding
    2. Bug #1235 - API timeout on large requests
    ...

You: Update bug 1234 priority to Critical
AI: ✅ Updated Bug #1234:
    - Priority: 2 → 1 (Critical)

You: exit
```

### Available Tools

The AI assistant has access to all MCP tools including:

- **query_work_items** - Query work items with flexible filters
- **get_work_item** - Get details for a specific work item
- **create_work_item** - Create a new work item
- **update_work_item** - Update an existing work item
- **list_connections** - List configured connections
- **get_metadata** - Retrieve work item types, fields, and states

### Automation Mode

For scripting and automation:

```bash
# Single query mode (saves session state so it can be resumed)
echo "List all bugs" | azdw ai-chat --exit-chat

# Single query mode, ephemeral (no session state persisted)
echo "List all bugs" | azdw ai-chat --temporary-chat --exit-chat

# Continue the most recently active session
azdw ai-chat --continue-last-session
```

---

## Chat Sessions

Every non-ephemeral `ai-chat` run is saved as a **named session** under
`~/.azdw/sessions/`, so you can pause and resume any number of conversations
in parallel — not just the most recent one. There is no limit on how many
sessions can exist.

The session name is the stable identifier used by the management commands and
by `--continue-session`. A session can be open in only one azdw process at a
time. Resuming a session restores its conversation history and last-used model;
if that model is no longer available, azdw falls back to the configured default.

### Naming

Sessions are named `yyyyMMdd-HHmmss-<Description>` (e.g.
`20260805-143000-Session`). New sessions start with the generic description
`Session`; after the first request/response exchange, azdw asks the
**same configured model**, in the background, for a short topic label and
silently renames the session (e.g. `20260805-143000-Deployment-issue`). This
happens once per session and never blocks or interrupts the conversation — if
it fails for any reason, the session simply keeps its default name. In the
TUI and Web UI, only the description part is shown as the title; the
timestamp is shown separately as dimmed metadata.

Each session also remembers the AI model that was last active in it and
reactivates that model (falling back to the default model if it is no longer
available) when the session is resumed.

> **Note on older/dormant sessions**: Auto-titling only fires during a live
> chat turn, right after the first AI response of that run. Sessions that
> pre-date this feature, or that were migrated from the legacy naming scheme
> but never resumed and chatted in again, keep the generic `Session`
> description indefinitely — nothing scans dormant sessions in the
> background. Use `azdw ai-chat session refresh` (below) to retroactively
> generate descriptions for such sessions from their existing content,
> without needing to reopen and chat in each one.

### Managing sessions

```bash
# List all sessions (table or --format json)
azdw ai-chat session list

# Make a selected session the target of --continue-last-session
azdw ai-chat session activate                 # interactive picker
azdw ai-chat session activate -n <NAME>       # non-interactive

# Then resume the activated session
azdw ai-chat --continue-last-session

# Delete sessions
azdw ai-chat session delete                   # interactive multi-select
azdw ai-chat session delete -n <NAME> --yes   # non-interactive, no confirmation
azdw ai-chat session delete --all             # delete everything (asks to confirm unless --yes)

# Retroactively generate AI descriptions for sessions still named "Session"
azdw ai-chat session refresh -n <NAME>        # a single session
azdw ai-chat session refresh --all            # every session still on the default name (asks to confirm unless --yes)
azdw ai-chat session refresh -n <NAME> --force # regenerate even if already custom-named

# Resume a specific session by name
azdw ai-chat --continue-session 20260805-143000-Deployment-issue
```

Use `session activate` when a script or operator workflow should keep using
`--continue-last-session` without embedding a session name. Use
`--continue-session <NAME>` when the exact conversation is known. These options
are mutually exclusive. Listing sessions shows each session's description,
timestamp, message count, model, active marker, and whether another process has
it open.

### In-chat session switching

While inside an interactive chat, press **Tab** (on an empty/plain input line)
or type **`/session`** to open a picker (newest sessions first, scrollable up
to 10 at a time, the currently active session pinned to the top and
pre-selected). Press Enter to switch, or Esc to cancel without changing
anything. Switching sessions prints a prominent colored banner naming the
session you switched to and its active model, so the visible chat history is
never confused with the previous session, and the model shown above the
input prompt updates automatically.

Opening the **same** session from two `azdw` processes at once is prevented:
the second process gets a clear error naming the process that already has it
open, avoiding silent conversation-history loss.

### Compacting context on demand

Type **`/compact`** at any time to immediately run the same context-window
compaction pipeline that automatically prevents overflow during normal chat
(shrinking large tool results, summarizing older exchanges via the LLM, then
trimming if still needed) — useful right before a long, detail-heavy request.

### Web UI

The embedded Web UI (`azdw ai-chat --webui`) shows a **Sessions** sidepanel
(shown automatically once more than one session exists) listing each
session's topic and last-modified date/time, with activate/rename/delete
actions and the active session highlighted. This panel is only available in
local (CLI-embedded) mode — the hosted/cloud Web UI does not support multiple
sessions.

### Session isolation

Sessions are fully isolated from one another: there is currently **no shared
user memory or context carried across sessions**. Each session's history,
model choice, and background auto-title are independent.

---

## MCP Server Integration

The Model Context Protocol (MCP) server enables AI assistants like GitHub Copilot, Cursor, and Claude Desktop to interact with Azure DevOps.

### Starting the MCP Server

```bash
azdw ai-mcp-server
```

### Options

| Option | Description |
| ------ | ----------- |
| `--client-approvals` | Let the MCP client handle tool execution approvals |
| `--work-dir <path>` | Work directory for sandboxed file operations |

### Initialize Client Configuration

Generate configuration snippets for various AI assistants:

```bash
# Interactive menu
azdw ai-mcp-server init

# Specific client
azdw ai-mcp-server init github-copilot-vscode
azdw ai-mcp-server init cursor
azdw ai-mcp-server init claude-desktop

# Auto-apply configuration
azdw ai-mcp-server init github-copilot-vscode --apply

# List supported clients
azdw ai-mcp-server init --list
```

### Supported MCP Clients

- GitHub Copilot (VS Code)
- Cursor
- Claude Desktop
- Windsurf
- LibreChat
- And more...

### MCP Server vs Built-in AI Chat

Both `azdw ai-chat` (built-in) and the MCP server (`azdw mcp`) provide AI-powered work item management, but serve different use cases:

| Feature | Built-in AI Chat | MCP Server |
| -------- | --------------- | ---------- |
| **Invocation** | `azdw ai-chat` | `azdw mcp` (integrated with IDE/client) |
| **IDE Integration** | Terminal only | Full IDE integration (VS Code, Cursor, Claude) |
| **Context Access** | Azure DevOps only | IDE context + Azure DevOps + other MCPs |
| **Prompt Templates** | None | Client-provided (agent modes, skills) |
| **Multi-tool Orchestration** | Limited | Full (combine with file tools, search, etc.) |
| **Session Management** | Single session | Persistent across IDE sessions |
| **Best For** | Quick terminal queries | Deep IDE integration, complex workflows |

**When to Use Built-in AI Chat:**
- Quick one-off queries from the terminal
- Automation scripts that need AI capabilities
- Environments without VS Code or other MCP clients

**When to Use MCP Server:**
- VS Code or Cursor as your primary IDE
- GitHub Copilot or Claude Desktop for AI assistance
- Complex workflows combining Azure DevOps with code context
- Leveraging prompt templates, agent modes, and skills
- Multi-MCP orchestration (combining multiple specialized servers)

---

## Agent Skills & Plugins for AI Assistants

### What Is an Agent Skill?

An **agent skill** is a structured package of Markdown files that teaches an AI
assistant how to use a specific tool, framework, or domain capability. Unlike
traditional documentation (which is written for humans), agent skills are
formatted for machine consumption — optimized token budgets, YAML frontmatter
for metadata, and clear step-by-step instructions that AI models can follow
reliably.

A skill typically contains:

- **SKILL.md** — the entry point: a concise set of instructions covering when to
  use the skill, what commands/tools are available, and how to handle errors.
- **Reference files** — detailed catalogs (API docs, CLI references, query
  syntax) that the AI loads on demand when it needs specifics.
- **Examples** — step-by-step walkthroughs the AI can follow or adapt.
- **Agents / Subagents** — specialized agent definitions that the AI can invoke
  for complex multi-step workflows.

Skills are **language-agnostic** and **tool-agnostic** — they work with any AI
assistant that supports file-based context injection (VS Code Copilot Chat,
GitHub Copilot CLI, Claude Code, Cursor, Windsurf, etc.).

### Why Agent Skills Matter

Without skills, AI assistants only know what's in their training data — which is
often outdated, incomplete, or wrong for specialized tools. Agent skills solve
this by providing:

| Benefit | Without Skills | With Skills |
| ------- | -------------- | ----------- |
| **Accuracy** | AI guesses CLI flags, API parameters | AI follows exact, verified instructions |
| **Coverage** | AI knows only popular commands | AI has the full tool catalog available |
| **Freshness** | AI uses training-cutoff knowledge | AI uses the version you actually have installed |
| **Domain knowledge** | AI lacks org-specific context | Skills can encode WIQL syntax, field mappings, conventions |
| **Consistency** | Different sessions produce different results | Same skill = same behavior across sessions |

### How the Discovery Mechanism Works

When `azdw` starts an azdw-owned AI session (via `azdw ai-chat`, the embedded
Web UI, or the standalone Web UI), the **skill discovery service** automatically
scans a prioritized set of directories for `SKILL.md` files:

```
Scan order (highest → lowest precedence):

1. <workspace>/.agents/skills/        ← Project-level (custom)
2. <workspace>/.github/skills/        ← GitHub Copilot convention
3. <workspace>/.claude/skills/        ← Claude Code convention
4. ~/.azdw/config/ai/skills/          ← User-level overrides
5. ~/.azdw/skills/                    ← User-level (shared)
6. ~/.agents/skills/                  ← User-level (cross-tool)
7. <azdw-install>/config/ai/skills/   ← Bundled defaults
```

Here, `<workspace>` means the workspace root used by the azdw-owned AI session.
For `azdw ai-chat`, this is the current working directory unless `--workspace-root`
or a persisted session root supplies a more specific value.

Each immediate subdirectory of a scan path containing a `SKILL.md` file is
registered as a skill. Skills are identified by their directory name (e.g.,
`manage-workitems`).

**Precedence and shadowing**: If a skill with the same name appears in multiple
scan paths, the **first one found** (highest precedence) wins and the others are
shadowed. This lets you override a bundled skill by placing your customized
version in your workspace or user directory.

**SKILL.md format**: Each `SKILL.md` file uses YAML frontmatter for metadata:

```markdown
---
name: my-custom-skill
description: A one-line summary of what this skill does
---
# My Custom Skill

Instructions for the AI model...
```

The `name` and `description` fields are required. The body contains the actual
skill instructions in Markdown.

### Skill Activation at Runtime

Discovery and activation are separate steps:

1. **Discovery** — At session start, all skills across all scan paths are
   catalogued into a `SkillCatalog`. This is fast (typically < 100 ms for 50+
   skills).
2. **Filtering** — Disabled skills (configured via `azdw config ai skills
   choose`) are removed from the catalog.
3. **Registration** — Each active skill is registered as an MCP tool
   (`activate_skill`) that the AI model can call when relevant. The tool listing
   includes each skill's name and description.
4. **Activation** — When the AI model determines it needs a skill, it calls
   `activate_skill` with the skill name. The full SKILL.md content and reference
   files are then injected into the conversation context.

This lazy activation keeps token usage low — only the skills the AI actually
needs are loaded into context.

### Always-On (Pinned) Skill

azdw's own bundled skill (`manage-workitems`) is **auto-pinned** into every
`azdw ai-chat` session. Unlike ordinary skills, which the AI activates on demand,
the pinned skill's instructions are injected into the system prompt at session
start so azdw usage guidance is available from the first turn without the model
having to discover and activate it.

Two mechanisms make this work:

1. **Bundled discovery** — The bundled plugin skills under
   `<exeDir>/config/ai/plugins/` are added to the discovery scan paths at the
   lowest precedence, so a workspace or user copy of the same skill name shadows
   the bundled one.
2. **External-only content stripping** — Setup/install sections in the bundled
   `SKILL.md` are wrapped in `<!-- azdw:external-only:begin -->` /
   `<!-- azdw:external-only:end -->` markers. These are invisible HTML comments
   for external AI clients (which need the setup steps) but are stripped when
   azdw injects the skill into its own in-process chat, where the `azdw_`-prefixed
   tools already exist.

The pinned skill is marked active on injection, so if the model calls
`activate_skill` for it the call is a deduplicated no-op (its content is never
added twice).

### What's Included

`azdw` ships with a bundled **agent skill** — a set of structured instructions
that teach AI assistants (GitHub Copilot, Claude Code, Cursor, etc.) how to use
`azdw` effectively for Azure DevOps work item management.

> **Note — Two Kinds of Plugins**: The term "plugin" has two distinct meanings
> in this project:
>
> 1. **Code Plugins** — MEF-based .NET assemblies that extend `azdw` at runtime
>    (data transforms, policy enforcement, custom renderers). See the
>    [Plugin Development Guide](Plugin-Development-Guide.md).
> 2. **Agent Plugins / Skills** — Markdown files with instructions and reference
>    material for AI models. This section covers agent plugins.

The bundled agent plugin `manage-workitems` contains:

| Component | Description |
| --------- | ----------- |
| **SKILL.md** | Core instructions: interface selection (MCP vs CLI), setup, querying, creating, updating, visualizing, error handling |
| **MCP-Tools.md** | Complete catalog of all 82 MCP tools with parameters |
| **CLI-Reference.md** | Full CLI command reference |
| **WIQL-Queries.md** | WIQL syntax reference with operators and macros |
| **Visualizing-Results.md** | Visualization formats and options |
| **Create-Report-Template.md** | Guide for creating Scriban report templates |
| **Examples.md** | Step-by-step workflow examples |
| **manage-work-items agent** | Specialized subagent for work item management tasks |

### Managing Agent Skills

#### Installing Skills

Use `azdw config ai skills install` to copy the bundled skill/plugin to your
workspace so your AI assistant can discover it:

```bash
# Install for both GitHub Copilot and Claude Code
azdw config ai skills install

# Install for a specific client only
azdw config ai skills install --client copilot
azdw config ai skills install --client claude

# Overwrite existing files
azdw config ai skills install --force
```

**Where files are placed:**

| Client | Target Location | Format |
| ------ | --------------- | ------ |
| VS Code Copilot Chat | `.github/skills/manage-workitems/` | Skill files only (SKILL.md + references) |
| GitHub Copilot CLI | `.github/plugins/manage-workitems/` | Full plugin (plugin.json + skills/ + agents/) |
| Claude Code | `.github/plugins/manage-workitems/` | Full plugin (plugin.json + skills/ + agents/) |

GitHub Copilot CLI and Claude Code share the same plugin directory
(`.github/plugins/`), since both use the same plugin format.

**GitHub Copilot CLI tip:** After running `azdw config ai skills install`, install
the plugin in Copilot CLI with:

```bash
copilot plugin install ./.github/plugins/manage-workitems
```

After installation, AI assistants automatically discover the skill and can use
it to help with Azure DevOps work item tasks.

#### Listing Installed Skills

Use `azdw config ai skills list` to see all bundled skills and their
installation status in the current workspace:

```bash
# Show all bundled skills
azdw config ai skills list

# Show only installed skills
azdw config ai skills list --installed
```

#### Choosing Which Skills Are Active

Use `azdw config ai skills choose` to enable or disable discovered skills.
Disabled skills are excluded from AI sessions — they won't appear in the skill
catalog and the AI model won't be able to activate them.

```bash
# Interactive multi-select (toggle with Space, confirm with Enter)
azdw config ai skills choose

# Enable all discovered skills
azdw config ai skills choose --all

# Disable all discovered skills
azdw config ai skills choose --none
```

Skill preferences are persisted to `~/.azdw/config/skill-filter.json` and
applied automatically in subsequent AI sessions.

### Skill Commands Summary

| Command | Description |
| ------- | ----------- |
| `azdw config ai skills install` | Install bundled skills to workspace for AI discovery |
| `azdw config ai skills list` | List bundled skills and installation status |
| `azdw config ai skills choose` | Enable/disable discovered skills interactively or via `--all` / `--none` |

### Limitations and Unsupported Skill Features

The azdw skill discovery and activation system implements the core agent skill
workflow (discover → filter → register → activate → read resources → execute
scripts) but does not cover every feature found in external AI skill platforms.
The following capabilities are **not currently supported**:

| Feature | Status | Notes |
| ------- | ------ | ----- |
| **Subagents / nested agents** | Not supported | Skill YAML frontmatter does not define subagent declarations. Subagents (e.g., the `manage-work-items` agent) are defined externally by the AI client via `.agent.md` files, not inside the azdw skill activation system. |
| **`applyTo` file-pattern matching** | Not supported | Skills cannot be auto-activated based on file patterns (e.g., `*.cs`, `*.yaml`). Activation is always explicit — either the AI model calls `activate_skill` or the user invokes `/skill:<name>`. |
| **Skill-level tool restrictions** | Parsed, not enforced | The `allowedTools` frontmatter field is read and stored but not enforced at runtime. All MCP tools remain available regardless of what a skill declares. |
| **Skill dependencies / composition** | Not supported | Skills cannot declare dependencies on other skills. Each skill is activated independently. |
| **Skill versioning** | Not supported | There is no version field or compatibility checking. Shadowing (by name) is the only override mechanism. |
| **Remote skill registries** | Not supported | Skills must be present on the local filesystem. There is no mechanism to fetch skills from a URL or package registry at runtime. |
| **Skill-provided custom MCP tools** | Not supported | Skills cannot register additional MCP tools. They can only provide instructions and reference files that teach the AI how to use existing tools. |
| **Hooks (pre/post execution)** | Installed, not executed by azdw | The `install` command copies hook files (`.github/hooks/`, `.claude/hooks/`) to the workspace, but azdw does not execute them. Hook execution is delegated to the AI client (GitHub Copilot, Claude Code) if the client supports hooks. |
| **Binary/compiled skill plugins** | Not supported | Skills are Markdown-only. There is no mechanism to load compiled code (DLLs, scripts with dependencies) as part of skill activation. For compiled extensibility, use azdw's MEF-based code plugin system instead. |

---

## AGENTS.md — Workspace Context for AI Agents

`azdw` automatically discovers and injects an `AGENTS.md` file from your workspace into every AI chat session. This is a standard convention (alongside `CLAUDE.md`, `copilot-instructions.md`, `GEMINI.md`) for providing project-specific context to AI agents.

For the broader workspace discovery model, including prompts, skills, and MCP configuration, see [Workspace Context and AI Discovery](Workspace-Context-and-AI-Discovery.md).

### What AGENTS.md does

When you start an `azdw ai-chat` session, connect via MCP, or use the Web UI, `azdw` looks for `AGENTS.md` in your current working directory and walks up toward the project root (`.sln` or `.git` boundary). If found, its content is appended to the system message under a `## Workspace Context (AGENTS.md)` heading.

This means you can teach AI agents about:
- Your project's tech stack, coding conventions, and naming patterns
- Domain terminology and Azure DevOps field reference names specific to your organization
- Which connections to prefer, which work item types are relevant, and how to interpret results
- AI agent behavior: tone, output format, approval thresholds, tool preferences

### File placement

| Location | When used |
| -------- | --------- |
| `<workspace>/AGENTS.md` | Recommended — discovered automatically from CWD or any parent directory up to `.sln`/`.git` root |
| `config/ai/AGENTS-example.md` (shipped) | Bundled example; installed or copied to `<workspace>/AGENTS.md` when you want starter workspace context |

### Content format

Plain Markdown (UTF-8). Keep it concise — the file is injected into every AI turn's system message. A focused 1–5 KB file is more effective than a 50 KB dump.

> **Size warning**: Files exceeding 50 KB trigger a warning and the content is truncated before injection.
> **Encoding**: Must be valid UTF-8. Files with a UTF-16 BOM or invalid byte sequences are skipped with a warning.

### Discovery order

1. CWD (`AGENTS.md` or `agents.md`, case-sensitive on Linux, case-insensitive on macOS/Windows)
2. Walk up parent directories, stopping at the first directory containing a `.sln` or `.git` marker
3. Returns `None` (no injection) if no file is found

### Installing the bundled example

```bash
# Install to workspace root (interactive conflict resolution)
azdw config ai skills install

# Force append — if AGENTS.md already exists, new content is appended
azdw config ai skills install --force
```

When a conflict is detected (AGENTS.md already exists), the interactive mode offers three options:
- **Skip** — leave your existing file untouched
- **Overwrite** — replace with the bundled version
- **Append** (default) — append the bundled content under an `## azdw Workspace Context` heading

### Ecosystem compatibility

`AGENTS.md` follows the same convention used by:
- Anthropic Claude (`CLAUDE.md`)
- OpenAI Codex (`codex.md`)
- Google Gemini (`GEMINI.md`)
- GitHub Copilot (`.github/copilot-instructions.md`)

A single `AGENTS.md` is recognized by `azdw` and also by AI coding tools that follow the AGENTS.md convention, providing consistent context across your entire AI toolchain.

---

## AI-Powered Report Templates

Generate custom report templates using AI from natural language descriptions.

### Commands

| Command | Description |
| ------- | ----------- |
| `azdw report template ai-prompt` | Generate an AI prompt for creating templates |
| `azdw report template ai-generate` | Generate a template from natural language |

### Generate a Template

```bash
azdw report template ai-generate \
  --template-id sprint-summary \
  --name "Sprint Summary Report" \
  --goal "Create a markdown report showing completed work items grouped by type with story points totals" \
  --output-format markdown
```

### Options for `ai-generate`

| Option | Description |
| ------ | ----------- |
| `--template-id` | Template ID (lowercase with hyphens) |
| `--name` | Display name for the template |
| `--goal` | Natural language description of the report |
| `--output-format` | Output format: markdown, html, csv, json, text |
| `--category` | Category for organization |
| `--tags` | Comma-separated tags |
| `--preview` | Preview without importing |
| `--overwrite` | Overwrite existing template |
| `--timeout` | AI request timeout in seconds |

### Generate AI Prompt

Get a comprehensive prompt for external AI tools:

```bash
azdw report template ai-prompt "I need a release notes template"
```

---

## Supported AI Approaches & Providers

### github-copilot

- **Models**: gpt-5.6-luna, gpt-5.6-terra, gpt-6-astra, claude-sonnet-5, claude-haiku-4.5, and more
- **Requirements**: GitHub Copilot subscription

```bash
azdw config ai set --approach github-copilot --model gpt-5.6-luna
```

### anthropic

Supports three providers: `anthropic` (direct), `microsoft-foundry` (Azure), `aws-bedrock`.

- **Models**: claude-sonnet-5, claude-opus-5, claude-haiku-4-5

```bash
# Direct Anthropic API
azdw config ai set --approach anthropic --model claude-sonnet-5 --api-key sk-ant-...

# Azure AI Foundry
azdw config ai set --approach anthropic --provider microsoft-foundry \
  --model claude-sonnet-5 \
  --endpoint https://your-resource.services.ai.azure.com/anthropic/ \
  --api-key <key>

# AWS Bedrock (uses AWS environment credentials — no API key needed)
azdw config ai set --approach anthropic --provider aws-bedrock \
  --model anthropic.claude-sonnet-5 \
  --aws-region us-east-1
```

### openai

Supports three providers: `openai` (direct), `microsoft-foundry` (Azure), `http` (compatible).

- **Models**: gpt-5.6-luna, gpt-5.6-terra, gpt-5.6-sol, gpt-6-astra, gpt-5.5, gpt-5.4, gpt-5-mini, and more

```bash
# Direct OpenAI
azdw config ai set --approach openai --model gpt-5.6-luna --api-key sk-...

# Azure OpenAI
azdw config ai set --approach openai --provider microsoft-foundry \
  --model gpt-5.6-luna \
  --endpoint https://your-resource.openai.azure.com \
  --deployment your-deployment \
  --api-key <key>

# HTTP-compatible endpoint
azdw config ai set --approach openai --provider http \
  --model gpt-5.6-luna \
  --endpoint https://your-custom-api/v1 \
  --api-key <key>
```

### ollama (Local LLM)

Recommended for privacy-sensitive environments **when you have ≥24 GB of GPU VRAM**.

> **⚠️ VRAM requirement**: Local models require ≥24 GB of inference memory (GPU VRAM or Apple Silicon Unified Memory).
> Models smaller than `gemma4:12b` (e.g., `gemma4:e4b`, `gemma4:e2b`) do not have sufficient capacity for reliable
> tool calling, multi-step reasoning, and structured output that azdw depends on.
> If your system has less than 24 GB, use **GitHub Copilot** or a **cloud-hosted provider** instead.

- **Requirements**: Ollama installed locally, ≥24 GB GPU VRAM (or Apple Silicon with ≥24 GB Unified Memory)
- **Example Models**: gemma4:12b (24–48 GB), gemma4:26b (>48 GB)
- **Installer**: `./scripts/install-ollama.ps1` auto-selects the largest suitable Gemma 4 model (or exits with guidance if VRAM < 24 GB)

```bash
# Install Ollama and pull a model (requires ≥24 GB VRAM)
ollama pull gemma4:12b

# Configure azdw
azdw config ai set --approach ollama --model gemma4:12b
```

For systems with less than 24 GB VRAM, use GitHub Copilot or a cloud provider:

```bash
# GitHub Copilot (free with a GitHub Copilot subscription)
azdw config ai set --approach github-copilot --model gpt-5.6-luna

# Anthropic (pay-per-use)
azdw config ai set --approach anthropic --model claude-sonnet-5 --api-key <key>

# Azure OpenAI (pay-per-use)
azdw config ai set --approach openai --provider microsoft-foundry --model gpt-5.6-luna --endpoint <url> --api-key <key>
```

### Model Requirements

For best results, use models with:
- **Native tool calling support** (function calling)
- **Context window ≥ 16K tokens**
- **Instruction-following capabilities**

### GitHub Copilot

- **Requirements**: GitHub Copilot subscription
- **Use Case**: Leverage existing GitHub Copilot subscription for AI operations

```bash
# Switch to GitHub Copilot SDK approach
azdw config ai set --approach github-copilot-sdk

# Verify authentication
github-copilot-cli auth status
```

---

## Related Documentation

- [MCP Server Setup Guide](MCP-Server-Setup.md) - Configure `azdw` as MCP server for AI assistants
- [Plugin Development Guide](Plugin-Development-Guide.md) - Creating code plugins (data transforms, policy, renderers)
- [CLI Help Overview](CLI-Help-Overview.md) - Complete CLI command reference
- [Configuration Discovery](Configuration-Discovery.md) - Configuration file locations
