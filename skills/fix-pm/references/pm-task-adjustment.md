# PM Task Adjustment Reference

Use this reference to retrieve, update, and verify already-created PM tasks.

## Resolution

Resolve every task from the provided `tasks-url` argument before editing.

Capture:

- stable task ID and URL;
- title and durable body/specification fields;
- dependency relations or dependency links;
- status, labels, assignees, milestones, project fields, and parent/epic links;
- recent relevant comments;
- PR backlinks or implementation links.

Do not mutate fields that are not part of the requested change.

## GitHub Issues

Read an issue:

```bash
gh issue view <number-or-url> --repo <owner/repo> --json number,title,body,state,url,labels,milestone,assignees,comments
```

Update title or body:

```bash
gh issue edit <number> --repo <owner/repo> --title "<title>" --body-file <body-file>
```

Add a comment only when the user explicitly asks for an audit note or when the PM workflow uses comments as the accepted update channel:

```bash
gh issue comment <number> --repo <owner/repo> --body-file <body-file>
```

Do not use comments as a substitute for updating the durable issue body when the task specification itself changed.

Close, reopen, label, assign, milestone, or project-field changes require explicit user scope or a confirmed Decision Gate.

## Jira, Notion, Linear, And Other PM Tools

Use the installed MCP or CLI for the selected PM tool.

Before updating items, inspect:

- target workspace/project/database;
- title, body, description, and acceptance-criteria fields;
- dependency, parent, epic, relation, and backlink fields;
- valid statuses, labels, owners, milestones, components, and priority values.

Update only fields that are part of the requested change. If the tool supports native dependency relations, prefer those over body-only dependency text.

## Verification

After every update:

1. Re-read the task through the same PM tool.
2. Compare the durable title/body/dependency fields with the intended update.
3. Record the stable ID and URL for the final response.
4. Report any field that could not be verified.
