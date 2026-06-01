# PM Task Retrieval Reference

Use this reference to resolve exact PM tasks before implementation starts. Never implement from a title alone unless the user provided the full desired change in the prompt.

## GitHub Issues

Discover the repository:

```bash
git rev-parse --show-toplevel
git remote get-url origin
gh repo view --json nameWithOwner,url,defaultBranchRef
```

Retrieve each issue by number or URL:

```bash
gh issue view <number-or-url> --repo <owner/repo> --json number,title,body,state,labels,assignees,milestone,comments,url,closed
```

Search only when the user provides a query rather than exact IDs:

```bash
gh issue list --repo <owner/repo> --search "<query>" --state all --limit 20 --json number,title,state,labels,url
```

Reject ambiguous search results. Ask for the exact issue numbers or URLs when several candidates match.

## Dependencies And Linked Tasks

Inspect issue bodies and comments for dependency references:

```bash
rg -n "(Depends on|Unblocks|blocked by|requires|#\\d+|https://github.com/.*/issues/\\d+)" <issue-body-files>
```

For GitHub linked issue metadata where available:

```bash
gh api /repos/<owner>/<repo>/issues/<issue-number>/timeline --paginate
```

If a requested task depends on another unresolved task that is not in scope, ask whether to include it before implementation.

## Notion And Other PM Tools

Use the relevant MCP or CLI to retrieve:

- title;
- body/content;
- status;
- comments or discussion that change scope;
- dependencies and linked tasks;
- canonical URL;
- schema or properties that can store PR links, such as a dedicated pull request, development, URL, relation, or rich-text field;
- whether comments can be added and whether the description/body can be edited.

If the selected PM tool cannot provide complete task content, stop before branch/PR creation and ask for the missing task details.

For non-GitHub PM tasks, record the best backlink destination before draft PR creation:

1. Prefer a dedicated PR, pull request, development, URL, or relation field.
2. If no dedicated field exists, prefer adding a task comment with the PR URL or URLs.
3. If comments are unavailable but the description/body is writable, append or update a clearly delimited PR links section.
4. If none of these write paths are available, treat PM backlinking as blocked and stop before implementation.

Do not change PM task status while recording PR backlinks unless the user explicitly asked for a status transition.

## Resolved Task Set

Keep one canonical resolved task set and reuse it consistently for:

- branch slug;
- draft PR title and body;
- linked issue syntax;
- non-GitHub PM backlink destination and written PR URL or URLs;
- implementation scope;
- final report.

Do not collapse a multi-task invocation into one representative issue.
