# External Research Reference

Use this reference after repository analysis.

Research order is broad to precise:

```text
Exa -> Context7 -> gh CLI
```

## Exa

Use Exa first to discover the landscape.

Search for:

```text
<feature or integration> best practices <framework/runtime>
<feature or integration> implementation patterns <framework/runtime>
<feature or integration> library alternatives <language/framework>
<candidate dependency> vs alternatives
<candidate dependency> risks security maintenance
```

Prefer recent, technical, and primary-adjacent sources. Use Exa to discover alternatives and common implementation patterns, then verify important claims against official docs or repositories.

## Context7

Use Context7 second for official documentation.

Check docs for:

- the project's framework and runtime APIs involved in the integration;
- candidate dependency APIs;
- installation and setup requirements;
- configuration, lifecycle, state, auth, security, deployment, and migration behavior;
- version-specific differences relevant to the repository.

Do not rely on memory for library syntax, package names, or current API behavior when Context7 can verify it.

## gh CLI

Use `gh` last to inspect concrete repositories and maintenance signals.

Repository discovery:

```bash
gh search repos "<feature or package> language:<language>" --limit 10
gh search repos "<package name>" --limit 10
```

Repository inspection:

```bash
gh repo view <owner/repo> --json nameWithOwner,description,url,homepageUrl,licenseInfo,stargazerCount,forkCount,watchers,pushedAt,createdAt,updatedAt,defaultBranchRef,isArchived,isFork
gh release list --repo <owner/repo> --limit 10
gh issue list --repo <owner/repo> --state open --limit 20 --json number,title,labels,createdAt,updatedAt,url
gh issue list --repo <owner/repo> --state closed --limit 20 --json number,title,labels,createdAt,updatedAt,url
gh repo view <owner/repo> --web
```

Package and source inspection when needed:

```bash
gh repo view <owner/repo> --json nameWithOwner,url,licenseInfo,pushedAt
gh api repos/<owner>/<repo>/contents/package.json --jq '.content' | base64 --decode
gh api repos/<owner>/<repo>/contents/README.md --jq '.content' | base64 --decode
gh api repos/<owner>/<repo>/contents/CHANGELOG.md --jq '.content' | base64 --decode
```

Treat these as positive dependency signals:

- maintained official or widely used repository;
- recent releases or commits;
- clear docs and examples;
- compatible license;
- small and understandable integration surface;
- active issue triage;
- API shape that fits the repository.

Treat these as negative dependency signals:

- archived repository;
- stale release history;
- unclear license;
- broad framework lock-in;
- large transitive dependency surface;
- unresolved security or maintenance issues;
- API mismatch with the repository's architecture.
