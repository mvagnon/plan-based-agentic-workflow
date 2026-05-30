---
name: implement-pm
description: Use this skill when the user wants to implement one or more PM tasks, GitHub Issues, Notion tasks, or plan-based workflow items directly in the current repository checkout. It fetches the referenced tasks, creates one dedicated branch and draft PR per invocation before implementation, studies the repository with Serena MCP when available, preserves unrelated local changes, implements all requested tasks in the current checkout, runs relevant checks, and reports the repository path, branch, draft PR, changes, and remaining risks. Trigger on phrases like implement PM tasks, implement these issues, work on these tickets, implement `#123`, or continue the plan-based agentic workflow.
disable-model-invocation: true
---

# Implement PM

## Portability Contract

This skill must work in Codex, Claude Code, Antigravity CLI, and other Agent Skills compatible runners. Treat runner-specific features as optional accelerators only.

- Do not rely on runner-specific environment variables or path substitutions.
- Resolve bundled references relative to this `SKILL.md` file.
- Read invocation input from the host runner's normal mechanism: `$ARGUMENTS`, slash-command arguments, command arguments, injected raw arguments, or the surrounding user message.
- Keep current-checkout safety in the instructions, not in platform-specific frontmatter. Implement directly in the current repository checkout on a dedicated invocation branch while preserving unrelated user changes.

## Input Contract

Read `$ARGUMENTS` or equivalent invocation input as a loose key-value contract:

- `Tasks`: required. Accept GitHub issue numbers, issue URLs, Notion page URLs, task IDs, or a small query that identifies exact PM items.
- `PM Tool`: optional. Default to GitHub Issues for the repository that owns the current git remote.
- `Project`: optional. For GitHub, accept `owner/repo`, a GitHub Project URL/number, or omit it and infer from `git remote`.

Ask one concise question only when the task references cannot be resolved to exact PM items. Do not guess between multiple matching tasks.

## Required Resources

Load these references when doing the corresponding part of the workflow:

- `../../references/implementation-protocol.md`: repository preflight, implementation, verification, and PM update protocol.
- `../../references/serena-codebase-analysis.md`: codebase exploration protocol and Serena fallback rules.
- `../../references/task-specification.md`: how to interpret task bodies created by `feed-pm`.
- `../../references/pm-tools.md`: task retrieval and PM tool conventions.

## Workflow

### 1. Resolve Tasks And Repository

1. Identify the repository root and current remote.
2. Resolve `pm_tool` and `project` with the same defaults as `feed-pm`.
3. Fetch every referenced PM task, including title, body, labels/status, comments that change scope, dependencies, and linked tasks.
4. Refuse ambiguous task references. If a dependency is required but missing from the requested task set, explain the dependency and ask whether to include it.

### 2. Prepare The Branch And Draft PR

Implement directly in the repository root for the current checkout. Do not create a secondary checkout.

Before editing:

- Check the repository root, current branch, remotes, and status.
- Do not move, stage, commit, revert, or delete unrelated user changes.
- Fetch remote refs only when needed for task resolution or implementation context.
- Create or switch to one dedicated branch for this invocation before implementation. Reuse a branch only when continuing the same invocation and the branch clearly matches the same task batch.
- If a task body requires a different base branch than the current checkout, ask how to proceed unless the user already authorized branch changes.
- If existing local changes overlap with the requested implementation, inspect them and work with them when possible. Ask only when the conflict makes safe implementation impossible.
- Open a draft PR for the dedicated branch before implementation edits. The PR description must detail the requested tasks, expected behavior, acceptance criteria, implementation plan, validation plan, and known risks or open questions.
- If the hosting provider cannot create a no-diff draft PR, create a single empty setup commit only to open the draft PR; do not include implementation changes in that commit.
- If authentication, remote configuration, or the PM/Git hosting tool prevents draft PR creation, stop before implementation and report the blocker.

### 3. Implement The Tasks

Work inside the current repository checkout on the dedicated invocation branch, after the draft PR exists.

Use Serena first for exploration when available:

- Activate the repository root as the Serena project.
- Use symbol overview, symbol lookup, reference lookup, diagnostics, and pattern search before reading whole files.
- Reuse existing components, hooks, services, schemas, validators, DTOs, and design-system primitives before creating anything new.

Implementation rules:

- Treat PM task bodies as the implementation contract, but obey repository instructions and user messages with higher priority.
- Keep business logic in one place. If multiple tasks need the same rule or schema, implement the shared foundation once.
- Keep handlers/controllers thin, validate at boundaries, and enforce server-side authorization for protected operations.
- Before committing or pushing implementation changes, review the diff and stage only changes that belong to this invocation. Leave unrelated concurrent user edits unstaged unless the user explicitly includes them.
- Do not add dependencies, create logs, mark PRs ready, merge PRs, or update PM statuses unless explicitly requested. Use `review-pr` as the normal follow-up for PR review and draft-to-ready promotion.
- Do not create tests by default. Add or update tests only when the task/user/project explicitly requires them or when directly affected existing tests must change.

### 4. Verify

Run the relevant existing checks for the changed area from package scripts, task runners, or CI config. Prefer typecheck, lint, format check, and focused tests that already exist. Do not start dev servers, containers, or browser automation by default.

Fix critical failures caused by your changes. Report unrelated pre-existing failures without broad refactors.

### 5. Report

Finish with:

- Repository path and current branch name.
- Draft PR URL.
- Implemented tasks and task URLs.
- Summary of code changes.
- Checks run and results.
- Files changed.
- Known risks, skipped items, and any PM task comments/status changes made.
- Suggested next command: `review-pr pr="<draft-pr-url>"`.

Do not switch away from the invocation branch, mark the PR ready, merge, or update PM statuses unless the user asks.
