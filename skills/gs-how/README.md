# gs-how

This skill explains how a subsystem works. It covers the runtime flow, where the code lives, and the parts that are easy to miss.

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a/pstack/skills/how), path `pstack/skills/how`, commit `ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory. `SKILL.md` and the prompts in `references` are adapted from that text so the skill runs on any harness. The steps, prompts, and output format are the same. These parts changed:

- Models are chosen in prose. The skill no longer reads the `pstack-models.mdc` rule or names model slugs.
- Cursor Task tool fields and their fallback rules are gone. The skill uses the harness's subagent tools, and does the work in the session when there are none.
- The reference to the `poteto-mode` skill is gone.
- The explainer prompt no longer names Cursor's file tools.

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

Install all twenty-two skills.

```bash
npx skills add agoodway/goodstack --skill gs-review --skill gs-openspec-ship-tickets --skill gs-openspec-ship --skill gs-openspec-to-tickets --skill gs-scratch --skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request --skill gs-blast-radius --skill gs-unslop --skill gs-deslop --skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me
```

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
