# PM Tools Reference

Use this reference for PM target discovery, source task retrieval, task creation, and approved source task updates.

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

For multi-repo work, resolve each repo independently from its nearest checkout root, submodule, child repository, or explicit path evidence. Create issues only in repos with `hasIssuesEnabled: true` and authenticated `gh` access. If more than one repo is plausible for the same task, use the runner-native clarification tool when available; otherwise stop before task creation or update and report that the project target cannot be resolved safely.

Retrieve cited GitHub Issues before planning when they are source PM tasks:

```bash
gh issue view <number-or-url> --repo <owner/repo> --json number,title,body,state,labels,milestone,assignees,url,comments
```

Use issue numbers only after the repository is safely resolved. Use issue URLs directly when they identify the repository. If a cited issue cannot be resolved or read, stop before planning and ask for the missing PM target detail.

Create one issue per new task:

```bash
gh issue create --repo <owner/repo> --title "<task title>" --body-file <body-file>
```

Update one cited source issue per approved mapped task:

```bash
gh issue edit <number-or-url> --repo <owner/repo> --title "<task title>" --body-file <body-file>
```

Do not pass labels, assignees, projects, milestones, or state flags during source issue updates unless the user explicitly approved changing them.

Apply labels, assignees, milestones, or project fields only when explicitly requested or discovered as repository convention.

## Jira, Notion, Linear, And Other PM Tools

Use the installed MCP or CLI for the selected PM tool.

Before creating or updating items, inspect:

- target project/board/database;
- valid statuses and fields;
- title/body fields;
- dependency or relation fields;
- labels, owners, milestones, components, or priorities when relevant.

When PM task IDs or URLs are cited as source tasks, retrieve each current item before planning. Capture stable ID, URL, title, body/description, comments or discussion when available, current status, and writable title/body fields.

After approval, update each cited source item mapped to an approved task by overwriting only its title/body or title/description with the approved execution contract. Preserve status, assignees, labels, project fields, comments, history, relations, and other metadata unless the user explicitly approved changing them.

Do not invent schema values. If the target or schema cannot be resolved safely, stop before task creation or update and report the missing target detail.

## Approval Boundary

PM discovery is allowed while preparing the plan. PM mutation is not.

Create or update PM items only after the user explicitly approves the latest proposed plan. If the user challenges the plan, revise the full plan first and wait for approval of that replacement.

If an approved roadmap mixes cited source tasks and new work, update mapped source tasks first, then create additional unmapped tasks in dependency order. If the mapping between an approved task and a cited source item is ambiguous, ask before mutating the PM system.

## Dependency Linking

Prefer native dependency relations when safely available. Otherwise include dependency task URLs in the body.

After creation or update, re-read or list the affected items when the tool supports it and record stable IDs/URLs for the final recap.
