---
name: review-pr
description: Use when one or more pull requests exist and the user intends to polish or merge PRs. It resolves PRs from the current repository or child repositories in a multi-repo workspace, commits and pushes every staged, unstaged, or untracked local change in the affected repo before proceeding, performs strict production-readiness review with especially strict architecture-boundary checks, reconciles PR descriptions with actual diffs, adds concise score/details comments, adds inline comments for actionable fixes, marks high-scoring draft PRs ready for review, and proposes or performs approval-gated merge finalization for production-ready PRs.
---

# Review PR

## Purpose

Perform a strict production-readiness review of PR code. Judge only the changed code and directly affected code paths, compare the implementation with the PR description when one exists, reconcile the PR body with the actual diff, then return a score out of 20 with clear fixes.

Use `fix-pr` as the follow-up skill for implementing fixes, clarifying review comments, and resolving PR conversations. For production-ready PRs, propose merge finalization and perform it only after explicit user approval.

This skill is intentionally side-effectful for real PR reviews: it may update PR bodies, submit one PR review with inline comments per PR, resolve stale conversations that are already addressed by the current diff, mark strong draft PRs ready according to the rules below, and complete explicitly approved production-ready merge finalization.

Be especially strict about architecture in the diff. Changed code must respect existing boundaries, dependency direction, ownership model, naming, shared abstractions, and framework-specific conventions. Treat architecture drift as a production-readiness risk, not a style preference.

## Input Contract

Read the arguments below or equivalent invocation input as a loose key-value contract:

`$ARGUMENTS`

Infer:

- `PR`: optional. Accept a PR URL, PR number, or branch name. If omitted, infer the PR from the current branch.
- `Repository`: optional. Accept a URL, repository identifier, or child repository path. Infer it from repository context when safe.

Ask one concise question only when the PR cannot be resolved or multiple unrelated PRs match the provided input. If the current workspace contains multiple child repositories and each has a PR associated with its current branch or the provided branch, treat those PRs as one multi-repo review set instead of ignoring child repos.

## Required References

Load these bundled references as needed:

- `references/github-pr-review.md`: concrete PR metadata, diff, checks, prior comments, review-thread, PR-body reconciliation, review submission, and ready-for-review mechanics.
- `references/merge-finalization.md`: final state checks, merge commands, non-GitHub PM completion rules, and post-merge checkout mechanics.

References are intentionally technical. Keep the skill body focused on review policy and consult the references for commands, payloads, and tool-specific details.

## Non-Scored Scope

Never lower the score because of:

- PR size.
- PR title, body, description, checklist, screenshots, labels, branch name, or metadata quality.
- Missing context in the PR description.
- Commit history shape, unless the committed code itself creates a production risk.

Only score the code changes and their direct impact. A large PR can require more careful inspection, but size itself is not a defect.

If a PR description exists, use it as the stated implementation contract. Do not score the description's writing quality, completeness, or formatting. Do score concrete code risks when the diff contradicts the description, fails stated acceptance criteria, omits promised behavior, or includes meaningful unannounced behavior that changes production risk.

## Required Context

Before scoring:

1. Resolve the repository set. In a normal repository or monorepo checkout, use the current Git repository root. In a workspace containing multiple independent child Git repositories, inspect each child repo and resolve PRs there too.
2. Check local repository status in every affected repository before reading or reviewing the diff.
3. If there are any local changes in an affected repository, including staged, unstaged, or untracked non-ignored files, commit and push all of them in that repository before continuing. Do not proceed to diff inspection, PR description reconciliation, scoring, comments, readiness promotion, merge, or PM follow-up until each affected working tree is clean and pushed.
4. If commit or push fails because of conflicts, missing identity, missing upstream, rejected push, authentication, failing hooks, branch protection, or another blocker, stop the review flow and report the blocker with the exact failed operation and repository path.
5. Identify the diff source from each PR when one exists, or from a committed branch comparison when no PR exists yet.
6. When a PR exists, read title, body, draft state, URL, base, and head.
7. Read unresolved review threads, issue comments, and prior review comments before adding a new review. Resolve only prior concerns already addressed by the current diff or fully explained by existing discussion.
8. Use Serena MCP for changed-file and nearby-symbol exploration in the repository being reviewed. If Serena is unavailable, stop and report the missing required dependency instead of scoring the PR from local search alone.
9. Read project-specific instructions such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, architecture docs, and relevant package docs for each affected repository.
10. Identify the actual architecture style or local convention used by the touched area before judging the diff.
11. Discover and load any available architecture skills that match the actual touched architecture before judging architecture.
12. Inspect changed files plus nearby modules, tests, schemas, routes, services, migrations, and security utilities needed to understand impact.
13. Prefer existing project conventions over generic preferences.
14. If architecture must be inferred from code, say it is an inference and name the evidence used.

Use `references/github-pr-review.md` for concrete metadata, diff, checks, prior discussion, review thread, and PR update operations.

## Architecture Review Standard

Do not invent architecture rules, and do not force layered expectations onto a repository that uses a different architecture. If the repo has no explicit architecture documentation, judge against the actual boundaries and patterns visible in the codebase, and use relevant architecture skills only to interpret those boundaries more rigorously.

Explicitly verify:

- Architecture identification: name the architecture style or local convention that governs the changed area before assigning architecture points.
- Ownership boundaries: the project's actual owners for routes/controllers, pages/views, components, hooks, state, services/use cases, models/entities, schemas/DTOs, repositories/adapters, persistence, integrations, shared packages, and design-system primitives.
- Dependency direction: enforce dependency rules implied by the actual architecture.
- Business-rule placement: validations, permission checks, transformations, formatting, query keys, DTO mapping, and workflow rules stay in their existing owners.
- Shared abstraction reuse: existing components, hooks, repositories, services, schemas, utilities, tokens, and variants are reused or extended instead of recreated.
- Package boundaries: shared packages do not import app-local code; app features do not bypass shared package/public exports; cross-package changes remain compatible with all consumers.
- Framework conventions: data fetching, routing, mutations, loading/error states, and server actions follow the project's established patterns.
- File/module shape: new files belong in the owning area, module, package, or framework location, use local naming conventions, and avoid generic abstractions whose only consumer is the current diff.

## Review Standard

Review as if the code will be deployed to production immediately after merge.

Check at least:

- PR description alignment when applicable;
- architecture, boundaries, ownership model, feature/module ownership, data flow, public APIs, dependency direction, and reuse of existing patterns;
- correctness, edge cases, regressions, error paths, async/race behavior, idempotency, migrations, and backwards compatibility;
- security, authentication, authorization, multi-tenancy isolation, input validation, injection, XSS, CSRF, SSRF, path traversal, file uploads, secrets, PII, logging, webhook verification, payment integrity, and rate limits;
- production readiness, observability, explicit errors, retries/timeouts where appropriate, transactional consistency, resource cleanup, obvious query cliffs, rollout, and rollback safety;
- tests and verification for changed behavior;
- maintainability, names, type safety, dead code, duplication, unnecessary abstractions, hidden side effects, and consistency with local style;
- frontend UX when applicable: responsive behavior, loading/error/empty/disabled states, accessibility, state ownership, and layout stability.

For architecture-heavy diffs, be skeptical by default. Do not award near-full architecture points unless you can name the governing architecture or local convention and verify that the changed files belong to the right owners.

For frontend changes, explicitly verify and note responsiveness, loading states, duplicate-submit protection, error/empty/disabled/hover/focus/active states, text/control overflow, keyboard access, focus visibility, labels, semantic elements, contrast, and screen-reader-friendly feedback.

## PR Updates

When a PR exists, reconcile its description after inspecting the diff and before finishing. Preserve author content; only replace sections previously generated by this skill.

Use `references/github-pr-review.md` for the exact reconciliation block and PR body update mechanics.

Before posting new review comments:

- resolve only conversations that are already addressed by the current diff or fully explained by existing discussion;
- do not resolve conversations that still need code changes, reviewer confirmation, or user decisions;
- avoid posting duplicate inline comments for a concern already present in an unresolved thread.

After each PR review is complete, submit exactly one PR review comment with the score and a few high-signal details. Add inline PR review comments for actionable findings that can be anchored to changed lines.

Inline comment rules:

- Add inline comments for `Blocker` and `Major` findings whenever a changed line is available.
- Add inline comments for `Minor` findings only when the action is concrete and localized.
- Do not add inline comments for nits unless the user explicitly requested nit-level review comments.
- Keep each inline comment short: state the required action and why it matters.
- If a finding cannot be anchored to a changed line, include it in the top-level PR comment instead of forcing a line comment.
- Avoid duplicate inline comments for the same finding in the same review run.

If the final score is strictly greater than `18/20` and the PR is still a draft, mark it ready for review. Do not mark PRs ready when the score is `18/20` or lower, when the score could not be produced, or when no PR exists.

Do not implement fixes from this skill. When the review finds actionable feedback, recommend `fix-pr` as the follow-up from the PR branch or workspace containing the reviewed child repositories.

## Approved Merge Finalization

Merge finalization is allowed only when all of these are true:

- the verdict is `PROD READY`;
- a PR exists and was inspected successfully;
- the user explicitly approved merge/finalization in the current request or after seeing the review result;
- the final pre-merge state still has no blockers.

If the PR is `PROD READY` but approval is missing, do not merge. Propose approval-gated finalization in the output.

When approval is present, use `references/merge-finalization.md` for final state checks, GitHub Issue handling, non-GitHub PM completion, merge, and post-merge checkout mechanics.

For a multi-repo review set, finalize each PR independently only after it is `PROD READY` and explicitly approved. Do not average scores across repositories; one blocked PR must not hide behind a production-ready PR in another child repo.

## Severity Rules

Use these severities:

- `Blocker`: must not merge. Includes exploitable security issues, broken authz, data loss/corruption, production outage risk, unsafe migrations, severe regressions, or architecture violations that make the system hard to operate safely.
- `Major`: should fix before merge. Includes likely bugs, missing validation, weak tests around risky behavior, maintainability issues that create near-term risk, or meaningful divergence from architecture.
- `Minor`: worth fixing, but not merge-blocking.
- `Nit`: optional polish. Do not let nits dominate the review.

Score caps:

- Any credible exploitable security issue: maximum `8/20`.
- Any data loss/corruption or production outage risk: maximum `10/20`.
- Any missing server-side authorization check on protected data/actions: maximum `8/20`.
- Any unsafe migration that can break existing production data: maximum `10/20`.
- Any clear architecture violation that puts business logic, security, persistence, UI, or integration ownership in the wrong owner area and is likely to spread: maximum `12/20`.
- Any cross-package or dependency-direction violation that can break consumers or make future changes unsafe: maximum `13/20`.
- Any architecture-sensitive diff where the governing architecture cannot be identified from docs, code, or a stated inference: maximum `16/20`.
- Any failure to consult an available, directly relevant architecture skill before scoring an architecture-sensitive diff: maximum `15/20`, unless the architecture can be fully validated from explicit project instructions and the omission is corrected before finalizing.
- Any architecture score of `3/6` or lower: maximum `17/20` and the verdict cannot be `PROD READY`.
- Any architecture score of `2/6` or lower: maximum `12/20`.
- Any untested high-risk behavior change in a repo with a test setup: maximum `15/20`.
- If the diff cannot be inspected, do not fabricate a score. State what is missing and how to obtain it.

## Scoring Rubric

Start from 20 and subtract for concrete code risks only. Apply architecture deductions rigorously:

- Architecture and boundaries: 6 points.
- Correctness and regression risk: 4 points.
- Security and privacy: 4 points.
- Production readiness and reliability: 2 points.
- Tests and verification: 2 points.
- Maintainability and best practices: 2 points.

For frontend PRs, include user experience issues in the most relevant scored category. Responsiveness, broken layout, missing loading states, inaccessible controls, or unusable interaction states are concrete code risks, not polish, when they affect real user flows.

Architecture and boundaries scoring guidance:

- `6/6`: The diff clearly follows the actual architecture used by the touched area, uses the correct owners, reuses local abstractions, and preserves package/dependency direction.
- `5/6`: One small, localized ownership or reuse weakness that is unlikely to spread and has an obvious fix.
- `4/6`: Minor architecture drift or a missed existing abstraction, but the main ownership model and dependency direction remain intact.
- `3/6`: Meaningful architecture drift, duplicated ownership, misplaced rules, or bypassed feature/shared abstractions. Treat this as a fix-before-merge risk.
- `2/6`: Major boundary violation across owners or packages, or a diff that makes future work likely to duplicate business logic or bypass validation/security paths.
- `1/6`: Severe architecture break that still has a narrow blast radius, such as a single high-risk owner inversion or app/shared dependency violation.
- `0/6`: Severe architecture break that makes the system hard to operate safely, such as UI importing persistence-only code, core/shared contracts importing presentation/framework/runtime details, bypassed server authz, unsafe persistence ownership, or shared packages depending on app-local modules.

Score bands:

- `18-20`: production-ready. Only minor or nit-level issues.
- `15-17`: close, but fixes are recommended before merge.
- `12-14`: not production-ready without targeted fixes.
- `8-11`: high-risk PR. Merge should be blocked.
- `0-7`: severe production or security risk.

Do not award points for PR description quality. Do not remove points for PR size. When implementation and PR description disagree, score the resulting code risk in the most relevant category.

## Output Format

Return the review in this exact order. When multiple child-repository PRs are in scope, repeat this full block once per PR and include the repository path in each block; do not combine scores.

```markdown
## Review PR

Repository: <path>
PR: <url or "none">
Score: <N>/20
Verdict: <PROD READY | FIX BEFORE MERGE | DO NOT MERGE>

### Findings

- <severity> - <file:line>
  Impact: <why this matters in production>
  Fix: <specific, actionable change>

### PR Description Alignment

- <if a PR description exists: summarize whether the implementation matches stated goals, acceptance criteria, validation plan, and scope; if no PR description exists, write `No PR description available.`>

### PR Updates

- <summarize PR description reconciliation changes, top-level score/details comment creation, inline review comments added, stale thread resolution, and whether the PR was marked ready; for no PR, write `No PR body updates or comments applied.`>

### Finalization

- <merge/finalization result, approval needed, blocker, or `Not run because the PR is not production-ready.`>

### Frontend UX Notes

- <required for frontend PRs; for non-frontend PRs, write `Not applicable.`>

### Score Breakdown

- Architecture and boundaries: <x>/6
- Correctness and regression risk: <x>/4
- Security and privacy: <x>/4
- Production readiness and reliability: <x>/2
- Tests and verification: <x>/2
- Maintainability and best practices: <x>/2

### Improvement Plan

1. <highest leverage fix>
2. <next fix>
3. <next fix>

### Non-Scored Notes

- <optional notes about PR metadata, missing context, commands not run, architecture style identified, and relevant architecture skills loaded>

### Next Step

- <exactly one next step>
```

If there are no findings, write `No blocking or major findings found.` under `Findings`, then still provide the score breakdown and residual risk.

Keep findings specific and code-grounded. Prefer file and line references. Avoid vague advice unless tied to a concrete code path.
