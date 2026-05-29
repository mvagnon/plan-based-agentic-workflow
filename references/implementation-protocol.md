# Implementation Protocol

This protocol keeps implementation isolated from the user's current worktree and makes the resulting changes easy to inspect.

## Worktree Setup

Preflight from the original repository:

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
```

Create the worktree root:

```bash
mkdir -p ~/Developer/worktrees
```

Create a branch/worktree:

```bash
git fetch --all --prune
git worktree add -b <branch> ~/Developer/worktrees/<repo-slug>-<task-slug> <base-ref>
```

Reuse rules:

- If the path exists, inspect `git -C <path> status --short --branch` and `git -C <path> rev-parse --show-toplevel`.
- Reuse only when the branch and existing changes clearly belong to the same task batch.
- Otherwise choose a distinct suffix, for example `-2` or a short date.

Branch naming:

```text
agent/<task-ids>-<short-slug>
```

Examples:

- `agent/123-124-workspace-invites`
- `agent/notion-abc123-billing-entitlements`

## Implementation Loop

Inside the worktree:

1. Read project instructions in scope.
2. Install nothing unless dependencies already exist and setup requires it.
3. Use Serena or targeted search to locate existing patterns.
4. Implement the smallest correct change for the task contract.
5. Keep shared logic centralized and reuse existing validation, types, services, hooks, repositories, and UI primitives.
6. Update directly affected docs only when setup, commands, env vars, architecture, endpoints, or data models changed.
7. Run focused checks.
8. Self-review the diff.

## Task Batch Handling

When multiple tasks are requested:

- Respect dependency order.
- Implement shared prerequisites first.
- Keep commits optional; do not commit unless the user asks.
- Do not create separate worktrees per task unless tasks are explicitly independent and the user requests parallelization.
- If one task becomes blocked, continue with independent tasks and report the blocker.

## Verification

Find check commands from package scripts, task runners, CI config, or repository instructions. Prefer:

- type checks;
- lint;
- formatting checks;
- focused existing tests directly affected by the change.

Do not start long-running dev servers, containers, or browser automation unless explicitly requested.

If checks fail:

- Fix failures caused by the implementation.
- Report pre-existing or unrelated failures with the failing command and concise evidence.

## PM Updates

Do not update PM status, add comments, or assign/move tasks unless the user requested it.

When updates are requested, use concise factual comments:

- branch/worktree path;
- completed acceptance criteria;
- checks run;
- blockers or scope changes.

## Final Response Template

```markdown
Implemented in `<worktree-path>` on branch `<branch>`.

Tasks: <urls or ids>

Changes:
- <high-signal change>
- <high-signal change>

Checks:
- `<command>`: passed
- `<command>`: failed/pre-existing <short note>

Remaining:
- <blocker/risk or "none">
```
