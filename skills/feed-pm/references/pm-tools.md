# PM Tools Reference

Use this reference for PM target discovery and approved task creation. `feed-pm` must write the proposed tasks to `~/pbaw-plans`, link the latest `index.md` for review, and receive explicit final confirmation to push/create PM items before creating or editing PM items.

## GitHub Repository Discovery

```bash
git rev-parse --show-toplevel
git remote get-url origin
gh repo view --json nameWithOwner,url,defaultBranchRef,hasIssuesEnabled
gh issue list --repo <owner/repo> --limit 20 --json number,title,state,labels,milestone,assignees,url
gh label list --repo <owner/repo> --limit 100 --json name,description,color
gh api /repos/<owner>/<repo>/milestones --paginate
```

If GitHub Projects are in scope, inspect before applying fields:

```bash
gh project list --owner <owner> --format json
gh project view <project-number> --owner <owner> --format json
gh project field-list <project-number> --owner <owner> --format json
```

Do not invent labels, milestones, assignees, project status values, or project fields.

## GitHub Issue Creation

Create one issue per finally confirmed task file:

```bash
gh issue create --repo <owner/repo> --title "<task title>" --body-file <body-file>
```

After creation, update both the PM item bodies and the local task files with stable issue URLs or numbers when dependencies were provisional:

```bash
gh issue edit <issue-number> --repo <owner/repo> --body-file <updated-body-file>
```

Add approved labels, assignees, or milestones only when they were explicitly requested or discovered as repository convention:

```bash
gh issue edit <issue-number> --repo <owner/repo> --add-label "<label>"
gh issue edit <issue-number> --repo <owner/repo> --add-assignee "<login>"
gh issue edit <issue-number> --repo <owner/repo> --milestone "<milestone>"
```

When adding to a GitHub Project, prefer the supported project command for the installed `gh` version:

```bash
gh project item-add <project-number> --owner <owner> --url <issue-url>
```

If project field updates are required, inspect field IDs and option IDs first; do not guess GraphQL IDs.

## Notion

Use the Notion MCP when available.

Technical discovery:

- resolve the database or page from the provided target;
- inspect database properties before creating pages;
- map title, body/content, status, relations, owner, and dependency fields only when the schema exposes them;
- use an existing planning/backlog status value when one is discoverable;
- store dependency issue URLs as relations only when the database already has a relation property for them.

If the Notion target or schema cannot be discovered, draft ready-to-copy task bodies in `~/pbaw-plans` and ask only for the missing database/page target before creating pages.

## Other PM Tools

Use an installed MCP or CLI only when discoverable. For Linear, Jira, Shortcut, Asana, or similar tools:

- inspect projects, teams, statuses, labels, and custom fields first;
- create one item per finally confirmed task file;
- preserve dependency order in bodies or native relationships;
- report unsupported fields instead of substituting a different PM system.

## Creation Gate Summary

Before executing any creation or edit command, summarize:

- latest plan index path and task files that will be used as source bodies;
- target PM tool and repository/project;
- number of tasks and titles;
- dependency order;
- labels, milestones, assignees, statuses, and project fields to apply;
- explicit final push/create confirmation received after linking the latest plan index in the current conversation.
