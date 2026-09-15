---
name: timeline
description: Generate a timeline visualization for a work item and its complete closure
required: workItemId, connectionName
---

Analyze the work item closure and generate a timeline visualization.

**Input**:
- Work Item ID: {{1}}
- Connection Name: {{2}}

**Instructions**:
1. Use the `FindClosure` MCP tool to find the complete hierarchy for work item {{1}} in connection {{2}}
2. Analyze the returned work items to understand the scope:
   - Identify the top-level item (Epic, Feature, etc.)
   - Note all child items and their states
   - Extract dates from work items (Target Date, Start Date, Iteration Path)
3. Use the `GenerateHierarchyVisualization` MCP tool to create a visual representation of the work item structure
4. Summarize the timeline:
   - List key milestones and their current status
   - Identify any items without dates that need attention
   - Highlight items at risk based on state and dates

**Output Format**:
Provide:
1. A summary of the work item hierarchy
2. The visualization output (Graphviz DOT format)
3. A timeline summary with key dates and milestones
4. Recommendations for items needing date assignments
