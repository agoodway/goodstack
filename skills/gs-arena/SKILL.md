---
name: gs-arena
description: "Spawn N parallel candidates at the same task, pick a base, graft the strongest parts of the losers into it. Use for /gs-arena, 'arena this', 'throw it in the arena', or when one attempt at a non-trivial artifact would lock in the wrong shape."
disable-model-invocation: true
---

# Arena

Run several attempts at the same task in parallel, pick the strongest as the
base, and graft the best parts of the others into it. Track the six phases
(Frame, Fan out, Cross-judge, Pick, Graft, Verify) in the harness's task list
if it has one.

## Frame

Every candidate gets the same prompt, so the prompt is the contract.

1. State the artifact each candidate produces.
2. Derive the rubric: 3-6 concrete, gradeable criteria for success on *this*
   task. The rubric is for picking. Candidates see only the task.
3. Pick the runners. If the user names models, use those. Otherwise run two
   candidates, each on a strong model from a different provider, at high
   reasoning effort. Add candidates when the task spans several design
   directions. If the harness reaches only one provider, or the work is
   generation-bound rather than judgment-sensitive, run every candidate on
   the same model. If a named model is unavailable, report it instead of
   substituting.
4. Give each candidate its own output location: a git worktree where
   possible, otherwise its own temp directory. Candidates never share a
   working tree.

## Fan out

Start all candidates in parallel with the harness's subagent tools. Give each
the task, the shared context, its output location, and instructions to
produce the artifact plus a short rationale naming the alternatives it
considered and rejected. If the harness has no subagent tools, tell the user
and stop. Candidates written in one session are not independent.

If a candidate produces nothing, continue with the rest and note the dropout.

## Cross-judge

Once every candidate has finished, start one read-only judge on a strong
model from a different provider than your own. Give it the rubric and the
candidates labeled by path, not by model. It scores each criterion and
recommends a base with its reasons. It runs while you do your own reading.
If no other provider is reachable, skip the judge and say so. Do not
substitute a judge from your own provider.

## Pick a base

Read every candidate end to end. Score each against the rubric criterion by
criterion, not on overall feel, then compare with the judge. Agreement
confirms the pick. Disagreement means one of you is biased or the rubric was
ambiguous, so read both rationales before deciding.

Pick the base a future maintainer can extend most easily without breaking
invariants. When two are tied, prefer the cleaner boundary or smaller API.

## Graft

Walk each losing candidate once more for what is worth porting, usually one
or two things, not most of it. Rewrite each graft into the base by hand so
the result reads as if it were designed that way from the start. Do not paste.

If the candidates converge on one shape, that is strong agreement. Ship it
and skip the graft. If they diverge wildly, the frame was under-specified.
Reframe and rerun instead of averaging.

## Verify

Check the result the way you would any finished work: run it, test it, and
show the evidence. If verification finds a problem the arena missed, either
the frame was wrong (reframe and rerun) or a candidate caught it and you
missed the graft (go back to Graft). Do not paper over it.

## Output

One synthesized artifact and a short note: the base and why, the judge's
verdict or that it was skipped, each graft with its source candidate, what
was rejected and why, any convergence or dropouts, and the verification
result.
