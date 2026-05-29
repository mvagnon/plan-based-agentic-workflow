# PM Tool Routing

Default to GitHub Issues because it is repository-native, easy to link to code, and reviewable by engineers. Use other PM tools when the user requests them or the repository already exposes a clear integration.

## GitHub Issues Default

Discovery:

```bash
git rev-parse --show-toplevel
git remote get-url origin
gh repo view --json nameWithOwner,url,defaultBranchRef
```

Create approved tasks:

```bash
gh issue create --repo <owner/repo> --title "<title>" --body-file <body-file>
```

After issue creation, update dependency links when needed:

```bash
gh issue edit <number> --repo <owner/repo> --body-file <updated-body-file>
```

Project linking:

- If a GitHub Project is specified and tooling supports it, add the created issues to that project.
- If project fields/statuses are not discoverable, do not invent values. Report the issue URLs and the missing project action.

Labels/milestones/assignees:

- Reuse existing labels and milestones only after listing or inspecting them.
- Do not create new labels by default.
- Do not assign users unless the user requested it or repository convention is clear.

## Notion

Use Notion MCP when available.

Discovery:

- Identify the database/page target from `project`.
- Inspect existing database properties before creating pages.
- Map task fields conservatively:
  - title -> page title;
  - body -> main page content;
  - status -> existing planning/backlog status only if discoverable;
  - dependencies -> relation or plain URLs depending on schema.

If the Notion target or schema is not discoverable, draft the tasks and ask for the database/page.

## Other PM Tools

Use an installed MCP/CLI only when discoverable. Examples: Linear, Jira, Shortcut, Asana.

When the tool is unavailable:

1. Produce approved, ready-to-copy task bodies.
2. Report exactly what target information is missing.
3. Do not silently create tasks in a different PM system.

## Human Approval Gate

Any action that creates, edits, comments on, moves, labels, or assigns PM items requires explicit user approval unless the user already requested that exact side effect in the current turn.

The approval prompt should summarize:

- target PM tool and project/repo;
- number of tasks;
- titles;
- dependency order;
- labels/status fields to apply, if any.

## Retrieval For Implementation

For GitHub:

```bash
gh issue view <number-or-url> --repo <owner/repo> --json number,title,body,state,labels,assignees,milestone,comments,url
```

For Notion or other MCP tools, retrieve the equivalent title, body/content, status, comments, dependencies, and URL.

Never implement from a title alone unless the user explicitly provides the full desired change in the prompt.
