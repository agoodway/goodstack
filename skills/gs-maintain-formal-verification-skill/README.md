# gs-maintain-formal-verification-skill

This skill brings a project's formal verification back in line with the code after the code changes. It reads every commit that touched verified code since the last sync, updates the model, harness, or properties to describe the code as it is now, and reruns each check. It then says whether each failure is drift in the verification or a bug in the code, and gives each check one outcome: in sync, updated, bug, or blocked.

It maintains a skill made by the companion `gs-create-formal-verification-skill` skill, which is in this repo, or any project-local skill that runs a model checker, prover, or code-level verifier against named code. It looks for that skill in every project skills directory the repo has, such as `.cursor/skills/`, `.claude/skills/`, and `.agents/skills/`. It saves each run's evidence under `.verify/<area>/<run-id>/` with a `run.md` index.

## Use cases

- Merges or refactors touched verified code without rechecking it, and you want to know whether the model still describes the code.
- A formal check fails after a change, and you want to know whether the verification drifted or the code broke the property.
- A formal check still passes after a large change, and you want to confirm the pass is not on a stale description.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-maintain-formal-verification-skill
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-maintain-formal-verification-skill
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-maintain-formal-verification-skill
```

Run it in a repo that already has a formal verification skill. In a harness without slash commands, ask for it by name.

## Source

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/aaeb0ea3a0584995aa8f55ce44c6c5259414b896/pstack/skills/maintain-formal-verification-skill), path `pstack/skills/maintain-formal-verification-skill`, commit `aaeb0ea3a0584995aa8f55ce44c6c5259414b896`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory.

`SKILL.md` is adapted from the original. The outcomes, edit scope, steps, and report are the same. These parts changed:

- The skill is named `gs-maintain-formal-verification-skill`, where the original is `maintain-formal-verification-skill`.
- The skill looks for the verify skill in every project skills directory, such as `.cursor/skills/`, `.claude/skills/`, and `.agents/skills/`. The original did not name a directory.
- Every run in the pass saves its evidence, such as checker output and counterexamples, to `.verify/<area>/<run-id>/` at the repo root, with a `run.md` index that records the commit SHA, branch, whether the working tree was clean, time, tool version, command, and each check's outcome. A verify skill that saves evidence anywhere else, or skips `run.md`, has drift. The report names the evidence folders. The edit scope allows one change outside the verification, adding `.verify/` to the root `.gitignore`. The original named no evidence location and allowed no edits outside the verification.
- A failing TLA+ check is read with the `gs-statechart` skill, by name, when it is installed. Without it, the agent tells the counterexample as its shortest sequence of steps in the code's own words. The original did not name a reader for counterexamples.
- The skill points to the `gs-create-formal-verification-skill` skill by name. The original named only the `/create-formal-verification-skill` command.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. It keeps `disable-model-invocation: true` and ends by saying to run only when the user asks for it.
