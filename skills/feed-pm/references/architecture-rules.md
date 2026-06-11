# Architecture Rules Reference

Use this reference during `feed-pm` before task decomposition and during `review-pr` before judging broad architecture, reuse, duplication, security, frontend, backend, data, and design-system compliance.

## Priority

Apply rules in this order:

1. Explicit user instructions for the current task.
2. Non-negotiable reuse, duplication, validation, typing, design-system, security, and no-hidden-scope rules from this file.
3. Governing project instruction files such as `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` for concrete architecture, layering, ownership, commands, and conventions.
4. Loaded skills.
5. Local code conventions inferred from folders, imports, naming, and nearby implementations.

When rules conflict in a way that changes the task plan or review verdict, surface the conflict instead of silently choosing.

## Architecture Basis

- Load governing project instruction files before planning or reviewing.
- Load relevant architecture, design, security, framework, and provider skills when the request or codebase calls for them.
- Treat declared project architecture, layering, dependency direction, and ownership rules as authoritative for concrete boundaries.
- Use code to locate current implementation, reusable owners, and affected files. Do not treat existing folder shape, imports, or naming as architecture authority when governing instructions are missing or incomplete.
- If architecture instructions are missing, incomplete, ambiguous, or insufficient for the plan, ask the user for architectural direction before decomposing architecture-sensitive work.
- If a named architecture is documented but its rules are missing, inconsistent, or imprecise, ask for the missing direction or research best practices for the same architecture and stack with Exa MCP before using inferred details in a review verdict.

## Reuse And Ownership

- Reuse existing code before creating new code.
- Before planning or accepting a new component, hook, utility, type, schema, DTO, decorator, service, repository, validator, query key, permission check, workflow, or abstraction, identify the existing owner or verify that none exists.
- If something similar exists, extend it, compose it, add a variant, or refactor the owner instead of creating a parallel implementation.
- Business rules must have one owner. Do not duplicate conditions, transformations, validation, authorization, permissions, formatting, data-fetching workflows, query construction, or API workflows.
- Reuse existing validation, typing, constants, enums, DTOs, interfaces, schemas, and validators. Do not redefine the same shape in several places.
- Reuse existing design-system primitives, tokens, variants, spacing, typography, colors, icons, layouts, and UI patterns before local styling.

## Task Boundaries

- Keep changes focused on the requested product or engineering outcome.
- Separate frontend, backend, and devops work into distinct PM tasks when more than one surface has real implementation work.
- Use a shared foundation task only when several surfaces depend on the same schema, contract, token, data model, or reusable primitive.
- Do not hide frontend, backend, or devops implementation inside a shared task.
- Do not introduce new dependencies, broad abstractions, broad rewrites, hidden behavior, or unrelated refactors as part of planning or review approval.
- Minimize net new implementation lines. Prefer plans with fewer added lines after accounting for deleted lines, and prefer deletion, reuse, or extension over adding parallel code.
- Surface small concessions in optional behavior, polish, generality, or configurability when they avoid a much larger diff without violating explicit requirements, security, or documented architecture; require user approval before depending on those concessions.
- Treat one line of code as one potential maintenance debt when choosing between otherwise valid plans.

## Frontend Architecture

- Follow the existing data-fetching architecture. If the project uses TanStack Query, components consume APIs through custom hooks, hooks use TanStack Query, and raw network calls stay in dedicated API/client functions.
- Keep query keys stable, explicit, and colocated with the owning feature when possible.
- Use skeletons for initial async data display and spinners for user-triggered async actions.
- Surface errors intentionally; do not silently swallow them.
- Keep meaningful components in separate files and prefer variants over near-duplicate components.
- Treat a new local UI component as a bug when an existing UI or design-system primitive can be reused.
- Keep mobile-first responsive behavior aligned with existing layout and typography patterns.

## Backend And Security Architecture

- Keep handlers/controllers thin and put business logic in services or domain modules.
- Validate inputs at boundaries and never trust client-provided data.
- Enforce authentication and authorization on the server side.
- Use existing security utilities and middleware.
- Make error handling explicit.
- Prefer transactions for multi-step writes that must stay consistent.
- Keep database queries intentional and avoid obvious N+1 patterns.
- Treat file uploads, redirects, dynamic queries, and user-generated content as high-risk areas.
- Never commit secrets, tokens, API keys, credentials, or private environment values.

## Planning And Review Evidence

- For `feed-pm`, collect enough evidence to name owner folders, reusable primitives, validation and typing owners, data model constraints, security constraints, expected file changes, and existing check commands.
- For `review-pr`, judge architecture from governing instructions and these rules; use code to verify compliance, not to lower the bar.
- Treat duplication in changed code as a bug, including near-duplicate files or components that should become one component with variants.
- Treat missed reuse, duplicated business logic, duplicated validation, duplicated permission checks, or duplicated data transformations as blockers when they affect changed code.
- For `feed-pm`, include the smallest coherent file impact, expected added/deleted file impact, and any reuse or user-approved concession that keeps the implementation compact.
- Do not plan new tests, new test files, or test-writing work unless the user explicitly requested tests.
