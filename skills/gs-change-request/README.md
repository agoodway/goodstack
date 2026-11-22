# gs-change-request

This skill writes the description file for a goodflows change request, which replaces a pull request on any Git host. The body follows `gs-pull-request`: it is written for a reader who did not make the change, says what changed, shows the smallest picture of how it works, records the evidence, and names what could break. It adds the questions the reviewer must answer and the few hunks the reviewer should judge.

The file opens with `change-claims/2` YAML front matter that goodflows parses. The front matter names the commit the claims describe, the door, the reach, each fact the change is safe because of, with how far it was proven and the evidence that proves it, the open risks, the questions, and the decision hunks copied from the real diff.

By default the skill only writes the file. With `--approved`, it also hands the file to the goodflows CLI, which creates the change request, or updates it when the file already holds a change request number. It takes the commands from `gs-change-request-ship` when that skill is installed, and validates the file before it uploads it. Without that skill, it reads the CLI's own help for the command. It stops with the file kept when the CLI is missing. It never pushes, opens a pull request, or calls a host API itself.

It does not commit unless you pass `--commit`. Without the flag, a dirty tree stops the skill and points at `/gs-git-commit`, because the claims describe one commit. With it, the skill commits the changes first, through `gs-git-commit` when that skill is installed, and the claims describe the new commit. It writes to `.goodflows/change-requests/<branch>/cr.md`, where each `/` in the branch name becomes a directory, so no two branches share a file or block each other's directory. It keeps that directory out of git through `.git/info/exclude`, so the file never changes the commit it describes. When the head moves and the change does not, such as after a clean rebase, it rewrites only `head`.

This skill is original to this repo. It calls other skills from this repo when they are installed, and it follows a short set of fallback rules when they are not.

## Use cases

- Your branch is committed and you want a change request description a reviewer can follow without reading the diff first, with each claim tied to its evidence and, for an OpenSpec change, to the requirement it covers.
- You rebased a branch whose change request already exists, and the claims need to name the new head.
- You already approved the claims, and you want the change request created or updated through the goodflows CLI in the same step.

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

Commit first, or pass `--commit`. Without the flag, a dirty working tree stops the skill.

```
/gs-change-request
/gs-change-request --approved
/gs-change-request --commit
/gs-change-request --commit --approved
```

The skill prints the path of the file, the commit it describes, and whether it wrote new claims or only rewrote `head`. A request that includes `--approved`, or plainly says the change request is already approved, then creates or updates the change request through the goodflows CLI and prints its number.

A request that includes `--commit` commits the working tree before it writes the file. The two flags combine.

With `--approved`, the `goodflows` CLI must be installed. With `--commit`, the skill uses the `gs-git-commit` skill when that skill is installed, and follows a short commit rule of its own when it is not.

## Source

The description sections, the verify-run rule, and the rule never to invent evidence come from the `gs-pull-request` skill in this repo. The proof scale comes from the `gs-blast-radius` skill in this repo.
