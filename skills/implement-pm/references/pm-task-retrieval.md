# PM Task Retrieval Reference

Use this reference after the branch script has completed.

## GitHub Issues

Discover the repository:

```bash
git remote get-url origin
gh repo view --json nameWithOwner,url,defaultBranchRef
```

Retrieve each issue:

```bash
gh issue view <number-or-url> --repo <owner/repo> --json number,title,body,state,labels,assignees,milestone,comments,url,closed
```

Reject ambiguous search results. Ask for exact IDs only when the provided task IDs cannot be resolved.

## Jira, Notion, Linear, And Other PM Tools

Use the installed MCP or CLI for the selected `pm-tool`.

Retrieve:

- title and stable URL;
- body/content;
- comments or discussion that change scope;
- current status;
- dependencies and linked tasks;
- acceptance criteria.

If the selected PM tool cannot provide complete task content and the user did not include the full task body, stop before implementation.

## Dependency Check

If a requested task depends on another unresolved task that is not included in `<task-ids>`, ask whether to include it before implementation.

Do not update PM status or create PR task links from `implement-pm`.
