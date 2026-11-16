# gs-pr-comment

This skill writes and posts a GitHub comment on the user's behalf. Every comment opens with a note naming the model and the user it speaks for. The comment is written in plain language, and it shows its point with a small picture where one is clearer than a sentence.

Theo Browne wrote the skill this one is adapted from. The original source is `leaving-pr-comments` in the [tstack repository](https://github.com/t3dotgg/tstack/tree/6efae364201abc9d9f07443e9caa461f42e51090/skills/leaving-pr-comments), path `skills/leaving-pr-comments`, commit `6efae364201abc9d9f07443e9caa461f42e51090`. The license is MIT. Copyright 2026 Theo Browne. The full notice is `LICENSE` in this directory. The file was pulled from [themusicman's grabbag](https://github.com/themusicman/grabbag/blob/main/skills/leaving-pr-comments/SKILL.md), which matches that commit.

`SKILL.md` keeps the original's attribution callout, its rules for where the callout applies, and its checks before and after posting. These parts changed:

- The skill is named `gs-pr-comment`, where the original is `leaving-pr-comments`.
- The writing rules are longer. They follow the [`gs-unslop`](../gs-unslop/README.md) skill in this repo: whole sentences, plain words, a named actor, and no em dashes.
- A new section says how to show the point: a GitHub suggestion, a diff, a trace tree, pseudocode, or a Mermaid diagram. It follows the [`gs-show-me`](../gs-show-me/README.md) skill in this repo.
- The comment body is passed to `gh` from a file, so its text never becomes shell syntax.
- The upstream `agents/openai.yaml` is not included.

The skill tells the agent to run the draft through `gs-unslop` and to draw the picture with `gs-show-me`. When either is not installed, the rules written into this skill apply on their own. [`gs-review-pr-reply`](../gs-review-pr-reply/README.md) uses the same callout when it posts a review.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-pr-comment
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-pr-comment
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

The agent uses this skill whenever it is about to leave a comment on GitHub for you. You can also call it directly.

```
/gs-pr-comment
```
