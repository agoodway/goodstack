# gs-scratch

This skill manages a gitignored `.scratch` directory for temporary project files.

The commands are `/gs-scratch bootstrap`, `/gs-scratch write`, `/gs-scratch edit`, and `/gs-scratch list`.

This skill is original to this repo. An earlier version was called scratchpad and stored files in `.scratchpad`. In this repo the skill name is `gs-scratch`, the commands start with `/gs-scratch`, and the directory is `.scratch`.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-scratch
```

Install all twenty-two skills.

```bash
npx skills add agoodway/goodstack --skill gs-review --skill gs-openspec-ship-tickets --skill gs-openspec-ship --skill gs-openspec-to-tickets --skill gs-scratch --skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request --skill gs-blast-radius --skill gs-unslop --skill gs-deslop --skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me
```

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-scratch
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

`/gs-scratch bootstrap` creates `.scratch` in the project root and adds `.scratch/` to `.gitignore` when that entry is missing.

`/gs-scratch write <filename>` writes `.scratch/<filename>`.

`/gs-scratch edit <filename>` edits a file already in `.scratch`.

`/gs-scratch list` lists the files in `.scratch`.
