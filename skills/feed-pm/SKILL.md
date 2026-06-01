---
name: feed-pm
description: Use this skill when the user wants to turn a product request, feature scope, bug, refactor, or backlog idea into implementation-ready PM tasks. It analyzes the repository with Serena MCP, loads matching architecture skills, clarifies remaining product intent, drafts concise PM items, and creates PM items only after explicit approval. Trigger on phrases like feed PM, create issues from this plan, split this work into tickets, prepare GitHub Issues or Notion tasks, or plan-based agentic workflow.
---

# Feed PM

## Purpose

Turn a product or engineering request into reviewable PM tasks that are grounded in the repository architecture and ready for a senior engineer to implement.

## Inputs

Read `$ARGUMENTS` or equivalent natural language as:

- `pm_tool`: optional. Default to GitHub Issues when the repository remote supports it.
- `project`: optional. Accept a URL, name, ID, repository, page, or database target.
- `tasks`: required unless the request scope is already clear from conversation.

Ask only when the PM target cannot be resolved safely or missing product intent would make the plan misleading.

## References

Load only what is needed:

- `references/pm-tools.md` for PM target discovery and item creation.
- `references/codebase-analysis.md` for Serena exploration and responsibility maps.
- `references/task-specification.md` for proposal tables, task templates, sizing, and quality checks.

## Rules

- Explore the repo and PM target before asking broad planning questions.
- Use Serena first. If Serena is unavailable, stop instead of drafting implementation-ready tasks from local search alone.
- Load matching architecture, validation, testing, design-system, security, or workflow skills before decomposing work.
- Do not ask the user to identify files, components, schemas, owners, or PM metadata that can be discovered safely.
- Do not create, edit, label, move, assign, or otherwise mutate PM items before explicit post-proposal approval.
- Record assumptions when you proceed on low-risk defaults.

## Workflow

1. Resolve the repository and PM target. Default to GitHub Issues only when safe.
2. Capture the user's stated goal, constraints, requested output, and implied assumptions.
3. Discover and load relevant skills. Record what each loaded skill changes about architecture, validation, testing, design, security, or workflow.
4. Explore the codebase with Serena. Find existing equivalents, owner layers, boundaries, reusable primitives, validation, data models, APIs, UI routes, jobs, integrations, tests, and risk surfaces.
5. Clarify remaining product and planning intent: goal, users, roles, permissions, success criteria, non-goals, platforms, APIs, data, UX, rollout, priority, dependencies, labels, owners, and task granularity.
6. Build a concise responsibility map: owner folders/layers, dependency direction, naming/placement rules, reusable services/schemas/components, cross-cutting constraints, and unresolved uncertainty.
7. Decompose into similarly sized, reviewable tasks. Prefer vertical slices when correct. Split shared foundations, migrations, permission changes, public API changes, and UI polish when that improves review quality.
8. Draft a proposal table and task bodies. Each task starts with problem/outcome, scope, non-goals, owner layer, implementation anchors, architecture constraints, and acceptance criteria.
9. Ask for explicit approval to create PM items. Revise first if the user requests changes.
10. Create only approved PM items, preserve dependency order, link related tasks with stable URLs or IDs, and apply metadata only when requested or locally conventional.

## Completion Output

Finish with:

- PM tool and target used.
- Draft-only status or created task URLs.
- Dependency order.
- Suggested next command, for example `implement-pm for tasks #123 #124 #125`.

## Final Checklist

- [ ] 1. PM target and repository resolved safely.
- [ ] 2. User goal, constraints, and assumptions captured.
- [ ] 3. Relevant skills loaded and their constraints recorded.
- [ ] 4. Codebase explored with Serena; existing patterns and risk surfaces identified.
- [ ] 5. Remaining product or scope ambiguities clarified.
- [ ] 6. Responsibility map written before task decomposition.
- [ ] 7. Tasks split into reviewable, dependency-aware units.
- [ ] 8. Proposal table and full task bodies shown to the user.
- [ ] 9. Explicit post-proposal approval received before PM mutation.
- [ ] 10. Approved items created, linked, ordered, and reported with the next command.
