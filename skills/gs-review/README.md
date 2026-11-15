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

## Project guidance with REVIEW.md

A `REVIEW.md` tells `gs-review` how your project wants to be reviewed. The file is optional. Without one, the review runs on the skill's defaults.

Put it at the repository root. A `REVIEW.md` in a subdirectory also applies, only to changed files under that directory, and it wins over the root file for those files. This suits a monorepo where each package has its own checks.

The file is plain Markdown with up to five sections. Use any of them.

```markdown
# Review guidance

## Ignore

- priv/static/**
- lib/my_app_web/generated/**

## Roles

- Always run Security and Database.
- Skip UI/a11y. The admin UI is internal.

## Look for

- Every query on a tenant-owned table is scoped by `account_id`.
- Database: a migration on `events` must not rewrite the table. It has 400 million rows.
- Money is `Decimal`. A float in a price calculation is a bug.

## Below the bar

- Missing `@spec` and `@doc`.
- N+1 queries in the admin dashboard.

## Checks

- mix precommit
- npm test --prefix assets
```

| Section | What it does |
|---|---|
| `Ignore` | Path patterns that leave the review, such as generated or vendored code |
| `Roles` | Roles that always run or never run. The role names are Correctness, Security, Tests, QA execution, Elixir, Frontend, UI/a11y, Database, Technical writing, Accuracy, and Architecture |
| `Look for` | Project-specific failures the reviewers should check for. Start an entry with a role name to send it to that role only |
| `Below the bar` | Issues your project has accepted, which the reviewers leave out |
| `Checks` | The test, lint, and typecheck commands the review runs, in place of the ones it would choose |

The review also uses guidance written under other headings or in prose when it clearly belongs to one of these five kinds. It uses nothing else in the file.

The file has these limits.

- It cannot make the review write, commit, or post anything, and it cannot change how the second-opinion providers run.
- It cannot skip Fresh Eyes or the verification pass.
- It cannot hide a Blocker. `Below the bar` removes `Should fix` findings only.
- It cannot run a check that deploys, pushes, publishes, deletes data, or changes git state.

`gs-review` reads `REVIEW.md` as it is at the base of the review. The base is `HEAD`, or the merge-base with the ref you passed. An edited `REVIEW.md` therefore applies in its previous version, and a new one applies once it is committed. For `/gs-review main`, a new file applies once it is on `main`. A change cannot rewrite the rules of its own review, but a `REVIEW.md` that an earlier commit changed does shape the review of later uncommitted work.

When the review finds a `REVIEW.md`, the report's Evidence section says what the file changed. It lists the roles added and skipped, the files ignored, and how many entries were used.

## Second opinions

Fresh Eyes and verification run on a model other than the host when one is reachable.

| Host | Provider order |
|---|---|
| Claude | Codex MCP session tool, Grok CLI, Claude subagent on another model |
| Codex | Grok CLI, Claude CLI |
| Grok | Codex MCP session tool, Claude CLI |

The Grok and Claude CLIs must already be installed and authenticated. This skill never installs or authenticates them. Each runs headless with read-only file tools. If no provider is usable, the skill uses a generic subagent or a host pass and labels that pass as a fallback in the report.
