# gs-find-bad-tests

This skill reads a test suite and reports the tests that guard no behavior. It sorts each one into a category, gives it a verdict of delete, rewrite, or unsure, and says why. It changes no file.

The agent can start this skill on its own, and other skills call it. `gs-prune-tests` uses its report to do the deleting and rewriting.

## Use cases

- You want to know how much of a test suite is worth keeping before anyone deletes anything.
- You want a list of brittle or empty tests to review, hand to a teammate, or attach to a ticket.

## Install

The source is `agoodway/goodstack`. From a local checkout, pass that directory instead of `agoodway/goodstack`.

List the skills in this repo.

```bash
npx skills add agoodway/goodstack --list
```

Install this skill into the current project.

```bash
npx skills add agoodway/goodstack --skill gs-find-bad-tests
```

To install every skill in this repo, see [Install](https://github.com/agoodway/goodstack#install) in the root README.

A local checkout uses the directory as the source.

```bash
npx skills add /path/to/goodstack --list
npx skills add /path/to/goodstack --skill gs-find-bad-tests
```

Add `-g` to install into your user skill directory instead of the current project.

## Usage

Ask the agent to find bad tests or audit the test suite, or call the skill directly. Name a path to limit the scope. Without one, the skill reads the test files your branch touched.

```
/gs-find-bad-tests
/gs-find-bad-tests src/cart
```

The report is a table with one row for each bad test: its file, its name, its category, the verdict, and the reason. The categories are past, nothing, implementation, and duplicate.

## Source

This skill is the finding half of `gs-prune-tests` in this repo, taken out so it can run alone. It draws on the same two sources.

- `prune-tests`, by Maze. The original source is the [caldoai/skills repository](https://github.com/caldoai/skills/blob/bd73b2ea5eb854ab8f0553fb41f77c8786f28f82/skills/prune-tests/SKILL.md), path `skills/prune-tests/SKILL.md`, commit `bd73b2ea5eb854ab8f0553fb41f77c8786f28f82`. The original directory holds only `SKILL.md`, so no other file came with it.
- `tests.md` and `mocking.md` in the `tdd` skill, by Matt Pocock. The original source is [mattpocock/skills](https://github.com/mattpocock/skills/tree/43ea0884b07a3e67a5a07f025ce92aefa983177b/skills/engineering/tdd), paths `skills/engineering/tdd/tests.md` and `skills/engineering/tdd/mocking.md`, commit `43ea0884b07a3e67a5a07f025ce92aefa983177b`. Only those two files are used. The rest of the `tdd` skill is not included.

Both are MIT licensed. Copyright (c) 2026 Maze and Copyright (c) 2026 Matt Pocock. The full notice is `LICENSE` in this directory.

`SKILL.md` keeps Maze's rule for what a test should depend on, and the three categories with their examples. These parts differ from the sources:

- The skill reports and changes no file. Maze's prune steps, the "What done looks like" list, and the diff example stay in `gs-prune-tests`.
- The skill is named `gs-find-bad-tests`, and the scope arrives in prose. A named path wins. Without one, the skill reads the test files the branch touched compared with the default branch, and it says so.
- A duplicate is a fourth category. The report names the test that stays, which is the one closest to what callers see.
- Matt Pocock's red flags join the implementation category as two examples: a test that mocks an internal collaborator and asserts the call, and a test that reads a store directly where the public interface could show the result. A note says a test name that describes how the code works is a sign of this category, and that the assertions decide.
- Two "Nothing" examples are widened so they apply outside front-end TypeScript. Maze's browser example now covers the platform, the framework, and libraries. The type system example adds what the compiler, a struct definition, or a schema enforces in a language without static types. The browser example says "a button element", where the original writes `<button>` in inline code that some renderers show empty.
- A new part on mocks comes from `mocking.md`. It takes that file's two lists, what to mock and what not to mock, and uses them to tell a mock at a system boundary from a mock of something we control. It adds that a test may assert a call to a boundary mock when the call is the behavior.
- The "Designing for Mockability" half of `mocking.md` tells an author how to shape code. Here it tells the skill what to report. A rewrite verdict says when the production code must first take its external client as a parameter, with the file's `processPayment` sample. A mock that branches on its arguments points to a generic fetch wrapper, which the report names. The file's `api` sample and its list of what the SDK approach means are left out.
- A code block shows one bad test for each fault. The calculateTotal, checkout, and createUser tests are the bad samples from `tests.md`. The other two are new.
- A keep list stops the skill from marking regression tests, tests of public APIs and external contracts, and tests that guard security or data integrity for deletion.
- Each bad test gets a verdict of delete, rewrite, or unsure. A rewrite verdict says what the test should assert, using Matt Pocock's list of good-test traits. An unsure verdict names the change to production code that would settle it, and the skill does not make that change.
- The skill lists production code that only the bad tests use, after it searches the whole repo for other uses.
- A section splits large scopes into batches. Subagents read batches in parallel when the harness has them, on the models the user names, otherwise the strongest the harness reaches, otherwise the session's model. Without them, the batches run one after another in the session.
- The report is a table of every bad test with its file, name, category, verdict, and reason. It ends by pointing to `gs-prune-tests` when that skill is installed.
