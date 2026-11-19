# gs-unslop

This skill edits text to remove AI patterns. It scans for the patterns in the skill, then rewrites. It keeps the meaning and matches the intended tone.

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/bc697d0a5a163cec979e362b601e36f5616083fd/pstack/skills/unslop), path `pstack/skills/unslop`, commit `bc697d0a5a163cec979e362b601e36f5616083fd`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory. The file pulled from [themusicman's grabbag](https://github.com/themusicman/grabbag/blob/main/skills/unslop/SKILL.md) matches that commit, and `SKILL.md` in this directory is that text with two changes to its front matter. The skill is named `gs-unslop`, where the original is `unslop`. The `disable-model-invocation` line is removed, so other skills in this repo can tell the agent to use it, and the description adds when to use the skill. The rules are unchanged.

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

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

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
