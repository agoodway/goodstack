# goodstack

Agent skills published for `npx skills add agoodway/goodstack`. Each skill installs alone, into any harness.

## Check

`bash test/list-skills.sh` prints `ok`. It needs network access and Node 22.20 or later. Run it after every change.

## Naming

Every skill is `gs-<name>`. The directory, the `name:` line, and the slash command all match. Upstream names stay unprefixed wherever a README credits the original.

## Portable skills

A skill reads the same in Claude Code, Codex, Cursor, Amp, and anything else.

- Name the job, and let the harness supply the tool: "the harness's subagent tools", "your file reading and search tools".
- Choose models in prose: the models the user names, otherwise the strongest the harness reaches, otherwise the session's model.
- Say what happens when the harness has no subagents, or reaches only one provider.
- Find the default branch with `git symbolic-ref --short refs/remotes/origin/HEAD`, then `git remote show origin`, then `main`.
- Pass text to `gh` from a file outside the repository.
- Arguments arrive in prose. Leave `$ARGUMENTS` out.

## Skills that use other skills

- Reference a skill by name with a fallback: "use `gs-unslop` when it is installed; without it, <the short rule>".
- Reference skills, never another skill's files. Each skill installs into its own directory.
- A skill that other skills call stays model-invocable. `disable-model-invocation: true` is for skills only the user starts.
- The recovery contract and the "Fix every verify issue" step are byte-identical in `gs-openspec-ship` and `gs-openspec-ship-tickets`. Edit both together.

## Skills derived from another repo

- Take the text from the original repo at a pinned commit, and compare bytes against it. Grabbag is a pointer to the source, not the source.
- `LICENSE` in the skill directory carries the copyright holder's MIT notice. A skill merged from two sources carries both lines.
- `README.md` names the author, repo, path, and commit, then lists every change from the original. A copy that changes only front matter says so.
- Leave out upstream `agents/openai.yaml`.

## Adding, renaming, or removing a skill

A new skill touches its own directory and the root `README.md`, and no other skill's files:

1. `skills/gs-<name>/`: `SKILL.md`, `README.md`, and `LICENSE` when derived.
2. Root `README.md`: the skill's line under Skills. A skill with `disable-model-invocation: true` also joins the sentence under "Who starts a skill". A derived skill also gets a row under Sources and changes the counts in Sources and License.
3. `test/list-skills.sh`: attribution checks for a derived skill. The test reads the skill list from `skills/`.

The root README's Skills section is the only list of skills, and the test fails when it differs from `skills/`. The root README installs every skill with `npx skills add agoodway/goodstack --skill '*'` and writes no total count. A skill's `README.md` installs that skill alone and links to the root README's Install section for the rest. The test fails when a skill's `README.md` names another skill in an install command.

## Writing

READMEs and skills follow `gs-unslop`: whole sentences, plain words, a named actor, sentence-case headings, commas and periods for punctuation.
