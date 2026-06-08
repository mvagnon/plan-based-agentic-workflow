# Tech Stack

- Markdown-first repository; skill behavior lives mostly in `SKILL.md` and `references/*.md`.
- Shell scripts use Bash with `set -euo pipefail`; validate syntax with `bash -n`.
- No app package manager or runtime build config in repo root; install workflow via `npx skills add mvagnon/plan-based-agentic-workflow` per README.
- GitHub/PM operations are delegated to skill references and external CLIs/MCPs such as `gh`, Serena MCP, and PM-tool MCPs.