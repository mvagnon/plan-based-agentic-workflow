---
name: implement-pm
description: Use this skill when the user wants to implement one or more PM tasks, GitHub Issues, Notion tasks, or plan-based workflow items in an isolated git worktree. It fetches the referenced tasks, creates or reuses a worktree under ~/Developer/worktrees, studies the repository with Serena MCP when available, implements all requested tasks in that worktree, runs relevant checks, and reports the branch, worktree path, changes, and remaining risks. Trigger on phrases like implement PM tasks, implement these issues, work on these tickets, create a worktree for `#123`, or continue the plan-based agentic workflow.
disable-model-invocation: true
---

# Implement PM

## Portability Contract

This skill must work in Codex, Claude Code, Antigravity CLI, and other Agent Skills compatible runners. Treat runner-specific features as optional accelerators only.

- Do not rely on runner-specific environment variables or path substitutions.
- Resolve bundled references relative to this `SKILL.md` file.
- Read invocation input from the host runner's normal mechanism: `$ARGUMENTS`, slash-command arguments, command arguments, injected raw arguments, or the surrounding user message.
- Keep worktree safety in the instructions, not in platform-specific frontmatter. Never modify the user's current worktree for task implementation.

## Input Contract

Read `$ARGUMENTS` or equivalent invocation input as a loose key-value contract:

- `Tasks`: required. Accept GitHub issue numbers, issue URLs, Notion page URLs, task IDs, or a small query that identifies exact PM items.
- `PM Tool`: optional. Default to GitHub Issues for the repository that owns the current git remote.
- `Project`: optional. For GitHub, accept `owner/repo`, a GitHub Project URL/number, or omit it and infer from `git remote`.

Ask one concise question only when the task references cannot be resolved to exact PM items. Do not guess between multiple matching tasks.

## Required Resources

Load these references when doing the corresponding part of the workflow:

- `../../references/implementation-protocol.md`: worktree, branch, implementation, verification, and PM update protocol.
- `../../references/serena-codebase-analysis.md`: codebase exploration protocol and Serena fallback rules.
- `../../references/task-specification.md`: how to interpret task bodies created by `feed-pm`.
- `../../references/pm-tools.md`: task retrieval and PM tool conventions.

## Workflow

### 1. Resolve Tasks And Repository

1. Identify the repository root and current remote.
2. Resolve `pm_tool` and `project` with the same defaults as `feed-pm`.
3. Fetch every referenced PM task, including title, body, labels/status, comments that change scope, dependencies, and linked tasks.
4. Refuse ambiguous task references. If a dependency is required but missing from the requested task set, explain the dependency and ask whether to include it.

### 2. Create Or Reuse The Worktree

Create one worktree for the requested batch under:

```text
~/Developer/worktrees/<repo-slug>-<task-slug>
```

Use a branch name like:

```text
agent/<task-ids>-<short-slug>
```

Before creating the worktree:

- Check the current worktree status and do not move, stage, commit, revert, or delete unrelated user changes.
- Fetch remote refs if needed.
- Prefer branching from the current repository default base unless the task body specifies another branch.
- If the branch or worktree already exists, inspect it and reuse it only when it clearly matches the same task batch.

### 3. Implement The Tasks

Work inside the new worktree only.

Use Serena first for exploration when available:

- Activate the worktree path as the project.
- Use symbol overview, symbol lookup, reference lookup, diagnostics, and pattern search before reading whole files.
- Reuse existing components, hooks, services, schemas, validators, DTOs, and design-system primitives before creating anything new.

Implementation rules:

- Treat PM task bodies as the implementation contract, but obey repository instructions and user messages with higher priority.
- Keep business logic in one place. If multiple tasks need the same rule or schema, implement the shared foundation once.
- Keep handlers/controllers thin, validate at boundaries, and enforce server-side authorization for protected operations.
- Do not add dependencies, create logs, push branches, open PRs, or update PM statuses unless explicitly requested.
- Do not create tests by default. Add or update tests only when the task/user/project explicitly requires them or when directly affected existing tests must change.

### 4. Verify

Run the relevant existing checks for the changed area from package scripts, task runners, or CI config. Prefer typecheck, lint, format check, and focused tests that already exist. Do not start dev servers, containers, or browser automation by default.

Fix critical failures caused by your changes. Report unrelated pre-existing failures without broad refactors.

### 5. Report

Finish with:

- Worktree path and branch name.
- Implemented tasks and task URLs.
- Summary of code changes.
- Checks run and results.
- Files changed.
- Known risks, skipped items, and any PM task comments/status changes made.

Do not merge, delete the worktree, push, or create a PR unless the user asks.
