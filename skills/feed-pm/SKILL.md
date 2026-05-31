---
name: feed-pm
description: Use this skill when the user wants an agentic planning workflow that turns a product request, feature scope, bug epic, refactor, or backlog idea into implementation-ready PM tasks. It analyzes the current repository, uses question or clarification tools to refine the user's intent and tradeoffs before task drafting, loads matching architecture skills when available, prioritizes Serena MCP semantic exploration when available, decomposes the work into similarly sized technical tasks, drafts concise but complete issue descriptions for senior-engineer review, and only creates PM items after explicit human approval. Trigger on phrases like feed PM, create issues from this plan, split this work into tickets, prepare GitHub Issues or Notion tasks, or plan-based agentic workflow.
---

# Feed PM

## Portability Contract

This skill must work in Codex, Claude Code, Antigravity CLI, and other Agent Skills compatible runners. Treat runner-specific features as optional accelerators only.

- Do not rely on runner-specific environment variables or path substitutions.
- Resolve bundled references relative to this `SKILL.md` file.
- Read invocation input from the host runner's normal mechanism: `$ARGUMENTS`, slash-command arguments, command arguments, injected raw arguments, or the surrounding user message.
- Use the runner's `question`, `clarification`, or equivalent user-input tool to refine product intent, scope boundaries, and implementation preferences before drafting PM items. If no such tool is available, ask concise questions in chat.
- Keep all side-effect safety in the instructions, not in platform-specific frontmatter. Never create PM items until the user explicitly approves the proposed tasks.

## Input Contract

Read `$ARGUMENTS` or equivalent invocation input as a loose key-value contract:

- `pm_tool`: optional. Default to GitHub Issues for the repository that owns the current git remote.
- `project`: optional. For GitHub, accept `owner/repo`, a GitHub Project URL/number, or omit it and infer from `git remote`.
- `tasks`: required unless the user provided scope in surrounding context. Treat it as the product goal, epic, bug, refactor, or list of work to plan.

Accept natural language too. If `pm_tool` or `project` are omitted, infer them. Ask when the target PM workspace cannot be discovered safely, and use the clarification policy below to lock down the requested scope before task drafting.

## Clarification Policy

Use clarification aggressively for product and planning intent, but not for facts that can be discovered from the repository or PM tool.

Before drafting PM items, clarify every material ambiguity that would change task boundaries, acceptance criteria, dependencies, implementation risk, or review size. Prefer the runner's `question` or `clarification` tool and batch questions when possible.

Clarify at least:

- goal and desired user or business outcome;
- target users, roles, permissions, and impacted workflows;
- success criteria, acceptance criteria, and non-goals;
- in-scope and out-of-scope platforms, repositories, packages, screens, APIs, jobs, integrations, or data models;
- UX, copy, API, data, migration, rollout, backwards-compatibility, security, privacy, billing, or observability preferences;
- priority order, dependencies, milestones, labels, owners, and desired task granularity;
- whether the user wants only draft tasks or wants approved tasks created in the PM tool after review.

Do not ask the user to identify files, components, schemas, architecture owners, existing patterns, or PM metadata that can be discovered safely. Explore first, then ask only for choices and intent that remain ambiguous.

If the user does not answer a low-risk preference question, proceed with the conservative default, record it as an assumption in the proposal, and keep the PM creation approval gate. If a missing answer would make the task plan misleading or unsafe, stop and ask before drafting or creating items.

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

### 2. Clarify User Intent

After resolving the PM target and before broad architecture exploration, extract the user's stated goal, constraints, and desired output from the invocation. Then ask all currently known product, scope, and planning questions that meet the clarification policy.

Use answers as the planning contract. Record:

- confirmed goal and success criteria;
- confirmed non-goals and excluded areas;
- chosen task granularity and PM output preference;
- assumptions accepted by the user or chosen as conservative defaults;
- open questions that must appear in task bodies if still unresolved.

If repository exploration later exposes new product or architecture ambiguity that materially changes task boundaries, pause and ask another focused clarification before final decomposition.

### 3. Discover And Load Architecture Skills

Before exploring or decomposing the work, inspect the runner-provided skill inventory, visible skill metadata, project-local skills, commands, plugin skills, and workflow docs. Load every available skill whose trigger clearly matches the requested work, detected stack, or affected architectural layer.

Load matching architecture skills even when the user did not name them. Examples:

- React/frontend feature architecture: `hexagonal-react`, React/Next performance skills, frontend design-system skills, responsive-design skills, Tailwind/design-system skills.
- Node/backend feature architecture: `hexagonal-node`, Hono/API framework skills, service/repository/controller layering skills.
- Python/backend feature architecture: any FastAPI, clean architecture, repository, migration, validation, or service-layer skill exposed by the runner or project.
- Monorepo/build boundaries: Turborepo, workspace, package-boundary, or build-pipeline skills.
- Domain integrations: Stripe, Figma, Vercel, Supabase, Notion, Atlassian, or other plugin skills when the feature touches those systems.

Use the runner's normal skill-loading mechanism. In runners where skills are files, read the relevant `SKILL.md` bodies just far enough to capture constraints. In runners with explicit tool discovery, search for matching skills before broad code exploration. Do not invent unavailable skills, and do not ask the user to choose a skill merely because multiple relevant skills exist.

Record the loaded-skill context as planning evidence:

- skill names loaded;
- why each skill applies;
- architecture, validation, testing, design-system, security, or workflow constraints learned from them;
- any relevant architecture skill that seemed applicable but was unavailable or could not be loaded.

Architecture skills constrain exploration and task decomposition. They do not override explicit current-turn user instructions, this skill's PM creation approval gate, or project-specific instructions with higher priority.

If the requested scope spans multiple repositories or layers, repeat this step for each affected repository/layer before drafting tasks.

### 4. Explore The Codebase

Use Serena first when available. Call Serena's initial instructions/config tools if they have not already been loaded, activate the current repository, then use symbol and reference queries before broad file reads.

Explore only enough to produce implementation-grade tasks:

- Project instructions and local rules: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, scoped instruction files, runner instructions, and any project-provided skills or commands that describe architecture or workflows.
- Loaded architecture skill constraints and project-local skill instructions discovered in step 3.
- Architecture resources: architecture docs, ADRs, package READMEs that explain module ownership, docs folders, diagrams, generated API docs, schema docs, code comments that document boundaries, and existing PM issues/PRs when they clarify the requested area.
- Architecture map: apps/packages/modules, framework boundaries, service layers, API surfaces, persistence, jobs, UI routes, design-system ownership, state management, tests/check scripts, and deployment/runtime boundaries.
- Existing equivalents: components, hooks, services, schemas, DTOs, validators, repositories, migrations, feature flags, permissions, and PM issue references related to the requested work.
- Risk surfaces: auth, billing, security, data migrations, external APIs, concurrency, observability, and user-facing UX.

Record evidence as file paths, symbols, commands, and discovered conventions. Do not paste large code excerpts into task bodies.

### 5. Build The Architecture Responsibility Map

Before decomposing tasks, produce a concise responsibility map for the affected area. This map is mandatory because the issue descriptions must guide implementation agents toward the correct ownership boundaries instead of encouraging ad hoc code placement.

Capture:

- Which architecture skills were loaded and which concrete constraints from those skills affect task placement, dependency direction, validation, UI composition, data fetching, persistence, tests, or review boundaries.
- Which folders/packages own presentation, routes, API clients, domain logic, persistence, schemas, validation, state management, permissions, tests, jobs, and generated code.
- Which layer is allowed to call which dependency. For example: `infrastructure/` owns raw fetch/client calls; hooks consume API adapters through TanStack Query or the project's existing data layer; services own business rules; controllers/routes stay thin.
- Existing naming and placement conventions for files, symbols, hooks, DTOs, validators, repositories, migrations, fixtures, and UI primitives.
- Cross-cutting project skills or instructions that constrain implementation, such as frontend design-system rules, backend layering rules, testing rules, security rules, or monorepo boundaries.
- Any architectural uncertainty. If the correct owner is ambiguous, call it out in the task body instead of guessing silently.

Keep the map short enough for review, but concrete enough to answer "where should this code live, and why?" for every proposed task.

### 6. Decompose Into Reviewable Tasks

Use the task rubric from `task-specification.md`.

Principles:

- Keep tasks similarly sized: one coherent implementation unit that can fit in one focused checkout or branch and one focused code review.
- Prefer vertical slices when they preserve correctness; use horizontal infrastructure tasks only when later tasks depend on them.
- Keep business rules centralized. If multiple future tasks need the same rule/schema/service, create one prerequisite task for that shared foundation.
- Align each task with the responsibility map. Every task should name the owner layer/folder for its core changes and avoid placing logic in a consumer layer that should only orchestrate or render.
- Apply loaded architecture skill constraints directly in task boundaries. For example, if a React architecture skill says hooks consume API adapters and domain stays framework-free, write tasks so those responsibilities stay separate.
- Separate risky migrations, permission changes, public API changes, and UI-only polish when reviewing them together would dilute attention.
- Each task must include enough technical detail for an implementation agent to start without rediscovering the whole plan, while the digest remains scannable by a senior engineer.

### 7. Draft The PM Items

Before creating anything, show a proposal table:

| Order | Title | Type | Size | Owner layer | Depends on | Main files/symbols | Risk |
|---|---|---|---|---|---|---|---|

Then provide each full task body using the template from `task-specification.md`.

The first screen of each task must be digestible:

- problem and outcome;
- scope and non-goals;
- owner layer and key implementation anchors;
- architecture-skill constraints that implementation agents must respect;
- acceptance criteria.

Put deeper implementation details after that: contracts, schemas, state transitions, pseudocode, Mermaid diagrams, migration notes, and verification guidance.

### 8. Human Approval Gate

Do not create, edit, or move PM items until the user explicitly approves the proposed tasks.

If the user asks for changes, revise the proposal first. If they approve only part of the plan, create only the approved items and keep dependencies valid.

### 9. Create PM Items

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
