# Suggested Commands

- List repo files: `rg --files`.
- Inspect targeted text: `rg -n '<pattern>' <paths>`.
- Validate branch script after skill edits: `bash -n skills/implement-pm/scripts/create-pm-branch.sh`.
- Check whitespace/conflict-marker issues before finishing: `git diff --check`.
- Review edits: `git diff -- <paths>` and `git status --short`.
- Commit completed changes with repository format: `<type>/<feature>: <message>`.