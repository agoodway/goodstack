---
name: gs-scratch
description: "Manage a gitignored .scratch/ directory for temporary project files. Use when the user says '/gs-scratch bootstrap', '/gs-scratch write', '/gs-scratch edit', '/gs-scratch list', or asks to use the project's scratch directory. Supports creating the dir, writing files, editing files, and listing contents."
---

# Scratch

Manage a `.scratch/` directory in the current project for temporary, gitignored files.

Use the harness's file tools for writes and edits, and its shell tool for directory checks and listing. Ask the user for any input that is missing.

## Commands

Take the command from what the user typed. Format: `/gs-scratch <command> [args]`

### bootstrap

Set up `.scratch/` in the project root.

1. Create `.scratch/` directory if it doesn't exist: `mkdir -p .scratch`
2. Check if `.gitignore` exists at project root
   - If not, create it with `.scratch/` as the only entry
   - If it exists, read it and check whether `.scratch/` or `.scratch` is already listed
   - If not listed, append `.scratch/` on a new line at the end
3. Confirm what was done

### write \<filename\>

Write content to `.scratch/<filename>`.

1. Verify `.scratch/` exists. If not, run bootstrap first.
2. Ask the user what content to write if they did not give it.
3. Use the harness's file tools to create or overwrite `.scratch/<filename>`.

### edit \<filename\>

Edit a file in `.scratch/`.

1. Verify `.scratch/<filename>` exists. If not, tell the user.
2. Read the file.
3. Ask the user what changes to make if their request does not say.
4. Use the harness's file tools to apply the changes.

### list

List files in `.scratch/`.

1. Verify `.scratch/` exists. If not, tell the user to run bootstrap.
2. Run `ls -la .scratch/` to show contents.
