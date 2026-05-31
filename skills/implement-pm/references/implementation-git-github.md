# Implementation Git And GitHub Reference

Use this reference for the concrete repository, branch, draft PR, linkage, commit, and push commands used by `implement-pm`.

## Preflight

Run from the target repository:

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
git remote get-url origin
```

Record:

- repository root;
- current branch before branch operations;
- current `HEAD`;
- remote owner/repo;
- staged, unstaged, and untracked files.

Do not stash, unstage, reset, delete, or commit unrelated local changes.

## Branch Creation

Create one invocation branch from the currently selected branch and current `HEAD`:

```bash
git switch -c agent/<task-ids>-<short-slug>
git status --short --branch
```

When continuing the same invocation, reuse the existing matching branch:

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

Push the invocation branch before implementation edits:

```bash
git push -u origin HEAD
```

Create the draft PR against the recorded source branch:

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
