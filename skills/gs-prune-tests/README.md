# gs-prune-tests

This skill deletes tests that guard no behavior and rewrites the ones that guard it the wrong way. A test stays only when it is anchored to intended behavior. Tests that depend on the past, on nothing, or on the implementation go, along with production code that existed only for them.

The agent can start this skill on its own. Deleting tests is destructive, but the skill only deletes after a green baseline, keeps regression, contract, and security tests, proves borderline cases by mutation, and runs the tests again at the end. The changes stay in the working tree for the user to review.

## Use cases

- Your test suite breaks on every refactor but rarely catches a bug, and you want the brittle tests rewritten or removed.
- You removed a feature or moved a module and want the tests and production code that existed only for it cleaned up.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-prune-tests
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-prune-tests
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

Ask the agent to prune or trim tests, or call the skill directly. Name a path to limit the scope.

```
/gs-prune-tests
/gs-prune-tests src/cart
```

## Source

Maze wrote the skill this one is adapted from. The original source is `prune-tests` in the [caldoai/skills repository](https://github.com/caldoai/skills/blob/bd73b2ea5eb854ab8f0553fb41f77c8786f28f82/skills/prune-tests/SKILL.md), path `skills/prune-tests/SKILL.md`, commit `bd73b2ea5eb854ab8f0553fb41f77c8786f28f82`. The license is MIT. Copyright (c) 2026 Maze. The full notice is `LICENSE` in this directory. The original directory holds only `SKILL.md`, so no other file came with it.

`SKILL.md` keeps the original's rules, its three categories with their examples, its prune steps, its "What done looks like" list, and its diff example. These parts changed:

- The skill is named `gs-prune-tests`, where the original is `prune-tests`. The `argument-hint` line is gone, and the scope arrives in prose.
- The description says when to use the skill: a bloated or brittle suite, tests that break on every refactor, cleanup after a removal or a move, or a request to prune or trim tests.
- A note says the examples are TypeScript and the rules apply to any language and test framework.
- A new first step picks the scope. A named path wins. Without one, the skill works on the test files the branch touched compared with the default branch, and it says so. A whole-repo pass happens only on request.
- The skill runs the tests before it prunes and stops when they already fail. It runs them again after, and everything that remains must pass. "What done looks like" gains a line for that.
- A new section proves a borderline test guards nothing by breaking the behavior it claims to guard, running it, and undoing the edit by hand. When the suite is slow, the skill does this only for borderline tests.
- A keep list protects regression tests for fixed bugs, tests of public APIs and external contracts, and tests that guard security or data integrity. When two tests guard the same behavior, the skill keeps the one closest to what callers see.
- Before it deletes production code, the skill searches the whole repo for other uses. It suggests `gs-blast-radius` for deletions it is unsure of, when that skill is installed.
- A new section splits large scopes into batches, one file or module at a time. Subagents take batches in parallel when the harness has them, on the models the user names, otherwise the strongest the harness reaches, otherwise the session's model. Two subagents share production code only when neither mutates it. Without them, the batches run one after another in the session.
- A new last step reports a table of every deleted or rewritten test with its file, name, category, action, and reason. It lists removed production code and the test command, and suggests committing the prune on its own.
- The "Nothing" example in the original writes `<button>` in inline code, and some renderers show it empty. This version says "a button element" instead.
