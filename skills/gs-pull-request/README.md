# gs-pull-request

This skill opens a draft GitHub pull request for the current branch. The description is written for a reader who did not make the change. It says what changed, shows the smallest picture of how it works, records the evidence, and names what could break.

The picture types come from Dex Horthy's show-me skill. The door and reach section follows the pull-request template in Matt Pocock's skills and the `gs-blast-radius` skill in this repo. The prose follows the `gs-unslop` skill in this repo. The `gs-show-me` skill is in this repo. The Matt Pocock template stays outside it.

It does not commit. A dirty tree stops the skill and points at `/gs-git-commit`.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-pull-request
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-pull-request
```

Add `-g` to install into your user skill directory instead of the current project.

Requires the `gh` CLI, installed and authenticated, and the `gs-git-commit` skill when the tree still needs a commit.

## Usage

Run `/gs-git-commit` first when the working tree is dirty.

```
/gs-pull-request
```

The skill prints the title and body and waits for approval, then pushes the branch and opens a draft pull request. It updates an existing pull request for the branch instead of opening a second one.
