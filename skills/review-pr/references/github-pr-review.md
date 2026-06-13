# GitHub PR Review Reference

Use this reference for concrete PR inspection, CI, and review commands.

## Resolve PR

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
gh pr view --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author,files,comments,reviews,reviewDecision,statusCheckRollup,closingIssuesReferences,linkedIssues
gh pr diff
gh pr checks
```

Child repositories:

```bash
find . -mindepth 2 -maxdepth 4 -name .git -prune -print
git -C <child-repo> status --short --branch
git -C <child-repo> branch --show-current
git -C <child-repo> remote -v
gh -R <owner/repo> pr view <branch-or-pr> --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author,files,comments,reviews,reviewDecision,statusCheckRollup,closingIssuesReferences,linkedIssues
```

If several unrelated PRs match, ask for the PR selector before reviewing.

## Linked PM Tasks

Resolve linked tasks before judging scope:

- `closingIssuesReferences` and `linkedIssues` from `gh pr view`;
- PM task URLs in the PR body;
- branch name `<pm-tool>/<task-ids>` when links are missing.

GitHub issue content:

```bash
gh issue view <number-or-url> --json number,title,body,state,labels,comments,url,closed
```

For non-GitHub PM tools, use the installed MCP or CLI. If a task cannot be read, report that limitation and review against the accessible PR body and diff.

## Previous Discussion

```bash
gh api /repos/<owner>/<repo>/issues/<number>/comments --paginate
gh api /repos/<owner>/<repo>/pulls/<number>/comments --paginate
gh api /repos/<owner>/<repo>/pulls/<number>/reviews --paginate
```

Review threads:

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

Avoid duplicate feedback for unresolved valid threads.

## Full Local CI

Discover commands:

```bash
rg --files -g 'package.json' -g 'turbo.json' -g 'pnpm-workspace.yaml' -g 'yarn.lock' -g 'package-lock.json'
rg --files -g 'pyproject.toml' -g 'pytest.ini' -g 'tox.ini' -g 'poetry.lock' -g 'requirements*.txt'
rg --files -g '.github/workflows/*.yml' -g '.github/workflows/*.yaml'
rg -n '"(lint|typecheck|check|test|format|build)"\s*:' package.json apps packages services src 2>/dev/null
```

Prefer repo-level commands when available:

```bash
npm test
npm run lint
npm run typecheck
npm run format:check
npm run build
pnpm test
pnpm lint
pnpm typecheck
pnpm format:check
pnpm build
yarn test
yarn lint
yarn typecheck
yarn build
pytest
ruff check .
mypy .
turbo run test
turbo run lint
turbo run typecheck
turbo run build
```

Do not use scoped, changed-only, affected-only, filtered, watch, dev-server, container, or browser automation commands by default.

Record command, path, pass/fail/not-run status, exit code, concise evidence, and whether the failure is PR-caused, likely PR-caused, or out of scope. Any missing or failing local CI blocks `PROD READY`, merge, and PM task closure.

## Submit Review

Prefer one official PR review:

```bash
gh api /repos/<owner>/<repo>/pulls/<number>/reviews --method POST --input <review-payload.json>
```

Payload shape:

```json
{
  "event": "COMMENT",
  "body": "Verdict: FIX BEFORE MERGE\n\nChecks:\n- npm test: passed\n\nFindings:\n- Major: ...",
  "comments": [
    {
      "path": "src/file.ts",
      "line": 42,
      "body": "Required fix and production impact."
    }
  ]
}
```

Fallback:

```bash
gh pr comment <pr> --body-file <review-body-file>
```

Mark a draft PR ready only when the verdict is `PROD READY`:

```bash
gh pr ready <pr>
```
