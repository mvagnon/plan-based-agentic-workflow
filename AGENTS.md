# PBAW Repository Instructions

## Skill Shape

Every `skills/<skill-name>/SKILL.md` must keep this shape:

````markdown
# Skill Name

## Summary

## Workflow

_This part is yours. Use the best structure for the skill._

## Expected Response Format

### Decision Gate

_Only include this subsection when the skill can stop for a user decision._

```markdown
Expected response format
```

### Final Response

```markdown
Expected response format
```

## Checklist
````

Use `## Workflow` as the standard concrete content section for the user's `## ton contenu` slot unless a skill has a clearer domain-specific section name.

## Collaboration Model

- Treat the user as the product and architecture authority.
- Treat the user as an experienced software engineer and software architect.
- Ask technical questions at that level. Do not reduce architecture, data, security, or UX decisions to vague product questions.
- Decision Gates should prioritize questions about user experience and database tables/data model. For other topics, focus on blockers or decisions that materially change the implementation plan.

## Skill Authoring Rules

- Keep `SKILL.md` short and operational. Move technical commands, provider details, templates, and API mechanics to `references/`.
- Put deterministic or repetitive logic in `scripts/` instead of explaining it repeatedly in the skill body.
- References must be technical only: commands, schemas, field mappings, API calls, and terse templates.
- Do not add review loops or repeated approval cycles. Use at most one Decision Gate in skills that require user input.
- Keep final response formats concise and task-specific.
- Do not create tests or logs by default.
- Update `agents/openai.yaml` whenever trigger policy or user-facing skill metadata changes.

## Workflow Rules

- `feed-pm`: load relevant architecture, design, and security skills before task decomposition. Use one mandatory Decision Gate, then direct PM task creation unless the user explicitly refuses or the PM target is unsafe.
- `implement-pm`: explicit invocation only. Keep `disable-model-invocation: true` and positional variables in `SKILL.md` frontmatter, and keep `policy.allow_implicit_invocation: false` in `agents/openai.yaml`.
- `implement-pm`: first action is always running `scripts/create-pm-branch.sh` with the declared `pm_tool` and `task_ids` variables.
- `create-pr`: owns draft PR creation, PM task backlinks, and launching `review-pr`. For GitHub Issues, use one closing keyword per issue when valid; validate links for non-default bases when possible; verify PM backlinks after writing.
- `review-pr`: local CI is required for `PROD READY`, merge, and PM task closure. Be strict on security, architecture, and code reuse.
- `fix-pr`: fixes and replies only. It does not rescore, approve, merge, close issues, or move PM items. Use at most one Decision Gate, then apply the remediation path directly unless refused.

## Checks

After editing skills, run:

```bash
bash -n skills/implement-pm/scripts/create-pm-branch.sh
git diff --check
```

Also run targeted `rg` searches for removed workflow concepts when refactoring behavior.
