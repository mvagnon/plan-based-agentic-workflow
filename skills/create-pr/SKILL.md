---
name: create-pr
description: "Use this skill after `implement-pm` when implementation branches already exist. It derives PM tool and task IDs from branches named `{pm-tool}/{task-ids}`, creates draft PRs for the current repository and child repositories on matching PM branches, attaches PM task URLs in the PR body, writes PR backlinks to the PM tasks, and immediately runs `review-pr`. Trigger on phrases like create PR, open draft PR, attach tasks to PR, backlink PM tasks, or continue after implement-pm."
---

# Create PR

## Summary

Create draft PRs from implementation branches.

The branch name is the source of truth:

```text
<pm-tool>/<task-ids>
```

The PR body stays minimal because the PM tasks carry the full specification. After creating and backlinking PRs, report every created PR URL to the user, then run `review-pr` and repeat the URL set in the final response.

## Diagram

```mermaid
flowchart TD
  A[Find Git repos] --> B[Read current branch]
  B --> C{Branch matches pm-tool/task-ids?}
  C -->|No| D[Skip child repo or stop if current repo]
  C -->|Yes| E[Resolve PM task URLs]
  E --> F[Create draft PR]
  F --> G[Capture PR URL]
  G --> H[Write PR URL back to PM tasks]
  H --> I[Verify PR body, URL, and backlinks]
  I --> J[Report PR URLs to user]
  J --> K[Run review-pr]
  K --> L[Return PR URLs]
```

## Inputs

No argument is required by default. Resolve the PM tool and task IDs from each repository branch.

Optional overrides:

- `repository`: current repo or child repo path.
- `base`: PR base branch when local branch metadata is missing or wrong.

## References

Load only what is needed:

- `references/pr-and-backlinks.md` for Git/GitHub PR commands, PM task URL resolution, and backlink updates.

## Workflow

### Repository Selection

Use the current Git repository first. If the current directory is a workspace with child Git repositories, include child repositories only when their current branch also matches `<pm-tool>/<task-ids>`.

Do not create branches from this skill. Branches belong to `implement-pm`.

### PR Creation

For each selected repository:

1. Parse `pm-tool` and `task-ids` from the current branch.
2. Resolve every PM task to a stable URL.
3. Read `branch.<branch>.pbaw-base` from local Git config. If missing, use the repository default branch unless the user provided `base`.
4. Create a draft PR and capture its URL.
5. Put PM task URLs at the top of the PR body.
6. Write the PR URL back to each PM task through a dedicated PR field, relation, comment, or description fallback.
7. Re-read enough state to verify the PR body and PM backlinks.
8. Report every created PR URL to the user.
9. Keep every created PR URL for the final response.
10. Immediately run `review-pr` for the created PR set.

### Rules

- Keep PR title and body short.
- Do not copy full task bodies into the PR.
- Do not invent expected outcomes, validation plans, labels, or PM statuses.
- For GitHub Issues, use one closing keyword per issue when the PR base supports native linking.
- For non-GitHub PM tasks, verify every PR URL after backlinking, especially when one task spans several repositories.
- Always report every created PR URL before `review-pr`, then return the same URL set in the final response, including when `review-pr` blocks or fails. For multi-repository PR sets, list one URL per repository.
- Do not mark tasks done.
- Do not merge.
- Stop before `review-pr` if any required task URL or PR backlink cannot be verified.

## Expected Response Format

### Response

Return this only after `review-pr` finishes or if PR creation/backlinking is blocked.

```markdown
## Create PR

Created PR URLs:

- <repo path>: <draft PR URL>

PM tasks:

- <task id/title>: <task URL> - backlink <verified|blocked>

Review PR URLs:

- <repo path>: <PR URL>
```
