---
name: review-pr
description: Use when a pull request exists, was just created, or the user intends to create, open, submit, merge, or review a PR in the plan-based agentic workflow. It performs strict production-readiness review, reconciles the PR description with the actual diff, appends a review recap to the PR body, and marks high-scoring draft PRs ready for review.
---

# Review PR

## Purpose

Perform a strict production-readiness review of PR code. Judge only the changed code and directly affected code paths, compare the implementation with the PR description when one exists, reconcile the PR body with the actual diff, then return a score out of 20 with clear fixes.

## Trigger Discipline

Use this skill immediately when:

- A PR is created or already exists.
- The user asks to create, open, submit, publish, or merge a PR.
- The user asks for a strict review, security review, architecture review, prod-ready check, merge readiness check, or best-practices review.
- The user is continuing the plan-based agentic workflow after `implement-pm`.

If the user is creating a PR, review the code diff before the final PR response whenever possible. If the PR was already created, review the created PR diff.

## Input Contract

Read `$ARGUMENTS` or equivalent invocation input as a loose key-value contract:

- `PR`: optional. Accept a PR URL, PR number, or branch name. If omitted, infer the PR from the current branch with `gh pr view`.
- `Repository`: optional. Accept `owner/repo` or infer it from the current git remote.

Ask one concise question only when the PR cannot be resolved or multiple PRs match the provided input.

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

1. Identify the diff source: `gh pr diff`, `gh pr view`, or local `git diff` when no PR exists yet.
2. When a PR exists, read its title, body, draft state, URL, base, and head, for example with `gh pr view --json number,title,body,url,isDraft,baseRefName,headRefName`.
3. Read project-specific instructions such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, architecture docs, and relevant `README.md` files.
4. Inspect changed files plus nearby modules, tests, schemas, routes, services, migrations, and security utilities needed to understand impact.
5. Prefer existing project conventions over generic preferences.
6. If architecture must be inferred from code, say it is an inference.

Do not invent architecture rules. If the repo has no explicit architecture documentation, judge against the actual boundaries and patterns visible in the codebase.

## Review Standard

Review as if the code will be deployed to production immediately after merge.

Check at least:

- PR description alignment when applicable: stated goals, acceptance criteria, exclusions, validation plan, and whether the diff implements the promised scope without adding risky unannounced behavior.
- Architecture: boundaries, layering, feature ownership, data flow, public APIs, dependency direction, reuse of existing patterns.
- Correctness: business logic, edge cases, regressions, error paths, async/race behavior, idempotency, migrations, backwards compatibility.
- Security: authentication, authorization, multi-tenancy isolation, input validation, injection, XSS, CSRF, SSRF, path traversal, file uploads, secrets, PII, logging, webhook verification, payment integrity, rate limits.
- Production readiness: observability, explicit errors, retries/timeouts where appropriate, transactional consistency, resource cleanup, N+1 queries, performance cliffs, rollout and rollback safety.
- Tests and verification: behavior coverage for changed logic, meaningful assertions, migration tests, security-sensitive tests, relevant static checks.
- Maintainability: clear names, type safety, dead code, duplication, unnecessary abstractions, hidden side effects, consistency with local style.
- Frontend impact when applicable: user experience, loading/error/empty/disabled states, accessibility, responsive behavior, state ownership, no fragile UI assumptions.

For frontend changes, explicitly verify and note the user experience:

- Responsiveness across mobile, tablet, and desktop breakpoints affected by the diff.
- Loading states that match the interaction scale:
  - Buttons and small components use spinners.
  - Medium and large components use skeletons that preserve layout stability.
  - Whole pages use a top loading bar, mostly for SSR/page transitions, when the project has that pattern.
- Async actions disable unsafe duplicate submissions and keep visible feedback.
- Error, empty, disabled, hover, focus, and active states are handled intentionally.
- Text, controls, dialogs, tables, and cards do not overflow, overlap, jump, or become unusable on narrow screens.
- Accessibility basics are preserved: keyboard access, focus visibility, labels, semantic elements, contrast, and screen-reader-friendly loading/error feedback.

## PR Body Reconciliation

When a PR exists, update its description after inspecting the diff and before finishing. Preserve the author's original content; only replace sections previously generated by this skill.

Use a generated block near the end of the PR body, before the review recap:

```markdown
<!-- review-pr:reconciliation:start -->
## Review PR Reconciliation

### Additional Completed Work
- <behavior or file area present in the diff but missing from the PR description>

### Not Completed
- ~~<promised task, checklist item, acceptance criterion, or scope item not implemented by the diff>~~ - <short factual reason>
<!-- review-pr:reconciliation:end -->
```

Rules:

- If the current PR body already matches the diff, either omit the reconciliation block or replace an old block with `No description drift detected.`
- If extra work was done beyond the existing PR description, add it under `Additional Completed Work`.
- If promised tasks, checklist items, or acceptance criteria were not done, mention them under `Not Completed` and strike them through with Markdown `~~...~~`. Do not delete or rewrite the original task text elsewhere in the PR body.
- Keep the reconciliation factual. Do not invent intent, and do not use it to hide risk.
- Use `gh pr edit <number-or-url> --body-file <file>` or an equivalent official PR tool to write the updated body.

After the review is complete, append or replace a generated recap block at the very end of the PR body:

```markdown
<!-- review-pr:recap:start -->
## Review PR Recap

- Score: <N>/20
- Verdict: <PROD READY | FIX BEFORE MERGE | DO NOT MERGE>
- Findings: <short summary, or `No blocking or major findings found.`>
- Checks reviewed: <diff, commands, CI, or `Not run locally.`>
<!-- review-pr:recap:end -->
```

If the final score is strictly greater than `18/20` and the PR is still a draft, mark it ready for review with `gh pr ready <number-or-url>` or the equivalent official tool. Do not mark PRs ready when the score is `18/20` or lower, when the score could not be produced, or when no PR exists.

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
- Any untested high-risk behavior change in a repo with a test setup: maximum `15/20`.
- If the diff cannot be inspected, do not fabricate a score. State what is missing and how to obtain it.

## Scoring Rubric

Start from 20 and subtract for concrete code risks only:

- Architecture and boundaries: 4 points.
- Correctness and regression risk: 4 points.
- Security and privacy: 4 points.
- Production readiness and reliability: 3 points.
- Tests and verification: 3 points.
- Maintainability and best practices: 2 points.

For frontend PRs, include user experience issues in the most relevant scored category. Responsiveness, broken layout, missing loading states, inaccessible controls, or unusable interaction states are concrete code risks, not polish, when they affect real user flows.

Score bands:

- `18-20`: production-ready. Only minor or nit-level issues.
- `15-17`: close, but fixes are recommended before merge.
- `12-14`: not production-ready without targeted fixes.
- `8-11`: high-risk PR. Merge should be blocked.
- `0-7`: severe production or security risk.

Do not award points for PR description quality. Do not remove points for PR size. When the implementation and PR description disagree, score the resulting code risk in the most relevant category, usually correctness, tests and verification, or maintainability.

## Output Format

Return the review in this exact order:

```markdown
## Review PR

Score: <N>/20
Verdict: <PROD READY | FIX BEFORE MERGE | DO NOT MERGE>

### Findings

- <severity> - <file:line>
  Impact: <why this matters in production>
  Fix: <specific, actionable change>

### PR Description Alignment

- <if a PR description exists: summarize whether the implementation matches stated goals, acceptance criteria, validation plan, and scope; if no PR description exists, write `No PR description available.`>

### PR Body Updates

- <summarize reconciliation block changes, review recap append/update, and whether the PR was marked ready for review; for no PR, write `No PR body updates applied.`>

### Frontend UX Notes

- <required for frontend PRs: responsiveness, loading states, interaction states, accessibility, and layout stability summary; for non-frontend PRs, write `Not applicable.`>

### Score Breakdown

- Architecture and boundaries: <x>/4
- Correctness and regression risk: <x>/4
- Security and privacy: <x>/4
- Production readiness and reliability: <x>/3
- Tests and verification: <x>/3
- Maintainability and best practices: <x>/2

### Improvement Plan

1. <highest leverage fix>
2. <next fix>
3. <next fix>

### Non-Scored Notes

- <optional notes about PR metadata, missing context, or commands not run>
```

If there are no findings, write `No blocking or major findings found.` under `Findings`, then still provide the score breakdown and any residual risk.

Keep findings specific and code-grounded. Prefer file and line references. Avoid vague advice such as "improve quality" unless tied to a concrete code path.
