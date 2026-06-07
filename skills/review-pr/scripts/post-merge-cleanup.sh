#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <pr-number-or-url>" >&2
}

if [ "$#" -ne 1 ]; then
  usage
  exit 64
fi

pr="$1"

if [ -z "$pr" ]; then
  usage
  exit 64
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Missing gh CLI" >&2
  exit 69
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not inside a git worktree" >&2
  exit 69
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Missing origin remote in $repo_root" >&2
  exit 69
fi

pr_fields="$(gh pr view "$pr" --json baseRefName,headRefName,state --jq '[.baseRefName, .headRefName, .state] | @tsv')"
IFS=$'\t' read -r base_ref head_ref pr_state <<<"$pr_fields"

if [ -z "$base_ref" ] || [ -z "$head_ref" ] || [ -z "$pr_state" ]; then
  echo "Could not resolve PR base/head/state for: $pr" >&2
  exit 69
fi

if [ "$pr_state" != "MERGED" ]; then
  echo "PR is not merged: $pr (state: $pr_state)" >&2
  exit 69
fi

if ! git check-ref-format --branch "$base_ref" >/dev/null 2>&1; then
  echo "Invalid PR base branch name: $base_ref" >&2
  exit 69
fi

if ! git check-ref-format --branch "$head_ref" >/dev/null 2>&1; then
  echo "Invalid PR head branch name: $head_ref" >&2
  exit 69
fi

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree is not clean in $repo_root" >&2
  git status --short >&2
  exit 69
fi

git fetch origin "refs/heads/${base_ref}:refs/remotes/origin/${base_ref}"

if git show-ref --verify --quiet "refs/heads/$base_ref"; then
  git switch -- "$base_ref"
else
  git switch --track -c "$base_ref" "origin/$base_ref"
fi

git pull --ff-only origin "$base_ref"

if [ "$head_ref" = "$base_ref" ]; then
  echo "Skipping local branch deletion because head and base are both: $head_ref"
elif git show-ref --verify --quiet "refs/heads/$head_ref"; then
  git branch -d -- "$head_ref"
else
  echo "Local PR branch not found, nothing to delete: $head_ref"
fi

printf 'Repository: %s\n' "$repo_root"
printf 'Base branch: %s\n' "$base_ref"
printf 'PR branch: %s\n' "$head_ref"
