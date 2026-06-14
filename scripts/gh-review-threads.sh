#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <owner> <repo> <pr-number>" >&2
}

if [ "$#" -ne 3 ]; then
  usage
  exit 64
fi

owner="$1"
repo="$2"
number="$3"

if [ -z "$owner" ] || [ -z "$repo" ] || [ -z "$number" ]; then
  usage
  exit 64
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "Missing gh CLI" >&2
  exit 69
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Missing python3" >&2
  exit 69
fi

query='
query($owner: String!, $repo: String!, $number: Int!, $cursor: String) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $number) {
      reviewThreads(first: 100, after: $cursor) {
        pageInfo { hasNextPage endCursor }
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          originalLine
          comments(first: 20) {
            nodes {
              id
              body
              author { login }
              url
              createdAt
            }
          }
        }
      }
    }
  }
}'

cursor=""
while :; do
  args=(-f "query=$query" -F "owner=$owner" -F "repo=$repo" -F "number=$number")
  if [ -n "$cursor" ]; then
    args+=(-F "cursor=$cursor")
  fi

  response="$(gh api graphql "${args[@]}")"
  printf '%s\n' "$response"

  page_info="$(printf '%s' "$response" | python3 -c 'import json, sys
data = json.load(sys.stdin)
info = data["data"]["repository"]["pullRequest"]["reviewThreads"]["pageInfo"]
print("1" if info["hasNextPage"] else "0")
print(info["endCursor"] or "")')"

  has_next="$(printf '%s\n' "$page_info" | sed -n '1p')"
  cursor="$(printf '%s\n' "$page_info" | sed -n '2p')"

  if [ "$has_next" != "1" ]; then
    break
  fi
done
