# gs-openspec-qa-scenarios

This skill writes QA scenarios from an OpenSpec change instead of from a diff. It reads the change's proposal, design, and spec deltas, and turns each requirement's WHEN and THEN into steps and Expect lines a QA engineer can follow in the running application. Because the scenarios come from the specs, you can write them before any code exists, and they set the bar the implementation is graded against.

Each Must scenario names the requirement and spec scenario it covers. A Coverage table lists every spec scenario in the change with the QA scenario that checks it, or the reason no person can check it by hand. Cases the requirements imply but no spec scenario states become Should or Could scenarios, and the skill lists them as gaps the author may want to add to the spec.

The output has the same shape as `gs-qa-scenarios`: a checklist, Must, Should, and Could priorities, steps with Expect lines, and the Setup, Not covered, and Questions sections. The set opens with YAML front matter for tools. It holds `source: intent`, the change id, and each scenario's id, priority, and the spec scenarios it covers, plus the coverage of every spec scenario. A tool can tell an intent set from a diff set and read it without parsing the Markdown. A pull request comment carries the same YAML in a fenced block at the end, because a comment cannot start with front matter. The skill writes no regression checks. Those need a diff, and `gs-qa-scenarios` writes them from the implementation branch.

This skill is original to this repo. It changes no code and no spec. It prints the scenarios in chat, and it saves them to `qa-scenarios.md` in the change directory only when you ask. Running the scenarios needs `gs-qa-scenarios`, whose run mode drives the app through the project's `verify-*` skill.

## Use cases

- You have an OpenSpec change and want the acceptance scenarios written before anyone builds it, so the implementation has a fixed bar.
- You want to see which requirements in a change no person can check in the running app, and which cases the specs leave out.
- An implementation is done, and you want to run it against what the spec asked for, not against what the code happens to do.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-openspec-qa-scenarios
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-openspec-qa-scenarios
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-openspec-qa-scenarios                          # asks which active change to cover
/gs-openspec-qa-scenarios add-account-invites      # one change
/gs-openspec-qa-scenarios add-account-invites, only the invites capability
/gs-openspec-qa-scenarios add-account-invites and save them
/gs-openspec-qa-scenarios add-account-invites and run them on this branch
```

Run it in the app repo that contains `openspec/changes/`. A change that fails `openspec validate` stops the skill.
