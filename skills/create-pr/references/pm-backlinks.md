# PM Backlinks Reference

Use this reference to resolve PM task URLs and write PR backlinks.

## GitHub Issues

Retrieve issue URLs:

```bash
gh issue view <number-or-url> --repo <owner/repo> --json number,title,url,state,body,comments
```

When GitHub closing keywords or linked issue metadata are present in the PR body, no extra issue edit is required for same-repository GitHub Issues.

For cross-repository GitHub Issues where native linking is not available, add a concise comment:

```bash
gh issue comment <issue> --repo <owner/repo> --body-file <comment-file>
```

Comment body:

```markdown
Draft PR: <pr-url>
```

## Jira, Notion, Linear, And Other PM Tools

Use the installed MCP or CLI for the selected `pm-tool`.

Prefer backlink destinations in this order:

1. Dedicated PR, pull request, development, URL, or relation field.
2. Task comment.
3. Clearly delimited PR links section in the task description/body.

Write all PR URLs when one task spans multiple repositories. Do not stop after the first repository PR.

After writing, re-read the task and verify every expected PR URL is present. Treat a missing PR URL as a backlink failure and stop before `review-pr`.

Do not update task status from `create-pr`.
