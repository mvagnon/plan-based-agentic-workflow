# Implementation Protocol

This protocol implements PM tasks directly in the current repository checkout while preserving unrelated local changes. Each invocation uses one dedicated branch and one draft PR. Use `review-pr` after implementation when the PR needs production-readiness review, PR body reconciliation, and possible promotion out of draft.

## Current Checkout Setup

Preflight from the repository:

```bash
git rev-parse --show-toplevel
git status --short --branch
git branch --show-current
git remote -v
```

Direct implementation rules:

- Do not create a secondary checkout.
- Treat the current checkout as the implementation location.
- Preserve unrelated user changes; do not move, stage, commit, revert, or delete them.
- Fetch remote refs only when needed for task resolution or implementation context.
- If the task requires a different base branch than the current checkout, ask how to proceed unless the user already authorized branch changes.
- If existing local changes overlap with the requested implementation, inspect them and work with them when possible. Ask only when the conflict makes safe implementation impossible.

Branch naming:

- Create or switch to one dedicated branch per new invocation, using a focused name like `agent/<task-ids>-<short-slug>`.
- Reuse a branch only when continuing the same invocation and the branch clearly matches the same task batch.
- Do not switch away from the invocation branch while implementing unless the user asks.

## Draft PR First

Before implementation edits:

1. Push the dedicated branch.
2. Open a draft PR against the intended base branch.
3. Write a detailed PR description covering task links, expected behavior, acceptance criteria, implementation plan, validation plan, known risks, and open questions.

If the hosting provider cannot create a no-diff draft PR, create a single empty setup commit only to make the branch eligible for PR creation. Do not include implementation changes in that commit.

If authentication, remote configuration, or the PM/Git hosting tool prevents draft PR creation, stop before implementation and report the blocker.

## Implementation Loop

Inside the repository checkout on the invocation branch:

1. Read project instructions in scope.
2. Confirm the draft PR exists before code edits.
3. Install nothing unless dependencies already exist and setup requires it.
4. Use Serena or targeted search to locate existing patterns.
5. Implement the smallest correct change for the task contract.
6. Keep shared logic centralized and reuse existing validation, types, services, hooks, repositories, and UI primitives.
7. Update directly affected docs only when setup, commands, env vars, architecture, endpoints, or data models changed.
8. Run focused checks.
9. Self-review the diff.
10. Stage and push only changes that belong to this invocation. Leave unrelated concurrent user edits unstaged unless the user explicitly includes them.

## Task Batch Handling

When multiple tasks are requested:

- Respect dependency order.
- Implement shared prerequisites first.
- Keep commits focused and scoped to the invocation branch.
- Do not mix unrelated manual edits into implementation commits.
- Do not create separate branches or checkouts per task unless tasks are explicitly independent and the user requests it.
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

- repository path and branch;
- completed acceptance criteria;
- checks run;
- blockers or scope changes.

## Final Response Template

```markdown
Implemented in `<repository-path>` on branch `<branch>`.

Draft PR: <url>

Tasks: <urls or ids>

Changes:
- <high-signal change>
- <high-signal change>

Checks:
- `<command>`: passed
- `<command>`: failed/pre-existing <short note>

Remaining:
- <blocker/risk or "none">

Next:
- Run `review-pr pr="<url>"` when the draft PR is ready for production-readiness review.
```
