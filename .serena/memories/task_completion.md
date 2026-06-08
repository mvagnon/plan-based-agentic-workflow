# Task Completion

For skill edits, run exactly the repository-required checks unless the task scope requires more:

- `bash -n skills/implement-pm/scripts/create-pm-branch.sh`
- `git diff --check`
- Targeted `rg` searches for removed workflow concepts when refactoring behavior.

Before final response:

- Review `git diff` for scope, dead code, duplicated rules, and naming consistency.
- Update README only when setup, commands, environment variables, architecture, or project conventions changed.
- Commit with `<type>/<feature>: <message>` after requested changes and checks pass.