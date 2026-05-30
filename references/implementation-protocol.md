# Implementation Protocol

This protocol implements PM tasks directly in the current repository checkout while preserving staged, unstaged, and unrelated local changes. Each invocation uses one dedicated branch created from the currently selected branch and one draft PR. Use `review-pr` after implementation when the PR needs production-readiness review, PR body reconciliation, and possible promotion out of draft.

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
- Record the currently selected branch before any branch operation and use it as the source/base branch for this invocation.
- Create the dedicated invocation branch from the currently selected branch and current `HEAD`, not from `main`, `master`, the default branch, or a freshly fetched remote ref unless the user explicitly authorizes that branch change.
- Preserve the existing index and working tree. Staged and unstaged changes are part of the current checkout state; do not stash, unstage, stage, commit, revert, or delete them unless they belong to the requested implementation or the user explicitly asks.
- Fetch remote refs only when needed for task resolution or implementation context.
- If the task requires a different base branch than the currently selected branch, ask how to proceed unless the user already authorized branch changes.
- If existing local changes overlap with the requested implementation, inspect them and work with them when possible. Ask only when the conflict makes safe implementation impossible.

Branch naming:

- Create or switch to one dedicated branch per new invocation, using a focused name like `agent/<task-ids>-<short-slug>`.
- Reuse a branch only when continuing the same invocation and the branch clearly matches the same task batch.
- When creating a new invocation branch, use the recorded source branch as the start point. Do not switch to `main`, `master`, or the repository default branch first.
- Do not switch away from the invocation branch while implementing unless the user asks.

## Draft PR First

Before implementation edits:

1. Push the dedicated branch.
2. Open a draft PR against the recorded source/base branch unless the user explicitly authorized a different base.
3. Start the PR description with all concerned task references, using one canonical identifier per task according to context, preferring the task or issue URL when available, otherwise the task ID or associated issue ID. Do not shorten a multi-task invocation to one issue or task reference.
4. For GitHub Issues, link the PR to every concerned issue using GitHub-native linked-issue syntax in the PR description, not plain text only. Use a closing keyword for each issue reference, for example `Resolves #123, resolves #124` or `Resolves owner/repo#123, resolves owner/repo#124`; repeat the keyword for every issue instead of writing `Resolves #123, #124`. If the PR targets a non-default branch and GitHub will not create linked issues from closing keywords, use available GitHub tooling to manually link every issue to the PR; if that cannot be done, stop before implementation and report the linking blocker. Treat this linkage as required PR metadata, while still avoiding separate issue comments, labels, status changes, or manual closure unless the user asks.
5. Write a detailed PR description covering expected behavior, acceptance criteria, implementation plan, validation plan, known risks, and open questions.
6. After creating or updating the draft PR, re-read the PR body or PR metadata and confirm every resolved task is present. For GitHub Issues, confirm every concerned issue is represented in the linked-issue syntax or manual linked-issues metadata before starting implementation edits.

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
