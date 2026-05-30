# Plan Based Agentic Workflow

Agent Skills for a plan-first development workflow:

- `feed-pm`: analyze a repository, decompose requested work, and draft reviewable technical PM tasks.
- `implement-pm`: fetch approved PM tasks, create one dedicated branch from the currently selected branch, open a draft PR per invocation, then implement the requested work directly in the current repository checkout while preserving staged and unstaged changes.
- `review-pr`: review an implementation PR, reconcile the PR body with the actual diff, append a review recap, and mark strong draft PRs ready for review.

The skills are designed to be portable across Codex, Claude Code, Antigravity CLI, and other Agent Skills compatible runners. Runner-specific metadata may be ignored by tools that do not support it; the workflow instructions remain the source of truth.

## Prerequisites

Required:

- Git.
- A skill runner that can load `skills/<skill-name>/SKILL.md` directories, such as Codex, Claude Code, Antigravity CLI, or another Agent Skills compatible tool.
- Serena MCP configured for best results when exploring codebases.
- `gh` authenticated for GitHub Issues and Pull Requests, or the matching MCP for the selected PM/Git hosting tool.

## Installation

Use this repository as a plugin or skill bundle. The expected layout is:

```text
plan-based-agentic-workflow/
|-- .claude-plugin/
|   `-- plugin.json
|-- README.md
|-- references/
|   |-- implementation-protocol.md
|   |-- pm-tools.md
|   |-- serena-codebase-analysis.md
|   `-- task-specification.md
`-- skills/
    |-- feed-pm/
    |   `-- SKILL.md
    |-- implement-pm/
    |   `-- SKILL.md
    `-- review-pr/
        `-- SKILL.md
```

For runners that scan a `skills/` directory, point them at this repository or copy/symlink the three skill directories. For Claude Code, the `.claude-plugin/plugin.json` manifest enables plugin installation and namespaced skill invocation. The core workflow does not depend on the Claude plugin manifest.

## Arguments

The skills accept loose key-value arguments and natural language. Prefer key-value arguments for repeatability:

```text
pm_tool=<github|notion|other> project=<repo|project-url|database> tasks="<scope or task references>"
```

Defaults:

- `pm_tool`: `github`
- `project`: inferred from the current repository git remote when possible
- `tasks`: required for `feed-pm` and `implement-pm` unless the user message already contains the full scope
- `pr`: optional for `review-pr`; infer it from the current branch when omitted

Examples:

```text
feed-pm pm_tool=github project=owner/repo tasks="Split the new workspace invite flow into implementation-ready issues."
```

```text
implement-pm pm_tool=github project=owner/repo tasks="#123 #124 #125"
```

```text
review-pr pr="https://github.com/owner/repo/pull/456"
```

## Workflow

### Planning With `feed-pm`

1. Infer or resolve the PM target.
2. Explore the codebase, preferring Serena MCP when available.
3. Reuse existing project architecture, validation, typing, and design-system patterns.
4. Decompose the requested work into similarly sized technical tasks.
5. Show a proposal table and full task bodies.
6. Create PM items only after explicit human approval.

Task bodies are optimized for senior-engineer review: a short digest first, then implementation anchors, contracts, diagrams when useful, dependencies, verification guidance, and reviewer notes.

### Implementation With `implement-pm`

1. Resolve exact PM task references.
2. Check the current repository status and preserve staged, unstaged, and unrelated local changes.
3. Create or switch to one dedicated branch from the currently selected branch for the invocation.
4. Open a draft PR against that source branch with the concerned task reference at the top of the description.
5. Implement directly in the current repository checkout.
6. Use Serena MCP or targeted search to reuse existing code before adding new code.
7. Run relevant checks from the target repository.
8. Report repository path, branch, draft PR, changed files, checks, and remaining risks.

### Review With `review-pr`

1. Resolve the PR from the current branch, PR URL, or PR number.
2. Read the PR title, body, draft state, base/head refs, and diff.
3. Review changed code and directly affected paths for production readiness.
4. Compare the PR description with the actual diff.
5. Update the PR body when it drifted from the implementation:
   - add extra completed work that is present in the diff but missing from the description;
   - add unfinished promised work as struck-through items without deleting the original text.
6. Append or replace a review recap at the end of the PR body.
7. If the final score is greater than `18/20`, mark a draft PR ready for review.
8. Report score, verdict, findings, PR body updates, checks reviewed, and residual risks.

## Safety Rules

- `feed-pm` must not create, edit, label, or move PM items before explicit approval.
- `implement-pm` must create its invocation branch from the currently selected branch and preserve staged, unstaged, and unrelated local changes in the current checkout.
- `review-pr` may edit the PR body and mark a draft PR ready only as described by its review workflow.
- No skill should add dependencies, create logs, merge PRs, or update PM statuses unless explicitly requested.
- Tests are not created by default. Existing tests may be updated only when directly affected or explicitly required by the task.

## Bundled References

- `references/serena-codebase-analysis.md`: semantic exploration protocol and fallbacks.
- `references/task-specification.md`: issue body template and task decomposition rubric.
- `references/pm-tools.md`: GitHub, Notion, and other PM tool conventions.
- `references/implementation-protocol.md`: current-checkout implementation, verification, and reporting protocol.
