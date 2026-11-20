---
name: gs-pull-request
description: "Open a draft GitHub pull request whose description a reviewer can follow without reading the diff first. Use when the user asks to open a pull request, says the pull request is already approved, asks to commit and open a pull request, runs /gs-pull-request, /gs-pull-request --approved, or /gs-pull-request --commit, or names gs-pull-request."
---

# Pull request

Open one draft GitHub pull request for the current branch. Write the description for a reader who did not make the change. That reader may be another engineer, a reviewer, or a teammate who will operate the result.

Do not commit unless the request includes `--commit`. When the working tree is dirty and the request has no `--commit`, stop and tell the user to run `/gs-git-commit` first, or to run this skill again with `--commit`. A caller that already forbids questions treats a dirty tree as blocked and does not commit, unless it passed `--commit`.

### Commit first

Read `--commit` from the request's prose. When the request includes `--commit`, or plainly asks to commit the changes before opening the pull request, commit the working tree before anything else:

- Use the `gs-git-commit` skill when it is installed. Skip its last step, which asks whether to push, because this skill pushes the branch.
- Without it, stage the files that belong to the change by name, and leave out secrets such as `.env` and `credentials.*`, build output, editor and OS files, and anything `.gitignore` covers. Make one commit for each unrelated change, with a conventional message, `type: what changed`, and no AI attribution footer. Ask the user before staging a file you are unsure of.

When the commit leaves the tree dirty, such as a file you chose not to stage, name those files and go on. When the tree was already clean, there is nothing to commit, so go on. `--commit` never skips the print-and-wait step. Only `--approved` does.

## Before writing

Run these as separate shell calls.

```bash
git status --porcelain
git branch --show-current
git symbolic-ref --short refs/remotes/origin/HEAD
git fetch origin
git log --oneline origin/<base>..HEAD
git diff origin/<base>...HEAD --stat
```

The base is the remote's default branch. The `symbolic-ref` call prints it as `origin/<base>`. Use `git remote show origin` when that call fails, and `main` when both fail. Compare against `origin/<base>`, not the local branch, which may be behind the remote.

Read `GLOSSARY.md` when the repo has one, and use those names in the description.

Read enough of the diff to say what changed, who it affects, and the one fact the change depends on. Cite a real `file:line`. A search that finds no caller is still an answer. Do not invent a caller, a test result, or an API.

## Description

Use this shape. Write the prose through the `gs-unslop` skill when it is installed. Without it, keep to these rules: sentence-case headings, straight quotes, no em dashes or emoji, a named actor, and no sentence that would still be true of any other change. Do not add an AI attribution footer.

```markdown
## What changed

<what a person or the system does differently>

## How it works

<one short paragraph>

<the smallest picture that makes the change clear>

## Evidence

<what was run, and what it showed>

## What could break

Door: <one-way or two-way, and why a revert is or is not enough>

Reach: <who or what is hit if this is wrong>

Depends on: <the one fact, file:line, and whether it was proven>

Left open: <each remaining risk, or "None found.">

## How to check

<the smallest steps a reviewer can run>
```

### What changed

Two or three sentences. Say what the user, operator, or system will do differently after merge.

### How it works

Add the smallest picture that makes the point. One picture is enough. Add a second only when the first hides the point.

Choose and draw the picture with the `gs-show-me` skill when it is installed. A description holds Markdown only, so do not write an HTML file. Without that skill, pick one of these: pseudocode for a rule or algorithm, a call tree for the path a request takes, a component tree for UI structure, a shallow file tree when the layout is the change, a Mermaid sequence or flowchart when data moves between parts, or a diff sketch when the point is what was added or removed.

Keep only the calls, files, and states a reader needs. Put the picture next to the sentence it explains.

### Evidence

Show a before and after when one exists. A screenshot is the right evidence for a visible UI change. Otherwise show the command, the test, or the output. Name the exact check that failed before and passes now.

When nothing was run, write `Not run` and name the check that would show the change works. Do not invent output.

#### Verify runs

A project verification skill writes each run to `.verify/<app>/<run-id>/`, with a `run.md` index that names the commit SHA the app was built from. Look for these indexes before writing Evidence.

```bash
ls .verify/*/*/run.md
git rev-parse HEAD
git log -1 --format=%H origin/<base>..HEAD -- <changed files>
```

A run built from a dirty working tree tested code that no commit holds, so it never applies, whatever its commit. Among clean runs, a run applies when its commit is HEAD. It also applies when its commit is on the branch and comes after the last commit that touched the changed files, so the run built the same code. Check that with `git merge-base --is-ancestor <last-touching-commit> <run-commit>` and `git merge-base --is-ancestor <run-commit> HEAD`. Ignore runs for any other commit, and say nothing about them. When no run applies, leave verify runs out of the description.

When a run applies and its features cover the change, use it in Evidence:

- Say which features the run drove, by feature ID and entry point, and which passed or failed.
- Inline short text proof from the run's artifacts, such as a command and its output or a response snippet, in a fenced block.
- Put each screenshot in Evidence as a Markdown image with its path under `.verify/` and alt text that says what it shows. Pass the same path to `gh pr create` or `gh pr edit` with `--attach`, and run `gh` from the repository root. `gh` uploads the file and rewrites the path to the uploaded copy. Look at each screenshot first, and leave out one that shows a secret, a token, or a real person's data.
- When `gh pr create --help` does not list `--attach`, write each path in backticks in place of the image, and after opening the pull request tell the user which files to drag into the description. When `gh` prints the pull request URL but exits non-zero, some uploads failed. Name the missing files to the user, and do not open the pull request again.

Never commit, stage, or push evidence files. They stay in `.verify/`, which the verification skill keeps in `.gitignore`.

### What could break

- Door. One-way when merge cannot be walked back, such as a destructive migration, sent mail or money, a published API, or deleted data. Two-way when a revert is enough.
- Reach. Name the callers, the data, or the people affected if the change is wrong.
- Depends on. State the one fact that makes the change safe, with `file:line`. Say how far you proved it, on the scale in the `gs-blast-radius` skill: you only stated it, pointed at the line, walked a failure that cannot happen, or ran the code. Write `unproven` when you did not run it.
- Left open. Each remaining risk says how it breaks, the `file:line`, and who is affected. Write `None found.` when none remain.

### How to check

Give the smallest steps a reviewer can run to see the change.

Before the body is final, read it again, including quoted code and command output. Remove secrets, tokens, absolute local paths, and private details.

## Open it

Read `--approved` from the request's prose. When the request includes `--approved`, or plainly says the pull request is already approved, skip the print-and-wait step. Open or update the pull request without waiting. The pull request stays a draft unless the user asks for a ready one.

When a person invoked `/gs-pull-request` and the request is not already approved, print the title and body and wait for approval. Apply any edits they ask for and show the changed body again.

When a caller says not to ask, open the pull request without waiting.

Push the branch when the remote does not have it.

```bash
git push -u origin HEAD
```

Do not force-push.

When `gh pr view` already finds a pull request for this branch, update that pull request with `gh pr edit` instead of opening another.

Otherwise write the body to a file outside the repository and pass it with `--body-file`, so the description never becomes shell syntax.

```bash
gh pr create --draft --title "<title>" --body-file <file>
```

Add `--attach <path>` for each screenshot that Evidence references.

The title is a conventional commit subject, `type: what changed`. Types are `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, and `style`.

Default to a draft. Open a ready pull request only when the user asks.

When the request was already approved, print the title, the body, and the pull request URL. Otherwise print the pull request URL on its own line.

## Errors

When push or `gh` fails, say the command and the error. Inspect the remote branch and any existing pull request before retrying. Reuse a pull request that already exists.
