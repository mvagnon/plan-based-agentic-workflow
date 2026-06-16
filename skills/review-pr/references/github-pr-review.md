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

Prefer one official PR review with a scored body and inline comments on changed code:

```bash
gh api /repos/<owner>/<repo>/pulls/<number>/reviews --method POST --input <review-payload.json>
```

Use inline `comments` for every finding that maps to a changed line. Do not bury line-specific findings only in the body. If a finding has no stable changed line, include it in the body under `Findings`.

The review body must include:

| Section | Required content |
| --- | --- |
| Verdict | `PROD READY`, `FIX BEFORE MERGE`, or `DO NOT MERGE`. |
| Score | Total score, for example `10/15`, and one row per scoring category. |
| Checks | Each local CI and required remote check with pass/fail/not-run status and concise evidence. |
| Findings | Required fixes first, each with severity, file/line when available, production impact, and expected remediation. |

Payload shape:

```json
{
  "event": "REQUEST_CHANGES",
  "body": "Verdict: FIX BEFORE MERGE\nScore: 9/15\n\nScore breakdown:\n| Category | Score |\n| --- | ---: |\n| Instruction-file compliance | 2/3 |\n| Reuse | 1/3 |\n| Dependency docs | 2/2 |\n| Maintainability and style | 1/2 |\n| Security | 3/3 |\n| Edge cases | 0/2 |\n\nChecks:\n- npm test: passed\n\nFindings:\n- Major: Missing empty-state handling in src/file.ts:42 causes a user-visible crash.",
  "comments": [
    {
      "path": "src/file.ts",
      "line": 42,
      "body": "Major: Missing empty-state handling here can crash the user flow. Handle the empty collection before rendering this branch."
    }
  ]
}
```

Use `REQUEST_CHANGES` for `FIX BEFORE MERGE` and `DO NOT MERGE`. Use `COMMENT` for `PROD READY` unless the user explicitly requested approval behavior.

Fallback:

```bash
gh pr comment <pr> --body-file <review-body-file>
```

Use the fallback only when the official review API cannot submit. The fallback body must still include verdict, total score, category breakdown, checks, and findings with file/line references when available.

Mark a draft PR ready only when the verdict is `PROD READY`:

```bash
gh pr ready <pr>
```
