# gs-openspec-implement-tickets

This skill implements the tickets that [`gs-openspec-to-tickets`](../gs-openspec-to-tickets) created, one ticket per OpenSpec change. Each ticket runs through its own pipeline. The pipeline applies the change, verifies it with `openspec-verify-change`, fixes every verify issue, runs gs-review, fixes every review issue and removes the tests and comments the review lists, and commits. Tickets run in blocking order. When a ticket lands, its change gets a spec sync and an archive. The run stops after the commits. It opens no pull request, and its summary gives each landed ticket's closing reference for the pull request or change request you open next.

Default mode is serial. One ticket runs at a time in the current checkout, with one subagent per step. It follows [`gs-openspec-implement`](../gs-openspec-implement), and it runs once per ticket.

Thread mode uses `--threads`. Each ticket runs in a T3 Code child thread that has its own worktree, in an Amp orb, or in a background subagent with its own worktree on harnesses that support one. Children run in parallel. `--parallel` sets the cap, and the default is 3. Children push ticket branches, and the orchestrator cherry-picks them onto the run branch.

The tracker decides which tickets are done. Supported trackers are GitHub, Linear, Jira, and local markdown. The orchestrator moves tickets to in progress, comments commits, and labels blocked tickets `needs-info`. Tickets close when the pull request merges.

## Use cases

- You have tickets from `gs-openspec-to-tickets` and want them implemented in blocking order, each one applied, verified, reviewed, and committed.
- You want independent tickets built in parallel in separate worktrees, threads, or orbs, then combined onto one branch.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-openspec-implement-tickets
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-openspec-implement-tickets
```

Add `-g` to install into your user skill directory instead of the current project.

It needs `openspec-apply-change`, `openspec-verify-change`, `openspec-archive-change`, and `openspec-sync-specs` from OpenSpec, plus `gs-review` and `gs-git-commit` from this repo. `gs-find-bad-tests` and `gs-find-bad-comments` are optional. With them installed, gs-review finds the tests and comments to remove more thoroughly. You also need the CLI or MCP for your tracker. Amp thread mode needs these skills installed in the project, because an orb sees only project skills.

## Usage

```
/gs-openspec-implement-tickets [change-id | ticket ...] [--threads] [--parallel <n>] [--store <id>]
```

These examples name a change, two tickets, or two changes in thread mode.

```
/gs-openspec-implement-tickets add-account-invites
/gs-openspec-implement-tickets ENG-123 ENG-124
/gs-openspec-implement-tickets add-account-invites add-invite-emails --threads --parallel 4
```

Run it in the repo that contains `openspec/changes/`. With no argument, the skill lists the active changes that have a `tickets.md` and asks which to implement.
