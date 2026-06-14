# Direct Implementation Reference

Use this reference only when the user chooses to implement directly from an approved `feed-pm` plan instead of creating or updating PM tasks.

## Boundary

Direct implementation is not the default path.

Do not create or update PM tasks, create PR task links, create branches, open PRs, write PR descriptions, post review comments, update PM status, invoke `implement-pm`, launch `review-pr`, or enter the `fix-pr` loop from this path.

Reuse only the implementation development rules:

- `../../implement-pm/references/development-rules.md`

## Worktree Boundary

Implement on the current branch and current worktree. Do not switch branches, create branches, push, or open a PR unless the user separately asks for that outside the direct implementation path.

Before editing, inspect the worktree enough to preserve unrelated local changes. If the current branch/worktree makes direct implementation unsafe, stop and ask for explicit direction.

## Workflow

1. Confirm the user selected direct implementation from the latest approved `feed-pm` plan.
2. Load `../../implement-pm/references/development-rules.md`.
3. Inspect the current branch and worktree for unrelated changes that affect the approved scope.
4. Implement only the approved scope.
5. Run relevant existing checks.
6. Review the diff for scope, reuse, net added lines, dead code, and regressions.
7. Report the implementation result without creating a PR, launching review, or proposing a `fix-pr` loop.
