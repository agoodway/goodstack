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

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

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
