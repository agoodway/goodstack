---
name: gs-openspec-review-change
description: >
  Quick-review an OpenSpec change, patch the findings that need no human input,
  then resolve the design-decision findings. Auto mode is the default: it applies
  the recommended answer to each design question and records why. Ask mode asks
  the user one question at a time, and runs only when the user asks for it. Use
  when the user runs /gs-openspec-review-change, says "review and fix the
  openspec", "patch the change specs", or "auto-fix OpenSpec findings", or wants
  a review-and-update pass on an OpenSpec change.
---

# Review and update an OpenSpec change

Run a quick review of an OpenSpec change, **patch the findings that do not need human input**, then resolve the remaining design-decision findings according to the selected **mode**.

This skill **modifies** OpenSpec change artifacts. It does **not** modify application source code.

Use the harness's subagent tools to run the specialists, and your file reading and search tools to read and edit files. To ask the user something, ask in the conversation or with the harness's question tool when it has one.

## Input

```text
/gs-openspec-review-change [change-id] [ask]
```

The change id and the mode arrive in prose. Read them from the user's request.

| User says | Mode |
|-----------|------|
| Nothing about a mode | `auto` |
| `auto`, `--auto`, "decide for me", "recommend", "answer for me" | `auto` |
| `ask`, `--ask`, "ask me", "interactive" | `ask` |

## Modes

| Mode | Behavior |
|------|----------|
| **`auto` (default)** | Patch mechanical findings. For each design-decision finding, pick the **recommended** option, apply it, and record the rationale. Do not ask the user about those findings. |
| **`ask`** | Patch mechanical findings. For each design-decision finding, ask the user one question at a time, then apply the fix from their answer. |

Use `ask` only when the user asks for it. Otherwise use `auto`.

Only design-decision findings are answered by the model. A missing change id is still resolved per [Change id](#change-id).

## Change id

- When the user names a change, use it.
- When the user names none, list active changes (`ls openspec/changes/` minus `archive/`) and ask which one to review.
- When the named change does not exist under `openspec/changes/`, stop and report it.

## OpenSpec conventions

- Changes live in `openspec/changes/<change-id>/` with `proposal.md`, `tasks.md`, optional `design.md`, and delta specs at `specs/<capability>/spec.md`.
- Canonical specs live in `openspec/specs/<capability>/spec.md`.
- This skill may edit only files under the target change directory.
- Report path: `openspec/changes/<change-id>/review-change.md`. Overwrite it if present.
- Severity tiers: **Critical** (blocks implementation or archiving), **Warning** (should fix before landing), **Suggestion** (nice to have).

## Workflow

### 1. Resolve the change id and mode

1. Resolve the change id from the request, or by asking.
2. Resolve the mode per [Modes](#modes).
3. Confirm both in a one-line status before reviewing, such as `Review: buyer-caps · mode=auto`.

### 2. Pre-read

Read these in one parallel batch when the harness allows it.

**Change artifacts** (`openspec/changes/<change-id>/`):

- `proposal.md`
- `design.md`, if present
- `tasks.md`
- Every delta spec under `specs/<capability>/spec.md`

**Surrounding context**, in the same batch:

- The canonical spec for each touched capability: `openspec/specs/<capability>/spec.md`
- Other active changes (`ls openspec/changes/`, unarchived) that touch the same capabilities
- Recently archived changes (`ls openspec/changes/archive/ | tail -20`), when useful
- Git: `git log --oneline -20 -- openspec/changes/<change-id>/` and `git status` for that directory

For each delta, note the capability, whether it is ADDED, MODIFIED, or REMOVED, and the behavior it claims.

### 3. Quick review with two specialists

Start **two** specialists in parallel as subagents. Two is enough for a quick pass. Put the pre-read contents in each brief so the specialists start at once.

Run the specialists on the models the user names, otherwise on the strongest model the harness reaches, otherwise on the session's model. When more than one provider is reachable, the two specialists may run on different providers.

If the harness has no subagent tools, run both specialist passes yourself in this session, one after the other. Re-read the change from disk before each pass, judge it against that pass's checks alone, and say so in the chat summary.

**Specialist A: structure and consistency**

- Covers format, structure, and consistency with other specs and changes.
- Receives all change artifacts, the canonical specs for touched capabilities, and the proposals and deltas of other active changes that touch the same capabilities.
- Checks delta format, SHALL and MUST language, the mapping between tasks and requirements, orphan tasks and requirements, naming consistency, and conflicts with canonical specs or other active changes.

**Specialist B: codebase alignment and gaps**

- Covers alignment with the codebase, and gaps and risks.
- Receives the proposal and deltas as context, and explores the codebase.
- Checks file paths, function names, schemas, hidden prerequisites, and work that is already implemented. Also checks for missing error and edge cases, auth, migrations, rollback, tests, and backward compatibility.

Each specialist returns rows in this format:

```text
severity | file:path:line | finding | suggested_fix | has_question: true/false | recommended: <short recommendation or n/a>
```

Set **`has_question: true`** when:

- The fix needs a **design decision** the reviewer cannot make alone.
- The proposal or spec is **genuinely ambiguous**.
- **Several fixes are valid**, and intent decides between them.

Set **`has_question: false`** (patchable without asking) when:

- The fix is **mechanical**, such as format, naming, a missing scenario, or a missing rollback step.
- The fix is **additive** and its content is obvious, such as a missing test task, error scenario, or index.
- The fix has **one verifiable correct answer**, such as a wrong path, a wrong function name, or a stale claim about the code.

Every `has_question: true` row **requires `recommended`**: the one option the specialist would pick, with enough detail to apply without more input. For example: `recommended: run the export as a background job; add a task for retry on failure`.

### 4. Classify findings

Merge both specialists' rows and remove duplicates. Then split them.

**Patch bucket** (`has_question: false`):

- Group by target file.
- Order patches top to bottom within each file.
- Prepare concrete edits.

**Question bucket** (`has_question: true`):

- Prepare the severity, title, `file:line`, excerpt, question text, options, and the **recommended** option.

### 5. Patch mechanical findings

For each finding in the patch bucket:

1. Read the target file if needed.
2. Apply the edit.
3. Log the change.

If a patch fails, for example because the text to replace is not found, skip it and record it under skipped patches.

### 6. Resolve the question bucket

#### Mode `auto`

For each finding, **without asking the user**:

1. Select the **recommended** option from the finding row.
2. If `recommended` is missing or empty, derive one from `suggested_fix` and mark the confidence as low in the report.
3. Apply the fix.
4. Record the title, `file:line`, the chosen recommendation, and a one- or two-sentence rationale that says why this option beat the alternatives.

Do **not** invent product requirements that contradict the proposal. Prefer the option that:

1. Matches the intent the proposal states.
2. Matches existing patterns in the codebase.
3. Is the smallest safe change to the specs.
4. Preserves backward compatibility when the proposal is silent.

If a finding cannot be resolved without the author's intent, for example two equally valid product directions with no signal in the proposal, **skip it**. Leave it in the report under Skipped and list it as needing human input. Do not guess product strategy.

#### Mode `ask`

Ask about each finding **one question at a time**. Do not batch independent design decisions into one prompt.

Present:

- The severity and finding title.
- The artifact excerpt (`file:line`).
- The question.
- Discrete options when possible, with **(Recommended)** on the specialist's preferred option.
- A free-form or "Other" answer when the harness supports it.

Then:

1. Wait for the user's answer.
2. Apply the fix based on their answer.
3. Continue to the next question.

If the user says `skip` or `later`, leave the finding unpatched and note it in the report.

### 7. Write the report

Write `openspec/changes/<change-id>/review-change.md` using [references/report_template.md](references/report_template.md).

Rules:

- Put `**Mode:** auto | ask` in the header.
- List patched findings only under **Patches applied**, not also under Critical, Warning, or Suggestion.
- The severity sections list only findings that remain unpatched or skipped.
- When questions were resolved inline, do not add a separate list of clarifying questions. Unresolved skips stay under **Skipped**, the severity sections, or both.

### 8. Summarize in chat

Print:

- The mode used.
- The original finding counts by severity.
- The counts of auto-patched, user-guided, model-recommended, and skipped findings.
- Every finding that remains unresolved, especially skips in `auto` mode.
- The path to the report.
- The verdict: ready, needs revision, or blocked.

Do not paste the full report into chat.

## Guardrails

- **Modifies OpenSpec only.** Edit the proposal, tasks, design, and delta specs under the change directory. Never edit source code.
- **No git commits and no branch changes.**
- **Classify conservatively.** When unsure whether a fix needs human input, set `has_question: true`. A needless question is cheap. A wrong patch is expensive.
- **`auto` is not reckless.** Skip a finding when the product intent is unknowable. Never invent scope.
- **Cite `file:line`** for every finding and every patch.
- **Verify before patching.** If a finding claims that function X does not exist, search for it before editing the spec.
- **Scope.** Touch only this change's directory.
- **One question at a time in `ask` mode.**
- **Every model decision in `auto` mode** appears in the report with its rationale.
