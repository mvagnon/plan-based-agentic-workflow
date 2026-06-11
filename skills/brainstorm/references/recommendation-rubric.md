# Recommendation Rubric

Use this rubric before writing the final recommendation.

## Criteria

Compare handmade and dependency approaches on:

```text
User intent fit:
Repository fit:
Architecture fit:
Reuse of existing code:
Net added lines after deletions:
Small concessions requiring approval:
Implementation complexity:
Data model impact:
Security and privacy risk:
Operational risk:
Maintenance burden:
Dependency and supply-chain risk:
Lock-in and migration path:
Time to ship:
Long-term flexibility:
Verification effort:
```

## Recommendation Rules

Prefer handmade when:

- the required behavior is narrow and close to existing code;
- the repository already has primitives that cover most of the feature;
- the handmade path can stay small by deleting, reusing, or extending existing owners and avoiding broad abstractions;
- dependency APIs would force architecture drift;
- security, privacy, or data ownership risk is high;
- the external package is stale, broad, poorly licensed, or difficult to remove.

Prefer an external dependency when:

- the feature requires complex domain logic that is easy to get wrong;
- a mature dependency has a strong API fit and active maintenance;
- the dependency reduces security, correctness, compatibility, or operational risk;
- the dependency is cheaper to integrate than to reproduce correctly;
- the dependency replaces hundreds of lines of local code with a small, maintainable integration surface;
- the migration or fallback path is clear.

Prefer the smaller coherent diff when:

- both approaches satisfy the user's core goal;
- the smaller approach only requires minor user-approved concessions in optional behavior, polish, configurability, or generality;
- those concessions avoid large amounts of code and do not violate documented architecture, security, data ownership, or explicit non-goals.
- the reduction is primarily fewer added lines after accounting for deleted lines, not just fewer files or tasks.

Prefer a prototype before final decision when:

- the repository fit is plausible but unproven;
- performance, bundle size, deployment behavior, or API ergonomics are uncertain;
- the dependency looks credible but integration risk is concentrated in one unknown.

## Confidence Levels

Use `high` when repository evidence and external research point to the same answer.

Use `medium` when the recommendation is clear but depends on one explicit assumption.

Use `low` when architecture instructions are missing, dependency evidence is weak, or the decision depends on runtime behavior that needs a prototype.
