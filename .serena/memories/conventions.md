# Conventions

- Preserve quoted YAML `description` values in skill frontmatter; unquoted `: ` can break `npx skills add/update` discovery.
- Update `agents/openai.yaml` whenever user-facing skill metadata or trigger policy changes.
- References should be technical only: commands, schemas, field mappings, API calls, terse templates, or compact rule references.
- Do not add review loops or repeated approval cycles; use Plan Mode and runner-native question tools for decisions when supported.
- Do not create tests or logs by default in skills. Test authoring is intentionally separate from implementation workflows.
- Treat the user as product and architecture authority; technical questions should focus on UX and database/data-model decisions or true blockers.