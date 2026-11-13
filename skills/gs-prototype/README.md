# gs-prototype

This skill builds a throwaway prototype to answer one design question. A question about logic or a state model gets a single HTML file that anyone can open and click through. A question about what a screen should look like gets several structurally different variants on one route, with a floating bar to switch between them.

Matt Pocock wrote this skill. The original source is [mattpocock/skills](https://github.com/mattpocock/skills/tree/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/engineering/prototype), path `skills/engineering/prototype`, commit `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d`. The license is MIT. Copyright 2026 Matt Pocock. The full notice is `LICENSE` in this directory. The files pulled from [themusicman's grabbag](https://github.com/themusicman/grabbag/blob/main/skills/mattpocock/prototype/SKILL.md) match that commit.

`SKILL.md` in this directory is that text with one change to its front matter: the skill is named `gs-prototype`, where the original is `prototype`. `LOGIC.md` and `UI.md` are unchanged. The instructions name no harness, tool, or model, so they needed no other change. The upstream `agents/openai.yaml` is not included.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-prototype
```

Install all twenty-two skills.

```bash
npx skills add agoodway/goodstack --skill gs-review --skill gs-openspec-ship-tickets --skill gs-openspec-ship --skill gs-openspec-to-tickets --skill gs-scratch --skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request --skill gs-blast-radius --skill gs-unslop --skill gs-deslop --skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me
```

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-prototype
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-prototype
```

The agent can also start it on its own, when you ask whether a state model feels right or what a screen should look like. When the prototype has answered its question, the skill folds the decision into the real code and keeps the prototype on a throwaway branch.
