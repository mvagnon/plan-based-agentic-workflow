# Merge Finalization Reference

Use this reference only after `review-pr` returns `PROD READY` and the user explicitly approves merge/finalization.

## Final State Check

Immediately before merging:

```bash
gh pr view <pr> --json number,url,state,isDraft,mergeable,baseRefName,headRefName,reviewDecision,statusCheckRollup,body
gh pr checks <pr>
gh api /repos/<owner>/<repo>/pulls/<number>/reviews --paginate
```

Do not merge if:

- the PR is closed;
- the PR is still draft;
- mergeability is negative or unknown in a way that cannot be resolved safely;
- required checks are failing;
- new blocking review feedback exists;
- non-GitHub PM finalization data cannot be resolved when required.

For a multi-repo review set, run this final state check separately for each PR in its owning repository. Do not merge a blocked child-repository PR because another PR in the set is ready.

## GitHub Issues

For GitHub Issues, rely on the closing keywords or linked issue metadata already created by `implement-pm`.

Do not manually close GitHub Issues as a separate finalization action.

Inspect closing references if needed:

```bash
gh pr view <pr> --json closingIssuesReferences,linkedIssues
```

## Non-GitHub PM Tasks

For Notion or another PM tool:

1. Extract every concerned task URL from the PR body.
2. Inspect the PM schema/status field, valid status values, and existing PR backlink field/comment/description created by `implement-pm`.
3. Confirm every PR URL for the task is present when the task spans multiple repositories.
4. Confirm a safe `Done` or equivalent completed state.
5. Stop before merge when any task URL, PR backlink, or completed status cannot be resolved safely.

Do not invent a status value.

## Merge

Use repository/default merge behavior unless the user requested a specific method:

```bash
gh pr merge <pr>
```

Only use explicit methods when requested or repository convention requires one:

```bash
gh pr merge <pr> --merge
gh pr merge <pr> --squash
gh pr merge <pr> --rebase
```

Do not use admin override, force, or branch deletion flags unless explicitly requested.

## Post-Merge Checkout

After a successful merge, checkout the PR base branch and fast-forward pull:

```bash
git checkout <base-ref>
git pull --ff-only
```

If local changes make checkout or pull unsafe, stop and report the blocker. Do not stash, overwrite, or reset unless the user explicitly asks.
