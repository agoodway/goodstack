# gs-qa-scenarios

This skill writes manual QA scenarios for the changes on a branch or pull request. A QA engineer can follow them in the running application without reading the code. Each scenario says what to test, why it matters, the exact steps, and the result to expect. The output also lists the setup, the regression checks, what a person cannot check by hand, and the questions the developer needs to answer.

This skill is original to this repo. It calls other skills from this repo when they are installed, and it follows a short set of fallback rules when they are not.

The skill changes no code. It prints the scenarios in chat, and it saves them to a file or posts them on the pull request only when you ask.

## Use cases

- Your branch is ready for QA, and the tester needs steps to check it in the running app without reading the code.
- You are reviewing a pull request and want a manual test plan that covers the main path, the edge cases, and the flows the change could break.

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

Reading a pull request or posting to one requires the `gh` CLI, installed and authenticated.

## Usage

```
/gs-qa-scenarios                       # the current branch against the default branch
/gs-qa-scenarios 482                   # a pull request by number
/gs-qa-scenarios 482 the checkout page # focus on one area
```

The agent can also start it on its own, when you ask for QA steps or a manual test plan for a change.
