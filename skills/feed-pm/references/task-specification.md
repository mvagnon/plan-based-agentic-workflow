# Task Specification Reference

Use this reference to create or update PM task bodies as execution contracts. The PM item itself is the durable source of truth for the implementer.

## Execution Contract Template

```markdown
## Summary

<One-sentence technical readout of the task and its role in the roadmap.>

## Implementation Objective

<The exact technical outcome this task must deliver.>

## Owner Area And Reuse

- Owner area: <folder/layer/component/service>
- Reuse: <existing service/schema/component/hook/validator/pattern>
- Minimal diff: <reuse, deletion, simplification, or user-approved concession that minimizes added lines relative to deleted lines>
- Constraints: <architecture, validation, auth, data, migration, compatibility, or design-system constraint>

## Expected File Impact

Expected new files:

- `<path>` - <purpose>
- None expected

Expected modified files:

- `<path>` - <change>
- None expected

Expected deleted files:

- `<path>` - <reason>
- None expected

## Interfaces And Data Flow

- Inputs: <API params, props, form fields, events, data sources, or "None">
- Outputs: <responses, UI states, emitted events, persisted data, or "None">
- Data flow: <short plain-text flow or "No cross-boundary data flow">

## Implementation Steps

1. <concrete implementation step>
2. <concrete implementation step>
3. <concrete implementation step>

## Edge Cases / Failure Modes

- <case and expected handling, or "None">

## External Dependencies

- Dependency: <name, service, package, API, or "None">
- Why needed: <reason or "N/A">
- Source/package/API: <identifier or "N/A">
- Documentation: <Before implementation, use Context7 to read current official documentation, or "N/A">

## Acceptance Criteria

- [ ] <observable criterion>
- [ ] <observable criterion>
- [ ] <edge/failure criterion when relevant>

## Verification

- <existing command or review point; do not add new tests unless explicitly requested>

## Dependencies

- Depends on: <task URL/title or "none">
- Unblocks: <task URL/title or "none">
```

## Contract Rules

- Write enough technical detail for an LLM to implement without re-planning the whole roadmap.
- Keep each task scoped to one primary owner area.
- Use exact file paths when repository analysis makes them discoverable.
- Use `<folder>/...` only when the owner area is clear but the exact file cannot be known before implementation.
- Write "None expected" for empty file categories.
- Match the task language to the language the user used to describe the requested work. Keep paths, commands, identifiers, APIs, and product names literal.
- Include the smallest coherent file impact. Prefer reuse, deletion, or a small user-approved concession when it removes large amounts of added code without breaking explicit requirements.
- Keep external dependencies inside each relevant task only. Do not add a global dependency section to the PM item set.
- If a task has no external dependency, write `Dependency: None` and keep the Context7 documentation line only when a dependency exists.
- Do not include Mermaid in PM task bodies by default. Use ordinary prose or compact plain-text sketches.

## Split Rules

Do not optimize for equally sized tasks. Split by engineering surface first.

Create separate tasks whenever the request touches more than one of:

- frontend or presentation work;
- backend, API, data, domain, validation, or authorization work;
- devops, infrastructure, CI/CD, deployment, observability, or environment work.

Also split tasks when one item mixes:

- migration plus UI;
- public API contract plus unrelated visual changes;
- permission model plus convenience refactor;
- shared foundation plus dependent feature work;
- multiple independent journeys;
- several risky integrations.

Merge tasks when separation adds noise:

- a type and its only consumer;
- a schema field and the single service branch that owns it;
- a small hook and the only UI caller.

Do not use merging to hide frontend, backend, or devops work in the same PM task. A shared foundation task is acceptable only when several surfaces depend on it.

## Quality Bar

- One primary owner area per task.
- Dependencies are explicit and acyclic.
- Shared rules, validators, schemas, services, and query keys have one owner.
- Implementation steps are concrete and ordered.
- Interfaces and data flow identify the inputs, outputs, and cross-boundary behavior.
- Edge cases and failure modes are stated when they materially affect implementation.
- Acceptance criteria are observable.
- Titles are action-oriented: `<verb> <scoped technical outcome>`.
- Verification references existing checks unless the user explicitly requested new tests.
- Task scope does not include new tests, new test files, or test-writing work unless the user explicitly requested tests.
- Implementation notes explain how the task minimizes added lines relative to deleted lines and avoids duplicated code.
