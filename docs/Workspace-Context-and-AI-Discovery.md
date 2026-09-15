---
title: Workspace Context and AI Discovery
nav_order: 200
---

# Workspace Context and AI Discovery

`azdw` uses a workspace context to decide where project-specific AI assets live and where workspace-scoped file operations should happen. In most interactive usage, the workspace is the current working directory. For `azdw ai-chat`, `--workspace-root <DIR>` can set it explicitly when the current directory is not the project you want to work in.

The workspace concept lets each repository carry its own AI instructions and local automation without changing global user settings or the bundled defaults that ship with `azdw`.

## Why It Matters

Workspace-scoped discovery provides three practical benefits:

1. Project context stays with the repository. Team instructions, prompt files, skills, and MCP server choices can be versioned with the project.
2. User-level configuration remains reusable. Personal prompts and skills under the home directory can apply across many workspaces.
3. Bundled defaults remain stable. Files under the `azdw` install directory are examples and fallback defaults, not the place for personal edits.

Changing the workspace can change which AI assets are discovered. For automation, start `azdw` from the intended repository root or pass `azdw ai-chat --workspace-root <DIR>` where supported.

## Discovery Tiers

Most AI assets use this precedence model:

1. Workspace/project assets under `<workspace>/.agents/`, `<workspace>/.github/`, or `<workspace>/.claude/`
2. User/shared assets under `~/.azdw/` or `~/.agents/`
3. Bundled defaults under `<azdw-install>/config/`

When two assets of the same type use the same name, the first one found wins. For example, a workspace prompt can shadow a user prompt with the same slash command name.

## Asset Locations

### Skills

Skills are discovered in this order:

1. `<workspace>/.agents/skills/`
2. `<workspace>/.github/skills/`
3. `<workspace>/.claude/skills/`
4. `~/.azdw/config/ai/skills/`
5. `~/.azdw/skills/`
6. `~/.agents/skills/`
7. `<azdw-install>/config/ai/skills/`

Each skill lives in a directory containing `SKILL.md`.

### Prompt Files

Prompt files are discovered in this order:

1. `<workspace>/.agents/prompts/`
2. `<workspace>/.github/prompts/`
3. `<workspace>/.claude/prompts/`
4. `~/.azdw/config/ai/prompts/`
5. `<azdw-install>/config/ai/prompts/`

Prompt files are Markdown files with prompt frontmatter. Files using the `.prompt.md` suffix are recommended.

### MCP Configuration

External MCP server configuration is discovered in this order:

1. `<workspace>/.agents/mcp.jsonc`
2. `<workspace>/.agents/mcp.json`
3. `<workspace>/.github/mcp.jsonc`
4. `<workspace>/.github/mcp.json`
5. `<workspace>/.claude/mcp.jsonc`
6. `<workspace>/.claude/mcp.json`
7. `~/.azdw/config/mcp.jsonc`
8. `~/.azdw/config/mcp.json`
9. `<azdw-install>/config/mcp.jsonc`
10. `<azdw-install>/config/mcp.json`

Only one MCP configuration file is loaded. Files are not merged. If you need both user-level and workspace-level MCP servers, put the complete desired set in the higher-precedence file.

### AGENTS.md

`AGENTS.md` is a single workspace context file, not a catalog. `azdw` looks from the current workspace/current directory upward until a project boundary such as `.sln` or `.git` is reached. If found, it injects the content into azdw-owned AI sessions.

The bundled `config/ai/AGENTS-example.md` is only an example. Install or copy it into your workspace when you want project-specific instructions.

## External MCP Clients

When `azdw` is used as an MCP server inside an external coding agent, such as GitHub Copilot Chat or Claude Code, the external host owns its own workspace discovery. Those clients discover their own `.github`, `.claude`, and `.agents` files using their own harness.

For that reason, the external `azdw mcp` server exposes operational Azure DevOps tools only. It does not expose azdw's internal skill activation tools, such as `azdw_ActivateSkill`, because that would let the host model load the same skill content twice.

Use project-level agents for external coding agents according to that host's conventions. Use azdw workspace discovery for skills, prompts, MCP configuration, and `AGENTS.md` in `azdw ai-chat`, the embedded Web UI, and other azdw-owned AI sessions.

## Related Documentation

- [AI Features Overview](AI-Features-Overview.md)
- [Prompt Files and Slash Commands](Prompt-Files.md)
- [Configuration Discovery](Configuration-Discovery.md)
- [MCP Server Setup Guide](MCP-Server-Setup.md)
