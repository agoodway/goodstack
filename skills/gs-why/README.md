# gs-why

This skill investigates why code is shaped the way it is. It looks for the decision, the constraint, and the evidence, then returns a cited read.

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a/pstack/skills/why), path `pstack/skills/why`, commit `ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory. `SKILL.md` and the files in `references` are adapted from that text so the skill runs on any harness. The steps and output format are the same. These parts changed:

- Models are chosen in prose. The skill no longer reads the `pstack-models.mdc` rule or names model slugs.
- Cursor Task tool fields and their fallback rules are gone. The skill uses the harness's subagent tools, and does the work in the session when there are none.
- The reference to the `poteto-mode` skill is gone.
- MCP discovery no longer depends on Cursor's tools map or `mcps/` directory. The skill lists whatever MCP servers and connectors the session has.
- The rule against read-only subagents is now conditional: it applies only where read-only mode removes MCP access.
- Pull request discussion comes from the host's own CLI, such as `glab` for GitLab. The original assumed `gh`. When the host has no CLI, the skill records the discussion as a gap, and the synthesizer prompt reports it that way.
- `references/sources/incident-postmortem.md` names an issue tracker and a team chat in general. The original named Linear and Slack.
- `references/sources/slack.md` numbers its steps 1 to 3, and no longer names the `mcp_auth` tool.
- `references/sources/code-archaeology.md` allows `grep -rn` where `rg` is not installed.
- The skill no longer uses the cursor location to guess a vague target.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. It ends by saying to run only when the user asks for it.

The instructions name the companion `gs-how` skill, which is in this repo.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-why
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-why
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-why
```

Use it for why something works this way, why a design was picked, a regression, a postmortem, or a threshold that should have evidence behind it.
