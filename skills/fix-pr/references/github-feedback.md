# GitHub Feedback Reference

Use this reference for collecting PR review feedback and mapping each conversation to a fix, clarification, or no-op.

## Resolve PR Context

Default to the PR associated with the current branch:

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
gh pr view --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author
```

Use an explicit PR URL, PR number, or branch only when the user provided one:

```bash
gh pr view <pr> --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author,files,comments,reviews,reviewDecision,statusCheckRollup
gh pr diff <pr>
gh pr checks <pr>
```

## Comments And Reviews

Collect all feedback sources:

```bash
gh api /repos/<owner>/<repo>/issues/<number>/comments --paginate
gh api /repos/<owner>/<repo>/pulls/<number>/comments --paginate
gh api /repos/<owner>/<repo>/pulls/<number>/reviews --paginate
```

Query review threads:

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

## Feedback Ledger

Record one ledger entry per distinct actionable item:

```text
Source:
  Reviewer:
  URL or thread ID:
  Review/comment type:

Location:
  Path:
  Current line:
  Original line:
  Outdated:

Concern:
  Requested action:
  Production risk:

Status:
  needs-fix | needs-user-decision | clarify-only | already-fixed | obsolete | out-of-scope

Planned response:
  Code change:
  Explanation:
  Resolve thread after response: yes/no
```

Group duplicate comments under one corrective action, but keep each GitHub conversation mapped for replies and resolution.
