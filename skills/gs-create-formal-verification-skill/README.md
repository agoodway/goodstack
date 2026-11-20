# gs-create-formal-verification-skill

This skill finds the part of a repo where a bug costs the most and tests reach the least, formally verifies one property of it, and leaves a project-local skill that rechecks that property on every change. It picks the tool that answers the question at the lowest cost, such as a TLA+ model checker, a proof assistant, or a verifier that runs on the code. Before it hands over, it shows that the check catches a scratch change that breaks the property.

The skill puts the generated skill in the project skills directory of the harness it runs in, such as `.cursor/skills/`, `.claude/skills/`, or `.agents/skills/`. The generated skill saves checker output and counterexamples under `.verify/<area>/<run-id>/` with a `run.md` index. The companion `gs-maintain-formal-verification-skill` skill, which is in this repo, brings the verification back in line after the code changes.

## Use cases

- A race, retry loop, or state machine can break in an order of steps that no test covers, and you want every order checked.
- You want an invariant of a parser, data structure, or unsafe code proved for every input in a stated scope, not only for the inputs a test names.
- You want later agents to have one command that rechecks the property and tells a real bug from a modeling error.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-create-formal-verification-skill
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-create-formal-verification-skill
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-create-formal-verification-skill
```

Run it in a repo with code whose promise tests cannot fully check. Name an area or a bug to start there. In a harness without slash commands, ask for it by name.

## Source

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/aaeb0ea3a0584995aa8f55ce44c6c5259414b896/pstack/skills/create-formal-verification-skill), path `pstack/skills/create-formal-verification-skill`, commit `aaeb0ea3a0584995aa8f55ce44c6c5259414b896`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory.

`SKILL.md` is adapted from the original. The steps and the standards for a good verification are the same. These parts changed:

- The skill is named `gs-create-formal-verification-skill`, where the original is `create-formal-verification-skill`.
- The generated skill goes in the project skills directory of the current harness, such as `.cursor/skills/`, `.claude/skills/`, or `.agents/skills/`, and in the one the repo already uses when this harness reads it. The original did not name a directory.
- The generated skill saves each run's evidence, such as checker output and counterexamples, to `.verify/<area>/<run-id>/` at the repo root, with a `run.md` index that records the commit SHA, branch, whether the working tree was clean, time, tool version, command, and each check's outcome. It adds `.verify/` to `.gitignore`. The hand-off check confirms the evidence is there and untracked. The original named no evidence location.
- The original told the next agent to read TLA+ results with pstack's `/statechart` skill, through a relative link to it. This skill names the `gs-statechart` skill instead, with no link, and uses it only when it is installed. Without it, the generated skill tells each counterexample as its shortest sequence of steps in the code's own words.
- The last step points to the `gs-maintain-formal-verification-skill` skill by name. The original named only the `/maintain-formal-verification-skill` command.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. It keeps `disable-model-invocation: true` and ends by saying to run only when the user asks for it.
