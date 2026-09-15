# Error Handling

## Overview

The `azdw` CLI provides intelligent error handling with user-friendly messages and automatic recovery for authentication failures.

## Authentication Error Handling

### Token Expiration

When a token expires, the CLI:

1. **Shows a brief, clear error message** instead of full stack traces
2. **Provides actionable guidance** for re-authentication
3. **Detects OAuth vs PAT authentication** and tailors the message accordingly

#### Example: OAuth Token Expired

```
❌ Authentication Error: myorg
   Token expired or invalid

💡 Your token has expired. Please sign in again:
   azdw credential add --connection myorg
```

#### Example: PAT Token Issues

```
❌ Authentication Error: myorg
   Authentication failed

💡 Please check your Personal Access Token (PAT) and ensure it:
   - Has not expired
   - Has the required permissions (Work Items: Read)
   - Run: azdw credential add --connection myorg
```

### Multi-Organization Scenarios

When querying across multiple organizations, if one connection's credentials fail:

- The error message clearly identifies **which connection** failed
- Other organizations may still succeed (partial results)
- The user gets specific guidance for the failing connection

## General Error Handling

### Brief Messages (Default)

By default, error messages are concise and actionable:

```
❌ Error executing query: Network error occurred
   
💡 Run with --verbose for detailed error information
```

### Verbose Mode

Use the `--verbose` flag to see full stack traces for debugging:

```bash
azdw query --type "User Story" --state "Active" --verbose
```

Output with `--verbose`:
```
❌ Error executing query: Network error occurred

Stack trace:
   at Azdw.Lib.Services.AzureDevOpsApiClient.QueryWorkItemsAsync(...)
   at Azdw.Commands.QueryCommand.<>c.<CreateQueryCommand>b__0_0(...)
   ...
```

## Exit Codes

The CLI uses standardized exit codes for programmatic consumption:

| Exit Code | Constant               | Description                                                |
|-----------|------------------------|------------------------------------------------------------|
| 0         | `Success`              | Command completed successfully                             |
| 1         | `GeneralError`         | General error occurred                                     |
| 2         | `AuthenticationFailed` | Authentication failed (expired token, invalid credentials) |
| 3         | `ConfigurationError`   | Configuration error                                        |
| 4         | `NetworkError`         | Network error                                              |
| 5         | `InvalidInput`         | Invalid input parameters                                   |
| 10        | `OperationCancelled`   | Operation cancelled by user                                |

### Using Exit Codes in Scripts

```bash
# PowerShell
azdw query --type "Bug" --state "Active"
if ($LASTEXITCODE -eq 2) {
    Write-Host "Authentication failed, please re-authenticate"
    azdw credential add
}

# Bash/Zsh
azdw query --type "Bug" --state "Active"
if [ $? -eq 2 ]; then
    echo "Authentication failed, please re-authenticate"
    azdw credential add
fi
```

## Automatic Retry Logic

The Azure DevOps API client includes automatic retry logic for authentication failures:

1. **HTTP 401 Unauthorized** responses trigger an authentication refresh
2. **For OAuth flows** (Device Code, Interactive Browser):
   - The authentication context is automatically refreshed
   - The original request is retried seamlessly
3. **For PAT tokens**:
   - The error is reported immediately (PATs cannot be automatically refreshed)
   - The user must update their PAT manually

## Best Practices

### For End Users

1. **Use OAuth flows** (Device Code or Interactive Browser) for automatic token refresh
2. **Check error messages** - they provide specific guidance for resolution
3. **Use `--verbose`** only when debugging or reporting issues
4. **Monitor exit codes** in scripts for automated error handling

### For Script Authors

1. **Check exit codes** rather than parsing error messages
2. **Capture stderr** for error messages, stdout for data
3. **Handle authentication failures** (exit code 2) by prompting for re-authentication
4. **Use `--verbose`** in CI/CD pipelines for detailed logs

## Implementation Details

### Last-Chance Exception Handler

The CLI includes a program-level exception handler that catches any unhandled exceptions that escape the command-level exception handlers. This ensures that users always receive human-readable error messages rather than raw stack traces.

#### Features

- **Consistent messaging**: Follows the same pattern as command-level handlers
- **Exception categorization**: Maps exception types to appropriate exit codes
- **Verbose support**: Shows technical details only with `--verbose` flag
- **Actionable guidance**: Provides troubleshooting steps for users

#### Example Output (Normal Mode)

```
❌ An unexpected error occurred
   Network communication error: Unable to connect to the remote server

💡 Run with --verbose for detailed error information

If this problem persists:
  - Check your command syntax with: azdw --help
  - Verify your Azure DevOps credentials
  - Report this issue at: https://github.com/thgossler/azdw
```

#### Example Output (Verbose Mode)

```
❌ An unexpected error occurred
   Network communication error: Unable to connect to the remote server

Stack trace:
   at System.Net.Http.HttpClient.SendAsync(...)
   at Azdw.Lib.Services.AzureDevOpsApiClient.ExecuteAsync(...)
   ...

Inner exception:
  SocketException: No connection could be made because the target machine actively refused it

If this problem persists:
  - Check your command syntax with: azdw --help
  - Verify your Azure DevOps credentials
  - Report this issue at: https://github.com/thgossler/azdw
```

#### Exception Type Mapping

The handler maps exception types to appropriate exit codes:

| Exception Type | Exit Code | User Message |
|---------------|-----------|--------------|
| `ArgumentException`, `ArgumentNullException` | `InvalidInput` | "Invalid command arguments" |
| `UnauthorizedAccessException` | `PermissionDenied` | "Access denied" |
| `FileNotFoundException`, `DirectoryNotFoundException` | `FileIOError` | "File or directory not found" |
| `IOException` | `FileIOError` | "File system error" |
| `HttpRequestException` | `NetworkError` | "Network communication error" |
| `TimeoutException`, `TaskCanceledException` | `NetworkError` | "Operation timed out" |
| `OperationCanceledException` | `OperationCancelled` | "Operation was cancelled" |
| `OutOfMemoryException` | `RuntimeError` | "Insufficient memory" |
| `InvalidOperationException` | `RuntimeError` | "Invalid operation" |
| All others | `GeneralError` | "Unexpected error" |

### Authentication Exception

The `AuthenticationException` class provides metadata for intelligent error handling:

```csharp
public class AuthenticationException : Exception
{
    public string ConnectionName { get; init; }
    public bool IsRetryable { get; init; }  // true for OAuth, false for PAT
    public bool IsTokenExpired { get; init; }
}
```

### API Client Retry Logic

The `AzureDevOpsApiClient` class includes:

- `AuthenticateWithRetryAsync()` - Handles token refresh for OAuth flows
- `ExecuteWithAuthRetryAsync()` - Wraps API calls with automatic 401 retry

### CLI Error Handling

The `QueryCommand` includes structured exception handling:

1. **AuthenticationException** - Specific handling with user guidance
2. **OperationCanceledException** - User cancellation handling
3. **Exception** - General error handling with verbose mode support

## Related Documentation

- [Authentication Types](Authentication-Types.md) - Details on PAT, Device Code, and Interactive Browser auth
- [Exit Codes](../src/azdw/ExitCodes.cs) - Complete list of exit codes
- [CLI Interface](../specs/001-net-8-lts/contracts/cli-interface.md) - Command-line interface specification
