# gs-review second-opinion providers

Read Availability and timeouts, then only the section for the provider you are about to use.

## Contents

- Availability and timeouts
- Grok headless
- Codex headless
- Claude headless
- Claude subagent on another model

## Availability and timeouts

Before the first pass, check that the provider exists, and skip it without attempting a pass if it does not:

- Codex headless: `command -v codex` succeeds
- Grok headless: `command -v grok` succeeds
- Claude headless: `command -v claude` succeeds

Give every pass a 10-minute timeout, using the shell call's timeout. A pass that times out, fails, or returns no usable review makes that provider unusable for the rest of the review; move to the next one in the host's row.

## Grok headless

Run each pass as a new Grok CLI process in single-turn headless mode, with the prompt as one argument:

```text
grok --cwd [repository root] --permission-mode dontAsk --sandbox strict --tools read_file,list_dir,grep --deny 'MCPTool(*)' --disable-web-search --no-subagents --output-format plain -p "[pass prompt]"
```

The tool allowlist lets Grok inspect the changed files while withholding edit and shell tools. Keep MCP and web access disabled, and run Grok inside both its strict sandbox and any read-only sandbox supplied by the host.

## Codex headless

Run each pass as a new Codex CLI process from the repository root, with the prompt on stdin:

```text
codex exec --cd [repository root] --sandbox read-only -c 'approval_policy="never"' -c 'web_search="disabled"' --ephemeral --color never -o [output file] - < [pass prompt file]
```

The read-only sandbox lets Codex read files and run read-only commands such as `git diff`, while every write fails. With approvals off, Codex never asks to leave the sandbox, and `--ephemeral` keeps the pass out of its session history. Take the review from the output file, which holds only Codex's final message. Write the prompt and output files outside the repository so they never appear in the change.

## Claude headless

Run each pass as a new Claude Code process from the repository root, with the prompt on stdin:

```text
claude -p --tools Read,Grep,Glob --permission-mode dontAsk --strict-mcp-config --no-session-persistence < [pass prompt file]
```

`--tools` limits Claude to read-only file tools, and `--strict-mcp-config` with no MCP config loads no MCP servers. Write the prompt file outside the repository so it never appears in the change.

## Claude subagent on another model

Only for a Claude host with no external provider. If the runtime lets you choose a subagent's model, launch a generic subagent on the most capable Claude model that is not the host's. This is a cross-tier opinion from the same vendor, weaker than a cross-vendor one.
