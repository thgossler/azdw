# Azure DevOps Work Item Handler API Documentation

## Table of Contents

- [Overview](#overview)
- [Base URL](#base-url)
- [REST API Endpoints](#rest-api-endpoints)
  - [Health & Status](#health--status)
  - [Organization Management](#organization-management)
  - [Work Item Operations](#work-item-operations)
  - [WIQL Queries](#wiql-queries)
  - [Relationship Management](#relationship-management)
  - [Template Management](#template-management)
  - [Report Generation](#report-generation)
  - [Cache Management](#cache-management)
  - [Field Mapping Management](#field-mapping-management)
- [GraphQL API](#graphql-api)
  - [Queries](#queries)
  - [Mutations](#mutations)
- [Model Context Protocol (MCP)](#model-context-protocol-mcp)
  - [Starting the MCP Server](#starting-the-mcp-server)
  - [Bridging MCP to OpenAPI](#bridging-mcp-to-openapi)
  - [Available Tools](#available-tools)
- [Feature Implementation Status](#feature-implementation-status)
- [Error Handling](#error-handling)
- [Pagination](#pagination)
  - [REST API Pagination](#rest-api-pagination)
  - [GraphQL Pagination](#graphql-pagination)
- [Authentication](#authentication)
- [Rate Limiting](#rate-limiting)
- [Next Steps for Full Implementation](#next-steps-for-full-implementation)


## Overview

The Azure DevOps Work Item Handler API service provides comprehensive access to Azure DevOps work items across multiple organizations through three interfaces:

- **REST API**: Traditional HTTP endpoints for integration
- **GraphQL API**: Query language for flexible data retrieval
- **Model Context Protocol (MCP)**: AI assistant integration tools

> **Note:** The API service is currently **single-tenant single-user**. Support for **multi-user** and **multi-tenant** deployments is planned to be added soon.

## Base URL

- **REST API**: `http://127.0.0.1:5016/api/v1`
- **GraphQL API**: `http://127.0.0.1:5016/graphql`
- **MCP Server**: Via CLI command `azdw mcp`

## REST API Endpoints

### Health & Status

#### GET /health
Returns basic health status.
```json
{
  "status": "Healthy",
  "timestamp": "2025-01-18T10:30:00Z",
  "version": "1.0.0"
}
```

#### GET /status
Returns detailed service status including configured organizations.
```json
{
  "status": "Running",
  "configuredOrganizations": 2,
  "organizations": ["Collaboration", "CloudPlatform"]
}
```

### Organization Management

#### GET /organizations
List all configured organizations.

#### POST /organizations
Add or update a connection.
```json
{
  "name": "MyOrg",
  "baseUrl": "https://dev.azure.com/MyOrg",
  "authenticationMethod": "PAT",
  "isCloud": true
}
```

#### POST /organizations/{orgName}/test
Test connectivity to an organization.

#### DELETE /organizations/{orgName}
Remove an organization configuration.

#### DELETE /organizations
Clear all organization connections. This endpoint removes all configured connections and returns the count of connections removed.

**Response:**
```json
{
  "success": true,
  "message": "Cleared 3 connections",
  "removedConnections": ["MyOrg", "CloudPlatform", "Collaboration"]
}
```

**Note:** This is a destructive operation. Ensure you have backups of connection configurations before using this endpoint.

### Work Item Operations

#### POST /workitems/query
Query work items across organizations.
```json
{
  "workItemTypes": ["Epic", "Feature"],
  "states": ["Active"],
  "organizations": ["MyOrg"],
  "maxResults": 100
}
```

For hierarchy, dependency, traceability, or linked-item discovery, include relationships explicitly and then control cross-connection or hyperlink expansion with the related flags:

```json
{
  "workItemIds": [12345],
  "includeRelationships": true,
  "followExternalRelationships": true,
  "resolveHyperlinks": true,
  "maxResults": 50
}
```

#### GET /workitems/{id}?organization={orgName}
Get a specific work item by ID.

#### POST /workitems
Create a new work item.
```json
{
  "organization": "MyOrg",
  "project": "MyProject",
  "type": "Feature",
  "title": "New Feature",
  "description": "Feature description",
  "assignedTo": "user@company.com",
  "tags": ["priority-high", "q4"]
}
```

#### PUT /workitems/{id}
Update an existing work item.
```json
{
  "organization": "MyOrg",
  "title": "Updated Title",
  "state": "Active",
  "tags": ["updated", "reviewed"]
}
```

### WIQL Queries

#### POST /wiql
Execute WIQL (Work Item Query Language) queries.
```json
{
  "query": "SELECT [System.Id], [System.Title] FROM workitems WHERE [System.WorkItemType] = 'Epic'",
  "organizations": ["MyOrg"],
  "maxResults": 200
}
```

### Relationship Management

#### POST /relationships
Resolve work item relationships (existing endpoint).

#### GET /workitems/{id}/relationships?organization={orgName}
Get relationships for a specific work item.

#### POST /workitems/{sourceId}/relationships
Add a relationship between work items.
```json
{
  "sourceOrganization": "MyOrg",
  "targetId": 67890,
  "relationType": "Child",
  "targetOrganization": "OtherOrg"
}
```

This endpoint now performs policy validation before creating relationships. If policy enforcement plugins are loaded, they will be invoked to check the proposed relationship. If any policy violations are detected, the endpoint returns `400 Bad Request` with details:

```json
{
  "success": false,
  "violations": [
    {
      "policyName": "HierarchyValidator",
      "message": "Cannot link Epic to Bug - invalid hierarchy",
      "severity": "Error"
    }
  ]
}
```

#### DELETE /workitems/{sourceId}/relationships/{targetId}
Remove a relationship between work items.

### Template Management

#### GET /templates
List all available templates.

#### GET /templates/{templateId}
Get a specific template.

#### POST /templates
Create a new template.

#### PUT /templates/{templateId}
Update an existing template.

#### DELETE /templates/{templateId}
Delete a template.

### Report Generation

#### POST /reports/generate
Generate a report using a template.
```json
{
  "templateId": "epic-summary",
  "data": { "workItems": [...] },
  "parameters": { "includeDetails": true },
  "renderer": "optional-plugin-renderer-name"
}
```

The `renderer` parameter allows specifying a custom plugin renderer. If provided, the system will check for a plugin implementing `ICustomRendererPlugin` with a matching name. If found, the plugin's renderer is used instead of the template system. If no matching plugin is found, falls back to template rendering.

#### POST /visualizations/generate
Generate visualizations.
```json
{
  "data": { "workItems": [...] },
  "format": "html",
  "options": { "layout": "hierarchical" },
  "renderer": "optional-plugin-renderer-name"
}
```

The `renderer` parameter allows specifying a custom plugin renderer for visualizations. If provided and a matching `ICustomRendererPlugin` is found, it will be used instead of the built-in GraphViz renderer.

### Cache Management

#### GET /cache/status
Get cache status information.

#### POST /cache/refresh
Refresh cache for organization(s).
```json
{
  "organizations": ["MyOrg"],
  "force": true
}
```

#### DELETE /cache
Clear cache.
- Query parameters: `organization`, `expiredOnly`

### Field Mapping Management

#### GET /organizations/{orgName}/fieldmappings
Get field mappings for an organization.

#### POST /organizations/{orgName}/fieldmappings
Update field mappings.
```json
{
  "Epic": {
    "fields": {
      "title": "System.Title",
      "priority": "Microsoft.VSTS.Common.Priority"
    }
  }
}
```

#### POST /organizations/{orgName}/fieldmappings/generate
Generate field mappings automatically.

### Pending Operations (Approval Workflow)

The pending operations endpoints implement an HTTP 202 Accepted pattern for AI-initiated operations that require user approval. This is used when the AI approach is configured to `GitHubCopilotSdk` or when explicit approval workflows are needed.

#### GET /operations
List all pending operations.

**Response:**
```json
[
  {
    "id": "op-abc123",
    "operationType": "UpdateWorkItem",
    "description": "Update Bug #1234: set priority to Critical",
    "status": "Pending",
    "createdAt": "2024-01-15T10:30:00Z",
    "expiresAt": "2024-01-15T10:45:00Z"
  }
]
```

#### GET /operations/{id}
Get status of a specific operation.

**Response (Pending):**
```json
{
  "id": "op-abc123",
  "operationType": "UpdateWorkItem",
  "description": "Update Bug #1234: set priority to Critical",
  "status": "Pending",
  "createdAt": "2024-01-15T10:30:00Z",
  "expiresAt": "2024-01-15T10:45:00Z"
}
```

**Response (Completed):**
```json
{
  "id": "op-abc123",
  "operationType": "UpdateWorkItem",
  "description": "Update Bug #1234: set priority to Critical",
  "status": "Approved",
  "result": { "workItemId": 1234, "success": true }
}
```

#### POST /operations/{id}/approve
Approve a pending operation. The operation will be executed and the result returned.

**Response:**
```json
{
  "id": "op-abc123",
  "status": "Approved",
  "result": { "workItemId": 1234, "success": true }
}
```

#### POST /operations/{id}/reject
Reject a pending operation.

**Request (optional):**
```json
{
  "reason": "Operation not authorized by team lead"
}
```

**Response:**
```json
{
  "id": "op-abc123",
  "status": "Rejected"
}
```

**Operation Status Values:**
- `Pending` - Awaiting user approval
- `Approved` - Approved and executed successfully
- `Rejected` - Rejected by user
- `Expired` - Approval timeout exceeded (default: 15 minutes)
- `Failed` - Execution failed after approval


## GraphQL API

### Queries

#### Available Queries:
- `getHealth`: Simple health check
- `getOrganizations`: List configured organizations
- `getOrganization(name: String!)`: Get specific organization
- `queryWorkItems(filter: QueryFilterInput!)`: Query work items
- `getWorkItem(id: Int!, organizationName: String!)`: Get specific work item
- `executeWiql(query: String!, organizationNames: [String], maxResults: Int)`: Execute WIQL
- `getWorkItemRelationships(workItemId: Int!, organizationName: String!, includeExternal: Boolean)`: Get relationships
- `getTemplates(category: String, outputFormat: String)`: Get templates

#### Example Query:
```graphql
query {
  queryWorkItems(filter: {
    workItemTypes: ["Epic", "Feature"]
    states: ["Active"]
    maxResults: 50
  }) {
    workItems {
      id
      title
      type
      state
      organization
      assignedTo
    }
    totalCount
  }
}
```

For hierarchy, dependency, traceability, or linked-item discovery, set `includeRelationships: true`. Hyperlink and cross-connection expansion stay explicit query choices rather than being implied automatically.

### Mutations

#### Available Mutations:
- `addOrganization(input: ConnectionInput!)`: Add organization
- `removeOrganization(name: String!)`: Remove organization
- `testConnection(name: String!)`: Test connection
- `createTemplate(input: RenderingTemplateInput!)`: Create template
- `updateTemplate(input: RenderingTemplateInput!)`: Update template
- `deleteTemplate(templateId: String!)`: Delete template
- `createWorkItem(input: CreateWorkItemInput!)`: Create work item
- `updateWorkItem(input: UpdateWorkItemInput!)`: Update work item
- `addRelationship(input: AddRelationshipInput!)`: Add relationship
- `removeRelationship(input: RemoveRelationshipInput!)`: Remove relationship
- `generateReport(input: GenerateReportInput!)`: Generate report
- `clearCache(input: ClearCacheInput!)`: Clear cache
- `refreshCache(input: RefreshCacheInput!)`: Refresh cache

#### Example Mutation:
```graphql
mutation {
  createWorkItem(input: {
    organization: "MyOrg"
    project: "MyProject"
    type: "Feature"
    title: "New Feature"
    description: "Feature description"
  }) {
    success
    workItem {
      id
      title
      type
    }
    errors
  }
}
```


## Model Context Protocol (MCP)

The MCP server exposes Azure DevOps functionality as tools for AI assistants.

### Starting the MCP Server
```bash
azdw mcp
```

### Bridging MCP to OpenAPI

If you need a local OpenAPI server without hosting the full API Service, you can bridge the CLI MCP server to OpenAPI using [mcpo](https://github.com/open-webui/mcpo).

**mcpo** (Model Context Protocol to OpenAPI) is a bridge tool that converts MCP servers into OpenAPI-compatible endpoints. This allows you to:
- Use the lightweight CLI MCP server instead of the full API service
- Integrate with tools that expect OpenAPI/REST interfaces
- Access azdw functionality through standard HTTP requests

**Example usage:**
```bash
# Bridge the azdw MCP server to OpenAPI using mcpo
# mcpo will start the MCP server automatically
mcpo --port 8000 -- azdw mcp
```

The MCP server will be accessible at `http://localhost:8000` with auto-generated OpenAPI documentation at `http://localhost:8000/docs`.

This approach is ideal for scenarios where you want OpenAPI compatibility without the overhead of running the full ASP.NET Core API service.

### Available Tools

#### query_work_items
Query work items with flexible filtering.
- Parameters: organizations, workItemTypes, states, assignedTo, titleContains, maxResults, includeRelationships
- For hierarchy, dependency, traceability, and linked-item requests, `includeRelationships` is often needed even though it is not the default.

#### execute_wiql
Execute WIQL queries.
- Parameters: query, organizations, maxResults

#### list_organizations
List all configured organizations.

#### add_connection
Add a new Azure DevOps connection.
- Parameters: name, baseUrl, authMethod, scope, projectName

#### remove_connection
Remove a specific Azure DevOps connection.
- Parameters: name

#### clear_all_connections
Clear all configured connections. This is a destructive operation that removes all organization connections. The tool uses a two-phase approval workflow with `Critical` risk level, showing a preview of connections to be removed before execution.

#### test_connection
Test connectivity to a specific connection.
- Parameters: name

#### list_templates
List available rendering templates.
- Parameters: category, outputFormat

#### get_work_item
Get a specific work item by ID.
- Parameters: id, organization, includeRelationships, includeHistory

#### create_work_item
Create a new work item, including custom Azure DevOps fields.
- Parameters: connection, project, type, title, description, assignedTo, tags, customFields, comment
- `customFields` is a JSON object whose keys are Azure DevOps field reference names such as `Custom.MyField` or `Microsoft.VSTS.Common.Priority`.

#### update_work_item
Update an existing work item, including custom Azure DevOps fields.
- Parameters: id, connection, title, description, state, assignedTo, tags, customFields, comment
- `customFields` is a JSON object whose keys are Azure DevOps field reference names. Set a value to `null` to remove that field.

#### get_work_item_relationships
Get work item relationships.
- Parameters: id, organization, includeExternal, depth

#### add_work_item_relationship
Add a relationship between work items.
- Parameters: sourceId, targetId, relationType, sourceOrganization, targetOrganization

This tool now performs policy validation during the approval process. If policy enforcement plugins are loaded, they will check the proposed relationship. Policy violations are included in the approval details and elevate the risk level to `High`, requiring explicit user confirmation before proceeding.

#### remove_work_item_relationship
Remove a relationship between work items.
- Parameters: sourceId, targetId, relationType, sourceOrganization, targetOrganization

#### generate_report
Generate reports using templates.
- Parameters: templateId, dataJson, parametersJson, rendererName (optional), format (optional)

Added `rendererName` and `format` parameters for custom plugin renderer support. If `rendererName` is provided, the system will attempt to use a matching `ICustomRendererPlugin` instead of template rendering.

#### get_current_date_time
Get the current date and time in the MCP server's local timezone (or a specified timezone).
- Parameters: format (optional, default: 'iso8601'), timeZoneId (optional, default: local system timezone)
- Returns: Current datetime with timezone information including UTC offset and daylight saving time status
- Formats: 'iso8601', 'rfc1123', 'short', 'long', 'date', 'time', or custom .NET format string
- Timezone: Accepts IANA (e.g., 'America/New_York') or Windows (e.g., 'Eastern Standard Time') timezone IDs

#### get_cache_status
Get cache status information.
- Parameters: organization

#### clear_cache
Clear cache for organization(s).
- Parameters: organization, expiredOnly

#### refresh_cache
Refresh cache for organization(s).
- Parameters: organizations, force


## Feature Implementation Status

### ✅ Fully Implemented
- Work item querying (query_work_items, queryWorkItems)
- WIQL query execution (execute_wiql, executeWiql)
- Organization management (list, add, remove, test)
- Template management (CRUD operations)
- Basic relationship resolution

### 🚧 Partially Implemented
- Individual work item operations (endpoints exist, need API client methods)
- Report generation (template framework exists, needs renderer fixes)
- Cache management (interfaces defined, need implementation)
- Field mapping operations (service exists, needs API exposure)

### ❌ Not Yet Implemented
- Work item creation/update (API client methods needed)
- Relationship add/remove (API client methods needed)
- Advanced visualization generation
- Cache service implementation


## Error Handling

All APIs return consistent error responses:

### REST API Errors
```json
{
  "error": "Error message",
  "details": "Additional error details"
}
```

### GraphQL Errors
```json
{
  "data": null,
  "errors": [
    {
      "message": "Error message",
      "path": ["fieldName"]
    }
  ]
}
```

### MCP Tool Errors
```json
{
  "success": false,
  "error": "Error message"
}
```


## Pagination

Both REST and GraphQL APIs support pagination for endpoints that return collections, ensuring efficient handling of large datasets.

### REST API Pagination

REST endpoints use **offset-based pagination** with page numbers and page sizes.

**Pagination Parameters:**
- `page`: Page number (default: 1, minimum: 1)
- `pageSize`: Items per page (default: 100, maximum: 1000)

**Pagination Response Structure:**
All paginated REST endpoints return responses with the following structure:

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "pageSize": 100,
    "totalItems": 250,
    "totalPages": 3,
    "hasNextPage": true,
    "hasPreviousPage": false,
    "links": {
      "self": "/api/v1/endpoint?page=1&pageSize=100",
      "first": "/api/v1/endpoint?page=1&pageSize=100",
      "last": "/api/v1/endpoint?page=3&pageSize=100",
      "next": "/api/v1/endpoint?page=2&pageSize=100",
      "previous": null
    }
  }
}
```

**Paginated REST Endpoints:**
- `POST /workitems/query` - Query work items
- `POST /wiql` - Execute WIQL queries
- `POST /relationships` - Resolve relationships
- `GET /templates` - List templates
- `GET /relationships/orphans` - Find orphaned work items
- `GET /relationships/circular` - Find circular dependencies
- `GET /plugins` - List plugins

**Example:**
```bash
# Get second page with 50 items per page
curl "http://localhost:5000/api/v1/workitems/query?page=2&pageSize=50" \
  -H "Content-Type: application/json" \
  -d '{"connections":["MyOrg"],"workItemTypes":["Epic"]}'
```

**HATEOAS Links:**
The `links` object provides REST-standard hypermedia navigation:
- `self`: Current page URL
- `first`: First page URL
- `last`: Last page URL
- `next`: Next page URL (null if on last page)
- `previous`: Previous page URL (null if on first page)

### GraphQL Pagination

GraphQL endpoints use **cursor-based pagination** following the Relay specification.

**Pagination Arguments:**
- `first`: Number of items to fetch (forward pagination)
- `after`: Cursor to fetch items after (forward pagination)
- `last`: Number of items to fetch (backward pagination)
- `before`: Cursor to fetch items before (backward pagination)

**Default:** `first: 100`, **Maximum:** `first/last: 1000`

**Connection Response Structure:**
Paginated GraphQL queries return a **Connection** type with:

```graphql
{
  edges {
    node {
      # Your data fields
    }
    cursor
  }
  pageInfo {
    hasNextPage
    hasPreviousPage
    startCursor
    endCursor
  }
  totalCount
}
```

**Paginated GraphQL Queries:**
- `getConnections` - List configured connections
- `getTemplates` - List templates
- `findOrphanedWorkItems` - Find orphaned work items
- `findCircularDependencies` - Find circular dependencies
- `workItemTypes` - List work item types
- `workItemFields` - List work item fields

**Example - Forward Pagination:**
```graphql
query {
  getTemplates(first: 10) {
    edges {
      node {
        id
        name
        category
        outputFormat
      }
      cursor
    }
    pageInfo {
      hasNextPage
      hasPreviousPage
      startCursor
      endCursor
    }
    totalCount
  }
}
```

**Example - Fetching Next Page:**
```graphql
query {
  getTemplates(first: 10, after: "cursor_value_from_previous_page") {
    edges {
      node {
        id
        name
      }
      cursor
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

**Example - Backward Pagination:**
```graphql
query {
  findOrphanedWorkItems(
    connections: ["MyOrg"]
    last: 20
    before: "cursor_value"
  ) {
    edges {
      node {
        id
        title
        type
      }
      cursor
    }
    pageInfo {
      hasPreviousPage
      startCursor
    }
  }
}
```

**Cursor-Based vs Offset-Based:**
- **Cursors** are opaque tokens that represent a position in the dataset
- More efficient for large datasets and real-time data
- Prevents "page drift" issues when data is added/removed during pagination
- Required for GraphQL Relay specification compliance

## Authentication

The API service uses the same authentication as the CLI:
- Personal Access Tokens (PAT)
- Device Code Flow
- Interactive Browser Flow

Credentials are managed through the CLI and shared with the API service.

## Rate Limiting

The service respects Azure DevOps rate limits and includes rate limiting information in responses where applicable.


## Next Steps for Full Implementation

1. **API Client Enhancement**: Implement missing methods in AzureDevOpsApiClient
   - CreateWorkItemAsync
   - UpdateWorkItemAsync
   - AddWorkItemRelationshipAsync
   - RemoveWorkItemRelationshipAsync

2. **Cache Service**: Complete ICacheService implementation
   - GetCacheStatus
   - RefreshCacheAsync
   - ClearCacheAsync

3. **Rendering Fixes**: Fix renderer method signatures and dependencies
   - GraphVizRenderer.RenderAsync
   - InteractiveHtmlRenderer parameter types

4. **Field Mapping API**: Add missing IFieldMappingService methods
   - GetFieldMappingsForOrganization
   - UpdateFieldMappingsAsync
   - GenerateFieldMappingsAsync

5. **Testing**: Comprehensive API testing across all interfaces

This documentation will be updated as features are fully implemented.
## Hosted Admin Endpoints

These endpoints are only available in hosted/cloud deployments where `IHostedAuditService` is registered.

### Audit Trail

**Authorization**: `AdminRequired` policy (`scope=admin` claim required).

#### Query by Actor

```
GET /api/v1/admin/audit?actor={userScopeId}&maxResults={n}
```

Returns all audit records for the specified user scope ID, most recent first.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `actor` | string | Yes | User scope ID to query |
| `maxResults` | int | No | Maximum records to return (default: 100) |

**Responses**: `200 OK` (array of `AuditRecord`), `400 Bad Request` (missing actor), `401/403` (unauthorized), `404 Not Found` (non-hosted mode).

#### Query by Capability

```
GET /api/v1/admin/audit/capability/{capabilityId}?maxResults={n}
```

Returns all audit records for the specified capability ID (e.g. `"chat"`, `"web-ui-settings"`, `"approve"`, `"reject"`).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `capabilityId` | string (path) | Yes | Capability identifier |
| `maxResults` | int | No | Maximum records to return (default: 100) |

**Responses**: `200 OK` (array of `AuditRecord`), `401/403` (unauthorized), `404 Not Found` (non-hosted mode).

### AuditRecord Schema

```json
{
  "auditId": "string",
  "actorUserScopeId": "string",
  "capabilityId": "string",
  "outcome": "approved | rejected | expired | overwritten | ...",
  "reasonClass": "string",
  "contextNote": "string | null",
  "relatedOperationId": "string | null",
  "recordedUtc": "2025-01-01T00:00:00Z",
  "retainUntilUtc": "2026-01-01T00:00:00Z"
}
```
