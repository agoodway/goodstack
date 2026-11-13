# gs-unslop

This skill edits text to remove AI patterns. It scans for the patterns in the skill, then rewrites. It keeps the meaning and matches the intended tone.

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/bc697d0a5a163cec979e362b601e36f5616083fd/pstack/skills/unslop), path `pstack/skills/unslop`, commit `bc697d0a5a163cec979e362b601e36f5616083fd`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory. The file pulled from [themusicman's grabbag](https://github.com/themusicman/grabbag/blob/main/skills/unslop/SKILL.md) matches that commit, and `SKILL.md` in this directory is that text with two changes to its front matter. The skill is named `gs-unslop`, where the original is `unslop`. The `disable-model-invocation` line is removed, so other skills in this repo can tell the agent to use it. The rules are unchanged.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-unslop
```

Install all twenty-two skills.

```bash
npx skills add agoodway/goodstack --skill gs-review --skill gs-openspec-ship-tickets --skill gs-openspec-ship --skill gs-openspec-to-tickets --skill gs-scratch --skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request --skill gs-blast-radius --skill gs-unslop --skill gs-deslop --skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me
```

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-unslop
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-unslop
```

Use it when you want the writing edited for AI patterns. The skill runs when you invoke it by name.
