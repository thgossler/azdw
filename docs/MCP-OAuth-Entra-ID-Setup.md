# MCP OAuth — Entra ID App Registration Setup

When `azdw` connects to remote MCP servers that require authentication, it uses the **OAuth 2.1 Authorization Code + PKCE** flow. This is the same protocol that VS Code Copilot Chat uses for remote MCP servers.

This guide covers two scenarios:

1. **Granting access to the vendor's pre-registered multi-tenant app** — the simplest option, no app registration needed on the client side.
2. **Creating your own Entra ID app registration** — for organizations that prefer full control over the client application identity.

## How It Works

When `azdw` connects to a remote MCP server (via a `"url"` entry in `mcp.jsonc`), it:

1. Sends a request to the server and receives a `401 Unauthorized` response.
2. Discovers the authorization server via `/.well-known/oauth-protected-resource` ([RFC 9728](https://datatracker.ietf.org/doc/html/rfc9728)).
3. Uses a pre-registered client ID (from `defaults.jsonc` or the `auth.clientId` field) — or falls back to Dynamic Client Registration ([RFC 7591](https://datatracker.ietf.org/doc/html/rfc7591)).
4. Opens the system browser for the user to sign in (Authorization Code + PKCE).
5. Listens on a random `http://localhost:{port}/` redirect URI to receive the authorization code.
6. Exchanges the code for an access token and connects to the MCP server.

## Required API Permissions

The client app registration (whether the vendor's or your own) needs the following **delegated** permissions:

| API | Permission | Type | Description |
| ---- | --------- | ----- | ---------- |
| Microsoft Graph | `User.Read` | Delegated | Sign in and read the user profile |
| *Your MCP Server API* | `MCP.Tools.Read` | Delegated | Read MCP tools |
| *Your MCP Server API* | `MCP.Tools.Execute` | Delegated | Execute MCP tools |

> **Note:** The exact MCP server permission names (`MCP.Tools.Read`, `MCP.Tools.Execute`) depend on how your organization's MCP server API app registration defines its scopes. The names above are a common convention; your server may use different scope names.

## Redirect URI Requirement

`azdw` picks a random free TCP port at runtime and listens on `http://localhost:{port}/` for the OAuth redirect. The app registration must be configured to allow this:

- **Platform**: Mobile and desktop applications
- **Redirect URI**: `http://localhost`

This is the standard configuration for native/desktop OAuth clients. Entra ID treats `http://localhost` as a wildcard that permits any port — no need to register specific port numbers.

---

## Option 1: Use the Vendor's Multi-Tenant App (Recommended)

`azdw` ships with a built-in multi-tenant Entra ID app registration. This is the default — no configuration needed on the `azdw` side.

To allow this app in your tenant, an Entra ID administrator must grant **admin consent** for the vendor's application. This is a one-time step per tenant.

### Step 1: Grant Admin Consent

An administrator in your Entra ID tenant must consent to the vendor's multi-tenant app. There are two ways:

**Option A: Admin Consent URL (recommended)**

Have an Entra ID Global Administrator or Cloud Application Administrator open the following URL in a browser:

```
https://login.microsoftonline.com/{your-tenant-id}/adminconsent?client_id={vendor-app-client-id}
```

Replace `{your-tenant-id}` with your Entra ID tenant ID (or primary domain) and `{vendor-app-client-id}` with the client ID provided by the vendor.

The administrator will see a consent prompt showing the requested permissions. After approval, all users in the tenant can use `azdw` with the vendor's app identity.

**Option B: Azure Portal**

1. Go to the [Azure Portal](https://portal.azure.com) → **Microsoft Entra ID** → **Enterprise Applications**.
2. Search for the vendor's application by its client ID.
3. Navigate to **Permissions** → **Grant admin consent for \<your tenant\>**.
4. Review and approve the requested permissions.

> **Note:** Depending on your Entra ID tenant configuration, admin consent may or may not be required. Some tenants allow users to consent to delegated permissions themselves. If users can sign in without errors, admin consent is already in place or not needed.

### Step 2: Grant API Permissions for Your MCP Server

The vendor's app also needs permission to call your organization's MCP server API. In the Azure Portal:

1. Go to **Microsoft Entra ID** → **App registrations** → find the vendor's app (it appears under **Enterprise Applications** after admin consent, but API permissions are configured on the app registration).

   > If the vendor's app does not appear under **App registrations** in your tenant (because it is a multi-tenant app registered in another tenant), you need to grant the API permissions via the **Enterprise Applications** blade or by having the vendor add your MCP server's API permissions to their app registration.

2. Under **API permissions** → **Add a permission** → **APIs my organization uses** → search for your MCP server API.
3. Select the delegated permissions: `MCP.Tools.Read` and `MCP.Tools.Execute` (or whatever scope names your MCP server defines).
4. Click **Grant admin consent** for your tenant.

### Step 3: Verify

No `defaults.jsonc` changes are needed — `azdw` uses the vendor's app by default. Add a remote MCP server to your `mcp.jsonc`:

```jsonc
{
  "mcpServers": {
    "my-company-mcp": {
      "url": "https://mcp.yourcompany.com/mcp"
    }
  }
}
```

Run `azdw ai chat` and the browser-based sign-in should appear on first use.

---

## Option 2: Create Your Own Entra ID App Registration

If your organization prefers not to grant access to the vendor's multi-tenant app — or wants tighter control over the client identity — you can register your own app.

### Step 1: Register the Application

1. Go to the [Azure Portal](https://portal.azure.com) → **Microsoft Entra ID** → **App registrations** → **New registration**.
2. Configure:
   - **Name**: e.g., `azdw MCP Client` (or any descriptive name)
   - **Supported account types**: *Accounts in this organizational directory only* (single tenant) — unless you need multi-tenant access.
   - **Redirect URI**:
     - Platform: **Mobile and desktop applications**
     - URI: `http://localhost`
3. Click **Register**.
4. Note the **Application (client) ID** — you will need it in Step 4.

### Step 2: Configure API Permissions

In your newly registered app:

1. Go to **API permissions** → **Add a permission**.
2. **Microsoft Graph** → Delegated → select `User.Read` (usually added by default).
3. **Add a permission** → **APIs my organization uses** → search for your MCP server API app registration.
4. Select the delegated permissions your MCP server requires, e.g.:
   - `MCP.Tools.Read`
   - `MCP.Tools.Execute`
5. Click **Grant admin consent for \<your tenant\>** (depending on your tenant policy, this may not be required for delegated-only permissions — but granting it proactively avoids individual user consent prompts).

### Step 3: Verify the App Configuration

In the Azure Portal, your app's **API permissions** tab should show:

| API | Permission | Type | Admin consent |
| ---- | --------- | ----- | ------------ |
| Microsoft Graph | `User.Read` | Delegated | Granted |
| *Your-MCP-Server-API* | `MCP.Tools.Read` | Delegated | Granted |
| *Your-MCP-Server-API* | `MCP.Tools.Execute` | Delegated | Granted |

No client secret is needed — the Authorization Code + PKCE flow is a public-client flow that does not require a secret.

### Step 4: Configure azdw to Use Your App

Set the `mcpOAuthClientId` in your `defaults.jsonc` configuration file:

**User-level override** (`~/.azdw/config/defaults.jsonc`):

```jsonc
{
  "mcpOAuthClientId": "<your-app-client-id>"
}
```

**Factory default** (for distribution packages: `<exe>/config/defaults.jsonc`):

```jsonc
{
  "$schema": "./defaults-schema.json",
  "version": "1.0",
  "mcpOAuthClientId": "<your-app-client-id>"
}
```

This replaces the vendor's built-in app ID for all remote MCP server connections that use MCP OAuth 2.1 auto-discovery.

> **Per-server override:** If you need different client IDs for different MCP servers, set the `clientId` inside the `auth` block of each server entry in `mcp.jsonc` — this takes precedence over `mcpOAuthClientId` in `defaults.jsonc`.

### Step 5: Verify

```jsonc
// mcp.jsonc
{
  "mcpServers": {
    "my-company-mcp": {
      "url": "https://mcp.yourcompany.com/mcp"
    }
  }
}
```

Run `azdw ai chat`. The browser sign-in should use your organization's app registration. After successful authentication, the MCP server tools will be available in the chat session.

---

## MCP Server-Side App Registration

This guide covers the **client-side** app registration (the app that `azdw` uses to authenticate the user). The **server-side** app registration (the API that exposes `MCP.Tools.Read` / `MCP.Tools.Execute` scopes) is configured by whichever team operates your remote MCP server.

Key points for the server-side registration:

- The server app registration must **expose API scopes** (e.g., `MCP.Tools.Read`, `MCP.Tools.Execute`) under **Expose an API**.
- The **Application ID URI** (e.g., `api://<server-app-id>`) is used as the scope prefix.
- The server must implement the MCP OAuth 2.1 protocol, including the `/.well-known/oauth-protected-resource` metadata endpoint ([RFC 9728](https://datatracker.ietf.org/doc/html/rfc9728)).

---

## Troubleshooting

### "The access token was rejected by the MCP server"

The token was issued but the MCP server does not accept it. Possible causes:

- The client app does not have the required API permissions on the MCP server. Check **API permissions** in the Azure Portal.
- Admin consent has not been granted. Ask your Entra ID administrator to grant consent.
- The MCP server expects specific scopes that differ from the defaults discovered via auto-discovery.

**Fix:** Verify that the client app has `MCP.Tools.Read` and `MCP.Tools.Execute` (or your server's equivalent scopes) granted and consented.

### "AADSTS65001: The user or administrator has not consented to use the application"

The user's tenant has not consented to the multi-tenant vendor app, or individual user consent is disabled.

**Fix:** An Entra ID administrator must grant admin consent using the admin consent URL or the Azure Portal (see [Option 1, Step 1](#step-1-grant-admin-consent)).

### Browser sign-in opens but the redirect fails

The app registration is missing the `http://localhost` redirect URI, or it is configured under the wrong platform.

**Fix:** In the app registration → **Authentication** → ensure `http://localhost` is listed under **Mobile and desktop applications** (not Web).

### Corporate proxy packet inspection workaround (VS Code MCP clients)

Some corporate proxies that perform TLS packet inspection or browser-flow interception
(for example ZScaler) can break the OAuth 2.1 Authorization Code + PKCE flow used by
remote MCP servers.

If the server operator has given you an access-token based fallback, a practical
workaround in **VS Code MCP client configuration** is to bypass the browser flow and
send a bearer token explicitly in the `Authorization` header.

Use a `promptString` input so the token is not stored in plain text inside the MCP
configuration file:

```jsonc
{
  "servers": {
    "some-mcp-server": {
      "type": "http",
      "url": "https://some-mcp-server.mydomain.com/mcp",
      "headers": {
        "Authorization": "Bearer ${input:some-mcp-server-token}"
      }
    }
  },
  "inputs": [
    {
      "type": "promptString",
      "id": "some-mcp-server-token",
      "description": "Some MCP Server token — run: az account get-access-token --tenant cfd36c51-fc8s-43cf-88b2-d6df3e15z894 --scope api://c2291df3-a630-4fg7-9cc6-ef1e476a9b6d/.default --query accessToken -o tsv",
      "password": true
    }
  ]
}
```

Notes:

- This workaround applies to **VS Code-style MCP client configuration** that supports
  `servers`, `headers`, and `inputs`.
- Replace the server name, URL, tenant ID, and scope with the values provided by the
  team operating your remote MCP server.
- Azure access tokens expire. When the token expires, rerun the `az account get-access-token ...`
  command and paste a fresh token when prompted.
- Prefer `promptString` with `"password": true` over hardcoding bearer tokens in JSON.

Important limitation:

- This exact workaround does **not** apply to `azdw`'s own external MCP configuration
  file (`mcp.jsonc`). That schema supports `url` and `auth`, but not arbitrary
  `headers` or VS Code `inputs`.
- For `azdw ai-chat` external MCP connections, continue using MCP OAuth auto-discovery,
  or configure an explicit `EntraIdDeviceCode` / `EntraIdInteractive` /
  `EntraIdClientCredentials` auth block when appropriate.

### "AADSTS700016: Application with identifier '...' was not found"

The `mcpOAuthClientId` in `defaults.jsonc` (or the `auth.clientId` in `mcp.jsonc`) does not match any app registration visible to the tenant.

**Fix:** Verify the client ID is correct. For the vendor's multi-tenant app, ensure the app has been consented to in your tenant first.

## See Also

- [MCP Server Setup Guide](MCP-Server-Setup.md) — Configuring `azdw` as an MCP server for VS Code / Claude Desktop
- [Token Expiration Guide](Token-Expiration-Guide.md) — Understanding OAuth token lifetimes
- [Configuration Discovery](Configuration-Discovery.md) — How `azdw` locates configuration files
- [`config/mcp-example.jsonc`](../config/mcp-example.jsonc) — Example MCP server configurations including all auth types
- [`config/defaults-example.jsonc`](../config/defaults-example.jsonc) — Example defaults including `mcpOAuthClientId`
