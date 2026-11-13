# gs-reflect

This skill reviews a finished session and turns what it learned into changes to the agent's environment. Four reviewers read the session in parallel, a synthesizer keeps the findings that will still be true in six months, and each one is routed to the cheapest fix: an automated check, a coding standard, a skill edit, or a pointer in a steering file. Nothing is applied until you approve it.

It combines two skills, both taken from [themusicman's grabbag](https://github.com/themusicman/grabbag).

- `reflect`, by Lauren Tan. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/7054003c3723e82d099fb7620e3bc8d7d63eebc6/pstack/skills/reflect), path `pstack/skills/reflect`, commit `7054003c3723e82d099fb7620e3bc8d7d63eebc6`. It supplies the pipeline: three reviewers with different lenses, a synthesizer, an approval step, and edits routed to skills.
- `retro`, by Matt Pocock. The original source is [mattpocock/skills](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/retro), path `skills/engineering/retro`, commit `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d`. It supplies the environment categories and the rule that a mechanical mistake gets a check, not a paragraph.

Both are MIT licensed. Copyright 2026 Lauren Tan and copyright 2026 Matt Pocock. The full notice is `LICENSE` in this directory.

These parts differ from the sources:

- `retro` becomes a fourth reviewer, the environment lens, in `references/environment-reviewer.md`. Its text is Matt Pocock's categories and reference notes, put into the same prompt shape as the other three.
- A finding can be routed to a check, a coding standard, a pointer or doc, a removal, or wider access to information, as well as to a skill. In `reflect` a rule that a tool could enforce went to the backlog. Here it becomes a check to build.
- Models are chosen in prose. The skill does not read `pstack-models.mdc` or name model slugs.
- Cursor Task tool fields, the Cursor transcript layout, and the references to `create-skill`, `poteto-mode`, and `writing-for-agents` are replaced by instructions any harness can follow.
- Backlog items are listed for you. `reflect` filed them to a tracker without waiting.
- The three original reviewer prompts change in one sentence each, which says what counts as a skill the session used. The synthesizer prompt takes four inputs and has the wider routing table.
- The `agents/openai.yaml` from `retro` is not included.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-reflect
```

Install all twenty-two skills.

```bash
npx skills add agoodway/goodstack --skill gs-review --skill gs-openspec-ship-tickets --skill gs-openspec-ship --skill gs-openspec-to-tickets --skill gs-scratch --skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request --skill gs-blast-radius --skill gs-unslop --skill gs-deslop --skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me
```

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-reflect
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-reflect
```

Run it at the end of a session that went wrong somewhere, or that took longer than it should have. It reviews the current conversation unless you name another session.
