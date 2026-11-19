---
name: gs-reflect
description: "Review a session with four parallel reviewers, surface durable learnings, and route each one to the cheapest fix in the agent's environment: an automated check, a coding standard, a skill edit, or a pointer in a steering file. Use when the user says reflect, asks for a retrospective on a session, or names gs-reflect. Only when the user asks for it."
disable-model-invocation: true
---

# Reflect

Mine a session for durable learnings, then route each one to a change in the agent's environment, so the next run goes better. The environment is everything a future agent starts with: automated checks, coding standards, skills, docs, steering files such as `AGENTS.md` and `CLAUDE.md`, and the tools it can reach.

Skip when the session was trivial or off-topic, or when an existing skill covered it and the agent followed that skill correctly. One-offs are not learnings.

## 1. Find the session

Review the current conversation unless the user names another session.

- If the harness keeps the session's transcript as a file and tells you where, pass that path. Look only in this project's transcript directory. Do not search other projects' transcripts, which hold private chats from unrelated work.
- Otherwise pass a digest. Include the user's messages and corrections verbatim, the `SKILL.md` path of each skill the session loaded, the steering files in play, the tool calls that failed with their errors, and the tool calls that were slow or large.

## 2. Start four reviewers in parallel

| Lens | Looks for | Prompt template |
|---|---|---|
| Judgment | The durable principle behind a mistake, correction, or decision | `references/judgment-reviewer.md` |
| Tooling | The command, flag, path, or lookup a future agent would have to rediscover | `references/tooling-reviewer.md` |
| Divergent | What the other lenses miss: second-order effects and skipped verification | `references/divergent-reviewer.md` |
| Environment | Gaps in checks, standards, steering files, and access to information | `references/environment-reviewer.md` |

Start all four as subagents at once, using the harness's subagent tools. Pass each template verbatim, with the transcript path or the digest substituted where marked. Each reviewer returns its findings in its reply.

If the user names models, use those. Otherwise run every reviewer on the strongest model the harness reaches. When more than one provider is reachable, run the Tooling reviewer on a different provider from the others. If the harness offers no model choice, use the session's model.

Reviewers need the session's MCP servers and connectors, to look up the tickets, chat threads, and traces the transcript cites. If the harness has a read-only subagent mode that removes that access, do not use it. Reviewers still write nothing.

If the harness has no subagent tools, apply each lens yourself, one at a time, from the same templates, and say so.

## 3. Synthesize

Start one more subagent on the strongest model the harness reaches. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted, Rejected, and Backlog list.

## 4. Prefer structure over prose

Check every Accepted row before you present it. A rule that a tool can enforce does not belong in prose.

- A mechanical rule (a fixed syntactic pattern, a banned API, an import shape, a file-location rule) becomes a check: a rule in the repo's own linter, a pre-commit hook, or a CI job, whichever is cheapest given what the repo already runs. Reroute the row to `check:`.
- A judgment call that no check could make stays as a coding standard or a skill edit.
- A steering file loaded into every agent's context carries navigation pointers and little else. Reroute anything longer to a doc, a standard, or a skill.

## 5. Approve and apply

Present the full Accepted, Rejected, and Backlog output, most severe first, and wait for explicit approval before applying anything. The user picks the subset and may redirect a routing. These changes affect every future agent in the repo. Do not auto-apply.

List the Backlog items for the user. File them to a tracker only when the user says which one.

Apply each approved row by its Routing:

- **Skill body edit.** A one-line bullet, a tightened sentence, or a corrected fact: make the edit. A new section or more than about ten lines: use the harness's skill-authoring skill when it has one, and edit by hand in the skill's existing shape when it does not.
- **`tune description: <skill path>`.** The skill existed and did not trigger. Rewrite its description so it does, with the skill-authoring skill when the harness has one.
- **`new skill: <kebab-name>`.** Create it with the skill-authoring skill when the harness has one. Do not invent a shape.
- **`check: <mechanism>`.** Build the lint rule, hook, or CI job, run it, and show that it fails on the mistake the session made.
- **`coding standard: <file>`.** Add or change the rule in the file the reviewer reads, such as `CODING_STANDARDS.md`.
- **`pointer: <steering file>` or `doc: <path>`.** Add one line that points at the right file, or put the detail in a doc that an existing file points at. Look for an existing doc before writing a new one.
- **`remove: <file>`.** Delete the instruction that changes no behavior, or move it to the place its Routing names.
- **`access: <what>`.** Give the agent the information it lacked, such as dev server logs written to a file or read-only access to a service. Ask before granting access to anything outside the repo.

Never edit a skill in a plugin cache or another installed copy that an update would overwrite. Show the destination before approval: the project's skill directory for this harness, such as `.claude/skills/<skill>/`, `.agents/skills/<skill>/`, `.cursor/skills/<skill>/`, or `.grok/skills/<skill>/`. After approval, copy the skill folder there and edit the copy. Never open a pull request or push.

Write skill and steering text for an agent reader: short, imperative, one rule per line. Use a `writing-for-agents` skill when one is installed.

If the environment has a `SKILL.md` validator, run it on every skill you touched.

## 6. Summarize

A short list, with no preamble:

- Applied: the file, and what changed, one line each.
- Checks added: the mechanism, and the command that runs it.
- New skills: the path, one line each. These are rare.
- Backlog: the title of each item, and whether it was filed.
- Dropped: one line per rejected finding, with the synthesizer's reason.
