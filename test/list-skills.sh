#!/usr/bin/env bash
# Drives `npx skills add` against this repo and checks the twenty-two shipped skills.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
cd "$TMP"

LIST_OUT="$TMP/list.txt"
INSTALL_OUT="$TMP/install.txt"

set +e
DISABLE_TELEMETRY=1 npx skills add "$ROOT" --list >"$LIST_OUT" 2>&1
LIST_EXIT=$?
DISABLE_TELEMETRY=1 npx skills add "$ROOT" --skill gs-scratch --skill gs-review -a claude-code -y --copy >"$INSTALL_OUT" 2>&1
INSTALL_EXIT=$?
set -e

python3 - "$ROOT" "$TMP" "$LIST_OUT" "$INSTALL_OUT" "$LIST_EXIT" "$INSTALL_EXIT" <<'PY'
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

expected = [
    "gs-review",
    "gs-openspec-ship-tickets",
    "gs-openspec-ship",
    "gs-openspec-to-tickets",
    "gs-scratch",
    "gs-review-pr-reply",
    "gs-git-commit",
    "gs-pull-request",
    "gs-blast-radius",
    "gs-unslop",
    "gs-deslop",
    "gs-how",
    "gs-why",
    "gs-arena",
    "gs-wait-what",
    "gs-show-me",
    "gs-pr-comment",
    "gs-reflect",
    "gs-sharpen",
    "gs-prototype",
    "gs-codebase-design",
    "gs-pr-show-me",
]
expected_set = set(expected)

if list_exit != 0:
    sys.exit(f"npx skills add --list exited {list_exit}\n{list_out}")
if install_exit != 0:
    sys.exit(f"npx skills add install exited {install_exit}\n{install_out}")

clean = re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "", list_out)
cli_names = re.findall(r"(?m)^│    ([a-z0-9-]+)$", clean)
found = re.search(r"Found (\d+) skills", clean)
if found is None or found.group(1) != "22":
    sys.exit(f"expected 'Found 22 skills' in list output, got count {found.group(1) if found else None}\n{clean}")
if set(cli_names) != expected_set or len(cli_names) != 22:
    sys.exit(f"CLI listed {cli_names}, expected {expected}")
if "scratchpad" in clean:
    sys.exit("CLI list mentioned scratchpad")

frontmatter = {}
skill_dirs = [p for p in (root / "skills").iterdir() if p.is_dir()]
if {p.name for p in skill_dirs} != expected_set:
    sys.exit(f"skill directories are {[p.name for p in skill_dirs]}")
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
for required in ("## What changed", "## How it works", "## Evidence", "## What could break", "## How to check", "gh pr create --draft", "/gs-git-commit"):
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

# gs-deslop differs from the cursor-team-kit original only in its name line, so it has no hash pin.
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

# how, why, and arena are adapted from the pstack originals, so they have no hash pin.
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

pr_show = (root / "skills" / "gs-pr-show-me" / "SKILL.md").read_text()
for required in ("gs-pull-request", "gs-show-me", "gh pr view", "gh pr diff", "## Where to look first", "read-only"):
    if required not in pr_show:
        sys.exit(f"gs-pr-show-me SKILL.md missing {required}")

installed = list(tmp.rglob("SKILL.md"))
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
for rel in ("references/specialists.md", "references/providers.md"):
    if not (goodreview_dir / rel).is_file():
        sys.exit(f"installed gs-review missing {rel}")

all_twenty_two = (
    "npx skills add agoodway/goodstack --skill gs-review "
    "--skill gs-openspec-ship-tickets --skill gs-openspec-ship "
    "--skill gs-openspec-to-tickets --skill gs-scratch "
    "--skill gs-review-pr-reply --skill gs-git-commit --skill gs-pull-request "
    "--skill gs-blast-radius --skill gs-unslop --skill gs-deslop "
    "--skill gs-how --skill gs-why --skill gs-arena --skill gs-wait-what --skill gs-show-me --skill gs-pr-comment --skill gs-reflect --skill gs-sharpen --skill gs-prototype --skill gs-codebase-design --skill gs-pr-show-me"
)
readmes = [root / "README.md", *sorted((root / "skills").glob("*/README.md"))]
if len(readmes) != 23:
    sys.exit(f"expected 23 READMEs, found {readmes}")
for readme in readmes:
    text = readme.read_text()
    skill = readme.parent.name if readme.parent.name != root.name else None
    for snippet in (
        "npx skills add agoodway/goodstack --list",
        all_twenty_two,
        "npx skills add /path/to/goodstack --list",
    ):
        if snippet not in text:
            sys.exit(f"{readme} missing {snippet!r}")
    if skill is None:
        one = "npx skills add agoodway/goodstack --skill gs-review"
    else:
        one = f"npx skills add agoodway/goodstack --skill {skill}"
    if one not in text:
        sys.exit(f"{readme} missing {one!r}")
    if skill == "gs-scratch":
        for snippet in (".scratch", "/gs-scratch bootstrap", "/gs-scratch write", "/gs-scratch edit", "/gs-scratch list", "scratchpad", ".scratchpad"):
            if snippet not in text:
                sys.exit(f"gs-scratch README missing {snippet}")

print("ok")
print("cli:", ", ".join(cli_names))
print("installed:", ", ".join(sorted(by_name)))
PY
