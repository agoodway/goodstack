# gs-qa-scenarios

This skill writes manual QA scenarios for the changes on a branch or pull request. A QA engineer can follow them in the running application without reading the code. Each scenario says what to test, why it matters, the exact steps, and the result to expect under each step. A checklist at the top has one box for each scenario, so the tester can use the output as a to-do list. The output also lists the setup, the regression checks, what a person cannot check by hand, and the questions the developer needs to answer. YAML front matter at the top gives tools the source, the revision, and each scenario's id and priority. A run never edits the set. It copies the set into the run folder and writes each result and its evidence to `run.md`, so the set stays byte for byte what was reviewed.

This skill is original to this repo. It calls other skills from this repo when they are installed, and it follows a short set of fallback rules when they are not.

The skill changes no code. It prints the scenarios in chat, and it saves them to a file or posts them on the pull request only when you ask.

The skill has three modes. Write, the default, writes the scenarios and prints them. Write and run writes the scenarios, then runs them through the project's `verify-*` skill. Run takes scenarios written earlier, from a Markdown file, a pull request comment, or the chat, and runs them without rewriting them. Both run modes report each scenario as passed, failed, or not run, and save the evidence under `.verify/<app>/<run-id>/` with a `run.md` index that is never committed. A project without a `verify-*` skill needs one first, which `gs-create-verification-skill` makes.

When you ask, the skill posts a run's results on the pull request as one comment. Each screenshot and recording sits under the result it proves, uploaded with `gh pr comment --attach`.

## Use cases

- Your branch is ready for QA, and the tester needs steps to check it in the running app without reading the code.
- You are reviewing a pull request and want a manual test plan that covers the main path, the edge cases, and the flows the change could break.
- You want the QA scenarios run against the app automatically, new or from a saved file or pull request comment, with a result and evidence for each one, and the results posted on the pull request with the screenshots that prove them.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-qa-scenarios
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-qa-scenarios
```

Add `-g` to install into your user skill directory instead of the current project.

Reading a pull request or posting to one requires the `gh` CLI, installed and authenticated. Attaching screenshots to a comment needs a `gh` whose `gh pr comment --help` lists `--attach`.

## Usage

```
/gs-qa-scenarios                       # the current branch against the default branch
/gs-qa-scenarios 482                   # a pull request by number
/gs-qa-scenarios 482 the checkout page # focus on one area
/gs-qa-scenarios write and run         # write the scenarios, then run them
/gs-qa-scenarios run qa.md             # run saved scenarios from a file
/gs-qa-scenarios run 482               # run the scenarios posted on a pull request
/gs-qa-scenarios run 482 and post the results  # run them, then post the results with screenshots
```

The skill runs only when you ask for it.
