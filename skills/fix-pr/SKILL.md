---
name: fix-pr
description: Use this skill after a PR review, low score, requested changes, "fix before merge" verdict, inline comments, or reviewer recommendations in the plan-based agentic workflow. It analyzes the whole PR and review feedback, uses Plan-mode structured clarification when available for ambiguous fixes that need user decisions, applies focused corrections in the current checkout, runs relevant checks, commits and pushes the PR branch, then replies to and resolves GitHub review threads with gh CLI/API when possible.
---

# Fix PR

## Purpose

Turn PR review feedback into a focused corrective implementation pass. Analyze the full PR, all review comments, inline threads, checks, and cited lines; ask the user for every decision that cannot be safely inferred; then fix the code, verify it, push it, and update the PR conversations.

This skill is for remediation after review. It is not a replacement for `review-pr`: do not rescore the PR, approve it, merge it, close issues, or move PM items unless the user explicitly asks.

## Portability Contract

This skill must work in Codex, Claude Code, Antigravity CLI, and other Agent Skills compatible runners. Treat runner-specific features as optional accelerators only.

- Do not rely on runner-specific environment variables or path substitutions.
- Resolve bundled references relative to this `SKILL.md` file.
- Read invocation input from the host runner's normal mechanism: `$ARGUMENTS`, slash-command arguments, command arguments, injected raw arguments, or the surrounding user message.
- If Plan mode is available, use the built-in structured question or clarification tool for ambiguous fixes that need user decisions.
- If Plan mode or structured clarification tools are not available, proceed using available context for unambiguous fixes. Ask concise chat questions and wait for answers before editing ambiguous items.

## Input Contract

Read `$ARGUMENTS` or equivalent invocation input as a loose key-value contract:

- `PR`: optional. Accept a PR URL, PR number, or branch name. If omitted, infer the PR from the current branch with `gh pr view`.
- `Repository`: optional. Accept `owner/repo` or infer it from the current git remote.
- `Scope`: optional. Accept a subset such as `blockers only`, `all review comments`, a reviewer name, a comment URL, or a review thread URL. Default to all unresolved actionable feedback.

Ask one concise question only when the PR cannot be resolved or multiple PRs match the provided input. Do not guess between candidate PRs.

## Required Context

Before deciding what to fix:

1. Identify the repository root, current branch, remotes, and local status.
2. Resolve the PR number, repository owner/name, URL, state, draft state, base ref, head ref, and head repository.
3. Read the PR title, body, changed files, diff, reviews, issue comments, review comments, review threads, and checks.
4. Use Serena MCP to inspect cited lines plus nearby code, tests, schemas, services, routes, components, or docs needed to understand the feedback. If Serena is unavailable, stop and report the missing required dependency instead of applying fixes from local search alone.
5. Read project instructions in scope, such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, architecture docs, and directly relevant package docs.
6. Discover existing code, validation, typing, business logic, and design-system patterns before adding anything new.
7. Treat outdated review threads as context: verify whether the concern is already fixed by the current head before deciding no action is needed.

Useful GitHub commands:

```bash
gh pr view <pr> --json number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author,files,comments,reviews,reviewDecision,statusCheckRollup
gh pr diff <pr>
gh pr checks <pr>
gh api /repos/<owner>/<repo>/pulls/<number>/comments --paginate
gh api /repos/<owner>/<repo>/pulls/<number>/reviews --paginate
gh api /repos/<owner>/<repo>/issues/<number>/comments --paginate
```

For unresolved review threads and thread resolution, prefer GraphQL through `gh api graphql`. Query `pullRequest.reviewThreads` with pagination, including each thread's `id`, `isResolved`, `isOutdated`, `path`, `line`, `originalLine`, and comments. Resolve handled threads with `resolveReviewThread`, and reply with `addPullRequestReviewThreadReply` when available. If GraphQL thread operations fail, fall back to `gh pr comment` with a clear summary and report that exact thread resolution was unavailable.

## Feedback Triage

Build a feedback ledger before editing. For every review item, record:

- source: reviewer, review, comment URL or thread ID;
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

Ask after collecting the feedback ledger, before editing ambiguous items.

Ask the user when:

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
- Checkout the PR head with `gh pr checkout <pr>` only when the current branch is not already the PR head and doing so will not overwrite local work.
- Preserve staged, unstaged, and unrelated local changes. Do not stash, unstage, commit, revert, or delete unrelated changes unless the user explicitly asks.
- If local changes overlap with the requested fixes, inspect them and work with them when possible. Ask only when safe integration is ambiguous.
- Confirm the user or token can push to the PR head branch. If the PR comes from a fork or protected branch where pushing is unavailable, implement locally when possible and report the push blocker.

### 2. Apply Focused Fixes

- Reuse existing services, hooks, schemas, validators, DTOs, repositories, utilities, components, tokens, variants, and test helpers.
- Keep business rules centralized. Do not duplicate validation, permission checks, transformations, query keys, or formatting rules in a second place.
- Keep handlers/controllers thin and enforce server-side authorization for protected operations.
- Keep UI fixes aligned with existing design-system primitives, loading/error patterns, responsiveness, and accessibility conventions.
- Do not add dependencies, logs, broad refactors, unrelated cleanup, or new tests by default. Add or update tests only when the user, project instructions, or a specific review comment requires it, or when directly affected existing tests must change.
- If a feedback item is best handled by clarification instead of code, prepare a concise factual reply and do not modify code for that item.

### 3. Verify

Run relevant existing checks for the touched area from package scripts, task runners, or CI config. Prefer:

- type checks;
- lint;
- formatting checks;
- focused existing tests directly affected by the fix.

Do not start dev servers, containers, browser automation, or long-running watch commands by default.

Fix critical failures caused by the remediation. Report pre-existing or unrelated failures with concise evidence.

### 4. Commit And Push

Self-review the diff before committing:

- confirm each changed file maps to a feedback item or required verification update;
- remove dead code and unused imports introduced by the fix;
- ensure unrelated user edits remain unstaged unless explicitly included;
- verify no secrets or sensitive data are added.

If code changed, stage only remediation changes, commit with the repository's existing commit style, and push the PR head branch. Use a clear default message such as:

```bash
git commit -m "fix: address PR review feedback"
git push
```

If there are no code changes because every item was already fixed, obsolete, or clarification-only, do not create an empty commit.

### 5. Update PR Conversations

After push or clarification:

- Reply to each handled review thread or comment with what changed, the commit SHA when available, and any checks run.
- Resolve the thread when the issue was fixed, already fixed, or fully clarified and the API supports resolution.
- Do not resolve threads that still need reviewer or user confirmation.
- Add one top-level PR comment summarizing fixed items, clarification-only items, checks, commit SHA, and remaining items.
- Do not edit PR title or body unless a review comment explicitly requests it or the fix materially changes the PR's stated scope. If editing the body, preserve author content.
- Do not mark the PR ready, approve it, merge it, close linked issues, or update PM status unless explicitly requested.

Use official GitHub tooling. Prefer thread-specific GraphQL replies/resolution. Fall back to `gh pr comment <pr> --body-file <file>` for the top-level summary or when thread-specific operations are unavailable.

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

- Run `review-pr pr="<url>"` again if a fresh production-readiness score is needed.
```

Keep the final answer concise and factual. Do not claim a thread was resolved unless the GitHub operation succeeded.
