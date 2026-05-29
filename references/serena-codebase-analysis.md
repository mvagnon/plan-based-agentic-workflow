# Serena Codebase Analysis

Use Serena as the primary code-intelligence layer when it is installed. The goal is to collect enough architectural evidence for planning or implementation without loading the whole repository into context.

## Startup

1. Call Serena initial instructions once per session if available.
2. Call the current-config/capability tool and note active tools. A useful Serena setup usually includes:
   - project activation;
   - symbol overview and symbol lookup;
   - reference lookup;
   - pattern search;
   - diagnostics;
   - memory read/write when the project has durable conventions.
3. Activate the repository root as the Serena project.
4. If onboarding is requested, perform only durable project-memory work that helps future tasks. Do not store task-local findings as memories.

## Exploration Order

Use this order before reading full source files:

1. Project instructions: locate `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, scoped instruction files, runner rules, and skill-specific rules.
2. Agent resources: inspect project-local skills, commands, prompts, MCP configuration, and workflow docs that define how this repository expects agents to plan or implement work.
3. Architecture resources: inspect ADRs, architecture docs, package/module READMEs that explain ownership, diagrams, API/schema docs, database/migration docs, and existing PM issues/PRs that clarify the requested area.
4. Repository topology: apps, packages, services, migrations, API routes, jobs, tests, scripts, design-system folders, generated code folders, and deployment/runtime folders.
5. Symbol overview: inspect relevant files/modules at the symbol level.
6. Symbol lookup: read bodies only for symbols that are likely implementation anchors.
7. References: use reference lookup to find callers, consumers, ownership boundaries, and duplication risks.
8. Pattern search: find schemas, DTOs, constants, permissions, query keys, route names, feature flags, error types, existing tests, and existing data-fetching patterns.
9. Diagnostics: run language diagnostics for changed files where the tool supports it.

## Architecture Responsibility Map

For planning, build a short map of the affected architecture before proposing tasks. Capture the responsibility of each relevant zone, for example:

- `app/`, `pages/`, `routes/`, or controllers: route composition, boundary validation, auth checks, response shaping.
- `components/` or design-system packages: presentational UI and reusable primitives.
- hooks or feature adapters: UI consumption of server state, usually through the project's existing data layer.
- `infrastructure/`, `adapters/`, `clients/`, or API packages: raw HTTP/fetch/SDK calls and external service integration.
- services, use cases, domain modules: business rules, workflow orchestration, invariants.
- repositories, persistence adapters, migrations, schema folders: database access, data model changes, persistence contracts.
- DTOs, validators, schema modules, generated types: boundary contracts and type-safe transformations.
- jobs, queues, events, webhooks: async side effects and retry/error contracts.
- tests, fixtures, factories: where existing verification patterns live.

Also capture allowed dependency direction. Examples:

- UI hooks consume API adapters; they do not duplicate fetch logic.
- Controllers/routes call services; they do not own business rules.
- Services depend on repositories or ports; they do not import UI concerns.
- Shared validation/types live in the existing schema/type owner rather than being redefined per feature.

If the repository uses different names, preserve the repository's vocabulary and map those names instead.

## Evidence To Capture

For planning tasks, capture:

- relevant files and symbols;
- existing patterns to reuse;
- architecture responsibility map for the affected area;
- owner layer/folder for each proposed task;
- missing or duplicated abstractions;
- data/API contracts and schema locations;
- known checks and task runners;
- dependency order between slices.

For implementation tasks, capture:

- exact symbols to modify;
- references that must remain compatible;
- generated files or migrations that require special commands;
- check commands scoped to the changed modules.

## Fallback When Serena Is Missing

Fall back to `rg`, `rg --files`, package scripts, manifests, and targeted file reads. Preserve the same discipline:

- search first;
- read narrow files;
- avoid full-directory dumps;
- cite file paths and symbol names instead of large code excerpts.

## Anti-Patterns

- Do not read entire large files before using symbol overview/search.
- Do not create tasks from product text alone when the codebase can reveal existing boundaries.
- Do not store volatile task observations as Serena memories.
- Do not let generated plans duplicate existing schemas, validators, hooks, or business rules.
