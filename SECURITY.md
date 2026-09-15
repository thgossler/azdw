# Security, Privacy, and Trust

This document explains what azdw does with your credentials and work-item data.
It is written for people using azdw, not for people developing the repository.

azdw is a local .NET application. The CLI, Web UI, MCP server, REST/GraphQL
service, PowerShell interface, and library use the same provider-neutral data
and authorization layer in the environment where you run them. azdw connects
directly to the Azure DevOps, GitHub, GitHub Enterprise, and AI endpoints that
you configure. There is no requirement to send your work-item data to an azdw
hosted data warehouse.

## How Your Data Flows

For a normal read-only query:

1. You choose a connection, scope, query, or work-item ID.
2. azdw authenticates directly to the selected provider using your configured
   credential.
3. The provider returns the requested work-item data and relationships.
4. azdw normalizes the result into a common model and renders it as a table,
   JSON, CSV, Markdown, HTML, or another requested format.

The deterministic data path does not require AI. Queries, relationship closure,
and reports can run without sending content to a model. Results may still be
written to local caches, logs, transcripts, exports, or generated reports, so
those files should be treated with the same care as the source work items.

## Credentials and Access

- Connection details and credentials are stored under `~/.azdw/`, using the
  local credential-storage mechanism and the protections of your operating-system
  account.
- Authentication can use Microsoft Entra device code or browser sign-in where
  supported. Use short-lived PATs only when an interactive method is not
  available.
- For GitHub, use fine-grained tokens limited to the repositories and permissions
  azdw actually needs.
- Read-only workflows should use read-only provider scopes. Add write or
  administrative scopes only for workflows that intentionally change provider
  data.
- azdw uses a credential to make the provider request you asked for. It should
  never be placed in a prompt, report, URL, query string, log, shell history, or
  source file.

The security of the host account still matters. Disk encryption, OS account
controls, backups, and access to `~/.azdw/` protect the credentials and local
data azdw can reach. Local encryption cannot protect data from a compromised
host or already-authorized user account.

## What azdw Can Change

Most azdw workflows are read-only. Features that create, edit, link, or otherwise
mutate provider data require the provider permission to do so. Depending on the
interface and configuration, azdw can also require a client confirmation or an
explicit approval step before a change is sent upstream.

Review proposed changes before approving them. Keep connection and tool scopes
narrow, especially when azdw is being used through an AI agent or MCP client.
The provider remains the final authority for authentication and authorization;
azdw cannot grant access that your provider account does not have.

## Optional AI Features

AI is optional. You can use deterministic queries, reports, and relationship
analysis without configuring a model.

When you enable AI, azdw sends the prompt and the selected context to the AI
endpoint you configured. Selected context can include work-item fields,
relationship results, and tool output. The endpoint may be a hosted service, an
organization-managed endpoint, or a local model such as Ollama. Check that
endpoint's retention, training, residency, and access policies before sending
confidential or regulated information.

AI output is a suggestion, not authorization. Work-item text can contain
instructions intended to manipulate an agent. Keep tool permissions and approval
requirements outside the influence of that text, and review any proposed
mutation before it is applied.

## MCP, REST, and Web UI Boundaries

The MCP server, REST/GraphQL service, and Web UI are trusted interfaces to the
credentials and provider access available to the azdw process. They are not
anonymous public services by default or by design.

If you make one available beyond your own machine or a private network:

- Add authentication and authorization for every sensitive route or tool.
- Use TLS and restrict network ingress to known callers.
- Bind only to the intended interface and configure CORS for explicit trusted
  origins.
- Protect query, export, cache, approval, administration, and mutation routes.
- Keep tokens out of browser storage, HTML, URLs, and query strings.
- Avoid exposing personal data or credentials through errors and logs.

The same rule applies to remote MCP servers, plugins, prompt files, and templates:
enable only integrations you trust and grant only the connections and tools they
need.

## Local Files and Privacy

Work-item titles, descriptions, comments, links, identities, URLs, custom fields,
queries, and generated reports may contain confidential business information or
personal data. Caches, chat transcripts, diagnostic logs, dashboards, CSV files,
JSON exports, and screenshots may contain that data too.

Before using production data:

1. Limit connections, fields, work-item types, and query scope to what is needed.
2. Confirm the retention and residency policies of every provider and AI endpoint.
3. Set a retention period for generated files and delete them when no longer
   needed.
4. Inspect and redact exports before sharing them.
5. Do not put credentials or real customer data in demos, screenshots, tests, or
   support reports unless it has been approved and sanitized.

Optional telemetry is designed not to intentionally include work-item content,
queries, credentials, tokens, organization URLs, email addresses, usernames,
hostnames, or IP addresses. It may include version, time, startup mode, a
locally derived country code, one-way installation or user fingerprints, and
connection counts. Use `AZDW_MINIMIZE_TELEMETRY=1` where your policy requires
minimal telemetry.

## A Trustworthy Setup

1. Install azdw from a release source you trust and verify any available release
   checksums or provenance information.
2. Start with one provider connection and the narrowest practical permissions.
3. Run a read-only query before enabling reports, AI, MCP, or write operations.
4. Keep services bound to localhost until authentication, TLS, and network access
   controls are configured.
5. Review the AI endpoint, MCP tools, plugins, templates, and generated scripts
   before allowing them to process production data.
6. Protect `~/.azdw/`, backups, caches, logs, and generated artifacts according to
   the sensitivity of the data they contain.

## If a Credential or Data May Have Leaked

1. Revoke the affected PAT, OAuth credential, GitHub token, key, or session.
2. Review provider audit logs for unexpected reads or writes.
3. Remove exposed local files and shared copies, preserving only sanitized
   evidence needed for investigation.
4. Rotate dependent credentials and notify the affected data owners.
5. Record the azdw version, affected connection, time window, and suspected
   scope without including secrets in the report.

## Reporting a Vulnerability

Please do not disclose an exploitable vulnerability in a public issue. Report it
privately through the repository's GitHub security advisory flow, or contact
57985062+thgossler@users.noreply.github.com with the affected version, a concise
reproduction, impact, and any mitigation. Do not include credentials, personal
data, or customer work-item content in a report.

This document describes the product's intended security boundaries and user
choices. It is not legal advice and cannot guarantee the security of an upstream
provider, AI vendor, browser, operating system, network, plugin, or user account.
