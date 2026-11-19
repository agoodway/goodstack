# gs-council

This skill brings in three delegates to review the work or give feedback. Each delegate runs on a strong model from a different provider, and all three run in parallel. The agent checks each result as it arrives, fixes what it agrees with, and asks for a fresh review. It scores every round, and it puts the scores in the pull request description when the work ends in one. It stops when every delegate is satisfied, and it keeps the scope from growing along the way.

## Use cases

- You finished a change and want three reviewers on models from different providers to check it in parallel.
- You want the agent to fix review feedback round after round, with a score for each round, until every reviewer is satisfied.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-council
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-council
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

Say "council" in your request, or call the skill directly.

```
/gs-council
```

## Source

Theo Browne wrote the skill this one is adapted from. The original source is `council` in the [tstack repository](https://github.com/t3dotgg/tstack/tree/11e37a74d0a6868c121cd0910ab2b3bd9873b92a/skills/council), path `skills/council/SKILL.md`, commit `11e37a74d0a6868c121cd0910ab2b3bd9873b92a`. The license is MIT. Copyright (c) 2026 Theo Browne. The full notice is `LICENSE` in this directory. The original directory holds only `SKILL.md`, so no other file came with it.

`SKILL.md` keeps the original's text and order: fix known issues first, run three delegates, act on results as they arrive, score each round, report the scores in the pull request, and fight scope creep. These parts changed so the skill runs the same in Claude Code, Codex, Cursor, Amp, and other harnesses:

- The skill is named `gs-council`, where the original is `council`. The description leads with what the skill does, keeps the original trigger, adds a request for a second opinion from other models, and says to run only when the user asks for a council.
- The harness's subagent tools are the default way to start the delegates. The T3 Code tools `orchestrator_capabilities` and `delegate_task` are kept as an example for T3 Code, not a requirement.
- High reasoning effort applies when the harness lets the agent set it.
- Three providers are preferred, not required. The original reports a missing provider instead of substituting. This version still reports it, then fills the empty seats with the strongest models the harness reaches. A council member the user names is still never substituted.
- When the harness has no subagent tools, the skill tells the user and stops.
- The original puts the council section before "the model and harness line" that tstack's other skills add to a pull request. This version puts it before such a line only when the description has one.

The model names in the skill, Claude Opus, GPT Sol, and Gemini Pro, are examples, as they are in the original.
