<p align="center">
  <img src=".github/assets/pbaw.png" alt="PBAW Logo" width="420" />
</p>

<div align="center">
  <a href="https://buymeacoffee.com/mvagnon">
    <img alt="Buy me a Coffee" src="https://img.shields.io/badge/Buy%20me%20a%20coffee-Support-yellow?logo=buymeacoffee" />
  </a>
</div>

---

# Plan Based Agentic Workflow

Agent Skills for a decision-to-delivery workflow with short skills, Plan Mode-friendly user decisions, and technical references kept out of the main skill body.

PBAW treats the user as the product and architecture authority, and as an experienced software engineer/architect. Questions and proposed plans should stay technical at that level, with priority on UX and database/data-model decisions; other questions should stay focused on blockers.

## Skills

- `brainstorm`: analyze the repository with Serena MCP, then research with Exa, Context7, and `gh` CLI (+ Repomix) to compare handmade and dependency-based approaches before PM planning.
- `feed-pm`: analyze the repository with Serena MCP, propose a PM-ready plan, revise it when challenged, create PM tasks after explicit approval, then recap.
- `implement-pm`: requires PM system name and exact task IDs, runs the branch script first, retrieves PM tasks, and focuses only on implementation.
- `create-pr`: create draft PRs from `{pm-tool}/{task-ids}` branches, attach PM task URLs, backlink PRs to tasks, then run `review-pr`.
- `review-pr`: perform a strict production-readiness review with mandatory full local CI.
- `fix-pr`: propose a PR remediation plan, revise it when challenged, then apply fixes after explicit approval.

## Prerequisites

Required:

- **Git**, for obvious reasons.
- **A coding agent** that supports skills and, ideally, plan mode.
- **Exa MCP** for giving more technical context.
- **Context7 MCP** for official dependency and framework documentation, in addition to Exa.
- **gh CLI** for GitHub PRs, issues and external repositories queries.
- **Repomix MCP** to gather context from actual GitHub repositories.

Good to have:

- **Serena MCP** for more accurate codebase analysis.
- Any PM tool MCP or CLI if needed.

## Installation

Install this workflow:

```bash
npx skills add mvagnon/plan-based-agentic-workflow --skill '*'
```

Expected layout:

```text
plan-based-agentic-workflow/
|-- .claude-plugin/
|   `-- plugin.json
|-- README.md
`-- skills/
    |-- brainstorm/
    |   |-- SKILL.md
    |   `-- references/
    |-- feed-pm/
    |   |-- SKILL.md
    |   `-- references/
    |-- implement-pm/
    |   |-- SKILL.md
    |   |-- references/
    |   `-- scripts/
    |       `-- create-pm-branch.sh
    |-- create-pr/
    |   |-- SKILL.md
    |   `-- references/
    |-- review-pr/
    |   |-- SKILL.md
    |   `-- references/
    `-- fix-pr/
        |-- SKILL.md
        `-- references/
```

## Workflow

Use this framework as a decision-to-delivery path.

### 0. Brainstorm The Approach

Use `brainstorm` when the best integration strategy is not settled yet.

The skill treats the user's request as complete, analyzes the repository with Serena MCP, then researches from broad to precise with Exa, Context7, and `gh` CLI. It returns one handmade approach, one external-dependency approach when credible, and a recommendation.

At the end, `brainstorm` offers exactly two next steps: invoke `feed-pm` with the recommended strategy, or challenge the strategy.

### 1. Plan And Create PM Tasks

Use `feed-pm` for a product request, bug, refactor, or backlog idea.

Run it in Plan Mode first. The skill resolves the PM target, analyzes the repository with Serena MCP, uses runner-native questions when available, and proposes a complete task plan with PM tool, project, task split, dependencies, and verification.

Challenge the plan until it is correct. Once approved, switch to Build mode and ask `feed-pm` to create the PM tasks.

### 2. Implement PM Tasks

Use `implement-pm <pm-tool> <task-ids>` with the PM system name and exact task IDs created by `feed-pm`.

Example:

```text
implement-pm jira pp-12-14-15
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

### 3. Create The PR And Run The First Review

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

### 4. Fix Review Issues

If the review finds issues, use `fix-pr`.

Run it in Plan Mode first. The skill collects PR feedback, builds a feedback ledger, inspects the code with Serena MCP, and proposes a complete remediation plan.

Challenge the plan until it is correct. Once approved, switch to Build mode and ask `fix-pr` to apply the fixes, run relevant checks, commit, push, and reply to handled PR conversations.

### 5. Review Again And Merge If Ready

Run `review-pr` again after `fix-pr`, or directly after `create-pr` when the first review had no issues.

`review-pr` performs the production-readiness review on changed code and directly affected paths. It is strict on security, architecture boundaries, code reuse, centralized business logic, correctness, and production regressions.

Local CI is mandatory for `PROD READY`, merge, and PM task closure. If local CI passes and the PR is production-ready, `review-pr` can proceed with merge/finalization according to the repository and PM-tool rules.

## Test Authoring Strategy

PBAW skills do not create new tests by default. This is intentional: tests written during small implementation tasks tend to target microscopic features and can create too many false positives.

When tests are needed, write them through the dedicated journey-test skill instead:

```bash
npx skills add mvagnon/skills --skill write-tests
```

That workflow favors tests for user journeys and product flows rather than fragile tests around narrow implementation details.

## Safety Rules

- `brainstorm` does not write code, create PM tasks, open PRs, mutate external systems, ask clarification questions, or recommend Plan Mode.
- `feed-pm` proposes a complete plan first, preserves it when challenged, and creates PM tasks only after explicit approval.
- `implement-pm` must run the branch script before PM retrieval, Serena analysis, or edits.
- `create-pr` creates draft PRs and PM backlinks, then runs `review-pr`.
- `review-pr` does not implement fixes and cannot merge or close PM tasks without passing local CI and explicit approval.
- `fix-pr` does not merge, mark PRs ready, close PM tasks, or update PM status.
- No skill should add dependencies, logs, broad refactors, or new tests by default.

## Technical References

References are bundled per skill and contain commands, templates, research mechanics, and PM/Git mechanics only. The main `SKILL.md` files define the human workflow and expected response format.

Repository-level authoring rules live in `AGENTS.md`.
