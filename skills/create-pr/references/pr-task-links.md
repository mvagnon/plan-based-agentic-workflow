# PR Task Links Reference

Use this reference for concrete GitHub PR commands and PM task URL resolution.

## Resolve Repositories

Current repository:

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote get-url origin
gh repo view --json nameWithOwner,url,defaultBranchRef
```

Child repositories:

```bash
find . -mindepth 2 -maxdepth 4 -name .git -prune -print
git -C <child-repo> status --short --branch
git -C <child-repo> branch --show-current
git -C <child-repo> remote get-url origin
```

Use the parent directory of each `.git` entry as `<child-repo>`.

## Branch Metadata

The branch must be:

```text
<pm-tool>/<task-ids>
```

Read the base branch recorded by `implement-pm`:

```bash
branch="$(git branch --show-current)"
git config --get "branch.${branch}.pbaw-base"
```

If no base is recorded, use the repository default branch from:

```bash
gh repo view --json defaultBranchRef
```

## PM Task URLs

For GitHub Issues:

```bash
gh issue view <number-or-url> --repo <owner/repo> --json number,title,url,state,body,comments
```

For Jira, Notion, Linear, or other PM tools, use the installed MCP or CLI for the selected `pm-tool`.

Resolve every task to a stable URL before creating the PR.

## Minimal PR Body

Write only task links and optional sibling PR links.

```markdown
## PM Tasks

- <task URL>
- <task URL>

## Related PRs

- <repo>: <PR URL>
```

Omit `Related PRs` when there are no sibling PRs.

For GitHub Issues in the same repository, use closing keywords only when the PR base is the repository's default branch:

```markdown
Resolves #123
Resolves #124
```

Use one closing keyword per issue. Do not use ambiguous grouped references:

```markdown
Resolves #123, #124
#123 #124
```

When the PR base is not the default branch, use plain issue URLs instead of closing keywords.

## Create Draft PR

```bash
git push -u origin HEAD
gh pr create --draft --base <base-branch> --head <head-branch> --title "<branch or concise task title>" --body-file <body-file>
gh pr view <pr> --json number,url,body,baseRefName,headRefName,closingIssuesReferences,linkedIssues
```

Capture each `url` value in a per-repository ledger for the final `create-pr` response.

Verify the PR body contains every required PM task URL or supported GitHub closing keyword. If closing keywords were expected to link issues, verify each issue appears in `closingIssuesReferences` or `linkedIssues`. If any required task link is missing from the PR body, update the PR body before running `review-pr`.

```bash
gh pr edit <pr> --body-file <body-file>
```

If the provider requires a diff before PR creation, stop and report that implementation commits are missing. Do not create empty commits from `create-pr`.

## PM Task Mutation Boundary

Do not write PR URLs, comments, fields, relations, description changes, or status changes back to PM tasks from `create-pr`.

When one task spans multiple repositories, include the same PM task URL in every relevant PR body. Do not stop after the first repository PR.
