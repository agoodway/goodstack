---
name: gs-pr-comment
description: "Write and post a pull request or issue comment on GitHub on the user's behalf, with the agent attribution note, plain language, and the smallest picture that shows the point. Use whenever leaving a pull request or issue comment on GitHub for the user, or when the user names gs-pr-comment."
---

# PR comment

Write and post a GitHub comment on the user's behalf. Every such comment says an agent wrote it, reads like one engineer talking to another, and shows its point instead of describing it where a small picture is clearer.

## Attribution

Open every agent-authored comment with this GitHub note callout:

```md
> [!NOTE]
> 🤖 **<model> responding on behalf of <user>**

The comment starts here.
```

- `<model>` is the verified public name of the model that wrote the comment. If the harness does not expose a model name, use the harness name. Do not guess.
- `<user>` is the user's name or GitHub login.
- Keep the attribution inside the note and the comment outside it. The line starts with the robot emoji. It is the only emoji in the comment.
- Do not add a horizontal rule, a Setext underline, a heading, a signature footer, or a second attribution.

Apply this to top-level pull request and issue comments, inline review comments, replies to bots or reviewers, and written explanations posted before resolving or dismissing feedback. Do not add it to pull request descriptions, commit messages, or text the user asked to post verbatim without attribution.

## Writing

The reader knows the code and has not seen your reasoning.

Run the draft through the `gs-unslop` skill before posting. The rules below are the ones that matter most in a comment, and they are the whole standard when `gs-unslop` is not installed.

- Lead with the conclusion. End at the fix or the next step.
- Cite the code, behavior, check, or reproduction the point rests on. Write code references as `file:line` and put identifiers in backticks.
- State a verified fact as fact. State a judgment as a judgment, and say what you did not verify.
- Write whole sentences with their articles and verbs. Name the actor: "the retry runs `charge_card` twice", not "the charge is run twice".
- Use the plain word: "use", "because", "if". Give a number or a named mechanism in place of an adverb.
- Separate clauses with periods and commas. Do not use em dashes.
- Leave out greetings, thanks, sign-offs, filler, and narration of what you did to get here.
- Cut a sentence that would still be true of any other pull request.
- Bold at most the one word or phrase that opens the comment, such as a severity.

## Show it

When a picture makes the point faster than a sentence, add one. Pick the smallest view that fits, and put it directly under the sentence it supports. One view per comment is usually enough. A point that fits in a sentence needs no picture.

Use the `gs-show-me` skill to choose and draw the view. The views below are the ones GitHub renders well in a comment, and they are the whole list when `gs-show-me` is not installed. Do not write an HTML file for a comment.

- A `suggestion` block when the fix replaces exactly the lines the comment is anchored to. Anchor the comment to that whole range so the author can apply it in one click.

````md
```suggestion
rate = cart.empty? ? 0 : discount / item_count
```
````

- A `diff` block when the fix touches other lines or another file.
- A trace tree when one cause leads to the failure. One step per line, each nested under the step that causes it:

```text
the client retries POST /invoices/:id/pay
  charge_card runs a second time
    the customer pays twice
```

- Pseudocode with the missing case marked when a branch, boundary, or empty input is handled wrongly:

```text
on(apply_discount)
  if cart is empty      <- not handled, divides by zero
  rate = discount / item_count
```

- A Mermaid sequence diagram when the point depends on the order of events between two actors, such as a race or a retry. GitHub renders Mermaid in comments.
- A shallow file tree or call tree when the point is where something lives or what calls it.

Keep only the lines, calls, and states the reader needs to see the point.

## Post

1. Read the whole comment, including quoted text, command output, and attachments, for secrets, tokens, absolute local paths, and private details. Remove them.
2. Preview the final Markdown, so the callout, quoting, and blank lines render as intended.
3. Write the body to a file outside the repository and pass that file to the command, so comment text never becomes shell syntax. For example, `gh pr comment <number> --body-file <file>`, or `gh api ... --input <file>` for a review or an inline comment.
4. Confirm GitHub returned the comment or review URL.
5. Resolve a review thread only after its response was posted successfully.
