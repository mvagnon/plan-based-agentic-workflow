---
name: feed-pm
description: Use this skill when the user wants an agentic planning workflow that turns a product request, feature scope, bug epic, refactor, or backlog idea into implementation-ready PM tasks. It analyzes the current repository, prioritizes Serena MCP semantic exploration when available, decomposes the work into similarly sized technical tasks, drafts concise but complete issue descriptions for senior-engineer review, and only creates PM items after explicit human approval. Trigger on phrases like feed PM, create issues from this plan, split this work into tickets, prepare GitHub Issues or Notion tasks, or plan-based agentic workflow.
disable-model-invocation: true
---

# Feed PM

## Portability Contract

This skill must work in Codex, Claude Code, Antigravity CLI, and other Agent Skills compatible runners. Treat runner-specific features as optional accelerators only.

- Do not rely on runner-specific environment variables or path substitutions.
- Resolve bundled references relative to this `SKILL.md` file.
- Read invocation input from the host runner's normal mechanism: `$ARGUMENTS`, slash-command arguments, command arguments, injected raw arguments, or the surrounding user message.
- Keep all side-effect safety in the instructions, not in platform-specific frontmatter. Never create PM items until the user explicitly approves the proposed tasks.

## Input Contract

Read `$ARGUMENTS` or equivalent invocation input as a loose key-value contract:

- `pm_tool`: optional. Default to GitHub Issues for the repository that owns the current git remote.
- `project`: optional. For GitHub, accept `owner/repo`, a GitHub Project URL/number, or omit it and infer from `git remote`.
- `tasks`: required unless the user provided scope in surrounding context. Treat it as the product goal, epic, bug, refactor, or list of work to plan.

Accept natural language too. If `pm_tool` or `project` are omitted, infer them. Ask one concise question only when the target PM workspace cannot be discovered safely or the requested scope is ambiguous enough that task creation would be misleading.

## Required Resources

Load these references when doing the corresponding part of the workflow:

- `../../references/serena-codebase-analysis.md`: codebase exploration protocol and Serena fallback rules.
- `../../references/task-specification.md`: PM issue structure, review-size limits, and decomposition quality rubric.
- `../../references/pm-tools.md`: GitHub Issues default behavior, Notion routing, and creation gate.

## Workflow

### 1. Resolve PM Target

1. Identify the repository root with git.
2. Resolve `pm_tool`:
   - Default: `github`.
   - `github`: use `gh` CLI or GitHub MCP if available.
   - `notion`: use Notion MCP if available; otherwise draft tasks and ask for the database/page target.
   - Any other PM tool: use an installed MCP/CLI only if it is discoverable; otherwise emit ready-to-copy task bodies.
3. Resolve `project`:
   - If omitted for GitHub, use the current repository remote.
   - If a GitHub Project is provided, create issues in the repo and add them to the project when the available tooling supports it.
   - If the repo or PM target is not discoverable, stop before planning side effects and ask for the missing target.

### 2. Explore The Codebase

Use Serena first when available. Call Serena's initial instructions/config tools if they have not already been loaded, activate the current repository, then use symbol and reference queries before broad file reads.

Explore only enough to produce implementation-grade tasks:

- Project instructions and local rules: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, scoped instruction files, runner instructions, and any project-provided skills or commands that describe architecture or workflows.
- Architecture resources: architecture docs, ADRs, package READMEs that explain module ownership, docs folders, diagrams, generated API docs, schema docs, code comments that document boundaries, and existing PM issues/PRs when they clarify the requested area.
- Architecture map: apps/packages/modules, framework boundaries, service layers, API surfaces, persistence, jobs, UI routes, design-system ownership, state management, tests/check scripts, and deployment/runtime boundaries.
- Existing equivalents: components, hooks, services, schemas, DTOs, validators, repositories, migrations, feature flags, permissions, and PM issue references related to the requested work.
- Risk surfaces: auth, billing, security, data migrations, external APIs, concurrency, observability, and user-facing UX.

Record evidence as file paths, symbols, commands, and discovered conventions. Do not paste large code excerpts into task bodies.

### 3. Build The Architecture Responsibility Map

Before decomposing tasks, produce a concise responsibility map for the affected area. This map is mandatory because the issue descriptions must guide implementation agents toward the correct ownership boundaries instead of encouraging ad hoc code placement.

Capture:

- Which folders/packages own presentation, routes, API clients, domain logic, persistence, schemas, validation, state management, permissions, tests, jobs, and generated code.
- Which layer is allowed to call which dependency. For example: `infrastructure/` owns raw fetch/client calls; hooks consume API adapters through TanStack Query or the project's existing data layer; services own business rules; controllers/routes stay thin.
- Existing naming and placement conventions for files, symbols, hooks, DTOs, validators, repositories, migrations, fixtures, and UI primitives.
- Cross-cutting project skills or instructions that constrain implementation, such as frontend design-system rules, backend layering rules, testing rules, security rules, or monorepo boundaries.
- Any architectural uncertainty. If the correct owner is ambiguous, call it out in the task body instead of guessing silently.

Keep the map short enough for review, but concrete enough to answer "where should this code live, and why?" for every proposed task.

### 4. Decompose Into Reviewable Tasks

Use the task rubric from `task-specification.md`.

Principles:

- Keep tasks similarly sized: one coherent implementation unit that can fit in one branch/worktree and one focused code review.
- Prefer vertical slices when they preserve correctness; use horizontal infrastructure tasks only when later tasks depend on them.
- Keep business rules centralized. If multiple future tasks need the same rule/schema/service, create one prerequisite task for that shared foundation.
- Align each task with the responsibility map. Every task should name the owner layer/folder for its core changes and avoid placing logic in a consumer layer that should only orchestrate or render.
- Separate risky migrations, permission changes, public API changes, and UI-only polish when reviewing them together would dilute attention.
- Each task must include enough technical detail for an implementation agent to start without rediscovering the whole plan, while the digest remains scannable by a senior engineer.

### 5. Draft The PM Items

Before creating anything, show a proposal table:

| Order | Title | Type | Size | Owner layer | Depends on | Main files/symbols | Risk |
|---|---|---|---|---|---|---|---|

Then provide each full task body using the template from `task-specification.md`.

The first screen of each task must be digestible:

- problem and outcome;
- scope and non-goals;
- owner layer and key implementation anchors;
- acceptance criteria.

Put deeper implementation details after that: contracts, schemas, state transitions, pseudocode, Mermaid diagrams, migration notes, and verification guidance.

### 6. Human Approval Gate

Do not create, edit, or move PM items until the user explicitly approves the proposed tasks.

If the user asks for changes, revise the proposal first. If they approve only part of the plan, create only the approved items and keep dependencies valid.

### 7. Create PM Items

After approval:

1. Create one PM item per approved task.
2. Preserve the chosen order and dependency references.
3. Link related tasks in bodies using stable URLs or issue numbers after creation.
4. Apply existing labels, statuses, milestones, project fields, or owners only when the repository already uses them or the user requested them.
5. Report created item URLs and a suggested `implement-pm` invocation.

## Completion Output

Finish with:

- PM tool and target used.
- Created task URLs or a clear note that only drafts were produced.
- Dependency order.
- Suggested next command, for example: `implement-pm tasks="#123 #124 #125"`.
