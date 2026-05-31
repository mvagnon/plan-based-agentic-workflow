# Codebase Analysis Reference

Use this reference for the technical mechanics behind the `feed-pm` repository analysis step. The skill body owns the planning flow; this file owns the concrete evidence to collect.

## Serena Startup

Use Serena as the required semantic code-intelligence layer before drafting implementation-ready PM tasks.

1. Load Serena initial instructions once per session when available.
2. Activate the repository root as the Serena project.
3. Prefer symbol overview, symbol lookup, reference lookup, diagnostics, and pattern search before reading full files.
4. Use local search only as a supplement after Serena is available or to diagnose a missing Serena setup.

Useful local fallback commands for narrow discovery:

```bash
git rev-parse --show-toplevel
rg --files -g 'AGENTS.md' -g 'CLAUDE.md' -g 'GEMINI.md' -g 'README.md'
rg --files | rg '(^|/)(docs|adr|architecture|migrations|schemas|tests|apps|packages|services|src)/'
rg -n "TODO|FIXME|feature flag|permission|authorization|validation|schema|DTO|repository|service|hook|queryKey"
```

Do not produce implementation-ready PM tasks from local search alone when Serena is unavailable.

## Evidence Checklist

Capture enough evidence for each proposed task to be implemented without re-planning:

- repository instructions and scoped agent rules;
- matching architecture skills loaded and why they apply;
- affected apps, packages, modules, routes, jobs, migrations, and deployment boundaries;
- owner folders for UI, API clients, hooks, services, repositories, schemas, validation, permissions, and tests;
- existing components, hooks, services, DTOs, validators, repositories, query keys, feature flags, and design-system primitives to reuse;
- allowed dependency direction and any observed boundary constraints;
- relevant check commands from package scripts, task runners, CI config, or project instructions;
- ambiguity that remains product intent rather than discoverable codebase fact.

## Responsibility Map Template

Use the repository's vocabulary. Replace these examples with the actual folders and owners discovered:

```text
Presentation/UI:
  Owner:
  May call:
  Must not own:

Routes/controllers/actions:
  Owner:
  Boundary validation:
  Authorization:

Application/services/domain:
  Owner:
  Business rules:
  Dependencies:

Persistence/integrations:
  Owner:
  Contracts:
  Migration or rollout concerns:

Shared contracts/types:
  Owner:
  Consumers:
  Compatibility constraints:

Verification:
  Existing commands:
  Existing test locations:
```

## Anti-Patterns

- Do not ask the user where code lives when Serena or repository search can discover it.
- Do not paste large code excerpts into issue bodies.
- Do not store task-local planning observations as durable Serena memories.
- Do not create tasks that duplicate existing validators, schemas, query keys, permissions, services, or UI primitives.
