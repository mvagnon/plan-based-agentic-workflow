# GitHub PR Review Reference

Use this reference for concrete GitHub CLI and API operations during `review-pr`. The skill body owns the review policy and scoring flow.

## Preflight And PR Resolution

Before reviewing:

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
gh pr view --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author
```

If local changes exist, commit and push them before inspecting/scoring the PR:

```bash
git status --short
git add <paths>
git commit -m "<concise repository-style message>"
git push
```

If commit or push fails, stop the review flow and report the exact failing command.

## Diff And Context

Read PR metadata and diff:

```bash
gh pr view <pr> --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author,files,comments,reviews,reviewDecision,statusCheckRollup
gh pr diff <pr>
gh pr checks <pr>
```

When no PR exists yet, compare the committed branch to the intended base:

```bash
git diff <base-ref>...HEAD
git diff --name-only <base-ref>...HEAD
```

Inspect prior discussion:

```bash
gh api /repos/<owner>/<repo>/issues/<number>/comments --paginate
gh api /repos/<owner>/<repo>/pulls/<number>/comments --paginate
gh api /repos/<owner>/<repo>/pulls/<number>/reviews --paginate
```

## Review Threads GraphQL

Query unresolved review threads:

```bash
gh api graphql -f query='
query($owner: String!, $repo: String!, $number: Int!, $cursor: String) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100, after: $cursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first: 20) {
            nodes {
              id
              body
              author { login }
              url
              createdAt
            }
          }
        }
      }
    }
  }
}' -F owner=<owner> -F repo=<repo> -F number=<number>
```

Resolve only threads already addressed by the current diff or fully explained by existing discussion:

```bash
gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread { id isResolved }
  }
}' -F threadId=<thread-id>
```

## PR Body Reconciliation

Edit the PR body with a temp file:

```bash
gh pr view <pr> --json body --jq .body > /tmp/pr-body.md
$EDITOR /tmp/pr-body.md
gh pr edit <pr> --body-file /tmp/pr-body.md
```

Generated reconciliation block:

```markdown
<!-- review-pr:reconciliation:start -->

## Review PR Reconciliation

### Additional Completed Work

- <behavior or file area present in the diff but missing from the PR description>

### Not Completed

- ~~<promised task, checklist item, acceptance criterion, or scope item not implemented by the diff>~~ - <short factual reason>
<!-- review-pr:reconciliation:end -->
```

Remove any legacy generated `review-pr:recap` block while preserving author content.

## Submit Review

Prefer one official PR review with a top-level body and inline comments:

```bash
gh api /repos/<owner>/<repo>/pulls/<number>/reviews \
  --method POST \
  --input <review-payload.json>
```

Payload shape:

```json
{
  "event": "COMMENT",
  "body": "Review score: 17/20 - FIX BEFORE MERGE\n\n- Main risk...\n- Checks reviewed...",
  "comments": [
    {
      "path": "src/file.ts",
      "line": 42,
      "body": "Fix this because it can break production behavior."
    }
  ]
}
```

When inline review API submission is unavailable, fall back to a top-level comment and report that inline comments could not be posted:

```bash
gh pr comment <pr> --body-file <review-body-file>
```

Mark strong draft PRs ready only after the final score is greater than 18:

```bash
gh pr ready <pr>
```
