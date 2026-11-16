# gs-review-pr-reply

This skill posts a [`gs-review`](../gs-review/README.md) report to the current branch's pull request as one GitHub review. The review has an overview comment with the verdict, and an inline comment on the changed line for each finding.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-review-pr-reply
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-review-pr-reply
```

Add `-g` to install into your user skill directory instead of the current project.

It needs the `gh` CLI, installed and authenticated. Run `gs-review` before this skill. Install that skill from this same repo.

## Usage

Run `/gs-review` first.

```
/gs-review-pr-reply                              # post every finding
/gs-review-pr-reply blockers only                # pick findings with a prompt
/gs-review-pr-reply 1 and 3, skip the test one
```

The skill shows the full draft and waits for approval before posting. It posts with the `COMMENT` event and never approves, requests changes, or resolves threads.

## What gets posted

- The overview has the verdict, a sketch of the change marked with where each finding lands, a table of the posted findings, the checks that ran, and the merge danger.
- Each finding whose line is in the pull request diff gets an inline comment. The comment shows the failure as a trace tree, a sequence diagram, or pseudocode, then a fix. When the fix replaces exactly the commented lines, it is a GitHub suggestion the author can apply in one click.
- A finding whose line is not in the diff goes in the overview.
- Every comment opens with a note naming the model and the user it is posting for.

The comments follow the [`gs-pr-comment`](../gs-pr-comment/README.md) skill for the note, the writing, and the pictures. When that skill is not installed, a short set of fallback rules in this skill applies.
