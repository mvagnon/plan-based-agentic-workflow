---
name: fix-pr
description: Use this skill after a PR review, low score, requested changes, "fix before merge" verdict, inline comments, or reviewer recommendations in the plan-based agentic workflow. By default it fixes the PR associated with the current branch, analyzes the whole PR and review feedback, uses structured clarification/question tooling when available for ambiguous fixes that need user decisions, applies focused corrections in the current checkout, runs relevant checks, commits and pushes the PR branch, then replies to and resolves GitHub review threads with official GitHub tooling when possible.
---

# Fix PR

## Purpose

Turn PR review feedback into a focused corrective implementation pass. Analyze the full PR, all review comments, inline threads, checks, and cited lines; ask the user for every decision that cannot be safely inferred; then fix the code, verify it, push it, and update the PR conversations.

This skill is for remediation after review. It is not a replacement for `review-pr`: do not rescore the PR, approve it, merge it, close issues, or move PM items unless the user explicitly asks.

## Input Contract

No argument is required for the normal workflow. Resolve the PR from the current branch first; this keeps remediation anchored to the branch the user is already working on.

Read the following arguments or equivalent invocation input as optional overrides:

`$ARGUMENTS`

Infer:

- `PR`: optional override. Accept a PR URL, PR number, or branch name only when the user wants to fix a PR other than the one associated with the current branch.
- `Repository`: optional. Accept a URL or repository identifier. Infer it from repository context when safe.
- `Scope`: optional. Accept a subset such as `blockers only`, `all review comments`, a reviewer name, a comment URL, or a review thread URL. Default to all unresolved actionable feedback.

Ask one concise question only when the PR cannot be resolved or multiple PRs match the provided input. Do not guess between candidate PRs.

## Required References

Load these bundled references as needed:

- `references/github-feedback.md`: PR context resolution, review/comment collection, review-thread query mechanics, and feedback ledger template.
- `references/remediation-git-github.md`: checkout, push-access checks, commit/push mechanics, review-thread replies, thread resolution, and fallback PR summary.

References are intentionally technical. Keep the skill body focused on remediation flow and consult the references for commands, payloads, and tool-specific details.

## Required Context

Before deciding what to fix:

1. Identify repository root, current branch, remotes, and local status.
2. Resolve PR number, repository, URL, state, draft state, base ref, head ref, and head repository from the current branch unless the user provided an explicit override.
3. Read PR title, body, changed files, diff, reviews, issue comments, review comments, review threads, and checks.
4. Use Serena MCP to inspect cited lines plus nearby code, tests, schemas, services, routes, components, or docs needed to understand the feedback. If Serena is unavailable, stop and report the missing required dependency instead of applying fixes from local search alone.
5. Read project instructions in scope, such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, architecture docs, and directly relevant package docs.
6. Discover existing code, validation, typing, business logic, and design-system patterns before adding anything new.
7. Treat outdated review threads as context: verify whether the concern is already fixed by the current head before deciding no action is needed.

Use `references/github-feedback.md` for the concrete collection mechanics and feedback ledger template.

## Feedback Triage

Build a feedback ledger before editing. For every review item, record:

- source: reviewer, review, comment URL, or thread ID;
- location: file and current or original line when available;
- requested action or concern;
- current status: `needs-fix`, `needs-user-decision`, `clarify-only`, `already-fixed`, `obsolete`, or `out-of-scope`;
- intended response: code change, explanation, or no action with reason;
- whether the thread should be resolved after the response.

Group duplicate comments under one corrective action, but keep each PR conversation mapped so every reviewer comment gets a response or an explicit reason it was not changed.

Prioritize:

1. Blockers, requested changes, failed checks, and security/correctness issues.
2. Major architecture, validation, data integrity, and regression concerns.
3. Minor actionable fixes.
4. Clarifications and non-actionable comments.

Do not implement nit-only or preference-only changes that conflict with project conventions unless the user explicitly asks.

## Question Policy

Ask after collecting the feedback ledger and before editing ambiguous items.

Ask the user when:

- structured clarification/question tooling is available and an ambiguous fix needs a user decision;
- a review comment conflicts with project instructions, architecture, or another comment;
- the requested fix changes product behavior, API contracts, data models, migrations, permissions, pricing, billing, or user-visible copy in a non-obvious way;
- a comment is unclear and several materially different fixes are plausible;
- the safest fix would be broad refactoring beyond the PR's intended scope;
- resolving a comment would require adding a dependency, creating new tests, changing PM scope, or updating unrelated code.

Do not ask about discoverable facts. Use repository inspection and GitHub context first.

When asking, batch all currently known questions and make each question concrete:

- cite the review comment or file area;
- state the decision needed;
- provide a recommended default when there is a clear conservative option;
- explain the implementation impact in one sentence.

After the user answers, treat the answers as the fix contract. If new ambiguity appears while implementing, stop and ask before guessing.

## Implementation Workflow

### 1. Prepare The Checkout

- Work in the current repository checkout. Do not create a secondary checkout.
- Check local status before branch operations.
- Move to the PR head branch only when the current branch is not already the PR head and doing so will not overwrite local work.
- Preserve staged, unstaged, and unrelated local changes. Do not stash, unstage, commit, revert, or delete unrelated changes unless the user explicitly asks.
- If local changes overlap with the requested fixes, inspect them and work with them when possible. Ask only when safe integration is ambiguous.
- Confirm the user or token can push to the PR head branch. If the PR comes from a fork or protected branch where pushing is unavailable, implement locally when possible and report the push blocker.

Use `references/remediation-git-github.md` for checkout and push-access mechanics.

### 2. Apply Focused Fixes

- Reuse existing services, hooks, schemas, validators, DTOs, repositories, utilities, components, tokens, variants, and test helpers.
- Keep business rules centralized. Do not duplicate validation, permission checks, transformations, query keys, or formatting rules in a second place.
- Keep handlers/controllers thin and enforce server-side authorization for protected operations.
- Keep UI fixes aligned with existing design-system primitives, loading/error patterns, responsiveness, and accessibility conventions.
- Do not add dependencies, logs, broad refactors, unrelated cleanup, or new tests by default.
- Add or update tests only when the user, project instructions, or a specific review comment requires it, or when directly affected existing tests must change.
- If a feedback item is best handled by clarification instead of code, prepare a concise factual reply and do not modify code for that item.

### 3. Verify

Run relevant existing checks for the touched area from package scripts, task runners, or CI config. Prefer type checks, lint, formatting checks, and focused existing tests directly affected by the fix.

Do not start dev servers, containers, browser automation, or long-running watch commands by default.

Fix critical failures caused by the remediation. Report pre-existing or unrelated failures with concise evidence.

### 4. Commit And Push

Self-review the diff before committing:

- confirm each changed file maps to a feedback item or required verification update;
- remove dead code and unused imports introduced by the fix;
- ensure unrelated user edits remain unstaged unless explicitly included;
- verify no secrets or sensitive data are added.

If code changed, stage only remediation changes, commit with the repository's existing commit style, and push the PR head branch. If there are no code changes because every item was already fixed, obsolete, or clarification-only, do not create an empty commit.

Use `references/remediation-git-github.md` for concrete staging, commit, push, and commit SHA capture mechanics.

### 5. Update PR Conversations

After push or clarification:

- reply to each handled review thread or comment with what changed, the commit SHA when available, and any checks run;
- resolve the thread when the issue was fixed, already fixed, or fully clarified and the API supports resolution;
- do not resolve threads that still need reviewer or user confirmation;
- add one top-level PR comment summarizing fixed items, clarification-only items, checks, commit SHA, and remaining items;
- do not edit PR title or body unless a review comment explicitly requests it or the fix materially changes the PR's stated scope;
- do not mark the PR ready, approve it, merge it, close linked issues, or update PM status unless explicitly requested.

Use `references/remediation-git-github.md` for thread replies, thread resolution, and fallback PR summary mechanics.

## Output Format

Return the result in this order:

```markdown
## Fix PR

PR: <url>
Branch: <head branch>
Commit: <sha or "none">

### Fixed

- <feedback item fixed, with file/area and reviewer thread/comment reference>

### Clarified Or Already Addressed

- <feedback item clarified, already fixed, obsolete, or out of scope, with reason>

### PR Updates

- <thread replies, resolved conversations, fallback comments, or unavailable operations>

### Checks

- `<command>`: <passed|failed|not run> - <short note>

### Remaining

- <open reviewer/user decision, failed check, push blocker, or "none">

### Next

- Run `review-pr` again from the PR branch if a fresh production-readiness score is needed.
```

Keep the final answer concise and factual. Do not claim a thread was resolved unless the GitHub operation succeeded.
