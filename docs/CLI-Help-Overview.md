# CLI Help Overview

This document contains a comprehensive overview of all CLI commands and their help pages.

## Table of Contents

- [azdw](#main-help)
- [connection](#connection)
  - [connection list](#connection---list)
  - [connection add](#connection---add)
  - [connection edit](#connection---edit)
  - [connection delete](#connection---delete)
  - [connection clear](#connection---clear)
  - [connection test](#connection---test)
  - [connection refresh](#connection---refresh)
  - [connection export](#connection---export)
  - [connection import](#connection---import)
  - [connection choose](#connection---choose)
- [wiql](#wiql)
- [workitem](#workitem)
  - [workitem get](#workitem---get)
  - [workitem create](#workitem---create)
  - [workitem update](#workitem---update)
  - [workitem delete](#workitem---delete)
  - [workitem open-url](#workitem---open-url)
- [credential](#credential)
  - [credential add](#credential---add)
  - [credential add-pat](#credential---add-pat)
  - [credential add-code](#credential---add-code)
  - [credential add-interactive](#credential---add-interactive)
  - [credential list](#credential---list)
  - [credential remove](#credential---remove)
  - [credential validate](#credential---validate)
  - [credential signout](#credential---signout)
  - [credential clear](#credential---clear)
  - [credential repair](#credential---repair)
- [config](#config)
  - [config fieldmap](#config---fieldmap)
    - [config fieldmap list](#config---fieldmap---list)
    - [config fieldmap show](#config---fieldmap---show)
    - [config fieldmap detect](#config---fieldmap---detect)
    - [config fieldmap generate](#config---fieldmap---generate)
    - [config fieldmap validate](#config---fieldmap---validate)
    - [config fieldmap import](#config---fieldmap---import)
    - [config fieldmap export](#config---fieldmap---export)
  - [config urlmap](#config---urlmap)
    - [config urlmap list](#config---urlmap---list)
    - [config urlmap add](#config---urlmap---add)
    - [config urlmap remove](#config---urlmap---remove)
    - [config urlmap clear](#config---urlmap---clear)
    - [config urlmap enable](#config---urlmap---enable)
  - [config paths](#config---paths)
  - [config shell-integration](#config---shell-integration)
  - [config ai](#config---ai)
    - [config ai set](#config---ai---set)
    - [config ai show](#config---ai---show)
    - [config ai clear](#config---ai---clear)
    - [config ai approval](#config---ai---approval)
    - [config ai skills](#config---ai---skills)
      - [config ai skills install](#config---ai---skills---install)
      - [config ai skills list](#config---ai---skills---list)
      - [config ai skills choose](#config---ai---skills---choose)
    - [config ai ghc-login-state](#config---ai---ghc-login-state)
    - [config ai logout](#config---ai---logout)
    - [config ai test](#config---ai---test)
  - [config user](#config---user)
    - [config user show](#config---user---show)
    - [config user set](#config---user---set)
    - [config user detect](#config---user---detect)
    - [config user clear](#config---user---clear)
- [report](#report)
  - [report generate](#report---generate)
  - [report template](#report---template)
    - [report template list](#report---template---list)
    - [report template info](#report---template---info)
    - [report template validate](#report---template---validate)
    - [report template create](#report---template---create)
    - [report template export](#report---template---export)
    - [report template import](#report---template---import)
    - [report template remove](#report---template---remove)
    - [report template ai-prompt](#report---template---ai-prompt)
    - [report template ai-generate](#report---template---ai-generate)
- [visualize](#visualize)
  - [visualize graph](#visualize---graph)
- [query](#query)
- [reconcile](#reconcile)
- [relationship](#relationship)
  - [relationship resolve](#relationship---resolve)
  - [relationship validate](#relationship---validate)
  - [relationship analyze](#relationship---analyze)
  - [relationship find-orphans](#relationship---find-orphans)
  - [relationship find-circular](#relationship---find-circular)
  - [relationship find-closure](#relationship---find-closure)
- [metadata](#metadata)
  - [metadata types](#metadata---types)
  - [metadata fields](#metadata---fields)
  - [metadata states](#metadata---states)
  - [metadata areas](#metadata---areas)
  - [metadata iterations](#metadata---iterations)
- [capacity](#capacity)
  - [capacity analyze](#capacity---analyze)
- [cache](#cache)
  - [cache status](#cache---status)
  - [cache stats](#cache---stats)
  - [cache clear](#cache---clear)
  - [cache refresh](#cache---refresh)
- [release-notes](#release-notes)
- [docs](#docs)
- [ai-mcp-server](#ai-mcp-server)
  - [ai-mcp-server init](#ai-mcp-server---init)
  - [ai-mcp-server tools](#ai-mcp-server---tools)
    - [ai-mcp-server tools list](#ai-mcp-server---tools---list)
    - [ai-mcp-server tools choose](#ai-mcp-server---tools---choose)
    - [ai-mcp-server tools reset](#ai-mcp-server---tools---reset)
- [ai-chat](#ai-chat)
  - [ai-chat session](#ai-chat---session)
    - [ai-chat session list](#ai-chat---session---list)
    - [ai-chat session activate](#ai-chat---session---activate)
    - [ai-chat session delete](#ai-chat---session---delete)
    - [ai-chat session refresh](#ai-chat---session---refresh)
- [update](#update)

## Main Help

```
azdw --help
```

```
Description:
  Cross-platform tool for unified access to Azure DevOps work items across multiple connections. Requires specific Azure DevOps permissions.

Usage:
  azdw [command] [options]

Options:
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --info                      Display build and version information
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --license                   Display the full license text
  --show-command-history      Show interactive command history selection
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime
  -?, -h, --help              Show help and usage information
  --version                   Show version information

Commands:
  connection          Manage Azure DevOps connections
  wiql <QUERY>        Execute WIQL (Work Item Query Language) queries across connections
  workitem            Create, update, and delete work items
  credential          Manage authentication credentials for connections
  config              Manage configuration (field mappings, URL mappings, paths, shell integration, AI)
  report              Generate reports and visualizations from work item data
  visualize           Generate visualizations of work item relationships
  query               Query work items Azure DevOps connections.
  reconcile           Analyze duplicate candidates and missing relationships without changing work items.
  relationship        Manage work item relationships across connections
  metadata            Display work item metadata (types, fields, states)
  capacity            Analyse demand-vs-supply load across portfolio dimensions
  cache               Manage cache operations
  release-notes       Display the embedded release notes in Markdown format
  docs                Open the README and docs in the mdv Markdown viewer
  ai-mcp-server, mcp  Start MCP (Model Context Protocol) server for AI assistant integration
  ai-chat, chat       Interactive AI-powered chat for Azure DevOps work item management.
  update              Check for and apply available product updates

```

## Connection

```
azdw connection --help
```

```
Description:
  Manage Azure DevOps connections

Usage:
  azdw connection [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  list, ls                   List all configured connections
  add                        Add a new connection
  edit, update               Update an existing connection's settings (name, URL, authentication, ...)
  delete, remove, rm <NAME>  Remove a connection
  clear                      Remove all configured connections
  test                       Test connectivity to connection(s)
  refresh                    Re-authenticate connections with missing, expired, or invalid credentials
  export                     Export connections to a JSON file
  import <FILEPATH>          Import connections from a JSON file
  choose, state              Enable or disable connections from automatic operations

```

## Connection - List

```
azdw connection list --help
```

```
Description:
  List all configured connections

Usage:
  azdw connection list [options]

Options:
  --format <FORMAT>           Output format (table, json, yaml) [default: table]
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Connection - Add

```
azdw connection add --help
```

```
Description:
  Add a new connection

Usage:
  azdw connection add [options]

Options:
  -n, --name <NAME>           Friendly name for the connection. If omitted in an interactive terminal, you will be prompted.
  -u, --url <URL>             Azure DevOps organization/collection or project URL (e.g., https://dev.azure.com/myorg[/project] or https://myserver.com/tfs/mycollection[/project]) or GitHub org URL (https://github.com/<org>). If omitted in an interactive terminal, you will be prompted.
  --auth-type <TYPE>          Authentication type (pat, code, interactive) [default: pat]
  --tenant <TENANT>           Entra ID tenant ID or name (required for device code flow and interactive authentication)
  --dry-run, --what-if        Show what would be done without actually performing the operation
  -f, --force                 Overwrite an existing connection with the same name
  --repos <REPO>              GitHub only: optional allow-list of repositories (owner/repo or bare repo) to narrow an org-scoped connection
  --project-status <PROJECT>  GitHub only: optional GitHub Projects (v2) reference (number or name) to enable Status-based state mapping
  --no-credential-prompt      Skip the interactive prompt to configure a Personal Access Token right after adding (for automation/installers that set credentials separately, e.g. via 'connection refresh')
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Connection - Edit

```
azdw connection edit --help
```

```
Description:
  Update an existing connection's settings (name, URL, authentication, ...)

Usage:
  azdw connection update [options]

Options:
  -n, --name <NAME>           Name of the connection to update. If omitted in an interactive terminal, you will be prompted to choose one.
  --new-name <NAME>           New friendly name for the connection (renames it). Stored credentials are migrated automatically.
  -u, --url <URL>             New Azure DevOps organization/collection or project URL, or GitHub org/repo URL.
  --auth-type <TYPE>          New authentication type (pat, code, interactive)
  --tenant <TENANT>           New Entra ID tenant ID or name (required for device code flow and interactive authentication)
  --repos <REPO>              GitHub only: replace the allow-list of repositories (owner/repo or bare repo) for an org-scoped connection
  --project-status <PROJECT>  GitHub only: GitHub Projects (v2) reference (number or name) to enable Status-based state mapping
  --dry-run, --what-if        Show what would be done without actually performing the operation
  -f, --force                 When renaming to a name used by another connection, overwrite (remove) that other connection
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Connection - Delete

```
azdw connection delete --help
```

```
Description:
  Remove a connection

Usage:
  azdw connection remove [<NAME>] [options]

Arguments:
  <NAME>  Name of the connection to remove. If omitted in an interactive terminal, you will be presented with a multi-select list.

Options:
  -y, --yes                   Skip confirmation prompts
  --dry-run, --what-if        Show what would be done without actually performing the operation
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Connection - Clear

```
azdw connection clear --help
```

```
Description:
  Remove all configured connections

Usage:
  azdw connection clear [options]

Options:
  -y, --yes                   Skip confirmation prompts
  --dry-run, --what-if        Show what would be done without actually performing the operation
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Connection - Test

```
azdw connection test --help
```

```
Description:
  Test connectivity to connection(s)

Usage:
  azdw connection test [options]

Options:
  -n, --name <NAME>           Name of specific connection to test (if not specified, tests all)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Connection - Refresh

```
azdw connection refresh --help
```

```
Description:
  Re-authenticate connections with missing, expired, or invalid credentials

Usage:
  azdw connection refresh [options]

Options:
  -n, --name <NAME>           Name of specific connection to refresh (if not specified, refreshes all with expired credentials)
  --dry-run, --what-if        Show what would be done without actually performing the operation
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Connection - Export

```
azdw connection export --help
```

```
Description:
  Export connections to a JSON file

Usage:
  azdw connection export [options]

Options:
  -n, --name, --names <NAME>         Names of specific connections to export (if not specified, all connections will be exported)
  -o, --output <FILEPATH>            Output file path [default: ~/.azdw/config/connection-setup.jsonc]
  --include-secrets, --with-secrets  Include PAT tokens in export (WARNING: sensitive data, use only for secure backups)
  -y, --yes                          Skip confirmation prompts
  -?, -h, --help                     Show help and usage information
  -v, --verbose                      Enable verbose logging output
  --silent                           Suppress informational messages, show only data output
  --full-traces                      Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                Force terminal color mode: auto (default), dark, or light.
  --force-unicode                    Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                      Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                             Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                    Decode HTML entities in field values for readable output
  --remove-html-tags                 Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                       Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification         Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins           Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                      Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                     Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                Skip checking for a newer version on startup
  --no-caching                       Disable all caching for the entire program runtime

```

## Connection - Import

```
azdw connection import --help
```

```
Description:
  Import connections from a JSON file

Usage:
  azdw connection import <FILEPATH> [options]

Arguments:
  <FILEPATH>  Path to the JSON file to import

Options:
  -m, --merge                 Merge with existing connections [default: replace all]
  -y, --yes                   Skip confirmation prompts
  --dry-run, --what-if        Show what would be done without actually performing the operation
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Connection - Choose

```
azdw connection choose --help
```

```
Description:
  Enable or disable connections from automatic operations

Usage:
  azdw connection choose [options]

Options:
  -n, --name <NAME>           Connection name. If omitted, launches interactive multi-select mode.
  --enabled <BOOL>            Set enabled state: true to enable, false to disable. Requires --name.
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Wiql

```
azdw wiql --help
```

```
Description:
  Execute WIQL (Work Item Query Language) queries across connections

Usage:
  azdw wiql [<QUERY>...] [options]

Arguments:
  <QUERY>  WIQL query tokens, @file.wiql, or a .wiql path. Use --query-file for multiline queries.

Options:
  -c, --connection, --connections <NAMES>  Specific connections to query (if not specified, queries all)
  --limit, --max <COUNT>                   Maximum number of results to return per connection [default: 200]
  --format <FORMAT>                        Output format (table, json, csv, ids) [default: table]
  --validate                               Validate WIQL syntax without executing the query
  --examples                               Show example WIQL queries
  --include-failed                         Include details about failed organization queries in output
  --pretty                                 Pretty-print JSON output (only applies to JSON format)
  --resolve-logical-types                  Resolve logical types into actual types per connection
  --include-pii                            Include personally identifiable information (PII) such as user names
  --all-fields                             Include all work item fields in JSON/CSV output, including custom fields (increases response size)
  --ai, --ai-query <TEXT>                  Translate a natural language description to WIQL and execute it. Shows the generated query for confirmation before execution. Supports any language the AI model understands.
  -y, --yes                                Skip confirmation prompt when using --ai-query
  --query-url <URL>                        Azure DevOps query URL to retrieve and execute. Extracts the WIQL from a stored query and executes it on the matching connection. Supports query results URLs, query-edit URLs, and abbreviated ?id= format.
  -f, --query-file <PATH>                  Read a multiline WIQL query from a .wiql file
  -?, -h, --help                           Show help and usage information
  -v, --verbose                            Enable verbose logging output
  --silent                                 Suppress informational messages, show only data output
  --full-traces                            Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                      Force terminal color mode: auto (default), dark, or light.
  --force-unicode                          Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                            Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                                   Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                          Decode HTML entities in field values for readable output
  --remove-html-tags                       Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                             Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification               Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins                 Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                            Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                           Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                      Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                      Skip checking for a newer version on startup
  --no-caching                             Disable all caching for the entire program runtime

```

## Workitem

```
azdw workitem --help
```

```
Description:
  Create, update, and delete work items

Usage:
  azdw workitem [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  get <ID>                 Get a work item by ID
  create                   Create a new work item
  update <ID>              Update an existing work item
  delete, remove, rm <ID>  Delete a work item
  open-url                 Open work item(s) in the default browser

```

## Workitem - Get

```
azdw workitem get --help
```

```
Description:
  Get a work item by ID

Usage:
  azdw workitem get [<ID>] [options]

Arguments:
  <ID>  Work item identifier: an Azure DevOps numeric id, a GitHub issue URL, or 'owner/repo#N'

Options:
  -i, --id <ID>               Work item identifier (alias for the positional ID argument)
  -c, --connection <NAME>     Connection name (optional - if not specified, searches all connections)
  -r, --relationships         Include work item relationships
  --history                   Include work item history
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Workitem - Create

```
azdw workitem create --help
```

```
Description:
  Create a new work item

Usage:
  azdw workitem create [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Azure DevOps connection name (REQUIRED)
  -p, --project <NAME>                Project name (optional if connection is project-scoped)
  -t, --type <TYPE>                   Work item type (e.g., 'User Story', Bug, Task). REQUIRED unless --from-file is used.
  --title <TEXT>                      Work item title. REQUIRED unless --from-file is used.
  -d, --description <TEXT>            Work item description (optional)
  -a, --assigned-to <USER>            Assign to user (email or display name) (optional)
  -s, --state <STATE>                 Initial state (optional, defaults to New)
  --area <PATH>                       Area path (optional)
  -I, --iteration <PATH>              Iteration path (optional)
  --tags <TAGS>                       Tags (comma-separated)
  --field, --fields <NAME:VALUE>      Custom fields in format FieldName:Value (comma-separated)
  --comment <TEXT>                    Add a Discussion comment when creating the work item (optional).
  --dry-run                           Preview the work item without creating it
  -f, --from-file <PATH|URL>          Path or URL to a JSON/JSONC work item spec file. When provided, --type and --title are optional (values come from the file). CLI options override file values.
  --no-update                         Always create a new work item; skip upsert existence check
  --force                             Force upsert matching against any work item regardless of the azdw tracking tag
  -r, --reconcile                     Populate per-item reconciliation data (effective fields, resolved IDs, LocalSyncStatus). Requires --from-file.
  --bypass-rules                      Bypass Azure DevOps work item rules (e.g. state-transition validation) so items can be created directly in non-initial states. Requires the 'Bypass rules on work item updates' permission.
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Workitem - Update

```
azdw workitem update --help
```

```
Description:
  Update an existing work item

Usage:
  azdw workitem update [<ID>] [options]

Arguments:
  <ID>  Work item ID to update. Required unless --from-file provides work item IDs.

Options:
  -c, --connection <NAME>         Azure DevOps connection name (optional, uses connection from work item if not specified)
  --title <TEXT>                  Updated title (optional)
  -d, --description <TEXT>        Updated description (optional)
  -s, --state <STATE>             Updated state (optional)
  -a, --assigned-to <USER>        Assign to user (optional)
  --area <PATH>                   Updated area path (optional)
  -I, --iteration <PATH>          Updated iteration path (optional)
  --tags-add <TAGS>               Tags to add (comma-separated)
  --tags-remove <TAGS>            Tags to remove (comma-separated)
  --field, --fields <NAME:VALUE>  Custom fields to update in format 'FieldName:Value' (comma-separated)
  --comment <TEXT>                Add a Discussion comment to the work item (optional). Supplements other field updates.
  --add-hyperlink <URL>           Add a native Hyperlink relation pointing at an arbitrary URL (e.g., an external GitHub issue). Repeatable.
  --remove-hyperlink <URL>        Remove a native Hyperlink relation matching the given URL. Repeatable.
  --hyperlink-comment <TEXT>      Optional comment stored on hyperlinks added via --add-hyperlink.
  --dry-run                       Preview the changes without updating
  -f, --from-file <PATH>          Path or URL to a JSON/JSONC spec file containing fields to update. When provided, inline field options become overrides.
  --upsert                        Create the work item if it does not yet exist (requires spec file entries to include type and title).
  -r, --reconcile                 Populate per-item reconciliation data (effective fields, resolved IDs, LocalSyncStatus). Requires --from-file.
  --bypass-rules                  Bypass Azure DevOps work item rules (e.g. state-transition validation) so the work item can be moved directly to any state. Requires the 'Bypass rules on work item updates' permission.
  -?, -h, --help                  Show help and usage information
  -v, --verbose                   Enable verbose logging output
  --silent                        Suppress informational messages, show only data output
  --full-traces                   Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>             Force terminal color mode: auto (default), dark, or light.
  --force-unicode                 Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                   Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                          Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                 Decode HTML entities in field values for readable output
  --remove-html-tags              Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                    Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification      Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins        Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                   Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                  Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names             Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check             Skip checking for a newer version on startup
  --no-caching                    Disable all caching for the entire program runtime

```

## Workitem - Delete

```
azdw workitem delete --help
```

```
Description:
  Delete a work item

Usage:
  azdw workitem delete <ID> [options]

Arguments:
  <ID>  Work item identifier to delete: an Azure DevOps numeric id, a GitHub issue URL, or 'owner/repo#N'

Options:
  -c, --connection <NAME>     Azure DevOps connection name (optional, uses connection from work item if not specified)
  -y, --yes                   Skip confirmation prompt
  --soft-delete               Soft delete (can be recovered)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Workitem - Open Url

```
azdw workitem open-url --help
```

```
Description:
  Open work item(s) in the default browser

Usage:
  azdw workitem open-url [options]

Options:
  -i, --id <ID> (REQUIRED)    Work item identifier(s) to open: Azure DevOps numeric ids, GitHub issue URLs, or 'owner/repo#N' (REQUIRED, comma-separated)
  -c, --connection <NAME>     Connection name (optional - if not specified, searches all connections)
  -p, --print-only            Print URL(s) without opening browser
  --copy                      Copy URL(s) to clipboard (implies --print-only)
  -a, --all                   Open all matching work items when ID exists in multiple connections
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Credential

```
azdw credential --help
```

```
Description:
  Manage authentication credentials for connections

Usage:
  azdw credential [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  add              Add credentials for a connection (interactive). PAT tokens require specific scopes
  add-pat          Add a Personal Access Token for a connection. Azure DevOps scopes: Work Items (Read & Write) + Project and Team (Read). GitHub fine-grained: Issues (Read and write) + Metadata (Read) + Email addresses (Read), or classic scopes repo + read:org + user:email.
  add-code         Add Device Code Flow authentication for a connection
  add-interactive  Add Interactive Browser authentication for a connection
  list             List all stored credentials
  remove           Remove credentials for a connection
  validate         Validate stored credentials
  signout          Sign out from a connection
  clear            Clear all stored credentials
  repair           Diagnose and repair corrupted credentials

```

## Credential - Add

```
azdw credential add --help
```

```
Description:
  Add credentials for a connection (interactive). PAT tokens require specific scopes

Usage:
  azdw credential add [options]

Options:
  -c, --connection <NAME>     Connection name (omit to launch the guided setup wizard)
  --auth-type <TYPE>          Authentication type (pat, code, interactive) [default: pat]
  --tenant <TENANT>           Entra ID tenant ID or name (required for OAuth)
  --validate                  Validate the credentials after storing
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Credential - Add Pat

```
azdw credential add-pat --help
```

```
Description:
  Add a Personal Access Token for a connection. Azure DevOps scopes: Work Items (Read & Write) + Project and Team (Read). GitHub fine-grained: Issues (Read and write) + Metadata (Read) + Email addresses (Read), or classic scopes repo + read:org + user:email.

Usage:
  azdw credential add-pat [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  --token <TOKEN>                     Personal Access Token (prompted securely if not specified)
  -d, --description <TEXT>            Description for the token
  --validate                          Validate the token after storing
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Credential - Add Code

```
azdw credential add-code --help
```

```
Description:
  Add Device Code Flow authentication for a connection

Usage:
  azdw credential add-code [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  --tenant <TENANT> (REQUIRED)        Entra ID tenant ID or name
  --headless                          Run in headless mode (for CI/CD scenarios)
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Credential - Add Interactive

```
azdw credential add-interactive --help
```

```
Description:
  Add Interactive Browser authentication for a connection

Usage:
  azdw credential add-interactive [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  --tenant <TENANT> (REQUIRED)        Entra ID tenant ID or name
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Credential - List

```
azdw credential list --help
```

```
Description:
  List all stored credentials

Usage:
  azdw credential list [options]

Options:
  --format <FORMAT>           Output format (table, json) [default: table]
  --show-tokens               Show masked token previews
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Credential - Remove

```
azdw credential remove --help
```

```
Description:
  Remove credentials for a connection

Usage:
  azdw credential remove [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  --auth-type <TYPE>                  Authentication type (pat, oauth)
  -y, --yes                           Skip confirmation prompt
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Credential - Validate

```
azdw credential validate --help
```

```
Description:
  Validate stored credentials

Usage:
  azdw credential validate [options]

Options:
  -c, --connection <NAME>     Connection name (validate specific connection, or all if not specified)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Credential - Signout

```
azdw credential signout --help
```

```
Description:
  Sign out from a connection

Usage:
  azdw credential signout [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  --auth-type <TYPE>                  Authentication type (pat, oauth)
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Credential - Clear

```
azdw credential clear --help
```

```
Description:
  Clear all stored credentials

Usage:
  azdw credential clear [options]

Options:
  -y, --confirm               Skip confirmation prompt
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Credential - Repair

```
azdw credential repair --help
```

```
Description:
  Diagnose and repair corrupted credentials

Usage:
  azdw credential repair [options]

Options:
  --backup                    Backup existing credentials before clearing
  --clear                     Clear all corrupted credentials (cannot be recovered)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config

```
azdw config --help
```

```
Description:
  Manage configuration (field mappings, URL mappings, paths, shell integration, AI)

Usage:
  azdw config [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  fieldmap           Manage field mapping configurations
  urlmap             Manage URL domain mappings for TFS server migrations
  paths              Display configuration paths and directory information
  shell-integration  Manage shell integrations (tab-completions, PATH, PowerShell module auto-import)
  ai                 Manage AI provider configuration for template generation
  user               Manage user identity for 'my work items' queries

```

## Config - Fieldmap

```
azdw config fieldmap --help
```

```
Description:
  Manage field mapping configurations

Usage:
  azdw config fieldmap [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  list, ls  List all available field mappings for connections
  show      Show detailed information about a specific field mapping
  detect    Detect the process template for a connection
  generate  Generate automatic field mappings for a connection
  validate  Validate field mappings for a connection
  import    Import a field mapping from a file into the user configuration directory
  export    Export a field mapping to a file

```

## Config - Fieldmap - List

```
azdw config fieldmap list --help
```

```
Description:
  List all available field mappings for connections

Usage:
  azdw config fieldmap list [options]

Options:
  -c, --connection <NAME>     Show mappings for a specific connection (if not specified, shows all)
  -t, --template <TEMPLATE>   Filter by process template (e.g., Agile, Scrum, CMMI)
  --verbose                   Show detailed field mapping information
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Fieldmap - Show

```
azdw config fieldmap show --help
```

```
Description:
  Show detailed information about a specific field mapping

Usage:
  azdw config fieldmap show [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  -t, --type <TYPE> (REQUIRED)        Logical work item type (e.g., UserStory, Task, Bug)
  --template <TEMPLATE>               Process template (if not specified, auto-detects)
  -o, --output <FORMAT>               Output format (table, json) [default: table]
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Config - Fieldmap - Detect

```
azdw config fieldmap detect --help
```

```
Description:
  Detect the process template for a connection

Usage:
  azdw config fieldmap detect [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Config - Fieldmap - Generate

```
azdw config fieldmap generate --help
```

```
Description:
  Generate automatic field mappings for a connection

Usage:
  azdw config fieldmap generate [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  -t, --template <TEMPLATE>           Process template (if not specified, auto-detects)
  -f, --force                         Overwrite existing mappings
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Config - Fieldmap - Validate

```
azdw config fieldmap validate --help
```

```
Description:
  Validate field mappings for a connection

Usage:
  azdw config fieldmap validate [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  -t, --type <TYPE>                   Validate a specific logical work item type (if not specified, validates all)
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Config - Fieldmap - Import

```
azdw config fieldmap import --help
```

```
Description:
  Import a field mapping from a file into the user configuration directory

Usage:
  azdw config fieldmap import [options]

Options:
  -F, --file <FILEPATH> (REQUIRED)  Field mapping JSON file to import
  -n, --name <NAME>                 Custom name for the imported mapping (if not specified, uses filename)
  -m, --merge                       Merge with existing mapping if it already exists
  -?, -h, --help                    Show help and usage information
  -v, --verbose                     Enable verbose logging output
  --silent                          Suppress informational messages, show only data output
  --full-traces                     Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>               Force terminal color mode: auto (default), dark, or light.
  --force-unicode                   Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                     Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                            Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                   Decode HTML entities in field values for readable output
  --remove-html-tags                Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                      Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification        Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins          Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                     Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                    Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names               Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check               Skip checking for a newer version on startup
  --no-caching                      Disable all caching for the entire program runtime

```

## Config - Fieldmap - Export

```
azdw config fieldmap export --help
```

```
Description:
  Export a field mapping to a file

Usage:
  azdw config fieldmap export [options]

Options:
  -n, --name <NAME> (REQUIRED)        Name of the field mapping to export
  -o, --output <FILEPATH> (REQUIRED)  Output file path
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Config - Urlmap

```
azdw config urlmap --help
```

```
Description:
  Manage URL domain mappings for TFS server migrations

Usage:
  azdw config urlmap [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  list, ls                 List all URL domain mappings
  add <OLD-URL> <NEW-URL>  Add a new URL domain mapping
  remove, rm               Remove a URL domain mapping
  clear                    Remove all URL domain mappings
  enable                   Enable or disable URL domain mapping

```

## Config - Urlmap - List

```
azdw config urlmap list --help
```

```
Description:
  List all URL domain mappings

Usage:
  azdw config urlmap list [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Urlmap - Add

```
azdw config urlmap add --help
```

```
Description:
  Add a new URL domain mapping

Usage:
  azdw config urlmap add <OLD-URL> <NEW-URL> [options]

Arguments:
  <OLD-URL>  The old URL prefix to map from
  <NEW-URL>  The new URL prefix to map to

Options:
  -d, --description <TEXT>    Optional description for this mapping
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Urlmap - Remove

```
azdw config urlmap remove --help
```

```
Description:
  Remove a URL domain mapping

Usage:
  azdw config urlmap remove [options]

Options:
  -i, --index <NUMBER>        Index of the mapping to remove (from list command)
  -u, --url <URL>             Old URL prefix of the mapping to remove
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Urlmap - Clear

```
azdw config urlmap clear --help
```

```
Description:
  Remove all URL domain mappings

Usage:
  azdw config urlmap clear [options]

Options:
  -y, --yes                   Skip confirmation prompts
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Urlmap - Enable

```
azdw config urlmap enable --help
```

```
Description:
  Enable or disable URL domain mapping

Usage:
  azdw config urlmap enable [options]

Options:
  --disable                   Disable URL mapping instead of enabling it
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Paths

```
azdw config paths --help
```

```
Description:
  Display configuration paths and directory information

Usage:
  azdw config paths [options]

Options:
  -v, --verbose               Show detailed path information including file counts and examples
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Shell Integration

```
azdw config shell-integration --help
```

```
Description:
  Manage shell integrations (tab-completions, PATH, PowerShell module auto-import)

Usage:
  azdw config shell-integration [options]

Options:
  -a, --all                   Apply for all detected shells [default: current shell only]
  -u, --uninstall             Uninstall shell integration
  -l, --list                  List detected shells and their completion status
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Ai

```
azdw config ai --help
```

```
Description:
  Manage AI provider configuration for template generation

Usage:
  azdw config ai [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  set              Configure AI provider settings. Run without options for interactive mode.
  show             Display current AI provider configuration
  clear            Remove AI provider configuration and stored credentials
  approval         Configure approval preferences for AI tool execution
  skills           Manage azdw agent skills
  ghc-login-state  Check whether an active GitHub Copilot login session exists
  logout           Sign out and forget a GitHub Copilot account
  test             Test AI provider connectivity and model response

```

## Config - Ai - Set

```
azdw config ai set --help
```

```
Description:
  Configure AI provider settings. Run without options for interactive mode.

Usage:
  azdw config ai set [options]

Options:
  -a, --approach <APPROACH>   AI approach: github-copilot, anthropic, openai, or ollama
  -p, --provider <PROVIDER>   AI provider within the approach (optional, inferred when unambiguous): local, anthropic, microsoft-foundry, aws-bedrock, openai, http, default
  --aws-region <REGION>       AWS region for AWS Bedrock provider (e.g., us-east-1)
  -m, --model <MODEL>         Model name (e.g., gpt-5.6-luna, claude-sonnet-5, gemma4:12b)
  -k, --api-key <KEY>         API key (required for OpenAI, Azure OpenAI, Anthropic, and Anthropic Foundry, stored securely)
  -e, --endpoint <URL>        Custom endpoint URL (required for Azure OpenAI and Anthropic Foundry, optional for Ollama and Anthropic)
  -d, --deployment <NAME>     Azure OpenAI deployment name (required for Azure OpenAI)
  --github-host <HOST>        GitHub host for the github-copilot approach (e.g., github.com or mycompany.ghe.com)
  --github-account <ACCOUNT>  GitHub account/login for the github-copilot approach
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Examples:
  azdw config ai set
  azdw config ai set --approach github-copilot --model gpt-5.6-luna
  azdw config ai set --approach anthropic --model claude-sonnet-5 --api-key <key>
  azdw config ai set --approach anthropic --provider microsoft-foundry --model claude-sonnet-5 --endpoint <url> --api-key <key>
  azdw config ai set --approach anthropic --provider aws-bedrock --model claude-sonnet-5
  azdw config ai set --approach openai --model gpt-5.6-luna --api-key <key>
  azdw config ai set --approach openai --provider microsoft-foundry --model gpt-5.6-luna --endpoint <url> --deployment <name> --api-key <key>
  azdw config ai set --approach ollama --model gemma4:12b

Note:
  Run without arguments for interactive selection.
  Approaches: github-copilot, anthropic, openai, ollama.
  Providers per approach:
    anthropic: anthropic (default), microsoft-foundry, aws-bedrock
    openai:    openai (default), microsoft-foundry, http
  For local LLMs, use Ollama with a model that has native tool calling
  support and a context window >= 16K tokens. Requires ≥24 GB VRAM (e.g., gemma4:12b).
  Endpoint formats:
    Azure (OpenAI):    https://<resource>.openai.azure.com
    Azure (Anthropic): https://<resource>.services.ai.azure.com/anthropic/
```

## Config - Ai - Show

```
azdw config ai show --help
```

```
Description:
  Display current AI provider configuration

Usage:
  azdw config ai show [options]

Options:
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Ai - Clear

```
azdw config ai clear --help
```

```
Description:
  Remove AI provider configuration and stored credentials

Usage:
  azdw config ai clear [options]

Options:
  -y, --yes                   Skip confirmation prompts
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Ai - Approval

```
azdw config ai approval --help
```

```
Description:
  Configure approval preferences for AI tool execution

Usage:
  azdw config ai approval [options]

Options:
  -m, --mode <MODE>           Approval mode: always-ask, auto-approve-edits, or auto-approve-all
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Examples:
  azdw config ai approval --mode always-ask
  azdw config ai approval --mode auto-approve-edits
  azdw config ai approval --mode auto-approve-all

Note:
  Controls when user approval is requested before executing AI-initiated operations.
  • always-ask: Prompt for every tool execution (safest, default)
  • auto-approve-edits: Auto-approve read-only and non-critical operations
  • auto-approve-all: Auto-approve all operations (use with caution)
```

## Config - Ai - Skills

```
azdw config ai skills --help
```

```
Description:
  Manage azdw agent skills

Usage:
  azdw config ai skills [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  install  Install bundled azdw AI content (plugins, skills, agents, prompts, hooks, MCP servers) to the workspace root for AI model discovery
  list     List all bundled azdw agent skills and their installation status in the current workspace
  choose   Enable or disable discovered agent skills interactively or non-interactively

```

## Config - Ai - Skills - Install

```
azdw config ai skills install --help
```

```
Description:
  Install bundled azdw AI content (plugins, skills, agents, prompts, hooks, MCP servers) to the workspace root for AI model discovery

Usage:
  azdw config ai skills install [options]

Options:
  -c, --client <CLIENT>       Install AI content only for the specified client (claude or copilot) non-interactively. If omitted, opens interactive selection.
  -f, --force                 Auto-confirm conflict overwrites without per-item prompts (use with --all for fully non-interactive forced install)
  -a, --all                   Install all items non-interactively without prompting for selection (combine with --force to also overwrite conflicts)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Examples:
  azdw config ai skills install
  azdw config ai skills install --all
  azdw config ai skills install --force
  azdw config ai skills install --all --force
  azdw config ai skills install --client copilot
  azdw config ai skills install --client copilot --force
  azdw config ai skills install --client claude
  azdw config ai skills install --client claude --force
```

## Config - Ai - Skills - List

```
azdw config ai skills list --help
```

```
Description:
  List all bundled azdw agent skills and their installation status in the current workspace

Usage:
  azdw config ai skills list [options]

Options:
  --installed                 Show only skills that are installed in the current workspace
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Examples:
  azdw config ai skills list
  azdw config ai skills list --installed
```

## Config - Ai - Skills - Choose

```
azdw config ai skills choose --help
```

```
Description:
  Enable or disable discovered agent skills interactively or non-interactively

Usage:
  azdw config ai skills choose [options]

Options:
  --all                       Enable all discovered skills without prompting.
  --none                      Disable all discovered skills without prompting.
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Examples:
  azdw config ai skills choose
  azdw config ai skills choose --all
  azdw config ai skills choose --none
```

## Config - Ai - Ghc Login State

```
azdw config ai ghc-login-state --help
```

```
Description:
  Check whether an active GitHub Copilot login session exists

Usage:
  azdw config ai ghc-login-state [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Ai - Logout

```
azdw config ai logout --help
```

```
Description:
  Sign out and forget a GitHub Copilot account

Usage:
  azdw config ai logout [options]

Options:
  --github-host <HOST>        GitHub host of the account to forget (e.g., github.com or mycompany.ghe.com)
  --github-account <ACCOUNT>  GitHub account/login to forget
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - Ai - Test

```
azdw config ai test --help
```

```
Description:
  Test AI provider connectivity and model response

Usage:
  azdw config ai test [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - User

```
azdw config user --help
```

```
Description:
  Manage user identity for 'my work items' queries

Usage:
  azdw config user [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  show    Show configured user identity (email) for connections
  set     Set user email for a connection
  detect  Auto-detect and save user email for connections
  clear   Clear saved user email

```

## Config - User - Show

```
azdw config user show --help
```

```
Description:
  Show configured user identity (email) for connections

Usage:
  azdw config user show [options]

Options:
  -c, --connection <NAME>     Show user identity for a specific connection only
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - User - Set

```
azdw config user set --help
```

```
Description:
  Set user email for a connection

Usage:
  azdw config user set [options]

Options:
  -c, --connection <NAME> (REQUIRED)  The connection name to set the email for
  -e, --email <EMAIL> (REQUIRED)      Your email address
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Config - User - Detect

```
azdw config user detect --help
```

```
Description:
  Auto-detect and save user email for connections

Usage:
  azdw config user detect [options]

Options:
  -c, --connection <NAME>     Detect for a specific connection only [default: all connections]
  -s, --save                  Save detected email to user profile
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Config - User - Clear

```
azdw config user clear --help
```

```
Description:
  Clear saved user email

Usage:
  azdw config user clear [options]

Options:
  -c, --connection <NAME>     Clear for a specific connection only
  --all                       Clear all saved user emails
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Report

```
azdw report --help
```

```
Description:
  Generate reports and visualizations from work item data

Usage:
  azdw report [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  generate  Generate a report using a template
  template  Manage report templates

```

## Report - Generate

```
azdw report generate --help
```

```
Description:
  Generate a report using a template

Usage:
  azdw report generate [options]

Options:
  -id, --template-id <ID> (REQUIRED)       Template ID to use for generating the report
  -d, --data                               JSON file containing work item data (mutually exclusive with query and closure options)
  --from-closure                           Load work items from a closure JSON file (output from 'relationship find-closure'). Provides closure-specific data including hierarchy and traversal metadata.
  -o, --output                             Output file path (if not specified, writes to stdout)
  --format <FORMAT>                        Output format override (markdown, html, json, csv)
  -p, --parameters <JSON>                  Template parameters as JSON string or file path
  -i, --interactive                        Interactive mode for parameter input
  -r, --renderer <NAME>                    Custom renderer plugin name to use (optional, uses built-in renderers if not specified)
  --type, --types <TYPE>                   Work item types to filter by (supports both logical and actual types)
  -s, --state, --states <STATES>           Work item states to filter by (e.g., New, Active, Resolved, Closed)
  --states-exclude <STATES>                Work item states to exclude (e.g., Closed, Removed)
  -a, --assigned-to <USERS>                Users assigned to work items
  --area, --areas <PATHS>                  Area paths to filter by (uses hierarchical matching, includes all sub-areas)
  --iteration, --iterations <PATHS>        Iteration paths to filter by
  --tags <TAGS>                            Tags to filter by (work item must have at least one of these tags)
  --tags-include <TAGS>                    Tags that work items must have (OR logic)
  --tags-exclude <TAGS>                    Tags that work items must not have (AND logic)
  --tags-case-sensitive                    Make tag matching case-sensitive
  --field, --fields <FILTERS>              Custom field filter in format 'field:operator:value' (e.g., 'priority:equals:high')
  --created-after <DATE>                   Include work items created after this date (YYYY-MM-DD or YYYY-MM-DD HH:MM:SS)
  --created-before <DATE>                  Include work items created before this date (YYYY-MM-DD or YYYY-MM-DD HH:MM:SS)
  --modified-after <DATE>                  Include work items modified after this date (YYYY-MM-DD or YYYY-MM-DD HH:MM:SS)
  --modified-before <DATE>                 Include work items modified before this date (YYYY-MM-DD or YYYY-MM-DD HH:MM:SS)
  --ids <ID>                               Specific work item IDs to include
  --limit, --max <COUNT>                   Maximum number of results to return [default: no limit]
  -c, --connection, --connections <NAMES>  Specific connections to query (if not specified, queries all)
  --relationships                          Include work item relationships in the results
  --no-cross-conn                          Disable cross-connection relationships (enabled by default)
  --no-resolve-hyperlinks                  Disable hyperlink resolution to work items (enabled by default)
  --by-conn                                Group results by connection
  --by-project                             Group results by project
  --include-pii                            Include personal information (by default, PII fields are excluded)
  --filter-related                         Apply type and state filters to related work items too (by default, related items of any type/state are included)
  -y, --yes                                Skip confirmation prompt when querying all work items
  --exclude-disabled-types                 Exclude work item types that are disabled in the process template
  --global-stack-rank <PROFILE>            Activate a named global stack rank profile (from global-stack-rank.jsonc) to return a single, normalized, cross-org/cross-provider virtual backlog ordered by global rank.
  --allow-untrusted-dirs                   Allow loading template files from any location on disk (disables trusted directory validation)
  --ai, --ai-query <TEXT>                  Translate a natural language description to a WIQL query for report data. Shows the generated query for confirmation before execution. Supports any language the AI model understands.
  -?, -h, --help                           Show help and usage information
  -v, --verbose                            Enable verbose logging output
  --silent                                 Suppress informational messages, show only data output
  --full-traces                            Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                      Force terminal color mode: auto (default), dark, or light.
  --force-unicode                          Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                            Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                                   Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                          Decode HTML entities in field values for readable output
  --remove-html-tags                       Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                             Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification               Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins                 Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                            Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                           Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                      Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                      Skip checking for a newer version on startup
  --no-caching                             Disable all caching for the entire program runtime

```

## Report - Template

```
azdw report template --help
```

```
Description:
  Manage report templates

Usage:
  azdw report template [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  list                           List available report templates
  info                           Show detailed information about a template
  validate                       Validate a template file or content
  create                         Create a new custom template
  export                         Export a template to a file
  import                         Import a template from a file (JSON or raw content)
  remove                         Remove a custom template
  ai-prompt <USER-REQUIREMENTS>  Generate a comprehensive AI prompt for creating report templates
  ai-generate                    Generate a report template using AI from a natural language description

```

## Report - Template - List

```
azdw report template list --help
```

```
Description:
  List available report templates

Usage:
  azdw report template list [options]

Options:
  -c, --category <CATEGORY>        Filter templates by category
  --format <FORMAT>                Output format (table, json) [default: table]
  -t, --tags <TAGS>                Filter templates by tags (comma-separated)
  --output-format-filter <FORMAT>  Filter by output format (markdown, html, json, csv)
  -?, -h, --help                   Show help and usage information
  -v, --verbose                    Enable verbose logging output
  --silent                         Suppress informational messages, show only data output
  --full-traces                    Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>              Force terminal color mode: auto (default), dark, or light.
  --force-unicode                  Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                    Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                           Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                  Decode HTML entities in field values for readable output
  --remove-html-tags               Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                     Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification       Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins         Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                    Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                   Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names              Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check              Skip checking for a newer version on startup
  --no-caching                     Disable all caching for the entire program runtime

```

## Report - Template - Info

```
azdw report template info --help
```

```
Description:
  Show detailed information about a template

Usage:
  azdw report template info [options]

Options:
  -i, --template-id <ID> (REQUIRED)  Template ID to show information for
  --format <FORMAT>                  Output format (detailed, json) [default: detailed]
  -?, -h, --help                     Show help and usage information
  -v, --verbose                      Enable verbose logging output
  --silent                           Suppress informational messages, show only data output
  --full-traces                      Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                Force terminal color mode: auto (default), dark, or light.
  --force-unicode                    Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                      Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                             Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                    Decode HTML entities in field values for readable output
  --remove-html-tags                 Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                       Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification         Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins           Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                      Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                     Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                Skip checking for a newer version on startup
  --no-caching                       Disable all caching for the entire program runtime

```

## Report - Template - Validate

```
azdw report template validate --help
```

```
Description:
  Validate a template file or content

Usage:
  azdw report template validate [options]

Options:
  --file                      Template file to validate
  -c, --content <CONTENT>     Template content string to validate
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Report - Template - Create

```
azdw report template create --help
```

```
Description:
  Create a new custom template

Usage:
  azdw report template create [options]

Options:
  --file (REQUIRED)           Template JSON file to create
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Report - Template - Export

```
azdw report template export --help
```

```
Description:
  Export a template to a file

Usage:
  azdw report template export [options]

Options:
  -id, --template-id <ID> (REQUIRED)  Template ID to export
  -o, --output (REQUIRED)             Output file path
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Report - Template - Import

```
azdw report template import --help
```

```
Description:
  Import a template from a file (JSON or raw content)

Usage:
  azdw report template import [options]

Options:
  --file (REQUIRED)           Template file to import (JSON metadata file or raw template content)
  -w, --overwrite             Overwrite existing template with same ID
  -id, --template-id <ID>     Template ID (auto-generated from filename if not provided)
  --template-name <NAME>      Template display name (auto-generated from filename if not provided)
  --description <TEXT>        Template description
  --category <CATEGORY>       Template category (e.g., 'Release Management', Dashboards, 'Sprint Reports')
  --tags <TAGS>               Comma-separated list of tags
  --author <AUTHOR>           Template author
  --version <VERSION>         Template version
  --non-interactive           Fail if metadata is missing instead of prompting
  --allow-untrusted-dirs      Allow loading the template file from any location on disk (disables trusted directory validation)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Report - Template - Remove

```
azdw report template remove --help
```

```
Description:
  Remove a custom template

Usage:
  azdw report template remove [options]

Options:
  -id, --template-id <ID> (REQUIRED)  Template ID to remove
  -f, --force                         Force removal without confirmation
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Report - Template - Ai Prompt

```
azdw report template ai-prompt --help
```

```
Description:
  Generate a comprehensive AI prompt for creating report templates

Usage:
  azdw report template ai-prompt [<USER-REQUIREMENTS>] [options]

Arguments:
  <USER-REQUIREMENTS>  Custom requirements text to insert into the prompt (replaces the placeholder section)

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Report - Template - Ai Generate

```
azdw report template ai-generate --help
```

```
Description:
  Generate a report template using AI from a natural language description

Usage:
  azdw report template ai-generate [options]

Options:
  -id, --template-id <ID>     Template ID (lowercase alphanumeric with hyphens, e.g., 'my-report-template'). If not provided, derived from --name.
  -n, --name <NAME>           Template display name (e.g., 'My Report Template'). If not provided with --template-id, defaults to title-cased ID.
  -g, --goal <TEXT>           Natural language description of what the template should produce
  --output-format <FORMAT>    Output format for the generated template (markdown, html, csv, json, text) [default: markdown]
  --category <CATEGORY>       Category for the generated template [default: AI Generated]
  --tags <TAGS>               Comma-separated tags for the generated template [default: ai-generated]
  --overwrite                 Overwrite if a template with the same ID exists
  --timeout <SECONDS>         AI request timeout in seconds [default: 120]
  --preview                   Preview the generated template JSON without importing
  --save-raw                  Save the raw AI response to a file for debugging
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Visualize

```
azdw visualize --help
```

```
Description:
  Generate visualizations of work item relationships

Usage:
  azdw visualize [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  graph  Generate visualization of work item relationships in various formats

```

## Visualize - Graph

```
azdw visualize graph --help
```

```
Description:
  Generate visualization of work item relationships in various formats

Usage:
  azdw visualize graph [options]

Options:
  -i, --id, --ids <ID>                 Work item IDs to visualize (ID-based mode)
  -c, --conn, --connection <NAME>      Azure DevOps connection name (required for ID-based mode)
  --from-closure                       Load work items from a closure JSON file (output from 'relationship find-closure')
  --from-file                          Load work items from a JSON file
  -t, --type, --types <TYPES>          Work item types to filter by (supports both logical and actual types)
  -s, --state, --states <STATES>       Work item states to filter by (e.g., New, Active, Resolved, Closed)
  --states-exclude <STATES>            Work item states to exclude (e.g., Closed, Removed)
  -a, --assigned-to <USERS>            Users assigned to work items
  --area, --areas <PATHS>              Area paths to filter by (uses hierarchical matching, includes all sub-areas)
  --iteration, --iterations <PATHS>    Iteration paths to filter by
  --tags <TAGS>                        Tags to filter by (work item must have at least one of these tags)
  --field, --fields <FILTERS>          Custom field filter in format 'field:operator:value' (e.g., 'priority:equals:high')
  -f, --format <FORMAT>                Output format (graphviz, graph, graphml, mermaid-flowchart, mermaid-er, mermaid-requirement, mermaid-kanban, mermaid-gantt) [default: graphviz]
  --layout <STYLE>                     Layout style (graph, tree, network) - DOT only [default: graph]
  --direction <DIRECTION>              Layout direction (tb, lr, bt, rl) - DOT only: tb=top-bottom, lr=left-right, bt=bottom-top, rl=right-left [default: tb]
  --renderer <NAME>                    Custom renderer plugin name to use (optional, uses built-in renderers if not specified)
  -d, --max-depth <DEPTH>              Maximum relationship depth to traverse
  --relationship-types <TYPES>         Specific relationship types to include (e.g., Child, Related)
  --hierarchy, --hierarchy-only        Include only hierarchical parent-child relationships
  --dependencies, --dependencies-only  Include only dependency relationships (Predecessor, Successor)
  --related, --related-only            Include only Related links
  --cross-conn-only                    Include only cross-connection relationships
  --no-cross-conn                      Disable cross-connection relationships (enabled by default)
  --no-resolve-hyperlinks              Disable hyperlink resolution to work items (enabled by default)
  --resolve-field-refs                 Resolve work item references from configured custom fields (uses field-reference-mappings.jsonc)
  --resolve-file-content               Fetch file content and apply content extraction patterns for file relationships (uses contentExtractionPatterns in file-relationship-config.jsonc)
  --by-conn                            Group results by connection [default: show integrated view with org/project columns]
  --by-project                         Group results by project [default: show integrated view with org/project columns]
  --exclude-disabled-types             Exclude work item types that are disabled in the process template [default: includes all types]
  --show-legend                        Include legend in visualization (graphviz and mermaid formats)
  --title <TEXT>                       Title for the visualization
  --kanban-state-order <STATES>        Custom state order for Kanban columns (e.g., New, Active, Resolved, Closed). Only applies to mermaid-kanban format.
  --exclude-weekends                   Exclude weekends from the Gantt chart timeline. Only applies to mermaid-gantt format.
  --color-map                          Path to JSON color map file (relative to executable or absolute)
  --node-fields <FIELDS>               Additional work item fields to display in nodes (e.g., System.State, System.AssignedTo)
  --include-pii                        Include personal information like AssignedTo [default: shows 'unknown' instead]
  --filter-related                     Apply type and state filters to related work items too (by default, related items of any type/state are included)
  --optimize-for-yed                   Generate yEd-optimized GraphML with colored shapes and group containers (only for graphml format)
  -y, --yes                            Skip confirmation prompt when querying all work items
  -o, --output                         Output file path (defaults to stdout)
  --ai, --ai-query <TEXT>              Translate a natural language description to a WIQL query for visualization. Shows the generated query for confirmation before execution. Supports any language the AI model understands.
  -?, -h, --help                       Show help and usage information
  -v, --verbose                        Enable verbose logging output
  --silent                             Suppress informational messages, show only data output
  --full-traces                        Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                  Force terminal color mode: auto (default), dark, or light.
  --force-unicode                      Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                        Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                               Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                      Decode HTML entities in field values for readable output
  --remove-html-tags                   Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                         Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification           Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins             Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                        Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                       Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                  Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                  Skip checking for a newer version on startup
  --no-caching                         Disable all caching for the entire program runtime

```

## Query

```
azdw query --help
```

```
Description:
  Query work items Azure DevOps connections.

Usage:
  azdw query [options]

Options:
  -t, --type, --types <TYPES>              Work item types to filter by (supports both logical and actual types)
  -s, --state, --states <STATES>           Work item states to filter by (e.g., New, Active, Resolved, Closed)
  --states-exclude <STATES>                Work item states to exclude (e.g., Closed, Removed)
  -a, --assigned-to <USERS>                Users assigned to work items
  --area, --areas <PATHS>                  Area paths to filter by. Examples: --areas 'Project\Team A, Project\Team B' or --areas "'Project\Team A', 'Project\Team B'"
  --iteration, --iterations <PATHS>        Iteration paths to filter by
  --tags <TAGS>                            Tags to filter by (work item must have at least one of these tags)
  --tags-include <TAGS>                    Tags that work items must have (OR logic)
  --tags-exclude <TAGS>                    Tags that work items must not have (AND logic)
  --tags-case-sensitive                    Make tag matching case-sensitive
  --field, --fields <FILTERS>              Custom field filter in format 'field:operator:value' (e.g., 'priority:equals:high')
  --created-after <DATE>                   Include work items created after this date (YYYY-MM-DD or YYYY-MM-DD HH:MM:SS)
  --created-before <DATE>                  Include work items created before this date (YYYY-MM-DD or YYYY-MM-DD HH:MM:SS)
  --modified-after <DATE>                  Include work items modified after this date (YYYY-MM-DD or YYYY-MM-DD HH:MM:SS)
  --modified-before <DATE>                 Include work items modified before this date (YYYY-MM-DD or YYYY-MM-DD HH:MM:SS)
  --ids <IDS>                              Specific work item IDs to include
  --limit, --max <COUNT>                   Maximum number of results to return [default: no limit]
  -c, --connection, --connections <NAMES>  Specific connections to query (if not specified, queries all)
  --format <FORMAT>                        Output format (table, json, csv) [default: table]
  --renderer <NAME>                        Custom renderer plugin name to use (optional, uses built-in formatters if not specified)
  --relationships                          Include work item relationships in the results; hyperlinks are resolved by default unless --no-resolve-hyperlinks is specified
  --no-cross-conn                          Disable cross-connection relationship resolution when including relationships (enabled by default with --relationships)
  --sort <COLUMN[:ORDER]>                  Sort by column(s). Format: ColumnName or ColumnName:asc|desc. Multiple sorts supported.
  --global-stack-rank <PROFILE>            Activate a named global stack rank profile (from global-stack-rank.jsonc) to return a single, normalized, cross-org/cross-provider virtual backlog ordered by global rank. Cannot be combined with --sort.
  --by-conn                                Group results by connection [default: show integrated view with org/project columns]
  --by-project                             Group results by project [default: show integrated view with org/project columns]
  --include-pii                            Include personal information (by default, PII fields are excluded, free text fields are not scanned)
  --exclude-disabled-types                 Exclude work item types that are disabled in the process template [default: includes all types]
  -y, --yes                                Skip confirmation prompt when querying all work items
  --no-resolve-hyperlinks                  Disable hyperlink resolution to work items when including relationships (enabled by default with --relationships, uses hyperlink-mappings.jsonc configuration)
  --hyperlinks-as <TYPE>                   Specify how to interpret hyperlinks as relationships (Parent, Child, Related, Dependency). Uses hyperlink-mappings.jsonc if not specified.
  --resolve-field-refs                     Resolve work item references from configured custom fields (uses field-reference-mappings.jsonc)
  --include-file-relationships             Include fake work items from file relationship patterns (e.g., ADR documents, RFCs from file-relationship-config.jsonc)
  --resolve-file-content                   Fetch file content and apply content extraction patterns for file relationships (uses contentExtractionPatterns in file-relationship-config.jsonc)
  --all-fields                             Include all work item fields in JSON/CSV output, including custom fields (increases response size)
  --filter-related                         Apply type and state filters to related work items too (by default, related items of any type/state are included)
  --cols, --columns <COLUMNS>              Columns to display in table output (e.g., ID,Type,State,Title,AssignedTo,CreatedDate,ModifiedDate,AreaPath,IterationPath,Priority,Tags)
  --ai, --ai-query <TEXT>                  Translate a natural language description to WIQL and execute it. Shows the generated query for confirmation before execution. Supports any language the AI model understands.
  -?, -h, --help                           Show help and usage information
  -v, --verbose                            Enable verbose logging output
  --silent                                 Suppress informational messages, show only data output
  --full-traces                            Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                      Force terminal color mode: auto (default), dark, or light.
  --force-unicode                          Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                            Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                                   Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                          Decode HTML entities in field values for readable output
  --remove-html-tags                       Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                             Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification               Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins                 Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                            Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                           Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                      Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                      Skip checking for a newer version on startup
  --no-caching                             Disable all caching for the entire program runtime

```

## Reconcile

```
azdw reconcile --help
```

```
Description:
  Analyze duplicate candidates and missing relationships without changing work items.

Usage:
  azdw reconcile [options]

Options:
  -c, --connection, --connections <NAMES>                          Connection aliases to analyze (default: all enabled connections).
  -t, --type, --types <TYPES>                                      Work item types to filter by (supports both logical and actual types)
  -s, --state, --states <STATES>                                   Work item states to filter by (e.g., New, Active, Resolved, Closed)
  --states-exclude <STATES>                                        Work item states to exclude (e.g., Closed, Removed)
  -a, --assigned-to <USERS>                                        Users assigned to work items
  --area, --areas <PATHS>                                          Area paths to filter by (uses hierarchical matching, includes all sub-areas)
  --iteration, --iterations <PATHS>                                Iteration paths to filter by
  --tags <TAGS>                                                    Tags to filter by (work item must have at least one of these tags)
  --tags-include <TAGS>                                            Tags that work items must have (OR logic)
  --tags-exclude <TAGS>                                            Tags that work items must not have (AND logic)
  --tags-case-sensitive                                            Make tag matching case-sensitive
  --field, --fields <FILTERS>                                      Custom field filter in format 'field:operator:value' (e.g., 'priority:equals:high')
  --ids <IDS>                                                      Specific work item IDs to include
  --limit, --max <COUNT>                                           Maximum retained items per connection before the global --max-items budget.
  --created-after <created-after>
  --created-before <created-before>
  --modified-after <modified-after>
  --modified-before <modified-before>
  --title <title>                                                  Title text to match within the candidate scope.
  --seed-keys <seed-keys>                                          Qualified keys within the retrieved universe; never fetched outside scope.
  --instructions <instructions>                                    Per-analysis guidance, at most 8000 characters; does not change filters.
  --instructions-file <instructions-file>                          UTF-8 guidance file; mutually exclusive with --instructions.
  --ai                                                             Opt in to sending selected work-item text and analysis context to the configured AI.
  --no-ai                                                          Only generate deterministic candidates; do not send work-item text to AI.
  --allow-cross-connection-ai                                      Allow text from different selected connections in the same AI assessment.
  --max-items <max-items>                                          Maximum retained items across all connections (1-1000). [default: 100]
  --max-scan-items-per-connection <max-scan-items-per-connection>  Maximum physical hits per connection (1-5000). [default: 500]
  --max-comparisons <max-comparisons>                              Maximum deterministic comparisons (1-100000). [default: 10000]
  --max-candidate-pairs <max-candidate-pairs>                      Maximum retained candidate pairs (1-1000). [default: 100]
  --max-ai-calls <max-ai-calls>                                    Maximum AI calls (0-100). [default: 10]
  --max-output-tokens <max-output-tokens>                          Maximum output tokens per AI call (100-8000). [default: 1500]
  --max-prompt-characters <max-prompt-characters>                  Maximum input characters per AI call (1000-100000). [default: 32000]
  --max-duration-seconds <max-duration-seconds>                    Elapsed time budget (1-1800 seconds). [default: 120]
  --minimum-score <minimum-score>                                  Minimum lexical retrieval score (0-1), not semantic confidence. [default: 0.2]
  --top-work-item-type <top-work-item-type>                        Override the configured top-level logical type.
  -o, --output <output>                                            Write the full versioned JSON document to this file.
  --format <json|table>                                            Output format: table or json. [default: table]
  -?, -h, --help                                                   Show help and usage information
  -v, --verbose                                                    Enable verbose logging output
  --silent                                                         Suppress informational messages, show only data output
  --full-traces                                                    Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                                              Force terminal color mode: auto (default), dark, or light.
  --force-unicode                                                  Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                                                    Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                                                           Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                                                  Decode HTML entities in field values for readable output
  --remove-html-tags                                               Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                                                     Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification                                       Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins                                         Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                                                    Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                                                   Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                                              Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                                              Skip checking for a newer version on startup
  --no-caching                                                     Disable all caching for the entire program runtime

```

## Relationship

```
azdw relationship --help
```

```
Description:
  Manage work item relationships across connections

Usage:
  azdw relationship [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  resolve        Resolve work item relationships with cross-connection support
  validate       Validate work item relationships against policies
  analyze        Analyze work item relationship patterns and metrics
  find-orphans   Find orphaned work items with no relationships
  find-circular  Find circular dependency chains in work item relationships
  find-closure   Find the complete hierarchy closure for one or more work items

```

## Relationship - Resolve

```
azdw relationship resolve --help
```

```
Description:
  Resolve work item relationships with cross-connection support

Usage:
  azdw relationship resolve [options]

Options:
  -i, --id, --ids <ID> (REQUIRED)     Work item IDs to resolve relationships for
  -c, --connection <NAME> (REQUIRED)  Azure DevOps connection name
  -o, --output                        Output file path for results (JSON format)
  -d, --max-depth <DEPTH>             Maximum relationship depth to traverse
  -r, --relationship-types <TYPE>     Relationship types to include (e.g., Hierarchy, Dependency, Related)
  --no-cross-conn                     Disable cross-connection relationships (enabled by default)
  --no-resolve-hyperlinks             Disable hyperlink resolution to work items (enabled by default)
  --hyperlinks-as <TYPE>              Specify how to interpret hyperlinks as relationships (Parent, Child, Related, Dependency). Uses hyperlink-mappings.jsonc if not specified.
  --resolve-field-refs                Resolve work item references from configured custom fields (uses field-reference-mappings.jsonc)
  --resolve-file-content              Fetch file content and apply content extraction patterns for file relationships (uses contentExtractionPatterns in file-relationship-config.jsonc)
  --no-bidirectional-hyperlinks       Disable bidirectional hyperlink search (enabled by default). When enabled, searches other connections for work items that hyperlink to resolved items.
  --limit-conns <NAMES>               Limit resolution to specific connections
  --states-exclude <STATES>           Work item states to exclude (e.g., Closed, Removed)
  -f, --format <FORMAT>               Output format (json, table, csv) [default: table]
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Relationship - Validate

```
azdw relationship validate --help
```

```
Description:
  Validate work item relationships against policies

Usage:
  azdw relationship validate [options]

Options:
  -i, --id, --ids <ID> (REQUIRED)     Work item IDs to validate relationships for
  -c, --connection <NAME> (REQUIRED)  Azure DevOps connection name
  -p, --policy-file                   Policy configuration file (JSON format)
  -o, --output                        Output file path for validation results
  -s, --strict                        Use strict policy enforcement mode
  -d, --max-depth <DEPTH>             Maximum relationship depth to traverse
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Relationship - Analyze

```
azdw relationship analyze --help
```

```
Description:
  Analyze work item relationship patterns and metrics

Usage:
  azdw relationship analyze [options]

Options:
  -i, --id, --ids <ID> (REQUIRED)     Work item IDs to analyze relationships for
  -c, --connection <NAME> (REQUIRED)  Azure DevOps connection name
  -o, --output                        Output file path for analysis results
  -m, --include-metrics               Include detailed relationship metrics
  -d, --max-depth <DEPTH>             Maximum relationship depth to traverse (default: 100). Pass 0 to remove the limit.
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Relationship - Find Orphans

```
azdw relationship find-orphans --help
```

```
Description:
  Find orphaned work items with no relationships

Usage:
  azdw relationship find-orphans [options]

Options:
  -c, --connections <NAMES> (REQUIRED)  Connection names to search for orphans
  -t, --types <TYPES>                   Filter by work item types
  -s, --states <STATES>                 Filter by work item states
  --limit, --max <COUNT>                Maximum number of work items to query [default: 1000]
  -o, --output                          Output file path for results (JSON format)
  -?, -h, --help                        Show help and usage information
  -v, --verbose                         Enable verbose logging output
  --silent                              Suppress informational messages, show only data output
  --full-traces                         Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                   Force terminal color mode: auto (default), dark, or light.
  --force-unicode                       Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                         Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                                Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                       Decode HTML entities in field values for readable output
  --remove-html-tags                    Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                          Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification            Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins              Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                         Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                        Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                   Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                   Skip checking for a newer version on startup
  --no-caching                          Disable all caching for the entire program runtime

```

## Relationship - Find Circular

```
azdw relationship find-circular --help
```

```
Description:
  Find circular dependency chains in work item relationships

Usage:
  azdw relationship find-circular [options]

Options:
  -c, --connections <NAMES> (REQUIRED)  Connection names to search for circular dependencies
  -t, --types <TYPES>                   Filter by work item types
  -s, --states <STATES>                 Filter by work item states
  --limit, --max <COUNT>                Maximum number of work items to query [default: 1000]
  -o, --output <output>                 Output file path for results (JSON format)
  --filter-related                      Apply type and state filters to related work items too (by default, related items of any type/state are included)
  -?, -h, --help                        Show help and usage information
  -v, --verbose                         Enable verbose logging output
  --silent                              Suppress informational messages, show only data output
  --full-traces                         Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                   Force terminal color mode: auto (default), dark, or light.
  --force-unicode                       Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                         Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                                Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                       Decode HTML entities in field values for readable output
  --remove-html-tags                    Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                          Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification            Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins              Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                         Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                        Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                   Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                   Skip checking for a newer version on startup
  --no-caching                          Disable all caching for the entire program runtime

```

## Relationship - Find Closure

```
azdw relationship find-closure --help
```

```
Description:
  Find the complete hierarchy closure for one or more work items

Usage:
  azdw relationship find-closure [options]

Options:
  -i, --id, --ids <ID> (REQUIRED)     Work item ID(s) to find closure for. Multiple IDs must be comma-separated (e.g., -i 100,200,300). When multiple IDs share relationships, their closures are automatically merged.
  -c, --connection <NAME> (REQUIRED)  Azure DevOps connection name
  -t, --top-type <TYPE>               Top-level work item type (e.g., Epic) [default: Epic]
  --no-siblings                       Exclude sibling items of the same type
  --include-top-siblings              Include siblings of top-level items
  --include-predecessors              Include predecessor relationships
  --no-resolve-hyperlinks             Disable hyperlink resolution to work items (enabled by default)
  --resolve-field-refs                Resolve work item references from configured custom fields (uses field-reference-mappings.jsonc)
  --resolve-file-content              Extract field values from file content using configured regex patterns (only when file relationship patterns with content extraction are configured)
  --hyperlinks-as <TYPE>              How to treat resolved hyperlinks (Parent, Child, Dependency, Related): Parent=hyperlinked items above, Child=hyperlinked items below, Dependency=predecessor, Related=related items
  --no-bidirectional-hyperlinks       Disable bidirectional hyperlink resolution (enabled by default). When enabled, also searches for work items in other connections that have hyperlinks pointing TO items in the closure.
  --bidirectional-hyperlinks-github   Enable reverse hyperlink discovery for GitHub (disabled by default). When enabled, GitHub issues are enumerated and their bodies scanned for links pointing TO items already in the closure, so a closure can pull in the GitHub issues that reference it. Independent of --no-bidirectional-hyperlinks.
  --no-cross-conn                     Disable cross-connection relationship resolution (enabled by default)
  --limit-conns <NAME>                Limit cross-connection resolution to specific connections
  -m, --max-size <SIZE>               Maximum closure size (1-10000) [default: 10000]
  --states-exclude <STATES>           Work item states to exclude (e.g., Closed, Removed)
  --exclude-disabled-types            Exclude work item types that are disabled in the process template [default: includes all types]
  -o, --output                        Output file path for results
  -f, --format <FORMAT>               Output format (json, table, csv) [default: table]
  --ai-tell-story                     Generate an AI-powered story narrative from the closure, including INVEST/SMART evaluation and clarifying questions for developers
  --include-pii                       Include PII fields (AssignedTo, CreatedBy, ChangedBy) in the AI story analysis
  --max-depth <LEVELS>                Limit results to the specified number of hierarchy levels from the start item. The closure is still fully computed, but only items within max-depth levels (positive for descendants, negative for ancestors) are included in results.
  -y, --yes                           Skip confirmation prompts
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Metadata

```
azdw metadata --help
```

```
Description:
  Display work item metadata (types, fields, states)

Usage:
  azdw metadata [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  types       List work item types for a connection
  fields      List fields for a work item type
  states      List valid states for a work item type
  areas       List area paths
  iterations  List iteration paths

```

## Metadata - Types

```
azdw metadata types --help
```

```
Description:
  List work item types for a connection

Usage:
  azdw metadata types [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name to query work item types for
  --verbose                           Show detailed information including reference names and states
  --refresh                           Force refresh from API (bypass cache)
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Metadata - Fields

```
azdw metadata fields --help
```

```
Description:
  List fields for a work item type

Usage:
  azdw metadata fields [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  -t, --type <TYPE> (REQUIRED)        Work item type (e.g., 'User Story', Bug, Task)
  -p, --project <NAME>                Optional project name
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Metadata - States

```
azdw metadata states --help
```

```
Description:
  List valid states for a work item type

Usage:
  azdw metadata states [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  -t, --type <TYPE> (REQUIRED)        Work item type (e.g., 'User Story', 'Bug', 'Task')
  -p, --project <NAME>                Optional project name
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Metadata - Areas

```
azdw metadata areas --help
```

```
Description:
  List area paths

Usage:
  azdw metadata areas [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  -p, --project <NAME>                Optional project name
  -d, --depth <DEPTH>                 Maximum depth to retrieve [default: all levels]
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Metadata - Iterations

```
azdw metadata iterations --help
```

```
Description:
  List iteration paths

Usage:
  azdw metadata iterations [options]

Options:
  -c, --connection <NAME> (REQUIRED)  Connection name
  -p, --project <NAME>                Optional project name
  -d, --depth <DEPTH>                 Maximum depth to retrieve [default: all levels]
  -?, -h, --help                      Show help and usage information
  -v, --verbose                       Enable verbose logging output
  --silent                            Suppress informational messages, show only data output
  --full-traces                       Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                 Force terminal color mode: auto (default), dark, or light.
  --force-unicode                     Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                       Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                              Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                     Decode HTML entities in field values for readable output
  --remove-html-tags                  Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                        Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification          Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins            Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                       Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                      Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                 Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                 Skip checking for a newer version on startup
  --no-caching                        Disable all caching for the entire program runtime

```

## Capacity

```
azdw capacity --help
```

```
Description:
  Analyse demand-vs-supply load across portfolio dimensions

Usage:
  azdw capacity [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  analyze  Compute a demand-vs-supply load table

```

## Capacity - Analyze

```
azdw capacity analyze --help
```

```
Description:
  Compute a demand-vs-supply load table

Usage:
  azdw capacity analyze [options]

Options:
  --capacity-file <PATH>           Capacity-supply file path (defaults to ~/.azdw/config/capacity-supply.jsonc, repo config/ fallback).
  --demand-field <REF>             Work-item numeric field reference to sum as demand (e.g. Microsoft.VSTS.Scheduling.Effort). Required unless 'capacityDemandField' is set in defaults.jsonc, in which case that value is used.
  --demand-unit <UNIT>             Unit of the demand field; validated against the capacity file unit (default personWeeks).
  --group-by <DIMS> (REQUIRED)     Comma-separated dimensions to group by (subset of team,valueStream,horizon,areaPath,period).
  --query <WIQL|IDS>               In-scope items: a WIQL query, or a comma-separated list of work item IDs.
  --closure <ID>                   In-scope items: a relationship closure root work item ID.
  --closure-file <PATH>            In-scope items: a closure output JSON file from 'relationship find-closure --format json' (may span multiple connections; --connection is ignored).
  --query-file <PATH>              In-scope items: a query output JSON file from 'query --format json' (may span multiple connections; --connection is ignored).
  --connection <NAME>              Connection name for the source retrieval (defaults to the first configured connection). Ignored when --closure-file or --query-file is used.
  --threshold-under <PCT>          Override the under-utilised upper bound percentage (policy).
  --threshold-overallocated <PCT>  Override the over-allocated lower bound percentage (policy).
  --target-load <PCT>              Enable drill-down: list contributors and deferral-to-target for over-allocated groups.
  --force-refresh                  For --closure-file/--query-file sources: ignore the demand values stored in the file and re-query the servers by work item ID for fresh values (cross-connection). No effect on live sources.
  --ai-estimate                    Use the configured AI model to estimate the demand field for in-scope work items that have no value. Fails early if no AI is configured. Estimates assume an average human dev team (not best-in-world, no AI coding-agent help) with tolerance for routine dependency updates and basic refactoring; a note explaining the assumptions is printed.
  --format <FORMAT>                Output format. [default: table]
  -?, -h, --help                   Show help and usage information
  -v, --verbose                    Enable verbose logging output
  --silent                         Suppress informational messages, show only data output
  --full-traces                    Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>              Force terminal color mode: auto (default), dark, or light.
  --force-unicode                  Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                    Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                           Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                  Decode HTML entities in field values for readable output
  --remove-html-tags               Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                     Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification       Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins         Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                    Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                   Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names              Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check              Skip checking for a newer version on startup
  --no-caching                     Disable all caching for the entire program runtime

```

## Cache

```
azdw cache --help
```

```
Description:
  Manage cache operations

Usage:
  azdw cache [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  status   Get cache status
  stats    Get detailed cache statistics
  clear    Clear cache entries
  refresh  Refresh cache entries approaching expiration

```

## Cache - Status

```
azdw cache status --help
```

```
Description:
  Get cache status

Usage:
  azdw cache status [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Cache - Stats

```
azdw cache stats --help
```

```
Description:
  Get detailed cache statistics

Usage:
  azdw cache stats [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Cache - Clear

```
azdw cache clear --help
```

```
Description:
  Clear cache entries

Usage:
  azdw cache clear [options]

Options:
  -c, --conn, --connection <NAME>  Clear cache only for specific connection
  --expired-only                   Clear only expired entries
  -y, --yes                        Skip confirmation prompts
  -?, -h, --help                   Show help and usage information
  -v, --verbose                    Enable verbose logging output
  --silent                         Suppress informational messages, show only data output
  --full-traces                    Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>              Force terminal color mode: auto (default), dark, or light.
  --force-unicode                  Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                    Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                           Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                  Decode HTML entities in field values for readable output
  --remove-html-tags               Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                     Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification       Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins         Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                    Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                   Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names              Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check              Skip checking for a newer version on startup
  --no-caching                     Disable all caching for the entire program runtime

```

## Cache - Refresh

```
azdw cache refresh --help
```

```
Description:
  Refresh cache entries approaching expiration

Usage:
  azdw cache refresh [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Release Notes

```
azdw release-notes --help
```

```
Description:
  Display the embedded release notes in Markdown format

Usage:
  azdw release-notes [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Docs

```
azdw docs --help
```

```
Description:
  Open the README and docs in the mdv Markdown viewer

Usage:
  azdw docs [options]

Options:
  --tui                       Force mdv to run in terminal UI (TUI) mode instead of opening the GUI
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Ai Mcp Server

```
azdw ai-mcp-server --help
```

```
Description:
  Start MCP (Model Context Protocol) server for AI assistant integration

Usage:
  azdw ai-mcp-server [command] [options]

Options:
  -c, --client-approvals      Disable server-side approvals and let the MCP client handle tool execution approvals. Use this when your MCP client (like VS Code) has its own approval UI.
  --work-dir <PATH>           Work directory for sandboxed file operations (write, read, render). Defaults to the current working directory (falls back to <temp>/azdw-mcp-work/ when the current directory is the home folder or a disk root). All file operations are restricted to this directory for security.
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  init <CLIENT>  Generates a ready-to-use configuration snippet for integrating azdw with various MCP-compatible AI assistants. Run with a client name to get the configuration, or without arguments for an interactive menu.
  tools          Manage MCP tool categories and list available tools

```

## Ai Mcp Server - Init

```
azdw ai-mcp-server init --help
```

```
Description:
  Generates a ready-to-use configuration snippet for integrating azdw with various MCP-compatible AI assistants. Run with a client name to get the configuration, or without arguments for an interactive menu.

Usage:
  azdw ai-mcp-server init [<CLIENT>] [options]

Arguments:
  <CLIENT>  The MCP client to configure (e.g., github-copilot-vscode, cursor, claude-desktop)

Options:
  -a, --apply                 Automatically apply the configuration to the client's config file (creates backup first)
  -p, --path <FILEPATH>       Custom path to the config file (required for clients without predefined paths like librechat)
  -l, --list                  List all supported MCP client identifiers (one per line, for scripting)
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Ai Mcp Server - Tools

```
azdw ai-mcp-server tools --help
```

```
Description:
  Manage MCP tool categories and list available tools

Usage:
  azdw ai-mcp-server tools [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  list    List all MCP tools with their full names and descriptions
  choose  Select which tool categories to enable interactively or non-interactively. Choices are saved for future use to reduce LLM context usage when using models with limited context windows.
  reset   Reset tool category selection to enable all tools (default behavior).

```

## Ai Mcp Server - Tools - List

```
azdw ai-mcp-server tools list --help
```

```
Description:
  List all MCP tools with their full names and descriptions

Usage:
  azdw ai-mcp-server tools list [options]

Options:
  --full-descriptions         Show full description text without truncation.
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Ai Mcp Server - Tools - Choose

```
azdw ai-mcp-server tools choose --help
```

```
Description:
  Select which tool categories to enable interactively or non-interactively. Choices are saved for future use to reduce LLM context usage when using models with limited context windows.

Usage:
  azdw ai-mcp-server tools choose [options]

Options:
  --categories, --category <CATEGORY-LIST>  Select one or more tool categories directly from the command line (comma-separated).
  --file <PATH>                             Load tool categories from a plain-text file with one category per line.
  --core-only                               Save a Core-only configuration without prompting.
  --list-categories                         List the category names that can be used with --categories/--category and exit.
  -?, -h, --help                            Show help and usage information
  -v, --verbose                             Enable verbose logging output
  --silent                                  Suppress informational messages, show only data output
  --full-traces                             Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>                       Force terminal color mode: auto (default), dark, or light.
  --force-unicode                           Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                             Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                                    Output in machine-readable JSON format (overrides --format when specified)
  --decode-values                           Decode HTML entities in field values for readable output
  --remove-html-tags                        Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                              Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification                Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins                  Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                             Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                            Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names                       Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check                       Skip checking for a newer version on startup
  --no-caching                              Disable all caching for the entire program runtime

```

## Ai Mcp Server - Tools - Reset

```
azdw ai-mcp-server tools reset --help
```

```
Description:
  Reset tool category selection to enable all tools (default behavior).

Usage:
  azdw ai-mcp-server tools reset [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Ai Chat

```
azdw ai-chat --help
```

```
Description:
  Interactive AI-powered chat for Azure DevOps work item management.

Usage:
  azdw ai-chat [command] [options]

Options:
  -r, --record                  Record chat transcript to ~/.azdw/chats/ directory
  --choose-tools                Interactively select which tool categories to enable. Useful for LLMs with limited context windows.
  --reset-tools                 Reset tool category selection to enable all tools.
  --show-thoughts               Show LLM reasoning/thoughts while processing (displayed temporarily in gray until the answer streams in).
  --persist                     Persist session state to disk so it can be resumed via --continue-last-session. Cannot be combined with --temporary-chat (mutually exclusive).
  --exit-chat                   Process one user input and exit. Use with --prompt-text or --prompt-file for automation. Combine with --temporary-chat for an ephemeral single-turn run, or with --persist (or leave unset, since persistence is on by default) to save session state for --continue-last-session.
  --prompt-file <FILE>          Read the initial prompt from a file. Useful for long or multi-line prompts. Supports {{query}}, {{1}}, {{2}} placeholders (use --prompt-args to supply values).
  --prompt-args <ARGS>          Arguments to substitute into prompt file placeholders ({{query}} for full string, {{1}}/{{2}}/... for positional). Shell-style quoting supported.
  --prompt-text <TEXT>          Initial user message text. Useful for single-turn queries without creating a prompt file. Cannot be combined with --prompt-file.
  --continue-last-session       Continue the previous chat session. Sessions are auto-saved after each AI response, so you can resume after any interruption.
  --continue-session <SESSION>  Continue a specific chat session by name (see 'azdw ai-chat session list').
  --workspace-root <DIR>        Workspace root directory for file I/O operations. Defaults to the current working directory. Sets the scope for file reads/writes and the unsafe workspace warning.
  --skip-model-checks           Skip LLM capability verification at startup for faster initialization. Use when you're confident your model configuration is correct.
  --auto-approve <LEVEL>        Auto-approve tool operations up to and including this risk level. Valid values: low, medium, high. Critical operations always require explicit approval.
  --webui                       Start the AI Chat Web UI in a browser instead of the terminal TUI.
  --port <port>                 Port for the embedded web server (default: 5280). Only applies when --webui is set. [default: 5280]
  --no-browser                  Suppress automatic browser opening when starting the web UI.
  --temporary-chat              Start an ephemeral session: no history persistence, and connection toggles are session-scoped.
  --no-suggestions              Disable follow-up suggestion generation in AI responses. Overrides the 'followUpSuggestions' defaults setting.
  --no-skills                   Disable Agent Skill discovery and activation for this session.
  -?, -h, --help                Show help and usage information
  -v, --verbose                 Enable verbose logging output
  --silent                      Suppress informational messages, show only data output
  --full-traces                 Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>           Force terminal color mode: auto (default), dark, or light.
  --force-unicode               Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii                 Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                        Output in machine-readable JSON format (overrides --format when specified)
  --decode-values               Decode HTML entities in field values for readable output
  --remove-html-tags            Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                  Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification    Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins      Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>                 Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown                Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names           Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check           Skip checking for a newer version on startup
  --no-caching                  Disable all caching for the entire program runtime

Commands:
  session  Manage persisted ai-chat sessions.

Examples:
  azdw ai-chat                                    Start interactive chat session
  azdw ai-chat --record                           Record transcript to ~/.azdw/chats/
  azdw ai-chat --workspace-root ./myproject       Set workspace root directory
  azdw mcp tools choose                       Select tool categories (for smaller LLMs)
  azdw ai-chat --verbose                          Show diagnostic output
  azdw ai-chat --exit-chat --prompt-text 'List epics'   Single query mode (saves session state)
  azdw ai-chat --exit-chat --prompt-file prompt.md      Single query mode from file
  azdw ai-chat --temporary-chat --exit-chat --prompt-text 'List epics'   Single query, ephemeral (no persistence)
  azdw ai-chat --prompt-file prompt.md --prompt-args 'Sprint 42'    Prompt file with arguments

Note:
  Prerequisites:
    1. Configure AI provider: azdw config ai set --provider ollama --model gemma4:12b
    2. Test configuration:    azdw config ai test
    3. Set up connection:     azdw connection add
  
  Workspace context:
    Place an AGENTS.md file in your workspace root to provide project-specific
    context (tech stack, conventions, terminology) to the AI. It is automatically
    discovered and injected into every chat session. Review an example under
    '<azdwInstallDir>/config/ai/AGENTS-example.md' or install a starter template
    with:
    azdw config ai skills install
```

## Ai Chat - Session

```
azdw ai-chat session --help
```

```
Description:
  Manage persisted ai-chat sessions.

Usage:
  azdw ai-chat session [command] [options]

Options:
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

Commands:
  list, ls    List available ai-chat sessions.
  activate    Set a session as the '--continue-last-session' target.
  delete, rm  Delete one or more persisted ai-chat sessions.
  refresh     Generate an AI-derived description for sessions that still have the default 'Session' name (e.g. after migrating older sessions).

```

## Ai Chat - Session - List

```
azdw ai-chat session list --help
```

```
Description:
  List available ai-chat sessions.

Usage:
  azdw ai-chat session list [options]

Options:
  --format <FORMAT>           Output format (table, json, yaml) [default: table]
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Ai Chat - Session - Activate

```
azdw ai-chat session activate --help
```

```
Description:
  Set a session as the '--continue-last-session' target.

Usage:
  azdw ai-chat session activate [options]

Options:
  -n, --name <name>           Name of the session to activate. If omitted in an interactive terminal, an interactive picker is shown.
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Ai Chat - Session - Delete

```
azdw ai-chat session delete --help
```

```
Description:
  Delete one or more persisted ai-chat sessions.

Usage:
  azdw ai-chat session delete [options]

Options:
  -n, --name <name>           Name of a single session to delete. If omitted in an interactive terminal, an interactive multi-select picker is shown.
  --all                       Delete all persisted sessions.
  -y, --yes                   Skip confirmation prompts
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Ai Chat - Session - Refresh

```
azdw ai-chat session refresh --help
```

```
Description:
  Generate an AI-derived description for sessions that still have the default 'Session' name (e.g. after migrating older sessions).

Usage:
  azdw ai-chat session refresh [options]

Options:
  -n, --name <name>           Name of a single session to refresh.
  --all                       Refresh every session that still has the default name. Combine with --force to also regenerate already-titled sessions.
  --force                     Regenerate the description even if the session already has a custom (non-default) name.
  -y, --yes                   Skip confirmation prompts
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

## Update

```
azdw update --help
```

```
Description:
  Check for and apply available product updates

Usage:
  azdw update [options]

Options:
  --force                     Re-download and reinstall even if already on the latest version
  --check                     Check for an available update without downloading
  --verbose                   Output detailed diagnostic information during the update
  --check-cert                Validate the server certificate issuer before downloading. Disabled by default to work in environments with TLS-intercepting corporate proxies
  --silent-install            Suppress all interactive prompts in the installer and skip connection/credential setup. Implied when the global --silent option is used.
  -?, -h, --help              Show help and usage information
  -v, --verbose               Enable verbose logging output
  --silent                    Suppress informational messages, show only data output
  --full-traces               Enable detailed execution tracing with secure parameter logging
  --color-mode <MODE>         Force terminal color mode: auto (default), dark, or light.
  --force-unicode             Force Unicode rendering (rounded borders, emoji) even when output is redirected to a file or pipe
  --force-ascii               Force pure-ASCII rendering (plain borders, no emoji) even on Unicode-capable terminals
  --json                      Output in machine-readable JSON format (overrides --format when specified)
  --decode-values             Decode HTML entities in field values for readable output
  --remove-html-tags          Remove HTML tags from field values for plain text output (implies --decode-values)
  --no-plugins                Disable plugin loading (useful for testing and troubleshooting)
  --skip-plugin-verification  Skip plugin security verification (WARNING: security risk, use only in trusted environments)
  --allow-unsigned-plugins    Allow loading plugins without valid Authenticode signatures (requires user approval for new plugins)
  --lang <CODE>               Set UI language using ISO culture code (e.g., de-DE, fr-FR). [default: en-US]
  --raw-markdown              Output markdown as plain text instead of formatted console output (for AI-generated content)
  --use-display-names         Use display names instead of short names for virtual types (e.g., 'Customer Requirement' instead of 'CustReq')
  --skip-update-check         Skip checking for a newer version on startup
  --no-caching                Disable all caching for the entire program runtime

```

