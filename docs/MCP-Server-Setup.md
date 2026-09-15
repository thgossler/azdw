# MCP Server Setup Guide

This guide explains how to configure `azdw` as a local Model Context Protocol (MCP) server in VS Code and Claude Desktop, with automatic Two-Phase Approval for safe operation.

## Why Use the MCP Server?

The MCP server provides advantages over the built-in `azdw ai-chat` command:

- **IDE Integration**: Work with Azure DevOps directly from VS Code, Cursor, or Claude Desktop
- **Context Awareness**: AI can access both your code context and Azure DevOps work items simultaneously
- **Prompt Templates**: Leverage your client's agent modes, skills, and custom prompts
- **Multi-tool Orchestration**: Combine azdw tools with file operations, search, and other MCPs
- **Persistent Sessions**: Maintain conversation context across IDE sessions
- **Approval UI**: Use your client's native confirmation dialogs for destructive operations

For a detailed comparison, see [MCP Server vs Built-in AI Chat](AI-Features-Overview.md#mcp-server-vs-built-in-ai-chat).

## Quick Start with `azdw mcp init`

The fastest way to configure any MCP client is to use the built-in configuration generator:

```bash
# See the configuration for your client
azdw mcp init <client-name>

# Examples:
azdw mcp init github-copilot-vscode
azdw mcp init claude-desktop
azdw mcp init cursor

# List all supported clients
azdw mcp init --list

# Automatically apply the configuration (creates backup first)
azdw mcp init github-copilot-vscode --apply
```

The `init` command outputs the exact JSON configuration snippet for your client, including the config file path. With `--apply`, it automatically creates or updates the config file.

## Overview

The `azdw` tool can run as an MCP server, allowing AI assistants like GitHub Copilot and Claude to interact with Azure DevOps work items through a standardized protocol.

## Approval Modes

The MCP server supports two approval modes for destructive operations:

### Client-Side Approvals (Recommended)

Use `azdw mcp --client-approvals` when your MCP client has native approval UI:

- **Pros**: Best user experience, native confirmation dialogs, no manual approval tokens
- **Cons**: Requires client support for tool confirmations
- **Best for**: VS Code with GitHub Copilot, modern MCP clients with built-in approval UI

### Server-Side Two-Phase Approvals

Use `azdw mcp` (without `--client-approvals`) for traditional token-based approvals:

- **Pros**: Works with any MCP client, explicit approval control, audit trail
- **Cons**: Requires calling `approve_operation`/`reject_operation` tools manually
- **Best for**: Clients without native approval UI, strict audit requirements

For detailed information on server-side approvals, see:
- [MCP Approval Mechanisms](./MCP-Approval-Mechanisms.md)
- [Two-Phase MCP Approval System](./Two-Phase-MCP-Approval-System.md)
- [Two-Phase MCP Approval Example](./Two-Phase-MCP-Approval-Example.md)

## Prerequisites

- `azdw` CLI tool installed and available in your PATH
- Valid Azure DevOps connection configured (see main README.md)
- VS Code with GitHub Copilot
- **GitHub account and a paid GitHub Copilot subscription**

## Setup for VS Code with GitHub Copilot

### 1. Open MCP Configuration

Use the VS Code Command Palette to open the MCP configuration:

1. Open the Command Palette (`Cmd+Shift+P` on macOS, `Ctrl+Shift+P` on Windows/Linux)
2. Type and select: **`MCP: Open User Configuration`**

This opens the MCP settings file for editing.

> **Note**: Alternatively, you can manually locate the file at:
> - **macOS**: `~/Library/Application Support/Code/User/mcp.json`
> - **Windows**: `%APPDATA%\Code\User\mcp.json`
> - **Linux**: `~/.config/Code/User/mcp.json`

### 2. Configure MCP Server

Add the following configuration to the `mcp.json` file:

**Option 1: Client-Side Approvals (Recommended for VS Code)**

When your MCP client (VS Code, Claude Desktop) has its own approval UI, use this configuration:

```json
{
  "servers": {
    "azdw": {
      "command": "azdw",
      "args": ["mcp", "--client-approvals"]
    }
  }
}
```

> **Note**: VS Code uses `"servers"` as the root key (not `"mcpServers"` like Claude Desktop and other clients).

The `--client-approvals` flag (or `-c`) disables server-side approval mechanisms and lets VS Code handle tool execution approvals through its native UI. This provides the best user experience with VS Code's built-in confirmation dialogs.

**Option 2: Server-Side Two-Phase Approvals**

For clients without built-in approval UI or when you prefer explicit approval tokens:

```json
{
  "servers": {
    "azdw": {
      "command": "azdw",
      "args": ["mcp"]
    }
  }
}
```

Without `--client-approvals`, the server uses a two-phase approval workflow where you must explicitly call `approve_operation` or `reject_operation` tools with the provided approval tokens. See [Two-Phase MCP Approval System](./Two-Phase-MCP-Approval-System.md) for details.

Then click on 'Start' for the newly configured MCP server or follow the steps as described in [Verify Configuration](#3-verify-configuration).

> **Note**: The MCP server automatically:
> - Uses the same connection configuration as the CLI tool (stored in `~/.azdw/connections.json`)
> - If you've already set up your connection using `azdw connection add`, no additional configuration is needed
> - With `--client-approvals`, VS Code prompts for confirmation on destructive operations
> - Without `--client-approvals`, you must use approval tools for High and Critical risk operations

### 3. Verify Configuration

1. Restart VS Code
2. Open the Command Palette (`Cmd+Shift+P` on macOS, `Ctrl+Shift+P` on Windows/Linux)
3. Run: `Developer: Reload Window`
4. Check the Output panel (View → Output) and select "GitHub Copilot Chat" from the dropdown
5. Look for messages indicating the MCP server started successfully

### 4. Test the Connection

In GitHub Copilot Chat, try:

```
List 5 work items.
```

The AI should use the `azdw` MCP server to query Azure DevOps across all configured connections.

## Setup for Claude Desktop

### 1. Locate Claude Configuration File

The Claude Desktop configuration file location:

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

### 2. Configure MCP Server

Create or edit the `claude_desktop_config.json` file:

**Option 1: Client-Side Approvals (If Claude supports native confirmations)**

```json
{
  "mcpServers": {
    "azdw": {
      "command": "azdw",
      "args": ["mcp", "--client-approvals"]
    }
  }
}
```

**Option 2: Server-Side Two-Phase Approvals (Default)**

```json
{
  "mcpServers": {
    "azdw": {
      "command": "azdw",
      "args": ["mcp"]
    }
  }
}
```

> **Choosing the Right Option**:
> - Use `--client-approvals` if Claude Desktop has native tool confirmation dialogs
> - Use default (no flag) for the traditional two-phase approval workflow with explicit approval tokens
> - See [Two-Phase MCP Approval System](./Two-Phase-MCP-Approval-System.md) for details on server-side approvals

Then click on 'Start' for the newly configured MCP server or follow the steps as described in [Restart Claude Desktop](#3-restart-claude-desktop).

> **Note**: The MCP server automatically:
> - Uses the same connection configuration as the CLI tool (stored in `~/.azdw/connections.json`)
> - If you've already set up your connection using `azdw connection add`, no additional configuration is needed

### 3. Restart Claude Desktop

Close and reopen the Claude Desktop application completely for the changes to take effect.

### 4. Verify the Connection

In the Claude Desktop interface:

1. Look for an MCP indicator (usually shows connected servers)
2. Try asking: "Can you list the work items assigned to me in Azure DevOps?"

Claude should use the MCP server to query your work items.

## Installing Agent Skills

After configuring the MCP server, you can optionally install the bundled agent
skill to give your AI assistant detailed knowledge of all `azdw` capabilities:

```bash
azdw config ai skills install
```

This copies structured instructions (MCP tool catalog, CLI reference, WIQL
syntax, examples) to your workspace where the AI assistant can discover them
automatically. For GitHub Copilot CLI, also run
`copilot plugin install ./.github/plugins/manage-workitems`
to activate the plugin. For details, see
[Agent Skills & Plugins for AI Assistants](AI-Features-Overview.md#agent-skills--plugins-for-ai-assistants).

External coding agents own their own workspace discovery. When `azdw` is used
as an MCP server, the client discovers `.github`, `.claude`, and `.agents`
assets through its own harness, while `azdw mcp` exposes operational Azure
DevOps tools only. azdw's internal skill activation tools are reserved for
azdw-owned AI sessions such as `azdw ai-chat`. See
[Workspace Context and AI Discovery](Workspace-Context-and-AI-Discovery.md)
for the full distinction.

### MCP Tools in Custom Agents and Subagents

Installing the skill/plugin helps the model understand when and how to use
`azdw`, but it does **not** by itself guarantee that custom agents or
subagents can call the `azdw` MCP tools. Tool availability is controlled by
the MCP client and by each agent's `tools` allowlist.

Important rules:

- The `azdw` MCP server must be configured and running in the client first.
- If a custom agent, prompt file, or agent profile defines a `tools:` list,
  that list becomes an allowlist. In that case, add `azdw/*` or the specific
  `azdw/<tool-name>` entries you want the agent to use.
- In VS Code, a prompt file `tools:` list overrides the custom agent's
  `tools:` list. If the prompt file restricts tools, repeat `azdw/*` there as
  well.
- If a coordinating agent should delegate work, include `agent` (or
  `runSubagent`) in its `tools:` list.
- If a worker/custom subagent should call `azdw` directly, that subagent also
  needs `azdw/*` in its own `tools:` list.
- Do not rely on implicit MCP tool inheritance across products and versions.
  VS Code, GitHub Copilot CLI, and Claude-style agents do not all behave the
  same way. The safest pattern is to explicitly allow `azdw/*` everywhere you
  expect direct MCP tool usage.

For VS Code Copilot custom agents, this is the important part many people
miss:

```md
---
name: Azure DevOps Implementer
description: Works on code and Azure DevOps work items together
tools: ['agent', 'read', 'search', 'edit', 'azdw/*']
agents: ['Work Item Researcher']
---

Use `azdw` MCP tools whenever Azure DevOps data is needed.
```

Example worker agent used as a subagent:

```md
---
name: Work Item Researcher
user-invocable: false
tools: ['read', 'search', 'azdw/*']
---

Use `azdw` MCP tools to gather Azure DevOps context and return only the
relevant findings.
```

The same principle applies to GitHub Copilot CLI and Claude-style custom
agents: if you restrict `tools:`, explicitly include `azdw/*` for direct MCP
access. Otherwise the skill may be present, but the agent still cannot call
the `azdw` tools.

## Configuration Options

### Basic Configuration

The minimal configuration shown above is all you need. The MCP server:
- **Always uses Two-Phase Approval** for High and Critical risk operations (built-in, cannot be disabled)
- **Automatically loads connections** from `~/.azdw/connections.json`
- **No command-line options required** - just `azdw mcp`

### Advanced Configuration

> **Note**: The `azdw mcp` command has no command-line options. All configuration is done through the CLI connection management (`azdw connection add/update`).

If you need to use a different connection configuration location, you can set environment variables:

```json
{
  "mcpServers": {
    "azdw": {
      "command": "azdw",
      "args": ["mcp"],
      "env": {
        "HOME": "/custom/home/directory"
      }
    }
  }
}
```

This changes where `~/.azdw/connections.json` is located. However, this is rarely needed.

## AI Approach Configuration

The MCP server supports two AI approaches for handling AI-powered operations. This affects how AI features like natural language queries and AI chat work within the MCP server context.

### DirectModelConfig (Default)

The default approach uses your configured AI provider (OpenAI, Azure OpenAI, or Ollama) for AI operations:

```bash
# Configure an AI provider first
azdw config ai set --provider openai --model gpt-5.6-luna --api-key <key>

# Or use local Ollama
azdw config ai set --provider ollama --model gemma4:12b
```

The MCP server automatically uses this configuration for AI features.

### GitHubCopilotSdk

> ⚠️ **Corporate Policy Note**: Some corporate environments may restrict or block
> sign-in via GitHub Copilot CLI and, thus, GitHub Copilot
> SDK approach. If you cannot authenticate, use the
> **DirectModelConfig** approach (OpenAI, Azure OpenAI, or Ollama) instead.

If you have a working GitHub Copilot subscription, you can use the Copilot SDK for AI operations:

```bash
# Switch to GitHub Copilot SDK approach
azdw config ai set --approach github-copilot-sdk

# Verify authentication
github-copilot-cli auth status
```

**Benefits:**
- **Unified billing** - Uses existing GitHub Copilot subscription
- **IDE integration** - Seamless when using GitHub Copilot in VS Code
- **Enterprise features** - Access to enterprise policies

**Requirements:**
- GitHub Copilot subscription (Individual, Business, or Enterprise)
- Authenticated GitHub Copilot CLI (run `copilot login` or `copilot login --host https://example.ghe.com`)
- MCP extensions enabled in GitHub Copilot settings

### Checking Current Configuration

```bash
# View current AI configuration
azdw config ai show

# Test AI connectivity
azdw config ai test
```

## Connection Setup

### Using the CLI Connection

The MCP server automatically uses the same connection configuration as the CLI tool, stored in `~/.azdw/connections.json`.

**If you haven't set up a connection yet:**

```bash
# Add a connection interactively
azdw connection add

# Or add a connection with all parameters
azdw connection add --name MyOrg --url https://dev.azure.com/myorg --project MyProject --pat YOUR_PAT
```

**Managing connections:**

```bash
# List all configured connections
azdw connection list

# Test your connection
azdw connection test

# Update an existing connection
azdw connection update --name MyOrg

# Remove a connection
azdw connection remove --name MyOrg
```

Once you've added at least one connection using the CLI, the MCP server will automatically use it—no additional configuration needed!

### Multiple Organizations

If you have multiple Azure DevOps organizations configured:

```bash
# Add multiple connections
azdw connection add --name OrgA --url https://dev.azure.com/orga --project ProjectA --pat PAT_A
azdw connection add --name OrgB --url https://dev.azure.com/orgb --project ProjectB --pat PAT_B

# Set the default connection
azdw connection set-default --name OrgA
```

The MCP server will:
- Use the default connection for single-organization queries
- Support querying across all configured connections when appropriate
- Respect the Two-Phase Approval for all write operations regardless of organization

## Security Considerations

### Two-Phase Approval Benefits

The MCP server **always uses Two-Phase Approval** for High and Critical risk operations:

1. **Read operations** execute immediately (safe queries, no approval needed)
2. **Medium risk operations** execute immediately (e.g., create/update work items)
3. **High/Critical risk operations** require explicit approval:
   - Delete work items
   - Remove connections
   - Delete templates
   - Other destructive operations

### Best Practices

1. **Always enable Two-Phase Approval** for MCP servers, be careful what you approve persistently!
2. **Review approval prompts carefully** before confirming
3. **Manage connections via the CLI** which handles secure credential storage
4. **Limit PAT permissions** to only required scopes:
   - `vso.work` (read)
   - `vso.work_write` (write, if needed)
5. **Rotate PATs regularly** per your organization's security policy
6. **Use separate connections** for different environments (dev, prod, etc.)

### Approval Configuration

**Two-Phase Approval is always enabled** and cannot be disabled via command-line options. This is by design for security. The approval settings are:

- **Medium Risk** (e.g., create/update work items): No approval required
- **High Risk** (e.g., delete work items): Approval required
- **Critical Risk** (e.g., remove connections): Approval required

If you need different approval settings, you would need to modify the source code in `McpCommand.cs`.

## Troubleshooting

### Server Won't Start

**Check the logs:**

VS Code:
1. View → Output
2. Select "GitHub Copilot Chat" from dropdown
3. Look for error messages

Claude Desktop:
1. Check the developer console (if available)
2. Look for connection errors

**Common issues:**

1. **`azdw` command not found**
   - Ensure `azdw` is in your PATH
   - Use absolute path: `"command": "/full/path/to/azdw"`

2. **No connections configured**
   - Run `azdw connection add` to set up a connection
   - Verify with `azdw connection list`
   - Test the connection: `azdw connection test`

3. **Authentication failures**
   - Verify your PAT is valid and not expired
   - Check PAT permissions include required scopes
   - Test connection: `azdw connection test`

### No MCP Tools Available

If the AI doesn't recognize Azure DevOps commands:

1. **Verify server is running** in the output logs
2. **Restart the IDE/application** completely
3. **Check MCP protocol version** compatibility
4. **Review server logs** for initialization errors

### Approval Prompts Not Appearing

If High/Critical risk operations execute without approval:

1. Verify the operation is actually High or Critical risk (see [MCP Approval Mechanisms](./MCP-Approval-Mechanisms.md))
2. Check if the approval token is being returned in the response
3. Ensure your MCP client supports the Two-Phase Approval pattern
4. Restart the MCP server and check logs in VS Code Output panel
5. Review the [Two-Phase MCP Approval System](./Two-Phase-MCP-Approval-System.md) documentation

### Testing Server Manually

The MCP server uses stdio transport (stdin/stdout) for communication, not HTTP. To test:

```bash
# Start server manually (writes logs to stderr)
azdw mcp

# The server will wait for JSON-RPC messages on stdin
# Press Ctrl+C to stop
```

> **Note**: The MCP server communicates via JSON-RPC over stdio, so there's no HTTP endpoint to test with curl.

## Advanced Usage

### Multiple MCP Server Instances

You can run multiple instances for different environments by using different HOME directories:

> **Note on Root Keys**: Use `"servers"` for VS Code GitHub Copilot, and `"mcpServers"` for Claude Desktop and most other MCP clients.

```json
{
  "mcpServers": {
    "azdw-production": {
      "command": "azdw",
      "args": ["mcp"],
      "env": {
        "HOME": "/path/to/prod/home"
      }
    },
    "azdw-development": {
      "command": "azdw",
      "args": ["mcp"],
      "env": {
        "HOME": "/path/to/dev/home"
      }
    }
  }
}
```

### Viewing Logs

The MCP server writes all logs to stderr (not stdout, which is used for JSON-RPC communication).

**In VS Code:**
1. Open View → Output
2. Select "GitHub Copilot Chat" from the dropdown
3. Look for `azdw` MCP server logs

**In Claude Desktop:**
- Check the application console/logs (location varies by platform)

**Manual testing:**
```bash
# Logs go to stderr, so you can redirect them
azdw mcp 2> azdw-mcp.log
```

> **Note**: The `azdw mcp` command has no `--log-level` or `--log-file` options. Logging is always enabled to stderr.

## Related Documentation

- [Two-Phase MCP Approval System](./Two-Phase-MCP-Approval-System.md) - Detailed approval mechanism
- [MCP Approval Mechanisms](./MCP-Approval-Mechanisms.md) - Technical implementation details
- [MCP Tool Differentiation](./MCP-Tool-Differentiation.md) - Understanding tool classifications
- [Authentication Types](./Authentication-Types.md) - Connection authentication options
- [Token Expiration Guide](./Token-Expiration-Guide.md) - Managing authentication tokens
- [Security Implementation](./Security-Implementation.md) - Security best practices

## AI Chat Command

In addition to running as an MCP server for external AI assistants, `azdw` includes a built-in interactive AI chat command that provides the same Azure DevOps tools directly in your terminal.

### Using AI Chat

```bash
# Start interactive AI chat
azdw ai-chat

# Using short alias
azdw chat

# With transcript recording
azdw ai-chat --record
```

### Configuration

Before using `ai-chat`, configure your AI provider:

```bash
# Configure OpenAI
azdw config ai set --provider openai --model gpt-5.6-luna

# Configure Azure OpenAI
azdw config ai set --provider azureopenai --endpoint https://my-resource.openai.azure.com --deployment my-gpt-5-6-luna --model gpt-5.6-luna

# Configure Ollama (local, no API key needed) - Recommended for local hosting
# Use a model with native tool calling and >= 16K context window
azdw config ai set --provider ollama --model gemma4:12b

# Test the configuration
azdw config ai test
```

### External MCP Server Integration (Preview)

The `ai-chat` command can also connect to external MCP servers for additional tool capabilities. Create an `mcp.jsonc` file in your config directory:

> **Authentication:** Remote MCP servers that require OAuth authentication work out-of-the-box via MCP OAuth 2.1 auto-discovery. For Entra ID setup (granting the vendor's app access or registering your own), see [MCP OAuth — Entra ID App Registration Setup](MCP-OAuth-Entra-ID-Setup.md).
>
> **Corporate proxy note:** Some packet-inspecting corporate proxies (for example ZScaler) can break the browser-based OAuth 2.1 flow used by remote MCP servers. A VS Code-specific bearer-token workaround is documented in [MCP OAuth — Entra ID App Registration Setup](MCP-OAuth-Entra-ID-Setup.md#corporate-proxy-packet-inspection-workaround-vs-code-mcp-clients).

**Config file locations:**
- **Local (per-installation)**: `<exe>/config/mcp.jsonc`
- **User (fallback)**: `~/.azdw/config/mcp.jsonc`

**Example mcp.jsonc:**
```json
{
  "mcpServers": {
    "tavily-search": {
      "command": "npx",
      "args": ["-y", "@anthropics/mcp-tavily"],
      "env": {
        "TAVILY_API_KEY": "your-api-key-here"
      },
      "approve": ["tavily_search"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropics/mcp-filesystem", "/path/to/allowed/dir"]
    }
  }
}
```

**Schema:** See `config/mcp-config-schema.json` for the full schema.

**Fields:**
- `command`: The executable to run
- `args`: Command-line arguments
- `env`: Environment variables for the process
- `approve`: List of tool names to auto-approve (no confirmation prompt)

## Getting Help

If you encounter issues:

1. Review this documentation and related guides
2. Check the [GitHub Issues](https://github.com/thgossler/azdw/issues)
3. Enable debug logging and examine the output
4. Test the connection directly with `azdw connection test`
5. Verify your Azure DevOps permissions match requirements

## Summary

With the MCP server configured (just `azdw mcp`), you can safely interact with Azure DevOps through AI assistants. Two-Phase Approval is always enabled by default, ensuring you maintain full control over High and Critical risk operations (like deletions) while allowing safe queries and standard work item operations to proceed automatically.
