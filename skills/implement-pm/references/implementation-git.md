# Implementation Git Reference

Use this reference for technical Git mechanics during `implement-pm`.

## Mandatory Branch Script

Run before any task retrieval or code analysis:

```bash
skills/implement-pm/scripts/create-pm-branch.sh <pm-tool> <task-ids>
```

The script:

- resolves the current Git root;
- records the source branch in local Git config as `branch.<pm-tool>/<task-ids>.pbaw-base`;
- creates or switches to branch `<pm-tool>/<task-ids>`;
- pushes the branch to `origin`;
- sets upstream tracking.

## Status Commands

Use these commands when checking local state:

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
git config --get branch.$(git branch --show-current).pbaw-base
```

Do not stash, reset, unstage, or delete unrelated local changes.

## Commit

When the implementation is ready to publish for `create-pr`, stage only task changes:

```bash
git status --short
git diff --stat
git diff
git add <paths>
git status --short
git commit -m "<repo-style commit message>"
```

Do not push.
Leave unrelated concurrent user edits unstaged unless the user explicitly included them.
