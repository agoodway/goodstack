# gs-how

This skill explains how a subsystem works. It covers the runtime flow, where the code lives, and the parts that are easy to miss.

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a/pstack/skills/how), path `pstack/skills/how`, commit `ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory. `SKILL.md` and the prompts in `references` are adapted from that text so the skill runs on any harness. The steps, prompts, and output format are the same. These parts changed:

- Models are chosen in prose. The skill no longer reads the `pstack-models.mdc` rule or names model slugs.
- Cursor Task tool fields and their fallback rules are gone. The skill uses the harness's subagent tools, and does the work in the session when there are none.
- The reference to the `poteto-mode` skill is gone.
- The explainer prompt no longer names Cursor's file tools.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. The `disable-model-invocation` line is removed, so the agent may start it.

The instructions name the companion `gs-why` skill, which is in this repo.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-how
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-how
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-how
```

Use it for how something works, a walkthrough before a change, or a question about where code should live.
