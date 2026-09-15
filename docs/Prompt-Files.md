# Prompt Files and Slash Commands

`azdw ai-chat` can load reusable Markdown prompt templates and expose them as
slash commands. These files use the `.prompt.md` naming convention and are a
simple way to package repeatable AI workflows for a team or customer.

This guide explains the prompt files that ship in client packages, how users
can customize them, and how to create new ones.

## Where Prompt Files Come From

Prompt files are discovered from two locations, in this priority order:

1. Workspace overrides: `<workspace>/.agents/prompts/`
2. Workspace overrides: `<workspace>/.github/prompts/`
3. Workspace overrides: `<workspace>/.claude/prompts/`
4. User overrides: `~/.azdw/config/ai/prompts/`
5. Shipped defaults: `config/ai/prompts/` next to the `azdw` binaries

If a user prompt defines the same slash command name as a shipped prompt, the
user prompt wins. If a workspace prompt defines the same slash command name,
the workspace prompt wins over both user and shipped prompts.

Client distribution packages can therefore ship ready-to-use examples under
`config/ai/prompts/`, while each user can copy and adapt them under
`~/.azdw/config/ai/prompts/` without modifying the installed package.
Teams can place project-specific prompts under the workspace directories above.

For the broader workspace model, including skills, MCP configuration,
and the external MCP client boundary, see
[Workspace Context and AI Discovery](Workspace-Context-and-AI-Discovery.md).

## Using the Shipped Prompt Files

Client packages may include prompt files such as:

- `config/ai/prompts/standup-example.prompt.md`
- `config/ai/prompts/summarize-example.prompt.md`
- `config/ai/prompts/timeline-example.prompt.md`

To use them:

1. Start chat with `azdw ai-chat`
2. Type `/help` to see the available built-in and prompt-based slash commands
3. Invoke the prompt by its configured slash command name

Examples:

```text
/standup last 3 completed work items in Team Alpha
/summarize-workitems 12345 12346 12347
/timeline 56789 my-ado-connection
```

The slash command name comes from the prompt file frontmatter `name:` field,
not from the filename alone.

## Prompt File Format

A discoverable prompt file should:

- Live in one of the prompt directories above
- Use the `.prompt.md` naming convention
- Start with YAML frontmatter that contains at least `name:`
- Optionally include `description:` for `/help` output

Example:

```md
---
name: summarize-workitems
description: Summarize a list of work items into a brief status report
---

Please analyze and summarize the following work items or query results:

{{query}}
```

Supported frontmatter fields for slash-command discovery:

- `name`: required slash command name
- `description`: optional help text shown in command listings

## Supported Placeholders

Prompt content can contain placeholders that are replaced with the arguments
entered after the slash command.

- `{{query}}`: the full raw argument string
- `{{1}}`, `{{2}}`, `{{3}}`, ...: positional arguments

Examples:

```text
/timeline 56789 my-ado-connection
```

With this prompt body:

```md
Work item: {{1}}
Connection: {{2}}
Original input: {{query}}
```

The prompt sent to the AI becomes:

```text
Work item: 56789
Connection: my-ado-connection
Original input: 56789 my-ado-connection
```

Quoted arguments are supported for positional placeholders.

```text
/my-prompt 12345 "Team Alpha"
```

In that case, `{{1}}` resolves to `12345` and `{{2}}` resolves to
`Team Alpha`.

## Customizing a Shipped Prompt

The recommended workflow is:

1. Copy a shipped prompt from `config/ai/prompts/`
2. Paste it into `~/.azdw/config/ai/prompts/`
3. Rename it if you want a different file name
4. Adjust the `name:` field if you want a different slash command
5. Edit the body and description for your own workflow
6. Restart `azdw ai-chat` and run `/help` to verify it was loaded

If you keep the same `name:` as a shipped prompt, your copy overrides the
package version.

## Creating a New Prompt

Create a file such as `~/.azdw/config/ai/prompts/my-summary.prompt.md` with
content like this:

```md
---
name: my-summary
description: Create a short stakeholder summary for the supplied work items
---

Summarize the following items for a stakeholder update:

{{query}}

Return:
1. Overall status
2. Key achievements
3. Current blockers
4. Recommended next steps
```

Then start chat and invoke it as:

```text
/my-summary 12345 12346 12347
```

## Troubleshooting

If a prompt does not appear in `/help`:

1. Verify the file is in `config/ai/prompts/` or `~/.azdw/config/ai/prompts/`
2. Verify the file starts with `---` frontmatter and includes `name:`
3. Verify the body is not empty
4. Check whether another prompt already uses the same command name
5. Restart `azdw ai-chat` after editing or adding the file

If you still do not see the prompt, compare your file with one of the shipped
examples in `config/ai/prompts/`.