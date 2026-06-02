# Verification Reference

Use existing repository checks that are relevant to the changed area.

## Discover Commands

```bash
rg --files -g 'package.json' -g 'turbo.json' -g 'pnpm-workspace.yaml' -g 'pyproject.toml' -g 'pytest.ini' -g '.github/workflows/*.yml' -g '.github/workflows/*.yaml'
rg -n '"(lint|typecheck|check|test|format|build)"\s*:' package.json apps packages services src 2>/dev/null
```

## Common Commands

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
