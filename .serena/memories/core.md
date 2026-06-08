# Core

- Repository packages PBAW agent skills under `skills/<skill>/` with one `SKILL.md`, optional `references/`, `scripts/`, and `agents/openai.yaml` metadata.
- Main workflow order: `feed-pm` -> `implement-pm` -> `create-pr` -> `review-pr` -> `fix-pr` as documented in `README.md`.
- Repository authoring source of truth: `AGENTS.md`; read it before editing skills.
- Skill bodies must stay short and operational; move commands/provider mechanics/templates into `references/`, deterministic logic into `scripts/`.
- Every skill `SKILL.md` keeps shape: Summary, Diagram, Workflow, Expected Response Format, Checklist.
- Mermaid diagrams are required inside `SKILL.md` and should represent operational workflow states only.

Read `mem:conventions` for skill authoring rules, `mem:task_completion` for required finish checks, and `mem:tech_stack` for project tooling.