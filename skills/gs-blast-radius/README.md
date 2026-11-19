# gs-blast-radius

This skill finds what a change could break somewhere else before it ships. It looks past the diff, names the one fact the change is safe because of, and proves that fact by running code.

The instructions name the companion skills `gs-how`, `gs-why`, and `gs-unslop`. Those skills are in this repo, and none of them is required.

## Use cases

- You are about to ship a small diff you do not trust, and you want to know what it could break outside the files it touches.
- A reviewer asks what a change could break, and you want the answer proved by running code instead of argued in prose.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-blast-radius
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-blast-radius
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-blast-radius
```

Use it for the blast radius of a change, or when you are reviewing a small diff you do not trust yet.

## Source

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/df581122cde17e6e27686b5a448bde23e4ad4318/pstack/skills/blast-radius), path `pstack/skills/blast-radius`, commit `df581122cde17e6e27686b5a448bde23e4ad4318`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory. The file pulled from [themusicman's grabbag](https://github.com/themusicman/grabbag/blob/main/skills/blast-radius/SKILL.md) matches that commit.

`SKILL.md` in this directory is adapted from that text so the skill works when installed on its own. The original had nothing tied to one harness. The method and the output are the same. These parts changed:

- Step 1 names the `git` and `gh` commands that pull the pull request and its commits. The original sent the agent to the `why` skill for them.
- Step 6 asks several models through the harness's subagent tools, and is skipped when only one model is reachable. The original ran the `arena` skill.
- The writeup goes through `gs-unslop` only if that skill is installed.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. The `disable-model-invocation` line is removed, so the agent may start it.
