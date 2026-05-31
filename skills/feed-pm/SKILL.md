---
name: feed-pm
description: Use this skill when the user wants to turn a product request, feature scope, bug, refactor, or backlog idea into implementation-ready PM tasks. It deeply analyzes the project with Serena MCP, loads matching architecture skills when available, uses clarification/question tooling when available to refine the request, decomposes the work into technical tasks, drafts concise but complete issue descriptions for senior-engineer review, and only creates PM items after explicit post-proposal approval. Trigger on phrases like feed PM, create issues from this plan, split this work into tickets, prepare GitHub Issues or Notion tasks, or plan-based agentic workflow.
---

# Feed PM

## Input Contract

Read the following arguments or equivalent invocation input as a loose key-value contract:

`$ARGUMENTS`

Infer:

- `pm_tool`: optional. Default to GitHub Issues for the repository that owns the current repository remote.
- `project`: optional. Accept a URL, name, ID, repository, project, page, or database target. Infer it from repository context when safe.
- `tasks`: required unless the user provided scope in surrounding context. Treat it as the product goal, epic, bug, refactor, or list of work to plan.

Accept natural language too. Ask only when the PM target cannot be discovered safely or when missing product intent would make the task plan misleading.

## Required References

Load these bundled references as needed:

- `references/codebase-analysis.md`: Serena startup, repository evidence checklist, responsibility-map template, and anti-patterns.
- `references/task-specification.md`: proposal table, issue body template, size rubric, diagrams, and task quality checklist.
- `references/pm-tools.md`: concrete PM target discovery and approved task creation mechanics for GitHub, Notion, and other tools.

References are intentionally technical. Keep the skill body focused on the workflow and consult the references for commands, templates, and tool-specific details.

## Clarification Policy

Use clarification/question tooling aggressively for product and planning intent, but not for facts that can be discovered from the repository or PM tool.

Before drafting PM items, analyze the repository and PM target first, then clarify every remaining material ambiguity that would change task boundaries, acceptance criteria, dependencies, implementation risk, or review size.

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

## Workflow

### 1. Resolve PM Target

Identify the repository and PM target. Default to GitHub Issues when the repository context supports it. Use Notion or another PM tool only when requested or clearly discoverable. Stop before side effects when the target cannot be resolved safely.

Use `references/pm-tools.md` for target discovery, issue/page creation mechanics, project-field handling, and the approval gate summary.

### 2. Capture User Intent

Extract the user's stated goal, constraints, requested output, and implied assumptions. Record the initial planning contract without asking broad product questions until repository and PM facts have been explored, unless the missing answer blocks safe target resolution.

### 3. Discover And Load Architecture Skills

Before exploring or decomposing the work, inspect the runner-provided skill inventory, visible skill metadata, project-local skills, commands, plugin skills, and workflow docs. Load every available skill whose trigger clearly matches the requested work, detected stack, or affected architectural layer.

Use the runner's normal skill-loading mechanism. Read only enough of each relevant skill to capture constraints. Do not invent unavailable skills, and do not ask the user to choose a skill merely because multiple relevant skills exist.

Record:

- skill names loaded and why they apply;
- architecture, validation, testing, design-system, security, or workflow constraints learned from them;
- relevant skills that seemed applicable but were unavailable or could not be loaded.

### 4. Explore The Codebase

Use Serena first. Load Serena instructions/configuration when available, activate the current repository, and prefer symbol/reference queries before broad file reads. If Serena is unavailable, stop and report the missing required dependency instead of producing implementation-ready PM tasks from local search alone.

Use `references/codebase-analysis.md` for the technical exploration checklist and responsibility-map template.

Explore only enough to produce implementation-grade tasks:

- project instructions and local rules;
- architecture resources and loaded skill constraints;
- apps, packages, modules, framework boundaries, API surfaces, persistence, jobs, UI routes, state management, tests, and deployment/runtime boundaries;
- existing equivalents to reuse;
- risk surfaces such as auth, billing, security, migrations, external APIs, concurrency, observability, and user-facing UX.

### 5. Clarify Remaining Intent

After architecture skill loading and repository/PM exploration, ask all remaining product, scope, and planning questions that meet the clarification policy.

Use answers as the planning contract. Record confirmed goals, non-goals, chosen task granularity, assumptions, and any open questions that must appear in task bodies.

### 6. Build The Architecture Responsibility Map

Produce a concise responsibility map for the affected area before task decomposition. The map must answer where implementation should live and why.

Capture owner folders/layers, allowed dependency direction, naming and placement conventions, reusable primitives/services/schemas, cross-cutting constraints, and any unresolved architectural uncertainty.

### 7. Decompose Into Reviewable Tasks

Use `references/task-specification.md` for the size rubric and issue body template.

Principles:

- Keep tasks similarly sized and reviewable.
- Prefer vertical slices when they preserve correctness.
- Create shared foundation tasks when multiple future tasks need the same rule, schema, service, permission, or contract.
- Align every task with the responsibility map.
- Separate risky migrations, permission changes, public API changes, and UI-only polish when reviewing them together would dilute attention.

### 8. Draft The PM Items

Show a proposal table first, then full task bodies. The first screen of each task must include problem/outcome, scope, non-goals, owner layer, key implementation anchors, architecture constraints, and acceptance criteria.

Put deeper implementation details after the digest: contracts, schemas, state transitions, diagrams when useful, migration notes, dependency order, verification guidance, and reviewer notes.

### 9. Human Approval Gate

Do not create, edit, label, move, assign, or otherwise mutate PM items until the user explicitly approves the proposed tasks after seeing them.

If the user asks for changes, revise the proposal first. If they approve only part of the plan, create only the approved items and keep dependencies valid.

### 10. Create PM Items

After approval, create one PM item per approved task, preserve dependency order, link related tasks in bodies using stable URLs or IDs after creation, and apply existing metadata only when repository convention or the user request supports it.

## Completion Output

Finish with:

- PM tool and target used.
- Created task URLs or a clear note that only drafts were produced.
- Dependency order.
- Suggested next command, for example: `implement-pm for tasks #123 #124 #125`.
