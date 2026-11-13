---
name: gs-git-commit
description: Commit the current changes with conventional messages and no AI attribution. Skip secrets and generated files. Use when the user says "/gs-git-commit" or asks to commit. This skill does not open pull requests.
---

# Git

Commit the current changes. This skill has no subcommands and does not open a pull request.

Use the harness's shell, file, and search tools. When a step needs a choice, ask the user, with the harness's question tool when it has one. Do not add an AI attribution footer.

## Interactive commands

When a git command would need interactive input, use a non-interactive alternative. Do not use `git add -p` unless the harness can drive the interaction. Otherwise stage explicit files or ask the user which files to include.

## Files to leave unstaged

Do not stage or commit any of the following:

- OS artifacts: `.DS_Store`, `Thumbs.db`, `Desktop.ini`, `._*`
- Editor and IDE files: `.idea/`, `.vscode/settings.json`, `*.swp`, `*.swo`, `*~`
- Build artifacts: `_build/`, `deps/`, `node_modules/`, `dist/`, `*.beam`
- Temp and debug files: `*.log`, `*.tmp`, `*.bak`, `*.orig`, `dump.rdb`
- Secrets: `.env`, `.env.*` except `.env.sample` and `.env.example`, and `credentials.*`
- Any file already covered by `.gitignore`

When a file might belong on this list and the change also needs it, ask the user before staging it.

## Group the commits

Review the changes and organize them into logical units before committing.

- Group related changes. The same feature, bug fix, or refactor belongs together.
- Separate unrelated changes. Different fixes or features get separate commits.
- Each commit should be independently revertible.
- Keep formatting separate from logic changes.

When changes span multiple concerns, stage specific files to create separate commits. Use partial staging only when the harness supports it safely. Otherwise ask the user how to split the changes.

## Commit

1. Run `git status` to see staged, unstaged, and untracked files.
2. Run `git diff` and `git diff --cached` to review the changes.
3. Leave every file in the skip list unstaged. Stage the related files that remain, including new files that are part of the change.
4. Group the remaining changes. When they cover more than one concern, make one commit per group, in dependency order. Migrations and schema changes go with the code that uses them. Test files go with the code they test.
5. For each group, stage only that group's files with `git add <file1> <file2>` and commit.
6. Use the message format below. When the user included a message, use it as the description.

```
type: concise description

Optional body for context
```

Types are `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, and `style`.

7. Do not add an AI attribution footer.
8. Show the commits you made.
9. Ask whether to push. Do not open a pull request. Opening one is the `gs-pull-request` skill.

## Errors

When a command fails, say what failed, suggest a fix, and ask whether to retry or stop.
