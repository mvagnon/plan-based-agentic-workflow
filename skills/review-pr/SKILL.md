---
name: review-pr
description: Use when a pull request exists, was just created, or the user intends to create, open, submit, merge, or review a PR in the plan-based agentic workflow. It first commits and pushes every staged, unstaged, or untracked local change before proceeding, then performs strict production-readiness review with especially strict architecture-boundary checks, reconciles the PR description with the actual diff, adds a concise score/details PR comment, adds inline review comments for actionable fixes, marks high-scoring draft PRs ready for review, and asks for explicit approval before merging the PR and closing associated issues or moving tickets to done.
---

# Review PR

## Purpose

Perform a strict production-readiness review of PR code. Judge only the changed code and directly affected code paths, compare the implementation with the PR description when one exists, reconcile the PR body with the actual diff, then return a score out of 20 with clear fixes.

Be especially strict about architecture in the diff. Changed code must respect existing boundaries, dependency direction, ownership model, naming, shared abstractions, and framework-specific conventions. Treat architecture drift as a production-readiness risk, not a style preference.

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

1. Check `git status --short` in the PR repository before reading or reviewing the diff.
2. If there are any local changes, including staged, unstaged, or untracked non-ignored files, commit and push all of them before continuing. Stage every local change with the repository's normal Git workflow, create a concise commit that describes the pending work, and push the current branch to its upstream or the PR head remote. Do not proceed to diff inspection, PR description reconciliation, scoring, comments, readiness promotion, merge, or PM follow-up until the working tree is clean and the commit has been pushed.
3. If commit or push fails because of conflicts, missing identity, missing upstream, rejected push, authentication, failing pre-commit hooks, branch protection, or any other blocker, stop the review flow and report the blocker with the exact command that failed. Do not silently skip local changes or review an unpushed worktree.
4. Identify the diff source: `gh pr diff`, `gh pr view`, or a committed branch comparison such as `git diff <base>...HEAD` when no PR exists yet.
5. When a PR exists, read its title, body, draft state, URL, base, and head, for example with `gh pr view --json number,title,body,url,isDraft,baseRefName,headRefName`.
6. Read project-specific instructions such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, architecture docs, and relevant `README.md` files.
7. Identify the actual architecture style or styles used by the touched area before judging the diff. It may be hexagonal, clean architecture, MVC, feature-sliced, vertical slice, modular monolith, framework-native routing, package-based component architecture, a custom project convention, or a mix. Do not assume `domain`/`application`/`infrastructure` layers unless the repository actually uses them.
8. Discover and load any available architecture skills that match the actual touched architecture before judging architecture. Examples include hexagonal/clean architecture skills only when those layers exist, React/frontend architecture skills for feature and hook boundaries, monorepo/Turborepo skills for package-boundary changes, design-system skills for UI package/theme/component-library changes, framework skills for routing/data-fetching layers, and domain-specific integration skills such as payments when touched. If a relevant architecture skill exists, consult it before scoring. If discovery is unavailable or no relevant skill exists, say so briefly and proceed from repo evidence.
9. Inspect changed files plus nearby modules, tests, schemas, routes, services, migrations, and security utilities needed to understand impact.
10. Prefer existing project conventions over generic preferences.
11. If architecture must be inferred from code, say it is an inference and name the evidence used.

Do not invent architecture rules, and do not force hexagonal or layered expectations onto a repo that uses a different architecture. If the repo has no explicit architecture documentation, judge against the actual boundaries and patterns visible in the codebase, and use relevant architecture skills only to interpret those boundaries more rigorously.

When reviewing architecture, explicitly verify the diff against:

- Architecture identification: name the architecture style or local convention that governs the changed area before assigning architecture points.
- Ownership boundaries: the project’s actual owners for routes/controllers, pages/views, components, hooks, state, services/use cases, models/entities, schemas/DTOs, repositories/adapters, persistence, integrations, shared packages, and design-system primitives. Use only the owners that exist in this repo.
- Dependency direction: enforce the dependency rules implied by the actual architecture. For example, core/shared contracts must not import app-local UI, runtime adapters, framework request objects, or persistence details unless the repo already establishes that pattern; feature, route, MVC, or framework-native structures must not bypass their established owners.
- Business-rule placement: validations, permission checks, transformations, formatting, query keys, DTO mapping, and workflow rules stay in their existing owners and are not duplicated into UI, route, controller, or other orchestration code unless that is the established owner.
- Shared abstraction reuse: existing components, hooks, repositories, services, schemas, utilities, tokens, and variants are reused or extended instead of recreated.
- Package boundaries: shared packages do not import app-local code; app features do not bypass shared package/public exports; cross-package changes remain compatible with all consumers.
- Framework conventions: data fetching, routing, mutations, loading/error states, and server actions follow the project’s established patterns.
- File/module shape: new files belong in the owning area, module, package, or framework location, use local naming conventions, and avoid generic abstractions whose only consumer is the current diff.

## Review Standard

Review as if the code will be deployed to production immediately after merge.

Check at least:

- PR description alignment when applicable: stated goals, acceptance criteria, exclusions, validation plan, and whether the diff implements the promised scope without adding risky unannounced behavior.
- Architecture: boundaries, ownership model, feature/module ownership, data flow, public APIs, dependency direction, reuse of existing patterns. This is a hard review axis: a diff that violates the repo’s architecture should lose meaningful score even when behavior appears to work.
- Correctness: business logic, edge cases, regressions, error paths, async/race behavior, idempotency, migrations, backwards compatibility.
- Security: authentication, authorization, multi-tenancy isolation, input validation, injection, XSS, CSRF, SSRF, path traversal, file uploads, secrets, PII, logging, webhook verification, payment integrity, rate limits.
- Production readiness: observability, explicit errors, retries/timeouts where appropriate, transactional consistency, resource cleanup, N+1 queries, performance cliffs, rollout and rollback safety.
- Tests and verification: behavior coverage for changed logic, meaningful assertions, migration tests, security-sensitive tests, relevant static checks.
- Maintainability: clear names, type safety, dead code, duplication, unnecessary abstractions, hidden side effects, consistency with local style.
- Frontend impact when applicable: user experience, loading/error/empty/disabled states, accessibility, responsive behavior, state ownership, no fragile UI assumptions.

For architecture-heavy diffs, be skeptical by default. Do not award near-full architecture points unless you can name the governing architecture or local convention and verify that the changed files belong to the right owners. A change is not production-ready if it works by bypassing the established architecture, duplicating ownership, weakening package boundaries, or placing future changes in the wrong place. Prefer a lower score with clear refactoring instructions over accepting architecture drift as harmless.

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

## PR Description Reconciliation And Review Comments

When a PR exists, update its description after inspecting the diff and before finishing. Preserve the author's original content; only replace sections previously generated by this skill.

Use a generated reconciliation block near the end of the PR body:

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
- Do not add the review summary, score, or line-level findings to the PR description. If a legacy `review-pr:recap` block generated by this skill already exists in the PR body, remove it while preserving non-generated author content.

After the review is complete, submit exactly one PR review comment with the score and a few high-signal details:

```markdown
Review score: <N>/20 - <PROD READY | FIX BEFORE MERGE | DO NOT MERGE>

<2-4 bullets max: main risks, checks reviewed, or `No blocking or major findings found.`>
```

Prefer a single official PR review submission with `event=COMMENT`, a concise review `body`, and inline `comments` when line comments are needed. For GitHub, use the Pull Request Reviews API through `gh api repos/<owner>/<repo>/pulls/<number>/reviews` with a JSON payload containing `event`, `body`, and `comments`, or an equivalent MCP/hosting tool. If the review API is unavailable, use `gh pr comment <number-or-url> --body-file <file>` for the score/details comment and report that inline comments could not be posted.

For each actionable finding that can be anchored to a changed line, add an inline PR review comment on the most relevant line.

Inline comment rules:

- Add inline comments for `Blocker` and `Major` findings whenever a changed line is available.
- Add inline comments for `Minor` findings only when the action is concrete and localized.
- Do not add inline comments for nits unless the user explicitly requested nit-level review comments.
- Keep each inline comment short: state the required action and why it matters.
- If a finding cannot be anchored to a changed line, include it in the top-level PR comment instead of forcing a line comment.
- Avoid duplicate inline comments for the same finding in the same review run.

If the final score is strictly greater than `18/20` and the PR is still a draft, mark it ready for review with `gh pr ready <number-or-url>` or the equivalent official tool. Do not mark PRs ready when the score is `18/20` or lower, when the score could not be produced, or when no PR exists.

## PM Follow-Up After Promotion

If the PR was a draft and this review marked it ready for review, treat the PR as newly open for follow-up purposes.

At the end of the review response:

- Identify associated PM items from the PR body, issue-closing keywords, linked issues, branch name, task URLs, or project metadata.
- Ask the user one concise question before taking merge or PM side effects: whether they want to merge the PR and close associated GitHub issues or move associated tickets to done, depending on the PM tool context. Example: `The PR was promoted from draft to ready. Do you want me to merge the PR and close GitHub issues #2 and #3?`
- Require explicit approval in the user's next response before acting. A successful score, PR promotion, or generic request to review is not approval to merge, close issues, move tickets, comment on PM items, or update statuses.
- If the user says no or declines, do not merge the PR, close issues, move tickets, comment on PM items, or update statuses.
- If the user explicitly approves merging, use the available official tool for the context, such as `gh pr merge` for GitHub PRs. Respect branch protection, required checks, merge conflicts, and repository merge policy; if the host blocks merge, report the blocker and do not force it.
- If the user explicitly approves PM closure/status updates, use the available official tool for the context, such as `gh issue close` for GitHub Issues, GitHub Projects field updates, Notion MCP status updates, or another configured PM tool. If GitHub closing keywords will close the issues automatically on merge, say that and avoid duplicate manual closure unless the user explicitly asks.
- Report exactly which PR was merged and which issues or tickets were updated. If associated items are ambiguous, ask for the exact items instead of guessing.

Do not offer merge or PM closure/status updates when the PR was already ready/open before this review, when the PR stayed draft, or when no PR exists.

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

### PR Updates

- <summarize PR description reconciliation changes, top-level score/details comment creation, inline review comments added, and whether the PR was marked ready for review; for no PR, write `No PR body updates or comments applied.`>

### Frontend UX Notes

- <required for frontend PRs: responsiveness, loading states, interaction states, accessibility, and layout stability summary; for non-frontend PRs, write `Not applicable.`>

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

- <optional notes about PR metadata, missing context, or commands not run>
- <mention the architecture style or local convention identified, plus relevant architecture skills loaded for this review, or `No relevant architecture skill was available/discovered.`>

### PM Follow-Up

- <if this review promoted a draft PR to ready/open: ask whether to merge the PR and close associated issues or move associated tickets to done; otherwise write `Not applicable.`>
```

If there are no findings, write `No blocking or major findings found.` under `Findings`, then still provide the score breakdown and any residual risk.

Keep findings specific and code-grounded. Prefer file and line references. Avoid vague advice such as "improve quality" unless tied to a concrete code path.
