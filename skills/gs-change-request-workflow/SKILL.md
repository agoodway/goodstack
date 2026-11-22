---
name: gs-change-request-workflow
description: "Take a branch through a GoodFlows change request, the replacement for a pull request: open it, upload scenario sets and verify runs, sync features, read the verdict, answer the review, and report the merge. Use when a repo's work lands through goodflows change requests, when asked to open, update, or merge a change request, when a verdict is pending, blocked, or needs_review and you need to know what fixes it, before running any goodflows cr or features command, or names gs-change-request-workflow."
---

# Work with GoodFlows change requests

A GoodFlows change request replaces a pull request on any Git host. The goodflows CLI reports facts from the local checkout, and the server grades them against the project's review policy. The server never talks to the Git host and never merges. You push, you merge, and you tell the server what you did.

This skill is the order of the steps and what each verdict reason asks for. It does not repeat the CLI. Every `goodflows` command has `--help` with examples, and `--json` prints its result as one JSON event. For exit codes, error codes, and the JSON fields, run `goodflows agents`. Formats live in the CLI too: check a file with the validate commands below before you upload it, and fix every problem they list at once.

## Before you start

- `command -v goodflows` prints a path. Without one, stop and say the CLI is not installed. Do not call the server's API with `curl` in its place.
- The repo's GoodFlows config has a `[reporting]` project, URL, and key. Writes need an `sk_` key. Never print the key.
- Work on a branch, not on the target branch. Commands find the change request of the current branch unless you pass `--number`.

## Who writes which file

The CLI uploads files. It does not write them. Each file has one writer, and you never edit a file another step owns to make an upload pass.

| File | Written by | Uploaded by |
|---|---|---|
| `.goodflows/change-requests/<branch>/cr.md`, the `change-claims/2` description (`goodflows cr path` prints it) | the `gs-change-request` skill | `cr open`, then `cr claims` |
| `openspec/changes/<id>/qa-scenarios.md`, the intent set, written from the OpenSpec change before code | the `gs-openspec-qa-scenarios` skill | `cr scenarios upload <file>` |
| `.goodflows/change-requests/<branch>/qa-scenarios.md`, the diff set, written from the branch (`cr path --json` prints it as `scenarios_path`) | the `gs-qa-scenarios` skill | `cr scenarios upload` |
| `.verify/<app>/<run-id>/`, a run folder with `scenarios.md`, `run.md`, and evidence | the repo's `verify-<app>` skill, driven by `gs-qa-scenarios` | `cr runs upload <folder>` |
| `verify-<app>/features/*.md`, the feature map, with `paths` globs in front matter | `gs-create-verification-skill`, kept true by `gs-maintain-verification-skill` | `features sync` |

`gs-qa-scenarios`, `gs-create-verification-skill`, and `gs-maintain-verification-skill` start only when the user asks, and some harnesses then refuse to start them for you. When the user asked for this workflow and a step needs one of them, find its installed `SKILL.md` instead: search the harness's installed skills, then the project skills directories, such as `.cursor/skills/`, `.claude/skills/`, and `.agents/skills/`, then the user skill directories. Read it, and follow its write or run mode for that step.

When a writer skill is not installed, say which file is missing and which skill writes it. Do not write the file from memory of its format.

`.goodflows/` and `.verify/` are never committed. The claims describe a commit, so committing them would change the commit they describe.

## The loop

Run the steps in this order. Skip a step the policy does not need; `cr verdict` says what is missing.

1. **Commit.** The claims, the diff set, and every counted run describe one clean commit. A dirty tree makes the run not count and the claims wrong.
2. **Scenarios.** A scenario set is stored on a change request, so open one first. With an OpenSpec change, open it with the change linked, upload the intent set, and have a person approve it, ideally before the code exists: `goodflows cr open --openspec-change <id> --title "<title>"`, then `cr scenarios upload <file>`. The link is set only at creation and cannot change later. A person with the approver role runs `cr scenarios approve`; an agent does not approve its own set unless the user tells it to. Without OpenSpec, run `goodflows cr open --title "<title>"` when the branch has no change request yet, then write the diff set for HEAD and upload it. The diff set names the commit it covers, so write and upload it again after every new commit.
3. **Push.** `goodflows cr push -- <git push arguments>` pushes and reports Git facts for the new head. A plain `git push` leaves the server on the old head.
4. **Drive.** Run the verify skill against the scenario set at HEAD. The run folder must hold the set as `scenarios.md`, byte for byte, and must come from a clean tree. Then `goodflows cr validate <folder>` and `goodflows cr runs upload <folder>`. Upload a failed run too: the verdict needs every result, and a person needs the evidence.
5. **Features.** When the change touched the feature map, `goodflows features validate`, then `goodflows features sync`. A sync recomputes every open change request's verdict.
6. **Describe.** Run `gs-change-request` for HEAD, then `goodflows cr validate`. While the file's `cr` is null, `goodflows cr open` creates the change request, or reuses the branch's one draft or open change request, and writes the number into the file. Once `cr` is set, `goodflows cr claims` updates it. Never run `cr open` for a file that has a number.
7. **Ready.** `goodflows cr ready` moves the draft to open.
8. **Wait.** `goodflows cr wait --until mergeable,needs_review --timeout <seconds>`. Exit 75 means the timeout passed before the verdict reached one of those states; run it again or read `cr verdict`. It is not a failure.
9. **Review.** On `needs_review`, `goodflows cr review` lists what a person must look at, with the answers each item allows. Hand the packet to the user. Answer an item with `cr answer` only when the user gave you that answer. A `request_change` or `reject` answer makes a task: `cr tasks` lists them, you fix the code, and `cr tasks done <id>` marks each one after the new head is pushed and graded.
10. **Merge.** `goodflows cr lease acquire` takes the target branch's merge slot for HEAD and prints a lease id. Merge on the Git host yourself, run `cr lease heartbeat <id>` if the merge outlasts the lease, then `goodflows cr merged --commit <merged commit> --lease <id>`. When the target moved since grading, the server wants a run on the merge result first (see `merge_result_ungraded` below). If you give up, `cr lease release <id>`.

Every new commit starts the head over: steps 2 (diff set), 3, 4, and 6 again. Answers and tasks bind to the head they were given at. When only the commit changed and not the diff, such as after a clean rebase, `gs-change-request` rewrites only `head`.

## Read the verdict

`goodflows cr verdict` prints the state and one reason per rule that fired, each with a `rule` and a `subject`. The state is the strongest outcome among them: `pending` (an input is missing), then `blocked` (an input fails), then `needs_review` (a person must look), then `mergeable`. Fix pending reasons first; a pending verdict hides nothing, but its other reasons may change once the input arrives.

The policy decides the outcome of most rules, so read the outcome from the verdict, not from this table. `goodflows policy get --effective` shows the settings in force.

| Rule | What it asks for |
|---|---|
| `git_facts_missing` | `cr push`, or `cr claims`, for the current head. |
| `claims_missing` | The claims file for this head: `gs-change-request`, then `cr claims` (or `cr open` while `cr` is null). |
| `required_workflow_missing` | A run of that GoodFlows workflow on this head, uploaded to the server, which needs `history = true` in `[reporting]`. Use the repo's `run-ci-<app>` skill. |
| `required_workflow_failed` | Fix the failing jobs and push a new head. Do not change the policy to clear it. |
| `scenario_set_missing` | No OpenSpec change is linked and no diff set exists. Write and upload the diff set. |
| `scenario_set_approval` | A person approves the current intent set. Ask the user; do not approve it yourself. |
| `diff_set_revision` | The diff set names an older commit. Write it again for HEAD and upload it. |
| `diff_set_weakened` | The new diff set removed or demoted a Must. A person answers it in `cr review`. |
| `scenario_results_missing` | No counted run grades that set at this head. Drive it from a clean tree and upload the run. |
| `must_failed`, `should_failed`, `should_not_run` | Read the run's evidence, fix the code, and drive the set again. Never edit the set to make a scenario pass. |
| `spec_gap` | A spec scenario no tester can see needs a proven `safe_because` fact with `covers` in the claims. |
| `feature_index_missing` | The project never synced features: `features validate`, then `features sync`. |
| `unmapped_area` | A changed file matches no feature's `paths`. Add the glob to the right feature file, or a new feature, with `gs-maintain-verification-skill`, then sync. |
| `undriven_feature` | A changed feature has no passed run at this head. Drive that feature and upload the run with it in `features`. |
| `one_way_door`, `proof_below_minimum`, `open_items`, `path_match`, `max_changed_files`, `max_changed_lines` | Claims and diff rules. A stronger proof or a resolved question may clear some; the rest go to a person through `cr review`. |
| `parent_not_merged`, `parent_closed` | A stacked change waits on its parent. Merge or reopen the parent, or `cr parent --clear`. |
| `merge_result_ungraded`, `merge_result_failed` | The target moved since grading. Drive the set on the merge result, upload that run, and fix what fails. |

A rule not in this table is newer than this skill. Read its `message`, then `goodflows cr verdict --help`.

## Rules

- Do not lower the policy, weaken a scenario, drop a feature glob, or mark a scenario not run to make a verdict pass.
- Do not approve, reject, or answer on a person's behalf unless they told you the answer in this conversation.
- When a command fails, quote the command and its error. Run `cr validate` or `features validate` on the file it read. A refused upload stored nothing, so fix the file and run the same command again. After a failed `cr open`, read `cr` in the claims file first: when it holds a number, the change request exists, so use `cr claims`.
- Report the change request number, the verdict state and its reasons, and anything waiting on a person.
