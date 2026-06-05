# Task Specification Reference

Use this reference to create concise PM task bodies. The PM item itself is the durable source of truth.

## Task Body Template

```markdown
## Summary

<One-sentence technical readout OR a compact plain-text diagram when that is faster to scan.>

Expected new files:

- `<path>` - <purpose>
- None expected

Expected modified files:

- `<path>` - <change>
- None expected

Expected deleted files:

- `<path>` - <reason>
- None expected

## Outcome

<One sentence describing the user/developer-visible result.>

## Scope

- <included work>
- <included work>

## Non-Goals

- <explicitly excluded work, or "None">

## Implementation Notes

- Owner area: <folder/layer/component/service>
- Reuse: <existing service/schema/component/hook/validator/pattern>
- Constraints: <architecture, validation, auth, data, migration, or compatibility constraint>

## Acceptance Criteria

- [ ] <observable criterion>
- [ ] <observable criterion>
- [ ] <edge/failure criterion when relevant>

## Dependencies

- Depends on: <task URL/title or "none">
- Unblocks: <task URL/title or "none">

## Verification

- <existing command or review point>
```

## Summary Rules

Use the task summary as the fastest engineering read.

- Use exact file paths when repository analysis makes them discoverable.
- Use `<folder>/...` only when the owner area is clear but the exact file cannot be known before implementation.
- Write "None expected" for empty file categories.
- Use a one-sentence technical readout by default.
- Use a compact plain-text diagram only when ownership, data flow, sequence, dependencies, or state transitions are clearer visually.
- Match the task language to the language the user used to describe the requested work. Keep paths, commands, identifiers, APIs, and product names literal.

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
- Acceptance criteria are observable.
- Titles are action-oriented: `<verb> <scoped technical outcome>`.
- Verification references existing checks unless the user explicitly requested new tests.
