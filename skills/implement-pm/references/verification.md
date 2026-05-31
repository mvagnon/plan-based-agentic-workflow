# Verification Reference

Use this reference to discover and run focused existing checks after implementing PM tasks.

## Command Discovery

Inspect project scripts and CI before running checks:

```bash
rg --files -g 'package.json' -g 'turbo.json' -g 'pnpm-workspace.yaml' -g 'yarn.lock' -g 'package-lock.json'
rg --files -g 'pyproject.toml' -g 'pytest.ini' -g 'tox.ini' -g 'poetry.lock' -g 'requirements*.txt'
rg --files -g '.github/workflows/*.yml' -g '.github/workflows/*.yaml'
rg -n '"(lint|typecheck|check|test|format|build)"\\s*:' package.json apps packages services src 2>/dev/null
```

Prefer commands already defined by the target repository:

- type checks;
- lint;
- formatting checks;
- focused existing tests directly affected by the change.

## Common Command Shapes

Use the repository's package manager and task runner. Examples:

```bash
npm run lint
npm run typecheck
npm test -- --runInBand <path-or-pattern>
pnpm lint
pnpm typecheck
pnpm test <path-or-pattern>
yarn lint
yarn typecheck
pytest <path-or-test-name>
ruff check .
mypy .
```

For Turborepo repositories, prefer scoped or affected commands when the repo already uses them:

```bash
turbo run lint --filter=<package>
turbo run typecheck --filter=<package>
turbo run test --filter=<package>
turbo run build --affected
```

Do not start dev servers, containers, browser automation, or watch commands by default.

## Reporting Failures

If a check fails:

- fix failures caused by the implementation;
- do not broaden the task to unrelated pre-existing failures;
- report the failing command, exit state, and concise evidence;
- distinguish changed-code failures from pre-existing or unrelated failures.
