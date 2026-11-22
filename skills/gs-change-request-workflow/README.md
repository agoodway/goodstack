# gs-change-request-workflow

This skill takes a branch through a goodflows change request, which replaces a pull request on any Git host. It gives the agent the order of the `goodflows cr` and `goodflows features` commands, from opening the change request to reporting the merge. It says which skill writes each file those commands upload, and what each verdict reason asks the agent to do.

It does not repeat the goodflows CLI. It names commands and sends the agent to each command's `--help`, to `goodflows agents`, and to `goodflows cr validate` and `goodflows features validate` for flags and file formats, so it stays accurate when the CLI changes. It never approves a scenario set or answers a review item on a person's behalf, and it never lowers the policy or weakens a scenario to make a verdict pass.

The agent can start this skill on its own whenever a request involves a change request. `gs-change-request` writes the description file this skill uploads.

This skill is original to this repo.

## Use cases

- Your branch is ready and you want the agent to open the change request, upload the scenario set and verify runs, and wait for a verdict.
- A verdict is `pending`, `blocked`, or `needs_review`, and you want to know which input is missing or failing and what fixes it.
- The verdict is `mergeable`, and you want the agent to take the merge lease, merge, and report the merge to goodflows.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-change-request-workflow
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-change-request-workflow
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

Ask in plain words, such as "open a change request for this branch", "why is the verdict blocked", or "merge the change request". In a harness with slash commands, `/gs-change-request-workflow` also starts it.

The `goodflows` CLI must be installed, and the repo's GoodFlows config must name the `[reporting]` project, URL, and key. The skill reports the change request number, the verdict and its reasons, and anything that waits on a person.
