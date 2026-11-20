# gs-pull-request

This skill opens a draft GitHub pull request for the current branch. The description is written for a reader who did not make the change. It says what changed, shows the smallest picture of how it works, records the evidence, and names what could break.

It does not commit unless you pass `--commit`. Without the flag, a dirty tree stops the skill and points at `/gs-git-commit`. With it, the skill commits the changes first, through `gs-git-commit` when that skill is installed, then opens the pull request.

When a project verification skill left a run in `.verify/<app>/<run-id>/` for the branch's current code, the Evidence section uses it. It names the features the run drove and what passed, inlines short text proof, and attaches the screenshots with `gh --attach`, which uploads them into the description. With a `gh` that has no `--attach`, the skill lists the screenshots by path and tells you which ones to drag in. It ignores runs for other commits and runs built from a dirty working tree, and it never commits the evidence.

## Use cases

- Your branch is committed and you want a draft pull request whose description a reviewer can follow without reading the diff first.
- You already approved the title and body, and you want the pull request opened without another confirmation step.
- You have uncommitted changes, and you want them committed and the pull request opened in one step.

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

Requires the `gh` CLI, installed and authenticated. With `--commit`, it uses the `gs-git-commit` skill when that skill is installed, and follows a short commit rule of its own when it is not.

## Usage

Run `/gs-git-commit` first when the working tree is dirty, or pass `--commit` to commit as part of the run.

```
/gs-pull-request
/gs-pull-request --commit
/gs-pull-request --commit --approved
```

The skill prints the title and body and waits for approval, then pushes the branch and opens a draft pull request. It updates an existing pull request for the branch instead of opening a second one. A request that includes `--approved`, or plainly says the pull request is already approved, skips that wait, opens or updates the draft, and then prints the title, the body, and the URL. A request that includes `--commit` commits the working tree before it writes the description. The two flags combine.

## Source

The picture types come from Dex Horthy's show-me skill. The door and reach section follows the pull-request template in Matt Pocock's skills and the `gs-blast-radius` skill in this repo. The prose follows the `gs-unslop` skill in this repo. The `gs-show-me` skill is in this repo. The Matt Pocock template stays outside it.
