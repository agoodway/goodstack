# gs-openspec-ship-tickets

This skill ships the tickets that [`gs-openspec-to-tickets`](../gs-openspec-to-tickets) created. Each ticket runs through its own pipeline. The pipeline applies that ticket's scope, verifies it against the acceptance criteria, fixes every verify issue, runs gs-review, fixes every review issue and removes the tests and comments the review lists, and commits. Tickets run in blocking order. When a change's last ticket lands, the change gets a full `openspec-verify-change`, fixes, a spec sync, and an archive. The run ends with one draft pull request that references every ticket shipped. When the project has a `verify-*` skill, the run then asks whether to run it, so you can see the change working in the real app.

Default mode is serial. One ticket runs at a time in the current checkout, with one subagent per step. It follows [`gs-openspec-ship`](../gs-openspec-ship), and it runs once per ticket.

Thread mode uses `--threads`. Each ticket runs in a T3 Code child thread that has its own worktree, in an Amp orb, or in a background subagent with its own worktree on harnesses that support one. Children run in parallel. `--parallel` sets the cap, and the default is 3. Children push ticket branches, and the orchestrator cherry-picks them onto the run branch.

The tracker decides which tickets are done. Supported trackers are GitHub, Linear, Jira, and local markdown. The orchestrator moves tickets to in progress, comments commits and the pull request URL, and labels blocked tickets `needs-info`. Tickets close when the pull request merges.

## Use cases

- You have tickets from `gs-openspec-to-tickets` and want them shipped in blocking order, each one applied, verified, reviewed, and committed.
- You want independent tickets built in parallel in separate worktrees, threads, or orbs, then combined into one draft pull request.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-openspec-ship-tickets
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-openspec-ship-tickets
```

Add `-g` to install into your user skill directory instead of the current project.

It needs `openspec-apply-change`, `openspec-verify-change`, `openspec-archive-change`, and `openspec-sync-specs` from OpenSpec, plus `gs-review`, `gs-git-commit`, and `gs-pull-request` from this repo. `gs-find-bad-tests` and `gs-find-bad-comments` are optional. With them installed, gs-review finds the tests and comments to remove more thoroughly. You also need the CLI or MCP for your tracker. Amp thread mode needs these skills installed in the project, because an orb sees only project skills.

## Usage

```
/gs-openspec-ship-tickets [change-id | ticket ...] [--threads] [--parallel <n>] [--store <id>]
```

These examples name a change, two tickets, or two changes in thread mode.

```
/gs-openspec-ship-tickets add-account-invites
/gs-openspec-ship-tickets ENG-123 ENG-124
/gs-openspec-ship-tickets add-account-invites add-invite-emails --threads --parallel 4
```

Run it in the repo that contains `openspec/changes/`. With no argument, the skill lists the active changes that have a `tickets.md` and asks which to ship.
