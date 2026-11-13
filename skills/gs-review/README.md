# gs-review

This skill reviews a change for what will break in production. The reviewers are generic subagents.

Specialists are chosen by what the change puts at risk. A small, low-risk change gets one reviewer holding all of them. Each finding must state a failure scenario, and a second model then tries to refute it. Confirmed and plausible findings reach the report. The review drops refuted findings and counts them. Style, naming, and anything a linter or CI already reports are out of scope.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-review
```

Install all twenty-two skills.

```bash
npx skills add agoodway/goodstack --skill gs-review --skill gs-openspec-ship-tickets --skill gs-openspec-ship --skill gs-openspec-to-tickets --skill gs-scratch --skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request --skill gs-blast-radius --skill gs-unslop --skill gs-deslop --skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me
```

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-review
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-review                      # all uncommitted changes
/gs-review main                 # everything since the merge-base with main
/gs-review lib/my_app/accounts  # focus on a path or area
```

The report opens with a verdict of `Ship`, `Fix first`, or `Don't ship`. Then it gives a sketch of what changed, the numbered findings with a failure trace and a fix each, the evidence, and the merge danger. Evidence covers the checks that ran and the findings that were refuted.

## Second opinions

Fresh Eyes and verification run on a model other than the host when one is reachable.

| Host | Provider order |
|---|---|
| Claude | Codex MCP session tool, Grok CLI, Claude subagent on another model |
| Codex | Grok CLI, Claude CLI |
| Grok | Codex MCP session tool, Claude CLI |

The Grok and Claude CLIs must already be installed and authenticated. This skill never installs or authenticates them. Each runs headless with read-only file tools. If no provider is usable, the skill uses a generic subagent or a host pass and labels that pass as a fallback in the report.
