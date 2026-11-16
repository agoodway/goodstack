# gs-codebase-design

This skill gives the agent a fixed vocabulary for designing deep modules: a lot of behaviour behind a small interface, placed at a clean seam, and testable through that interface. It defines module, interface, depth, seam, adapter, leverage, and locality, and it says how to deepen shallow modules and how to compare several interface designs.

Matt Pocock wrote this skill. The original source is [mattpocock/skills](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/codebase-design), path `skills/engineering/codebase-design`, commit `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d`. The license is MIT. Copyright 2026 Matt Pocock. The full notice is `LICENSE` in this directory. The files pulled from [themusicman's grabbag](https://github.com/themusicman/grabbag/blob/main/skills/mattpocock/codebase-design/SKILL.md) match that commit.

`DEEPENING.md` is unchanged. These parts changed:

- `SKILL.md` names the skill `gs-codebase-design`, where the original is `codebase-design`. Its text is unchanged.
- `DESIGN-IT-TWICE.md` says what to do when the harness has no subagent tools: draft each design in the session, one constraint at a time.
- `DESIGN-IT-TWICE.md` treats the project's glossary as optional. The original assumed a `GLOSSARY.md`.
- The upstream `agents/openai.yaml` is not included.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-codebase-design
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-codebase-design
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-codebase-design
```

The agent can also start it on its own, when you ask it to design or improve a module's interface, find shallow modules to deepen, or decide where a seam goes.
