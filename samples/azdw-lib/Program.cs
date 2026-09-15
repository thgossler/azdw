/*
 * This sample uses the public AzdwClient facade from an extracted azdw package.
 * It demonstrates the complete flow without starting azdw.service:
 * load the configured connections, query recent work items, select one item,
 * resolve its relationship closure, and present the hierarchy as a table.
 */
using System.Reflection;
using System.Runtime.InteropServices;
using System.Runtime.Loader;
using Azdw.Lib;
using Azdw.Lib.Models;

// The first argument is normally the extracted client package directory. A
// direct DLL path and environment variables are also supported for quick tests.
var packageRoot = args.FirstOrDefault()
    ?? Environment.GetEnvironmentVariable("AZDW_PACKAGE_ROOT")
    ?? Environment.GetEnvironmentVariable("AZDW_LIB_PATH");

// Fail early with usage guidance instead of letting assembly loading produce a
// less helpful error later in the program.
if (string.IsNullOrWhiteSpace(packageRoot))
{
    Console.Error.WriteLine("Usage: dotnet run --project samples/azdw-lib/Azdw.Lib.Sample.csproj -- <extracted-client-package-or-azdw.lib.dll>");
    Console.Error.WriteLine("Set AzdwLibPath to the azdw.lib.dll path at build time, or use AZDW_LIB_PATH.");
    return 2;
}

// Resolve the library inside the package. The helper understands the layouts
// produced by the different azdw client packaging modes and runtime platforms.
var libraryPath = ResolveLibraryPath(Path.GetFullPath(packageRoot));
if (libraryPath is null)
{
    Console.Error.WriteLine("Could not find azdw.lib.dll in the extracted client package.");
    return 2;
}

// Loading only azdw.lib.dll is not enough: the facade has transitive assemblies
// beside it in the package. This resolver lets .NET find those dependencies
// from the same package directory when the facade first needs them.
var packageBin = Path.GetDirectoryName(libraryPath)!;
Func<AssemblyLoadContext, AssemblyName, Assembly?> resolvePackageAssembly = (_, assemblyName) =>
{
    if (string.IsNullOrWhiteSpace(assemblyName.Name))
    {
        return null;
    }

    var dependencyPath = Path.Combine(packageBin, $"{assemblyName.Name}.dll");
    return File.Exists(dependencyPath)
        ? AssemblyLoadContext.Default.LoadFromAssemblyPath(dependencyPath)
        : null;
};

AssemblyLoadContext.Default.Resolving += resolvePackageAssembly;

try
{
    // AzdwClient owns the reusable library service graph. The async disposable
    // lifetime releases connections and other resources when the sample exits.
    await using var client = await AzdwClient.CreateAsync();

    // Start with the configured connections so the reader can see which
    // providers are available before any work-item query is attempted.
    var connections = await client.GetConnectionsAsync();

    Console.WriteLine("Configured connections");
    if (connections.Count == 0)
    {
        Console.WriteLine("  No connections configured.");
    }
    else
    {
        foreach (var connection in connections)
        {
            Console.WriteLine($"  {connection.Name} | {connection.Provider} | {connection.ConnectionStatus} | {connection.BaseUrl}");
        }
    }

    // Ask the facade for a small, per-connection snapshot ordered by the
    // provider's ChangedDate field. The same result is later used as the pool
    // from which the demonstration selects one work item.
    var recent = await client.GetRecentWorkItemsAsync(new RecentWorkItemsOptions
    {
        MaxResultsPerConnection = 3,
        SortBy = "System.ChangedDate:desc"
    });

    Console.WriteLine();
    Console.WriteLine("Most recently changed 3 work items per connection");
    var recentWorkItems = new List<(Connection Connection, WorkItem WorkItem)>();
    foreach (var connection in recent.Connections)
    {
        Console.WriteLine($"  {connection.Name}");
        var workItems = recent.WorkItemsByConnection[connection.Name];
        if (workItems.Count == 0)
        {
            Console.WriteLine("    No work items returned.");
            continue;
        }

        foreach (var workItem in workItems)
        {
            Console.WriteLine($"    #{workItem.Id} | {workItem.Type} | {workItem.Title} | changed {workItem.ChangedDate:u}");

            // Keep the connection next to the item. A work-item ID alone is
            // not sufficient when several configured providers are involved.
            recentWorkItems.Add((connection, workItem));
        }
    }

    // Query failures are reported separately by the facade so one unavailable
    // connection does not hide successful results from the other connections.
    if (recent.Failures.Count > 0)
    {
        Console.WriteLine();
        Console.WriteLine("Connection query failures");
        foreach (var failure in recent.Failures)
        {
            Console.WriteLine($"  {failure.ConnectionUrl} | {failure.ErrorMessage}");
        }
    }

    // There is nothing meaningful to select or traverse when every query was
    // empty, but an empty result is still a successful sample run.
    if (recentWorkItems.Count == 0)
    {
        Console.WriteLine();
        Console.WriteLine("No recent work items were returned, so there is no closure to explore.");
        return 0;
    }

    // Pick one item from the combined result set to keep the example compact
    // while still exercising the relationship API with live data.
    var selected = recentWorkItems[Random.Shared.Next(recentWorkItems.Count)];
    Console.WriteLine();
    Console.WriteLine($"Randomly selected work item: #{selected.WorkItem.Id} ({selected.Connection.Name})");
    Console.WriteLine($"  {selected.WorkItem.Type}: {selected.WorkItem.Title}");

    // The capability is exposed through the typed facade group rather than by
    // constructing a concrete service. The connection name keeps this lookup
    // scoped to the provider that returned the selected item.
    var closureService = client.Capabilities.WorkItems.Closures
        ?? throw new InvalidOperationException("The reusable closure capability is not available.");
    var closure = await closureService.FindClosureAsync(new ClosureRequest
    {
        WorkItemId = selected.WorkItem.Id,
        ConnectionName = selected.Connection.Name
    });

    // ClosureNode.Depth is positive for ancestors and negative for descendants
    // in the library model. The display convention requested by this sample is
    // the reverse, so the value is inverted once while building table rows.
    Console.WriteLine();
    Console.WriteLine($"Closure: {closure.Status} ({closure.Nodes.Count} work items)");
    if (closure.Nodes.Count == 0)
    {
        Console.WriteLine("No work items were found in the closure.");
    }
    else
    {
        // Sort by displayed hierarchy level first, then by ID so rows remain
        // stable when several items occupy the same level.
        var closureRows = closure.Nodes
            .OrderBy(node => -node.Depth)
            .ThenBy(node => node.WorkItem.Id)
            .Select(node => new[]
            {
                (-node.Depth).ToString("+0;-0;0"),
                $"#{node.WorkItem.Id}",
                node.WorkItem.Type ?? "-",
                node.WorkItem.State ?? "-",
                TrimForTable(node.WorkItem.Title, 72),
                $"{node.WorkItem.ChangedDate:u}"
            })
            .ToList();

        PrintUnicodeTable(
            new[] { "Level", "ID", "Type", "State", "Title", "Changed" },
            closureRows);
    }

    return 0;
}
catch (Exception exception)
{
    // Samples should show a concise failure while preserving the non-zero exit
    // code that makes failures visible to scripts and CI jobs.
    Console.Error.WriteLine($"Sample failed: {exception.Message}");
    return 1;
}
finally
{
    // Remove the process-wide resolver subscription before leaving so this
    // sample does not affect any host that embeds or invokes it repeatedly.
    AssemblyLoadContext.Default.Resolving -= resolvePackageAssembly;
}

static string? ResolveLibraryPath(string packageRoot)
{
    // Client packages have used a few layouts over time. Keep this lookup
    // tolerant so the sample remains useful across package versions and OSes.
    var runtimeId = GetRuntimeId();
    var candidates = new[]
    {
        packageRoot.EndsWith(".dll", StringComparison.OrdinalIgnoreCase) ? packageRoot : null,
        Path.Combine(packageRoot, "bin", "azdw.lib.dll"),
        Path.Combine(packageRoot, "dist", runtimeId, "api", "azdw.lib.dll"),
        Path.Combine(packageRoot, "dist", runtimeId, "azdw.lib.dll"),
        Path.Combine(packageRoot, "dist", runtimeId, "lib", "azdw.lib.dll"),
        Path.Combine(packageRoot, "dist", runtimeId, "azdw", "azdw.lib.dll"),
        Path.Combine(packageRoot, "azdw.lib.dll")
    };

    return candidates.FirstOrDefault(path => !string.IsNullOrWhiteSpace(path) && File.Exists(path));
}

static string GetRuntimeId()
{
    // Match the package naming convention used by azdw's self-contained
    // distributions, such as osx-arm64 or win-x64.
    var architecture = RuntimeInformation.OSArchitecture == Architecture.Arm64 ? "arm64" : "x64";
    var operatingSystem = OperatingSystem.IsWindows() ? "win" : OperatingSystem.IsMacOS() ? "osx" : "linux";
    return $"{operatingSystem}-{architecture}";
}

static string TrimForTable(string? value, int maximumLength)
{
    // Titles and custom fields can contain line breaks or be very long. Make
    // them safe for a single readable table row without changing source data.
    var singleLine = string.IsNullOrWhiteSpace(value)
        ? "-"
        : value.Replace('\r', ' ').Replace('\n', ' ').Trim();

    return singleLine.Length <= maximumLength
        ? singleLine
        : $"{singleLine[..(maximumLength - 3)]}...";
}

static void PrintUnicodeTable(IReadOnlyList<string> headers, IReadOnlyList<string[]> rows)
{
    // Calculate each column width from both its header and its longest value so
    // the box remains aligned for different work-item titles and states.
    var widths = headers
        .Select((header, index) => Math.Max(
            header.Length,
            rows.Count == 0 ? 0 : rows.Max(row => row[index].Length)))
        .ToArray();

    var top = $"┌{string.Join("┬", widths.Select(width => new string('─', width + 2)))}┐";
    var separator = $"├{string.Join("┼", widths.Select(width => new string('─', width + 2)))}┤";
    var bottom = $"└{string.Join("┴", widths.Select(width => new string('─', width + 2)))}┘";

    Console.WriteLine(top);
    PrintRow(headers);
    Console.WriteLine(separator);
    foreach (var row in rows)
    {
        PrintRow(row);
    }

    Console.WriteLine(bottom);

    void PrintRow(IEnumerable<string> values)
    {
        // Padding each cell to the measured width keeps the Unicode borders
        // aligned while allowing the table to adapt to live data.
        Console.WriteLine($"│ {string.Join(" │ ", values.Select((value, index) => value.PadRight(widths[index])))} │");
    }
}
