# PR And Backlinks Reference

Use this reference for concrete GitHub PR commands, PM task URL resolution, and PR backlinks.

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

When the PR base is not the default branch, first use plain issue URLs. If the hosting provider supports manual issue linking for that base, create the manual links and verify them with `gh pr view`.

## Create Draft PR

```bash
git push -u origin HEAD
gh pr create --draft --base <base-branch> --head <head-branch> --title "<branch or concise task title>" --body-file <body-file>
gh pr view <pr> --json number,url,body,baseRefName,headRefName,closingIssuesReferences,linkedIssues
```

If closing keywords were expected to link issues, verify each issue appears in `closingIssuesReferences` or `linkedIssues`. If the PR base is non-default and links are absent, create manual links when the tool supports it; otherwise keep plain task URLs in the body and report the limitation.

If the provider requires a diff before PR creation, stop and report that implementation commits are missing. Do not create empty commits from `create-pr`.

## Write Backlinks

When GitHub closing keywords or linked issue metadata are present in the PR body, no extra issue edit is required for same-repository GitHub Issues.

For cross-repository GitHub Issues where native linking is not available, add a concise comment:

```bash
gh issue comment <issue> --repo <owner/repo> --body-file <comment-file>
```

Comment body:

```markdown
Draft PR: <pr-url>
```

For Jira, Notion, Linear, or other PM tools, prefer backlink destinations in this order:

1. Dedicated PR, pull request, development, URL, or relation field.
2. Task comment.
3. Clearly delimited PR links section in the task description/body.

Write all PR URLs when one task spans multiple repositories. Do not stop after the first repository PR.

After writing, re-read the task and verify every expected PR URL is present. Treat a missing PR URL as a backlink failure and stop before `review-pr`.

Do not update task status from `create-pr`.
