<p align="center">
  <img src=".github/assets/pbaw.png" alt="PBAW Logo" width="420" />
</p>

# Plan Based Agentic Workflow

Agent Skills for a PM-task-first development workflow with short skills, one Decision Gate where needed, and technical references kept out of the main skill body.

PBAW treats the user as the product and architecture authority, and as an experienced software engineer/architect. Decision Gates should ask technical questions at that level, with priority on UX and database/data-model decisions; other questions should stay focused on blockers.

## Skills

- `feed-pm`: analyze the repository with Serena MCP, use exactly one Decision Gate, create PM tasks directly, then recap.
- `fix-pm`: explicitly adjust already-created PM tasks in place, then verify the updated task state.
- `implement-pm`: explicitly invoked only, run the branch script first, retrieve PM tasks, and focus only on implementation.
- `create-pr`: create draft PRs from `{pm-tool}/{task-ids}` branches, attach PM task URLs, backlink PRs to tasks, then run `review-pr`.
- `review-pr`: perform a strict production-readiness review with mandatory full local CI.
- `fix-pr`: fix PR feedback with at most one Decision Gate and no loop.

## Prerequisites

Required:

- Git.
- A skill runner that can load `skills/<skill-name>/SKILL.md`.
- Serena MCP configured.
- `gh` authenticated for GitHub PRs and Issues when GitHub is used.
- The PM tool MCP or CLI for Jira, Notion, Linear, or another selected PM system.

## Installation

Install this workflow:

```bash
npx skills add mvagnon/plan-based-agentic-workflow
```

Expected layout:

```text
plan-based-agentic-workflow/
|-- .claude-plugin/
|   `-- plugin.json
|-- README.md
`-- skills/
    |-- feed-pm/
    |   |-- SKILL.md
    |   |-- agents/
    |   `-- references/
    |-- fix-pm/
    |   |-- SKILL.md
    |   |-- agents/
    |   `-- references/
    |-- implement-pm/
    |   |-- SKILL.md
    |   |-- agents/
    |   |-- references/
    |   `-- scripts/
    |       `-- create-pm-branch.sh
    |-- create-pr/
    |   |-- SKILL.md
    |   |-- agents/
    |   `-- references/
    |-- review-pr/
    |   |-- SKILL.md
    |   |-- agents/
    |   `-- references/
    `-- fix-pr/
        |-- SKILL.md
        |-- agents/
        `-- references/
```

## Workflow

### 1. Create PM Tasks

Use `feed-pm` for a product request, bug, refactor, or backlog idea.

Flow:

1. Resolve PM target.
2. Load relevant skills.
3. Analyze the repository with Serena MCP.
4. Use one mandatory Decision Gate.
5. Create PM tasks directly unless the user explicitly refuses or the PM target is unsafe.
6. Recap task URLs and the next implementation command.

No local planning workspace and no repeated approval cycle.

### 2. Adjust PM Tasks

Use:

```text
/fix-pm <tasks-url> <changes>
```

Example:

```text
/fix-pm https://github.com/acme/app/issues/123 "split deployment work into a separate devops task and clarify the API acceptance criteria"
```

`fix-pm` retrieves already-created PM tasks, applies requested changes in place, and verifies the updated task state. It uses at most one Decision Gate when the update is ambiguous, structurally risky, or unsafe to apply directly.

It does not implement code, create branches, create PRs, review PRs, merge, or close tasks by default.

`fix-pm` is explicit-only: its skill frontmatter disables model invocation and declares `tasks-url` plus `changes` positional variables.

### 3. Implement PM Tasks

Use:

```text
/implement-pm <pm-tool> <task-ids>
```

Example:

```text
/implement-pm jira pp-12-14-15
```

`implement-pm` first runs:

```bash
skills/implement-pm/scripts/create-pm-branch.sh <pm-tool> <task-ids>
```

The script creates and pushes branch:

```text
<pm-tool>/<task-ids>
```

Then the skill retrieves the tasks, analyzes the codebase with Serena, implements the work, and stops with a concise report. It does not create PRs or update PM backlinks.

`implement-pm` is explicit-only: its skill frontmatter disables model invocation and declares `pm_tool` plus `task_ids` positional variables.

### 4. Create Draft PRs

Run `create-pr` after implementation.

It reads branch names like:

```text
jira/pp-12-14-15
github/123-124
```

Then it:

1. Resolves PM task URLs.
2. Creates draft PRs.
3. Adds PM task URLs to the PR body.
4. Writes PR URLs back to the PM tasks.
5. Runs `review-pr` immediately.

PR bodies stay minimal because task bodies are the source of truth.

### 5. Review PRs

`review-pr` reviews changed code and directly affected paths. It is strict on:

- security, auth, privacy, and secrets;
- architecture boundaries and dependency direction;
- reuse of existing code and centralized business logic;
- correctness and production regressions.

Local CI is mandatory for `PROD READY`, merge, and PM task closure. If local CI is missing or failing, the PR is not mergeable.

### 6. Fix PR Feedback

`fix-pr` collects PR feedback, builds a feedback ledger, and fixes unambiguous issues directly.

It uses one Decision Gate only when remediation needs user or architect input. After the answer, it applies the roadmap directly unless the user explicitly refuses or changes scope.

## Safety Rules

- `feed-pm` uses one Decision Gate and creates tasks directly after clarification unless refused.
- `fix-pm` updates existing PM tasks in place and uses at most one Decision Gate for ambiguous, structural, or unsafe changes.
- `implement-pm` must run the branch script before PM retrieval, Serena analysis, or edits.
- `create-pr` creates draft PRs and PM backlinks, then runs `review-pr`.
- `review-pr` does not implement fixes and cannot merge or close PM tasks without passing local CI and explicit approval.
- `fix-pr` does not merge, mark PRs ready, close PM tasks, or update PM status.
- No skill should add dependencies, logs, broad refactors, or new tests by default.

## Technical References

References are bundled per skill and contain commands, templates, and PM/Git mechanics only. The main `SKILL.md` files define the human workflow and expected response format.

Repository-level authoring rules live in `AGENTS.md`.
