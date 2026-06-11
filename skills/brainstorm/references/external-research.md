# External Research Reference

Use this reference after repository analysis.

Research order is repository-informed and candidate-first:

```text
gh CLI -> Repomix when handmade patterns are useful -> Context7 when dependency or framework docs are needed -> Exa if more research is needed
```

## gh CLI

Use `gh` first to discover concrete repositories and maintenance signals.

Repository discovery:

```bash
gh search repos --language "searched-language" --topic "searched-topic"
gh search repos "<feature or package> language:<language>" --limit 10
gh search repos "<package name>" --limit 10
```

Repository inspection:

```bash
gh repo view owner/repo
gh repo view <owner/repo> --json nameWithOwner,description,url,homepageUrl,licenseInfo,stargazerCount,forkCount,watchers,pushedAt,createdAt,updatedAt,defaultBranchRef,isArchived,isFork
gh release list --repo <owner/repo> --limit 10
gh issue list --repo <owner/repo> --state open --limit 20 --json number,title,labels,createdAt,updatedAt,url
gh issue list --repo <owner/repo> --state closed --limit 20 --json number,title,labels,createdAt,updatedAt,url
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

## Repomix

Use Repomix only when the handmade approach needs implementation patterns from a remote repository.

Prefer `pack_remote_repository`, `read_repomix_output`, and `grep_repomix_output` over broad manual browsing.

## Context7

Use Context7 after candidate discovery for official documentation.

Check docs for:

- the project's framework and runtime APIs involved in the integration;
- candidate dependency APIs;
- installation and setup requirements;
- configuration, lifecycle, state, auth, security, deployment, and migration behavior;
- version-specific differences relevant to the repository.

Skip Context7 when the user only wants a handmade approach and official framework or dependency docs would not change the decision.

Do not rely on memory for library syntax, package names, or current API behavior when Context7 can verify it.

## Exa

Use Exa last to enrich the gathered information if the decision still needs broader context.

Search for:

```text
<feature or integration> best practices <framework/runtime>
<feature or integration> implementation patterns <framework/runtime>
<feature or integration> library alternatives <language/framework>
<candidate dependency> vs alternatives
<candidate dependency> risks security maintenance
```

Prefer recent, technical, and primary-adjacent sources. Use Exa to enrich alternatives and common implementation patterns, then rely only on claims that are consistent with official docs or repository evidence.
