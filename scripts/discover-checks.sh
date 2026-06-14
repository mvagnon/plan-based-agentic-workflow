#!/usr/bin/env bash
set -euo pipefail

root="${1:-}"
if [ -z "$root" ]; then
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    root="$(git rev-parse --show-toplevel)"
  else
    root="$PWD"
  fi
fi

cd "$root"

if ! command -v python3 >/dev/null 2>&1; then
  echo "Missing python3" >&2
  exit 69
fi

echo "Repository: $PWD"
echo
echo "== Manifests =="
if command -v rg >/dev/null 2>&1; then
  rg --files --hidden \
    -g 'package.json' \
    -g 'turbo.json' \
    -g 'pnpm-workspace.yaml' \
    -g 'pyproject.toml' \
    -g 'pytest.ini' \
    -g 'tox.ini' \
    -g '.github/workflows/*.yml' \
    -g '.github/workflows/*.yaml' || true
else
  find . \
    \( -name package.json -o -name turbo.json -o -name pnpm-workspace.yaml -o -name pyproject.toml -o -name pytest.ini -o -name tox.ini -o -path './.github/workflows/*.yml' -o -path './.github/workflows/*.yaml' \) \
    -not -path '*/node_modules/*' \
    -print
fi

echo
echo "== Package scripts =="
python3 - "$PWD" <<'PY'
from __future__ import annotations

import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
script_order = ["test", "lint", "typecheck", "check", "format:check", "build"]

def package_manager(directory: Path) -> str:
    for current in [directory, *directory.parents]:
        if current == root.parent:
            break
        if (current / "pnpm-lock.yaml").exists():
            return "pnpm"
        if (current / "yarn.lock").exists():
            return "yarn"
        if (current / "package-lock.json").exists():
            return "npm"
    return "npm"

def command(pm: str, script: str) -> str:
    if pm == "npm":
        return "npm test" if script == "test" else f"npm run {script}"
    return f"{pm} {script}"

found = False
for path in sorted(root.rglob("package.json")):
    if "node_modules" in path.parts:
        continue
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        continue

    scripts = data.get("scripts")
    if not isinstance(scripts, dict):
        continue

    matches = [name for name in script_order if name in scripts]
    if not matches:
        continue

    found = True
    pm = package_manager(path.parent)
    rel = path.relative_to(root)
    print(f"{rel}:")
    for name in matches:
        print(f"  - {command(pm, name)}")

if not found:
    print("No package check scripts found.")
PY

echo
echo "== Python checks =="
if [ -f pyproject.toml ] || [ -f pytest.ini ]; then
  [ -f pyproject.toml ] && echo "pyproject.toml: inspect for ruff, mypy, pytest configuration"
  [ -f pytest.ini ] && echo "pytest.ini: pytest"
else
  echo "No root Python check configuration found."
fi
