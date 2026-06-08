# Development Rules Reference

Use this reference during `implement-pm` before editing, and during `review-pr` before judging architecture, reuse, testing, or maintainability.

## Priority

Apply rules in this order:

1. Explicit user instructions for the current task.
2. These development rules.
3. Loaded skills.
4. Governing project instruction files such as `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md`.
5. Local code conventions inferred from folders, imports, naming, and nearby implementations.

When rules conflict in a way that changes implementation or review outcome, surface the conflict instead of silently choosing.

## Before Editing

- Load governing project instruction files.
- Use Serena to inspect the affected code path.
- Before adding any component, hook, utility, type, schema, decorator, service, or abstraction, search for an existing equivalent.
- Reuse existing schemas, DTOs, types, constants, validators, services, hooks, repositories, components, layout primitives, tokens, variants, icons, spacing, typography, and colors.
- If an existing owner is close but incomplete, extend, compose, or refactor it instead of creating a parallel implementation.

## Implementation Rules

- Keep changes focused on the PM task and avoid unrelated rewrites.
- Keep business rules in one place. Extract repeated conditions, transformations, validation, permission checks, formatting rules, and workflows.
- Follow existing data-fetching, validation, typing, component, backend, security, and error-handling patterns.
- Keep handlers/controllers thin, validate inputs at boundaries, never trust client-provided data, and enforce authorization on the server side.
- Do not add dependencies, hidden behavior, broad abstractions, broad refactors, logs, or tests by default.
- Keep code simple, explicit, consistently named, strictly typed where useful, and free of dead code.

## Frontend Adaptation

- Consume APIs through the existing data layer. If the project uses TanStack Query, components use custom hooks, hooks use Query, and raw network calls stay in client/API functions.
- Use skeletons for initial async data display and spinners for user-triggered async actions.
- Disable duplicate unsafe actions while pending and surface errors intentionally.
- Keep meaningful components in separate files and prefer variants over near-duplicate components.
- Reuse design-system primitives before local styling.

## Tests

- Do not create new tests by default during implementation.
- Update existing tests only when directly affected by the implementation.
- If test creation is explicitly requested, prefer the dedicated journey-test workflow from `write-tests` instead of writing narrow feature-level tests inside `implement-pm`.
- Install that workflow when needed:

```bash
npx skills add mvagnon/skills --skill write-tests
```

## Before Finishing

- Run relevant existing checks discovered from the repository.
- Review the diff for scope, duplication, dead code, inconsistent naming, missed reuse, and regressions.
- Update README files only when setup, commands, environment variables, architecture, or project conventions changed.
- Commit only task-related changes with the repository commit-message convention.
