# Merge Finalization Reference

Use this reference only after `review-pr` returns `PROD READY` and the user explicitly approves merge/finalization.

## Final State Check

```bash
gh pr view <pr> --json number,url,state,isDraft,mergeable,baseRefName,headRefName,reviewDecision,statusCheckRollup,body,closingIssuesReferences,linkedIssues
gh pr checks <pr>
gh api /repos/<owner>/<repo>/pulls/<number>/reviews --paginate
```

Confirm the full local CI suite was run against the current PR head commit. If the head changed or the prior run is missing, rerun full local CI before merging.

Do not merge if:

- the PR is closed;
- the PR is draft;
- mergeability is negative or unknown;
- required remote checks are failing;
- full local CI is missing or failing, including out-of-scope failures;
- unresolved blocking review feedback exists;
- PM task links or backlink state cannot be resolved when task closure is requested.

## Merge

Use repository/default merge behavior unless the user requested a method:

```bash
gh pr merge <pr>
```

Explicit methods only when requested or conventional:

```bash
gh pr merge <pr> --merge
gh pr merge <pr> --squash
gh pr merge <pr> --rebase
```

Do not use admin override, force, or branch deletion flags unless explicitly requested.

## PM Task Closure

Only close or mark PM tasks done after:

- merge succeeded;
- full local CI passed for the merged PR head;
- required remote checks passed;
- the PM task URL and safe completed status are known.

For GitHub Issues, rely on PR closing keywords or linked issue metadata. Do not manually close GitHub Issues unless the user explicitly asks.

For Jira, Notion, Linear, or another PM tool, inspect valid status values before changing status. Do not invent a completed status.

## Post-Merge Checkout

```bash
git checkout <base-ref>
git pull --ff-only
```

If local changes make checkout or pull unsafe, stop and report the blocker. Do not stash, overwrite, or reset unless the user explicitly asks.
