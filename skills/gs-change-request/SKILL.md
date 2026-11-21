---
name: gs-change-request
description: "Write the description file for a goodflows change request, the replacement for a pull request on any Git host, with change-claims/1 YAML front matter that goodflows parses and a body a reviewer can follow without reading the diff first. By default it writes the file only. With --approved it also creates or updates the change request through the goodflows CLI. It never pushes, opens a pull request, or calls a host API itself. Use when the user asks to write, create, or update a change request, a CR description, or the change claims for a branch, asks to describe a branch for goodflows, says the change request is already approved, runs /gs-change-request or /gs-change-request --approved, or names gs-change-request."
---

# Change request

Write the description of a goodflows change request for the current branch. A change request replaces a pull request and works on any Git host. Write it for a reader who did not make the change. That reader may be another engineer, a reviewer, or a teammate who will operate the result.

The file has two parts. YAML front matter holds the claims goodflows parses: the commit they describe, the door, the reach, the facts the change depends on, the open risks, the questions for the reviewer, and the hunks the reviewer should judge. The Markdown body says the same things for a person.

By default this skill only writes the file. With `--approved`, it then hands the file to the goodflows CLI, which creates or updates the change request. See [Create it](#create-it). Either way, do not push, do not open a pull request, and do not call a host API through `gh`, `glab`, `curl`, or anything else yourself. Whatever reaches the host goes through the goodflows CLI. Do not commit, and do not stage the file.

## Before writing

Run these as separate shell calls.

```bash
git status --porcelain
git branch --show-current
git rev-parse HEAD
git symbolic-ref --short refs/remotes/origin/HEAD
git fetch origin
git log --oneline origin/<base>..HEAD
git diff origin/<base>...HEAD --stat
```

The base is the remote's default branch. The `symbolic-ref` call prints it as `origin/<base>`. Use `git remote show origin` when that call fails, and `main` when both fail. Compare against `origin/<base>`, not the local branch, which may be behind the remote. `git fetch` only reads from the remote, so it is allowed.

The claims describe one commit, so the working tree must be clean. When `git status --porcelain` prints anything, stop and tell the user to commit first, with the `gs-git-commit` skill when it is installed. Do not commit for them.

Read `GLOSSARY.md` when the repo has one, and use those names in the description.

Read enough of the diff to say what changed, who it affects, and the facts the change depends on. Cite a real `file:line`. A search that finds no caller is still an answer. Do not invent a caller, a test result, or an API.

## Where the file goes

Write the file to `.goodflows/change-requests/<branch>.md` at the repository root, where `<branch>` is the branch name with each `/` replaced by `-`. On a detached HEAD, use `detached-<short SHA>`. Create the directories when they are missing.

The file must stay out of the commits it describes. Committing it would make a new commit, so the `head` it names would be stale the moment it landed. Keep it untracked without editing a tracked file: run `git rev-parse --git-path info/exclude`, and add the line `.goodflows/` to that file when it is not there. Do not edit `.gitignore`, because that dirties the tree the claims describe.

Do not write the file into an OpenSpec change directory, even when the branch has one. That directory is tracked, and archiving the change moves it. Name the OpenSpec change in What changed instead.

## One file per branch, rewritten per head

The claims are per head. When the file already exists, read its front matter first, and keep its `cr` value.

- When the old `head` is the current HEAD, update the claims you can now prove better, and leave the rest.
- When the head changed and the change did not, such as after a rebase with no conflicts, a reworded commit, or a squash, keep the body and every claim, and rewrite only `head`. The change is the same when `git diff <old-base>...<old-head> | git patch-id --stable` and `git diff origin/<base>...HEAD | git patch-id --stable` print the same ID, where `<old-base>` is `git merge-base origin/<base> <old-head>`. When the old head is no longer in the repository, treat the change as changed.
- When the change itself changed, write every claim again for the new head. Copy nothing from the old file except `cr`, and recheck each fact and its proof.

## The file

Use this shape. Write the prose through the `gs-unslop` skill when it is installed. Without it, keep to these rules: sentence-case headings, straight quotes, no em dashes or emoji, a named actor, and no sentence that would still be true of any other change. Do not add an AI attribution footer.

```markdown
---
format: change-claims/1
cr: null
head: "[full commit SHA of HEAD]"
door: two_way
door_reason: "[why a revert is or is not enough]"
reach: "[who or what is hit if this is wrong]"
depends_on:
  - fact: "[a fact that makes the change safe]"
    location: "[path:line]"
    proof: ran
left_open:
  - risk: "[how it breaks]"
    location: "[path:line]"
    affected: "[who or what is hit]"
questions:
  - id: 1
    text: "[the question the reviewer must answer]"
    options:
      - "[an option]"
      - "[another option]"
    recommendation: "[one of the options, copied exactly]"
decisions:
  - id: 1
    path: "[path from the repository root]"
    hunk: |-
      @@ -10,3 +10,4 @@ [the hunk exactly as git diff prints it]
       [context line]
      -[removed line]
      +[added line]
    note: "[why this hunk changed, or what the reviewer should check]"
---

# [type: what changed]

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

Depends on: <each fact, file:line, and how far it was proven>

Left open: <each remaining risk, or "None found.">

## How to check

<the smallest steps a reviewer can run>

## Questions for the reviewer

<each question with its options and your recommendation, or "None.">

## Decisions to judge

<each decision hunk as a diff block with its note, or "None.">
```

### Front matter

The front matter is the contract goodflows reads. Keep it exactly as follows:

- The file starts with a line that holds only `---`, and the front matter ends at the next such line. Nothing comes before it.
- Write the keys in the order the shape shows. Quote every string value with double quotes, and escape a double quote inside one as `\"`. The one exception is `hunk`, which is a literal block scalar, `|-`, so the diff lines keep their exact text. Numbers, `null`, and the lowercase values below stay bare.
- `format` is `change-claims/1`. A change to the fields that would break a reader gets a new number.
- `cr` is the change request number goodflows gave, as a bare integer. Before the change request exists it is `null`. The goodflows CLI writes the number into this field when it creates the change request. Take it from the existing file or from the user. Never guess it, and never ask a host for it.
- `head` is the full SHA that `git rev-parse HEAD` prints.
- `door` is `one_way` or `two_way`, and `door_reason` says why.
- `depends_on` lists each fact the change is safe because of, with at least one entry. A trivial change still names one, such as "No code reads this file" with `proof: stated`. `location` is a real `file:line`. `proof` is how far you proved the fact, on the `gs-blast-radius` scale, from weakest to strongest: `stated`, `pointed`, `walked`, or `ran`. See What could break.
- `left_open` lists each remaining risk, or is `[]`.
- `questions` lists what the reviewer must decide that you could not settle from the code, the specs, or the request, or is `[]`. `id` counts from 1. `options` has two or more entries. `recommendation` is one of the `options`, copied exactly.
- `decisions` lists at most three hunks a reviewer should judge, or is `[]`. A hunk is a decision when it holds a tradeoff, a rejected alternative, a behavior that changes, or an edge case you resolved. Leave routine edits out. `id` counts from 1. `path` is the file's path from the repository root. `hunk` starts at its `@@` line and is copied from `git diff origin/<base>...HEAD -- <path>`, cut to the lines that carry the decision, with no line edited. `note` is one sentence on why it changed or what to check.
- The body says the same things for the reviewer. When you change one, change the other.

### Title

The `#` heading is a conventional commit subject, `type: what changed`. Types are `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, and `style`.

### What changed

Two or three sentences. Say what the user, operator, or system will do differently after merge. When the branch implements an OpenSpec change, name it here.

### How it works

Add the smallest picture that makes the point. One picture is enough. Add a second only when the first hides the point.

Choose and draw the picture with the `gs-show-me` skill when it is installed. The body holds Markdown only, so do not write an HTML file. Without that skill, pick one of these: pseudocode for a rule or algorithm, a call tree for the path a request takes, a component tree for UI structure, a shallow file tree when the layout is the change, a Mermaid sequence or flowchart when data moves between parts, or a diff sketch when the point is what was added or removed.

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

A run built from a dirty working tree tested code that no commit holds, so it never applies, whatever its commit. Among clean runs, a run applies when its commit is HEAD. It also applies when its commit is on the branch and comes after the last commit that touched the changed files, so the run built the same code. Check that with `git merge-base --is-ancestor <last-touching-commit> <run-commit>` and `git merge-base --is-ancestor <run-commit> HEAD`. Ignore runs for any other commit, and say nothing about them. When no run applies, leave verify runs out of the file.

When a run applies and its features cover the change, use it in Evidence:

- Say which features the run drove, by feature ID and entry point, and which passed or failed.
- Inline short text proof from the run's artifacts, such as a command and its output or a response snippet, in a fenced block.
- Put each screenshot in Evidence as a Markdown image with its path under `.verify/` and alt text that says what it shows. Leave the path as it is. The goodflows CLI uploads what the file references. Look at each screenshot first, and leave out one that shows a secret, a token, or a real person's data.

Never commit, stage, or push evidence files. They stay in `.verify/`, which the verification skill keeps in `.gitignore`.

### What could break

- Door. One-way when merge cannot be walked back, such as a destructive migration, sent mail or money, a published API, or deleted data. Two-way when a revert is enough.
- Reach. Name the callers, the data, or the people affected if the change is wrong.
- Depends on. State each fact that makes the change safe, with `file:line`, and how far you proved it, on the scale in the `gs-blast-radius` skill. `stated` means you only said it. `pointed` means you pointed at the line. `walked` means you walked the failure step by step and showed it cannot happen. `ran` means you ran code that proves it. Give a fact the proof you reached, not the one you meant to reach. In the body, write `unproven` beside a fact you did not run.
- Left open. Each remaining risk says how it breaks, the `file:line`, and who is affected. Write `None found.` when none remain.

### How to check

Give the smallest steps a reviewer can run to see the change.

### Questions and decisions

Under "Questions for the reviewer", give each question with its number, its options, and your recommendation marked. Under "Decisions to judge", give each decision as a `diff` block under a `### [id]. [path]` heading, with its note under the block. Write `None.` under a heading with nothing in it.

Before the file is final, read it again, including quoted code and command output. Remove secrets, tokens, absolute local paths, and private details. Check that the front matter parses as YAML, that `head` is the current HEAD, and that every `hunk` appears in the diff as written.

## Create it

Read `--approved` from the request's prose. When the request includes `--approved`, or plainly says the change request is already approved, create or update the change request after the file is final. Without it, skip this section and go to Finish.

1. Run `command -v goodflows`. When it prints nothing, the CLI is not installed. Keep the file, say so, and go to Finish.
2. Run `goodflows --help`, and the help of the change request command it lists, such as `goodflows cr --help`. Find the command that creates a change request from a description file, and the one that updates an existing change request. Use only commands and flags the help prints. Do not guess a command. When the help names none that fits, keep the file, quote the help's command list, and go to Finish.
3. When `cr` is `null`, run the create command with the file's path. When `cr` holds a number, run the update command for that number instead, so a second change request is never made.
4. Read the file again. When the CLI wrote the change request number into `cr`, keep it. When `cr` is still `null` and the CLI printed the number, write that number into `cr` yourself, and change nothing else.

The CLI may push the branch or call the host as part of its own work. That is its job, not this skill's. Do not run a push or a host command to help it.

When a goodflows command fails, quote the command and its error. Read the file again before you retry. When `cr` now holds a number, the change request was created, so retry with the update command, not the create command. Do not retry the same failing command unchanged.

## Finish

Print the path of the file, the `head` it describes, and whether you wrote new claims or only rewrote `head`. With `--approved`, also print the change request number and any URL the CLI printed, or why the change request was not created. Without `--approved`, say that `/gs-change-request --approved` creates or updates the change request through the goodflows CLI, and do not run it. When `cr` is still `null`, say that the goodflows CLI writes it into the file when it creates the change request.
