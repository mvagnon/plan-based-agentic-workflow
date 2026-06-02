#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <pm-tool> <task-ids>" >&2
}

if [ "$#" -ne 2 ]; then
  usage
  exit 64
fi

pm_tool="$1"
task_ids="$2"
branch="${pm_tool}/${task_ids}"

if [ -z "$pm_tool" ] || [ -z "$task_ids" ]; then
  usage
  exit 64
fi

if ! git check-ref-format --branch "$branch" >/dev/null 2>&1; then
  echo "Invalid branch name: $branch" >&2
  exit 64
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Missing origin remote in $repo_root" >&2
  exit 69
fi

source_branch="$(git branch --show-current)"
if [ -z "$source_branch" ]; then
  echo "Cannot create PM branch from detached HEAD" >&2
  exit 69
fi

if git show-ref --verify --quiet "refs/heads/$branch"; then
  if [ "$source_branch" = "$branch" ]; then
    existing_base="$(git config --get "branch.${branch}.pbaw-base" || true)"
    if [ -n "$existing_base" ]; then
      source_branch="$existing_base"
    else
      origin_default="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD || true)"
      if [ -n "$origin_default" ]; then
        source_branch="${origin_default#origin/}"
      fi
    fi
  fi
  git switch "$branch"
else
  git switch -c "$branch"
fi

git config "branch.${branch}.pbaw-base" "$source_branch"
git config "branch.${branch}.pbaw-pm-tool" "$pm_tool"
git config "branch.${branch}.pbaw-task-ids" "$task_ids"

git push -u origin "$branch"

printf 'Repository: %s\n' "$repo_root"
printf 'Branch: %s\n' "$branch"
printf 'Base: %s\n' "$source_branch"
