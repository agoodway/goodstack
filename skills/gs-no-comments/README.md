# gs-no-comments

This skill runs a deliberate, aggressive pass over a diff or a set of files. It deletes nearly every comment, flags the code that needed one, and fixes that code. For a lighter cleanup of AI slop in the branch diff, use `gs-deslop`.

It finds the comments with `gs-find-bad-comments` when that skill is installed, and with its own Comment Sicko reference without it.

## Use cases

- You want to delete nearly every comment in a diff and fix the unclear code that needed them.
- Lint or type suppressions in a set of files hide real bugs, and you want them gone along with the comments.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-no-comments
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-no-comments
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

```
/gs-no-comments
```

Name files or a diff to limit the pass. Without one, it works on the current diff against the default branch.

## Source

Lauren Tan wrote this skill and its agent. The original sources are in the pstack plugin of the [Cursor plugins repository](https://github.com/cursor/plugins/tree/bf0c7cd80abdbf7fe47b634978a7d1b4071f71a7/pstack), commit `bf0c7cd80abdbf7fe47b634978a7d1b4071f71a7`. The skill is `pstack/skills/no-comments/SKILL.md`, and the agent it starts is `pstack/agents/comment-sicko.md`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory.

`SKILL.md` and `references/comment-sicko.md` are adapted from those two files so the skill installs on its own and runs on any harness. The steps, the keep list, the `MUST KILL` flags, the handling of suppressions, and the report are the same. These parts changed:

- Step 1 gets its report from `gs-find-bad-comments` when that skill is installed, or takes a report that skill already made. That report changes no file, so this skill deletes the comments it names. Its `reshape` verdicts stand in for the `MUST KILL` flags. Without that skill, step 1 runs Comment Sicko as before.

- The Comment Sicko agent is now `references/comment-sicko.md` inside the skill. The skill hands its text to whatever subagent the harness has. The original was a Cursor agent in a top-level `agents` directory, started through the `Task` tool's `subagent_type` field.
- When the harness has no subagent tools, the skill runs the pass itself, re-reads every file in scope from disk, and says so.
- Models are chosen in prose. The reference to the `poteto-mode` skill for reasoning level and speed is gone.
- Step 3 writes a short design sketch in the skill. The original ran the `architect` skill.
- Step 4 says in one sentence each what the `principle-fix-root-causes` and `principle-redesign-from-first-principles` skills asked for. The original named those skills.
- `/why` became a trace of the symbol's history with `git log -L` and `git blame`. When that leaves the history unclear and `gs-why` is installed, the skill asks the user to run `/gs-why`, because `gs-why` is user-started only.
- In step 2, a keep must prove the keep-list exception it claims. The original asked every keep to prove it is about something we cannot change, which contradicted the keep list for license headers, API docs, and `prettier-ignore`.
- The scope uses the repository's default branch. The original defaulted to `main`.
- The skill is named `gs-no-comments`, and its description says the pass is aggressive and points to `gs-deslop` for lighter cleanup.
- The description says what the skill does, then when to use it in plain phrases and by name, so a harness that routes on the description alone, such as Amp, can find it. It says never to run unasked.
