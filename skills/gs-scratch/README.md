# gs-scratch

This skill manages a gitignored `.scratch` directory for temporary project files.

The commands are `/gs-scratch bootstrap`, `/gs-scratch write`, `/gs-scratch edit`, and `/gs-scratch list`.

This skill is original to this repo. An earlier version was called scratchpad and stored files in `.scratchpad`. In this repo the skill name is `gs-scratch`, the commands start with `/gs-scratch`, and the directory is `.scratch`.

## Use cases

- You need a place in the project for notes, drafts, or temporary files that git never picks up.
- You want the agent to write and edit working files in `.scratch` instead of the source tree.

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

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

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
