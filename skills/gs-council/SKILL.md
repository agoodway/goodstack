---
name: gs-council
description: Trigger this if the user says 'council'. Brings in three delegates on strong models from different providers to review the work or give feedback in parallel, scores each review round, and fixes the recommendations it agrees with until they are satisfied.
---

# Council

Before an audit, address outstanding PR comments, fix known issues, and run
relevant checks. Give council the updated implementation; do not defer known
fixes until reviews return. If the user wants to discard the implementation
and explore new ideas, skip fixes to code being replaced.

Bring in three delegates to help with the user's request, usually for review
or feedback. Use one strong model from each of three different providers, at
high reasoning effort when the harness lets you set it. If the user's
instructions name council members, use those. Otherwise pick the latest
flagship model from each provider the harness reaches, for example Claude
Opus, GPT Sol, and Gemini Pro.

Use the harness's subagent tools to start one delegate per model in parallel.
In T3 Code, for example, use `orchestrator_capabilities` to resolve the
models, then `delegate_task`. If a named member is unavailable, report it
instead of substituting. If the harness reaches fewer than three providers,
say which are missing, then fill the remaining seats with the strongest
models it does reach. If the harness has no subagent tools, tell the user and
stop.

Give each delegate the request and relevant context. For review or feedback,
keep their work read-only. Collect their responses and summarize the useful
findings, disagreements, and recommended next steps.

Do not wait idle. When a result arrives, check its findings against the code
at once and decide what to fix while the other delegates run. Do not edit
files while a delegate still reviews the same checkout. If the user's
instructions mark a delegate as non-blocking, do not wait for it; treat a
late result as feedback and do not record its score.

For a code review, ask each delegate for a score out of 10.
Count each full review pass as one round.
A fresh review after fixes starts a new round.

If the work ends in a pull request, put the results in the PR description.
If the description ends with a line naming the model and harness, put this
section before it:

```markdown
## Council review

Rounds: 2

| Delegate | Round 1 | Round 2 |
| --- | --- | --- |
| Claude Opus | 7/10 | 9/10 |
| GPT Sol | 8/10 | 10/10 |
| Gemini Pro | 7/10 | 9/10 |
```

If a delegate gives no score, write `no score`. Do not invent one.
If the PR is open, edit the description. Do not post a comment for this.
If there is no PR, put the same results in the final reply only.

If you agree with their recommendations, make the changes and request a fresh
review after. Continue this process until all delegates are satisfied with the
outcome.

Do not let repeated reviews result in scope creep. It is your job to fight to
keep scope limited.
