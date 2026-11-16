---
name: gs-no-comments
description: "A deliberate, aggressive pass that deletes nearly every comment in a diff or set of files, flags the code that needed one for a reshape, and fixes it. Lint and type suppressions that hide real bugs go too. Use for /gs-no-comments, 'kill the comments', or 'no comments'. For a lighter cleanup of AI slop in the branch diff, use gs-deslop."
disable-model-invocation: true
---

# No comments

Run Comment Sicko on the scope, then act on the findings you accept.

Comment Sicko's rules live in `references/comment-sicko.md`: what it keeps, when it marks code `MUST KILL`, how it treats suppressions, and what it reports. Defer to its fresh perspective. Do not restate or soften its rules.

## Scope

Use the files or diff the user names. Otherwise use the current diff against the default branch, including the working tree. Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD`, then `git remote show origin`, then `main`.

## Steps

1. Start one subagent with the harness's subagent tools. Give it the scope and the full text of `references/comment-sicko.md` as its instructions. Use the model the user names, otherwise the strongest the harness reaches, otherwise the session's model. If the harness has no subagent tools, run the pass yourself and say so. Re-read every file in scope from disk first, and judge each comment against the reference file alone, not against what you remember from this session. Write the report before you start step 2.
2. Inspect its report and diff. Reject application-code edits, scope escapes, exception-protected deletions, misstated `MUST KILL` reasons, and flags that treat kept intentional code as guilty. Reshape flags on our-code surprises stay actionable. Do not restore those comments. A keep survives only with proof it fits its exception on the keep list. A keep for non-obvious behavior needs proof it is about something we cannot change. Audit missed scoped lint and TypeScript suppressions. Correctness or safety suppressions stay actionable `MUST KILL`s. Restore deletions only with exact exceptions and scoped proof. Before accepting thin `IMPORTANT` or `do not remove` kills or keeps, trace their symbol and read its history with `git log -L` and `git blame`. When the history is still unclear and `gs-why` is installed, ask the user to run `/gs-why` on the symbol, because only the user can start it. If a kill is ambiguous, do not restore. If a keep is refuted or still ambiguous, delete it. Revert and rerun one rejected report with the failure named. Reject a second, report it open, and stop with `gs-no-comments` failed.
3. Fix trivial accepted flags directly by deleting a dead path, dropping a parameter, or using the real API. If any fix needs a new shape, write one short design sketch for the accepted set and the code around it. Name the renames, extracted functions, types, or module boundaries that make each flagged behavior obvious without a comment, and say which flag each one answers. Stop at the sketch. Step 4 implements it.
4. Implement the smallest root-cause fix in scope. Remove every named workaround. If the root cause is out of scope, land the smallest in-scope fix and report the rest open. Fix the cause the comment was excusing, not the symptom it described, and never bolt on a guard that hides the symptom. When the code is shaped wrong, design it again from what it must do rather than patching the shape that needed the comment. Neither aim widens the scope or reaches instances outside it.
5. Constraint comments say `do not remove`, `do not change wording`, or `talk to X before changing`. Leave keeps about things we cannot change. For the rest, offer the cheapest in-scope type, runtime check, test, or CI lint that enforces the constraint. Wait for the user to approve. When no one is there to approve, encode only what the caller approved in advance. If approved, encode the constraint, then delete the comment. Otherwise delete the comment, report the constraint open, and sketch the out-of-scope work.
6. Report the deletion count, restored comments, reruns, the design sketch, fixes, encoding offers, encodings, unenforced constraints, and other open work.
