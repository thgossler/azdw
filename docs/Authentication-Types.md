---
title: Authentication Types
nav_order: 20
---



azdw supports three authentication methods for Azure DevOps, each optimized for different scenarios.

## Overview

| Auth Type | Flag | Best For | Interactive | Requires Browser |
| --------- | ----- | -------- | ----------- | --------------- |
| PAT | `--auth-type pat` | Simple, direct access | Yes (token entry) | No |
| Device Code | `--auth-type code` | Headless/CI scenarios | Yes (code entry) | Yes (separate device) |
| Interactive Browser | `--auth-type interactive` | Desktop scenarios | No (browser opens) | Yes (same device) |

> **🚀 Quick Tip:** For fastest onboarding with multiple connections, use the [Automated Connection Setup](#automated-connection-setup) feature!

## 1. PAT (Personal Access Token)

### Description
Uses a Personal Access Token generated from Azure DevOps settings. The token is stored securely in an encrypted local file.

### When to Use
- Quick setup and testing
- Automation scripts on trusted machines
- Scenarios where OAuth is not available
- Single organization access

### Requirements
- A valid PAT from Azure DevOps with appropriate scopes
- No Entra ID tenant ID required

> 📹 **New to PATs?** Watch [How to create a Personal Access Token in Azure DevOps](https://tinyurl.com/ado-create-pat) for a quick step-by-step walkthrough.

### Required PAT Scopes

When creating a PAT in Azure DevOps (User Settings → Personal Access Tokens), you must select the appropriate scopes:

#### Minimum Required Scopes (Read-Only Operations)
- ✅ **Work Items: Read** - Required for all query and metadata operations
- ✅ **Project and team: Read** - Required for project information and work item types

#### Additional Scopes for Full Functionality
- ✅ **Work Items: Write** - Required for creating and updating work items
- ⚠️ **Build: Read** (optional) - If working with work items linked to builds
- ⚠️ **Release: Read** (optional) - If working with work items linked to releases

#### What Each Scope Enables

**Work Items (Read)** allows:
- Execute WIQL queries to find work items
- Retrieve work item details and fields
- Access work item type metadata
- Get field definitions and allowed values
- Retrieve work item state information
- Read work item relationships

**Work Items (Write)** allows:
- Create new work items
- Update existing work item fields
- Manage work item relationships
- Change work item states
- Add/remove tags and links

**Project and team (Read)** allows:
- List projects in the organization
- Access project-specific metadata
- Required for project-scoped operations
- Get team and area path information

### User Account Requirements

In addition to PAT scopes, your user account needs:

1. **Basic Access Level** (minimum)
   - **Stakeholder access is insufficient** for azdw functionality
   - Contact your organization admin to upgrade if needed

2. **Organization Membership**
   - Must be a member (not just guest) of the Azure DevOps organization
   - Can be invited as a member with Basic access

3. **Project Permissions** (if accessing specific projects)
   - **View work items** permission for read operations
   - **Edit work items** permission for create/update operations

### GitHub & GitHub Enterprise PAT Permissions

For **GitHub.com**, **GitHub Enterprise Cloud** (`*.ghe.com`), and **GitHub
Enterprise Server** connections, azdw uses a GitHub Personal Access Token. GitHub
issues are the equivalent of Azure DevOps work items.

**Fine-grained personal access token (recommended):**
- ✅ **Repository → Issues: Read and write** — read, create, and update issues
  (use **Read** only for read-only usage)
- ✅ **Repository → Metadata: Read** — mandatory baseline (auto-selected);
  resolves repositories and milestones
- ✅ **Account → Email addresses: Read** — detect your primary verified email for
  identity/assignment

**Personal access token (classic):**
- ✅ **`repo`** — read/write issues in private and public repositories (use
  **`public_repo`** for public-only repositories)
- ⚠️ **`read:org`** (optional) — only needed to enumerate org-owned repositories
  for an org-level connection
- ✅ **`user:email`** — read your email addresses for identity detection

> Prefer fine-grained tokens scoped to just the repositories your connection
> uses. For the full permission matrix, setup steps, and troubleshooting, see
> [GitHub & GitHub Enterprise Permissions](GitHub-Permissions.md).

### Usage

```bash
# Interactive (recommended - prompts for token)
azdw credential add --connection MyOrg --auth-type pat

# Direct (token provided as argument)
azdw credential add-pat --connection MyOrg --token your-pat-token
```

### Advantages
- ✅ Simple to set up
- ✅ No Entra ID configuration required
- ✅ Works in any environment
- ✅ No browser needed
- ✅ Fine-grained scope control

### Disadvantages
- ⚠️ Token must be manually renewed when expired
- ⚠️ Limited to PAT permissions and scopes
- ⚠️ Not ideal for multi-tenant scenarios
- ⚠️ Must manage separate tokens per organization

### PAT Security Best Practices

1. **Use Minimum Required Scopes**
   - Start with read-only scopes for testing
   - Add write scopes only when needed
   - Avoid "Full access" scopes

2. **Set Appropriate Expiration**
   - Use 30-90 day expiration for security
   - Set calendar reminders before expiration
   - Rotate tokens regularly

3. **Token Management**
   - Use descriptive names (e.g., "azdw-readonly-2025-Q1")
   - Never commit tokens to source control
   - Store tokens securely (azdw encrypts them locally)
   - Consider separate tokens for different purposes

## 2. Device Code Flow (OAuth2)

### Description
Uses OAuth2 Device Code Flow where the application displays a code that you enter on a separate device or browser. This is ideal for headless environments or CI/CD pipelines.

### When to Use
- Headless servers or containers
- CI/CD pipelines
- SSH sessions without browser access
- Multi-tenant scenarios
- When you need to authenticate from a different device

### Requirements
- Entra ID tenant ID or name
- Browser access (can be on a different device)
- Internet connectivity

### Usage

```bash
# Using generic add command
azdw credential add \
  --connection MyOrg \
  --auth-type code \
  --tenant your-tenant-id-or-name

# Using specific command
azdw credential add-oauth \
  --connection MyOrg \
  --tenant your-tenant-id-or-name \
  [--headless]
```

### Flow
1. CLI displays a device code and URL
2. User navigates to the URL (can be on any device)
3. User enters the device code
4. User completes authentication in the browser
5. CLI receives the OAuth token
6. Token is stored securely with automatic refresh

### Advantages
- ✅ Works in headless environments
- ✅ Automatic token refresh
- ✅ Multi-tenant support
- ✅ Can authenticate from different device
- ✅ More secure than PAT (supports MFA)

### Disadvantages
- ⚠️ Requires manual code entry
- ⚠️ Requires Entra ID tenant ID
- ⚠️ Slightly more complex initial setup

## 3. Interactive Browser (OAuth2)

### Description
Uses OAuth2 Interactive Browser Flow where a browser window automatically opens for sign-in. This provides the smoothest authentication experience for desktop scenarios.

### When to Use
- Local development on desktop/laptop
- Workstations with GUI and browser
- Best user experience for interactive sessions
- Multi-tenant scenarios

### Requirements
- Entra ID tenant ID or name
- Browser access on the same device
- Desktop environment (not headless)
- Internet connectivity

### Usage

```bash
# Using generic add command
azdw credential add \
  --connection MyOrg \
  --auth-type interactive \
  --tenant your-tenant-id-or-name

# Using specific command
azdw credential add-interactive \
  --connection MyOrg \
  --tenant your-tenant-id-or-name
```

### Flow
1. CLI triggers browser to open automatically
2. User completes authentication in the browser
3. Browser redirects back to the application
4. CLI receives the OAuth token
5. Token is stored securely with automatic refresh

### Advantages
- ✅ Smoothest user experience
- ✅ No code copying required
- ✅ Automatic token refresh
- ✅ Multi-tenant support
- ✅ More secure than PAT (supports MFA)
- ✅ Single sign-on support

### Disadvantages
- ⚠️ Requires browser on same device
- ⚠️ Not suitable for headless environments
- ⚠️ Requires Entra ID tenant ID

## Comparison Table

| Feature | PAT | Device Code | Interactive Browser |
| -------- | ---- | ----------- | ----------------- |
| Token expiration | Manual renewal (1-365 days) | Auto-refresh (~1 hr access, ~90 days refresh) | Auto-refresh (~1 hr access, ~90 days refresh) |
| Long-running operations | ⚠️ May fail if PAT expires | ✅ Seamless (auto-refresh) | ✅ Seamless (auto-refresh) |
| User intervention needed | Every 1-365 days | Every ~90 days | Every ~90 days |
| Multi-tenant support | ❌ | ✅ | ✅ |
| Multi-factor auth | Limited | ✅ | ✅ |
| Headless environments | ✅ | ✅ | ❌ |
| Desktop GUI required | ❌ | ❌ | ✅ |
| Setup complexity | Low | Medium | Medium |
| Security | Medium | High | High |
| User experience | Medium | Medium | High |

## Examples

### Example 1: Local Development (Interactive Browser)

```bash
# Best for developers on their workstation
azdw credential add-interactive \
  --connection contoso \
  --tenant 12345678-1234-1234-1234-123456789012
```

### Example 2: CI/CD Pipeline (Device Code)

```bash
# Best for automated builds with manual approval
azdw credential add-oauth \
  --connection contoso \
  --tenant 12345678-1234-1234-1234-123456789012 \
  --headless
```

### Example 3: Quick Testing (PAT)

```bash
# Best for quick tests and simple scenarios
azdw credential add-pat \
  --connection contoso \
  --token dGhpcyBpcyBhIGZha2UgdG9rZW4=
```

## Token Expiration & Refresh

Understanding token expiration helps you choose the right authentication method and avoid interruptions during long-running operations.

### PAT (Personal Access Token) Expiration

**Expiration Behavior:**
- PATs **do not expire automatically** in azdw's local storage
- However, PATs **do expire** on Azure DevOps based on the expiration date you set when creating them
- You must **manually renew** expired PATs in Azure DevOps and update credentials in azdw

**Setting Expiration:**
When creating a PAT in Azure DevOps (User Settings → Personal Access Tokens):
- Choose an expiration period: 1 day, 30 days, 60 days, 90 days, or custom (up to 1 year)
- **Recommendation:** Use shorter expiration periods (30-90 days) for better security
- Set calendar reminders before expiration to renew the PAT

**Renewal Process:**
```bash
# When your PAT expires, update it with a new one:
azdw credential add-pat --connection MyOrg --token <new-pat-token>
```

**Best For:**
- ✅ Short-term testing (1-30 days)
- ✅ Quick automation scripts
- ⚠️ Not ideal for long-running operations (requires manual renewal)


### OAuth Token Expiration (Device Code & Interactive Browser)

**Expiration Behavior:**
- **Access tokens** expire after approximately **1 hour** (managed by Microsoft Entra ID)
- **Refresh tokens** remain valid for approximately **90 days** (managed by Microsoft Entra ID)
- azdw **automatically refreshes** access tokens when they expire using the refresh token
- **Proactive refresh**: Tokens are refreshed **5 minutes before** expiration to prevent interruptions
- **Completely transparent**: You won't notice token refreshes happening in the background

**What This Means for You:**
- ✅ **No manual intervention required** for up to 90 days
- ✅ **Long-running operations work seamlessly** (hours or days)
- ✅ **Automatic re-authentication** as long as refresh token is valid
- ⚠️ After 90 days of inactivity, you'll need to sign in again

**Re-authentication After 90 Days:**
If your refresh token expires (typically after 90 days), simply run the credential add command again:
```bash
# Device Code Flow
azdw credential add --connection MyOrg --auth-type code --tenant <tenant-id-or-name>

# Interactive Browser
azdw credential add --connection MyOrg --auth-type interactive --tenant <tenant-id-or-name>
```

**Best For:**
- ✅ Long-running operations (hours, days, weeks)
- ✅ Daily development work (set it and forget it)
- ✅ CI/CD pipelines running frequently


### Choosing Authentication Method Based on Token Lifetime

| Scenario | Recommended Method | Why |
| --------- | ---------------- | ---- |
| Quick one-time query | PAT (30 days) | Simplest setup, adequate lifetime |
| Daily development work | Interactive Browser | Auto-refresh, 90-day validity, best UX |
| Long-running data exports | OAuth (any) | Automatic refresh prevents interruptions |
| CI/CD running multiple times per day | Device Code | Auto-refresh, 90-day validity, CI-friendly |
| Infrequent automation (monthly) | PAT (90 days) | Simple, manual renewal acceptable |
| Production services | OAuth + automated re-auth | Best security, automated token management |


### Token Expiration FAQ

**Q: How do I know when my token will expire?**
- **PAT:** Check Azure DevOps → User Settings → Personal Access Tokens to see expiration dates
- **OAuth:** Access tokens refresh automatically; you'll be prompted to re-authenticate after ~90 days of inactivity

**Q: What happens if my token expires during a long-running operation?**
- **PAT:** Operation will fail with authentication error; you'll need to renew and restart
- **OAuth:** Token is automatically refreshed in the background; operation continues seamlessly

**Q: Can I extend OAuth token lifetime beyond 90 days?**
- Token lifetimes are managed by Microsoft Entra ID and cannot be controlled by azdw
- For continuous operations, ensure your automation runs at least once every 90 days
- Consider using Azure Managed Identities or Service Principals for production scenarios

**Q: Why did I get re-authenticated even though I used azdw yesterday?**
- Access tokens expire after ~1 hour, but azdw automatically refreshes them
- If you see a re-authentication prompt, your refresh token likely expired (~90 days)
- This is normal security behavior to ensure credentials aren't valid indefinitely

**Q: Should I use PAT or OAuth for CI/CD?**
- **OAuth Device Code** is recommended for better security and automatic refresh
- **PAT** is acceptable if your CI/CD runs frequently enough to detect expiration before issues arise
- Always use short-lived PATs (30-90 days) and automate renewal in CI/CD if using PAT


## Security Best Practices

1. **Use OAuth (Device Code or Interactive) over PAT when possible**
   - Better security with MFA support
   - Automatic token refresh (no manual renewal)
   - Centralized access management

2. **Protect your credentials**
   - Never commit PATs to source control
   - Use environment variables or secure vaults in CI/CD
   - Regularly rotate PATs if you must use them

3. **Minimum permissions (PAT-specific)**
   - **Start with read-only scopes**: Work Items (Read) + Project and team (Read)
   - **Add write scopes only when needed**: Work Items (Write) for create/update operations
   - **Avoid "Full access" or "All scopes"** - use specific scopes only
   - **Use separate PATs for different purposes** (read-only vs. read-write)

4. **Access Level Requirements**
   - Ensure **Basic access level** (minimum) - Stakeholder access is insufficient
   - Verify **organization membership** (not just guest access)
   - Request appropriate **project permissions** from project admins

5. **Multi-connection security**
   - Use **separate PATs per connection** for isolation
   - Consider **OAuth for better security** in multi-org scenarios
   - **Regularly audit access** across organizations

6. **Environment-specific choices**
   - Development: Interactive Browser (auto-refresh, best UX)
   - CI/CD: Device Code (auto-refresh, CI-friendly)
   - Testing: PAT with read-only scopes (short-lived, 30 days max)
   - Production: OAuth with automated re-authentication

## Troubleshooting

### PAT Authentication Issues
- **Verify the token hasn't expired** in Azure DevOps Personal Access Tokens page
- **Check the token has correct scopes**:
  - Minimum: Work Items (Read) + Project and team (Read)
  - For create/update: Add Work Items (Write)
- **Verify user account has Basic access level** (not Stakeholder)
- **Ensure organization membership** (not just guest access)
- **Check project-level permissions** if accessing specific projects
- **Ensure the organization name is correct** in the connection URL

### Device Code Flow Issues
- Verify tenant ID is correct
- Check you're using the correct device code URL
- Ensure you have permissions in the Entra ID tenant
- Try clearing cached credentials with `azdw credential clear`

### Interactive Browser Issues
- Ensure browser can open on the system
- Check no firewall blocking localhost redirect
- Verify tenant ID is correct
- Try using Device Code as alternative

## Automated Connection Setup

For rapid onboarding with multiple connections, azdw provides a fully automated setup feature using MSAL (Microsoft Authentication Library) and Azure DevOps PAT Creation API.

### How It Works

The automated setup combines the best of both worlds:
1. **Interactive Browser Authentication** via MSAL for secure OAuth sign-in
2. **Programmatic PAT Token Creation** via Azure DevOps REST API
3. **Automatic Connection Configuration** with the generated PAT tokens

This eliminates manual token creation while maintaining security and ease of use.

### Quick Start

1. **Create configuration file:**
   ```bash
   cp config/connection-setup-example.jsonc config/connection-setup.jsonc
   # Edit with your organizations and tenant IDs
   ```

2. **Run initialization with automated setup:**
   ```bash
   # Linux/macOS
   ./init.sh -SetupConnections
   
   # Windows
   .\init.cmd -SetupConnections
   ```

### Configuration Format

Create a `connection-setup.jsonc` file in the config folder under the repository root:

```json
{
  "connections": [
    {
      "name": "MyOrg",
      "url": "https://dev.azure.com/myorganization",
      "tenantId": "your-tenant-id.onmicrosoft.com",
      "description": "Main organization",
      "validityDays": 365
    },
    {
      "name": "PartnerOrg",
      "url": "https://dev.azure.com/partnerorg",
      "tenantId": "partner-tenant-id.onmicrosoft.com",
      "description": "Partner organization",
      "validityDays": 180
    }
  ],
  "validation": {
    "queryTypes": ["User Story", "Bug"],
    "queryLimit": 5
  }
}
```

### Configuration Fields

- **`name`** (required) - Connection name for azdw
- **`url`** (required) - Azure DevOps organization URL
- **`tenantId`** (required) - Microsoft Entra ID tenant ID or domain name (e.g., `contoso.onmicrosoft.com`)
- **`description`** (optional) - Description for the generated PAT token
- **`validityDays`** (optional) - Token validity period in days (default: 365, maximum: 365)

### What Gets Automated

✅ **Fully Automated:**
- Installation of MSAL.PS PowerShell module (if not present)
- Interactive browser sign-in via MSAL
- PAT token creation via Azure DevOps REST API
  - Auto-generated name: `azdw - yyyy-MM-dd HH:mm:ss`
  - Maximum expiration period (configurable)
  - Required scopes: Work Items (Read & Write), Project (Read)
- Connection configuration with generated PAT
- Connection verification via `azdw connection list`
- Query testing to confirm functionality

### Technical Details

**Azure DevOps PAT Creation API:**
- Endpoint: `POST https://vssps.dev.azure.com/{org}/_apis/tokens/pats?api-version=7.1-preview.1`
- Requires: OAuth token with scope `499b84ac-1321-427f-aa17-267ca6975798/.default`
- Returns: PAT token with specified scopes and expiration

**MSAL Configuration:**
- Client ID: `499b84ac-1321-427f-aa17-267ca6975798` (Azure DevOps Service)
- Authentication: Interactive browser flow
- Module: MSAL.PS (PowerShell wrapper for MSAL.NET)

**Generated PAT Token:**
- Scopes: `vso.work_write` (Work Items Read & Write), `vso.project` (Project Read)
- Validity: Configurable (default: 365 days)
- Name format: `azdw - yyyy-MM-dd HH:mm:ss`
- Storage: Encrypted locally by azdw

### Benefits

- **Zero Manual Steps**: No need to visit Azure DevOps portal to create tokens
- **Multi-Connection Support**: Set up dozens of connections in minutes
- **Automatic Verification**: Script validates each connection and tests queries
- **Consistent Configuration**: Share `connection-setup.jsonc` templates across teams
- **Onboarding Acceleration**: New team members productive immediately
- **Secure**: Uses OAuth + encrypted local storage, no tokens in configuration files

### Requirements

- PowerShell 5.1 or later
- MSAL.PS module (auto-installed)
- Microsoft Entra ID account with access to Azure DevOps organizations
- Internet connection for MSAL authentication

### Best Practices

1. **Keep `connection-setup.jsonc` out of version control** (it may contain secrets)
2. **Create organization-specific templates** for easy team onboarding
3. **Use descriptive connection names** to identify organizations easily
4. **Set appropriate validity periods** based on security requirements
5. **Document tenant IDs** in secure team documentation
6. **Rotate tokens regularly** by re-running the setup periodically

### Troubleshooting

**MSAL.PS module installation fails:**
```powershell
# Manual installation
Install-Module -Name MSAL.PS -Scope CurrentUser -Force
```

**Authentication fails:**
- Verify tenant ID is correct
- Ensure your account has access to the Azure DevOps organization
- Check that multi-factor authentication (if required) is completed

**PAT creation fails:**
- Ensure you have Basic or higher access level (not Stakeholder)
- Verify you're a member (not guest) of the organization
- Check organization policies don't restrict PAT creation

**Connection validation fails:**
- Verify the organization URL is correct
- Ensure network connectivity to Azure DevOps
- Check firewall settings aren't blocking access

## See Also

- [Azure DevOps PAT Documentation](https://docs.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
- [OAuth 2.0 Device Code Flow](https://oauth.net/2/device-flow/)
- [Microsoft Identity Platform](https://docs.microsoft.com/azure/active-directory/develop/)
