---
name: review-pr
description: "Use when one or more pull requests exist and the user wants a strict production-readiness review, approval signal, or merge finalization. It resolves PRs from the current repository or child repositories, reads linked PM tasks and prior discussion, reviews changed code with Serena MCP, runs the full local CI suite, posts concise review feedback, and only allows merge or PM task closure when local CI passes. It uses the PR scoring reference as the source of truth, judges declared project architecture from instruction files, and treats changed-code duplication as a bug."
---

# Review PR

## Summary

Review PRs as if they will deploy immediately after merge.

The review is strict on:

- security, authentication, authorization, privacy, and secrets;
- declared architecture boundaries and dependency direction from governing project instruction files;
- reuse of existing business logic, validators, schemas, services, components, and design-system primitives;
- duplicated and near-duplicate code that should be standardized, including close UI components that should become one component with variants.

Local CI passing is mandatory for `PROD READY`, merge, and PM task closure.

## Diagram

```mermaid
flowchart TD
  A[Resolve PR set] --> B[Read PM tasks and prior discussion]
  B --> C[Inspect diff and affected code with Serena]
  C --> D[Run full local CI]
  D --> E[Load scoring reference]
  E --> F[Score production risk]
  F --> L[Post one concise review]
  L --> G{Merge approved and eligible?}
  G -->|No| H[Report next fix-pr or approval step]
  G -->|Yes| I[Finalize merge]
  I --> J[Close or update PM tasks only after CI passes]
  J --> K[Run post-merge cleanup]
```

## Inputs

Optional:

- `PR`: PR URL, PR number, or branch.
- `repository`: repository path or owner/repo.

Default to the PR associated with the current branch. In a workspace, include matching child-repository PRs.

## References

Load only what is needed:

- `references/github-pr-review.md` for PR metadata, diffs, previous discussion, CI, review comments, and ready-for-review commands.
- `../feed-pm/references/architecture-rules.md` before judging architecture, reuse, duplication, task boundaries, security, frontend, backend, or design-system compliance.
- `../implement-pm/references/development-rules.md` before judging concrete implementation hygiene, local change safety, checks, and finalization readiness.
- `references/pr-scoring.md` before assigning any score or verdict. It is the scoring source of truth.
- `references/merge-finalization.md` only after the verdict is `PROD READY` and the user explicitly approved merge/finalization.

## Workflow

### Rules

- Do not implement fixes from this skill. Use `fix-pr`.
- Use Serena for changed files and directly affected code paths. If Serena is unavailable, stop.
- Load and enforce `../feed-pm/references/architecture-rules.md`; treat changed-code violations as review findings and apply `references/pr-scoring.md` for severity, score, and verdict.
- Load and enforce `../implement-pm/references/development-rules.md` for concrete implementation hygiene, change safety, and check expectations.
- Load and respect all governing global and project-specific `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` files. Treat them as authoritative repository instructions; if they conflict, surface the conflict instead of silently choosing.
- For architecture review, use the governing instruction files as the source of truth, not the code. Use code only to verify compliance, unless project-specific instruction files are missing.
- When architecture instructions name an architecture but details are missing, inconsistent, or imprecise, use Exa MCP to research best practices for that same architecture and stack before judging the PR.
- Treat duplication in changed code as a bug, including duplicated business logic, validation, permission logic, transformations, services, hooks, schemas, utilities, and near-duplicate components that should be variants.
- Read linked PM tasks before judging scope coverage.
- Read previous comments, reviews, and threads before posting new feedback.
- Run the full local CI suite for each affected repository before posting the final review.
- Do not mark `PROD READY` if local CI did not run or failed, even when failures appear out of scope.
- Do not merge or close PM tasks unless the verdict is `PROD READY`, local CI passes, required remote checks pass, and the user explicitly approved finalization.
- After merge and approved PM task actions, run the post-merge cleanup script to switch to the PR base branch, fast-forward pull it, and delete the local merged PR branch.
- Do not lower the review bar because a PR is small.
- Use `references/pr-scoring.md` as the only scoring source of truth. If it was not loaded, do not assign a score or verdict.

## Expected Response Format

### Response

```markdown
## Review PR

PR: <url>
Score: <N>/10 | not available
Verdict: <PROD READY | FIX BEFORE MERGE | DO NOT MERGE>
Architecture basis: <instruction files, inferred, or Exa-backed details>

Findings:
- <severity> - <file:line or area> - <impact and required fix>

Checks:
- `<command>`: <passed|failed|not run> - <short note>

PR updates:
- <review/comment/body/ready/finalization action>

Finalization:
- <merge/PM closure result, approval needed, or blocker>

Next:
<exact next step, usually `fix-pr` or explicit merge approval>
```

If there are no findings, write `No blocking or major findings found.`
