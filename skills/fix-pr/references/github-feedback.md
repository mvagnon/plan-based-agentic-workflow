# GitHub Feedback Reference

Use this reference for collecting PR feedback and building the remediation ledger.

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
