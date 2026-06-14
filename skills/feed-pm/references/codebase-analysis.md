# Codebase Analysis Reference

Use this reference for the technical evidence behind `feed-pm`.

## Serena Startup

Use Serena as the required code-intelligence layer before creating or updating PM tasks.

```bash
git rev-parse --show-toplevel
rg --files -g 'AGENTS.md' -g 'CLAUDE.md' -g 'GEMINI.md' -g 'README.md'
```

Prefer Serena symbol overview, symbol lookup, reference lookup, diagnostics, and pattern search before reading full files. Use local search only as a supplement.

If Serena is unavailable, stop. Do not create or update implementation-ready PM tasks from local search alone.

## Evidence To Collect

Capture only what affects task boundaries:

- implementation details supplied by the user, including desired behavior, affected surfaces, data model/API notes, constraints, non-goals, rollout needs, and preferred direction;
- repository instructions and loaded architecture skills;
- owner folders for UI, routes/controllers/actions, services/domain, repositories, schemas, validation, permissions, and integrations;
- existing components, hooks, services, DTOs, validators, repositories, query keys, feature flags, and design-system primitives to reuse;
- dependency direction and package boundaries;
- public API, data model, migration, authorization, validation, and rollout constraints;
- expected new, modified, and deleted files for each task, using exact paths when discoverable and owner folders otherwise;
- the smallest coherent file impact, including expected added/deleted line pressure, reuse opportunities, and small concessions that could avoid unnecessary added lines if the user approves them;
- frontend, backend, and devops surfaces touched by the request;
- existing check commands from scripts, task runners, CI config, or project instructions;
- product or architecture uncertainty that is not discoverable from code.

## Responsibility Map Shape

Use the repository's vocabulary. Keep it short.

```text
UI/presentation:
API/boundaries:
Domain/services:
Persistence/integrations:
Shared contracts/types:
Verification:
```

## Anti-Patterns

- Do not ask the user where code lives when Serena or repository search can discover it.
- Do not paste large code excerpts into PM tasks.
- Do not create tasks that duplicate existing validators, schemas, query keys, permissions, services, or UI primitives.
- Do not create a generic plan that could fit another repository.
- Do not include new tests, test files, or test-writing tasks unless the user explicitly requested tests.
