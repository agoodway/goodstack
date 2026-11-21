#!/usr/bin/env bash
# Drives `npx skills add` against this repo and checks every skill under skills/.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

LIST_OUT="$TMP/list.txt"
INSTALL_OUT="$TMP/install.txt"
ALL_OUT="$TMP/all.txt"

set +e
DISABLE_TELEMETRY=1 npx skills add "$ROOT" --list >"$LIST_OUT" 2>&1
LIST_EXIT=$?
DISABLE_TELEMETRY=1 npx skills add "$ROOT" --skill gs-scratch --skill gs-review -a claude-code -y --copy >"$INSTALL_OUT" 2>&1
INSTALL_EXIT=$?
mkdir "$TMP/all"
(cd "$TMP/all" && DISABLE_TELEMETRY=1 npx skills add "$ROOT" --skill '*' -a claude-code -y --copy) >"$ALL_OUT" 2>&1
ALL_EXIT=$?
set -e

python3 - "$ROOT" "$TMP" "$LIST_OUT" "$INSTALL_OUT" "$LIST_EXIT" "$INSTALL_EXIT" "$ALL_OUT" "$ALL_EXIT" <<'PY'
import hashlib
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
tmp = Path(sys.argv[2])
list_out = Path(sys.argv[3]).read_text(errors="replace")
install_out = Path(sys.argv[4]).read_text(errors="replace")
list_exit = int(sys.argv[5])
install_exit = int(sys.argv[6])
all_out = Path(sys.argv[7]).read_text(errors="replace")
all_exit = int(sys.argv[8])

# skills/ is the source of truth. Adding a skill directory needs no edit here.
expected = sorted(p.name for p in (root / "skills").iterdir() if p.is_dir())
expected_set = set(expected)

if list_exit != 0:
    sys.exit(f"npx skills add --list exited {list_exit}\n{list_out}")
if install_exit != 0:
    sys.exit(f"npx skills add install exited {install_exit}\n{install_out}")
if all_exit != 0:
    sys.exit(f"npx skills add --skill '*' exited {all_exit}\n{all_out}")

clean = re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "", list_out)
cli_names = re.findall(r"(?m)^│    ([a-z0-9-]+)$", clean)
found = re.search(r"Found (\d+) skills", clean)
if found is None or int(found.group(1)) != len(expected):
    sys.exit(f"expected 'Found {len(expected)} skills' in list output, got count {found.group(1) if found else None}\n{clean}")
if set(cli_names) != expected_set or len(cli_names) != len(expected):
    sys.exit(f"CLI listed {cli_names}, expected {expected}")
if "scratchpad" in clean:
    sys.exit("CLI list mentioned scratchpad")

frontmatter = {}
skill_dirs = [root / "skills" / name for name in expected]
for skill_dir in skill_dirs:
    if not skill_dir.name.startswith("gs-"):
        sys.exit(f"skill directory {skill_dir.name} does not start with gs-")
for skill_dir in skill_dirs:
    text = (skill_dir / "SKILL.md").read_text()
    match = re.search(r"(?m)^name:\s*(\S+)\s*$", text)
    if match is None:
        sys.exit(f"{skill_dir.name} SKILL.md has no name")
    frontmatter[skill_dir.name] = match.group(1).strip('"')
if frontmatter != {name: name for name in expected_set}:
    sys.exit(f"frontmatter names {frontmatter}")
outside = [p for p in root.rglob("SKILL.md") if p.parent.parent != (root / "skills")]
if outside:
    sys.exit(f"unexpected SKILL.md files: {outside}")

scratch = (root / "skills" / "gs-scratch" / "SKILL.md").read_text()
for banned in (".scratchpad", "/scratchpad", "scratchpad"):
    if banned in scratch:
        sys.exit(f"gs-scratch SKILL.md still contains {banned}")
if "name: gs-scratch" not in scratch or ".scratch" not in scratch:
    sys.exit("gs-scratch SKILL.md missing name or .scratch")
for command in ("/gs-scratch bootstrap", "/gs-scratch write", "/gs-scratch edit", "/gs-scratch list"):
    if command not in scratch:
        sys.exit(f"gs-scratch SKILL.md missing {command}")

git_skill = (root / "skills" / "gs-git-commit" / "SKILL.md").read_text()
for banned in ("/git commit", "/git pr", "commit-all", "pr-update", "pr-pull-review", "/git help"):
    if banned in git_skill:
        sys.exit(f"gs-git-commit SKILL.md still has subcommand {banned}")
for required in (".env", "node_modules/", "credentials.", ".gitignore", "Do not open a pull request"):
    if required not in git_skill:
        sys.exit(f"gs-git-commit SKILL.md missing {required}")

pr_skill = (root / "skills" / "gs-pull-request" / "SKILL.md").read_text()
for required in ("## What changed", "## How it works", "## Evidence", "## What could break", "## How to check", "Safe because: <the one fact", "gh pr create --draft", "/gs-git-commit"):
    if required not in pr_skill:
        sys.exit(f"gs-pull-request SKILL.md missing {required}")

# blast-radius is adapted from the pstack original, so it has no hash pin.
blast_license = (root / "skills" / "gs-blast-radius" / "LICENSE").read_text()
if "Copyright (c) 2026 Lauren Tan" not in blast_license or "MIT License" not in blast_license:
    sys.exit("gs-blast-radius LICENSE missing the pstack MIT notice")
blast_readme = (root / "skills" / "gs-blast-radius" / "README.md").read_text()
for snippet in (
    "Lauren Tan",
    "https://github.com/cursor/plugins",
    "pstack/skills/blast-radius",
    "df581122cde17e6e27686b5a448bde23e4ad4318",
    "themusicman/grabbag",
):
    if snippet not in blast_readme:
        sys.exit(f"gs-blast-radius README missing {snippet}")

# gs-no-comments is adapted from a pstack skill and agent, so it has no hash pin.
no_comments_dir = root / "skills" / "gs-no-comments"
no_comments_license = (no_comments_dir / "LICENSE").read_text()
if "Copyright (c) 2026 Lauren Tan" not in no_comments_license or "MIT License" not in no_comments_license:
    sys.exit("gs-no-comments LICENSE missing the pstack MIT notice")
no_comments_readme = (no_comments_dir / "README.md").read_text()
for snippet in (
    "Lauren Tan",
    "https://github.com/cursor/plugins",
    "pstack/skills/no-comments/SKILL.md",
    "pstack/agents/comment-sicko.md",
    "bf0c7cd80abdbf7fe47b634978a7d1b4071f71a7",
):
    if snippet not in no_comments_readme:
        sys.exit(f"gs-no-comments README missing {snippet}")
# gs-find-bad-comments holds the comment rules. gs-no-comments keeps no copy and stops without it.
if (no_comments_dir / "references" / "comment-sicko.md").exists():
    sys.exit("gs-no-comments must not keep a copy of the rules in gs-find-bad-comments")
no_comments_skill = (no_comments_dir / "SKILL.md").read_text()
for snippet in (
    "`gs-find-bad-comments` is not installed. Stop before you change any file.",
    "npx skills add agoodway/goodstack --skill gs-find-bad-comments",
):
    if snippet not in no_comments_skill:
        sys.exit(f"gs-no-comments SKILL.md missing {snippet}")

# gs-find-bad-comments is the finding half of gs-no-comments, so it shares its sources.
find_comments_dir = root / "skills" / "gs-find-bad-comments"
find_comments_license = (find_comments_dir / "LICENSE").read_text()
if "Copyright (c) 2026 Lauren Tan" not in find_comments_license or "MIT License" not in find_comments_license:
    sys.exit("gs-find-bad-comments LICENSE missing the pstack MIT notice")
find_comments_readme = (find_comments_dir / "README.md").read_text()
for snippet in (
    "Lauren Tan",
    "https://github.com/cursor/plugins",
    "pstack/skills/no-comments/SKILL.md",
    "pstack/agents/comment-sicko.md",
    "bf0c7cd80abdbf7fe47b634978a7d1b4071f71a7",
):
    if snippet not in find_comments_readme:
        sys.exit(f"gs-find-bad-comments README missing {snippet}")
find_comments_skill = (find_comments_dir / "SKILL.md").read_text()
if "Change no file." not in find_comments_skill:
    sys.exit("gs-find-bad-comments SKILL.md must stay read-only")
if "disable-model-invocation" in find_comments_skill:
    sys.exit("gs-find-bad-comments is called by other skills, so it stays model-invocable")

# gs-unslop differs from the pstack original only in its name line, so it has no hash pin.
unslop_license = (root / "skills" / "gs-unslop" / "LICENSE").read_text()
if "Copyright (c) 2026 Lauren Tan" not in unslop_license or "MIT License" not in unslop_license:
    sys.exit("gs-unslop LICENSE missing the pstack MIT notice")
unslop_readme = (root / "skills" / "gs-unslop" / "README.md").read_text()
for snippet in (
    "Lauren Tan",
    "https://github.com/cursor/plugins",
    "pstack/skills/unslop",
    "bc697d0a5a163cec979e362b601e36f5616083fd",
    "themusicman/grabbag",
):
    if snippet not in unslop_readme:
        sys.exit(f"gs-unslop README missing {snippet}")

# gs-deslop differs from the cursor-team-kit original only in its name and a pointer to gs-no-comments, so it has no hash pin.
deslop_license = (root / "skills" / "gs-deslop" / "LICENSE").read_text()
if "Copyright (c) 2026 Cursor" not in deslop_license or "MIT License" not in deslop_license:
    sys.exit("gs-deslop LICENSE missing the Cursor MIT notice")
deslop_readme = (root / "skills" / "gs-deslop" / "README.md").read_text()
for snippet in (
    "Cursor",
    "https://github.com/cursor/plugins",
    "cursor-team-kit/skills/deslop",
    "b21ab167c8d6aad6e4d91bc0de429eedd49665ed",
    "https://github.com/themusicman/grabbag/blob/main/skills/deslop/SOURCE.md",
    "themusicman/grabbag",
):
    if snippet not in deslop_readme:
        sys.exit(f"gs-deslop README missing {snippet}")

# how, why, arena, statechart, and the verification skills are adapted from the pstack originals, so they have no hash pin.
pstack_skills = {
    "gs-how": (
        "ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a",
        "pstack/skills/how",
        ("references/explainer-prompt.md", "references/explorer-prompt.md"),
    ),
    "gs-why": (
        "ce649c03ac3b75b6ae80cbd15b7e2c536caedb5a",
        "pstack/skills/why",
        ("references/epistemics.md", "references/synthesizer-prompt.md"),
    ),
    "gs-arena": (
        "ab1f702ce8e8b6557edb56b09f52cde8bfb83f17",
        "pstack/skills/arena",
        (),
    ),
    "gs-create-verification-skill": (
        "e58dd043600587dbaf58ba315e7f2b38373eeb43",
        "pstack/skills/create-verification-skill",
        (
            "references/feature-map-example/README.md",
            "references/feature-map-example/search.md",
            "references/feature-map-example/create-note.md",
        ),
    ),
    "gs-maintain-verification-skill": (
        "e58dd043600587dbaf58ba315e7f2b38373eeb43",
        "pstack/skills/maintain-verification-skill",
        (),
    ),
    "gs-create-formal-verification-skill": (
        "aaeb0ea3a0584995aa8f55ce44c6c5259414b896",
        "pstack/skills/create-formal-verification-skill",
        (),
    ),
    "gs-maintain-formal-verification-skill": (
        "aaeb0ea3a0584995aa8f55ce44c6c5259414b896",
        "pstack/skills/maintain-formal-verification-skill",
        (),
    ),
    "gs-statechart": (
        "aaeb0ea3a0584995aa8f55ce44c6c5259414b896",
        "pstack/skills/statechart",
        (
            "references/render.md",
            "scripts/statechart",
            "scripts/statechart.ts",
            "scripts/package.json",
            "scripts/tsconfig.json",
            "scripts/test/cli.test.ts",
            "scripts/test/corpus/CounterStart/CounterStart.tla",
        ),
    ),
}
for skill, (commit, source_path, required_files) in pstack_skills.items():
    skill_dir = root / "skills" / skill
    license_text = (skill_dir / "LICENSE").read_text()
    if "Copyright (c) 2026 Lauren Tan" not in license_text or "MIT License" not in license_text:
        sys.exit(f"{skill} LICENSE missing the pstack MIT notice")
    readme = (skill_dir / "README.md").read_text()
    for snippet in ("Lauren Tan", "https://github.com/cursor/plugins", source_path, commit):
        if snippet not in readme:
            sys.exit(f"{skill} README missing {snippet}")
    for rel in required_files:
        if not (skill_dir / rel).is_file():
            sys.exit(f"{skill} missing {rel}")

wait_dir = root / "skills" / "gs-wait-what"
wait_license = (wait_dir / "LICENSE").read_text()
for holder in ("Copyright (c) 2026 Lauren Tan", "Copyright (c) 2026 Matt Pocock", "MIT License"):
    if holder not in wait_license:
        sys.exit(f"gs-wait-what LICENSE missing {holder}")
wait_readme = (wait_dir / "README.md").read_text()
for snippet in (
    "Lauren Tan",
    "pstack/skills/bro",
    "99559f2f52047978602ef365589275831e76af07",
    "Matt Pocock",
    "skills/productivity/wait-what",
    "4ae2317ddb22b046e26455e4f9c9b3aaaf62212d",
    "themusicman/grabbag",
):
    if snippet not in wait_readme:
        sys.exit(f"gs-wait-what README missing {snippet}")

show_dir = root / "skills" / "gs-show-me"
# show-me is adapted from the HumanLayer original, so it has no hash pin.
show_license = (show_dir / "LICENSE").read_text()
if "Copyright (c) 2026 HumanLayer" not in show_license or "MIT License" not in show_license:
    sys.exit("gs-show-me LICENSE missing the HumanLayer MIT notice")
show_readme = (show_dir / "README.md").read_text()
for snippet in (
    "HumanLayer",
    "https://github.com/humanlayer/skills",
    "plugins/show-me/skills/show-me",
    "4d69d20f6e9b57b4fcf0d501ccfb1be961f0f329",
    "themusicman/grabbag",
):
    if snippet not in show_readme:
        sys.exit(f"gs-show-me README missing {snippet}")

comment_dir = root / "skills" / "gs-pr-comment"
comment_license = (comment_dir / "LICENSE").read_text()
if "Copyright (c) 2026 Theo Browne" not in comment_license or "MIT License" not in comment_license:
    sys.exit("gs-pr-comment LICENSE missing the tstack MIT notice")
comment_readme = (comment_dir / "README.md").read_text()
for snippet in (
    "Theo Browne",
    "https://github.com/t3dotgg/tstack",
    "skills/leaving-pr-comments",
    "6efae364201abc9d9f07443e9caa461f42e51090",
    "themusicman/grabbag",
):
    if snippet not in comment_readme:
        sys.exit(f"gs-pr-comment README missing {snippet}")
comment_skill = (comment_dir / "SKILL.md").read_text()
for required in ("> [!NOTE]", "responding on behalf of", "--body-file"):
    if required not in comment_skill:
        sys.exit(f"gs-pr-comment SKILL.md missing {required}")

council_dir = root / "skills" / "gs-council"
council_license = (council_dir / "LICENSE").read_text()
if "Copyright (c) 2026 Theo Browne" not in council_license or "MIT License" not in council_license:
    sys.exit("gs-council LICENSE missing the tstack MIT notice")
council_readme = (council_dir / "README.md").read_text()
for snippet in (
    "Theo Browne",
    "https://github.com/t3dotgg/tstack",
    "skills/council/SKILL.md",
    "11e37a74d0a6868c121cd0910ab2b3bd9873b92a",
):
    if snippet not in council_readme:
        sys.exit(f"gs-council README missing {snippet}")

reflect_dir = root / "skills" / "gs-reflect"
reflect_license = (reflect_dir / "LICENSE").read_text()
for holder in ("Copyright (c) 2026 Lauren Tan", "Copyright (c) 2026 Matt Pocock", "MIT License"):
    if holder not in reflect_license:
        sys.exit(f"gs-reflect LICENSE missing {holder}")
reflect_readme = (reflect_dir / "README.md").read_text()
for snippet in (
    "Lauren Tan",
    "pstack/skills/reflect",
    "7054003c3723e82d099fb7620e3bc8d7d63eebc6",
    "Matt Pocock",
    "skills/engineering/retro",
    "4ae2317ddb22b046e26455e4f9c9b3aaaf62212d",
    "themusicman/grabbag",
):
    if snippet not in reflect_readme:
        sys.exit(f"gs-reflect README missing {snippet}")
for rel in (
    "references/judgment-reviewer.md",
    "references/tooling-reviewer.md",
    "references/divergent-reviewer.md",
    "references/environment-reviewer.md",
    "references/synthesizer.md",
):
    if not (reflect_dir / rel).is_file():
        sys.exit(f"gs-reflect missing {rel}")

sharpen_dir = root / "skills" / "gs-sharpen"
sharpen_license = (sharpen_dir / "LICENSE").read_text()
if "Copyright (c) 2026 Lauren Tan" not in sharpen_license or "MIT License" not in sharpen_license:
    sys.exit("gs-sharpen LICENSE missing the pstack MIT notice")
sharpen_readme = (sharpen_dir / "README.md").read_text()
for snippet in ("Lauren Tan", "https://github.com/cursor/plugins", "pstack/skills/sharpen", "88d47514b82e7c44f00f2b2a72ff6dd12158038c", "themusicman/grabbag"):
    if snippet not in sharpen_readme:
        sys.exit(f"gs-sharpen README missing {snippet}")

prototype_dir = root / "skills" / "gs-prototype"
prototype_license = (prototype_dir / "LICENSE").read_text()
if "Copyright (c) 2026 Matt Pocock" not in prototype_license or "MIT License" not in prototype_license:
    sys.exit("gs-prototype LICENSE missing Matt Pocock's MIT notice")
prototype_readme = (prototype_dir / "README.md").read_text()
for snippet in ("Matt Pocock", "https://github.com/mattpocock/skills", "skills/engineering/prototype", "4ae2317ddb22b046e26455e4f9c9b3aaaf62212d", "themusicman/grabbag"):
    if snippet not in prototype_readme:
        sys.exit(f"gs-prototype README missing {snippet}")
for rel in ("LOGIC.md", "UI.md"):
    if not (prototype_dir / rel).is_file():
        sys.exit(f"gs-prototype missing {rel}")

design_dir = root / "skills" / "gs-codebase-design"
design_license = (design_dir / "LICENSE").read_text()
if "Copyright (c) 2026 Matt Pocock" not in design_license or "MIT License" not in design_license:
    sys.exit("gs-codebase-design LICENSE missing Matt Pocock's MIT notice")
design_readme = (design_dir / "README.md").read_text()
for snippet in ("Matt Pocock", "https://github.com/mattpocock/skills", "skills/engineering/codebase-design", "4ae2317ddb22b046e26455e4f9c9b3aaaf62212d", "themusicman/grabbag"):
    if snippet not in design_readme:
        sys.exit(f"gs-codebase-design README missing {snippet}")
for rel in ("DEEPENING.md", "DESIGN-IT-TWICE.md"):
    if not (design_dir / rel).is_file():
        sys.exit(f"gs-codebase-design missing {rel}")

architecture_dir = root / "skills" / "gs-improve-codebase-architecture"
architecture_license = (architecture_dir / "LICENSE").read_text()
if "Copyright (c) 2026 Matt Pocock" not in architecture_license or "MIT License" not in architecture_license:
    sys.exit("gs-improve-codebase-architecture LICENSE missing Matt Pocock's MIT notice")
architecture_readme = (architecture_dir / "README.md").read_text()
for snippet in ("Matt Pocock", "https://github.com/mattpocock/skills", "skills/engineering/improve-codebase-architecture", "abeeaf95660ba9e8b7c753eb38f441ca707a8823"):
    if snippet not in architecture_readme:
        sys.exit(f"gs-improve-codebase-architecture README missing {snippet}")
if not (architecture_dir / "HTML-REPORT.md").is_file():
    sys.exit("gs-improve-codebase-architecture missing HTML-REPORT.md")
if (architecture_dir / "agents").exists():
    sys.exit("gs-improve-codebase-architecture includes upstream agents/")
architecture_skill = (architecture_dir / "SKILL.md").read_text()
for required in ("disable-model-invocation: true", "Only when the user asks for it.", "gs-codebase-design", "no subagent tools"):
    if required not in architecture_skill:
        sys.exit(f"gs-improve-codebase-architecture SKILL.md missing {required}")
# The grilling and domain-modeling skills are not ported, so nothing may call them.
for path in (architecture_dir / "SKILL.md", architecture_dir / "HTML-REPORT.md"):
    text = path.read_text()
    for banned in ("grilling", "domain-modeling", "Skill tool", "/codebase-design", "\u2014"):
        if banned in text:
            sys.exit(f"gs-improve-codebase-architecture {path.name} contains {banned!r}")

# gs-openspec-to-tickets is rebuilt from Matt Pocock's to-tickets, so it has no hash pin.
tickets_dir = root / "skills" / "gs-openspec-to-tickets"
tickets_license = (tickets_dir / "LICENSE").read_text()
if "Copyright (c) 2026 Matt Pocock" not in tickets_license or "MIT License" not in tickets_license:
    sys.exit("gs-openspec-to-tickets LICENSE missing Matt Pocock's MIT notice")
tickets_readme = (tickets_dir / "README.md").read_text()
for snippet in ("Matt Pocock", "https://github.com/mattpocock/skills", "skills/engineering/to-tickets", "4ae2317ddb22b046e26455e4f9c9b3aaaf62212d"):
    if snippet not in tickets_readme:
        sys.exit(f"gs-openspec-to-tickets README missing {snippet}")
for rel in ("tracker-github.md", "tracker-linear.md", "tracker-jira.md", "tracker-local.md"):
    if not (tickets_dir / rel).is_file():
        sys.exit(f"gs-openspec-to-tickets missing {rel}")

# gs-prune-tests is adapted from the caldoai original, so it has no hash pin.
prune_dir = root / "skills" / "gs-prune-tests"
prune_license = (prune_dir / "LICENSE").read_text()
for holder in ("Copyright (c) 2026 Maze", "Copyright (c) 2026 Matt Pocock", "MIT License"):
    if holder not in prune_license:
        sys.exit(f"gs-prune-tests LICENSE missing {holder}")
prune_readme = (prune_dir / "README.md").read_text()
for snippet in (
    "Maze",
    "https://github.com/caldoai/skills",
    "skills/prune-tests/SKILL.md",
    "bd73b2ea5eb854ab8f0553fb41f77c8786f28f82",
    "Matt Pocock",
    "https://github.com/mattpocock/skills",
    "skills/engineering/tdd/tests.md",
    "43ea0884b07a3e67a5a07f025ce92aefa983177b",
):
    if snippet not in prune_readme:
        sys.exit(f"gs-prune-tests README missing {snippet}")
if "skills/engineering/tdd/mocking.md" not in prune_readme:
    sys.exit("gs-prune-tests README missing skills/engineering/tdd/mocking.md")
prune_skill = (prune_dir / "SKILL.md").read_text()
if "argument-hint" in prune_skill or "$ARGUMENTS" in prune_skill:
    sys.exit("gs-prune-tests SKILL.md takes arguments in prose")
if "`gs-find-bad-tests`" not in prune_skill or "Without it, apply this short rule." not in prune_skill:
    sys.exit("gs-prune-tests SKILL.md must use gs-find-bad-tests with a fallback")

# gs-find-bad-tests is the finding half of gs-prune-tests, so it shares both sources.
find_dir = root / "skills" / "gs-find-bad-tests"
find_license = (find_dir / "LICENSE").read_text()
for holder in ("Copyright (c) 2026 Maze", "Copyright (c) 2026 Matt Pocock", "MIT License"):
    if holder not in find_license:
        sys.exit(f"gs-find-bad-tests LICENSE missing {holder}")
find_readme = (find_dir / "README.md").read_text()
for snippet in (
    "Maze",
    "https://github.com/caldoai/skills",
    "skills/prune-tests/SKILL.md",
    "bd73b2ea5eb854ab8f0553fb41f77c8786f28f82",
    "Matt Pocock",
    "https://github.com/mattpocock/skills",
    "skills/engineering/tdd/tests.md",
    "43ea0884b07a3e67a5a07f025ce92aefa983177b",
):
    if snippet not in find_readme:
        sys.exit(f"gs-find-bad-tests README missing {snippet}")
if "skills/engineering/tdd/mocking.md" not in find_readme:
    sys.exit("gs-find-bad-tests README missing skills/engineering/tdd/mocking.md")
find_skill = (find_dir / "SKILL.md").read_text()
if "argument-hint" in find_skill or "$ARGUMENTS" in find_skill:
    sys.exit("gs-find-bad-tests SKILL.md takes arguments in prose")
if "Change no file." not in find_skill:
    sys.exit("gs-find-bad-tests SKILL.md must stay read-only")

# Goodflows parses the change-claims/2 front matter, so its keys and their order stay fixed.
cr_skill = (root / "skills" / "gs-change-request" / "SKILL.md").read_text()
cr_block = re.search(r"(?ms)^```markdown\n---\n(format: change-claims/2\n.*?)^---\n\n# ", cr_skill)
if cr_block is None:
    sys.exit("gs-change-request SKILL.md has no change-claims/2 front matter before its # title")
cr_top = re.findall(r"(?m)^([a-z_]+):", cr_block.group(1))
if cr_top != ["format", "cr", "head", "door", "door_reason", "reach", "safe_because", "left_open", "questions", "decisions"]:
    sys.exit(f"gs-change-request front matter keys changed: {cr_top}")
cr_nested = set(re.findall(r"(?m)^ +-? *([a-z_]+):", cr_block.group(1)))
for key in ("fact", "location", "proof", "evidence", "covers", "capability", "requirement", "scenario", "risk", "affected", "id", "text", "options", "recommendation", "path", "hunk", "note"):
    if key not in cr_nested:
        sys.exit(f"gs-change-request front matter missing {key}")
for required in (
    "## What changed", "## How it works", "## Evidence", "## What could break", "## How to check",
    "`stated`, `pointed`, `walked`, or `ran`", "`one_way` or `two_way`", "Do not invent output.",
    "A run built from a dirty working tree tested code that no commit holds",
    ".goodflows/change-requests/<branch>/cr.md", "info/exclude", "git patch-id --verbatim", "not `--stable`", ".detached/<short SHA>/cr.md", "rewrite only `head`",
    "do not push, do not open a pull request, and do not call a host API",
    "Read `--approved` from the request's prose.",
    "command -v goodflows",
    "Without evidence, a fact is `walked` at most.",
    "Add one `safe_because` fact for each such row",
    "`status: no_check`",
    "Safe because: <each fact",
    "Read `--commit` from the request's prose.",
    "Skip its last step, which asks whether to push, because this skill never pushes.",
    "`--commit` never creates the change request. Only `--approved` does.",
    "Do not guess a command.",
    "run the update command for that number instead",
):
    if required not in cr_skill:
        sys.exit(f"gs-change-request SKILL.md missing {required}")
for banned in ("gh pr create", "gh pr edit", "git push", "--attach", "\u2014", "$ARGUMENTS"):
    if banned in cr_skill:
        sys.exit(f"gs-change-request SKILL.md must not contain {banned!r}")

pr_show = (root / "skills" / "gs-pr-show-me" / "SKILL.md").read_text()
for required in ("gs-pull-request", "gs-show-me", "gh pr view", "gh pr diff", "## Where to look first", "read-only"):
    if required not in pr_show:
        sys.exit(f"gs-pr-show-me SKILL.md missing {required}")

# The verification pair must stay harness-neutral and run without subagents.
create_verify = (root / "skills" / "gs-create-verification-skill" / "SKILL.md").read_text()
if ".cursor/skills/verify-" in create_verify:
    sys.exit("gs-create-verification-skill SKILL.md hardcodes .cursor/skills/verify-")
maintain_verify = (root / "skills" / "gs-maintain-verification-skill" / "SKILL.md").read_text()
if "When the harness has no subagents" not in maintain_verify:
    sys.exit("gs-maintain-verification-skill SKILL.md missing the no-subagent fallback")

# The formal verification pair names gs-statechart with a fallback and never links outside the repo.
for skill in ("gs-create-formal-verification-skill", "gs-maintain-formal-verification-skill"):
    text = (root / "skills" / skill / "SKILL.md").read_text()
    for banned in ("/statechart", "../", "/create-formal", "/maintain-formal", "\u2014"):
        if banned in text:
            sys.exit(f"{skill} SKILL.md contains {banned!r}")
    for required in ("`gs-statechart`", "shortest sequence of steps in the code's own words", ".verify/<area>/<run-id>/", "run.md", "Only when the user asks for it."):
        if required not in text:
            sys.exit(f"{skill} SKILL.md missing {required}")

qa_skill = (root / "skills" / "gs-qa-scenarios" / "SKILL.md").read_text()
for required in ("gs-pull-request", "gs-blast-radius", "gs-show-me", "gs-unslop", "## Setup", "## Scenarios", "## Regression checks", "## Checklist", "- Expect:", "--body-file"):
    if required not in qa_skill:
        sys.exit(f"gs-qa-scenarios SKILL.md missing {required}")
if "$ARGUMENTS" in qa_skill:
    sys.exit("gs-qa-scenarios SKILL.md takes arguments in prose")
# The run modes drive the app only through a project verify-* skill and keep evidence in .verify/.
for required in (
    "## Modes",
    "**write**: the default",
    "**write and run**",
    "**run**",
    "[write | write and run | run]",
    "`verify-*` skill",
    ".cursor/skills/",
    ".claude/skills/",
    ".agents/skills/",
    "gs-create-verification-skill",
    "gs-maintain-verification-skill",
    "Launch, Doctor, Drive, Evidence, and Cleanup",
    ".verify/<app>/<run-id>/",
    "run.md",
    "Never stage or commit anything under `.verify/`",
    "Never edit a scenario to make it pass",
    "In write and run mode, skip that walk",
    "> [!NOTE]",
    "**Passed**",
    "**Failed**",
    "**Not run**",
):
    if required not in qa_skill:
        sys.exit(f"gs-qa-scenarios SKILL.md missing {required}")
qa_description = re.search(r'(?m)^description:\s*"(.*)"\s*$', qa_skill)
if qa_description is None or len(qa_description.group(1)) >= 1024:
    sys.exit("gs-qa-scenarios description is missing or not under 1024 characters")
for phrase in ("run the QA scenarios", "automate the QA steps", "verify-*"):
    if phrase not in qa_description.group(1):
        sys.exit(f"gs-qa-scenarios description missing {phrase}")
if "skills/gs-create-verification-skill" in qa_skill or "skills/gs-maintain-verification-skill" in qa_skill:
    sys.exit("gs-qa-scenarios SKILL.md references a verification skill by path")

# gs-openspec-qa-scenarios writes the gs-qa-scenarios shape from specs. Other tools parse both, so the markers stay fixed.
# Goodflows parses the qa-scenarios/2 front matter both skills write, so its fields stay fixed.
def front_matter_keys(text, source):
    block = re.search(rf"(?ms)^```markdown\n---\nformat: qa-scenarios/2\nsource: {source}\n(.*?)^---\n\n# QA: ", text)
    if block is None:
        return None
    return re.findall(r"(?m)^[ -]*([a-z_]+):", block.group(1))
diff_keys = front_matter_keys(qa_skill, "diff")
if diff_keys is None:
    sys.exit("gs-qa-scenarios SKILL.md has no qa-scenarios/2 front matter with source: diff before its # QA: heading")
for required in ("`source: intent`", "info string is `yaml qa-scenarios`", "`failed_step`", "`not_run`", "`evidence`", "run:\n  folder:"):
    if required not in qa_skill:
        sys.exit(f"gs-qa-scenarios SKILL.md missing {required}")
intent_skill = (root / "skills" / "gs-openspec-qa-scenarios" / "SKILL.md").read_text()
for required in (
    "info string is `yaml qa-scenarios`",
    "## Setup",
    "## Checklist",
    "## Scenarios",
    "## Regression checks",
    "## Coverage",
    "## Not covered by these scenarios",
    "## Questions for the developer",
    "Covers: [capability] \u00b7 [Requirement]: [Scenario]",
    "- Expect:",
    "(Must)",
    "No observable check: ",
    "npx skills add agoodway/goodstack --skill gs-qa-scenarios",
    "find its installed `SKILL.md`",
):
    if required not in intent_skill:
        sys.exit(f"gs-openspec-qa-scenarios SKILL.md missing {required}")
intent_keys = front_matter_keys(intent_skill, "intent")
if intent_keys is None:
    sys.exit("gs-openspec-qa-scenarios SKILL.md has no qa-scenarios/2 front matter with source: intent before its # QA: heading")
if diff_keys[:4] != ["branch", "base", "revision", "review"] or intent_keys[:3] != ["change", "specs", "review"]:
    sys.exit(f"front matter identity keys changed: diff {diff_keys[:4]}, intent {intent_keys[:3]}")
# review names the change under review on any Git host. Sets written before it carry pr, which run mode still reads.
if "pr" in diff_keys or "pr" in intent_keys:
    sys.exit("qa scenario front matter must use the host-neutral review key, not pr")
if "has a `pr` key" not in qa_skill:
    sys.exit("gs-qa-scenarios run mode must still read sets that carry pr")
for shared in ("scenarios", "id", "name", "priority"):
    if shared not in diff_keys or shared not in intent_keys:
        sys.exit(f"front matter key {shared} missing from one of the qa scenario skills")
for intent_only in ("covers", "capability", "requirement", "scenario", "implied", "coverage", "status"):
    if intent_only not in intent_keys:
        sys.exit(f"gs-openspec-qa-scenarios front matter missing {intent_only}")
# Goodflows matches a coverage row to a covers entry or a safe_because fact by its capability, requirement, and scenario.
coverage_block = re.search(r"(?ms)^coverage:\n(.*?)^---\n", intent_skill)
coverage_rows = [re.findall(r"(?m)^ *([a-z_]+):", row) for row in re.split(r"(?m)^  - ", coverage_block.group(1))[1:]] if coverage_block else []
if not coverage_rows:
    sys.exit("gs-openspec-qa-scenarios front matter has no coverage rows")
for row in coverage_rows:
    if row[:5] != ["capability", "requirement", "scenario", "status", "scenarios"] or not set(row) <= {"capability", "requirement", "scenario", "status", "scenarios", "reason"}:
        sys.exit(f"gs-openspec-qa-scenarios coverage row keys changed: {row}")
for required in ("`covered` or `no_check`", "Each of the three is 1 to 200 characters"):
    if required not in intent_skill:
        sys.exit(f"gs-openspec-qa-scenarios SKILL.md missing {required}")
if "A `qa-scenarios/1` set has `delta`, `qa`, and `no_check`" not in qa_skill:
    sys.exit("gs-qa-scenarios run mode must still read qa-scenarios/1 intent sets")
if "$ARGUMENTS" in intent_skill or "\u2014" in intent_skill:
    sys.exit("gs-openspec-qa-scenarios SKILL.md takes arguments in prose and has no em dashes")

all_installed = {p.parent.name for p in (tmp / "all").rglob("SKILL.md")}
if all_installed != expected_set:
    sys.exit(f"--skill '*' installed {sorted(all_installed)}, expected {expected}")

installed = [p for p in tmp.rglob("SKILL.md") if (tmp / "all") not in p.parents]
by_name = {p.parent.name: p for p in installed}
if set(by_name) != {"gs-scratch", "gs-review"}:
    sys.exit(f"install produced {[str(p) for p in installed]}")
installed_scratch = by_name["gs-scratch"].read_text()
if "name: gs-scratch" not in installed_scratch or ".scratch" not in installed_scratch:
    sys.exit("installed scratch SKILL.md missing name or .scratch")
for banned in (".scratchpad", "/scratchpad", "scratchpad"):
    if banned in installed_scratch:
        sys.exit(f"installed scratch SKILL.md contains {banned}")
goodreview_dir = by_name["gs-review"].parent
for rel in ("references/specialists.md", "references/providers.md", "references/review-md.md"):
    if not (goodreview_dir / rel).is_file():
        sys.exit(f"installed gs-review missing {rel}")

# The root README's Skills section is the one list of skills. It must name every
# skill directory, and nothing else, so it cannot drift from skills/.
readme_text = (root / "README.md").read_text()
skills_section = re.search(r"(?ms)^## Skills\n(.*?)^## ", readme_text)
if skills_section is None:
    sys.exit("README.md has no Skills section")
# Each line links the skill name to its README, so a line whose link is missing
# or points at another skill counts as missing.
listed = re.findall(r"(?m)^- \[`(gs-[a-z0-9-]+)`\]\(skills/\1/README\.md\)", skills_section.group(1))
if sorted(listed) != expected:
    missing = sorted(expected_set - set(listed))
    extra = sorted(set(listed) - expected_set)
    dupes = sorted({n for n in listed if listed.count(n) > 1})
    sys.exit(f"README.md Skills list is out of sync with skills/: missing {missing}, unknown {extra}, repeated {dupes}")

# No README spells out a skill count for installing everything, and no command
# names more than one skill. A README that does has to change whenever a skill is added.
number = (
    r"(?:\d+|(?:twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety)(?:-[a-z]+)?"
    r"|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve"
    r"|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen)"
)
total_count = re.compile(rf"(?i)\b(?:all|every|install|publishes)\s+{number}\s+(?:agent\s+)?skills\b")
readmes = [root / "README.md", *(root / "skills" / name / "README.md" for name in expected)]
for readme in readmes:
    if not readme.is_file():
        sys.exit(f"missing {readme}")
    text = readme.read_text()
    skill = readme.parent.name if readme.parent != root else None
    match = total_count.search(text)
    if match:
        sys.exit(f"{readme} gives the total skill count: {match.group(0)!r}")
    for line in text.splitlines():
        if len(re.findall(r"--skill\b", line)) > 1:
            sys.exit(f"{readme} has a command that names several skills: {line!r}")
    flagged = set(re.findall(r"--skill\s+(gs-[a-z0-9-]+)", text))
    if skill is None:
        for snippet in (
            "npx skills add agoodway/goodstack --list",
            "npx skills add agoodway/goodstack --skill gs-review",
            "npx skills add agoodway/goodstack --skill '*'",
            "npx skills add /path/to/goodstack --skill '*'",
        ):
            if snippet not in text:
                sys.exit(f"README.md missing {snippet!r}")
        if flagged - {"gs-review"}:
            sys.exit(f"README.md install commands name {sorted(flagged)}; use --skill '*' to install everything")
        continue
    if flagged != {skill}:
        sys.exit(f"{readme} install commands name {sorted(flagged)}; a skill README installs only {skill}")
    if "--skill '*'" in text or "--all" in text:
        sys.exit(f"{readme} installs every skill; link to the root README instead")
    for snippet in (
        f"npx skills add agoodway/goodstack --skill {skill}",
        f"npx skills add /path/to/goodstack --skill {skill}",
        "https://github.com/agoodway/goodstack#install",
    ):
        if snippet not in text:
            sys.exit(f"{readme} missing {snippet!r}")
    if skill == "gs-scratch":
        for snippet in (".scratch", "/gs-scratch bootstrap", "/gs-scratch write", "/gs-scratch edit", "/gs-scratch list", "scratchpad", ".scratchpad"):
            if snippet not in text:
                sys.exit(f"gs-scratch README missing {snippet}")

print("ok")
print("cli:", ", ".join(cli_names))
print("installed:", ", ".join(sorted(by_name)))
PY
