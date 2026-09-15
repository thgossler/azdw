# Live Data Samples

These samples use an extracted azdw client package to read configured
connections and retrieve the three most recently changed work items for each
available connection. They do not require the azdw source code.

Before running a sample:

- Install or extract an azdw client package for your platform.
- Configure at least one connection and credential under `~/.azdw/` using the
  packaged `azdw` executable.
- Ensure the configured accounts can read work items.

## C# Sample

The C# sample is a small `net10.0` project with a compile-time reference to the
packaged `azdw.lib.dll`. It uses the public `AzdwClient` facade to load the
configured connections, query recent work items, and print the results. It does
not start an API process or make REST calls.

After printing the three most recently changed work items for each connection,
the sample randomly selects one returned work item, finds its closure through
`client.Capabilities.WorkItems.Closures`, and prints the closure in a Unicode
table. The displayed level uses `0` for the selected item, negative values for
items above it in the hierarchy, and positive values for items below it.
Set `AzdwLibPath` to the direct DLL path when building and pass either the
extracted package directory or the direct DLL path as the first application
argument:

```bash
dotnet run --project samples/azdw-lib/Azdw.Lib.Sample.csproj \
  -p:AzdwLibPath=/path/to/extracted-azdw-package/dist/osx-arm64/api/azdw.lib.dll \
  -- /path/to/extracted-azdw-package
dotnet run --project samples/azdw-lib/Azdw.Lib.Sample.csproj \
  -p:AzdwLibPath=/path/to/extracted-azdw-package/dist/osx-arm64/api/azdw.lib.dll \
  -- /path/to/extracted-azdw-package/dist/osx-arm64/api/azdw.lib.dll
```

You can use `AZDW_LIB_PATH` as the build property and runtime fallback instead:

```bash
AZDW_LIB_PATH=/path/to/extracted-azdw-package/dist/osx-arm64/api/azdw.lib.dll \
  dotnet run --project samples/azdw-lib/Azdw.Lib.Sample.csproj
```

The sample selects the platform runtime directory automatically, for example
`dist/osx-arm64/api/azdw.lib.dll` on Apple Silicon macOS.

## PowerShell Module Sample

The PowerShell 7 sample imports the packaged `azdw` module from the extracted
package and calls its cmdlets. The `azdw` executable must already be available
on `PATH`; the module resolves it there. The sample does not invoke the
executable directly and does not require `azdw.service`.

Pass the extracted package directory, or the packaged module manifest, as the
first argument:

```powershell
pwsh -NoProfile -File samples/azdw-pwsh/RecentWorkItems.ps1 /path/to/extracted-azdw-package
pwsh -NoProfile -File samples/azdw-pwsh/RecentWorkItems.ps1 /path/to/extracted-azdw-package/src/azdw.pwsh/azdw.psd1
```

You can use `AZDW_PACKAGE_ROOT` instead of the argument:

```powershell
$env:AZDW_PACKAGE_ROOT = '/path/to/extracted-azdw-package'
pwsh -NoProfile -File samples/azdw-pwsh/RecentWorkItems.ps1
```

The script calls `Get-AzdwConnection` and then `Get-AzdwWorkItem` once per
connection with a limit of three and `System.ChangedDate:desc` ordering.

## Browser REST Sample

This is the independent REST example. The launcher starts the packaged API
service, serves this folder over localhost, waits for both processes to become
ready, and opens the HTML page in the operating system's default browser. It
keeps both child processes running until you press Ctrl+C. Python 3 is not
required; the launcher hosts the page with PowerShell and .NET's
`HttpListener`.

Run it from macOS, Linux, or Windows PowerShell 7:

```powershell
pwsh -NoProfile -File samples/rest-api/Start-RestApiSample.ps1 /path/to/extracted-azdw-package
```

You can also provide the package directory through `AZDW_PACKAGE_ROOT`:

```powershell
$env:AZDW_PACKAGE_ROOT = '/path/to/extracted-azdw-package'
pwsh -NoProfile -File samples/rest-api/Start-RestApiSample.ps1
```

The API listens on `http://127.0.0.1:5016` and the browser sample is served at
`http://127.0.0.1:8080` by default. Use `-ApiPort` or `-SamplePort` when those
ports are already in use. Use `-NoBrowser` to start both servers without
opening a browser automatically. Additional arguments are forwarded to
`azdw.service` after its `--urls` argument.

Once the page opens, click **Load connections and recent work items**. The
sample calls
`GET /api/v1/connections`, then posts a filter with `maxResults: 3` and
`sortBy: "System.ChangedDate:desc"` to
`POST /api/v1/workitems/query?groupByConnection=true&pageSize=3`. Successful and
failed connections are shown separately when the service reports them.
