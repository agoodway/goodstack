---
name: gs-deslop
description: Remove AI-generated code slop and clean up code style. For a deeper, opt-in pass that deletes nearly every comment, use gs-no-comments.
---

# Remove AI code slop

Check the diff against main and remove AI-generated slop introduced in the branch.

For a deeper, opt-in pass that deletes nearly every comment and fixes the code that needed one, use `gs-no-comments`.

## Focus Areas

- Extra comments that are unnecessary or inconsistent with local style
- Defensive checks or try/catch blocks that are abnormal for trusted code paths
- Casts to `any` used only to bypass type issues
- Deeply nested code that should be simplified with early returns
- Other patterns inconsistent with the file and surrounding codebase

## Guardrails

- Keep behavior unchanged unless fixing a clear bug.
- Prefer minimal, focused edits over broad rewrites.
- Keep the final summary concise (1-3 sentences).
