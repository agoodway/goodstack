# gs-openspec-review-change

This skill quick-reviews an OpenSpec change and fixes what it finds. Two specialists review the change. One checks structure and consistency with other specs, and the other checks the change against the codebase. The skill patches every finding that has one obvious fix, then resolves the findings that need a design decision.

Auto mode is the default. In auto mode, the skill applies the recommended answer to each design question and records why it chose it. It skips a question when only the author's intent can settle it. Ask mode runs only when you ask for it, and it asks you one question at a time.

The skill edits only files inside the change directory: `proposal.md`, `design.md`, `tasks.md`, and the delta specs. It writes its report to `openspec/changes/<change-id>/review-change.md`. It never edits source code, commits, or changes branches.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-openspec-review-change
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-openspec-review-change
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-openspec-review-change [change-id] [ask]
```

This example reviews one change in auto mode.

```
/gs-openspec-review-change add-account-invites
```

This example asks you each design question instead.

```
/gs-openspec-review-change add-account-invites, ask me
```

Run it in the app repo that contains `openspec/changes/`. If no change is named, the skill lists active changes and asks which one to review. A missing change id is always your choice, even in auto mode.

## Modes

| Mode | Behavior |
|------|----------|
| `auto` | The default. Patches mechanical findings, applies the recommended answer to each design question, and records the rationale. |
| `ask` | Runs when you say "ask", "ask me", "interactive", or `--ask`. Patches mechanical findings, then asks one design question at a time and applies your answer. |

When the harness has no subagent tools, the skill runs both specialist passes itself, one after the other, re-reading the change before each.
