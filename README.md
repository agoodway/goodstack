# goodstack

This repo publishes agent skills. They review and ship code, explain a codebase, test a design before you build it, and edit prose. Each skill installs on its own with the skills CLI. The source is `agoodway/goodstack`.

The skills are written to run in Claude Code, Codex, Cursor, Amp, and any other harness that reads skills. Three skills name specific tools for an optional feature, and each says what it does without them. `gs-review` names the Codex, Grok, and Claude tools it can ask for a second opinion. `gs-openspec-ship-tickets` names T3 Code, Amp, and Claude Code for its thread mode. `gs-council` names the T3 Code tools that can start its delegates.

Every skill name starts with `gs-`, so a skill from this repo never overwrites a same-named skill from another source.

## Skills

### Review and ship

- [`gs-review`](skills/gs-review/README.md) reviews a change for what will break in production. Specialist reviewers raise findings, and a second model tries to refute each one. A project can shape its own reviews with an optional `REVIEW.md`.
- [`gs-council`](skills/gs-council/README.md) asks three delegates on models from different providers to review the work in parallel. The agent fixes what it agrees with, scores each round, and repeats until they are satisfied.
- [`gs-review-pr-reply`](skills/gs-review-pr-reply/README.md) posts a `gs-review` report to the current branch's pull request as one GitHub review.
- [`gs-git-commit`](skills/gs-git-commit/README.md) commits the current changes with conventional messages. It skips secrets and generated files, and it adds no AI attribution.
- [`gs-pull-request`](skills/gs-pull-request/README.md) opens a draft GitHub pull request. The description says what changed, how it works, what was run, and what could break.
- [`gs-change-request`](skills/gs-change-request/README.md) writes the description file for a goodflows change request, the replacement for a pull request on any Git host. YAML front matter holds the claims goodflows parses, and the body follows `gs-pull-request`. With `--approved` it creates or updates the change request through the goodflows CLI, and it never pushes or calls a host API itself.
- [`gs-change-request-ship`](skills/gs-change-request-ship/README.md) takes a branch through a goodflows change request, from opening it to reporting the merge. It gives the order of the `goodflows cr` commands, which skill writes each file they upload, and what each verdict reason asks for.
- [`gs-pr-comment`](skills/gs-pr-comment/README.md) writes and posts a GitHub comment for you. Each comment opens with a note naming the model and the user it speaks for.
- [`gs-pr-show-me`](skills/gs-pr-show-me/README.md) explains what an existing pull request changes, in plain language with small pictures. It reads the pull request and posts nothing.
- [`gs-qa-scenarios`](skills/gs-qa-scenarios/README.md) writes manual QA scenarios for a branch or pull request. Each scenario tells a QA engineer what to test, why, the exact steps, and the result to expect. It can also run the scenarios through the project's `verify-*` skill and report a result with evidence for each one.

### OpenSpec

- [`gs-openspec-ship`](skills/gs-openspec-ship/README.md) takes each named OpenSpec change through apply, verify, review, archive, and commit. It rebases onto the remote's default branch first, and it opens one draft pull request at the end.
- [`gs-openspec-review-change`](skills/gs-openspec-review-change/README.md) quick-reviews an OpenSpec change before you build it. It patches the findings with one obvious fix and answers design questions with a recorded recommendation, or asks you each one when you request it.
- [`gs-openspec-qa-scenarios`](skills/gs-openspec-qa-scenarios/README.md) writes QA scenarios from an OpenSpec change's specs, before or after anyone builds it. Each Must scenario names the requirement it covers, and the output has the same shape as `gs-qa-scenarios`, so its run mode can run either set.
- [`gs-openspec-to-tickets`](skills/gs-openspec-to-tickets/README.md) breaks OpenSpec changes into tickets that each cut through every layer. It publishes them to GitHub, Linear, Jira, or local markdown.
- [`gs-openspec-ship-tickets`](skills/gs-openspec-ship-tickets/README.md) ships those tickets in blocking order, one pipeline per ticket. It archives each finished change and opens one draft pull request.

### Understand code

- [`gs-how`](skills/gs-how/README.md) explains how a subsystem works. It covers the runtime flow and where the code lives.
- [`gs-why`](skills/gs-why/README.md) investigates why code is shaped the way it is. It cites what it finds in git history, tickets, docs, and chat.
- [`gs-blast-radius`](skills/gs-blast-radius/README.md) finds what a change could break outside the diff. It names the one fact the change is safe because of, and it proves that fact by running code.

### Verify the app

- [`gs-create-verification-skill`](skills/gs-create-verification-skill/README.md) generates a project-local skill that launches the app, drives it the way a user does, and captures evidence. It seeds a feature map and runs the new skill once before handing it over.
- [`gs-maintain-verification-skill`](skills/gs-maintain-verification-skill/README.md) checks a verification skill and its feature map against the source and the live app. It ships proven corrections in at most one pull request.
- [`gs-create-formal-verification-skill`](skills/gs-create-formal-verification-skill/README.md) formally verifies one property of the code where a bug costs the most and tests reach the least, with the tool that fits. It leaves a project-local skill that rechecks the property on every change.
- [`gs-maintain-formal-verification-skill`](skills/gs-maintain-formal-verification-skill/README.md) brings formal verification back in line after the code changes. It says whether each failure is drift in the verification or a bug in the code.
- [`gs-statechart`](skills/gs-statechart/README.md) checks a TLA+ model of a system that moves between states with TLC, and draws it as a Mermaid statechart. The report gives the shortest path to each state that breaks a rule.

### Design

- [`gs-arena`](skills/gs-arena/README.md) runs several attempts at the same task in parallel. It picks one as the base and grafts the strongest parts of the others into it.
- [`gs-prototype`](skills/gs-prototype/README.md) builds a throwaway prototype to answer one design question. Logic gets a clickable HTML file. A screen gets several variants you can switch between.
- [`gs-improve-codebase-architecture`](skills/gs-improve-codebase-architecture/README.md) scans a codebase for shallow modules to deepen and writes the candidates to an HTML report with before and after diagrams. It then asks you about the one you pick, one decision at a time.
- [`gs-codebase-design`](skills/gs-codebase-design/README.md) gives the agent a fixed vocabulary for designing deep modules. It also says how to deepen shallow modules and how to compare interface designs.
- [`gs-sharpen`](skills/gs-sharpen/README.md) makes a task deeper, not bigger, and then rewrites your prompt.

### Write and explain

- [`gs-unslop`](skills/gs-unslop/README.md) edits text to remove AI writing patterns.
- [`gs-deslop`](skills/gs-deslop/README.md) removes AI-generated code slop from the branch's diff.
- [`gs-no-comments`](skills/gs-no-comments/README.md) deletes nearly every comment in a diff and fixes the code that needed one. It is a deliberate, aggressive pass, where `gs-deslop` is the lighter cleanup.
- [`gs-find-bad-comments`](skills/gs-find-bad-comments/README.md) reports the comments and lint or type suppressions that should be removed, with a kind, a verdict, and a reason for each. It changes no file.
- [`gs-show-me`](skills/gs-show-me/README.md) explains the current topic with the smallest picture that fits. The picture is a tree, a diagram, a diff, or one HTML file.
- [`gs-wait-what`](skills/gs-wait-what/README.md) makes the agent say its last message again in plain language, with the context you are missing.

### Housekeeping

- [`gs-find-bad-tests`](skills/gs-find-bad-tests/README.md) reports the tests that guard no behavior, with a category, a verdict, and a reason for each. It changes no file.
- [`gs-prune-tests`](skills/gs-prune-tests/README.md) deletes tests that guard no behavior and rewrites the ones that guard it the wrong way. It keeps regression, contract, and security tests, and the tests must pass before and after.
- [`gs-reflect`](skills/gs-reflect/README.md) reviews a finished session with four reviewers. It routes each lasting lesson to a check, a coding standard, a skill edit, or a pointer in a steering file.
- [`gs-scratch`](skills/gs-scratch/README.md) manages a gitignored `.scratch` directory for temporary project files. The commands are `/gs-scratch bootstrap`, `/gs-scratch write`, `/gs-scratch edit`, and `/gs-scratch list`.

### Who starts a skill

Fourteen skills run only when you type the command: `gs-arena`, `gs-why`, `gs-improve-codebase-architecture`, `gs-no-comments`, `gs-reflect`, `gs-openspec-ship`, `gs-openspec-to-tickets`, `gs-openspec-ship-tickets`, `gs-create-verification-skill`, `gs-maintain-verification-skill`, `gs-create-formal-verification-skill`, `gs-maintain-formal-verification-skill`, `gs-statechart`, and `gs-qa-scenarios`. The agent can also start the other skills when a request matches their description. Amp has no slash commands and ignores the `disable-model-invocation` flag that sets this, so these fourteen say in their descriptions to run only when you ask for them.

## Install

The skills CLI requires Node.js 22.20 or later.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install one skill into the current project. This example installs `gs-review`.

```bash
npx skills add agoodway/goodstack --skill gs-review
```

Install every skill in this repo. Quote the `*` so the shell passes it to the CLI unchanged.

```bash
npx skills add agoodway/goodstack --skill '*'
```

From a local checkout, pass the directory in place of `agoodway/goodstack`.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-review
npx skills add /path/to/goodstack --skill '*'
```

Add `-g` to install into your user skill directory.

## Sources

Twelve skills are original to this repo: `gs-review`, `gs-review-pr-reply`, `gs-git-commit`, `gs-pull-request`, `gs-change-request`, `gs-pr-show-me`, `gs-qa-scenarios`, `gs-scratch`, `gs-openspec-ship`, `gs-openspec-ship-tickets`, `gs-openspec-review-change`, and `gs-openspec-qa-scenarios`.

The other twenty-five come from skills that other people published. The originals have no `gs-` prefix. Each skill's own `README.md` gives the original's path and commit, and lists every change this repo made.

| Skill | Original | Author | What this repo changed |
|---|---|---|---|
| `gs-arena` | `arena` in pstack | Lauren Tan | Rewritten to run on any harness with subagents |
| `gs-how` | `how` in pstack | Lauren Tan | The skill and its prompts run on any harness |
| `gs-why` | `why` in pstack | Lauren Tan | The skill and its prompts run on any harness |
| `gs-blast-radius` | `blast-radius` in pstack | Lauren Tan | It works without its companion skills |
| `gs-no-comments` | `no-comments` and the `comment-sicko` agent in pstack | Lauren Tan | The agent's rules moved to `gs-find-bad-comments`, which this skill needs. It works without pstack's other companion skills |
| `gs-find-bad-comments` | `no-comments` and the `comment-sicko` agent in pstack | Lauren Tan | The finding half of `no-comments`, as a report in plain voice that changes no file |
| `gs-create-verification-skill` | `create-verification-skill` in pstack | Lauren Tan | The generated skill goes in the current harness's skills directory |
| `gs-maintain-verification-skill` | `maintain-verification-skill` in pstack | Lauren Tan | It finds the target in any harness's skills directory, and reads features one at a time without subagents |
| `gs-create-formal-verification-skill` | `create-formal-verification-skill` in pstack | Lauren Tan | Evidence goes in `.verify/`, and `gs-statechart` is optional |
| `gs-maintain-formal-verification-skill` | `maintain-formal-verification-skill` in pstack | Lauren Tan | It finds the target in any harness's skills directory, and keeps evidence in `.verify/` |
| `gs-statechart` | `statechart` in pstack | Lauren Tan | The name, a description that says when to use it in plain phrases, a rendered chart by default, and run steps for a missing executable bit or mise |
| `gs-sharpen` | `sharpen` in pstack | Lauren Tan | The name |
| `gs-unslop` | `unslop` in pstack | Lauren Tan | The name, and the agent may start it |
| `gs-deslop` | `deslop` in cursor-team-kit | Cursor | The name, and a pointer to `gs-no-comments` |
| `gs-show-me` | `show-me` in HumanLayer's skills | HumanLayer | It opens the HTML file on any operating system, and the agent may start it |
| `gs-pr-comment` | `leaving-pr-comments` in tstack | Theo Browne | Added writing rules and small pictures |
| `gs-council` | `council` in tstack | Theo Browne | It runs on any harness with subagents, and works with fewer than three providers |
| `gs-prototype` | `prototype` in Matt Pocock's skills | Matt Pocock | The name |
| `gs-codebase-design` | `codebase-design` in Matt Pocock's skills | Matt Pocock | One reference file runs without subagents |
| `gs-improve-codebase-architecture` | `improve-codebase-architecture` in Matt Pocock's skills | Matt Pocock | The question loop and glossary handling are written into the skill instead of calling other skills, and it runs without subagents |
| `gs-openspec-to-tickets` | `to-tickets` in Matt Pocock's skills | Matt Pocock | Rebuilt around OpenSpec changes |
| `gs-wait-what` | `bro` in pstack, and `wait-what` in Matt Pocock's skills | Lauren Tan and Matt Pocock | New text that merges both |
| `gs-reflect` | `reflect` in pstack, and `retro` in Matt Pocock's skills | Lauren Tan and Matt Pocock | `retro` becomes a fourth reviewer, and a lesson can become a check or a coding standard |
| `gs-find-bad-tests` | `prune-tests` in Caldo's skills, and `tests.md` and `mocking.md` from `tdd` in Matt Pocock's skills | Maze and Matt Pocock | The finding half of `prune-tests`, as a report that changes no file. `tests.md` adds examples and the traits a rewrite should have, and `mocking.md` adds how to judge a mock |
| `gs-prune-tests` | `prune-tests` in Caldo's skills, and `tests.md` and `mocking.md` from `tdd` in Matt Pocock's skills | Maze and Matt Pocock | Adds a scope, a green baseline, mutation checks, a keep list, batches, and a final report. It finds the tests with `gs-find-bad-tests`. `tests.md` adds the traits of a rewritten test, and `mocking.md` adds where a mock may sit |

The original repos are:

- pstack and cursor-team-kit: https://github.com/cursor/plugins
- Matt Pocock's skills: https://github.com/mattpocock/skills
- HumanLayer's skills: https://github.com/humanlayer/skills
- tstack: https://github.com/t3dotgg/tstack
- Caldo's skills: https://github.com/caldoai/skills

## License

The license is MIT. See `LICENSE`. Each of the twenty-five skills above also keeps its original author's MIT notice in its own `LICENSE` file.
