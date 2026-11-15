# goodstack

This repo publishes twenty-two agent skills. They review and ship code, explain a codebase, test a design before you build it, and edit prose. Each skill installs on its own with the skills CLI. The source is `agoodway/goodstack`.

The skills are written to run in Claude Code, Codex, Cursor, Amp, and any other harness that reads skills. Two skills name specific tools for an optional feature, and each says what it does without them. `gs-review` names the Codex, Grok, and Claude tools it can ask for a second opinion. `gs-openspec-ship-tickets` names T3 Code, Amp, and Claude Code for its thread mode.

Every skill name starts with `gs-`, so a skill from this repo never overwrites a same-named skill from another source.

## Skills

### Review and ship

- `gs-review` reviews a change for what will break in production. Specialist reviewers raise findings, and a second model tries to refute each one. A project can shape its own reviews with an optional `REVIEW.md`.
- `gs-review-pr-reply` posts a `gs-review` report to the current branch's pull request as one GitHub review.
- `gs-git-commit` commits the current changes with conventional messages. It skips secrets and generated files, and it adds no AI attribution.
- `gs-pull-request` opens a draft GitHub pull request. The description says what changed, how it works, what was run, and what could break.
- `gs-pr-comment` writes and posts a GitHub comment for you. Each comment opens with a note naming the model and the user it speaks for.
- `gs-pr-show-me` explains what an existing pull request changes, in plain language with small pictures. It reads the pull request and posts nothing.

### OpenSpec

- `gs-openspec-ship` takes each named OpenSpec change through apply, verify, review, archive, and commit. It rebases onto the remote's default branch first, and it opens one draft pull request at the end.
- `gs-openspec-to-tickets` breaks OpenSpec changes into tickets that each cut through every layer. It publishes them to GitHub, Linear, Jira, or local markdown.
- `gs-openspec-ship-tickets` ships those tickets in blocking order, one pipeline per ticket. It archives each finished change and opens one draft pull request.

### Understand code

- `gs-how` explains how a subsystem works. It covers the runtime flow and where the code lives.
- `gs-why` investigates why code is shaped the way it is. It cites what it finds in git history, tickets, docs, and chat.
- `gs-blast-radius` finds what a change could break outside the diff. It names the one fact the change is safe because of, and it proves that fact by running code.

### Design

- `gs-arena` runs several attempts at the same task in parallel. It picks one as the base and grafts the strongest parts of the others into it.
- `gs-prototype` builds a throwaway prototype to answer one design question. Logic gets a clickable HTML file. A screen gets several variants you can switch between.
- `gs-codebase-design` gives the agent a fixed vocabulary for designing deep modules. It also says how to deepen shallow modules and how to compare interface designs.
- `gs-sharpen` makes a task deeper, not bigger, and then rewrites your prompt.

### Write and explain

- `gs-unslop` edits text to remove AI writing patterns.
- `gs-deslop` removes AI-generated code slop from the branch's diff.
- `gs-show-me` explains the current topic with the smallest picture that fits. The picture is a tree, a diagram, a diff, or one HTML file.
- `gs-wait-what` makes the agent say its last message again in plain language, with the context you are missing.

### Housekeeping

- `gs-reflect` reviews a finished session with four reviewers. It routes each lasting lesson to a check, a coding standard, a skill edit, or a pointer in a steering file.
- `gs-scratch` manages a gitignored `.scratch` directory for temporary project files. The commands are `/gs-scratch bootstrap`, `/gs-scratch write`, `/gs-scratch edit`, and `/gs-scratch list`.

### Who starts a skill

Ten skills run only when you type the command: `gs-arena`, `gs-blast-radius`, `gs-how`, `gs-why`, `gs-reflect`, `gs-sharpen`, `gs-wait-what`, `gs-openspec-ship`, `gs-openspec-to-tickets`, and `gs-openspec-ship-tickets`. The agent can also start the other skills when a request matches their description.

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

Install all twenty-two skills.

```bash
npx skills add agoodway/goodstack --skill gs-review --skill gs-openspec-ship-tickets --skill gs-openspec-ship --skill gs-openspec-to-tickets --skill gs-scratch --skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request --skill gs-blast-radius --skill gs-unslop --skill gs-deslop --skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me
```

From a local checkout, pass the directory in place of `agoodway/goodstack`.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-review
npx skills add /path/to/goodstack --skill gs-review --skill gs-openspec-ship-tickets --skill gs-openspec-ship --skill gs-openspec-to-tickets --skill gs-scratch --skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request --skill gs-blast-radius --skill gs-unslop --skill gs-deslop --skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me
```

Add `-g` to install into your user skill directory.

## Sources

Eight skills are original to this repo: `gs-review`, `gs-review-pr-reply`, `gs-git-commit`, `gs-pull-request`, `gs-pr-show-me`, `gs-scratch`, `gs-openspec-ship`, and `gs-openspec-ship-tickets`.

The other fourteen come from skills that other people published. The originals have no `gs-` prefix. Each skill's own `README.md` gives the original's path and commit, and lists every change this repo made.

| Skill | Original | Author | What this repo changed |
|---|---|---|---|
| `gs-arena` | `arena` in pstack | Lauren Tan | Rewritten to run on any harness with subagents |
| `gs-how` | `how` in pstack | Lauren Tan | The skill and its prompts run on any harness |
| `gs-why` | `why` in pstack | Lauren Tan | The skill and its prompts run on any harness |
| `gs-blast-radius` | `blast-radius` in pstack | Lauren Tan | It works without its companion skills |
| `gs-sharpen` | `sharpen` in pstack | Lauren Tan | The name |
| `gs-unslop` | `unslop` in pstack | Lauren Tan | The name, and the agent may start it |
| `gs-deslop` | `deslop` in cursor-team-kit | Cursor | The name |
| `gs-show-me` | `show-me` in HumanLayer's skills | HumanLayer | It opens the HTML file on any operating system, and the agent may start it |
| `gs-pr-comment` | `leaving-pr-comments` in tstack | Theo Browne | Added writing rules and small pictures |
| `gs-prototype` | `prototype` in Matt Pocock's skills | Matt Pocock | The name |
| `gs-codebase-design` | `codebase-design` in Matt Pocock's skills | Matt Pocock | One reference file runs without subagents |
| `gs-openspec-to-tickets` | `to-tickets` in Matt Pocock's skills | Matt Pocock | Rebuilt around OpenSpec changes |
| `gs-wait-what` | `bro` in pstack, and `wait-what` in Matt Pocock's skills | Lauren Tan and Matt Pocock | New text that merges both |
| `gs-reflect` | `reflect` in pstack, and `retro` in Matt Pocock's skills | Lauren Tan and Matt Pocock | `retro` becomes a fourth reviewer, and a lesson can become a check or a coding standard |

The original repos are:

- pstack and cursor-team-kit: https://github.com/cursor/plugins
- Matt Pocock's skills: https://github.com/mattpocock/skills
- HumanLayer's skills: https://github.com/humanlayer/skills
- tstack: https://github.com/t3dotgg/tstack

## License

The license is MIT. See `LICENSE`. Each of the fourteen skills above also keeps its original author's MIT notice in its own `LICENSE` file.
