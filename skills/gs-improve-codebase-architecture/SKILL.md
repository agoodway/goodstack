---
name: gs-improve-codebase-architecture
description: "Scan a codebase for deepening opportunities, present them as a visual HTML report, then question the user through whichever one they pick. Use when the user asks to improve the codebase architecture, find refactoring or deepening opportunities, find shallow modules, review where the architecture causes friction, or names gs-improve-codebase-architecture. Only when the user asks for it."
disable-model-invocation: true
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities**: refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

The project's domain model informs this skill, and it builds on a shared design vocabulary:

- Use `gs-codebase-design` when it is installed, for the architecture vocabulary (**module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**) and its principles (the deletion test, "the interface is the test surface", "one adapter means a hypothetical seam, two means a real one"). Without it, use these definitions:
  - **Module**: anything with an interface and an implementation, from a function to a package.
  - **Interface**: everything a caller must know to use the module: types, invariants, ordering, error modes, configuration, and performance.
  - **Depth**: how much behaviour a caller can exercise per unit of interface. A deep module hides a lot behind a small interface. A shallow module's interface is nearly as complex as its implementation.
  - **Seam**: the place where a module's interface lives, where behaviour can change without editing that place.
  - **Adapter**: a concrete thing that satisfies an interface at a seam.
  - **Leverage**: what callers get from depth, more capability per unit of interface.
  - **Locality**: what maintainers get from depth, change and bugs concentrated in one place.
  - The deletion test: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across callers, it earned its keep.

  Use these terms exactly in every suggestion. Don't drift into "component," "service," "API," or "boundary."
- When the project has a domain glossary (`GLOSSARY.md`), its terms name good seams. When it has ADRs in `docs/adr/`, they record decisions this skill should not re-litigate. A project may have neither.

## Process

### 1. Explore

**Scope before you scan: YAGNI.** Deepening a module pays off by making future changes to it easier, so put extra weight on the parts of the codebase that have recently changed. Decide *where* to look before you look:

- If the user named a direction (a module, a subsystem, a pain point), take it, and skip the inference below.
- Otherwise, walk back a good stretch of the commit history (`git log --oneline`) to find the codebase's hot spots, the files and areas that keep coming up, and let those paths pull your attention first. If the changes are scattered with no clear hot spot, widen the net.

Read `GLOSSARY.md` and any ADRs in the area you're touching first, when they exist.

Then use the harness's subagent tools to start one subagent with a fresh context window to walk the codebase. Give it the scope, the vocabulary above, and the questions below, and ask it to report the candidates with file paths. If the harness has no subagent tools, walk the codebase yourself in this session and say so.

Don't follow rigid heuristics. Explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow**, with an interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file. Open it for the user (`xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows) and tell them the absolute path.

The report uses **Tailwind via CDN** for layout and styling, and **Mermaid via CDN** for diagrams where a graph, flow, or sequence reliably communicates the structure. Mix Mermaid with hand-crafted CSS and SVG visuals: use Mermaid when relationships are graph-shaped (call graphs, dependencies, sequences), and hand-built divs or SVG when you want something more editorial (mass diagrams, cross-sections, collapse animations). Each candidate gets a **before/after visualisation**. Be visual.

For each candidate, render a card with:

- **Files**: which files and modules are involved
- **Problem**: why the current architecture is causing friction
- **Solution**: a plain English description of what would change
- **Benefits**: explained in terms of locality and leverage, and how tests would improve
- **Before / After diagram**: side by side, custom-drawn, showing the shallowness and the deepening
- **Recommendation strength**: one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge

End the report with a **Top recommendation** section: which candidate you'd tackle first and why.

**Use the glossary vocabulary for the domain, and the architecture vocabulary above for the architecture.** If `GLOSSARY.md` defines "Order," talk about "the Order intake module," not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly in the card (for example a warning callout: _"contradicts ADR-0007, but worth reopening because..."_). Don't list every theoretical refactor an ADR forbids.

See [HTML-REPORT.md](HTML-REPORT.md) for the full HTML scaffold, diagram patterns, and styling guidance.

Do NOT propose interfaces yet. After the file is written, ask the user: "Which of these would you like to explore?"

### 3. Question loop

Once the user picks a candidate, walk the decision tree with them. Ask one question at a time, wait for the answer, and let it shape the next question. Cover these decisions:

- **Constraints**: what must not change, such as callers you can't touch, performance limits, or a public contract.
- **Dependencies**: what the candidate talks to, and which category each dependency falls in: in-process, local-substitutable, ports and adapters, or mock.
- **The shape of the deepened module**: what its interface is, and what it absorbs from its callers.
- **What sits behind the seam**: which adapters exist now, and whether two of them justify the seam.
- **What tests survive**: which tests move to the new interface, which ones the change deletes, and what new test covers the behaviour the old ones guarded.

When the code or the docs can answer a question, look it up instead of asking. Give your recommended answer with each question, so the user can accept it or correct it. Stop when every decision above has an answer, then summarise the agreed design.

Handle the domain notes inline as decisions crystallise. Never create `GLOSSARY.md` or an ADR unless the user agrees.

- **Naming a deepened module after a concept not in `GLOSSARY.md`?** Offer to add the term. If the file doesn't exist, ask before you create it.
- **Sharpening a fuzzy term during the conversation?** When `GLOSSARY.md` exists, offer to update the entry right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when a future explorer would need the reason to avoid suggesting the same thing again. Skip passing reasons ("not worth it right now") and self-evident ones. If the user agrees, write a short ADR in `docs/adr/` that matches the numbering and format of the ones already there.
- **Want to explore alternative interfaces for the deepened module?** Use the design-it-twice pattern from `gs-codebase-design` when it is installed. Without it, use the harness's subagent tools to draft three or more radically different interfaces in parallel, each under a different constraint (smallest interface, most flexible, best for the common caller). Compare them on depth, locality, and seam placement, and recommend one. If the harness has no subagent tools, draft each design yourself, one constraint at a time, and say so.
