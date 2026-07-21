---
description: Extract non-obvious learnings from this session into CLAUDE.md / AGENTS.md files
---

Analyze this session and extract non-obvious learnings into the repo's agent context files.

Target file convention: use whatever the repo already uses (`CLAUDE.md` or `AGENTS.md`); default to `CLAUDE.md` if neither exists at the target level. These files can exist at any directory level. Place learnings as close to the relevant code as possible:

- Project-wide learnings -> root file
- Package/module-specific -> packages/foo/CLAUDE.md
- Feature-specific -> src/auth/CLAUDE.md

Learnings about me or my workflow (not this repo) go to your persistent memory instead, not into the repo.

What counts as a learning (non-obvious discoveries only):

- Hidden relationships between files or modules
- Execution paths that differ from how code appears
- Non-obvious configuration, env vars, or flags
- Debugging breakthroughs when error messages were misleading
- API/tool quirks and workarounds
- Build/test commands not in README
- Architectural decisions and constraints
- Files that must change together

What NOT to include:

- Obvious facts from documentation
- Standard language/framework behavior
- Things already in a context file
- Verbose explanations
- Session-specific details

Process:

1. Review the session for discoveries, errors that took multiple attempts, unexpected connections
2. Determine scope: what directory does each learning apply to?
3. Read existing context files at the relevant levels
4. Create or update the file at the appropriate level
5. Keep entries to 1-3 lines per insight

After updating, summarize which files were created/updated and how many learnings per file.

$ARGUMENTS
