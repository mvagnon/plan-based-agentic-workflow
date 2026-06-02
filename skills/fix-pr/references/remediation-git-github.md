# Remediation Git And GitHub Reference

Use this reference for checkout, commit, push, replies, and thread resolution.

## Checkout

```bash
git status --short --branch
gh pr checkout <pr>
git status --short --branch
```

Do not checkout if it would overwrite staged, unstaged, or unrelated local changes.

For multi-repo remediation, repeat checkout, edit, verify, commit, push, and thread updates per owning child repository.

## Commit And Push

```bash
git status --short
git diff --stat
git diff
git add <paths>
git status --short
git commit -m "fix: address PR review feedback"
git push
git rev-parse --short HEAD
```

If every item was already fixed, obsolete, or clarification-only, do not create an empty commit.

## Thread Replies

Reply to handled threads:

```bash
gh api graphql -f query='
mutation($threadId: ID!, $body: String!) {
  addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) {
    comment { id url }
  }
}' -F threadId=<thread-id> -f body=@<reply-body-file>
```

Reply body should include:

```markdown
Changed: <what changed, or why current head already addresses it>
Commit: <sha or "none">
Checks: <commands and pass/fail/not-run summary>
```

Resolve only handled threads:

```bash
gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread { id isResolved }
  }
}' -F threadId=<thread-id>
```

Do not resolve threads that still need reviewer or user confirmation.

Fallback top-level comment:

```bash
gh pr comment <pr> --body-file <summary-file>
```
