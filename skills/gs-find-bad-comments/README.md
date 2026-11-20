# gs-find-bad-comments

This skill reads a diff or a set of files and reports the comments and lint or type suppressions that should be removed. It gives each one a kind, a verdict of delete or reshape, and a reason. It changes no file.

The pass is strict. It reports nearly every comment, and only a short keep list survives. The agent can start this skill on its own, and other skills call it. `gs-no-comments` uses its report to delete the comments and fix the code that needed them.

## Use cases

- You want to see which comments in a diff would go before anyone deletes them.
- You want a list of the lint and type suppressions that hide real bugs, with the symbol each one protects.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-find-bad-comments
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-find-bad-comments
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

Ask the agent to find bad comments or audit the comments in a diff, or call the skill directly. Name files or a diff to limit the scope. Without one, the skill reads the current diff against the default branch.

```
/gs-find-bad-comments
/gs-find-bad-comments src/cart
```

The report is a table with one row for each bad comment: where it is, its text, its kind, the verdict, and the reason. A second table lists the comments the skill kept, with the exception each one fits.

## Source

This skill is the finding half of `gs-no-comments` in this repo, taken out so it can run alone and change nothing. Lauren Tan wrote the skill and the agent it comes from. The original sources are in the pstack plugin of the [Cursor plugins repository](https://github.com/cursor/plugins/tree/bf0c7cd80abdbf7fe47b634978a7d1b4071f71a7/pstack), commit `bf0c7cd80abdbf7fe47b634978a7d1b4071f71a7`. The skill is `pstack/skills/no-comments/SKILL.md`, and the agent it starts is `pstack/agents/comment-sicko.md`. The license is MIT. Copyright 2026 Lauren Tan. The full notice is `LICENSE` in this directory.

`SKILL.md` keeps the rules of the `comment-sicko` agent: the five keep-list exceptions, the rule that a comment in doubt goes, the handling of suppressions, the trace through `git log -L` and `git blame`, and the flag on code that needed a comment. These parts differ from the sources:

- The skill reports and changes no file. The original agent deletes the comments it condemns. The audit of the report, the fixes, and the handling of constraint comments stay in `gs-no-comments`.
- The rules are written as plain instructions. The agent's persona, its opening line, and its voice are gone, since other skills call this one and put its rows in their own reports.
- The agent's `MUST KILL` flag is the verdict `reshape`. A comment with nothing to fix behind it gets the verdict `delete`.
- Each reported comment has a kind: narration, banner, dead code, justification, surprise, suppression, or constraint. The agent names most of these in passing. Suppressions in Python, `# type: ignore` and `# noqa`, are named beside the TypeScript ones.
- With a diff as the scope, the skill judges only the comments and suppressions the diff adds or changes.
- The scope uses the repository's default branch. The original defaulted to `main`.
- The report is a table of every bad comment and a table of every kept comment with its exception and proof. The agent reported touched files, a deletion count, flags, and skips.
- A section splits large scopes into batches. Subagents read batches in parallel when the harness has them, on the models the user names, otherwise the strongest the harness reaches, otherwise the session's model. Without them, the batches run one after another in the session.
- The skill is named `gs-find-bad-comments`. Its description says what it does and when to use it, and the agent may start it.
