---
name: feed-pm
description: "Use this skill when the user wants to turn a product request, feature scope, bug, refactor, or backlog idea into implementation-ready PM tasks. Requires a task/request description; pm_tool and project_id are optional. It analyzes the repository with Serena MCP, uses exactly one Decision Gate for clarification or task-creation confirmation, creates PM tasks directly, preserves the user's task-description language, and returns a concise recap. Trigger on feed PM, create issues, create PM tasks, split work into tickets, prepare Jira/GitHub/Notion tasks, or plan-based agentic workflow."
---

# Feed PM

## Summary

Turn one product or engineering request into PM tasks that are grounded in the codebase.

The workflow has one user stop: a mandatory Decision Gate. Use it either to ask the missing clarification questions or to confirm task creation. If the user answers clarification questions and does not explicitly refuse creation, create the tasks directly after that answer.

Treat the user as the product and architecture authority, and as an experienced software engineer/architect.

Use one stop only and do not use runner-specific clarification tools.

## Diagram

```mermaid
flowchart TD
  A[Read request, pm_tool, project_id, and tasks] --> B[Load relevant skills and references]
  B --> C[Analyze repository with Serena]
  C --> D[Draft language-matched task set]
  D --> E[Split frontend, backend, devops, and shared work]
  E --> F{Decision Gate}
  F -->|Needs clarification| G[Ask UX, DB, PM target, or blocking questions]
  F -->|Ready| H[Ask for task creation confirmation]
  G --> I[User answers]
  H --> I
  I --> J{Explicit refusal or unsafe target?}
  J -->|Yes| K[Stop with blocker recap]
  J -->|No| L[Create PM tasks with compact summaries]
  L --> M[Recap task URLs and next implement-pm command]
```

## Workflow

### Inputs

Read the explicit invocation or user message as:

- `pm_tool`: optional, for example `github`, `jira`, `notion`, or another installed PM MCP/CLI.
- `project_id`: optional repository, board, project, database, or PM target.
- `tasks`: required unless the request is clear from the conversation.

If `pm_tool` or `project_id` are missing/unclear, fall back to GitHub Issues on the repository or repositories concerned by the request when the remotes, `gh` authentication, and issue settings make that safe. If the target cannot be resolved safely, use the Decision Gate to ask for the missing PM target detail.

Preserve the language used by the user to describe the requested work for PM task titles, task bodies, Decision Gate task previews, and the final recap. Keep code identifiers, paths, commands, API names, and product terms literal.

### References

Load only the references needed for the current PM tool:

- `references/codebase-analysis.md` for Serena exploration.
- `references/task-specification.md` for concise PM task bodies.
- `references/pm-tools.md` for PM discovery and item creation commands.

### Rules

- Use Serena before drafting tasks. If Serena is unavailable, stop instead of creating implementation-ready tasks from local search alone.
- Load relevant architecture, design, and security resources if any before decomposing tasks.
- Discover repository facts before asking the user: files, ownership, schemas, routes, services, components, validators, conventions, and check commands.
- Ask questions that affect user experience or database tables/data model even when not strictly blocking. For architecture, security, API, validation, delivery, and PM target, focus on blockers or decisions that materially change the task set.
- Match the PM task language to the dominant language the user used to describe the work.
- Do not force tasks to have equal size. Uneven tasks are correct when the engineering boundaries are uneven.
- Separate frontend, backend, and devops work into distinct PM tasks whenever the request touches more than one of those surfaces. Omit a surface only when it has no real implementation work.
- Keep shared contracts, schemas, tokens, or foundations in their own task only when they are reused by several surfaces; do not hide frontend, backend, or devops implementation inside that shared task.
- Use exactly one Decision Gate.
- Do not write local planning Markdown.
- Do not use runner-specific clarification tools. The Decision Gate is normal chat.
- Do not create duplicate tasks for the same business rule, validator, component, or workflow.
- Do not invent labels, statuses, assignees, milestones, project fields, or PM schema values.
- Create tasks even without an explicit "yes" when the user answered clarification questions and did not refuse task creation.

### Task Creation

After the Decision Gate response:

1. Apply the user's answers and conservative defaults.
2. Create one PM item per task in dependency order.
3. Include task dependencies using native PM relationships when safely available; otherwise include dependency URLs in the task body.
4. Include a compact task summary with expected new, modified, and deleted files plus either a one-sentence technical readout or a compact plain-text diagram.
5. Return a short recap with task URLs and the next `implement-pm` request details.

If the user explicitly refuses creation, changes the scope so much that the task set is invalid, or the PM target is still unsafe to mutate, stop and report the blocker. Do not start a second Decision Gate.

## Expected Response Format

### Decision Gate

Use this exact shape for the single stop:

```markdown
## Decision Gate

I need one Decision Gate before creating PM tasks.

Questions or confirmation:

- <UX question, database/data-model question, blocker, or creation confirmation>

Recommended defaults:

- <default and why it is safe>

What I will create:

- <task title 1> - <frontend|backend|devops|shared> - <one-line technical summary>
- <task title 2> - <frontend|backend|devops|shared> - <one-line technical summary>

After your answer:

- I will create the PM tasks directly unless you explicitly refuse creation or change the scope.
```

### Final Response

```markdown
## Feed PM

PM target: <tool and project/repository target>

Created:

- <task id/title>: <url>

Dependency order:

1. <task id/title>
2. <task id/title>

Next:
Use `implement-pm` with `<pm-tool>` and `<task-ids>`.
```

If no tasks were created, replace `Created` with `Not created` and give the blocking reason.

## Checklist

- [ ] Repository and PM target resolved safely.
- [ ] Relevant architecture, design, and security resources if any are loaded before task decomposition.
- [ ] Serena used before task drafting.
- [ ] Existing architecture, validation, typing, business logic, and design-system patterns identified.
- [ ] PM task language matches the language used by the user to describe the work.
- [ ] Frontend, backend, and devops work separated whenever more than one surface is involved.
- [ ] Each task summary lists expected new, modified, and deleted files, plus a one-sentence technical readout or compact plain-text diagram.
- [ ] Exactly one Decision Gate used.
- [ ] No local planning Markdown written.
- [ ] PM tasks created directly after a non-refusal Decision Gate answer.
- [ ] Final recap includes task URLs, dependency order, and the next `implement-pm` request details.
