# gs-create-verification-skill

This skill generates a project-local verification skill for the current repo. The generated skill launches the app, checks that the instance is healthy, drives it the way a user does, captures evidence, and cleans up. It also seeds a feature map with one file per user-facing feature, and the agent runs the generated skill once end to end before handing it over.

The skill puts the generated skill in the project skills directory of the harness it runs in, such as `.cursor/skills/`, `.claude/skills/`, or `.agents/skills/`. The companion `gs-maintain-verification-skill` skill, which is in this repo, keeps that skill and its feature map current.

## Use cases

- Your project has no scripted way to start the real app and prove that a UI, CLI, or service change works.
- You want later agents to have a tested recipe for launching, driving, and cleaning up the app, with real selectors and commands from the repo.
- You want a feature map that lists each user-facing feature, how to reach it, and what end state proves it works.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-create-verification-skill
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-create-verification-skill
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-create-verification-skill
```

Run it in a repo that has no verification skill yet. In a harness without slash commands, ask for it by name.

## Source

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/e58dd043600587dbaf58ba315e7f2b38373eeb43/pstack/skills/create-verification-skill), path `pstack/skills/create-verification-skill`, commit `e58dd043600587dbaf58ba315e7f2b38373eeb43`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory.

`SKILL.md` and the files in `references/feature-map-example` are adapted from the original. The steps and the generated skill's sections are the same. These parts changed:

- The skill is named `gs-create-verification-skill`, where the original is `create-verification-skill`.
- The generated skill writes every run's evidence to `.verify/<app>/<run-id>/` at the repo root, with a `run.md` index that records the commit SHA, branch, whether the working tree was clean, time, outcome, and each feature driven with its artifact files. `run.md` opens with `verify-run-notes/1` YAML front matter that the goodflows CLI parses. It adds `.verify/` to `.gitignore`, and cleanup never removes it. The original let the generated skill name its own location and gave the index no fixed shape.
- The feature map example writes its proof under `.verify/notes/$RUN_ID/` and records each feature in `run.md`. The original wrote to `artifacts/<feature>/`.
- The generated skill goes in the project skills directory of the current harness, such as `.cursor/skills/`, `.claude/skills/`, or `.agents/skills/`, and in the one the repo already uses when this harness reads it. The original always wrote to `.cursor/skills/`.
- The last step points to the `gs-maintain-verification-skill` skill by name. The original named only the `/maintain-verification-skill` command.
- Em dashes are replaced with colons, a comma, or a period.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. It keeps `disable-model-invocation: true` and ends by saying to run only when the user asks for it.
