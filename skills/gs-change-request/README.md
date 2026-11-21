# gs-change-request

This skill writes the description file for a goodflows change request, which replaces a pull request on any Git host. The body follows `gs-pull-request`: it is written for a reader who did not make the change, says what changed, shows the smallest picture of how it works, records the evidence, and names what could break. It adds the questions the reviewer must answer and the few hunks the reviewer should judge.

The file opens with `change-claims/1` YAML front matter that goodflows parses. The front matter names the commit the claims describe, the door, the reach, each fact the change depends on with how far it was proven, the open risks, the questions, and the decision hunks copied from the real diff.

The skill only writes the file. It never pushes, opens a pull request, or calls a host API. Uploading the file is the goodflows CLI's job. It writes to `.goodflows/change-requests/<branch>.md` and keeps that directory out of git through `.git/info/exclude`, so the file never changes the commit it describes. When the head moves and the change does not, such as after a clean rebase, it rewrites only `head`.

This skill is original to this repo. It calls other skills from this repo when they are installed, and it follows a short set of fallback rules when they are not.

## Use cases

- Your branch is committed and you want a change request description a reviewer can follow without reading the diff first.
- You rebased a branch whose change request already exists, and the claims need to name the new head.
- You want the facts a change depends on, its open risks, and the decisions a reviewer should judge in a form a tool can read.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-change-request
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-change-request
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

Commit first. A dirty working tree stops the skill.

```
/gs-change-request
```

The skill prints the path of the file, the commit it describes, and whether it wrote new claims or only rewrote `head`.

## Source

The description sections, the verify-run rule, and the rule never to invent evidence come from the `gs-pull-request` skill in this repo. The proof scale comes from the `gs-blast-radius` skill in this repo.
