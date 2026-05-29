# Plan Based Agentic Workflow

Agent Skills for a plan-first development workflow:

- `feed-pm`: analyze a repository, decompose requested work, and draft reviewable technical PM tasks.
- `implement-pm`: fetch approved PM tasks, create a git worktree under `~/Developer/worktrees`, and implement the requested work there.

The skills are designed to be portable across Codex, Claude Code, Antigravity CLI, and other Agent Skills compatible runners. Runner-specific metadata may be ignored by tools that do not support it; the workflow instructions remain the source of truth.

## Prerequisites

Required:

- Git with `git worktree` support.
- A skill runner that can load `skills/<skill-name>/SKILL.md` directories, such as Codex, Claude Code, Antigravity CLI, or another Agent Skills compatible tool.
- Serena MCP configured for best results when exploring codebases.
- `gh` authenticated for GitHub Issues, or the matching MCP for the selected PM tool.

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
    `-- implement-pm/
        `-- SKILL.md
```

For runners that scan a `skills/` directory, point them at this repository or copy/symlink the two skill directories. For Claude Code, the `.claude-plugin/plugin.json` manifest enables plugin installation and namespaced skill invocation. The core workflow does not depend on the Claude plugin manifest.

## Arguments

Both skills accept loose key-value arguments and natural language. Prefer key-value arguments for repeatability:

```text
pm_tool=<github|notion|other> project=<repo|project-url|database> tasks="<scope or task references>"
```

Defaults:

- `pm_tool`: `github`
- `project`: inferred from the current repository git remote when possible
- `tasks`: required unless the user message already contains the full scope

Examples:

```text
feed-pm pm_tool=github project=owner/repo tasks="Split the new workspace invite flow into implementation-ready issues."
```

```text
implement-pm pm_tool=github project=owner/repo tasks="#123 #124 #125"
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
2. Create or reuse a matching worktree under `~/Developer/worktrees`.
3. Implement inside that worktree only.
4. Use Serena MCP or targeted search to reuse existing code before adding new code.
5. Run relevant checks from the target repository.
6. Report branch, worktree path, changed files, checks, and remaining risks.

## Safety Rules

- `feed-pm` must not create, edit, label, or move PM items before explicit approval.
- `implement-pm` must not modify the user's current worktree.
- Neither skill should add dependencies, push branches, open PRs, create logs, or update PM statuses unless explicitly requested.
- Tests are not created by default. Existing tests may be updated only when directly affected or explicitly required by the task.

## Bundled References

- `references/serena-codebase-analysis.md`: semantic exploration protocol and fallbacks.
- `references/task-specification.md`: issue body template and task decomposition rubric.
- `references/pm-tools.md`: GitHub, Notion, and other PM tool conventions.
- `references/implementation-protocol.md`: worktree, implementation, verification, and reporting protocol.
