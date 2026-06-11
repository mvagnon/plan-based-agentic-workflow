# Direct Implementation Reference

Use this reference only when the user chooses to implement directly from an approved `feed-pm` plan instead of creating PM tasks.

## Boundary

Direct implementation is not the default path.

Do not invoke the `implement-pm` skill. Reuse its branch script and development rules only:

- `../../implement-pm/scripts/create-pm-branch.sh`
- `../../implement-pm/references/development-rules.md`
- `../../implement-pm/references/implementation-git.md`

Do not create PM tasks, PM backlinks, PR descriptions, review comments, or PM status updates from this path.

## Branch Arguments

The approved plan must include explicit branch script arguments:

```text
pm_tool: direct
task_ids: <scope-slug>
```

Choose `<scope-slug>` from the approved scope:

- use lowercase kebab-case;
- keep it short and readable;
- include only letters, numbers, dots, underscores, and hyphens;
- do not include spaces, slashes, secrets, URLs, or PM IDs that were not provided.

Examples:

```bash
skills/implement-pm/scripts/create-pm-branch.sh "direct" "checkout-error-state"
skills/implement-pm/scripts/create-pm-branch.sh "direct" "dashboard-filters"
```

## Workflow

1. Confirm the user selected direct implementation from the latest approved `feed-pm` plan.
2. Load `../../implement-pm/references/development-rules.md`.
3. Run the branch script with the explicit arguments from the plan before editing.
4. Implement only the approved scope.
5. Run relevant existing checks.
6. Review the diff for scope, reuse, net added lines, dead code, and regressions.
7. Report the implementation result and next `create-pr` step.

If the approved plan lacks explicit branch script arguments, ask for or propose the exact `direct/<scope-slug>` branch arguments before editing.
