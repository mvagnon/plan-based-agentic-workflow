# Repo Analysis Reference

Use this reference for repository evidence before external research.

## Startup

Use Serena as the required code-intelligence layer.

Local discovery commands that can support Serena:

```bash
git rev-parse --show-toplevel
rg --files -g 'AGENTS.md' -g 'CLAUDE.md' -g 'GEMINI.md' -g 'README.md'
rg --files
```

Read governing instructions before implementation files:

```text
AGENTS.md
CLAUDE.md
GEMINI.md
README.md
```

If Serena is unavailable, stop. Do not produce a repository-grounded recommendation from local text search alone.

## Evidence To Capture

Capture only evidence that changes the recommendation:

- documented architecture, ownership, layering, dependency direction, and no-go constraints;
- feature owner folders and directly affected packages or apps;
- existing services, hooks, components, schemas, validators, DTOs, repositories, clients, commands, routes, or integrations to reuse;
- current dependencies that already solve part of the request;
- data model, migration, persistence, API, auth, authorization, privacy, and deployment constraints;
- package manager, runtime, framework versions, and build constraints when discoverable;
- existing check commands from scripts, task runners, CI config, or project instructions;
- missing architecture instructions that limit confidence.

## Responsibility Map Shape

Use the repository's vocabulary and keep the map compact.

```text
UI/presentation:
API/boundaries:
Domain/services:
Persistence/integrations:
Shared contracts/types:
Dependencies:
Verification:
```

## Anti-Patterns

- Do not ask the user where code lives when Serena or repository search can discover it.
- Do not infer undocumented architecture from folder names as if it were authoritative.
- Do not recommend a dependency before checking for existing local primitives or dependencies.
- Do not paste large code excerpts into the recommendation.
