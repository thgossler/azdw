---
title: Azure DevOps Permissions
nav_order: 30
---

# Azure DevOps Permissions

This document outlines the minimum permissions required for azdw to function properly with Azure DevOps.

> **Using GitHub or GitHub Enterprise instead?** See
> [GitHub & GitHub Enterprise Permissions](GitHub-Permissions.md) for the equivalent
> classic and fine-grained personal access token permissions.

## Quick Reference

### PAT Token Scopes

| Feature | Required Scopes (OAuth Scope Names) |
|---------|-------------------------------------|
| **Query work items (WIQL)** | Work Items (Read & Write) [`vso.work_write`] + Project and Team (Read) [`vso.project`] |
| **Create/update work items** | Work Items (Read & Write) [`vso.work_write`] + Project and Team (Read) [`vso.project`] |
| **Cross-org relationships** | Same scopes on all organizations |
| **File content extraction** (`--resolve-file-content`) | Code (Read) [`vso.code`] - Required to fetch Git file contents for field extraction |

> **Note:** Azure DevOps does not have separate "Read", "Write", and "Manage" scopes for Work Items. The actual scopes are:
> - **Work Items (Read)** = `vso.work` - Read-only access
> - **Work Items (Read & Write)** = `vso.work_write` - Read, create, update, execute WIQL queries
> - **Code (Read)** = `vso.code` - Read source code and metadata (required for `--resolve-file-content`)

### User Access Requirements

- **Access Level**: Basic (minimum) - Stakeholder access is insufficient
- **Organization**: Must be a member (not guest) of Azure DevOps organization
- **Project Permissions**: View/Edit work items as needed

## Detailed Permission Requirements

### Query Operations (WIQL Queries, Metadata)

**Required PAT Scopes:**
- ✅ **Work Items (Read & Write)** [`vso.work_write`] - Execute WIQL queries, read work items
- ✅ **Project and Team (Read)** [`vso.project`] - Access project metadata for validation

**Why "Read & Write" is required for queries:**
According to the [official Azure DevOps REST API documentation](https://learn.microsoft.com/en-us/rest/api/azure/devops/wit/work-items/create), the `vso.work_write` scope grants the ability to:
> "read, create, and update work items and queries, update board metadata, read area and iterations paths other work item tracking related metadata, **execute queries**, and to receive notifications about work item events via service hooks."

WIQL query execution (`POST /_apis/wit/wiql`) requires the `vso.work_write` scope, not just `vso.work` (read-only).

**API Endpoints Used:**
- `POST /_apis/wit/wiql` - Execute WIQL queries (**requires `vso.work_write`**)
- `GET /_apis/wit/workitems` - Get work item details (requires `vso.work_write`)
- `GET /_apis/wit/workitemtypes` - Get work item type metadata (requires `vso.work_write`)
- `GET /_apis/wit/fields` - Get field definitions (requires `vso.work_write`)
- `GET /_apis/projects` - Get project information (requires `vso.project` or `vso.profile`)

**User Requirements:**
- Basic access level (minimum)
- View work items permission in target projects

### Write Operations (Create, Update)

**Required PAT Scopes:**
- ✅ **Work Items (Read & Write)** [`vso.work_write`] - Create and modify work items
- ✅ **Project and Team (Read)** [`vso.project`] - Access project metadata

**API Endpoints Used:**
- `POST /_apis/wit/workitems/${type}` - Create new work items
- `PATCH /_apis/wit/workitems/{id}` - Update existing work items

**User Requirements:**
- Basic access level (minimum)
- Create/Edit work items permission in target projects

### Cross-Connection Operations

**Requirements:**
- Separate PAT or OAuth credentials for each organization
- Same permission requirements apply to each organization
- User must be a member of all target organizations

## Setting Up PAT with Correct Scopes

1. **Navigate to Azure DevOps**
   - Go to https://dev.azure.com/[your-organization]
   - Click User Settings (profile icon) → Personal Access Tokens

2. **Create New Token**
   - Click "New Token"
   - Give it a descriptive name (e.g., "azdw-tool-2025")
   - Set expiration (30-90 days recommended)

3. **Select Scopes** (Custom Defined)
   - **For query and read operations:**
     - ✅ **Work Items**: Select **Read & Write** (this is required for WIQL queries, not just "Read")
     - ✅ **Project and Team**: Select **Read**
   
   - **For full functionality (same as above):**
     - ✅ **Work Items**: Select **Read & Write**
     - ✅ **Project and Team**: Select **Read**

   - **For file content extraction** (`--resolve-file-content`):
     - ✅ **Code**: Select **Read** (required to fetch Git file contents for extracting fields like ADR status)

4. **Copy Token**
   - Copy the generated token immediately
   - Store it securely (azdw will encrypt it locally)

## Common Permission Errors

### "Unauthorized" (401) or HTTP 302 Redirects to Sign-In Page
```
Error: Access denied to organization 'myorg'
```
or
```
Error: Authentication redirect detected. Azure DevOps returned 302.
```

**Possible Causes:**
- PAT token expired or invalid
- **PAT missing "Read & Write" scope for Work Items** (only has "Read")
- User not a member of the organization
- Stakeholder access level (insufficient)

**Solutions:**
- Check PAT expiration in Azure DevOps
- **Verify PAT has "Work Items (Read & Write)" scope, not just "Read"**
- Verify organization membership
- Request Basic access level from admin

### "Forbidden" (403)
```
Error: Access forbidden for operation
```

**Possible Causes:**
- Missing required PAT scopes
- No permission to specific project
- Trying to write without Write scope

**Solutions:**
- Add missing scopes to PAT
- Request project access from project admin
- Ensure PAT includes Work Items (Read & Write) for all operations

### "File content extraction fails" (401 with `--resolve-file-content`)
```
Failed to fetch file content from '...': HTTP 401 Unauthorized.
To use --resolve-file-content, your PAT requires 'Code (Read)' permission.
```

**Possible Causes:**
- PAT does not have "Code (Read)" scope
- Attempting to use `--resolve-file-content` without Git repository access

**Solutions:**
- Add **Code (Read)** scope to your PAT in Azure DevOps
- Navigate to User Settings → Personal Access Tokens → Edit → Add "Code (Read)"
- The Code scope is required to access Git repository content via the Azure DevOps REST API

### "Work item type not found"
```
Error: Work item type 'Epic' not found
```

**Possible Causes:**
- Missing "Project and team (Read)" scope
- No access to target project
- Project name incorrect

**Solutions:**
- Add "Project and team (Read)" to PAT
- Verify project name and access
- Check organization URL is correct

## Verification Commands

Test your permissions with these azdw commands:

```bash
# Test basic connectivity
azdw connection check --name MyOrg

# Test read permissions
azdw query --connections MyOrg --types Epic --limit 1

# Test metadata access
azdw metadata types --connection MyOrg

# Test project access
azdw metadata projects --connection MyOrg
```

## Best Practices

1. **Start with minimum scopes** (read-only) and add write permissions only when needed
2. **Use descriptive PAT names** that indicate purpose and expiration
3. **Set reasonable expiration dates** (30-90 days for security)
4. **Never commit PATs to source control** or share them
5. **Use separate PATs for different purposes** (read-only vs. read-write)
6. **Regularly audit and rotate tokens**

## OAuth Alternative

Consider using OAuth (Device Code Flow or Interactive Browser) instead of PAT for:
- Better security (MFA support, automatic refresh)
- Multi-tenant scenarios
- Long-running operations (no manual token renewal)

OAuth tokens inherit your user permissions, so no separate scope configuration is needed.

## See Also

- [Authentication Types Documentation](Authentication-Types.md)
- [Azure DevOps PAT Documentation](https://docs.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
- [Azure DevOps Permissions Reference](https://docs.microsoft.com/azure/devops/organizations/security/permissions)