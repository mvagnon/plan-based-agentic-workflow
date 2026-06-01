---
name: implement-pm
description: Use this skill when the user wants to implement one or more PM tasks, GitHub Issues, Notion tasks, or plan-based workflow items directly in the current checkout or a workspace containing child repositories. It fetches the referenced tasks, creates dedicated branch(es) from the currently selected branch(es), opens draft PR(s) before implementation, writes PR backlinks to non-GitHub PM tasks, studies the repository with Serena MCP, preserves staged, unstaged, and unrelated local changes, implements the requested work, runs relevant checks, and reports repository paths, branches, draft PRs, changes, and remaining risks. Trigger on phrases like implement PM tasks, implement these issues, work on these tickets, implement issue references, or continue the plan-based agentic workflow.
---

# Implement PM

## Input Contract

Read the following arguments or equivalent invocation input as a loose key-value contract:

`$ARGUMENTS`

Infer:

- `Tasks`: required. Accept GitHub issue numbers, issue URLs, Notion page URLs, task IDs, or a small query that identifies exact PM items.
- `PM Tool`: optional. Default to GitHub Issues for the repository or child repositories that own the target remotes.
- `Project`: optional. For GitHub, accept a repository, project URL, or project number. Infer from repository context when safe.

Ask one concise question only when the task references cannot be resolved to exact PM items. Do not guess between multiple matching tasks.

## Required References

Load these bundled references as needed:

- `references/pm-task-retrieval.md`: exact task resolution, dependency discovery, and canonical task-set handling.
- `references/implementation-git-github.md`: repository preflight, branch creation, draft PR creation, required task linkage, staging, commit, and push mechanics.
- `references/verification.md`: check-command discovery, common verification command shapes, and failure reporting.

References are intentionally technical. Keep the skill body focused on the workflow and consult the references for commands, payloads, and tool-specific details.

## Workflow

### 1. Resolve Tasks And Repository

Resolve every requested PM task before branch or PR work starts. Fetch title, body, labels/status, comments that change scope, dependencies, linked tasks, and canonical URLs.

Use `references/pm-task-retrieval.md` for retrieval commands, search behavior, dependency handling, and ambiguity rules.

Preserve the complete resolved task set for the branch name, draft PR body, implementation scope, and final report. Never collapse a multi-task invocation to the first task only.

Resolve the target repository set before branch work:

- In a normal repository or monorepo checkout, use the current Git repository root.
- In a workspace directory that contains multiple independent child Git repositories, inspect the child repositories and map each task to the affected repo or repos.
- If the affected child repos cannot be inferred from task content, explicit user input, existing branch names, or file paths, ask one concise question before creating branches.
- For multi-repo work, keep one branch and one draft PR per affected repository. Do not mix changes from different child repositories into one PR.

### 2. Prepare The Branch And Draft PR

Implement directly in the current checkout or affected child repository checkout. Do not create a secondary checkout.

Before editing:

- identify repository root, current branch, remotes, and local status for each affected repository;
- record each currently selected branch and treat it as that repository's source/base branch for this invocation;
- create or switch to one dedicated invocation branch per affected repository from the current checkout state;
- preserve staged, unstaged, and unrelated local changes;
- fetch remote refs only when needed for task resolution or implementation context;
- open each draft PR from the dedicated branch to the recorded source/base branch before implementation edits;
- put every concerned task reference at the top of the PR body;
- for GitHub Issues, link every concerned issue using native linked-issue syntax;
- for non-GitHub PM tasks, write the draft PR URL or URLs back to the PM task's dedicated PR field when one exists, or to a task comment/description fallback when no dedicated field exists;
- confirm every resolved task is represented in the draft PR body and, for non-GitHub PM tasks, in the PM task backlink before implementation edits.

Use `references/implementation-git-github.md` for concrete branch, draft PR, linkage, and pre-edit verification mechanics.

If authentication, remote configuration, PR creation, GitHub Issue linking, or non-GitHub PM backlinking prevents required linkage, stop before implementation and report the blocker.

### 3. Implement The Tasks

Work inside each affected checkout on its dedicated invocation branch, after the draft PR exists and required task linkage/backlinks are confirmed.

Use Serena first for exploration:

- activate the repository being edited as the Serena project;
- use symbol overview, symbol lookup, reference lookup, diagnostics, and pattern search before reading whole files;
- reuse existing components, hooks, services, schemas, validators, DTOs, repositories, utilities, and design-system primitives before creating anything new.

If Serena is unavailable, stop and report the missing required dependency instead of implementing from local search alone.

Implementation rules:

- Treat PM task bodies as the implementation contract, while obeying higher-priority user and repository instructions.
- Keep business logic in one place. If multiple tasks need the same rule or schema, implement the shared foundation once.
- Keep handlers/controllers thin, validate at boundaries, and enforce server-side authorization for protected operations.
- Do not add dependencies, create logs, mark PRs ready, merge PRs, or update PM statuses unless explicitly requested.
- Do not create tests by default. Add or update tests only when the task, user, project, or directly affected existing tests require it.

### 4. Verify

Run relevant existing checks for the changed area from package scripts, task runners, or CI config. Prefer type checks, lint, formatting checks, and focused tests that already exist.

Use `references/verification.md` for command discovery and reporting. Do not start dev servers, containers, browser automation, or watch commands by default.

Fix critical failures caused by your changes. Report unrelated pre-existing failures without broad refactors.

### 5. Stage, Commit, And Push

Before committing or pushing implementation changes:

- self-review the diff;
- confirm each changed file belongs to this invocation;
- remove dead code and unused imports introduced by the change;
- verify no secrets or sensitive data were added;
- stage only invocation changes.

Use `references/implementation-git-github.md` for staging, commit, and push mechanics.

### 6. Report

Finish with:

- repository path(s) and current branch name(s);
- draft PR URL(s);
- implemented tasks and task URLs;
- summary of code changes;
- checks run and results;
- files changed;
- known risks, skipped items, and any PM task backlink comments/description/field updates or status changes made;
- suggested next command: `review-pr` from the PR branch or workspace containing the affected child repositories.

Do not switch away from invocation branches, mark PRs ready, merge, or update PM statuses unless the user asks.
