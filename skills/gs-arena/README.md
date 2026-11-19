# gs-arena

This skill runs several attempts at the same task, picks the strongest as the base, and grafts the best parts of the others into it.

## Use cases

- You have a non-trivial task where one attempt could lock in the wrong shape, and you want several candidates to compare before you pick one.
- You want candidates on models from different providers to attempt the same task, and a judge from another provider to score them against a rubric.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-arena
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-arena
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-arena
```

Use it when one attempt at a non-trivial artifact would lock in the wrong shape.

## Source

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/ab1f702ce8e8b6557edb56b09f52cde8bfb83f17/pstack/skills/arena), path `pstack/skills/arena`, commit `ab1f702ce8e8b6557edb56b09f52cde8bfb83f17`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory.

`SKILL.md` is adapted from that text so it runs on any harness with subagents. The phases and the method are the same. These parts changed:

- Models are chosen in prose. The skill no longer reads `~/.cursor/rules/pstack-models.mdc` or names model slugs. Candidates run on strong models from different providers when the harness reaches more than one, and on the same model otherwise.
- The cross-judge comes from a different provider than the session's own model. When none is reachable the judge is skipped and the skill says so.
- Cursor Task tool fields and their fallback rules are gone. The skill uses the harness's subagent tools, and stops when there are none.
- References to the pstack principle skills and `poteto-mode` are replaced by a sentence each saying what they asked for.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. It ends by saying to run only when the user asks for an arena.
