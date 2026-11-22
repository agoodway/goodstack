---
name: gs-openspec-to-tickets
description: "Publish one ticket per OpenSpec change to the project's tracker (GitHub, Linear, Jira, or local markdown), with a blocking edge wherever one change builds on another, so independent changes can run in parallel. Use when the user asks to turn OpenSpec changes into tickets or issues, runs /gs-openspec-to-tickets, or names gs-openspec-to-tickets. Only when the user asks for it."
disable-model-invocation: true
---

# OpenSpec to Tickets

Publish one **ticket** per OpenSpec change. A ticket is the whole change. When several changes are named, each ticket declares the changes that **block** it, and every other pair of changes stays free to run in parallel.

## Input

```text
/gs-openspec-to-tickets <change> [<change> ...]
```

Also accept a prose list of change names. When no change is named, run `openspec list --json` and ask which active changes to ticket (several may be picked). A name that is not an active change is reported as not found; continue with the rest.

## Process

### 1. Gate each change

For each named change:

- Run `openspec validate <change>`. A change that fails is reported with the errors and dropped from the run.
- If `openspec/changes/<change>/tickets.md` exists, the change is already ticketed. Report the path and drop it. Re-ticketing is the user's call: they delete `tickets.md` and rerun.

Done when every named change is either in the run or reported as dropped. Stop if none remain.

### 2. Resolve the tracker

Read `AGENTS.md`, then `CLAUDE.md`, and follow any doc they point at for the issue tracker (Matt Pocock's layout puts it at `docs/agents/issue-tracker.md`). Look for the tracker and its target: the GitHub repo, the Linear team, the Jira project key.

When no tracker is named, ask the user which one: **GitHub**, **Linear**, **Jira**, or **local markdown**. Ask for the target too when the tracker needs one and it is not discoverable. Then offer once to record the answer in whichever of `AGENTS.md` / `CLAUDE.md` exists (`AGENTS.md` when neither does), as:

```markdown
## Agent skills

### Issue tracker

[Tracker and target, e.g. "Linear, team ENG"]. Tickets come from `/gs-openspec-to-tickets`.
```

Update an existing `## Agent skills` block in place rather than appending a second one.

Read the matching tracker file now; it holds the commands for every later step that touches the tracker:

- GitHub: [tracker-github.md](tracker-github.md)
- Linear: [tracker-linear.md](tracker-linear.md)
- Jira: [tracker-jira.md](tracker-jira.md)
- Local markdown: [tracker-local.md](tracker-local.md)

Any other tracker the user names: ask them to describe in a paragraph how to create an issue, link a blocker, and apply a label, then follow that description.

### 3. Resolve the labels

The triage labels are Matt Pocock's defaults:

| Role              | Default label     | Meaning                                  |
| ----------------- | ----------------- | ---------------------------------------- |
| `needs-triage`    | `needs-triage`    | Maintainer needs to evaluate this issue  |
| `needs-info`      | `needs-info`      | Waiting on reporter for more information |
| `ready-for-agent` | `ready-for-agent` | Fully specified, ready for an AFK agent  |
| `ready-for-human` | `ready-for-human` | Requires human implementation            |
| `wontfix`         | `wontfix`         | Will not be actioned                     |

When `docs/agents/triage-labels.md` exists, its mapping overrides the label strings. This skill applies only `ready-for-agent` and `ready-for-human`.

### 4. Read each change

Read the whole change: `proposal.md`, `design.md` when present, every spec delta under `specs/`, and `tasks.md`.

List every **scenario** in the spec deltas: each `#### Scenario:` under an ADDED or MODIFIED requirement, plus each REMOVED requirement. These become the ticket's acceptance criteria.

### 5. Draft the tickets

Draft one ticket per change. Each ticket carries:

- **Title**: the change's title, short, in the domain vocabulary
- **Change**: the OpenSpec change it stands for
- **Blocked by**: the changes that must land before this one can start
- **Why** and **What changes**: the proposal's sections, condensed
- **Acceptance criteria**: every scenario from step 4, its WHEN/THEN restated as a checkbox
- **Label**: `ready-for-human` when the change needs a person (credentials, a third-party dashboard, a product or design decision), else `ready-for-agent`

Change B is **blocked by** change A only when B cannot be built or verified until A lands:

- B uses a capability, schema, interface, or data that A adds.
- B's spec deltas modify or remove a requirement that A adds or modifies.
- B's proposal or design names A as a prerequisite.

Leave every other pair unblocked. Two changes that edit the same files but do not build on each other get no edge: the conflict is resolved when they are integrated, and an edge would make them run one after the other. Add no edge to make an order tidy.

Look for blockers among the changes in this run and among the active changes that already have a `tickets.md`. A blocker with a `tickets.md` is linked to the ticket that file names. A change that depends on an active change with no `tickets.md`, outside this run, gets no edge. Report that dependency in step 6, so the user can add the other change to the run. An archived change has already landed and blocks nothing.

The edges form no cycle. When two changes each need the other, report the cycle in step 6 and ask the user which edge to drop or which changes to merge.

Done when every change in the run has one drafted ticket, and every edge points at a change that genuinely gates it.

### 6. Ask the user to approve

Present the tickets as a numbered list. For each one show its title, blocked by, label, and the number of acceptance criteria. Below the list, show the groups of changes that can run in parallel, in the order the edges allow. Then report any dependency on an unticketed change and any cycle. Ask:

- Are the blocking edges correct? Is one missing, or does one hold back work that could run in parallel?
- Is each `ready-for-human` call right?

Iterate until the user approves. Nothing is published before approval.

### 7. Publish

Ensure the labels exist first. List any label the tracker lacks, confirm once, then create them per the tracker file.

Publish the tickets in dependency order, blockers first, so each blocking edge can reference a real identifier. Work the **frontier**: any ticket whose blockers are all published. Each ticket gets its label, and links its blockers natively where the tracker supports it.

Done when every approved ticket exists on the tracker with its label and blockers.

### 8. Write the index

Write `openspec/changes/<change>/tickets.md` for each published change. Leave every other file in the change untouched.

```markdown
# Tickets: <change>

Tracker: <tracker and target>

| Ticket           | Title   | Label           | Blocked by                   |
| ---------------- | ------- | --------------- | ---------------------------- |
| <ID/URL or path> | <title> | ready-for-agent | None, or <change>, <change>  |
```

The table has one row. `Blocked by` lists change names.

Then report to the user: each change's ticket link and blockers, the groups that can run in parallel, and any change dropped in step 1.

## Template

Ticket bodies avoid file paths and code snippets: they go stale fast. The exception is a snippet that encodes a decision more precisely than prose (a state machine, schema, or type shape) from the change's design; trim it to the decision-rich part.

<issue-template>

## Why

The proposal's Why, condensed.

## What changes

The proposal's What Changes, condensed, as the end-to-end behaviour this ticket makes work.

## Acceptance criteria

- [ ] WHEN … THEN … (from `<Requirement>: <Scenario>`)
- [ ] …

## OpenSpec

Change `<change>`. This ticket is the whole change.

## Blocked by

A reference to each blocking ticket, or "None (can start immediately)". Omit this section when blockers were set as native links.

</issue-template>
