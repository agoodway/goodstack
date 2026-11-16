# gs-deslop

This skill checks the diff against main and removes AI-generated slop introduced in the branch.

Cursor wrote this skill. The original source is the cursor-team-kit plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/b21ab167c8d6aad6e4d91bc0de429eedd49665ed/cursor-team-kit/skills/deslop), path `cursor-team-kit/skills/deslop`, commit `b21ab167c8d6aad6e4d91bc0de429eedd49665ed`. The license is MIT. Copyright 2026 Cursor. The full notice is `LICENSE` in this directory. Grabbag records that source in [SOURCE.md](https://github.com/themusicman/grabbag/blob/main/skills/deslop/SOURCE.md). The file pulled from [themusicman's grabbag](https://github.com/themusicman/grabbag/blob/main/skills/deslop/SKILL.md) matches that commit, and `SKILL.md` in this directory is that text with one change: the skill is named `gs-deslop`, where the original is `deslop`.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-deslop
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-deslop
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-deslop
```

Use it to remove AI-generated slop from the branch diff against main.
