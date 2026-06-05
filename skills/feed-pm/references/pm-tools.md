# PM Tools Reference

Use this reference for PM target discovery and task creation.

## GitHub Issues

Use GitHub Issues as the fallback PM target when `pm_tool` or `project_id` are missing and the concerned repository or repositories can be resolved safely from the current checkout.

Discover repository and issue metadata for each concerned repo:

```bash
git rev-parse --show-toplevel
git remote get-url origin
gh repo view --json nameWithOwner,url,defaultBranchRef,hasIssuesEnabled
gh issue list --repo <owner/repo> --limit 20 --json number,title,state,labels,milestone,assignees,url
gh label list --repo <owner/repo> --limit 100 --json name,description,color
gh api /repos/<owner>/<repo>/milestones --paginate
```

For multi-repo work, resolve each repo independently from its nearest checkout root, submodule, child repository, or explicit path evidence. Create issues only in repos with `hasIssuesEnabled: true` and authenticated `gh` access. If more than one repo is plausible for the same task, use the Decision Gate to confirm the target instead of guessing.

Create one issue per task:

```bash
gh issue create --repo <owner/repo> --title "<task title>" --body-file <body-file>
```

Apply labels, assignees, milestones, or project fields only when explicitly requested or discovered as repository convention.

## Jira, Notion, Linear, And Other PM Tools

Use the installed MCP or CLI for the selected PM tool.

Before creating items, inspect:

- target project/board/database;
- valid statuses and fields;
- title/body fields;
- dependency or relation fields;
- labels, owners, milestones, components, or priorities when relevant.

Do not invent schema values. If the target or schema cannot be resolved safely, stop after the Decision Gate response and report the missing target detail.

## Dependency Linking

Prefer native dependency relations when safely available. Otherwise include dependency task URLs in the body.

After creation, re-read or list the created items when the tool supports it and record stable IDs/URLs for the final recap.
