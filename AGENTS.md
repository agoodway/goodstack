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

## Descriptions

Amp shows the model only each skill's `name` and `description`, has no slash commands, and ignores `disable-model-invocation`. So the description alone decides whether any harness routes to the skill.

- Start with one sentence on what the skill does.
- Follow with `Use when` and the plain phrases a person would say, plus the skill's name, such as `or names gs-sharpen`. A slash command may be one trigger, never the only one.
- A skill with `disable-model-invocation: true` ends with `Only when the user asks for it.` or an equivalent. That sentence is Amp's version of the flag.
- Keep modes, pipelines, and other detail in the body. Keep the description under 1024 characters, with no em dashes.

## Skills that use other skills

- Reference a skill by name with a fallback: "use `gs-unslop` when it is installed; without it, <the short rule>".
- A skill may require another skill only when the fallback would be a full copy of that skill's rules. Then it stops before it changes any file, and gives the user the command that installs the other skill. Its `README.md` says which skill it needs. `gs-no-comments` requires `gs-find-bad-comments` this way.
- Reference skills, never another skill's files. Each skill installs into its own directory.
- A skill that other skills call stays model-invocable. `disable-model-invocation: true` is for skills only the user starts.
- The recovery contract and the "Fix every verify issue" step are byte-identical in `gs-openspec-ship` and `gs-openspec-ship-tickets`. Edit both together.

## Skills derived from another repo

- Take the text from the original repo at a pinned commit, and compare bytes against it. Grabbag is a pointer to the source, not the source.
- `LICENSE` in the skill directory carries the copyright holder's MIT notice. A skill merged from two sources carries both lines.
- `README.md` names the author, repo, path, and commit, then lists every change from the original. A copy that changes only front matter says so. This text goes in a `## Source` section, the last section of the file, after Install and Usage.
- Leave out upstream `agents/openai.yaml`.

## Adding, renaming, or removing a skill

A new skill needs these files:

1. `skills/gs-<name>/`: `SKILL.md`, `README.md`, and `LICENSE` when derived.
2. Root `README.md`: the skill's line under Skills, which opens with the skill name linked to `skills/gs-<name>/README.md`. A skill with `disable-model-invocation: true` also joins the sentence under "Who starts a skill". A derived skill also gets a row under Sources and changes the counts in Sources and License.
3. `test/list-skills.sh`: attribution checks for a derived skill. The test reads the skill list from `skills/`.

Every skill `README.md` opens with what the skill does. A `## Use cases` section follows, before Install. It lists one to three situations where someone would reach for the skill, one sentence each, taken from what `SKILL.md` does.

The root README's Skills section is the only list of skills, and the test fails when it differs from `skills/`. The root README installs every skill with `npx skills add agoodway/goodstack --skill '*'` and writes no total count. A skill's `README.md` gives no skill count and no list of other skills. It installs that skill alone and links to the root README's Install section for the rest. The test fails when a skill's `README.md` names another skill in an install command.

Skills may reference and edit each other when it makes sense, such as a pointer from one skill to a related one.

## Writing

READMEs and skills follow `gs-unslop`: whole sentences, plain words, a named actor, sentence-case headings, commas and periods for punctuation.
