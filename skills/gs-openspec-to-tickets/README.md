# gs-openspec-to-tickets

This skill breaks one or more OpenSpec changes into tracer-bullet tickets and publishes them to the project's tracker. Each change gets a parent ticket. Its slices are vertical. Each slice declares the tickets that block it, and blockers can cross changes. Each slice takes its acceptance criteria from the spec-delta scenarios it covers. After you approve the breakdown, the skill publishes in dependency order and writes an index to `openspec/changes/<change>/tickets.md`.

Supported trackers are GitHub with `gh`, Linear with MCP, Jira with the Atlassian MCP or `jira-cli`, and local markdown inside the change directory. The skill reads the tracker from `AGENTS.md` or `CLAUDE.md`. If neither names one, the skill asks and offers to record the answer.

The skill labels tickets with [Matt Pocock's default triage labels](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/triage-labels.md). The label is `ready-for-agent`, or `ready-for-human` when a slice needs a person. A `docs/agents/triage-labels.md` file overrides the label strings.

## Use cases

- You have an OpenSpec change that is too large for one pull request and want it split into vertical slices that each cut through every layer.
- You want tickets in GitHub, Linear, Jira, or local markdown, with blocking order and acceptance criteria taken from the spec scenarios.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-openspec-to-tickets
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-openspec-to-tickets
```

Add `-g` to install into your user skill directory instead of the current project.

It needs the `openspec` CLI, plus the CLI or MCP for your tracker.

## Usage

```
/gs-openspec-to-tickets [change-id ...]
```

This example publishes tickets for two changes.

```
/gs-openspec-to-tickets add-account-invites add-invite-emails
```

Run it in the repo that contains `openspec/changes/`. If no change name is given, the skill lists the active changes and asks which ones to ticket. The skill skips and reports a change that fails `openspec validate`, or that already has a `tickets.md`.

## Source

Matt Pocock wrote the skill this one is adapted from. The original source is `to-tickets` in [mattpocock/skills](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/to-tickets), path `skills/engineering/to-tickets`, commit `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d`. The license is MIT. Copyright 2026 Matt Pocock. The full notice is `LICENSE` in this directory.

`SKILL.md` keeps the original's vertical-slice rules, its exception for wide refactors, its step that asks the user to approve the breakdown, and its issue template. These parts changed:

- The skill is named `gs-openspec-to-tickets`, where the original is `to-tickets`.
- The input is one or more OpenSpec changes. The original takes a plan, a spec, or the conversation.
- A new first step drops a change that fails `openspec validate` or that already has a `tickets.md`.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. It ends by saying to run only when the user asks for it.
- The skill finds the tracker itself, from `AGENTS.md` or `CLAUDE.md`, and asks when neither names one. The original relied on `/setup-matt-pocock-skills`.
- Four new files hold the commands for GitHub, Linear, Jira, and local markdown.
- The triage labels are written into the skill, and a slice that needs a person gets `ready-for-human`.
- Each change gets a parent ticket, and a slice can be blocked by a ticket from another change.
- Acceptance criteria come from the spec-delta scenarios, and every scenario must be covered by a ticket.
- Local tickets live in the change directory under `tickets/`. The original wrote them under `.scratch/`.
- A new last step writes the `tickets.md` index.
- The upstream `agents/openai.yaml` is not included.
