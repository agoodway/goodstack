# gs-maintain-verification-skill

This skill runs an upkeep pass on a project's verification skill and its feature map. Readers explain each feature from source and flag drift, then one live session drives every feature. The pass ends clean, changed with one pull request of proven corrections, or blocked with the reason.

It maintains a skill made by the companion `gs-create-verification-skill` skill, which is in this repo, or any project-local verification skill with a feature map. It looks for that skill in every project skills directory the repo has, such as `.cursor/skills/`, `.claude/skills/`, and `.agents/skills/`.

## Use cases

- The app changed and you want to know whether the verification skill still launches it and drives every feature.
- You want doc drift and harness gaps in the feature map fixed in one pull request. The skill reports product bugs to you and keeps them out of that pull request.
- You want a periodic audit that covers every feature from source and live, not only the ones that changed.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-maintain-verification-skill
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-maintain-verification-skill
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-maintain-verification-skill
```

Run it in a repo that already has a verification skill. In a harness without slash commands, ask for it by name.

## Source

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/e58dd043600587dbaf58ba315e7f2b38373eeb43/pstack/skills/maintain-verification-skill), path `pstack/skills/maintain-verification-skill`, commit `e58dd043600587dbaf58ba315e7f2b38373eeb43`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory.

`SKILL.md` is adapted from the original. The outcomes, edit scope, and steps are the same. These parts changed:

- The skill is named `gs-maintain-verification-skill`, where the original is `maintain-verification-skill`.
- The skill looks for the target in every project skills directory, such as `.cursor/skills/`, `.claude/skills/`, and `.agents/skills/`. The original looked in `.cursor/skills/`.
- The source wave uses the harness's subagent tools. When the harness has no subagents, the agent reads the feature files one at a time with the same read-only limits and the same return shape.
- Index hygiene checks where the verification skill writes evidence. Any location other than `.verify/<app>/<run-id>/` with a `run.md` index and `.verify/` in `.gitignore` is drift, and the pass moves it there. The live pass writes its own evidence to the same place. The edit scope allows one change outside the skill's directory, adding `.verify/` to the root `.gitignore`. The original let each skill name its own location and allowed no edits outside the skill's directory.
- The skill points to the `gs-create-verification-skill` skill by name. The original named only the `/create-verification-skill` command.
- Em dashes are replaced with colons, periods, or commas.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. It keeps `disable-model-invocation: true` and ends by saying to run only when the user asks for it.
