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

When invoked from a workspace that may contain multiple independent child repositories, enumerate and inspect child repos before deciding that no PR exists:

```bash
find . -mindepth 2 -maxdepth 4 -name .git -prune -print
git -C <child-repo> status --short --branch
git -C <child-repo> branch --show-current
git -C <child-repo> remote -v
```

Use the parent directory of each `.git` entry as `<child-repo>`.

Resolve PRs from each candidate child repository when they match the current branch, provided branch, explicit PR URL, or the PRs reported by a preceding multi-repo `review-pr` run:

```bash
gh -R <owner/repo> pr view <branch-or-pr> --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author,files,comments,reviews,reviewDecision,statusCheckRollup
```

Keep matching child-repository PRs in scope together. Ask only when several unrelated PRs match and no branch, URL, repository, or prior review output disambiguates them.

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
