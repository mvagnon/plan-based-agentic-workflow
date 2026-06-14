# GitHub PR Review Reference

Use this reference for concrete PR inspection, CI, and review commands.

## Resolve PR

```bash
scripts/gh-pr-context.sh [pr-number-url-or-branch] [owner/repo]
```

Child repositories:

```bash
find . -mindepth 2 -maxdepth 4 -name .git -prune -print
git -C <child-repo> status --short --branch
git -C <child-repo> branch --show-current
git -C <child-repo> remote -v
scripts/gh-pr-context.sh <branch-or-pr> <owner/repo>
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
scripts/gh-review-threads.sh <owner> <repo> <pr-number>
```

Avoid duplicate feedback for unresolved valid threads.

## Full Local CI

Discover commands:

```bash
scripts/discover-checks.sh [repo-root]
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
