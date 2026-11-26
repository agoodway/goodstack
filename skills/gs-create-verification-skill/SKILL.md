---
name: gs-create-verification-skill
description: "Generate a project-local verification skill that launches the app, drives it the way a user does, and captures evidence, in any language, framework, or platform. Use when the user asks to make a verify skill or a control skill for this repo, wants a scripted way to prove UI, CLI, or service behavior, says the project has no way to drive the real app, or names gs-create-verification-skill. Only when the user asks for it."
disable-model-invocation: true
---

# Create a verification skill

Every serious project needs a scripted way to drive the real app and prove behavior: launch it, exercise a feature the way a user would, and capture evidence. This skill generates that as a project-local skill (`<skills>/verify-<app>/`) tailored to the repo. `<skills>` is the project skills directory of the harness you are running in, such as `.cursor/skills/`, `.claude/skills/`, or `.agents/skills/`. If the repo already keeps project skills in a directory this harness reads, use that one. You write the generator's output for the next agent, not for a human: it will be read cold, mid-task, by an agent that has never seen the app.

## 1. Interview the repo, not the user

Answer these from the codebase and only ask the user what you cannot observe:

- **Surface:** what does a user actually touch? A web UI, a CLI/TUI, a desktop app, an API, a mobile app, a library? A repo can have several; pick the primary one and note the rest.
- **Run:** how does the app start locally? Prefer the repo's own documented dev command (package scripts, Makefile, README quickstart). Note ports, env vars, seed data, auth.
- **Drive:** how can an agent interact with it programmatically? Existing harnesses first: Playwright/Cypress specs, expect scripts, PTY helpers, curl-able endpoints, a debug port. Only then pick a generic recipe: browser/CDP for web and Electron, a tmux/PTY harness for CLI/TUI, plain HTTP for services.
- **Observe:** what evidence can be captured? Screenshots, terminal transcripts, response bodies, logs, exit codes, DB state.
- **Isolate:** can two instances run side by side (ports, data dirs, profiles)? If not, say so in the generated skill: refusing to double-drive a shared instance beats corrupting the user's session.

If the checkout doesn't build or start as-is, fix that first (or report it precisely) before generating; a skill written against a broken base teaches wrong steps. When an irrelevant missing asset blocks startup (a static dir the API never serves, a sample config), the generated skill may create it, clearly marked as verification scaffolding, and remove it in cleanup.

## 2. Generate the skill

Write `<skills>/verify-<app>/SKILL.md` with YAML frontmatter (`name: verify-<app>` and a `description` that names the app, the surface, and when to reach for it, since without frontmatter the skill never registers) and these sections, each grounded in what the interview actually found (no placeholders left):

- **Launch:** the exact command that starts the app for verification, and how to tell it's ready (a log line, a prompt). Launch must reach a usable state from an empty data dir, including any migrations and seed data. Ready means usable, not just that a process answers. A database health check can pass while its init scripts are still running. Include teardown. For a short-lived CLI or TUI there is no server to keep alive: launch means build the binary (or install deps) once, then start each drive in its own isolated PTY or tmux session.
- **Doctor:** one read-only check that answers "is this instance worth driving?": process up, right version/build, port owned by us, auth valid. An agent runs this first whenever anything looks off.
- **Drive:** the harness recipe with real selectors/commands from this repo, not examples. Prefer stable handles (ARIA labels, data attributes, prompt strings, route paths) over coordinates and tab order.
- **Evidence:** what to capture for a proof, written to the standard location so other skills can find it. Every run writes to `.verify/<app>/<run-id>/` at the repo root, where `<run-id>` sorts by time, such as `20261119T143000Z-<short-sha>` (UTC time, then the short commit SHA). The run folder holds the artifacts (screenshots, ARIA snapshots, terminal transcripts, response bodies, logs) and a `run.md` index with the full commit SHA and branch the app was built from, whether the working tree was clean (`git status --porcelain` printed nothing) or dirty, and for a dirty tree the changed files, the time, the outcome, and one entry per feature driven: the feature ID, the entry point, pass or fail, and the artifact files that prove it. The skill adds `.verify/` to `.gitignore` when it is not there, so evidence is never committed. State the proof standards: exercise the real user path, not internal setters or test-only endpoints; capture the action and the resulting state, not just the final screen; verify side effects (files written, rows inserted, messages sent) alongside what's visible; mocks only where a production boundary already isolates the external system. When the safe path is a dry-run or test mode, verify what it actually skips by observing (files, network, git refs) rather than trusting its name: some dry-runs still touch the network or open a browser.
- **Cleanup:** how to tear down instances the run created. Never kill by process name; kill what you started. Cleanup removes instances and scratch state, never the evidence: proof artifacts survive the teardown in `.verify/<app>/<run-id>/`, and cleanup never removes `.verify/`.
- **Helpers:** any script the skill ships is executable and its invocation is shown in the skill body. A helper the reader has to reverse-engineer is not a helper.

The Evidence section tells every run to open `run.md` with this YAML front matter, and to write the Markdown index below it. Read the project's guidance, such as `AGENTS.md`, first. When the project's guidance names a format or a validator for run notes, the Evidence section gives that format in place of this block, and tells every run to run the validator after writing `run.md` and fix every error it lists. Otherwise copy the block and its rules into the generated skill:

```yaml
---
format: "gs-verify-run-notes/1"
set:
  path: "[path of the scenario set file from the repository root]"
  sha256: "[64 lowercase hex characters]"
commit: "[full SHA the app was built from]"
branch: "[branch, or null without the quotes]"
dirty: false
changed_files: []
started_at: "[UTC time the run started, such as 2026-11-19T14:30:00Z]"
finished_at: "[UTC time the run finished]"
results:
  - id: 1
    result: failed
    failed_step: "3"
    reason: "[what failed, or why it did not run, or null without the quotes]"
    evidence:
      - "03-cancel.png"
features:
  - id: "[feature ID]"
    entry_point: "[entry point]"
    result: passed
drift: []
---
```

- The file starts with a line that holds only `---`, and the front matter ends at the next such line. The free Markdown index follows it.
- `format` is `"gs-verify-run-notes/1"`. Quote every string with double quotes. Numbers, `true`, `false`, `null`, and the result values stay bare.
- `set` names the scenario set the run drove, when it came from a file: its `path` from the repository root, and `sha256`, the lowercase SHA-256 of the copy saved as `scenarios.md` in the run folder. Leave `set` out when the run drove no set from a file.
- `commit` is the full SHA the app was built from. `dirty` is `true` when `git status --porcelain` printed anything, and `changed_files` then lists those files. Otherwise `dirty` is `false` and `changed_files` is `[]`.
- `started_at` and `finished_at` are UTC times in RFC 3339, such as `2026-11-19T14:30:00Z`.
- `results` has exactly one entry per scenario id in `scenarios.md`, or is `[]` when the run drove no scenario set. `id` is the scenario's integer id. `result` is `passed`, `failed`, or `not_run`. `failed_step` is the step number as a quoted string, such as `"3"`, or `null`. A bare number would not parse as a step. `reason` says what failed or why the scenario did not run, or is `null` for a passed one. `evidence` lists the files that prove it, as paths relative to the run folder.
- `features` lists each feature driven, with its feature ID, entry point, and `passed` or `failed`, or is `[]`. `drift` lists each feature map problem the run found, as a string, or is `[]`.

## 3. Seed the feature map

Create `<skills>/verify-<app>/features/README.md` plus one file per user-facing feature you can identify (aim for the top 3-5 to start, from routes, commands, menus, or docs). Follow the shape in [`references/feature-map-example/`](references/feature-map-example/), with a README index and one file per feature. Each file answers, from the user's point of view: what the feature is, how to reach it, how to drive it with the harness, and what observable end state proves it works. The four H2s are `Sub-features`, `How to get to it (user POV)`, `Driving it with <harness>`, and `Gotchas`. If the seed data lacks a precondition that a journey needs, the journey reports a failure and the reason goes in that feature's `Gotchas`. Never weaken the journey to make it pass. The map is the repo's maintained verification source; a proof that drives one convenient entry point is incomplete when the map lists others.

## 4. Prove the generated skill before handing it over

Run its own instructions end to end once: launch, doctor, drive ONE mapped feature (one is enough; the map exists so later runs can cover the rest), capture evidence, clean up. After cleanup, confirm the evidence and its `run.md` still exist in `.verify/<app>/<run-id>/`, and that `git status` does not list them. A cleanup that eats the proof fails this step. Fix what fails, and run the generated cleanup after every failed iteration too, so broken attempts don't strand processes and ports. A generated skill that was never executed is a draft, not a deliverable. If you proved it in a stand-in for the real target (a container in place of a fresh VM, a local stack in place of a remote one), list every setup step the stand-in did that the target will not. Those steps stay unverified until a run on the real target covers them.

## 5. Offer the maintenance loop

Point the user at the `gs-maintain-verification-skill` skill (`/gs-maintain-verification-skill` in harnesses with slash commands) for keeping the map honest as the app changes. Suggest a cadence only if they ask.
