---
name: gs-how
description: "Explain subsystem architecture, runtime flow, and onboarding mental models. Use when the user asks how X works, wants a code walkthrough before changing something, asks a placement, ownership, or layering question ('where should this live', 'which package owns this', 'is this the right layer'), or names gs-how. Use gs-why for motivation."
---

# How

Explore the codebase to answer "how does X work?" questions. Produce architectural explanations at the level of a senior engineer onboarding onto a subsystem, enough to build a working mental model, not so much that it reads like annotated source code.

Run explorers and explainers as read-only subagents, using the harness's subagent tools. If the user names models, use those. Otherwise run explorers on a fast, capable model and the explainer on the strongest model the harness reaches. If the harness offers no model choice, use the session's model. If the harness has no subagent tools, do the exploring and explaining yourself, in this session, from the same prompts, and say so.

## 1. Assess complexity

If the scope is ambiguous, state your interpretation and explore. The user can redirect.

- **Simple** (a single module, a small utility, a narrow question such as "how does function X work"): no explorers. Start one explainer that explores and explains in one pass, built from `references/explainer-prompt.md` without the explorer-findings section. Go to step 4.
- **Complex** (a subsystem spanning multiple files or services, a cross-cutting feature, a full architectural overview): go to step 2.

When in doubt, take the simple path.

## 2. Explore (complex only)

Decompose the question into 2 to 4 angles, each a distinct slice of the subsystem. Start all explorers in parallel, each with `references/explorer-prompt.md` and its angle filled in.

## 3. Synthesize (complex only)

Once all explorers have returned, start one explainer with `references/explainer-prompt.md` and every explorer's findings filled in.

## 4. Present

Present the explainer's output. Light edits for clarity or context from the conversation are fine. Do not substantially rewrite it.

## Output format

The explanation uses the sections defined in `references/explainer-prompt.md`, dropping any that do not apply: Overview, Key Concepts, How It Works, Where Things Live, Gotchas.
