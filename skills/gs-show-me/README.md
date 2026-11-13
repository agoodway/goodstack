# gs-show-me

This skill explains the current topic visually. It picks the smallest view that makes the point: pseudocode, a call tree, a component tree, a file tree, a Mermaid diagram, a diff, or one focused HTML file.

HumanLayer wrote this skill. The original source is the show-me plugin in the [HumanLayer skills repository](https://github.com/humanlayer/skills/tree/4d69d20f6e9b57b4fcf0d501ccfb1be961f0f329/plugins/show-me/skills/show-me), path `plugins/show-me/skills/show-me`, commit `4d69d20f6e9b57b4fcf0d501ccfb1be961f0f329`. The license is MIT. Copyright 2026 HumanLayer. The full notice is `LICENSE` in this directory. The file was pulled from [themusicman's grabbag](https://github.com/themusicman/grabbag/blob/main/skills/humanlayer/show-me/SKILL.md), which records it as unmodified from that commit.

`SKILL.md` in this directory is adapted from that text so it runs on any harness and operating system. One part changed: the original opened the HTML file with `Bash(open ...)`, which is Claude Code notation for the macOS `open` command. The skill now uses the harness's preview or browser tool, or the system opener for macOS, Linux, or Windows, and gives the user the path when it cannot open the file. The `disable-model-invocation` line is also removed, so other skills in this repo can tell the agent to use this one. The upstream `agents/openai.yaml` is not included.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-show-me
```

Install all twenty-two skills.

```bash
npx skills add agoodway/goodstack --skill gs-review --skill gs-openspec-ship-tickets --skill gs-openspec-ship --skill gs-openspec-to-tickets --skill gs-scratch --skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request --skill gs-blast-radius --skill gs-unslop --skill gs-deslop --skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me
```

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-show-me
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-show-me
```

Use it when a diagram or a sketch of the code's shape would explain the topic faster than prose.
