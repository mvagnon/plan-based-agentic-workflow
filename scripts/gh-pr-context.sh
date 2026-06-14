#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [pr-number-url-or-branch] [owner/repo]" >&2
}

if [ "$#" -gt 2 ]; then
  usage
  exit 64
fi

pr="${1:-}"
repo="${2:-}"

if ! command -v gh >/dev/null 2>&1; then
  echo "Missing gh CLI" >&2
  exit 69
fi

selector_args=()
if [ -n "$pr" ]; then
  selector_args=("$pr")
fi

repo_args=()
if [ -n "$repo" ]; then
  repo_args=(--repo "$repo")
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  repo_root="$(git rev-parse --show-toplevel)"
  echo "Repository: $repo_root"
  git -C "$repo_root" status --short --branch
  git -C "$repo_root" branch --show-current
  git -C "$repo_root" remote -v
fi

fields="number,title,body,url,state,isDraft,baseRefName,headRefName,headRepository,headRepositoryOwner,author,files,comments,reviews,reviewDecision,statusCheckRollup,closingIssuesReferences,linkedIssues"

echo
echo "== PR metadata =="
gh pr view "${selector_args[@]}" "${repo_args[@]}" --json "$fields"

echo
echo "== PR diff =="
gh pr diff "${selector_args[@]}" "${repo_args[@]}"

echo
echo "== PR checks =="
if ! gh pr checks "${selector_args[@]}" "${repo_args[@]}"; then
  echo "gh pr checks reported failing, pending, or unavailable checks." >&2
fi
