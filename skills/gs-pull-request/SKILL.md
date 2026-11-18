---
name: gs-pull-request
description: Open a draft GitHub pull request whose description a reviewer can follow without reading the diff first. Use when the user says "/gs-pull-request", "/gs-pull-request --approved", or asks to open a pull request.
---

# Pull request

Open one draft GitHub pull request for the current branch. Write the description for a reader who did not make the change. That reader may be another engineer, a reviewer, or a teammate who will operate the result.

Do not commit. When the working tree is dirty, stop and tell the user to run `/gs-git-commit` first. A caller that already forbids questions treats a dirty tree as blocked and does not commit.

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

The title is a conventional commit subject, `type: what changed`. Types are `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, and `style`.

Default to a draft. Open a ready pull request only when the user asks.

When the request was already approved, print the title, the body, and the pull request URL. Otherwise print the pull request URL on its own line.

## Errors

When push or `gh` fails, say the command and the error. Inspect the remote branch and any existing pull request before retrying. Reuse a pull request that already exists.
