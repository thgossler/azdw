---
title: Token Expiration Guide
nav_order: 50
---

# Token Expiration Guide

**Quick Reference:** Understanding when your authentication tokens expire and what to do about it.


## TL;DR - Choose Your Auth Method

| Your Situation | Use This | Token Lifetime | Manual Renewal Needed |
|----------------|----------|----------------|----------------------|
| Daily development work | Interactive Browser | ~90 days | Once every 3 months |
| Long-running data exports | Device Code or Interactive | ~90 days | Once every 3 months |
| Quick testing (one-time use) | PAT | Set when you create it (1-365 days) | Yes, when PAT expires |
| CI/CD pipeline (runs daily) | Device Code | ~90 days | Once every 3 months |
| Infrequent automation (monthly) | PAT | 30-90 days recommended | Yes, based on your setting |

**Bottom Line:** If you don't want to worry about token expiration, use **OAuth (Device Code or Interactive Browser)** – they auto-refresh for ~90 days.


## Detailed Expiration Behavior

### 1. PAT (Personal Access Token)

**What Expires:**
- The PAT itself expires on Azure DevOps based on the expiration date **you choose** when creating it
- azdw stores your PAT locally but doesn't track its expiration date
- You must manually renew the PAT in Azure DevOps before it expires

**Setting the Expiration:**
When you create a PAT in Azure DevOps (User Settings → Personal Access Tokens → New Token):
1. Choose expiration: 1 day, 30 days, 60 days, 90 days, or Custom (up to 1 year)
2. **Recommended:** 30-90 days for balance of security and convenience
3. Set a calendar reminder a few days before expiration

**What Happens When It Expires:**
```
❌ Authentication Error: The Personal Access Token has expired
💡 Solution: Create a new PAT in Azure DevOps and update azdw
```

**Renewal Steps:**
```bash
# 1. Create new PAT in Azure DevOps (https://dev.azure.com/your-org/_usersSettings/tokens)
# 2. Update azdw with the new token:
azdw credential add-pat --connection MyOrg --token <new-pat-token>
```


### 2. OAuth (Device Code & Interactive Browser)

**What Expires:**
- **Access tokens** expire after ~1 hour
- **Refresh tokens** expire after ~90 days of inactivity
- Both managed automatically by Microsoft Entra ID (you don't control the duration)

**How Auto-Refresh Works:**
```
You run a command
    ↓
azdw checks: "Is my access token expired or expiring soon?"
    ↓
YES → azdw automatically refreshes it using the refresh token (transparent to you)
    ↓
NO → azdw uses the existing access token
    ↓
Command executes normally
```

**Proactive Refresh:**
- azdw refreshes tokens **5 minutes before** they expire
- This prevents interruptions during long-running operations
- You never notice this happening – it's completely automatic

**What Happens After 90 Days:**
```
⚠️  Your refresh token has expired (no activity for ~90 days)
💡 Solution: Simply authenticate again with the same command you used originally
```

**Re-authentication:**
```bash
# Device Code Flow
azdw credential add --connection MyOrg --auth-type code --tenant <tenant-id-or-name>

# Interactive Browser
azdw credential add --connection MyOrg --auth-type interactive --tenant <tenant-id-or-name>
```


## Common Scenarios & Solutions

### Scenario 1: "I authenticated yesterday, why am I being asked again?"

**Likely Cause:** Your refresh token expired (~90 days since last use)

**Solution:** This is normal – just authenticate again. OAuth tokens don't last forever for security reasons.

```bash
# Re-run your original auth command
azdw credential add --connection MyOrg --auth-type interactive --tenant <tenant-id-or-name>
```


### Scenario 2: "My long-running export failed with an auth error"

**If using PAT:**
- Your PAT expired during the operation
- **Solution:** Use OAuth methods (Device Code/Interactive) for long-running operations

**If using OAuth:**
- Unlikely – tokens auto-refresh during operations
- Check your network connection and tenant permissions

```bash
# Switch to OAuth for long-running operations
azdw credential add --connection MyOrg --auth-type code --tenant <tenant-id-or-name>
```


### Scenario 3: "I want to avoid authentication prompts for 6 months"

**Bad News:** Not possible with any method for security reasons

**Best Option:** OAuth (Device Code/Interactive)
- Lasts ~90 days (3 months)
- Automatically handles hourly token refreshes
- One re-authentication every 3 months

**Why Not Longer:**
- Security best practice: credentials shouldn't be valid indefinitely
- Microsoft Entra ID enforces 90-day refresh token limit
- Encourages regular access reviews


### Scenario 4: "My CI/CD pipeline needs to run monthly – which auth method?"

**Option 1 (Recommended):** OAuth Device Code
- Auto-refreshes for 90 days
- One manual re-auth every 3 months
- More secure (supports MFA)

```bash
azdw credential add --connection MyOrg --auth-type code --tenant <tenant-id-or-name> --headless
```

**Option 2:** PAT with 90-day expiration
- Simpler for infrequent use
- Set calendar reminder to renew every 85 days
- Acceptable for trusted environments

```bash
# In your CI/CD, use environment variable
export AZDW_PAT="your-pat-token"
azdw credential add-pat --connection MyOrg --token "$AZDW_PAT"
```


## Token Lifetime Reference

| Token Type | Lifetime | Controlled By | Auto-Refresh | Manual Action Required |
|------------|----------|---------------|--------------|------------------------|
| PAT | 1-365 days (your choice) | You (when creating PAT) | ❌ No | ✅ Yes (renew in Azure DevOps) |
| OAuth Access Token | ~1 hour | Microsoft Entra ID | ✅ Yes (transparent) | ❌ No |
| OAuth Refresh Token | ~90 days | Microsoft Entra ID | ✅ Yes (until expires) | ✅ Yes (re-authenticate after 90 days) |


## Best Practices

### ✅ DO
- **Use OAuth** (Device Code/Interactive) for operations lasting > 1 hour
- **Set PAT expiration** to 30-90 days (not maximum 1 year)
- **Set calendar reminders** to renew PATs before expiration
- **Re-authenticate before critical operations** if you haven't used OAuth in 80+ days
- **Use environment variables** for PATs in CI/CD (never hardcode)

### ❌ DON'T
- Don't use PATs with 1-year expiration (security risk)
- Don't commit PATs to source control (use secure vaults)
- Don't ignore authentication errors (they indicate expired credentials)
- Don't use PATs for long-running operations (use OAuth instead)
- Don't expect OAuth to last > 90 days (plan for quarterly re-auth)


## Troubleshooting

### "Error: Authentication failed"

**Check:**
1. Is your PAT expired? → Create new PAT and update azdw
2. Is your OAuth refresh token expired? → Re-authenticate with same command
3. Network issues? → Check internet connectivity and firewall
4. Wrong tenant ID? → Verify tenant ID in Azure Portal

### "Error: Token refresh failed"

**Causes:**
- Network connectivity issues during refresh
- Refresh token expired (90+ days)
- Azure Entra ID policy changed (requires re-authentication)

**Solution:**
```bash
# Re-authenticate from scratch
azdw credential remove --connection MyOrg
azdw credential add --connection MyOrg --auth-type interactive --tenant <tenant-id-or-name>
```


## See Also

- [Authentication Types Documentation](./Authentication-Types.md) - Detailed comparison of auth methods
- [Azure DevOps PAT Documentation](https://docs.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
- [OAuth 2.0 Token Lifetimes](https://docs.microsoft.com/azure/active-directory/develop/active-directory-configurable-token-lifetimes)
