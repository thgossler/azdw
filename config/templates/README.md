# Template Directory

This directory contains default report templates for the Azure DevOps Work Item Handler Library.

## Available Templates

### Sprint Reports
- **sprint-report-md.json** - Comprehensive sprint report in Markdown format showing completed, in-progress, and remaining work with metrics
- **sprint-retro-html.json** - Sprint retrospective report in HTML format
- **sprint-summary-md.json** - Sprint summary in Markdown format

### Dashboards
- **team-dashboard-interactive-html.json** - Interactive HTML dashboard with charts and metrics for team progress visualization
- **team-dashboard-scriban-html.json** - Scriban-rendered HTML dashboard with team and relationship summaries
- **delivery-plan-html.json** - Interactive delivery plan resembling Azure DevOps Delivery Plans with timeline view, team rows, work item cards organized by iterations, filtering, zoom controls, and collapsible teams

### Release Management
- **release-notes-md.json** - Release notes generator that categorizes work items into features, bug fixes, and technical improvements

### Data Export
- **work-items-export-csv.json** - Flexible CSV export with customizable column selection

### Work Item Analysis
- **default.json** - Default work-item analysis output
- **feature-closure-summary-md.json** - Markdown summary of a feature and its relationship closure
- **work-item-analysis-html.json** - Detailed work-item analysis in HTML format
- **work-summary-md.json** - Work-item summary in Markdown format

`report-template-schema.json` is the validation schema for report templates and is not a renderable template.

## Template Structure

Each template is a JSON file containing:
- **Template metadata** (id, name, description, category, tags)
- **Scriban template content** for rendering
- **Parameters** for customization
- **Output format** specification
- **Supported data types**

## Using Templates

Templates can be used through:

### 1. CLI - Direct Query + Generate (Recommended)
Query work items and generate reports in a single command:

```bash
# Sprint report with query filters
azdw report generate \
  --template-id sprint-report-md \
  --types Feature,UserStory,Task \
  --states Done,Closed \
  --iteration "Sprint 42" \
  --parameters '{"sprint_name":"Sprint 42","team":"Platform"}' \
  --output sprint-report.md

# Release notes for recent changes
azdw report generate \
  --template-id release-notes-md \
  --states Closed,Done \
  --created-after 2025-10-01 \
  --parameters '{"version":"2.0.0","release_date":"2025-11-15"}' \
  --output release-notes.md

# Team dashboard across multiple connections
azdw report generate \
  --template-id team-dashboard-interactive-html \
  --connections Org1,Org2 \
  --limit 200 \
  --parameters '{"team_name":"Platform Team"}' \
  --output dashboard.html

# CSV export with filtering
azdw report generate \
  --template-id work-items-export-csv \
  --types Bug,Task \
  --states Active,New \
  --assigned-to "john@example.com" \
  --output bugs-and-tasks.csv
```

### 2. CLI - Legacy Two-Step Workflow
Query to JSON file, then generate (backward compatibility):

```bash
# Step 1: Query and save to JSON
azdw query --types Feature --states Done --json > sprint-data.json

# Step 2: Generate report from JSON
azdw report generate \
  --template-id sprint-report-md \
  --data sprint-data.json \
  --parameters '{"sprint_name":"Sprint 42"}' \
  --output sprint-report.md
```

### 3. Template Service
Programmatic access via `TemplateService`:

```csharp
var templateService = serviceProvider.GetRequiredService<ITemplateService>();
var result = await templateService.RenderTemplateAsync("sprint-report-md", workItems, parameters);
```

### 4. Custom Templates
Create your own by following the same JSON structure

## Template Development

To create custom templates:
1. Copy an existing template as a starting point
2. Modify the template content using Scriban syntax
3. Update parameters and metadata
4. Save with a unique ID
5. Test with sample data

For Scriban syntax reference, see: https://github.com/scriban/scriban/blob/master/doc/language.md

### VS Code Extensions for Template Editing

**Pain Point**: Template content in JSON files is stored as a single-line string with JSON double-escaped line breaks, making direct editing challenging.

**Solution**: Use these VS Code extensions to simplify template editing:

1. **[Escape Buster](https://marketplace.visualstudio.com/items?itemName=deng-wt.escape-buster)**  
   - Allows opening JSON string content in a separate editor tab
   - Automatically handles JSON escaping/unescaping when saving
   - **Usage**: Right-click on the template content string → "Escape Buster: Edit String in New Tab"

2. **[Scriban Language](https://marketplace.visualstudio.com/items?itemName=ThumNet.vscode-scriban-language)**  
   - Provides syntax highlighting for Scriban templates
   - Offers IntelliSense and code completion
   - Improves readability of template logic

**Workflow**:
1. Install both extensions in VS Code
2. Open a template JSON file (e.g., `sprint-report-md.json`)
3. Right-click on the `"template"` field value → "Escape Buster: Edit String in New Tab"
4. Edit the Scriban template with full syntax highlighting and formatting
5. Save the temporary tab to automatically update the JSON file with proper escaping

## Template Categories

- **Reports** - Summary and detailed reports
- **Dashboards** - Interactive visualizations
- **Export** - Data export formats
- **Sprint Reports** - Agile sprint analysis
- **Release Management** - Release notes and changelogs
- **Charts** - Data visualizations and graphs