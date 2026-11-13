# gs-openspec-ship

This skill ships one or more OpenSpec changes through a fixed pipeline. It rebases the current branch onto the remote's default branch, then applies, verifies, fixes every verify issue, runs gs-review, fixes every review issue, archives after syncing specs, and commits. After the named changes finish, it opens one draft pull request for the commits from that run.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-openspec-ship
```

Install all twenty-two skills.

```bash
npx skills add agoodway/goodstack --skill gs-review --skill gs-openspec-ship-tickets --skill gs-openspec-ship --skill gs-openspec-to-tickets --skill gs-scratch --skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request --skill gs-blast-radius --skill gs-unslop --skill gs-deslop --skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me
```

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-openspec-ship
```

Add `-g` to install into your user skill directory instead of the current project.

It needs `openspec-apply-change`, `openspec-verify-change`, `openspec-archive-change`, and `openspec-sync-specs` from OpenSpec, plus `gs-review`, `gs-git-commit`, and `gs-pull-request` from this repo.

## Usage

```
/gs-openspec-ship [change-id ...]
```

This example ships one change.

```
/gs-openspec-ship add-account-invites
```

Run it in the app repo that contains `openspec/changes/`. If no change name is given, the skill lists active changes and asks which ones to ship. An optional `--store <id>` is passed through to every OpenSpec command.
