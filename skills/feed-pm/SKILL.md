---
name: feed-pm
description: Use this skill when the user wants to turn a product request, feature scope, bug, refactor, or backlog idea into implementation-ready PM tasks. It analyzes the repository with Serena MCP, loads matching architecture skills, uses built-in clarification/question tools when available and portable Decision Gates otherwise, writes persistent task plans under ~/pbaw-plans for review, revises those files through clarifications, and creates PM items only after final push confirmation. Trigger on phrases like feed PM, create issues from this plan, split this work into tickets, prepare GitHub Issues or Notion tasks, or plan-based agentic workflow.
---

# Feed PM

## Purpose

Turn a product or engineering request into reviewable PM tasks that are grounded in the repository architecture, persisted as plan files, and ready for a senior engineer to implement.

PBAW is a collaborative workflow: the user is the product and architecture authority, and the agent is the technical operator. Treat the user as a qualified software engineer: ask technical, architectural, product, and delivery questions when they materially affect the outcome. The agent discovers what can be discovered, proposes a concrete roadmap, and executes only the approved path.

## Inputs

Read `$ARGUMENTS` or equivalent natural language as:

- `pm_tool`: optional. Default to GitHub Issues when the repository remote supports it.
- `project`: optional. Accept a URL, name, ID, repository, page, or database target.
- `tasks`: required unless the request scope is already clear from conversation.

Ask only when the PM target cannot be resolved safely or missing product, technical, or architecture intent would make the plan misleading. Use built-in clarification/question tools when available; otherwise ask through the same Decision Gate in normal chat. When a clarification is needed, ask the clarification directly instead of presenting all draft tasks inline. Do not switch to Plan Mode just to access question tooling.

## References

Load only what is needed:

- `references/pm-tools.md` for PM target discovery and item creation.
- `references/codebase-analysis.md` for Serena exploration and responsibility maps.
- `references/task-specification.md` for plan-file layout, task templates, sizing, and quality checks.

## Rules

- Explore the repo and PM target before asking broad planning questions.
- Use Serena first. If Serena is unavailable, stop instead of drafting implementation-ready tasks from local search alone.
- Load matching architecture, validation, testing, design-system, security, or workflow skills before decomposing work.
- Do not ask the user to identify files, components, schemas, owners, or PM metadata that can be discovered safely.
- Do not create, edit, label, move, assign, or otherwise mutate PM items before explicit final confirmation to push the latest linked plan files to the PM tool.
- Record assumptions when you proceed on low-risk defaults.

## Persistent Plan Files

Use `~/pbaw-plans` as the durable planning workspace for every `feed-pm` request.

- Create one request directory named `<YYYYMMDD-HHMMSS>-<request-slug>`, for example `~/pbaw-plans/20260602-143012-workspace-invites`.
- Write `index.md` in that directory as the review entrypoint. It contains the PM target, request summary, assumptions, responsibility map, proposal table, dependency order, metadata to apply, creation plan, and links to task files.
- Write one Markdown file per proposed PM task with an explicit order and slug, for example `01-add-invite-acceptance-service.md`.
- Draft incrementally. It is acceptable for early task files to contain partial details while exploration or clarification is still active, but update them as soon as the missing information is resolved.
- Revise the same request directory after user clarifications, corrections, scope changes, or confirmation. Do not fork a new plan directory for the same request unless the user starts a separate scope.
- Use the latest task files as the source bodies for PM item creation after final confirmation.
- In user-facing responses before PM creation, do not paste the proposal table or full task bodies. Give the `index.md` path and ask the user to review it and confirm whether to push it to the PM tool.

## Decision Gates

Use built-in clarification/question tools when available for Decision Gates. When they are unavailable, present the same Decision Gate in normal chat. A Decision Gate is not a planning-only pause; it is an approval checkpoint for the planning direction; when a roadmap exists, keep that roadmap in the linked plan files instead of pasting it inline.

Every Decision Gate must:

- state the unresolved architect decisions and recommended defaults, including product, architecture, data model, validation, permission, API, UI, rollout, and task-boundary decisions when relevant;
- keep the latest proposal table, task bodies, target PM tool, dependency order, metadata, and creation plan in the plan files when enough information exists;
- explain that the user's answer authorizes the planning direction unless they refuse, correct, or narrow it;
- avoid asking for files, schemas, owners, labels, or metadata that can be discovered.

After the user answers a Decision Gate:

- if the answer accepts, selects options, adds compatible detail, or does not object to the roadmap, continue exploration if useful and revise the plan files;
- if the answer refuses, changes scope, contradicts the roadmap, or adds a constraint that invalidates the proposal, revise the plan files before asking again for review;
- if the PM target is still unsafe to mutate, ask only for the missing target detail.
- always provide the updated `index.md` link and ask for explicit final confirmation before pushing or creating PM items.

## Process Schema

```mermaid
flowchart TD
  A[Resolve repository and PM target] --> B[Load relevant skills]
  B --> C[Explore codebase with Serena]
  C --> D[Draft or revise plan files in ~/pbaw-plans]
  D --> E{Material decision needed?}
  E -->|No| F[Link index.md and ask for review]
  F --> G{Review response}
  G -->|Final push confirmed| H[Create approved PM items from latest files]
  G -->|No or changes requested| I[Revise plan files]
  I --> D
  E -->|Yes| J[Use question tool or Decision Gate for clarification]
  J --> K{User refuses or changes roadmap?}
  K -->|No| L[Continue exploration if useful]
  L --> D
  K -->|Yes| I
  H --> M[Report URLs, dependency order, next implement-pm command]
```

## Workflow

1. Resolve the repository and PM target. Default to GitHub Issues only when safe.
2. Capture the user's stated goal, constraints, requested output, and implied assumptions.
3. Discover and load relevant skills. Record what each loaded skill changes about architecture, validation, testing, design, security, or workflow.
4. Explore the codebase with Serena. Find existing equivalents, owner layers, boundaries, reusable primitives, validation, data models, APIs, UI routes, jobs, integrations, tests, and risk surfaces.
5. Build a concise responsibility map: owner folders/layers, dependency direction, naming/placement rules, reusable services/schemas/components, cross-cutting constraints, and unresolved uncertainty.
6. Decompose into similarly sized, reviewable tasks. Prefer vertical slices when correct. Split shared foundations, migrations, permission changes, public API changes, and UI polish when that improves review quality.
7. Create or update the request directory in `~/pbaw-plans`. Draft `index.md` plus one task file per proposed PM item. Each task starts with problem/outcome, scope, non-goals, owner layer, implementation anchors, architecture constraints, and acceptance criteria.
8. If needed, use built-in clarification/question tools when available, or show a Decision Gate otherwise, to clarify remaining product, technical, architecture, and planning intent. Ask the question directly; do not paste all tasks inline. Then update the plan files.
9. Link `index.md` and ask the user to review the latest files and explicitly confirm whether to push/create the PM items. Revise first if the user refuses, corrects, narrows, or expands the proposal.
10. Create only finally confirmed PM items from the latest plan files, preserve dependency order, link related tasks with stable URLs or IDs, and apply metadata only when requested or locally conventional.

## Completion Output

Finish with:

- PM tool and target used.
- Draft-only status or created task URLs.
- Plan index path used for the latest review or PM creation.
- Dependency order.
- Suggested next command, for example `implement-pm for tasks #123 #124 #125`.

## Final Checklist

- [ ] 1. PM target and repository resolved safely.
- [ ] 2. User goal, constraints, and assumptions captured.
- [ ] 3. Relevant skills loaded and their constraints recorded.
- [ ] 4. Codebase explored with Serena; existing patterns and risk surfaces identified.
- [ ] 5. Remaining product, technical, architecture, or scope ambiguities clarified through built-in tooling or a portable Decision Gate when needed.
- [ ] 6. Responsibility map written in the plan index before task decomposition.
- [ ] 7. Tasks split into reviewable, dependency-aware units.
- [ ] 8. Proposal table and full task bodies written to `~/pbaw-plans` and linked for review.
- [ ] 9. Explicit final push confirmation received after linking the latest plan index before PM mutation.
- [ ] 10. Approved items created, linked, ordered, and reported with the next command.
