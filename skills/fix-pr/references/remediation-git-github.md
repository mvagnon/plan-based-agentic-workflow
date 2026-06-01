# Remediation Git And GitHub Reference

Use this reference for checkout, commit, push, replies, and thread resolution during `fix-pr`.

## Checkout

Work in the current repository checkout or the child repository checkout that owns the PR when already on the PR head branch.

Checkout the PR head only when needed and safe:

```bash
git status --short --branch
gh pr checkout <pr>
git status --short --branch
```

Do not checkout if it would overwrite staged, unstaged, or unrelated local changes. If overlapping local changes exist, inspect and integrate them or ask when safe integration is ambiguous.

For multi-repo remediation, repeat checkout, edit, verify, commit, push, and thread update operations per owning child repository. Do not stage or commit files from a sibling repository in the current PR's commit.

## Verify Push Access

Inspect PR head metadata:

```bash
gh pr view <pr> --json headRefName,headRepository,headRepositoryOwner,maintainerCanModify
git remote -v
```

If the PR comes from a fork or protected branch where pushing is unavailable, implement locally when possible and report the push blocker.

## Commit And Push

Before committing:

```bash
git status --short
git diff --stat
git diff
git diff --cached
```

Stage only remediation changes:

```bash
git add <paths>
git status --short
git commit -m "fix: address PR review feedback"
git push
git rev-parse --short HEAD
```

If every item was already fixed, obsolete, or clarification-only, do not create an empty commit.

## Reply To Review Threads

Prefer thread-specific replies:

```bash
gh api graphql -f query='
mutation($threadId: ID!, $body: String!) {
  addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) {
    comment { id url }
  }
}' -F threadId=<thread-id> -f body=@<reply-body-file>
```

Resolve handled threads only after the code change or clarification is complete:

```bash
gh api graphql -f query='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread { id isResolved }
  }
}' -F threadId=<thread-id>
```

Do not resolve threads that still need reviewer or user confirmation.

## Fallback PR Comment

When thread-specific replies or resolution are unavailable, add one top-level summary:

```bash
gh pr comment <pr> --body-file <summary-file>
```

Summary template:

```markdown
## Fix PR Update

Commit: <sha or "none">

Fixed:
- <item and thread/comment URL>

Clarified or already addressed:
- <item and reason>

Checks:
- `<command>`: <passed|failed|not run> - <short note>

Remaining:
- <item or "none">
```

Report exact thread operations that failed; do not claim a thread was resolved unless the API call succeeded.
