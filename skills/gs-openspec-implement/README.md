# gs-openspec-implement

This skill implements one or more OpenSpec changes through a fixed pipeline. It rebases the current branch onto the remote's default branch, then applies, verifies, fixes every verify issue, runs gs-review, fixes every review issue and removes the tests and comments the review lists, archives after syncing specs, and commits. It makes one commit per change and stops there. It does not push and does not open a pull request, so you choose how the commits land.

## Use cases

- You have OpenSpec changes ready to build and want each one applied, verified, reviewed, archived, and committed without running every step by hand.
- You want a batch of OpenSpec changes committed on a branch rebased onto the default branch, and you will push, open the pull request, or open the change request yourself.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-openspec-implement
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-openspec-implement
```

Add `-g` to install into your user skill directory instead of the current project.

It needs `openspec-apply-change`, `openspec-verify-change`, `openspec-archive-change`, and `openspec-sync-specs` from OpenSpec, plus `gs-review` and `gs-git-commit` from this repo. `gs-find-bad-tests` and `gs-find-bad-comments` are optional. With them installed, gs-review finds the tests and comments to remove more thoroughly.

## Usage

```
/gs-openspec-implement [change-id ...]
```

This example implements one change.

```
/gs-openspec-implement add-account-invites
```

Run it in the app repo that contains `openspec/changes/`. If no change name is given, the skill lists active changes and asks which ones to implement. An optional `--store <id>` is passed through to every OpenSpec command.
