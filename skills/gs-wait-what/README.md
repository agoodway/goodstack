# gs-wait-what

This skill makes the agent say its last message again in plain language. It starts with a little context, then restates the message in short sentences without jargon.

It combines two skills, both taken from [themusicman's grabbag](https://github.com/themusicman/grabbag).

- `bro`, by Lauren Tan. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/99559f2f52047978602ef365589275831e76af07/pstack/skills/bro), path `pstack/skills/bro`, commit `99559f2f52047978602ef365589275831e76af07`. It asks for a simpler, shorter restatement with no jargon.
- `wait-what`, by Matt Pocock. The original source is [mattpocock/skills](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/productivity/wait-what), path `skills/productivity/wait-what`, commit `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d`. It asks for context first, Simplified Technical English, and the repo's glossary terms.

Both are MIT licensed. Copyright 2026 Lauren Tan and copyright 2026 Matt Pocock. The full notice is `LICENSE` in this directory.

`SKILL.md` is new text that keeps both sets of instructions and runs on any harness. These parts differ from the sources:

- The rules of ASD-STE100 Simplified Technical English are written out as plain instructions, so the agent does not need to know the standard by name.
- The glossary is optional. The skill uses one if the repo has it, and does not require `GLOSSARY.md` or `GLOSSARY-MAP.md`.
- Matt Pocock's `agents/openai.yaml` is not included.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. The `disable-model-invocation` line is removed, so the agent may start it.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-wait-what
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-wait-what
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-wait-what
```

Use it when the agent's last message was too dense, too full of jargon, or assumed context you do not have.
