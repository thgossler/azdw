# Creating Report Templates for azdw

Guide for creating and importing Scriban-based report templates that transform
Azure DevOps work item query results including relationship data into Markdown, 
HTML, CSV, or JSON output.

---

## Approaches

| Method | Best for | AI required |
| ------ | -------- | ----------- |
| `azdw report template ai-generate` | Quick generation from a description | Yes |
| `azdw report template ai-prompt` | Copying a prompt into an external AI chat | No |
| Write manually + `azdw report import-template` | Full control | No |
| MCP tool `azdw_ReportTemplateCreate` | Create directly via MCP | No |
| MCP tool `azdw_ReportTemplateImport` | Import JSON via MCP | No |

---

## Quick Start: AI-Generate a Template

```bash
# Generate and auto-import in one step
azdw report template ai-generate \
  --name "Sprint Summary" \
  --goal "A markdown sprint summary grouped by state with completion percentage" \
  --output-format markdown

# Preview without importing
azdw report template ai-generate \
  --name "Bug Triage Report" \
  --goal "HTML table of open bugs sorted by priority with severity colors" \
  --output-format html \
  --preview

# With all options
azdw report template ai-generate \
  --template-id my-report \
  --name "My Report" \
  --goal "CSV export of all work items with org, project, type, state" \
  --output-format csv \
  --category "Data Export" \
  --tags "csv,export" \
  --overwrite
```

**Options**:

| Option | Description | Default |
| ------ | ----------- | ------- |
| `--template-id`, `-id` | Template ID (lowercase, hyphens) | Derived from `--name` |
| `--name`, `-n` | Display name | Derived from `--template-id` |
| `--goal`, `-g` | Natural language description | Interactive prompt |
| `--output-format` | markdown, html, csv, json, text | markdown |
| `--category` | Template category | AI Generated |
| `--tags` | Comma-separated tags | ai-generated |
| `--overwrite` | Replace existing template | false |
| `--timeout` | AI timeout in seconds | 120 |
| `--preview` | Show JSON without importing | false |
| `--save-raw` | Save raw AI response to file | — |

---

## Quick Start: AI-Prompt for External AI

```bash
# Generate the full prompt (copy into ChatGPT, Claude, etc.)
azdw report template ai-prompt

# With your requirements pre-filled
azdw report template ai-prompt "A weekly status report grouped by team member \
  showing completed and in-progress items with story point totals"
```

The output is a comprehensive prompt that includes all template syntax, data
model, examples, and best practices. Paste it into any AI chat to get a
ready-to-import template.

---

## Manual Template Creation

### Option 1: Raw Template File

Create a file (e.g., `my-report.md`) with Scriban template content, then import:

```bash
azdw report import-template --file my-report.md \
  --template-id my-report \
  --template-name "My Report" \
  --description "Weekly status report" \
  --category "Sprint Reports" \
  --tags "sprint,weekly,markdown"
```

If metadata options are omitted, they are prompted interactively (unless
`--non-interactive` is set).

### Option 2: JSON Metadata File

Create a JSON file with complete template definition:

```json
{
  "id": "my-report",
  "name": "My Report",
  "description": "Weekly status report",
  "engineType": "scriban",
  "content": "<Scriban template content here>",
  "outputFormat": "markdown",
  "mimeType": "text/markdown",
  "fileExtension": ".md",
  "category": "Sprint Reports",
  "tags": ["sprint", "weekly", "markdown"],
  "parameters": {
    "sprint_name": {
      "name": "sprint_name",
      "displayName": "Sprint Name",
      "description": "Name of the sprint",
      "dataType": "string",
      "isRequired": true,
      "placeholderText": "Sprint 2025.1"
    }
  },
  "defaultValues": {
    "sprint_name": "Current Sprint"
  },
  "isEnabled": true,
  "version": "1.0.0",
  "author": "Your Name"
}
```

```bash
azdw report import-template --file my-report.json --overwrite
```

### Option 3: Via MCP Tools

```text
# Create directly with content
azdw_ReportTemplateCreate(name="my-report", content="...", description="...")

# Or import full JSON
azdw_ReportTemplateImport(json="{...}")
```

---

## Using a Template

```bash
# Generate report from a query
azdw report generate --template my-report \
  --types Bug Task --states Active \
  --output report.md

# With custom parameters
azdw report generate --template my-report \
  --types Feature --states Active Done \
  --parameters '{"sprint_name":"Sprint 2025.3"}' \
  --output report.md

# With connection filter
azdw report generate --template my-report \
  --connections myorg \
  --types Bug --states Active
```

---

## Template Data Model

Templates receive these variables at render time:

### Top-Level Variables

| Variable | Type | Description |
| -------- | ---- | ----------- |
| `items` | array | Work item objects (primary data source) |
| `data` | array | Same as `items` (alias) |
| `parameters` | object | User-provided parameters |
| `timestamp` | datetime | Current UTC time at render |
| `template_id` | string | ID of the template |
| `template_name` | string | Display name of the template |
| `output_format` | string | Target format (markdown, html, csv, json) |

### Work Item Properties

Each item in the `items` array:

| Property | Type | Description |
| -------- | ---- | ----------- |
| `id` | int | Work item ID |
| `title` | string | Title |
| `logical_type` | string | Abstracted type (Epic, Feature, UserStory, Task, Bug, etc.) |
| `work_item_type` | string | Same as `logical_type` |
| `type` | string | Same as `logical_type` |
| `state` | string | Current state (New, Active, Resolved, Closed, etc.) |
| `description` | string? | Description/acceptance criteria |
| `priority` | string | Priority (Critical, High, Medium, Low) |
| `assigned_to` | string | Assigned user display name |
| `created_by` | string | Creator display name |
| `created_date` | datetime | Creation timestamp |
| `modified_date` | datetime | Last modification timestamp |
| `changed_date` | datetime | Same as `modified_date` |
| `url` | string | URL to work item in Azure DevOps |
| `web_url` | string | Same as `url` |
| `project` | string | Project name |
| `area_path` | string? | Area path |
| `iteration_path` | string? | Iteration path |
| `tags` | string[] | Tags |
| `connection` | object | Source connection (`name`, `base_url`) |
| `fields` | dict | All raw work item fields (key-value) |

---

## Scriban Template Syntax

### Basics

```scriban
{{# Comment #}}
{{ variable_name }}
{{~ trim_left ~}}   {{# whitespace control #}}
```

### Control Flow

```scriban
{{~ if condition ~}}
  Content when true
{{~ else if other_condition ~}}
  Alternative
{{~ else ~}}
  Default
{{~ end ~}}

{{~ for item in items ~}}
  {{ for.index }}: {{ item.title }}
  {{~ unless for.last ~}}, {{~ end ~}}
{{~ end ~}}
```

### Variables and Assignments

```scriban
{{~ completed = items | where 'state == "Done" || state == "Closed"' ~}}
{{~ count = items | size ~}}
{{~ status = count > 0 ? "Has items" : "Empty" ~}}
```

### Array Operations

| Filter | Usage | Example |
| ------ | ----- | ------- |
| `size` | Count elements | `{{ items \ | size }}` |
| `where` | Filter by condition | `{{ items \ | where 'state == "Active"' }}` |
| `sort_by` | Sort by property | `{{ items \ | sort_by 'created_date' }}` |
| `group_by` | Group by property | `{{ items \ | group_by 'state' }}` |
| `first` | First element | `{{ items \ | first }}` |
| `last` | Last element | `{{ items \ | last }}` |
| `select` | Project to property | `{{ items \ | select 'title' }}` |
| `limit` | First N items | `{{ items \ | limit 5 }}` |

### Math Operations

| Filter | Example |
| ------ | ------- |
| `sum` | `{{ numbers \ | sum }}` |
| `avg` | `{{ numbers \ | avg }}` |
| `min` | `{{ numbers \ | min }}` |
| `max` | `{{ numbers \ | max }}` |

### String and Formatting

| Filter | Example |
| ------ | ------- |
| `to_upper` | `{{ text \ | to_upper }}` |
| `to_lower` | `{{ text \ | to_lower }}` |
| `truncate` | `{{ text \ | truncate 50 }}` |
| `format_date` | `{{ date \ | format_date 'yyyy-MM-dd HH:mm:ss' }}` |
| `format_number` | `{{ count \ | format_number '#,##0' }}` |
| `html_escape` | `{{ content \ | html_escape }}` |
| `js_escape` | `{{ text \ | js_escape }}` |
| `url_encode` | `{{ query \ | url_encode }}` |
| `json` | `{{ object \ | json }}` |

### Custom Functions

| Function | Example |
| -------- | ------- |
| `org_name_from_url` | `{{ connection.base_url \ | org_name_from_url }}` |
| `markdown_table` | `{{ items \ | markdown_table }}` |
| `csv_format` | `{{ items \ | csv_format }}` |

---

## Examples

### Sprint Summary (Markdown)

```scriban
# Sprint Report: {{ parameters.sprint_name }}

**Generated:** {{ timestamp | format_date 'yyyy-MM-dd HH:mm:ss UTC' }}
**Total Items:** {{ items | size }}

## Summary
{{~ completed = items | where 'state == "Done" || state == "Closed"' ~}}
{{~ in_progress = items | where 'state == "Active" || state == "In Progress"' ~}}
{{~ not_started = items | where 'state == "New" || state == "To Do"' ~}}

- Completed: {{ completed | size }}
- In Progress: {{ in_progress | size }}
- Not Started: {{ not_started | size }}

## Completed Work
{{~ if (completed | size) > 0 ~}}
| ID | Title | Type | Assignee |
|-------|-------|------|----------|
{{~ for item in completed ~}}
| [{{ item.id }}]({{ item.url }}) | {{ item.title }} | {{ item.logical_type }} | {{ item.assigned_to }} |
{{~ end ~}}
{{~ else ~}}
No completed items.
{{~ end ~}}
```

### Work Items by State (HTML)

```scriban
<!DOCTYPE html>
<html>
<head>
  <title>{{ parameters.report_title }}</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #4CAF50; color: white; }
  </style>
</head>
<body>
  <h1>{{ parameters.report_title }}</h1>
  <p>Generated: {{ timestamp | format_date 'yyyy-MM-dd HH:mm:ss' }}</p>

  {{~ grouped = items | group_by 'state' ~}}
  {{~ for group in grouped ~}}
  <h2>{{ group.key }} ({{ group.items | size }})</h2>
  <table>
    <thead>
      <tr><th>ID</th><th>Title</th><th>Type</th><th>Assigned To</th></tr>
    </thead>
    <tbody>
    {{~ for item in group.items ~}}
      <tr>
        <td><a href="{{ item.url }}">{{ item.id }}</a></td>
        <td>{{ item.title | html_escape }}</td>
        <td>{{ item.logical_type }}</td>
        <td>{{ item.assigned_to }}</td>
      </tr>
    {{~ end ~}}
    </tbody>
  </table>
  {{~ end ~}}
</body>
</html>
```

### CSV Export

```scriban
ID,Title,Type,State,Assigned To,Project,Organization,URL
{{~ for item in items ~}}
{{ item.id }},"{{ item.title }}",{{ item.logical_type }},{{ item.state }},"{{ item.assigned_to }}",{{ item.project }},"{{ item.connection.base_url | org_name_from_url }}",{{ item.url }}
{{~ end ~}}
```

---

## Common Patterns

### Filtering by Multiple Conditions

```scriban
{{~ active_bugs = items | where 'logical_type == "Bug"' | where 'state == "Active"' ~}}
```

> **Important**: Chain multiple `where` filters. Do NOT use `&&` inside a single
> `where` expression — use chained `where` instead.

### Calculating Percentages

```scriban
{{~ total = items | size ~}}
{{~ completed = items | where 'state == "Closed"' | size ~}}
{{~ completion_rate = (completed / total) * 100 ~}}
Completion: {{ completion_rate | format_number '#0.0' }}%
```

### Grouping and Counting

```scriban
{{~ by_type = items | group_by 'logical_type' ~}}
{{~ for group in by_type ~}}
{{ group.key }}: {{ group.items | size }} items
{{~ end ~}}
```

### Accessing Connection Info

```scriban
{{~ for item in items ~}}
Organization: {{ item.connection.base_url | org_name_from_url }}
Project: {{ item.project }}
{{~ end ~}}
```

---

## Output Format Reference

| Format | Extension | `outputFormat` | `mimeType` |
| ------ | --------- | -------------- | ---------- |
| Markdown | `.md` | `markdown` | `text/markdown` |
| HTML | `.html` | `html` | `text/html` |
| CSV | `.csv` | `csv` | `text/csv` |
| JSON | `.json` | `json` | `application/json` |

---

## Theme & Branding Configuration

The `azdw report template ai-generate` command automatically uses the
configured color theme from `branding.css` when generating HTML templates. This
ensures generated templates match the organization's visual identity.

### Branding File Locations

The branding configuration follows the standard azdw config discovery pattern:

1. **User overrides**: `~/.azdw/config/branding.css` (checked first)
2. **Factory defaults**: `{azdw-install-dir}/config/branding.css` (fallback)

### For AI Agents Creating Templates Manually

When creating HTML templates without using `ai-generate`, read the branding
configuration to ensure visual consistency:

```bash
# Show config directories to find the shipped config path
azdw config paths

# Read branding.css from user override (if exists) or shipped config directory
# User override location:
cat ~/.azdw/config/branding.css

# Shipped config location (in the same directory as the azdw executable):
# e.g., /path/to/azdw/config/branding.css
```

The shipped config directory is shown by `azdw config paths` as
"Shipped Config Directory". The `branding.css` file is located in that directory.

### Key CSS Variables

Use these CSS custom properties in HTML templates for consistent styling:

| Variable | Purpose | Default |
| -------- | ------- | ------- |
| `--accent-primary` | Brand/accent color (links, buttons, highlights) | `#D97757` (coral) |
| `--accent-primary-hover` | Hover state for accent color | `#C4613F` |
| `--bg-primary` | Page background | `#F5F5F0` |
| `--bg-card` | Card/panel backgrounds | `#FAFAF8` |
| `--text-primary` | Main text color | `#1A1A1A` |
| `--text-secondary` | Secondary text | `#5C5C5C` |
| `--text-muted` | Subtle text, labels | `#8C8C8C` |
| `--border-light` | Light borders | `#E5E5E0` |
| `--font-primary` | Main font family | `'Merriweather', Georgia, serif` |
| `--color-success` | Success/completed states | `#228B22` |
| `--color-warning` | Warning/in-progress states | `#B8860B` |
| `--color-error` | Error/bug states | `#cc293d` |
| `--color-epic` | Epic work item type | `#B8540F` |
| `--color-feature` | Feature work item type | `#D97757` |
| `--color-bug` | Bug work item type | `#cc293d` |
| `--color-task` | Task work item type | `#8CAD57` |

### Example: Using Theme Variables in HTML Templates

```scriban
<!DOCTYPE html>
<html>
<head>
  <title>{{ parameters.report_title }}</title>
  <style>
    :root {
      /* Copy these from branding.css or use defaults */
      --accent-primary: #D97757;
      --bg-primary: #F5F5F0;
      --bg-card: #FAFAF8;
      --text-primary: #1A1A1A;
      --border-light: #E5E5E0;
      --font-primary: 'Merriweather', Georgia, serif;
    }
    body {
      font-family: var(--font-primary);
      background: var(--bg-primary);
      color: var(--text-primary);
    }
    .card {
      background: var(--bg-card);
      border: 1px solid var(--border-light);
      border-radius: 12px;
      padding: 24px;
    }
    a { color: var(--accent-primary); }
    a:hover { color: var(--accent-primary-hover); }
  </style>
</head>
<body>
  ...
</body>
</html>
```

> **Tip**: The full `branding.css` file includes font imports, semantic colors,
> work item type colors, badge styles, and layout variables. See
> `config/branding.css` in the azdw installation directory for the complete
> reference.

---

## Best Practices

1. **Use whitespace control** (`{{~` and `~}}`) to avoid extra blank lines
2. **Validate data existence** before accessing — use `if` checks
3. **Escape output** for the target format (`html_escape`, `js_escape`, etc.)
4. **Provide meaningful parameters** for customization
5. **Handle empty collections** with fallback messages
6. **Use descriptive variable names** for intermediate values
7. **Chain `where` filters** instead of compound conditions inside a single
   `where`
8. **Test with edge cases**: empty items, null values, special characters

---

## Template Management Commands

```bash
# List all templates
azdw report template list

# Show template details
azdw report template info --template-id my-report

# Validate template syntax
azdw report template validate --template-id my-report

# Export template for backup
azdw report template export --template-id my-report

# Remove a template
azdw report template remove --template-id my-report --force
```
