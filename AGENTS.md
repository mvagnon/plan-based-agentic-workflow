# PBAW Repository Instructions

## Skill Shape

Every `skills/<skill-name>/SKILL.md` must keep this shape:

```markdown
# Skill Name

## Summary

## Diagram

## Inputs

## References

## Workflow

## Expected Response Format
```

Use `## Workflow` as the standard concrete content section for the skill. You can adapt it depending on the skill being built.

## Mermaid Diagrams

Every `SKILL.md` should include a compact `## Diagram` section.

For repository skill documentation, use Mermaid only for static workflow diagrams inside the skills in this repository. Keep diagrams operational, not decorative:

- show the major workflow states and decision points;
- show user decision, clarification, approval, and blocker paths when they affect the workflow;
- show stop/blocker paths when they affect the workflow;
- keep node labels short enough to scan quickly;
- update the diagram whenever workflow order, ownership, or stopping behavior changes.

Do not make runtime workflows load `mermaid-diagrams`, and do not push generated PM tasks, PRs, reviews, or comments to use Mermaid by default. Exception: `feed-pm` may load `mermaid-diagrams` only to add one compact Mermaid summary at the top of the pre-approval Technical Roadmap. PM task bodies should use ordinary prose or compact plain-text sketches when that is the clearest durable spec.

## Collaboration Model

- Treat the user as the product and architecture authority.
- Treat the user as an experienced software engineer and software architect.
- Ask technical questions at that level. Do not reduce architecture, data, security, or UX decisions to vague product questions.
- User questions and proposed plans should prioritize decisions about user experience and database tables/data model. For other topics, focus on blockers or decisions that materially change the implementation plan.

## Skill Authoring Rules

- Keep `SKILL.md` short and operational. Move technical commands, provider details, templates, and API mechanics to `references/`.
- Put deterministic or repetitive logic in `scripts/` instead of explaining it repeatedly in the skill body.
- References must be technical only: commands, schemas, field mappings, API calls, and terse templates.
- Use Mermaid diagrams for repository skill documentation and keep them synchronized with the workflow instructions.
- Do not add review loops or repeated approval cycles. Prefer runner-native questions and Plan Mode for user decisions when the runner supports them.
- Keep final response formats concise and task-specific.
- Do not create tests or logs by default.
- Quote every `description` value in `SKILL.md` frontmatter. Frontmatter is YAML; unquoted `: ` inside descriptions can make `npx skills add` and `npx skills update` silently skip the skill.

## Workflow Rules

- `feed-pm`: load relevant architecture, design, and security skills before task decomposition. Recommend Plan Mode, use the runner-native question/clarification tool when available, propose a complete PM task plan, preserve the previous plan when challenged, and create PM tasks only after explicit user approval.
- `implement-pm`: require PM system name and exact task IDs, regardless of prompt shape. Describe required inputs in the `SKILL.md` frontmatter description.
- `implement-pm`: first action is always running `scripts/create-pm-branch.sh` with the declared `pm_tool` and `task_ids` variables.
- `create-pr`: owns draft PR creation, PM task backlinks, and launching `review-pr`. For GitHub Issues, use one closing keyword per issue when valid; validate links for non-default bases when possible; verify PM backlinks after writing.
- `review-pr`: local CI is required for `PROD READY`, merge, and PM task closure. Be strict on security, architecture, and code reuse. Post review details on the PR and return only PR URLs in chat.
- `fix-pr`: fixes and replies directly. It does not rescore, approve, merge, close issues, or move PM items. Collect PR feedback, inspect cited code, apply focused fixes, run checks, commit and push, then reply to handled conversations. Ask the user only for blockers that require an explicit product, architecture, security, access, or scope decision.

## Checks

After editing skills, run:

```bash
bash -n skills/implement-pm/scripts/create-pm-branch.sh
scripts/validate-skills.sh
git diff --check
```

Also run targeted `rg` searches for removed workflow concepts when refactoring behavior.
