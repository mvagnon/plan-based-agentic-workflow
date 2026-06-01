---
name: implement-pm
description: Use this skill when the user wants to implement one or more PM tasks, GitHub Issues, Notion tasks, or plan-based workflow items in the current checkout or a workspace containing child repositories. It resolves the exact tasks, creates dedicated branch(es) and draft PR(s) before implementation, links every task, writes a merged PR description with expected outcomes and validation intent, studies the repository with Serena MCP, preserves unrelated local work, implements focused changes, runs relevant checks, commits and pushes, then reports PRs, changes, checks, and risks.
---

# Implement PM

## Purpose

Implement approved PM tasks in the owning checkout while preserving task traceability, local user work, and repository architecture.

## Inputs

Read `$ARGUMENTS` or equivalent natural language as:

- `Tasks`: required. Accept GitHub issue numbers or URLs, Notion page URLs, task IDs, or a small query that resolves to exact PM items.
- `PM Tool`: optional. Default to GitHub Issues for the repository or child repositories that own the target remotes.
- `Project`: optional. Accept a repository, project URL, or project number.

Ask one concise question only when task references cannot be resolved exactly. Do not guess between multiple matching tasks.

## References

Load only what is needed:

- `references/pm-task-retrieval.md` for task resolution, dependencies, and canonical task sets.
- `references/implementation-git-github.md` for repository preflight, branches, draft PRs, task links, commits, and pushes.
- `references/verification.md` for check discovery and failure reporting.

## Rules

- Resolve every requested task before branch or PR work. Never collapse a multi-task request to the first task.
- Work in the current checkout or affected child checkout. Do not create secondary checkouts.
- Keep one branch and one draft PR per affected repository.
- Create draft PRs and required task links before implementation edits.
- Treat the PR body as a review handoff: include task links plus a concise merged summary of expected outcomes, validation intent, and explicit out-of-scope items derived from the resolved task set.
- Use Serena first. If Serena is unavailable, stop instead of implementing from local search alone.
- Reuse existing components, hooks, services, schemas, validators, DTOs, repositories, utilities, and design-system primitives before creating anything new.
- Do not add dependencies, create logs, mark PRs ready, merge PRs, update PM statuses, or create tests by default.

## Workflow

1. Resolve tasks and repositories. Fetch task title, body, labels/status, comments that change scope, dependencies, linked tasks, canonical URLs, and writable backlink options.
2. Map each task to the affected repository or repositories. Ask before branch work if child-repository ownership cannot be inferred safely.
3. Prepare each repository: identify root, current branch, remotes, status, and source/base branch. Preserve staged, unstaged, untracked, and unrelated local work.
4. Create or switch to a dedicated invocation branch from the current checkout state.
5. Open each draft PR to the recorded source/base branch before implementation edits. Put every task reference at the top of the PR body, then synthesize the concerned tasks into expected outcomes, validation intent, and explicit out-of-scope items. Link GitHub Issues with native syntax and write non-GitHub PR backlinks where supported.
6. Confirm every resolved task appears in the draft PR body, the merged expected outcomes are present, and every required non-GitHub backlink is present. Stop before implementation if required linkage fails.
7. Implement the tasks using Serena and loaded repository rules. Keep business logic centralized, handlers/controllers thin, boundary validation explicit, and server-side authorization enforced.
8. Run relevant existing checks from package scripts, task runners, or CI config. Avoid dev servers, containers, browser automation, and watch commands by default.
9. Fix critical failures caused by your changes. Report unrelated pre-existing failures with evidence.
10. Self-review the diff, remove dead code and unused imports introduced by the change, verify no secrets were added, stage only invocation changes, commit with local style, and push.
11. Report repository paths, branches, draft PR URLs, task URLs, code changes, checks, changed files, risks, skipped items, backlinks, and the suggested next command: `review-pr`.

## Final Checklist

- [ ] 1. Exact PM task set resolved, including comments, dependencies, and canonical URLs.
- [ ] 2. Affected repository set mapped; child-repo ambiguity resolved.
- [ ] 3. Current branch, remotes, base branch, and local status recorded for each repo.
- [ ] 4. Dedicated branch created or selected without losing unrelated local work.
- [ ] 5. Draft PR opened before implementation edits.
- [ ] 6. Every task linked in the PR body, merged expected outcomes included, and non-GitHub backlinks written and verified when required.
- [ ] 7. Repository explored with Serena and existing patterns reused.
- [ ] 8. Implementation kept focused on task scope and architecture.
- [ ] 9. Relevant existing checks run; caused failures fixed and unrelated failures reported.
- [ ] 10. Diff self-reviewed, staged narrowly, committed, pushed, and reported with PR URLs and next `review-pr` step.
