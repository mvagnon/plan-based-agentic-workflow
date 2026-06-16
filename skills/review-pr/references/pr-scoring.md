# PR Scoring Reference

This file is the source of truth for `review-pr` scoring and verdicts. Load it before assigning any score or verdict. Do not score from memory.

## Required Review Basis

Use this priority order:

| Priority | Source |
| --- | --- |
| 1 | Explicit user instructions for the review or finalization request. |
| 2 | Governing project instruction files: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and equivalents. |
| 3 | Official dependency documentation through Context7 MCP when available, then GitHub README/changelog/issues when useful. |
| 4 | `../../implement-pm/references/development-rules.md`. |
| 5 | This scoring reference. |
| 6 | Project code, only to verify implementation details and compliance. |

For architecture, the instruction files are authoritative. Identify the named architecture, layering rules, dependency direction, module boundaries, ownership rules, and testing/check expectations from those files. Do not infer architecture from code.

If governing instruction files are missing, incomplete, inconsistent, or too imprecise for an architecture-sensitive verdict, surface that as a review blocker and ask the user for architecture direction.

Do not use Exa MCP to override explicit project instructions. If governing instruction files conflict with each other in a way that changes the verdict, surface the conflict as a review blocker instead of silently choosing.

When dependency usage is added, upgraded, or materially changed, verify the changed usage against official documentation through Context7 MCP when available, then GitHub README/changelog/issues when useful. Use Exa MCP only when official sources are insufficient or outdated. Treat dependency-documented examples, documented project examples, and documented best practices as review evidence.

## Hard Blockers

Any hard blocker prevents `PROD READY`.

| Area | Blocker |
| --- | --- |
| Security | Exploitable issue, broken authn/authz, secret exposure, privacy leak, unsafe input, injection, XSS, SSRF, path traversal, or unsafe upload. |
| Data and operations | Data loss, corruption, outage risk, unsafe migration, or broken rollback path. |
| Instructions | Violation of governing `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, or equivalent project instructions. |
| Dependency docs | Unjustified material deviation from official dependency docs or documented examples when it affects architecture, security, correctness, reuse, data flow, or operations. |
| Reuse | Duplicated business logic, validation, permission checks, transformations, API workflows, query construction, data-fetching logic, or formatting rules where an owner exists. |
| Reuse | Near-duplicate components, hooks, services, schemas, DTOs, validators, repositories, or utilities that should be unified or expressed as variants. |
| Reuse | Failure to reuse a clearly available component, schema, service, validator, hook, repository, utility, or design-system primitive. |
| CI | Local CI errors or required remote check failures. |
| Inspection | Diff, linked PM tasks, or affected code paths cannot be inspected. |

Treat duplication as a bug. Do not describe it as cleanup, polish, or a later refactor when it affects changed code. Components that differ only by text, small layout tweaks, styling, state, or optional behavior should normally be one component with variants.

## Scoring

The score is `/15` and communicates production risk. Do not include the numeric score in chat responses. Include the score and category breakdown in the PR review or PR comment.

Local CI is not scored. Run it anyway. Any local CI error blocks `PROD READY`, merge, and PM task closure.

| Category | Points | Full credit |
| --- | ---: | --- |
| Instruction-file compliance | 3 | Follows loaded `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and equivalent project instructions. |
| Reuse | 3 | Reuses existing owners and primitives; no duplicated or near-duplicated logic, components, schemas, services, hooks, utilities, or workflows. |
| Dependency docs | 2 | Changed dependency usage matches official docs verified through Context7 MCP when available, plus documented project examples when relevant. |
| Maintainability and style | 2 | Matches `../../implement-pm/references/development-rules.md`: simple, readable, focused, consistently named, type-safe where useful, and avoids unnecessary net line growth. |
| Security | 3 | No credible security, authn/authz, privacy, secret-handling, or unsafe-input risk. |
| Edge cases | 2 | Handles material edge cases, regressions, empty/error states, rollback/failure paths, and linked PM scope boundaries. |

Use this point scale inside each category:

| Category max | Full | Partial | Zero |
| ---: | --- | --- | --- |
| 3 | Fully compliant. | Minor issue that is local and low risk. | Violation, duplication, missed obvious reuse, or unclear ownership. |
| 2 | Fully compliant. | Minor issue that should be cleaned up before or soon after merge. | Material deviation, avoidable complexity, dead code, weak typing, or inconsistent style. |

Apply caps after scoring:

| Condition | Cap / verdict |
| --- | --- |
| Any hard blocker | Cannot be `PROD READY`. |
| Diff cannot be inspected | `Score: not available`; `DO NOT MERGE`. |
| Severe security, data, outage, or rollback risk | Max `7/15`; normally `DO NOT MERGE`. |
| Instruction-file violation | Instruction-file compliance is `0/3`; max `12/15`; at least `FIX BEFORE MERGE`. |
| Duplication or missed obvious reuse in changed code | Reuse is `0/3`; max `12/15`; at least `FIX BEFORE MERGE`. |
| Dependency-doc violation affecting behavior, data flow, security, or operations | Dependency docs is `0/2`; max `12/15`; at least `FIX BEFORE MERGE`. |
| Meaningful security weakness | Security is at most `1/3`; at least `FIX BEFORE MERGE`. |
| Material unhandled edge case or likely regression | Edge cases is at most `1/2`; at least `FIX BEFORE MERGE`. |
| Local CI errors or required remote check failures | At least `FIX BEFORE MERGE`; no score penalty unless the failure reveals a scored issue. |

## Verdicts

| Verdict | Rule |
| --- | --- |
| `PROD READY` | Score `10-15`, no hard blockers, full local CI passed without errors, required remote checks passed, linked PM scope covered, and all scoring categories reviewed. |
| `FIX BEFORE MERGE` | Targeted remediation is required, checks have errors, duplication exists in changed code, or the PR cannot earn at least `10`. |
| `DO NOT MERGE` | Severe security, data, outage, rollback, or instruction/dependency risk; or the diff cannot be inspected. |

If the diff cannot be inspected, do not fabricate a score. Use `Score: not available` and `DO NOT MERGE`.

## Review Evidence

Before awarding points:

| Category | Required evidence |
| --- | --- |
| Instruction-file compliance | Confirm relevant instruction files were loaded and name the governing basis in review notes. |
| Reuse | Verify existing owners before accepting new logic, components, schemas, services, hooks, utilities, or workflows. |
| Reuse | Search for near-duplicates when the PR adds a component, hook, service, validator, schema, utility, or business rule. |
| Dependency docs | Verify changed dependency usage with Context7 MCP when available, then GitHub README/changelog/issues when useful. |
| Dependency docs | Require a precise technical reason before accepting deviations from documented examples or best practices. |
| Maintainability and style | Load `../../implement-pm/references/development-rules.md`, then check focus, naming, typing, dead code, hidden behavior, scope creep, and added/deleted line balance. |
| Security | Check authn/authz, input validation, secrets, privacy, unsafe redirects, uploads, dynamic queries, user-generated content, and server-side enforcement. |
| Edge cases | Check PM scope boundaries, empty states, error states, invalid input, unavailable dependencies, migration/rollback paths, and likely regressions. |
