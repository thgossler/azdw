# Getting Started

This guide is the fastest end-user path for installing azdw, connecting it to
Azure DevOps, running a first query, and optionally using the browser-based AI
chat.

## 1. Install azdw

Download the installer for your platform from the GitHub Releases page:

- Windows x64 or ARM64: `azdw-Installer.exe`
- macOS Intel or Apple Silicon: `azdw-Installer.app` or `azdw-Installer`
- Linux x64 or ARM64: `azdw-Installer`

Run the installer and then open a new terminal.

Verify the installation:

```bash
azdw --info
azdw --help
```

## 2. Add an Azure DevOps Connection

For PAT-based authentication:

```bash
azdw connection add \
  --name MyOrg \
  --url https://dev.azure.com/myorganization
```

If you prefer OAuth instead of PATs, use `--auth-type code` for Device Code Flow
or `--auth-type interactive` for browser sign-in. See
[Authentication Types](Authentication-Types.md) for the full matrix.

## 3. Add Credentials

Recommended PAT flow:

```bash
azdw credential add --connection MyOrg --auth-type pat
```

OAuth examples:

```bash
azdw credential add --connection MyOrg --auth-type code --tenant your-tenant-id-or-name
azdw credential add --connection MyOrg --auth-type interactive --tenant your-tenant-id-or-name
```

## 4. Run Your First Query

```bash
azdw query \
  --connections MyOrg \
  --types Epic \
  --limit 5 \
  --output table
```

That confirms your connection, credentials, and permissions are working.

## 5. Optional: Launch the Browser-Based Web UI

The AI chat can run in a browser-based progressive web app instead of the
terminal UI:

```bash
azdw ai-chat --webui
```

The command starts an embedded localhost web server, opens your default browser,
and streams responses in real time. For more Web UI details, see
[AI Features Overview](AI-Features-Overview.md).

## 6. Useful Next Steps

- Enable shell integration: `azdw config shell-integration`
- Check updates: `azdw update --check`
- Read common scenarios: [CLI Use Cases](CLI-Use-Cases.md)
- Review permissions: [Azure DevOps Permissions](Azure-DevOps-Permissions.md)
- Explore configuration: [Configuration Guide](../config/README.md)

## Troubleshooting Checklist

- If connection checks fail, verify the organization URL and your Azure DevOps
  access level.
- If queries fail with permission errors, review the PAT scopes and project
  permissions in [Azure DevOps Permissions](Azure-DevOps-Permissions.md).
- If OAuth sign-in is blocked in your environment, use PAT or a direct AI model
  configuration instead of GitHub Copilot SDK.
