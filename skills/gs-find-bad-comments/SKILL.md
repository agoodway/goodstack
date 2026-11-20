---
name: gs-find-bad-comments
description: "Find the comments and lint or type suppressions that should be removed and report them, without changing any file. It is strict: nearly every comment is reported, and only a short keep list survives. Use when the user asks to find bad comments, audit the comments in a diff or a set of files, asks which comments should go, wants a report before deleting comments, or names gs-find-bad-comments. To delete the comments and fix the code that needed them, the user runs gs-no-comments."
---

Find every comment that should be removed, and report it. Change no file.

This pass is strict on purpose. A comment is guilty until it fits the keep list. Code that needs a comment to be understood is reported too, as code to reshape.

**0. Pick the scope**

The user names the scope in prose. With files or a directory, judge every comment in them. With a diff, or with nothing named, judge only the comments and suppressions the diff adds or changes. With nothing named, the diff is the current one against the default branch, including the working tree, and you tell the user that is the scope. Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD`, then `git remote show origin`, then `main`.

**1. Judge each comment against the keep list**

Read every file in scope from disk. Judge each comment against this list alone, not against what you remember of the session.

Only these comments are kept:

- Legal or license headers.
- Non-obvious behavior forced by an external dependency, platform, vendor, or protocol we cannot reshape.
- `// prettier-ignore`, and a lint suppression whose rule is faulty, pedantic, or style-only.
- Doc comments that define a public API contract.
- Issue or RFC links that explain a constraint code cannot express.

When you are not sure a keep clause applies, report the comment. Everything else is reported, including these kinds:

- **narration:** it says what the next line already says.
- **banner:** it divides or decorates the file.
- **dead code:** it is commented-out code.
- **justification:** it argues for a workaround, with words such as `fine for now` or `too risky`, or at length.
- **surprise:** it explains non-obvious behavior in our own code. We can change our own code, so the comment goes and the code is reshaped.
- **suppression:** it turns off a lint or type check, such as `eslint-disable`, `@ts-ignore`, `@ts-expect-error`, `# type: ignore`, or `# noqa`. Look up the rule. Keep it only when the rule is faulty, pedantic, or style-only.
- **constraint:** it says `IMPORTANT`, `do not remove`, `do not change wording`, or `talk to X before changing`.

**2. Trace the claims you cannot see**

`IMPORTANT`, `do not remove`, `too risky`, `fine for now`, and long justifications are a reason to look, not a reason to keep. Read the nearby code first. If the comment's claim is not obvious there, trace the symbol or call it names, read its history with `git log -L` and `git blame`, and read the commits and pull requests that introduced it.

Keep the comment only when the trace proves it is on the keep list today, on a live path: a real gotcha in something we cannot change. A surprise in our own code is reported with a reshape verdict. A comment still in doubt after the trace is reported.

**3. Give each bad comment a verdict**

- **delete:** the comment goes, and the code needs nothing.
- **reshape:** the comment goes, and the code it excused needs a rename, an extracted function, a type, or a new design that makes the behavior obvious without prose. Name the exact symbol. Use this for a surprise, for a justification with no proven keep-list exception, and for a suppression of a rule that catches real bugs or protects correctness or safety. Never suggest a shorter comment in its place.

Every reshape names code inside the scope and tells the truth about it. Invent nothing. Say what should become obvious, and do not write the new code.

**Large scopes**

Work one file or one module at a time. When the harness has subagent tools, give each subagent its own files to read in parallel, and have each one return the same tables the report uses below. Run the subagents on the models the user names, otherwise on the strongest model the harness reaches, otherwise on the session's model. Without subagents, read the same batches one after another in this session.

**4. Report**

Start with the scope, the number of comments you read, and the number you report. Then give a table of every bad comment.

| Where | Comment | Kind | Verdict | Why |
|---|---|---|---|---|
| `cart.ts:14` | `// loop over the items` | narration | delete | The `for` loop below says it. |
| `cart.ts:31` | `// total can be negative after a refund, see below` | surprise | reshape | `Cart.total` needs a type or a name that says a refund can make it negative. |
| `api.ts:8` | `// @ts-ignore` | suppression | reshape | The rule catches a real type error in `fetchUser`. The call passes a string where the function takes a number. |
| `sync.ts:52` | `// IMPORTANT: do not remove this sleep` | constraint | reshape | `git blame` ties it to a race in our own `flushQueue`. The queue should wait on the write, not sleep. |

Quote long comments by their first words. The kind is narration, banner, dead code, justification, surprise, suppression, or constraint.

After the table, list the comments you kept, each with the keep-list exception it fits and the proof.

| Where | Comment | Exception | Proof |
|---|---|---|---|
| `http.ts:3` | `// Safari drops the header when...` | external platform | The WebKit bug the comment links is still open. |

When no comment in scope is bad, say so, and give the scope and the count you read.

End by saying how to act on the report. When `gs-no-comments` is installed, tell the user that skill takes this report, deletes the comments, and fixes the code marked reshape, and that only the user can start it. Without it, the user deletes the comments and reshapes the code by hand.
