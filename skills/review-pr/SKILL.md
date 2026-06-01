---
name: review-pr
description: Use when one or more pull requests exist and the user intends to polish, approve, or merge PRs. It resolves PRs from the current repository or child repositories, commits and pushes local changes before review, reads linked PM tasks plus previous reviews/comments/thread history before adding new feedback, performs strict production-readiness and architecture review, runs the full local CI suite, reconciles PR descriptions, posts score/details and inline comments, marks strong drafts ready, and only finalizes merge after explicit approval.
---

# Review PR

## Purpose

Perform a strict production-readiness review of PR code. Score only changed code and directly affected code paths, compare the diff with both the linked PM tasks and the PR description, run the full local CI suite, post one clear review per PR, and recommend `fix-pr` when fixes are needed.

This skill may update PR bodies, submit review comments, resolve stale conversations that are already addressed, mark strong draft PRs ready, and complete explicitly approved merge finalization.

## Inputs

Read `$ARGUMENTS` or equivalent natural language as:

- `PR`: optional PR URL, PR number, or branch name. If omitted, infer from the current branch.
- `Repository`: optional repository URL, identifier, or child repository path.

Ask one concise question only when the PR cannot be resolved or multiple unrelated PRs match. In a workspace with child repositories, treat matching child-repo PRs as one multi-repo review set.

## References

Load only what is needed:

- `references/github-pr-review.md` for PR metadata, diffs, prior discussion, review threads, checks, PR body reconciliation, review submission, and ready-for-review mechanics.
- `references/merge-finalization.md` for approved merge finalization and PM completion rules.

## Rules

- Do not implement fixes from this skill.
- Use `fix-pr` as the follow-up for code changes and review-thread remediation.
- Score code risk only. Do not lower the score for PR size, metadata quality, missing description context, or commit history shape unless the committed code creates production risk.
- Treat PR-caused CI failures as scored risks. Mention demonstrably out-of-scope full-suite failures without lowering the score.
- Treat linked PM tasks as the source of truth for intended scope. Use the PR description as a reviewer-facing summary and reconcile it when it omits or misstates task coverage.
- Use Serena for changed-file and nearby-symbol exploration. If Serena is unavailable, stop instead of scoring from local search alone.
- Identify the actual architecture or local convention before judging architecture. Load directly relevant architecture skills when available.
- Prefer existing project conventions over generic preferences.
- Do not merge unless the verdict is `PROD READY`, the full local CI suite and required GitHub checks pass, and the user explicitly approved finalization.

## Workflow

1. Resolve the PR set. Use the current Git root for normal repos; inspect child Git repositories in multi-repo workspaces.
2. Check local status in every affected repository. If there are staged, unstaged, or untracked non-ignored changes, commit and push them before reading the diff or reviewing. Stop if commit or push fails.
3. Read PR metadata: title, body, URL, state, draft state, base, head, author, linked issues/tasks, changed files, status checks, review decision, and diff.
4. Resolve linked PM tasks from PR body references, GitHub `closingIssuesReferences` or `linkedIssues`, and non-GitHub task URLs in the body. Read task title, body, comments that change scope, dependencies, and canonical URLs before judging coverage.
5. Build a prior-discussion ledger before adding feedback. Read issue comments, review summaries, review comments, and all review threads, including unresolved, resolved, and outdated threads when available. Record source, URL/thread ID, status, concern, whether current head addresses it, and whether new feedback would duplicate it.
6. Use the ledger to avoid duplicate inline comments, carry forward unresolved valid concerns, and resolve only conversations already addressed by current code or fully explained by existing discussion.
7. Read project instructions and relevant package docs. Load matching skills and record the constraints they add.
8. Inspect changed files plus nearby modules, tests, schemas, routes, services, migrations, security utilities, and UI patterns needed to understand impact.
9. Run the full local CI suite for every affected repository before posting the PR review. Prefer repo-level non-interactive lint, typecheck, test, format-check, and build commands. Use scoped commands only when no full-repository command exists, and report that limitation.
10. Classify every check failure as PR-caused, likely PR-caused, or out of scope with concise evidence.
11. Review the diff against the standards below and calculate the score from concrete code risks.
12. Reconcile the PR description after inspecting the linked PM tasks and diff. Preserve author content and only replace sections previously generated by this skill.
13. Submit exactly one PR review per PR with score, verdict, CI status, out-of-scope failures, and high-signal details. Add inline comments for actionable findings anchored to changed lines.
14. Mark a draft PR ready only when the final score is strictly greater than `18/20`.
15. If merge finalization is approved and all merge conditions pass, finalize with `references/merge-finalization.md`. Otherwise report the required approval or blocker.

## Review Standard

Review as if the code will deploy immediately after merge. Check:

- Linked PM task coverage and PR description alignment when task references or a description exist.
- Architecture, boundaries, ownership, dependency direction, data flow, public APIs, and reuse of existing patterns.
- Correctness, edge cases, regressions, error paths, async/race behavior, idempotency, migrations, and backwards compatibility.
- Security, authn/authz, multi-tenancy, validation, injection, XSS, CSRF, SSRF, path traversal, file uploads, secrets, PII, logging, webhooks, payments, and rate limits.
- Production readiness, observability, explicit errors, retries/timeouts, transactions, cleanup, query cliffs, rollout, and rollback safety.
- Full-suite CI status, tests, and verification for changed behavior.
- Maintainability, naming, type safety, dead code, duplication, unnecessary abstraction, hidden side effects, and local style.
- Frontend UX when applicable: responsiveness, loading/error/empty/disabled states, duplicate-submit protection, hover/focus/active states, text/control overflow, keyboard access, labels, semantics, contrast, screen-reader feedback, and layout stability.

Architecture checks must name the governing architecture or local convention. Verify owner folders/layers, allowed dependency direction, business-rule placement, shared abstraction reuse, package boundaries, framework conventions, and file/module placement.

## Severity And Score

Use these severities:

- `Blocker`: must not merge. Examples: exploitable security, broken authz, data loss, outage risk, unsafe migration, severe regression, or architecture break that makes the system unsafe to operate.
- `Major`: should fix before merge. Examples: likely bug, missing validation, weak tests around risky behavior, near-term maintainability risk, or meaningful architecture drift.
- `Minor`: worth fixing, but not merge-blocking.
- `Nit`: optional polish.

Start from `20` and subtract concrete code risks:

| Category | Points |
| --- | ---: |
| Architecture and boundaries | 6 |
| Correctness and regression risk | 4 |
| Security and privacy | 4 |
| Production readiness and reliability | 2 |
| Tests and verification | 2 |
| Maintainability and best practices | 2 |

Score bands:

- `18-20`: production-ready. Only minor or nit-level issues.
- `15-17`: close, but fixes are recommended before merge.
- `12-14`: not production-ready without targeted fixes.
- `8-11`: high-risk PR. Merge should be blocked.
- `0-7`: severe production or security risk.

Score caps:

- Credible exploitable security issue or missing server-side authz on protected data/actions: max `8/20`.
- Data loss, corruption, outage risk, or unsafe production migration: max `10/20`.
- Clear architecture violation likely to spread: max `12/20`.
- Cross-package or dependency-direction violation that can break consumers: max `13/20`.
- Architecture-sensitive diff with unidentified governing architecture: max `16/20`.
- Available directly relevant architecture skill not consulted before scoring: max `15/20`, unless corrected before finalizing.
- Architecture score `3/6` or lower: max `17/20` and verdict cannot be `PROD READY`.
- Architecture score `2/6` or lower: max `12/20`.
- Untested high-risk behavior change in a repo with a test setup: max `15/20`.
- Diff cannot be inspected: do not fabricate a score.

## PR Updates

- Resolve only conversations already addressed by current code or fully explained by existing discussion.
- Do not resolve conversations that still need code changes, reviewer confirmation, or user decisions.
- Avoid duplicate inline comments for concerns already present in unresolved threads.
- Add inline comments for `Blocker` and `Major` findings whenever a changed line is available.
- Add inline comments for `Minor` only when concrete and localized.
- Do not add inline comments for nits unless the user requested nit-level review.
- Keep inline comments short: required action and why it matters.
- Put unanchored findings in the top-level review body.

## Output Format

Repeat this block once per PR in multi-repo reviews. Do not combine scores.

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
- <match/mismatch with linked PM tasks, stated goals, acceptance criteria, validation plan, and scope; or `No PR description available.`>

### PR Updates
- <PR body reconciliation, top-level review, inline comments, prior-thread handling, ready-for-review status>

### Finalization
- <merge result, approval needed, blocker, or `Not run because the PR is not production-ready.`>

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
- <full local CI commands/status, out-of-scope failures, prior discussion ledger summary, PR metadata, missing context, commands not run, architecture style identified, and loaded skills>

### Next Step
- <exactly one next step>
```

If there are no findings, write `No blocking or major findings found.` under `Findings`.

## Final Checklist

- [ ] 1. PR set resolved from current branch or explicit input, including child repos.
- [ ] 2. Local changes in each affected repo committed and pushed, or review stopped with the blocker.
- [ ] 3. PR metadata, linked tasks, diff, changed files, and checks read.
- [ ] 4. Linked PM task bodies/comments plus previous issue comments, review summaries, review comments, and review threads read before new feedback.
- [ ] 5. Prior-discussion ledger used to avoid duplicates and handle stale or unresolved conversations.
- [ ] 6. Project instructions, relevant package docs, Serena context, and matching skills loaded.
- [ ] 7. Changed code and directly affected code paths inspected with architecture ownership identified.
- [ ] 8. Full local CI suite run or missing full-suite commands reported with reason.
- [ ] 9. Check failures classified as PR-caused, likely PR-caused, or out of scope.
- [ ] 10. Score and verdict calculated from concrete code risks with score caps applied.
- [ ] 11. PR description reconciled without overwriting author content.
- [ ] 12. One review posted per PR with top-level score/details and non-duplicate inline comments.
- [ ] 13. Draft marked ready only when score is greater than `18/20`.
- [ ] 14. Merge finalization performed only with explicit approval and passing final checks.
- [ ] 15. Final response includes score breakdown, prior-discussion summary, CI status, PR updates, and one next step.
