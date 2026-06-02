<p align="center">
  <img src=".github/assets/pbaw.png" alt="PBAW Logo" width="420" />
</p>

# Plan Based Agentic Workflow

Agent Skills for a plan-first development workflow:

- `feed-pm`: analyze a repository with Serena MCP, clarify remaining non-discoverable intent and tradeoffs, decompose requested work, and draft reviewable technical PM tasks.
- `implement-pm`: fetch approved PM tasks, create dedicated branch(es) from the currently selected branch(es), open draft PR(s) before implementation, write PR backlinks to non-GitHub PM tasks, then implement the requested work directly in the current repository checkout or affected child repositories while preserving staged and unstaged changes.
- `review-pr`: review implementation PRs from the current repo or child repos in a multi-repo workspace, run the full local CI suite, report out-of-scope CI failures in the PR comment, reconcile PR bodies with actual diffs, resolve stale already-addressed conversations, add concise score/details comments plus inline action comments, mark strong draft PRs ready for review, and propose or perform approval-gated merge finalization for production-ready PRs.
- `fix-pr`: infer PRs from the current branch or child repositories, analyze PR review feedback, use portable Decision Gates for ambiguous fixes, apply focused fixes in the owning checkout, push PR branches, and reply to or resolve handled review conversations.

PBAW is agent agnostic. The skills are designed to be portable across Codex, Claude Code, Antigravity CLI, and other Agent Skills compatible runners. They use built-in clarification/question tools when available, but do not depend on Plan Mode or proprietary question tools. Runner-specific metadata may be ignored by tools that do not support it; the workflow instructions remain the source of truth.

Using the host tool's Plan Mode is not recommended for PBAW skills. Plan Mode often intentionally limits agent capabilities, while PBAW relies on normal execution plus Decision Gates to keep the user in the architect role and the agent in the technician role.

PBAW is also a team workflow: the user is the product and architecture authority, and the agent is the technical operator. Treat the user as a qualified software engineer; clarification can and should cover technical architecture, contracts, validation, data, security, and delivery tradeoffs, not only product outcomes. When the agent needs human judgment, it uses a built-in clarification/question tool when available, or a normal-chat Decision Gate otherwise, and includes the roadmap it will execute.

Each skill follows the standard Agent Skills layout: `SKILL.md` contains the workflow and safety rules, while bundled resources live inside the same skill directory. Technical references are intentionally stored under `skills/<skill-name>/references/` so copying or symlinking one skill directory imports the references it needs.

## Prerequisites

Required:

- Git.
- A skill runner that can load `skills/<skill-name>/SKILL.md` directories, such as Codex, Claude Code, Antigravity CLI, or another Agent Skills compatible tool.
- Serena MCP configured. PBAW depends on Serena for reliable codebase analysis.
- `gh` authenticated for GitHub Issues and Pull Requests, or the matching MCP for the selected PM/Git hosting tool.

## Installation

Install the skills with `npx`; this is the recommended method:

```bash
npx skills add mvagnon/plan-based-agentic-workflow
```

Alternatively, fork or clone this repository and use it as a plugin or skill bundle. The expected layout is:

```text
plan-based-agentic-workflow/
|-- .claude-plugin/
|   `-- plugin.json
|-- README.md
`-- skills/
    |-- feed-pm/
    |   |-- SKILL.md
    |   |-- agents/
    |   `-- references/
    |       |-- codebase-analysis.md
    |       |-- pm-tools.md
    |       `-- task-specification.md
    |-- implement-pm/
    |   |-- SKILL.md
    |   |-- agents/
    |   `-- references/
    |       |-- implementation-git-github.md
    |       |-- pm-task-retrieval.md
    |       `-- verification.md
    |-- review-pr/
    |   |-- SKILL.md
    |   |-- agents/
    |   `-- references/
    |       |-- github-pr-review.md
    |       `-- merge-finalization.md
    `-- fix-pr/
        |-- SKILL.md
        |-- agents/
        `-- references/
            |-- github-feedback.md
            `-- remediation-git-github.md
```

For runners that scan a `skills/` directory, point them at the cloned repository or copy/symlink the four skill directories. For Claude Code, the `.claude-plugin/plugin.json` manifest enables plugin installation and namespaced skill invocation. The core workflow does not depend on the Claude plugin manifest.

## Arguments

The skills accept loose key-value arguments and natural language. Prefer key-value arguments for repeatability:

```text
pm_tool=<github|notion|other> project=<repo|project-url|database> tasks="<scope or task references>"
```

Defaults:

- `pm_tool`: `github`
- `project`: inferred from the current or target repository remote when possible
- `tasks`: required for `feed-pm` and `implement-pm` unless the user message already contains the full scope
- `pr`: optional for `review-pr` and `fix-pr`; infer it from the current branch when omitted
- `scope`: optional for `fix-pr`; defaults to all unresolved actionable feedback

Examples:

```text
feed-pm pm_tool=github project=owner/repo tasks="Split the new workspace invite flow into implementation-ready issues."
```

```text
implement-pm pm_tool=github project=owner/repo tasks="#123 #124 #125"
```

```text
review-pr
```

```text
fix-pr
```

## Workflow

### Planning With `feed-pm`

1. Infer or resolve the PM target.
2. Load relevant architecture skills and explore the codebase with Serena MCP.
3. Use built-in clarification/question tools when available, or a portable Decision Gate in normal chat otherwise, when remaining non-discoverable product, technical, or architecture decisions need architect input.
4. Reuse existing project architecture, validation, typing, and design-system patterns.
5. Decompose the requested work into similarly sized technical tasks.
6. Show a proposal table and full task bodies.
7. Create PM items after explicit approval, or directly after a Decision Gate response when the gate already presented the proposal table, full task bodies, and creation plan, and the user did not refuse, correct, or narrow it.

Task bodies are optimized for senior-engineer review: a short digest first, then implementation anchors, contracts, diagrams when useful, dependencies, verification guidance, and reviewer notes.

### Implementation With `implement-pm`

1. Resolve exact PM task references.
2. Resolve the target repository set: the current repo/monorepo, or affected child repos when the workspace contains multiple independent Git repositories.
3. Check each affected repository status and preserve staged, unstaged, and unrelated local changes.
4. Create or switch to one dedicated branch per affected repository from its currently selected branch.
5. Open each draft PR against that repository's source branch with every concerned task reference at the top of the description.
6. For GitHub Issues, link the PR to every concerned issue with GitHub-native linked-issue syntax, not plain text only.
7. For non-GitHub PM tasks, write every draft PR URL back to the dedicated PR field, or to a task comment/description fallback when no dedicated field exists.
8. Implement directly in the current repository checkout or affected child repositories.
9. Use Serena MCP plus targeted search to reuse existing code before adding new code.
10. Run relevant checks from the target repositories.
11. Report repository paths, branches, draft PRs, changed files, checks, and remaining risks.

### Review With `review-pr`

1. Resolve PRs from the current branch, PR URL, PR number, or matching child repositories in a multi-repo workspace.
2. Read the PR title, body, draft state, base/head refs, and diff.
3. Review changed code and directly affected paths for production readiness.
4. Run the full local CI suite for each affected repository, preferring repo-level tests, lint, typecheck, format-check, and build commands over scoped or affected commands.
5. Classify any full-suite failures as PR-caused, likely PR-caused, or out of scope. Score PR-caused failures normally and mention out-of-scope failures in the PR comment.
6. Compare the PR description with the actual diff.
7. Update the PR body when it drifted from the implementation:
   - add extra completed work that is present in the diff but missing from the description;
   - add unfinished promised work as struck-through items without deleting the original text.
8. Add one concise score/details PR comment per PR with the full-suite CI status and inline review comments for actionable fixes, not review details in the PR body.
9. If the final score is greater than `18/20`, mark a draft PR ready for review.
10. If fixes or clarifications are needed, recommend `fix-pr` from the PR branch or workspace containing the affected child repositories.
11. If the PR is production-ready but merge approval is missing, propose finalization: merge the PR, update non-GitHub PM tasks to `Done` when applicable, then checkout the PR base branch and pull.
12. If merge approval is present, re-check the PR state and full-suite CI status, merge with GitHub tooling, update non-GitHub PM tasks to `Done`, then checkout the PR base branch and pull.
13. Report score, verdict, findings, PR body updates, PR comments, finalization status, full-suite commands/results, and residual risks per PR.

### Fix Review Feedback With `fix-pr`

1. Resolve PRs from the current branch or matching child repositories by default; use a PR URL, PR number, branch name, repository, or child path when provided as an override.
2. Read the PR body, diff, checks, reviews, issue comments, review comments, unresolved review threads, and cited lines.
3. Build a feedback ledger that maps every actionable comment to a code fix, clarification, already-fixed status, obsolete status, or user decision.
4. Use built-in clarification/question tools when available, or a portable Decision Gate in normal chat otherwise, for ambiguous fixes that need architect input; the response approves the remediation roadmap unless the user refuses, corrects, or narrows it.
5. Checkout each PR head branch safely in its owning repository, preserving staged, unstaged, and unrelated local changes.
6. Apply focused corrections using existing project architecture, validation, typing, business logic, and design-system patterns.
7. Run relevant existing checks for the touched area.
8. Commit and push remediation changes to the owning PR head branch.
9. Reply to handled review threads or comments, resolve conversations when GitHub allows it, and add one top-level PR summary.

## Safety Rules

- `feed-pm` must not create, edit, label, or move PM items before explicit post-proposal approval or Decision Gate approval.
- `implement-pm` must create invocation branches from the currently selected branch in each affected repository and preserve staged, unstaged, and unrelated local changes in each checkout.
- `review-pr` is intentionally side-effectful: it may edit the PR body, run the full local CI suite, add review comments, resolve stale already-addressed conversations, mark a draft PR ready, and complete explicitly approved merge finalization only as described by its review workflow.
- `fix-pr` may commit and push focused remediation changes, reply to review feedback, and resolve handled review threads. It must not merge PRs, close issues, mark PM items done, or mark PRs ready unless explicitly requested.
- No skill should add dependencies, create logs, merge PRs, or update PM statuses unless explicitly requested. For `review-pr`, explicit merge/finalization approval may be given before the review or after a `PROD READY` result.
- Tests are not created by default. Existing tests may be updated only when directly affected or explicitly required by the task.

## Bundled References

References are bundled per skill, not at the repository root. This matches the standard skill resource model and keeps symlinked/imported skill directories self-contained.

- `skills/feed-pm/references/codebase-analysis.md`: Serena startup, evidence collection, and responsibility-map mechanics.
- `skills/feed-pm/references/task-specification.md`: proposal table, issue template, task sizing, and quality checklist.
- `skills/feed-pm/references/pm-tools.md`: GitHub, Notion, and other PM task creation mechanics.
- `skills/implement-pm/references/pm-task-retrieval.md`: exact PM task retrieval and dependency resolution.
- `skills/implement-pm/references/implementation-git-github.md`: branch, draft PR, linkage, staging, commit, and push mechanics.
- `skills/implement-pm/references/verification.md`: check-command discovery and verification reporting.
- `skills/review-pr/references/github-pr-review.md`: PR inspection, full local CI suite discovery/execution, review threads, body reconciliation, review submission, and ready-for-review mechanics.
- `skills/review-pr/references/merge-finalization.md`: final state checks including full-suite CI status, merge, PM completion, and post-merge checkout mechanics.
- `skills/fix-pr/references/github-feedback.md`: feedback collection and ledger template.
- `skills/fix-pr/references/remediation-git-github.md`: checkout, remediation commit/push, thread replies, resolution, and fallback comment mechanics.
