# gs-openspec-to-tickets

This skill publishes one ticket per OpenSpec change to the project's tracker. The ticket is the whole change, and its acceptance criteria are the scenarios in the change's spec deltas. When you name several changes, a ticket is blocked by another only when its change builds on the other, so every other change can run in parallel. After you approve the tickets and their blocking edges, the skill publishes in dependency order and writes an index to `openspec/changes/<change>/tickets.md`.

Supported trackers are GitHub with `gh`, Linear with MCP, Jira with the Atlassian MCP or `jira-cli`, and local markdown inside the change directory. The skill reads the tracker from `AGENTS.md` or `CLAUDE.md`. If neither names one, the skill asks and offers to record the answer.

The skill labels tickets with [Matt Pocock's default triage labels](https://github.com/mattpocock/skills/blob/main/skills/engineering/setup-matt-pocock-skills/triage-labels.md). The label is `ready-for-agent`, or `ready-for-human` when a change needs a person. A `docs/agents/triage-labels.md` file overrides the label strings.

## Use cases

- You have several OpenSpec changes and want to know which can be built in parallel and which must wait for another.
- You want each change tracked as one ticket in GitHub, Linear, Jira, or local markdown, with acceptance criteria taken from the spec scenarios.

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

`SKILL.md` keeps the original's blocking edges, its step that asks the user to approve before anything is published, its publishing in dependency order, and the outline of its issue template. These parts changed:

- The skill is named `gs-openspec-to-tickets`, where the original is `to-tickets`.
- The input is one or more OpenSpec changes. The original takes a plan, a spec, or the conversation.
- A new first step drops a change that fails `openspec validate` or that already has a `tickets.md`.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. It ends by saying to run only when the user asks for it.
- The skill finds the tracker itself, from `AGENTS.md` or `CLAUDE.md`, and asks when neither names one. The original relied on `/setup-matt-pocock-skills`.
- Four new files hold the commands for GitHub, Linear, Jira, and local markdown.
- The triage labels are written into the skill, and a change that needs a person gets `ready-for-human`.
- Each change gets one ticket. The original's vertical-slice rules, its exception for wide refactors, and its questions about granularity are removed.
- A ticket is blocked only by another change it builds on, and the skill says which changes can run in parallel.
- Acceptance criteria are every scenario in the change's spec deltas.
- A local ticket lives in the change directory as `ticket.md`. The original wrote tickets under `.scratch/`.
- A new last step writes the `tickets.md` index.
- The upstream `agents/openai.yaml` is not included.
