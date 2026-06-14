# PR Scoring Reference

This file is the source of truth for `review-pr` scoring and verdicts. Load it before assigning any score or verdict. Do not score from memory.

## Required Review Basis

Use this priority order:

1. Explicit user instructions for the review or finalization request.
2. Governing project instruction files: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, and equivalent repo-specific instruction files for concrete architecture, layering, ownership, commands, and conventions.
3. Official dependency documentation and documented project examples when the PR adds, upgrades, or materially changes usage of an external dependency.
4. `../../feed-pm/references/architecture-rules.md` for non-negotiable reuse, duplication, validation, typing, security, frontend, backend, data, and design-system expectations.
5. `../../implement-pm/references/development-rules.md` for concrete implementation hygiene, local change safety, checks, and finalization readiness.
6. This scoring reference.
7. Project code, only to verify implementation details and compliance.

For architecture, the instruction files are authoritative. Identify the named architecture, layering rules, dependency direction, module boundaries, ownership rules, and testing/check expectations from those files. Do not infer the architecture from the code unless project-specific instruction files are missing.

If the architecture instructions name an architecture but omit, contradict, or blur important details, use Exa MCP to research best practices for that same architecture and stack. Prefer official docs, maintainer material, and widely accepted technical references. Apply those best practices only to fill the missing or inconsistent details, and state that this is an inference from external architecture guidance.

Do not use Exa MCP to override explicit project instructions. If governing instruction files conflict with each other in a way that changes the verdict, surface the conflict as a review blocker instead of silently choosing.

If project-specific instruction files are missing, infer architecture from folders, imports, naming, nearby implementations, and repository conventions. Mark the architecture basis as inferred in the review.

When dependency usage is added, upgraded, or materially changed, verify the changed usage against official documentation through Context7 MCP when available, then GitHub README/changelog/issues when useful. Use Exa MCP only when official sources are insufficient or outdated. Treat dependency-documented examples, documented project examples, and documented best practices as review evidence.

## Hard Blockers

Any hard blocker prevents `PROD READY`.

- Exploitable security issue, broken authn/authz, secret exposure, privacy leak, unsafe user input, injection, XSS, SSRF, path traversal, or unsafe file upload.
- Data loss, corruption, outage risk, unsafe migration, or broken rollback path.
- Architecture boundary violation against the project instruction files, or against researched best practices when instruction details are missing.
- Unjustified material deviation from official dependency documentation, dependency-documented examples, documented project examples, or documented best practices when it affects architecture, security, correctness, reuse, data flow, or operational behavior.
- New or retained duplicated business logic, validation, permission checks, data transformations, API workflows, query construction, data-fetching logic, or formatting rules where an owner exists.
- Near-duplicate components, hooks, services, schemas, DTOs, validators, repositories, or utilities that should be unified or expressed as variants.
- Failure to reuse an existing component, schema, service, validator, hook, repository, utility, or design-system primitive when that reuse is clearly available.
- Missing or failing local CI.
- Required remote checks failing.
- Diff, linked PM tasks, or affected code paths cannot be inspected.

Treat duplication as a bug. Do not describe it as cleanup, polish, or a later refactor when it affects changed code. Components that differ only by text, small layout tweaks, styling, state, or optional behavior should normally be one component with variants.

## Scoring

The score is `/10` and communicates production risk internally. A high score is never allowed when a hard blocker exists. Do not include the numeric score in chat responses or PR reviews unless the user explicitly asks for it.

Calculate the category score, then apply automatic caps:

- Any hard blocker: verdict cannot be `PROD READY`.
- Diff cannot be inspected: `Score: not available` and `DO NOT MERGE`.
- Severe security, data, outage, or rollback risk: maximum `5/10` and normally `DO NOT MERGE`.
- Architecture boundary violation: Architecture and reuse is `0/3`; maximum total score is `7/10`.
- Duplication in changed code: Architecture and reuse is `0/3`; maximum total score is `7/10`; verdict is at least `FIX BEFORE MERGE`.
- Missing or failing local CI: Reliability, operations, and CI is `0/1`; verdict is at least `FIX BEFORE MERGE`.

- Security and privacy: `0-3`
  - `3`: no credible security, auth, privacy, or secret-handling risk.
  - `2`: minor hardening issue without realistic exploit path.
  - `1`: meaningful security weakness requiring changes.
  - `0`: exploitable or severe security/privacy issue.

- Architecture and reuse: `0-3`
  - `3`: follows declared architecture, dependency direction, documented dependency patterns, ownership boundaries, and reuse rules.
  - `2`: minor local style or boundary concern that does not spread.
  - `1`: architecture or reuse issue likely to spread or confuse ownership.
  - `0`: architecture violation, undocumented dependency-pattern deviation, duplicated logic, duplicated component pattern, or missed obvious reuse.

- Correctness and regressions: `0-2`
  - `2`: behavior matches PM scope and no likely regression found.
  - `1`: targeted correctness risk, edge case, or incomplete scenario.
  - `0`: broken core behavior, PM scope miss, or likely regression.

- Reliability, operations, and CI: `0-1`
  - `1`: local CI and required remote checks pass; operational risks are handled.
  - `0`: CI missing/failing, migration/deploy/rollback risk, or operational uncertainty.

- Maintainability and local style: `0-1`
  - `1`: code is simple, readable, named consistently, and fits local conventions.
  - `0`: avoidable complexity, unclear naming, dead code, weak typing, inconsistent local style, or large avoidable net additions where deletion, reuse, or a small user-approved concession would preserve scope with much less code.

## Verdicts

- `PROD READY`: score `9-10`, no hard blockers, full local CI passed, required remote checks passed, linked PM scope covered, and architecture/reuse review completed.
- `FIX BEFORE MERGE`: targeted remediation is required, checks are incomplete/failing, duplication exists in changed code, or the PR cannot earn at least `9`.
- `DO NOT MERGE`: severe security, data, outage, rollback, or architecture risk; or the diff cannot be inspected.

If the diff cannot be inspected, do not fabricate a score. Use `Score: not available` and `DO NOT MERGE`.

## Review Evidence

Before awarding architecture/reuse points:

- confirm the relevant instruction files were loaded;
- name the governing architecture basis in the review notes;
- do not rely on code to define architecture unless project-specific instruction files are missing;
- use Exa MCP for missing, inconsistent, or imprecise details of a named architecture;
- for added, upgraded, or materially changed dependency usage, verify official dependency documentation through Context7 MCP when available, then GitHub README/changelog/issues when useful, and Exa MCP only when official sources are insufficient or outdated;
- compare changed dependency usage to dependency-documented examples and documented project examples;
- require a precise technical reason before accepting deviations from documented examples or documented dependency best practices;
- verify existing owners before accepting new logic, components, schemas, services, hooks, or utilities;
- search for near-duplicates when the PR adds a component, hook, service, validator, schema, utility, or business rule;
- compare added lines to deleted lines and challenge large avoidable net additions when a smaller reuse/deletion path or user-approved concession would preserve the PM scope;
- report duplication as a finding when it appears in changed code.
