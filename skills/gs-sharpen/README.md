# gs-sharpen

This skill makes a task deeper, not bigger, and then rewrites your prompt. Before rewriting, the agent says what a top professional would do that you did not ask for, what raw material they would start from, which methods and tools they would use, and what would show the result is right. It leaves the choices that are yours open.

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/88d47514b82e7c44f00f2b2a72ff6dd12158038c/pstack/skills/sharpen), path `pstack/skills/sharpen`, commit `88d47514b82e7c44f00f2b2a72ff6dd12158038c`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory. The file pulled from [themusicman's grabbag](https://github.com/themusicman/grabbag/blob/main/skills/sharpen/SKILL.md) matches that commit.

`SKILL.md` in this directory is that text with two changes to its front matter. The skill is named `gs-sharpen`, where the original is `sharpen`, and its description is rewritten to say what it does and when to use it. The `disable-model-invocation` line is removed, so the agent may start it. The instructions are unchanged. They name no harness, tool, or model, so they needed no other change.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-sharpen
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-sharpen
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-sharpen
```

Run it on a task or prompt you are about to hand to the agent, when you want a better version of the same task and not a longer one.
