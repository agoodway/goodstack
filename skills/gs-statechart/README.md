# gs-statechart

This skill checks a TLA+ model of a system that moves between states, such as a product flow, a protocol, or a service, and draws it as a Mermaid statechart. The agent writes the spec and a view module that puts each state and step in the reader's words. The command runs TLC on the model and writes the chart and a report. The report gives the shortest path to each state that breaks a rule.

## Use cases

- You want to see every state a flow can reach, and every step between them, before you build or change it.
- TLC found a counterexample, and you want it shown as a path through states that a person can read.
- You want to check a rule about a protocol or a service, such as "a paid order never goes back to pending", and see where it breaks.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-statechart
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-statechart
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-statechart
```

Describe the system and the rules it must keep. In a harness without slash commands, ask for it by name. The agent writes the spec in a scratch folder and runs the command from the skill's `scripts` folder.

```sh
sh <skill dir>/scripts/statechart SPEC.tla [--config FILE] [--view FILE] [--out DIR]
```

Run the launcher with `sh`, because an installed copy can lose its executable bit. The command writes `report.md`, `chart.mmd`, and `tlc.out` to the `--out` folder. It exits 0 when every rule holds and 1 when a rule breaks. When the harness can show an image or a rendered artifact, the agent renders the chart with Pele and gives the Mermaid text after it. Otherwise it shows the Mermaid text.

### Requirements

- A runtime that runs TypeScript: Node 22.18 to 22.x, Node 23.6 or later, Bun 1.1.5 or later, or Deno 2.0 or later. The `statechart` launcher picks the first one it finds. On native Windows, run `node --disable-warning=ExperimentalWarning <skill dir>/scripts/statechart.ts` with Node.
- [mise](https://mise.jdx.dev) on PATH. The command does not install it. When it is missing, the agent asks before it installs mise, unless the machine is a disposable sandbox. It runs `curl https://mise.run | sh`, which puts mise in `~/.local/bin`, adds that folder to PATH for the session only, and leaves shell startup files alone. The first run uses mise to install TLC and Java, so that run needs the network. To skip mise, set `TLA2TOOLS` to the path of `tla2tools.jar` and `JAVA` to a Java 11 or later binary.

### Tests

The skill's tests are in `scripts/test`. Run them from `scripts`.

```sh
npm install
npm test
```

The tests that run TLC itself skip unless `TLA2TOOLS` names `tla2tools.jar`. The other tests replay TLC output saved in `scripts/test/corpus`.

## Source

Lauren Tan wrote this skill. The original source is the pstack plugin in the [Cursor plugins repository](https://github.com/cursor/plugins/tree/aaeb0ea3a0584995aa8f55ce44c6c5259414b896/pstack/skills/statechart), path `pstack/skills/statechart`, commit `aaeb0ea3a0584995aa8f55ce44c6c5259414b896`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory, copied from the pstack plugin.

`SKILL.md`, `references/render.md`, and every file in `scripts`, including the tests and their corpus, are copied from the original. The command works the same. These parts changed:

- The skill is named `gs-statechart`, where the original is `statechart`. The `name:` line, the usage text in `scripts/statechart.ts`, and the launcher's error message say `gs-statechart`. The test in `scripts/test/cli.test.ts` that reads that error message expects the new name.
- The package in `scripts/package.json` is named `@goodstack/gs-statechart`, where the original is `@cursor-skill/statechart`.
- "Show the chart" renders the chart with Pele by default when the host can show an image or a rendered artifact, and gives the Mermaid text after the image. The original showed a `mermaid` code block and rendered only when the user asked for an image or the chart was too large to read.
- "Run" calls the launcher with `sh`, because an installed copy can lose its executable bit, and says that `mise` must already be on PATH. When it is missing, the agent asks before it installs mise, except in a disposable sandbox, and the section names the `TLA2TOOLS` and `JAVA` variables that skip mise.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. It keeps `disable-model-invocation: true` and ends by saying to run only when the user asks for it. The original said "Use for /statechart".
