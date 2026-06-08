# Development Rules Reference

Use this reference during `implement-pm` before editing and final diff review, during `fix-pr` before remediation edits and replies, and during `review-pr` before judging concrete implementation hygiene, local change safety, checks, and finalization readiness.

This file covers implementation mechanics. Use `../../feed-pm/references/architecture-rules.md` for broad planning, architecture, ownership, reuse, and duplication policy.

## Before Editing

- Load governing project instruction files.
- Use Serena to inspect the affected code path and nearby ownership before changing files.
- Search for an existing equivalent before adding any component, hook, utility, type, schema, decorator, service, repository, validator, query key, or abstraction.
- If an existing owner is close but incomplete, extend it, compose it, add a variant, or make a focused refactor instead of creating a parallel implementation.
- Preserve unrelated local work. Do not stash, reset, unstage, delete, overwrite, force-delete, or commit unrelated changes unless the user explicitly asks.

## Focused Implementation

- Keep changes scoped to the PM task, approved remediation plan, or explicit user request.
- Prefer the smallest correct change that fits the existing architecture and local conventions.
- Follow existing data-fetching, validation, typing, component, backend, security, and error-handling patterns.
- Keep code clear, explicitly named, consistently organized, strictly typed where useful, and free of dead code, unused imports, unused variables, obsolete files, and hidden behavior.
- Do not weaken types to silence errors.
- Do not add dependencies, broad abstractions, broad refactors, logs, or new tests by default.
- If a requested fix would require broad architecture changes, stop and report the mismatch instead of expanding scope silently.

## Frontend Details

- Consume APIs through the existing data layer. If the project uses TanStack Query, components use custom hooks, hooks use Query, and raw network calls stay in client/API functions.
- Disable actions that cannot safely run twice while pending.
- Use spinners for user-triggered async actions and skeletons for initial async data display.
- Surface errors intentionally, with retry affordances for data-display failures when relevant.
- Keep meaningful components in separate files when the implementation creates or substantially changes component structure.
- Reuse design-system primitives before local styling.

## Backend And Security Details

- Keep handlers/controllers thin.
- Validate inputs at boundaries.
- Never trust client-provided data.
- Enforce authorization on the server side.
- Use existing security utilities and middleware.
- Keep database queries intentional and avoid obvious N+1 patterns.
- Use transactions for multi-step writes that must stay consistent.
- Treat file uploads, redirects, dynamic queries, and user-generated content as high-risk areas.

## Tests And Logs

- Do not create new tests by default.
- Update existing tests only when directly affected by the implementation or remediation.
- If test creation is explicitly requested, prefer the dedicated journey-test workflow from `write-tests` instead of narrow implementation-detail tests.
- Do not add logs by default.

## Checks

Discover relevant existing checks:

```bash
rg --files -g 'package.json' -g 'turbo.json' -g 'pnpm-workspace.yaml' -g 'pyproject.toml' -g 'pytest.ini' -g '.github/workflows/*.yml' -g '.github/workflows/*.yaml'
rg -n '"(lint|typecheck|check|test|format|build)"\s*:' package.json apps packages services src 2>/dev/null
```

Prefer existing repo-level commands when relevant:

```bash
npm test
npm run lint
npm run typecheck
npm run build
pnpm test
pnpm lint
pnpm typecheck
pnpm build
yarn test
yarn lint
yarn typecheck
yarn build
pytest
ruff check .
mypy .
```

Do not start dev servers, watch commands, containers, or browser automation by default.

Report commands as `not run` when no relevant existing command exists or when the only available check requires an excluded long-running tool.

## Before Finishing

- Review the diff for scope, duplication, dead code, inconsistent naming, missed reuse, and regressions.
- Update README files only when setup, commands, environment variables, architecture, or project conventions changed.
- Follow the owning skill's Git behavior: `implement-pm` commits without pushing, `fix-pr` commits and pushes after approved remediation, and `review-pr` does not implement fixes.
