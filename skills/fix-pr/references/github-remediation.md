# GitHub Remediation Reference

Use this reference for collecting PR feedback, building the remediation ledger, checking out the PR branch, committing, pushing, replying, and resolving handled threads.

## Resolve PR Context

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
gh pr view --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author,files,comments,reviews,reviewDecision,statusCheckRollup
gh pr diff
gh pr checks
```

Child repositories:

```bash
find . -mindepth 2 -maxdepth 4 -name .git -prune -print
git -C <child-repo> status --short --branch
git -C <child-repo> branch --show-current
git -C <child-repo> remote -v
```

Resolve matching child PRs:

```bash
gh -R <owner/repo> pr view <branch-or-pr> --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author,files,comments,reviews,reviewDecision,statusCheckRollup
```

## Comments, Reviews, And Threads

```bash
gh api /repos/<owner>/<repo>/issues/<number>/comments --paginate
gh api /repos/<owner>/<repo>/pulls/<number>/comments --paginate
gh api /repos/<owner>/<repo>/pulls/<number>/reviews --paginate
```

Review threads, including outdated and resolved threads:

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

Paginate until `hasNextPage` is false.

Treat outdated threads as historical context. Before marking them obsolete or already fixed, inspect current head and verify whether the concern is actually addressed.

## Feedback Ledger

Record one entry per distinct actionable item:

```text
Source:
Location:
Concern:
Production risk:
Status: needs-fix | needs-user-decision | clarify-only | already-fixed | obsolete | out-of-scope
Planned response:
Current head verification:
Threads/comments to reply to:
Resolve after response: yes/no
```

Group duplicates under one fix, but keep every GitHub conversation mapped.

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
