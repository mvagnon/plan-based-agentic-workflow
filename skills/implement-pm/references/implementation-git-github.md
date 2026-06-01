# Implementation Git And GitHub Reference

Use this reference for the concrete repository, branch, draft PR, linkage, commit, and push commands used by `implement-pm`.

## Preflight

Run from the target repository, or from each affected child repository in a multi-repo workspace:

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
git remote get-url origin
```

When the current directory is not itself the target repository, or may be a workspace containing multiple independent repositories, enumerate child Git repositories and inspect each candidate before choosing targets:

```bash
find . -mindepth 2 -maxdepth 4 -name .git -prune -print
git -C <child-repo> status --short --branch
git -C <child-repo> branch --show-current
git -C <child-repo> remote -v
```

Use the parent directory of each `.git` entry as `<child-repo>`.

Treat nested `.git` entries as independent child repository candidates, not monorepo packages. Do not assume a parent directory with multiple child repos has one shared branch, remote, PR, or check command.

Record:

- repository root;
- current branch before branch operations;
- current `HEAD`;
- remote owner/repo;
- staged, unstaged, and untracked files.

Do not stash, unstage, reset, delete, or commit unrelated local changes.

## Branch Creation

Create one invocation branch from the currently selected branch and current `HEAD` in each affected repository:

```bash
git switch -c agent/<task-ids>-<short-slug>
git status --short --branch
```

When continuing the same invocation, reuse the existing matching branch in that repository:

```bash
git branch --show-current
git status --short --branch
```

Fetch only when task resolution or remote PR creation needs it:

```bash
git fetch --prune origin
```

Do not switch to the default branch first unless the user explicitly authorized a different base.

## Draft PR Creation

Push each invocation branch before implementation edits:

```bash
git push -u origin HEAD
```

Create each draft PR against that repository's recorded source branch:

```bash
gh pr create --draft --base <recorded-source-branch> --head <head-branch> --title "<title>" --body-file <pr-body-file>
```

If the hosting provider requires a diff before PR creation, create one empty setup commit only:

```bash
git commit --allow-empty -m "chore: open implementation draft PR"
git push -u origin HEAD
gh pr create --draft --base <recorded-source-branch> --head <head-branch> --title "<title>" --body-file <pr-body-file>
```

Do not include implementation changes in the setup commit.

For multi-repo work, repeat draft PR creation per affected child repository and keep a task-to-PR map. A non-GitHub PM task that spans several repositories must receive every draft PR URL, not only the first one.

## Required PR Body Linkage

Start the PR body with all concerned task references.

For GitHub Issues, use one closing keyword per issue:

```markdown
Resolves #123, resolves #124, resolves owner/other-repo#125
```

Do not write:

```markdown
Resolves #123, #124
#123 #124
```

After PR creation, confirm the body and linked references:

```bash
gh pr view <pr> --json number,url,body,baseRefName,headRefName,closingIssuesReferences,linkedIssues
```

If the PR targets a non-default branch and closing keywords do not link issues, use available GitHub tooling to create manual links. If manual linking is unavailable, stop before implementation and report the blocker.

## Non-GitHub PM Backlinks

After every required draft PR exists, update each non-GitHub PM task with the PR URL or URLs before implementation edits.

Use the task schema discovered during PM retrieval:

- write to the dedicated PR, pull request, development, URL, relation, or rich-text field when present;
- otherwise add a task comment that lists all PR URLs and the repository each PR belongs to;
- otherwise append or update a clearly delimited PR links section in the task description/body.

Keep the fallback concise and factual:

```markdown
Implementation PRs:
- <owner/repo>: <pr-url>
- <owner/other-repo>: <pr-url>
```

After writing, re-read the PM task through the relevant MCP or CLI and confirm every PR URL is present. If the PM tool has no writable PR field, comment, or description path, stop before implementation and report the blocker.

Do not move the PM task status while backlinking PRs unless the user explicitly requested it.

## Staging And Push

Before committing implementation changes:

```bash
git status --short
git diff --stat
git diff
git diff --cached
```

Stage only invocation changes:

```bash
git add <paths>
git status --short
git commit -m "<repo-style commit message>"
git push
```

Leave unrelated concurrent user edits unstaged unless the user explicitly included them.
