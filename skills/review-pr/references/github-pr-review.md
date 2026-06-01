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

When the current directory is a workspace that may contain multiple independent child repositories, enumerate and inspect child repos before deciding that no PR exists:

```bash
find . -mindepth 2 -maxdepth 4 -name .git -prune -print
git -C <child-repo> status --short --branch
git -C <child-repo> branch --show-current
git -C <child-repo> remote -v
```

Use the parent directory of each `.git` entry as `<child-repo>`.

For each candidate child repository, resolve the PR from the current branch, explicit PR, or explicit branch:

```bash
gh -R <owner/repo> pr view <branch-or-pr> --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author
```

If several child repositories have PRs for the current branch or provided branch, keep them all in scope. If several unrelated PRs match and there is no clear branch or user-provided selector, ask before reviewing.

If local changes exist, commit and push them before inspecting/scoring the PR:

```bash
git status --short
git add <paths>
git commit -m "<concise repository-style message>"
git push
```

If commit or push fails, stop the review flow and report the exact failing command.

Run status, commit, and push commands in the repository that owns the PR. A parent workspace directory with child repos does not have a shared PR status.

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

## Full Local CI Suite

Run the full local CI suite in each affected repository before submitting the PR review comment. Discover repository commands from package scripts, task-runner config, language config, and CI workflows:

```bash
rg --files -g 'package.json' -g 'turbo.json' -g 'pnpm-workspace.yaml' -g 'yarn.lock' -g 'package-lock.json'
rg --files -g 'pyproject.toml' -g 'pytest.ini' -g 'tox.ini' -g 'poetry.lock' -g 'requirements*.txt'
rg --files -g '.github/workflows/*.yml' -g '.github/workflows/*.yaml'
rg -n '"(lint|typecheck|check|test|format|build)"\s*:' package.json apps packages services src 2>/dev/null
```

Prefer the repository's package manager and task runner. Run repo-level commands whenever they exist, for example:

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
```

For Turborepo repositories, run full-repository tasks without filters when available:

```bash
turbo run test
turbo run lint
turbo run typecheck
turbo run build
```

Do not use scoped, package-only, changed-only, affected-only, or filtered commands such as `--filter`, `--affected`, path-specific test patterns, or package-directory commands when a full-repository command exists. Use a scoped command only when the repository has no full command for that check, and report that limitation in the PR comment.

Do not start dev servers, watch commands, containers, or browser automation by default. If the repository's only available check requires one of those, report the command as not run with the reason unless the user explicitly approved it.

For every command, record:

- command and repository path;
- pass/fail/not-run status;
- exit code when available;
- concise failure evidence;
- whether the failure is caused by the PR, likely caused by the PR, or out of scope.

Classify a failure as out of scope only when the failing test, file, package, service, or dependency path is demonstrably unrelated to the PR diff and directly affected code paths. When uncertain, treat the failure as likely caused by the PR for scoring and review purposes.

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
  "body": "Review score: 17/20 - FIX BEFORE MERGE\n\nFull local CI suite:\n- npm test: pass\n- npm run lint: fail, out of scope: pre-existing lint error in scripts/legacy.ts\n\n- Main risk...",
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
