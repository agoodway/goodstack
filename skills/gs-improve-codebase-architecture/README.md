# gs-improve-codebase-architecture

This skill scans a codebase for deepening opportunities: refactors that turn shallow modules into deep ones, so the code is easier to test and to navigate. It writes the candidates to a self-contained HTML report in the OS temp directory, with a before and after diagram for each one. Then it questions you, one decision at a time, about the candidate you pick.

## Use cases

- You want to know where the architecture of a codebase causes the most friction, ranked by how strongly the agent recommends each fix.
- You suspect a subsystem is a tangle of shallow modules and want a visual report of how to deepen it.
- You picked a refactor and want to settle its constraints, its interface, and which tests survive before you write code.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-improve-codebase-architecture
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-improve-codebase-architecture
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-improve-codebase-architecture
```

Name a module, a subsystem, or a pain point to point the scan at it. Without one, the agent starts from the areas that changed most in recent commits. The skill runs only when you ask for it.

## Source

Matt Pocock wrote this skill. The original source is [mattpocock/skills](https://github.com/mattpocock/skills/tree/abeeaf95660ba9e8b7c753eb38f441ca707a8823/skills/engineering/improve-codebase-architecture), path `skills/engineering/improve-codebase-architecture`, commit `abeeaf95660ba9e8b7c753eb38f441ca707a8823`. The license is MIT. Copyright 2026 Matt Pocock. The full notice is `LICENSE` in this directory.

These parts changed:

- `SKILL.md` names the skill `gs-improve-codebase-architecture`, where the original is `improve-codebase-architecture`, and its description says when to use it and that it runs only when the user asks.
- `SKILL.md` names the vocabulary skill `gs-codebase-design` instead of calling the Skill tool, and it defines the vocabulary inline for when that skill is not installed.
- `SKILL.md` no longer calls the grilling skill. Step 3 is a question loop written into the skill: one question at a time, with a recommended answer, covering constraints, dependencies, the shape of the deepened module, what sits behind the seam, and what tests survive.
- `SKILL.md` no longer calls the domain-modeling skill. It still reads `GLOSSARY.md` and `docs/adr/` when they exist, and it offers glossary updates and ADRs in plain words. It never creates those files unless the user agrees. The original created `GLOSSARY.md` without asking.
- `SKILL.md` uses the harness's subagent tools for the codebase walk and for alternative interfaces. When the harness has no subagent tools, the agent does that work in the session.
- `HTML-REPORT.md` points at the vocabulary in `SKILL.md` and `gs-codebase-design`, where the original pointed at `/codebase-design`. Its other text is unchanged.
- Small wording edits for plain style. Neither file has an em dash.
- The upstream `agents/openai.yaml` is not included.
