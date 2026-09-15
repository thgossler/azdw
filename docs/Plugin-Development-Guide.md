---
title: Plugin Development
nav_order: 240
---

# Plugin Development

## Introduction

### Why Extensibility?

Azure DevOps work item management involves diverse organizational needs: custom workflows, specialized reporting, unique validation rules, and integration with proprietary tools. Rather than building every possible feature into the core application, the azdw plugin system empowers you to extend functionality to match your specific requirements.

The plugin system enables:

- **Customization**: Add organization-specific logic without modifying core code
- **Reusability**: Share plugins across teams and projects
- **Maintainability**: Update plugins independently from the main application
- **AI Integration**: Expose custom functionality to LLM assistants via MCP (Model Context Protocol)

### Design Goals

The azdw plugin architecture was designed with several key principles:

**Compile-Time Safety**: Plugin metadata is enforced through interfaces, not attributes. If you forget required properties like `Name`, `Description`, or `Version`, your code won't compile. This prevents runtime surprises and ensures plugins are always properly documented.

**LLM-Friendly**: All plugins are automatically discoverable by AI assistants through the MCP server. Your plugin's description helps LLMs understand when and how to use it, enabling intelligent workflow automation.

**MEF-Based Discovery**: Using .NET's Managed Extensibility Framework, plugins are discovered and loaded automatically without configuration files. Simply place your compiled DLL in the `plugins/` directory.

**Zero-Configuration**: No XML files, no registration steps. Build your plugin, copy the DLL, and it's immediately available.

## Understanding the Plugin System

### Plugin Architecture

The plugin system follows a provider pattern where the core application defines interfaces and your plugins implement them. At startup, the application scans for plugins, loads them via MEF (Managed Extensibility Framework), and invokes them at appropriate points in the workflow.

All plugins share a common base interface that enforces metadata requirements:

```csharp
public interface IPlugin
{
    string Name { get; }        // Unique identifier
    string Description { get; }  // Human and LLM-readable explanation
    string Version { get; }      // Semantic version (e.g., "1.0.0")
}
```

This base interface ensures every plugin is self-documenting and discoverable.

### Plugin Types

The system supports four plugin categories, each serving a distinct purpose:

**1. Data Transform Plugins** (`IDataTransformPlugin`) - **Automatic Invocation**
- Enrich work items with calculated fields
- Normalize data across different projects
- Add visual indicators or computed metadata
- Example: Add "Age in Days" field based on creation date
- **Invocation**: Automatically applied to ALL query results across ALL interfaces (CLI, MCP, REST API, GraphQL, PowerShell)

**2. Policy Enforcement Plugins** (`IPolicyEnforcementPlugin`) - **Automatic with Context**
- Validate work items against business rules
- Check required fields or relationships
- Enforce organizational standards
- Example: Ensure critical bugs have assigned owners
- **Invocation**: 
  - **Blocking** for mutations (Create/Update): Validation errors prevent the operation
  - **Metadata** for queries: Validation results stored in QueryResult.PolicyValidationResults for reporting

**3. Custom Renderer Plugins** (`ICustomRendererPlugin`) - **Opt-in Invocation**
- Generate custom output formats
- Create specialized visualizations
- Export data in proprietary formats
- Example: Render work items as Markdown cards
- **Invocation**: Only when explicitly selected via --renderer (CLI) or -Renderer (PowerShell) parameters

**4. Query Filter Plugins** (`IQueryFilterPlugin`) - **Automatic Invocation**
- Modify queries dynamically before execution
- Add organization-specific filters
- Implement custom search logic
- Example: Auto-filter by user's team or apply security restrictions
- **Invocation**: Automatically applied to ALL queries across ALL interfaces (CLI, MCP, REST API, GraphQL, PowerShell, WIQL)

### When and Where Plugins Run

Understanding when each plugin type is invoked helps you design effective plugins:

#### Automatic Invocation (No Configuration Needed)

These plugins run automatically for every relevant operation across all interfaces:

**Data Transform Plugins:**
- Triggered: After fetching work items from Azure DevOps, before returning results
- Scope: All query operations (query, WIQL, specific work item fetch, relationship queries)
- Interfaces: CLI commands, MCP tools, REST API endpoints, GraphQL queries, PowerShell cmdlets
- Order: Applied sequentially in plugin load order
- Failure handling: Logged as warning, continues with original data

**Query Filter Plugins:**
- Triggered: Before building/executing Azure DevOps API queries
- Scope: All query operations (except raw WIQL which bypasses query filters)
- Interfaces: CLI commands, MCP tools, REST API endpoints, GraphQL queries, PowerShell cmdlets
- Order: Applied sequentially, each filter modifies the cumulative query
- Failure handling: Logged as warning, uses original query parameters

**Policy Enforcement (Queries):**
- Triggered: After data transforms, before returning query results
- Scope: All query operations
- Behavior: Non-blocking - validation results stored as metadata in QueryResult.PolicyValidationResults
- Use case: Generate compliance reports, flag violations for review
- Interfaces: CLI commands, MCP tools, REST API endpoints, GraphQL queries, PowerShell cmdlets

**Policy Enforcement (Mutations):**
- Triggered: Before creating or updating work items
- Scope: Create/Update operations only
- Behavior: **Blocking** - throws exception if validation fails, operation is aborted
- Use case: Enforce required fields, prevent invalid state transitions
- Interfaces: CLI commands, MCP tools, REST API endpoints, GraphQL mutations, PowerShell cmdlets

#### Opt-in Invocation (Explicit Selection Required)

These plugins require explicit activation:

**Custom Renderer Plugins:**
- Triggered: When explicitly selected via CLI option or API parameter
- CLI: `azdw report generate --renderer MyRenderer`
- CLI: `azdw visualization generate --renderer MyGraphRenderer`
- CLI: `azdw query --renderer MyTableRenderer`
- PowerShell: `ConvertTo-AzdwReport -Renderer MyRenderer`
- PowerShell: `ConvertTo-AzdwVisualization -Renderer MyGraphRenderer`
- MCP/API: Currently use built-in renderers only
- Behavior: If specified renderer not found, falls back to built-in renderers

#### Interface Coverage Summary

| Plugin Type | CLI | MCP | REST API | GraphQL | PowerShell | WIQL |
|-------------|-----|-----|----------|---------|------------|------|
| Data Transform | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto |
| Query Filter | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto | ❌ N/A* |
| Policy (Query) | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto |
| Policy (Mutate) | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto | ✅ Auto | N/A |
| Custom Renderer | 🔧 Opt-in | ❌ Built-in | ❌ Built-in | ❌ Built-in | 🔧 Opt-in | N/A |

*Query filters don't apply to WIQL because users write raw SQL-like queries that bypass the query builder.

### How Plugins Are Discovered

Plugin discovery happens automatically during application startup:

1. **Scan Phase**: The system examines:
   - `<executable-directory>/plugins/*.dll` for external plugins
   - Embedded assemblies for built-in plugins

2. **Load Phase**: Each DLL is inspected for MEF exports matching plugin interfaces

3. **Registration Phase**: Valid plugins are instantiated and registered by type

4. **Invocation Phase**: Plugins are called at appropriate points during work item operations

Failed plugin loads are logged but don't prevent application startup, ensuring robustness.

## Setting Up Your Development Environment

### Prerequisites

Before creating plugins, ensure you have:

- .NET 10 SDK or later
- A C# IDE (Visual Studio, VS Code with C# extension, or Rider)
- Basic understanding of async/await patterns in C#
- Familiarity with Azure DevOps work items (optional but helpful)

### Project Structure

Create a new class library project:

```bash
dotnet new classlib -n MyAzdwPlugins -f net8.0
cd MyAzdwPlugins
dotnet add package System.ComponentModel.Composition
```

Reference the azdw library to access plugin interfaces:

```bash
dotnet add reference path/to/azdw.lib/azdw.lib.csproj
```

Your project structure should look like:

```
MyAzdwPlugins/
├── MyAzdwPlugins.csproj
├── MyTransformPlugin.cs
├── MyPolicyPlugin.cs
└── README.md
```

## Creating Your First Plugin

### Required Metadata

### Required Metadata

Every plugin must provide three metadata properties through interface implementation. This is enforced at compile time—if you forget any of these, your code won't build:

```csharp
public interface IPlugin
{
    /// <summary>
    /// Unique identifier for the plugin (e.g., "EnrichWithPriority")
    /// Used by the system and shown to users
    /// </summary>
    string Name { get; }

    /// <summary>
    /// Clear explanation of what the plugin does
    /// Shown to both humans and AI assistants
    /// </summary>
    string Description { get; }

    /// <summary>
    /// Semantic version (Major.Minor.Patch)
    /// Example: "1.0.0"
    /// </summary>
    string Version { get; }
}
```

The interface-based approach ensures you can't accidentally create an undocumented plugin. The compiler enforces these requirements, providing immediate feedback during development.

### Data Transform Plugin Example

Let's create a simple plugin that adds a "Processed" timestamp to work items:

### Data Transform Plugin Example

Let's create a simple plugin that adds a "Processed" timestamp to work items:

```csharp
using System.ComponentModel.Composition;
using Azdw.Lib.Extensions;
using Azdw.Lib.Models;

[Export(typeof(IDataTransformPlugin))]
public class TimestampPlugin : IDataTransformPlugin
{
    // Required metadata (enforced by IPlugin interface)
    public string Name => "TimestampTransform";
    public string Description => "Adds processing timestamp to work items";
    public string Version => "1.0.0";

    // Determine if this plugin should process the work item
    public bool CanTransform(WorkItem workItem, string context)
    {
        // Process all work items
        return workItem != null;
    }

    // Perform the transformation
    public Task<WorkItem> TransformAsync(WorkItem workItem, string context)
    {
        // Add custom field with current timestamp
        workItem.Fields["Custom.ProcessedAt"] = DateTime.UtcNow.ToString("o");
        workItem.Fields["Custom.ProcessedBy"] = Name;
        
        return Task.FromResult(workItem);
    }
}
```

Key points about this plugin:

- **MEF Export**: The `[Export]` attribute tells MEF this class implements `IDataTransformPlugin`
- **Metadata Properties**: `Name`, `Description`, and `Version` are compile-time enforced
- **CanTransform**: Controls when the plugin runs (here: always)
- **TransformAsync**: Does the actual work (here: adds timestamp fields)

### Building and Deploying

Build your plugin project:

```bash
dotnet build -c Release
```

Copy the compiled DLL to the azdw plugins directory:

```bash
# Find your azdw installation
which azdw  # Example: /usr/local/bin/azdw

# Create plugins directory if needed
mkdir -p /usr/local/bin/plugins

# Copy your plugin
cp bin/Release/net8.0/MyAzdwPlugins.dll /usr/local/bin/plugins/
```

That's it! The next time azdw runs, your plugin will be automatically discovered and loaded.

### Working with Relationships

Policy enforcement and custom renderer plugins receive work item relationships as a parameter, enabling relationship-aware validation and rendering.

**Policy Enforcement Example:**

```csharp
public Task<PolicyValidationResult> ValidateAsync(
    WorkItem workItem, 
    IEnumerable<WorkItemRelationship> relationships, 
    string context)
{
    var result = new PolicyValidationResult { PluginName = Name, IsValid = true };
    
    // Validate that critical bugs have parent features
    if (workItem.Type == "Bug" && workItem.Priority <= 2)
    {
        var hasParent = relationships?.Any(r => 
            r.SourceId == workItem.Id && 
            r.RelationType.Contains("Parent")) ?? false;
        
        if (!hasParent)
        {
            result.IsValid = false;
            result.ErrorMessage = "Critical bugs must be linked to a parent feature";
        }
    }
    
    return Task.FromResult(result);
}
```

**Custom Renderer Example:**

```csharp
public Task<string> RenderAsync(
    IEnumerable<WorkItem> workItems, 
    IEnumerable<WorkItemRelationship> relationships, 
    string format, 
    Dictionary<string, object>? options)
{
    var output = new StringBuilder();
    
    foreach (var item in workItems)
    {
        // Count related work items
        var relatedCount = relationships?.Count(r => 
            r.SourceId == item.Id || r.TargetId == item.Id) ?? 0;
        
        output.AppendLine($"{item.Id}: {item.Title} ({relatedCount} links)");
        
        // Show parent relationships
        var parents = relationships?
            .Where(r => r.SourceId == item.Id && r.RelationType.Contains("Parent"))
            .Select(r => r.TargetId);
        
        if (parents?.Any() ?? false)
        {
            output.AppendLine($"  Parent(s): {string.Join(", ", parents)}");
        }
    }
    
    return Task.FromResult(output.ToString());
}
```

**Key Points:**
- The `relationships` parameter contains ALL relationships for the work items being processed
- For policy validation, you receive relationships for the single work item being validated
- For rendering, you receive relationships for all work items in the collection
- Relationships are bidirectional: check both `SourceId` and `TargetId`
- Common relationship types: `Child`, `Parent`, `Related`, `Predecessor`, `Successor`, `Produces-For`, `Consumes-From`. azdw normalizes the Azure DevOps link reference names (`System.LinkTypes.*`) before plugins see them; the raw name is preserved in `OriginalRelationshipType`

## Advanced Plugin Types

### Policy Enforcement Plugins

Policy plugins validate work items against business rules. They're useful for enforcing organizational standards:

```csharp
[Export(typeof(IPolicyEnforcementPlugin))]
public class RequiredFieldsPolicy : IPolicyEnforcementPlugin
{
    public string Name => "RequiredFieldsPolicy";
    public string Description => "Ensures critical work items have required fields populated";
    public string Version => "1.0.0";

    public bool CanValidate(WorkItem workItem, string context)
    {
        // Only validate bugs and tasks
        return workItem.Type == "Bug" || workItem.Type == "Task";
    }

    public Task<PolicyValidationResult> ValidateAsync(WorkItem workItem, IEnumerable<WorkItemRelationship> relationships, string context)
    {
        var result = new PolicyValidationResult
        {
            PluginName = Name,
            IsValid = true
        };

        // Check required fields
        if (workItem.Type == "Bug" && string.IsNullOrEmpty(workItem.Fields.GetValueOrDefault("System.AssignedTo")?.ToString()))
        {
            result.IsValid = false;
            result.ErrorMessage = "Bugs must have an assigned owner";
            result.ViolatedRules.Add("Required: System.AssignedTo");
        }

        // Example: Check if critical bugs have parent features
        if (workItem.Type == "Bug" && workItem.Priority <= 2)
        {
            var hasParent = relationships?.Any(r => 
                r.SourceId == workItem.Id && 
                r.RelationType.Contains("Parent")) ?? false;
            
            if (!hasParent)
            {
                result.IsValid = false;
                result.ErrorMessage = "Critical bugs must be linked to a parent feature";
                result.ViolatedRules.Add("Required: Parent relationship");
            }
        }

        return Task.FromResult(result);
    }
}
```

### Custom Renderer Plugins

Renderer plugins create custom output formats. They're perfect for generating specialized reports or exports:

### Custom Renderer Plugins

Renderer plugins create custom output formats. They're perfect for generating specialized reports or exports:

```csharp
[Export(typeof(ICustomRendererPlugin))]
public class MarkdownSummaryRenderer : ICustomRendererPlugin
{
    public string Name => "MarkdownSummary";
    public string Description => "Renders work items as a summary table in Markdown format";
    public string Version => "1.0.0";

    // Formats this plugin supports
    public IEnumerable<string> SupportedFormats => new[] { "markdown", "md" };

    public Task<string> RenderAsync(
        IEnumerable<WorkItem> workItems,
        IEnumerable<WorkItemRelationship> relationships,
        string format,
        Dictionary<string, object>? options = null)
    {
        var sb = new StringBuilder();
        sb.AppendLine("# Work Items Summary");
        sb.AppendLine();
        sb.AppendLine("| ID | Title | State | Type | Links |");
        sb.AppendLine("|-----|-------|-------|------|-------|");

        foreach (var item in workItems)
        {
            // Count relationships for this work item
            var linkCount = relationships?.Count(r => 
                r.SourceId == item.Id || r.TargetId == item.Id) ?? 0;
            
            sb.AppendLine($"| {item.Id} | {item.Title} | {item.State} | {item.Type} | {linkCount} |");
        }

        return Task.FromResult(sb.ToString());
    }
}
```

### Query Filter Plugins

Query filter plugins modify search parameters dynamically. They're useful for applying organization-specific filters automatically:

```csharp
[Export(typeof(IQueryFilterPlugin))]
public class TeamScopeFilter : IQueryFilterPlugin
{
    public string Name => "TeamScopeFilter";
    public string Description => "Automatically filters queries to user's team";
    public string Version => "1.0.0";

    public bool CanFilter(Dictionary<string, object> query, string context)
    {
        // Apply when context indicates team filtering is desired
        return context.Contains("TeamScope");
    }

    public Task<Dictionary<string, object>> FilterAsync(
        Dictionary<string, object> query, 
        string context)
    {
        // Add team filter to the query
        if (!query.ContainsKey("AreaPath"))
        {
            query["AreaPath"] = GetUserTeamPath();
        }

        return Task.FromResult(query);
    }

    private string GetUserTeamPath()
    {
        // Implementation to get user's team path
        return "MyOrg\\MyTeam";
    }
}
```

## Testing and Debugging

### Unit Testing

Write unit tests to verify your plugin's behavior:

```csharp
using Xunit;

public class TimestampPluginTests
{
    [Fact]
    public void Plugin_Has_Required_Metadata()
    {
        var plugin = new TimestampPlugin();

        Assert.NotNull(plugin.Name);
        Assert.NotEmpty(plugin.Name);
        Assert.NotNull(plugin.Description);
        Assert.NotEmpty(plugin.Description);
        Assert.Matches(@"^\d+\.\d+\.\d+$", plugin.Version);
    }

    [Fact]
    public async Task Plugin_Adds_Timestamp_Field()
    {
        var plugin = new TimestampPlugin();
        var workItem = new WorkItem { Id = 123, Title = "Test" };

        var result = await plugin.TransformAsync(workItem, "test");

        Assert.Contains("Custom.ProcessedAt", result.Fields.Keys);
        Assert.Contains("Custom.ProcessedBy", result.Fields.Keys);
    }

    [Fact]
    public async Task Plugin_Handles_Null_GracefullyAsync()
    {
        var plugin = new TimestampPlugin();
        
        Assert.False(plugin.CanTransform(null, "test"));
    }
}
```

### Integration Testing

Test your plugin with the actual azdw CLI:

```bash
# Query with your plugin active
azdw query --connections MyOrg --limit 5 --json > with-plugin.json

# Query without plugins for comparison
azdw query --connections MyOrg --limit 5 --json --no-plugins > baseline.json

# Compare the outputs
diff with-plugin.json baseline.json
```

### Debugging Techniques

Enable verbose logging to see plugin activity:

```bash
azdw query --connections MyOrg --verbose 2>&1 | grep -i plugin
```

Look for log entries like:
- "Loading plugins from directory: /usr/local/bin/plugins"
- "Loaded 5 plugins: 2 data transforms, 1 policy enforcers, 2 renderers"
- "Applying data transform plugin: TimestampTransform"

### Using --no-plugins Flag

The `--no-plugins` flag is invaluable for debugging. It disables all plugins (both built-in and custom), letting you compare baseline behavior:

### Using --no-plugins Flag

The `--no-plugins` flag is invaluable for debugging. It disables all plugins (both built-in and custom), letting you compare baseline behavior:

```bash
# Run with plugins (default)
azdw query --connections MyOrg --limit 10 --json > with-plugins.json

# Run without any plugins
azdw query --connections MyOrg --limit 10 --json --no-plugins > no-plugins.json

# See what your plugins added
diff no-plugins.json with-plugins.json
```

Use cases for `--no-plugins`:
- **Isolate issues**: Determine if a problem is plugin-related
- **Measure impact**: See what data your plugins add
- **Performance testing**: Compare execution speed with and without plugins
- **Baseline verification**: Ensure core functionality works independently

## Best Practices

### Writing Clear Metadata

Your plugin's metadata is its first impression, both to developers and AI assistants. Write clear, descriptive names and explanations.

Poor metadata example:
```csharp
public string Name => "Plugin1";
public string Description => "Does stuff";
```

Good metadata example:
```csharp
public string Name => "EnrichWithPriority";
public string Description => "Adds visual priority indicators (🔴 Critical, 🟠 High, 🟡 Medium) based on work item priority field";
```

The good example tells you exactly what the plugin does and when you'd want to use it.

### Semantic Versioning

### Semantic Versioning

Follow semantic versioning for your plugin versions:

```csharp
public string Version => "1.2.3";
//                        ^ ^ ^
//                        | | |
//                Major --+ | |
//                Minor ----+ |
//                Patch ------+
```

Version number guidelines:
- **Major** (1.x.x): Breaking changes to plugin behavior or interface
- **Minor** (x.2.x): New features, backward compatible with existing usage
- **Patch** (x.x.3): Bug fixes, no functional changes

### Context-Aware Processing

Use the `context` parameter to make plugins intelligent about when they run:

```csharp
public bool CanTransform(WorkItem workItem, string context)
{
    // Only process items from production projects
    if (!context.Contains("Production"))
        return false;
    
    // Only process high-priority items
    if (workItem.Fields.GetValueOrDefault("Priority")?.ToString() != "1")
        return false;
    
    return true;
}
```

This prevents plugins from doing unnecessary work and allows conditional behavior based on the operation context.

### Error Handling

Always handle errors gracefully. A plugin failure shouldn't break the entire operation:

```csharp
public async Task<WorkItem> TransformAsync(WorkItem workItem, string context)
{
    try
    {
        // Attempt transformation
        var result = ComputeExpensiveMetric(workItem);
        workItem.Fields["Custom.Metric"] = result;
        return workItem;
    }
    catch (Exception ex)
    {
        // Log error but don't throw
        Console.Error.WriteLine($"Plugin {Name} failed: {ex.Message}");
        
        // Return work item unmodified
        return workItem;
    }
}
```

The key principle: log the error, but return the work item in a valid state so processing can continue.

### Performance Considerations

Plugins run for every work item, so performance matters:

- **Keep transformations fast**: Aim for under 100ms per work item
- **Cache expensive operations**: Don't recalculate the same data repeatedly
- **Use async properly**: Don't block on I/O operations
- **Consider batching**: If possible, process multiple items together

Example of efficient caching:

```csharp
public class CachedLookupPlugin : IDataTransformPlugin
{
    private readonly Dictionary<string, string> _cache = new();
    
    public async Task<WorkItem> TransformAsync(WorkItem workItem, string context)
    {
        var key = workItem.Project;
        
        if (!_cache.ContainsKey(key))
        {
            // Expensive lookup only once per project
            _cache[key] = await LookupProjectMetadata(key);
        }
        
        workItem.Fields["Custom.ProjectMeta"] = _cache[key];
        return workItem;
    }
}
```

## Integration with AI and APIs

### MCP Integration

When the MCP server starts, plugins are automatically exposed to AI assistants. The LLM can discover your plugins via the `list_plugins()` tool:

```json
{
  "totalPlugins": 3,
  "plugins": [
    {
      "name": "TimestampTransform",
      "description": "Adds processing timestamp to work items",
      "version": "1.0.0",
      "type": "DataTransform"
    },
    ...
  ]
}
```

AI assistants use your `Description` property to understand when to use your plugin, making it crucial to write clear, purposeful descriptions.

### REST API Exposure

Plugins are also exposed via the REST API:

```bash
curl http://localhost:5000/api/v1/plugins
```

This allows programmatic discovery and integration with other tools in your ecosystem.

## Deployment and Configuration

### Plugin Directory Structure

Plugins can be loaded from two locations:

**1. External Plugin Directory**: `<executable-directory>/plugins/`
- Place custom plugin DLLs here
- Example: `/usr/local/bin/azdw/plugins/MyPlugin.dll`
- Best for organization-specific or third-party plugins

**2. Embedded Plugins**: Built into the application
- Located in the `src/azdw.plugins/` source project
- Compiled directly into the main application
- Best for widely-used, standard functionality

### Deploying Custom Plugins

Step-by-step deployment guide:

**Step 1: Build your plugin**
```bash
cd MyAzdwPlugins
dotnet build -c Release
```

**Step 2: Locate the azdw installation**
```bash
which azdw
# Output: /usr/local/bin/azdw
```

**Step 3: Create plugins directory**
```bash
mkdir -p /usr/local/bin/plugins
```

**Step 4: Copy your plugin**
```bash
cp bin/Release/net8.0/MyAzdwPlugins.dll /usr/local/bin/plugins/
```

**Step 5: Verify it loads**
```bash
azdw query --connections Test --limit 1 --verbose 2>&1 | grep "Loaded.*plugin"
```

You should see output like:
```
Loaded 6 plugins: 3 data transforms, 1 policy enforcers, 2 renderers, 0 query filters
```

### Verifying Plugin Loading

Multiple ways to verify your plugin is working:

**Via CLI with verbose logging:**
```bash
azdw query --connections MyOrg --verbose
```

**Via REST API:**
```bash
curl http://localhost:5000/api/v1/plugins | jq '.plugins[] | select(.name == "TimestampTransform")'
```

**Via MCP (ask the AI):**
```
"List all available plugins"
```

**Test actual functionality:**
```bash
# Query with your plugin
azdw query --connections MyOrg --limit 1 --json | grep "Custom.ProcessedAt"

# Should show your plugin's field
"Custom.ProcessedAt": "2025-11-16T23:30:00Z"
```

## Troubleshooting

### Common Issues

**Issue: Plugin not loading**

Possible causes:
- DLL not in correct directory (should be `<azdw-dir>/plugins/`)
- Missing dependencies (ensure all referenced DLLs are present)
- MEF export missing (`[Export(typeof(IDataTransformPlugin))]`)
- Target framework mismatch (plugin must target .NET 10)

Check logs with `--verbose` flag for error messages.

**Issue: Plugin loads but doesn't execute**

Check:
- Is `CanTransform/CanValidate/CanFilter` returning `true`?
- Is the plugin registered for the correct interface type?
- Are there exceptions being swallowed? Add logging.

**Issue: Plugin causes errors**

Debug strategy:
1. Run with `--no-plugins` to confirm core functionality works
2. Enable verbose logging
3. Add try-catch blocks with detailed error logging
4. Test plugin in isolation with unit tests

### Debugging Tools

**Check what's loaded:**
```bash
azdw query --connections MyOrg --verbose 2>&1 | grep -A 10 "Loading plugins"
```

**Compare with/without plugins:**
```bash
diff <(azdw query --connections MyOrg --limit 1 --json) \
     <(azdw query --connections MyOrg --limit 1 --json --no-plugins)
```

**Validate plugin DLL:**
```bash
dotnet --info
ls -lh /usr/local/bin/plugins/
```

## Security Considerations

When developing plugins, keep security in mind:

**Input Validation**: Always validate work item data before processing. Don't assume fields exist or contain expected data types.

```csharp
public bool CanTransform(WorkItem workItem, string context)
{
    if (workItem == null) return false;
    if (string.IsNullOrEmpty(workItem.Title)) return false;
    // Additional validation...
    return true;
}
```

**Avoid Side Effects**: Plugins should not:
- Write to files or databases (except for logging)
- Make external API calls without explicit user consent
- Modify global state
- Access credentials or sensitive data unnecessarily

**Performance Limits**: Implement timeouts for expensive operations to prevent denial-of-service:

```csharp
using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));
var result = await ComputeMetricAsync(workItem, cts.Token);
```

**Logging**: Log errors appropriately but never log:
- Passwords or tokens
- Personal identifiable information (PII)
- Azure DevOps PATs
- Internal IP addresses or infrastructure details

### Plugin Trust and Verification

Starting with version 1.x, azdw implements **plugin security verification** to protect against malicious plugins:

#### How It Works

1. **Plugin Discovery**: azdw scans `<executable-dir>/plugins/` for `*.dll` files
2. **Hash Calculation**: SHA-256 hash computed for each plugin (cached based on file modification time)
1. **Plugin Discovery**: azdw scans `<executable-dir>/plugins/` for `*.dll` files
2. **Hash Calculation**: SHA-256 hash computed for each plugin (cached based on file modification time)
3. **Block List Check**: Hash compared against blocked list - **blocked plugins are NEVER loaded** (even with `--skip-plugin-verification`)
4. **Trust Check**: Hash compared against trusted list in `~/.azdw/trusted-plugins.json`
5. **Signature Validation** (conditional):
   - **Skipped if**: `--skip-plugin-verification` is set
   - **Skipped if**: `--allow-unsigned-plugins` is set (but approval still required)
   - **Required otherwise**: Authenticode signature must be valid
6. **User Approval** (when needed):
   - **Interactive mode**: Shows approval prompt [Yes/No/Skip] with plugin details
   - **JSON mode**: Throws error and exits with code 15 (cannot prompt)
   - **Not needed if**: Plugin hash is in trusted list, or `--skip-plugin-verification` is set
7. **Loading**: Only approved/trusted plugins are loaded into MEF container

#### Security Behavior Decision Matrix

| Plugin State | No Flags | `--allow-unsigned-plugins` | `--skip-plugin-verification` | `--no-plugins` |
|--------------|----------|---------------------------|------------------------------|----------------|
| **Signed & Trusted** | ✅ Load | ✅ Load | ✅ Load | ❌ Skip |
| **Signed & New** | 🔔 Prompt for approval | 🔔 Prompt for approval | ✅ Load + ⚠️ Warning | ❌ Skip |
| **Unsigned & Trusted** | ❌ Reject (require signature) | ✅ Load | ✅ Load + ⚠️ Warning | ❌ Skip |
| **Unsigned & New** | ❌ Reject (require signature) | 🔔 Prompt for approval | ✅ Load + ⚠️ Warning | ❌ Skip |
| **Blocked** | ❌ Skip | ❌ Skip | ❌ Skip (blocked) | ❌ Skip |

**JSON Mode (`--json` flag) Effect:**
- 🔔 **Prompt for approval** → ❌ **Exit with code 15** and error message
- ⚠️ **Warning** → Suppressed (written to logs only)

**Legend:**
- ✅ = Loads successfully
- ❌ = Does not load
- 🔔 = User interaction required
- ⚠️ = Security warning shown

#### Trust Management

The trust configuration is stored in `~/.azdw/trusted-plugins.json`:

```json
{
  "version": "1.0",
  "settings": {
    "requireApproval": true,
    "requireSignature": false
  },
  "trustedPlugins": [
    {
      "name": "MyPlugin",
      "version": "1.0.0",
      "sha256": "a3f8b2c1d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1",
      "approvedAt": "2025-11-17T10:30:00Z",
      "approvedBy": "user@example.com",
      "certificateSubject": "CN=MyCompany, O=MyCompany Inc"
    }
  ],
  "blockedPlugins": [
    {
      "sha256": "b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5",
      "blockedAt": "2025-11-16T15:20:00Z",
      "reason": "Rejected by user"
    }
  ]
}
```

**Pre-trusting plugins for automation:**

To avoid approval prompts in CI/CD or JSON mode, calculate and add the plugin hash:

```bash
# Calculate SHA-256 hash of your plugin
shasum -a 256 MyPlugin.dll

# Add to trusted list in ~/.azdw/trusted-plugins.json
# Use the full 64-character hex hash as the sha256 value
```

**Settings explained:**
- `requireApproval`: If `true`, plugins not in trusted list require approval
- `requireSignature`: If `true`, all plugins must have valid Authenticode signatures (overrides `--allow-unsigned-plugins`)

#### Command-Line Security Options

**`--skip-plugin-verification`**
- **Effect**: Bypasses signature validation and approval prompts for non-blocked plugins
- **Warning**: Shows prominent security warning (unless suppressed with `--json`)
- **Use case**: Trusted development environments, CI/CD pipelines
- **⚠️ SECURITY RISK**: Loads all non-blocked plugins without validation
- **Important**: Block list is ALWAYS enforced - blocked plugins are never loaded

**`--allow-unsigned-plugins`**
- **Effect**: Allows plugins without valid Authenticode signatures, but still requires user approval
- **Behavior**:
  - **Interactive mode** (default): Shows approval prompt with plugin details
  - **JSON mode** (`--json` flag): Fails with exit code 15 and error message
- **Use case**: Loading internally-developed plugins that aren't code-signed
- **Note**: Signed plugins from trusted publishers don't require approval
- **Important**: Block list is ALWAYS enforced - blocked plugins are never loaded

**`--no-plugins`**
- **Effect**: Disables plugin loading entirely (both built-in and custom)
- **Use case**: Debugging, baseline testing, security-conscious environments
- **No approval or verification occurs**: Plugins are never loaded

#### Exit Codes for Automation

When using azdw in scripts or automation pipelines, check these exit codes:

- **Exit 0**: Success - command completed, plugins loaded (if applicable)
- **Exit 15**: Plugin approval required but cannot prompt (JSON mode with `--allow-unsigned-plugins`)
- **Error code**: `PLUGIN_APPROVAL_REQUIRED`

Example script handling:

```bash
#!/bin/bash

# Attempt query with plugins
azdw query --connections Prod --json > output.json
exit_code=$?

if [ $exit_code -eq 15 ]; then
    echo "ERROR: Plugin approval required. Options:"
    echo "  1. Use --skip-plugin-verification (if environment is trusted)"
    echo "  2. Run without --json to approve interactively"
    echo "  3. Pre-trust plugins in ~/.azdw/trusted-plugins.json"
    exit 1
elif [ $exit_code -ne 0 ]; then
    echo "ERROR: Command failed with exit code $exit_code"
    exit $exit_code
fi
```

#### Signing Your Plugins (Recommended)

To avoid approval prompts for your users, **sign your plugins** with Authenticode:

```bash
# Sign with certificate from file
signtool sign /f MyCert.pfx /p MyPassword /fd SHA256 /t http://timestamp.digicert.com MyPlugin.dll

# Sign with certificate from store
signtool sign /n "My Company Certificate" /fd SHA256 /t http://timestamp.digicert.com MyPlugin.dll

# Verify signature
signtool verify /pa MyPlugin.dll
```

**Benefits of signing**:
- Users see your verified publisher name
- No approval prompts for trusted publishers
- Tamper protection via certificate validation
- Professional trust indicators

#### For Plugin Distributors

When distributing plugins:

1. **Sign all plugins** with a valid code-signing certificate
2. **Document your certificate subject** so users can verify it
3. **Provide SHA-256 hashes** for users who want to pre-trust
4. **Use semantic versioning** and document breaking changes
5. **Test on clean systems** to ensure signature validation works

#### For Plugin Users

When loading plugins from third parties:

1. **Check if plugin is signed** and by whom (shown in approval prompt)
2. **Verify the publisher** matches the expected source
3. **Review the SHA-256 hash** if provided by the publisher for verification
4. **Use `--no-plugins`** to test baseline behavior first
5. **Report suspicious plugins** to your security team

**Understanding approval prompts:**

- **[Y] Yes**: Trust this specific plugin version (by hash) permanently
- **[N] No**: Block this plugin permanently (adds to block list)
- **[S] Skip**: Don't load this time, but ask again next run (no trust/block decision)

**JSON mode considerations:**

If you use azdw in scripts with `--json` flag:
- Unapproved plugins will cause **exit code 15** instead of prompting
- Pre-trust plugins in `~/.azdw/trusted-plugins.json`, OR
- Use `--skip-plugin-verification` if the environment is trusted

Example approval prompt:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PLUGIN APPROVAL REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Plugin File:  CustomMetricsPlugin.dll
  Full Path:    /usr/local/bin/azdw/plugins/CustomMetricsPlugin.dll
  File Size:    45.2 KB
  SHA-256:      a3f8b2c1d4e5f6a7b8c9d0e1f2a3b4c5...

  ✓ Valid Authenticode Signature
    Signed by: CN=Acme Corporation, O=Acme Inc
    Thumbprint: 1234567890ABCDEF...

  Do you want to load this plugin?

    [Y] Yes  - Trust and load this plugin
    [N] No   - Block this plugin permanently
    [S] Skip - Ignore this time (ask again next time)

  Your choice [Y/N/S]:
```

## Reference

### Plugin Interfaces

Core interfaces defined in `src/azdw.lib/Extensions/PluginExtensions.cs`:

```csharp
// Base interface for all plugins
public interface IPlugin
{
    string Name { get; }
    string Description { get; }
    string Version { get; }
}

// Data transformation
public interface IDataTransformPlugin : IPlugin
{
    bool CanTransform(WorkItem workItem, string context);
    Task<WorkItem> TransformAsync(WorkItem workItem, string context);
}

// Policy enforcement
public interface IPolicyEnforcementPlugin : IPlugin
{
    bool CanValidate(WorkItem workItem, string context);
    Task<PolicyValidationResult> ValidateAsync(WorkItem workItem, IEnumerable<WorkItemRelationship> relationships, string context);
}

// Custom rendering
public interface ICustomRendererPlugin : IPlugin
{
    IEnumerable<string> SupportedFormats { get; }
    Task<string> RenderAsync(IEnumerable<WorkItem> workItems, IEnumerable<WorkItemRelationship> relationships, string format, Dictionary<string, object>? options);
}

// Query filtering
public interface IQueryFilterPlugin : IPlugin
{
    bool CanFilter(Dictionary<string, object> query, string context);
    Task<Dictionary<string, object>> FilterAsync(Dictionary<string, object> query, string context);
}
```

### Sample Code

Complete working examples are available in:
- **Source Code**: `src/azdw.plugins/` - Built-in plugins showing best practices
- **Test Suite**: `tests/azdw.plugins.tests/` - Unit test examples

### Quick Reference: Security Flags

| Flag | Block List | Trust Check | Signature Check | Approval Required | JSON Mode Behavior |
|------|------------|-------------|-----------------|-------------------|-------------------|
| (none) | ✅ Always | ✅ Yes | ✅ Yes | Only if new & unsigned | ❌ Exit 15 if approval needed |
| `--allow-unsigned-plugins` | ✅ Always | ✅ Yes | ❌ Skip | Always if new | ❌ Exit 15 if approval needed |
| `--skip-plugin-verification` | ✅ Always | ❌ Skip | ❌ Skip | ❌ No | ✅ Load all with warning |
| `--no-plugins` | N/A | N/A | N/A | N/A | ✅ No plugins loaded |

**Key Points:**
- **Block list is ALWAYS enforced** - blocked plugins are never loaded, even with `--skip-plugin-verification`
- **Trusted plugins** (hash in `~/.azdw/trusted-plugins.json`) never require approval
- **Exit code 15** (`PLUGIN_APPROVAL_REQUIRED`) = approval required but can't prompt in JSON mode
- **Security warnings** are suppressed in JSON mode but logged
- **Test Suite**: `tests/azdw.plugins.tests/` - Unit test examples

### Support Resources

- **Issues**: https://github.com/thgossler/azdw/issues
- **Interface Definitions**: `src/azdw.lib/Extensions/PluginExtensions.cs`
- **Example Plugins**: `src/azdw.plugins/`

---

## Summary

The azdw plugin system provides a powerful, type-safe way to extend work item management functionality:

- **Compile-time enforcement** ensures plugins are always properly documented
- **MEF-based discovery** means zero-configuration deployment
- **Multiple plugin types** support diverse extensibility scenarios
- **MCP integration** makes plugins AI-accessible automatically
- **The `--no-plugins` flag** enables easy testing and debugging

Start simple with a data transform plugin, test thoroughly, and expand from there. The compile-time safety and automatic discovery make plugin development straightforward, while the AI integration opens up powerful automation possibilities.
