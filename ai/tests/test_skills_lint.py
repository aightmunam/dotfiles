"""Lint for new-form skills and new agents (stdlib only).

Checks run on NEW_FORM (skill dirs with source-map.md or tenet-map.md, minus
KEPT) and on the NEW_AGENTS files that exist.
"""

import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SKILLS_DIR = ROOT / "ai" / "skills"
AGENTS_DIR = ROOT / "ai" / "agents"
PRINCIPLES_DIR = ROOT / "ai" / "principles"
AGENTS_MD = ROOT / "ai" / "AGENTS.md"
STE_LINT = ROOT / "ai" / "vendor" / "ste-lint.py"

EM_DASH = chr(0x2014)
MAX_SKILL_LINES = 80
# Skills outside the house form.
KEPT = {
    "commit", "design-system", "explain_code",
}
PLANNED = {
    "research", "brainstorm", "make-plan", "build", "tdd", "debug", "prove", "verifier",
    "performance", "pr", "unslop", "technical-writing", "reply", "address", "new-skill", "handoff", "recall", "bro",
    "ketchup", "review-pr", "staging", "data-op", "fix-merge-conflicts", "what-did-i-get-done",
    "reflect", "correct", "automate-me",
}
# Spec 8.7 table: skill -> principles it must name in SKILL.md or a reference file.
PRINCIPLE_TARGETS = {
    "debug": ["attack-the-premise", "fix-root-causes"],
    "address": ["attack-the-premise", "encode-lessons-in-structure"],
    "review-pr": [
        "boundary-discipline", "fix-root-causes", "minimize-reader-load",
        "model-the-domain", "test-behavior-not-implementation",
    ],
    "build": ["boundary-discipline", "separate-before-serializing-shared-state"],
    "tdd": ["boundary-discipline", "test-behavior-not-implementation"],
    "data-op": ["build-the-lever", "make-operations-idempotent", "prove-it-works"],
    "make-plan": [
        "build-the-lever", "foundational-thinking", "model-the-domain",
        "separate-before-serializing-shared-state",
    ],
    "new-skill": ["encode-lessons-in-structure"],
    "reflect": ["encode-lessons-in-structure"],
    "correct": ["encode-lessons-in-structure", "test-behavior-not-implementation"],
    "automate-me": ["encode-lessons-in-structure"],
    "performance": ["explain-the-number"],
    "staging": ["make-operations-idempotent", "prove-it-works"],
    "prove": ["prove-it-works"],
    "handoff": ["prove-it-works"],
    "recall": ["prove-it-works"],
}
POINTER_RE = re.compile(r"~/\.agents/principles/([A-Za-z0-9_-]+)\.md")
PLUGIN_MARKERS = ("superpowers:", "agent-skills:", "feature-dev:", "plugins/cache")
# Agent files and AGENTS.md may not name superpowers at all. Skill source maps may cite it.
STRICT_MARKERS = PLUGIN_MARKERS + ("superpowers",)
NEW_AGENTS = {"reviewer", "explorer"}
# The four Repo Rules lines, verbatim (ai/skills/debug/SKILL.md). Every PLANNED skill
# except the text-only ones carries them in SKILL.md (final review I3, M7).
REPO_RULES = (
    "never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.",
    "No alembic upgrade or downgrade, and no DB mutation, on a production database"
    " without in-the-moment user confirmation.",
    "Do not read .env files.",
    "Worktrees only under ~/wt/<repo>/<name>.",
)
TEXT_ONLY = {"bro", "unslop"}


def new_form(skills_dir=SKILLS_DIR):
    if not skills_dir.is_dir():
        return []
    return sorted(
        d.name
        for d in skills_dir.iterdir()
        if d.is_dir()
        and (
            d.name in PLANNED
            or (d / "source-map.md").is_file()
            or (d / "tenet-map.md").is_file()
        )
    )


NEW_FORM = new_form()
SKILLS_UNDER_TEST = [n for n in NEW_FORM if n not in KEPT]


def frontmatter(text):
    """Return (fields, lines) from the block between the first two --- lines, or (None, [])."""
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return None, []
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            block = lines[1:i]
            break
    else:
        return None, []
    fields = {}
    for line in block:
        if ":" in line and not line.startswith((" ", "\t")):
            key, _, value = line.partition(":")
            fields[key.strip()] = value.strip()
    return fields, block


def check_name(path, expected):
    fm, _ = frontmatter(path.read_text(encoding="utf-8"))
    if fm is None:
        return [f"{path}: missing frontmatter"]
    if fm.get("name") != expected:
        return [f"{path}: name {fm.get('name')!r} must equal {expected!r}"]
    return []


def check_description(path):
    fm, block = frontmatter(path.read_text(encoding="utf-8"))
    if fm is None:
        return [f"{path}: missing frontmatter"]
    desc = fm.get("description", "")
    errors = []
    if not desc or desc in ("|", ">", "|-", ">-"):
        errors.append(f"{path}: description must be one non-empty line")
    for i, line in enumerate(block):
        if not line.startswith("description:"):
            continue
        for nxt in block[i + 1 :]:
            if nxt.strip() == "":
                continue
            if nxt.startswith((" ", "\t")):
                errors.append(f"{path}: description spans more than one line")
            break
    if not desc.startswith("Use when"):
        errors.append(f"{path}: description must start with 'Use when'")
    if ": " in desc or " #" in desc:
        errors.append(f"{path}: description has an unquoted ': ' or ' #', invalid YAML")
    if '"' in desc:
        errors.append(f"{path}: description must not contain a double quote")
    return errors


def check_no_em_dash(paths):
    return [f"{p}: contains an em dash" for p in paths if EM_DASH in p.read_text(encoding="utf-8")]


def check_length(path):
    n = len(path.read_text(encoding="utf-8").splitlines())
    return [f"{path}: {n} lines, at most {MAX_SKILL_LINES} allowed"] if n > MAX_SKILL_LINES else []


def check_source_map(skill_dir):
    required = "tenet-map.md" if skill_dir.name == "debug" else "source-map.md"
    return [] if (skill_dir / required).is_file() else [f"{skill_dir}: missing {required}"]


def check_ste(path):
    r = subprocess.run(
        [sys.executable, str(STE_LINT), str(path)], capture_output=True, text=True, cwd=str(ROOT)
    )
    if r.returncode != 0:
        return [f"{path}: ste-lint exit {r.returncode}\n{r.stdout}{r.stderr}"]
    return []


def md_files(skill_dir):
    return sorted(skill_dir.rglob("*.md"))


def agent_errors(path):
    return (
        check_name(path, path.stem)
        + check_description(path)
        + check_no_em_dash([path])
        + check_ste(path)
    )


def principle_names(principles_dir=PRINCIPLES_DIR):
    if not principles_dir.is_dir():
        return set()
    return {p.stem for p in principles_dir.glob("*.md")}


def check_pointers(paths, principles_dir=PRINCIPLES_DIR):
    known = principle_names(principles_dir)
    errors = []
    for p in paths:
        for name in POINTER_RE.findall(p.read_text(encoding="utf-8")):
            if name not in known:
                errors.append(f"{p}: pointer to missing principle {name}.md")
    return errors


def index_names(agents_md):
    text = agents_md.read_text(encoding="utf-8")
    m = re.search(r"^## Principles\s*$(.*?)(?=^## |\Z)", text, re.M | re.S)
    return set(POINTER_RE.findall(m.group(1))) if m else set()


def check_index(agents_md, principles_dir=PRINCIPLES_DIR):
    indexed = index_names(agents_md)
    files = principle_names(principles_dir)
    return [f"index lists {n}.md, file missing" for n in sorted(indexed - files)] + [
        f"{n}.md is in no index line" for n in sorted(files - indexed)
    ]


def check_targets(skill_dir, principles):
    text = "\n".join(p.read_text(encoding="utf-8") for p in md_files(skill_dir))
    return [
        f"{skill_dir.name}: no pointer to {n}"
        for n in principles
        if f"~/.agents/principles/{n}.md" not in text
    ]


def check_principle_shape(path):
    text = path.read_text(encoding="utf-8")
    errors = []
    if not any(line.startswith("Source:") for line in text.splitlines()):
        errors.append(f"{path}: missing Source: line")
    if len(text.splitlines()) > 40:
        errors.append(f"{path}: more than 40 lines")
    if EM_DASH in text:
        errors.append(f"{path}: contains an em dash")
    return errors


def check_plugin_refs(paths, markers=PLUGIN_MARKERS):
    return [
        f"{p}: names {m}"
        for p in paths
        for m in markers
        if m in p.read_text(encoding="utf-8")
    ]


def check_repo_rules(path, lines=REPO_RULES):
    text = path.read_text(encoding="utf-8") if path.is_file() else ""
    return [f"{path}: missing Repo Rules line: {line}" for line in lines if line not in text]


def agent_files():
    return [AGENTS_DIR / f"{n}.md" for n in sorted(NEW_AGENTS) if (AGENTS_DIR / f"{n}.md").is_file()]


def skill_md_files():
    return [f for n in SKILLS_UNDER_TEST for f in md_files(SKILLS_DIR / n)]


class SkillsLint(unittest.TestCase):
    def each(self, check):
        for name in SKILLS_UNDER_TEST:
            with self.subTest(skill=name):
                errors = check(SKILLS_DIR / name)
                self.assertEqual(errors, [], "\n".join(errors))

    def test_every_custom_skill_has_house_form(self):
        for d in sorted(SKILLS_DIR.iterdir()):
            if not d.is_dir() or d.name in KEPT:
                continue
            with self.subTest(skill=d.name):
                self.assertIn(d.name, PLANNED, f"{d.name} is not a planned skill and not in KEPT")
                self.assertTrue((d / "SKILL.md").is_file(), f"{d.name}: missing SKILL.md")
                self.assertEqual(check_source_map(d), [])

    def test_repo_rules_lines(self):
        for name in sorted(PLANNED - TEXT_ONLY):
            with self.subTest(skill=name):
                errors = check_repo_rules(SKILLS_DIR / name / "SKILL.md")
                self.assertEqual(errors, [], "\n".join(errors))

    def test_name_matches_dir(self):
        self.each(lambda d: check_name(d / "SKILL.md", d.name))

    def test_description_shape(self):
        self.each(lambda d: check_description(d / "SKILL.md"))

    def test_no_em_dash(self):
        self.each(lambda d: check_no_em_dash(md_files(d)))

    def test_skill_md_length(self):
        self.each(lambda d: check_length(d / "SKILL.md"))

    def test_source_map_present(self):
        self.each(check_source_map)

    def test_ste_lint_strict(self):
        self.each(lambda d: check_ste(d / "SKILL.md"))

    def test_agents_shape(self):
        for name in sorted(NEW_AGENTS):
            path = AGENTS_DIR / f"{name}.md"
            if not path.is_file():
                continue  # explorer.md arrives in Task 2.4; checked once it exists.
            with self.subTest(agent=name):
                errors = agent_errors(path)
                self.assertEqual(errors, [], "\n".join(errors))

    def test_principle_pointers_resolve(self):
        paths = skill_md_files() + agent_files() + [AGENTS_MD] + sorted(PRINCIPLES_DIR.glob("*.md"))
        errors = check_pointers(paths)
        self.assertEqual(errors, [], "\n".join(errors))

    def test_principles_index_matches_files(self):
        self.assertTrue(principle_names(), "no principle files")
        errors = check_index(AGENTS_MD)
        self.assertEqual(errors, [], "\n".join(errors))

    def test_principle_targets(self):
        for name, principles in PRINCIPLE_TARGETS.items():
            if name not in SKILLS_UNDER_TEST or not (SKILLS_DIR / name / "SKILL.md").is_file():
                continue  # Not built yet, or still legacy.
            with self.subTest(skill=name):
                errors = check_targets(SKILLS_DIR / name, principles)
                self.assertEqual(errors, [], "\n".join(errors))

    def test_principle_files_shape(self):
        files = sorted(PRINCIPLES_DIR.glob("*.md"))
        self.assertTrue(files, "no principle files")
        for f in files:
            with self.subTest(principle=f.name):
                errors = check_principle_shape(f)
                self.assertEqual(errors, [], "\n".join(errors))

    def test_no_plugin_references(self):
        errors = check_plugin_refs(skill_md_files())
        errors += check_plugin_refs(agent_files(), STRICT_MARKERS)
        self.assertEqual(errors, [], "\n".join(errors))

    def test_no_plugin_references_in_agents_md(self):
        errors = check_plugin_refs([AGENTS_MD], STRICT_MARKERS)
        self.assertEqual(errors, [], "\n".join(errors))


class LintSelfCheck(unittest.TestCase):
    """The checks must fail on bad input, so the lint is not vacuous."""

    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name) / "good-name"
        self.dir.mkdir()

    def skill(self, text):
        p = self.dir / "SKILL.md"
        p.write_text(text, encoding="utf-8")
        return p

    def test_name_mismatch(self):
        p = self.skill("---\nname: other\ndescription: Use when x.\n---\nbody\n")
        self.assertTrue(check_name(p, "good-name"))

    def test_good_passes(self):
        p = self.skill("---\nname: good-name\ndescription: Use when a test runs.\n---\nbody\n")
        self.assertEqual(check_name(p, "good-name") + check_description(p), [])

    def test_quoted_description(self):
        p = self.skill('---\nname: good-name\ndescription: "Use when x."\n---\n')
        self.assertTrue(check_description(p))

    def test_not_use_when(self):
        p = self.skill("---\nname: good-name\ndescription: Does things.\n---\n")
        self.assertTrue(check_description(p))

    def test_multiline_description(self):
        p = self.skill("---\nname: good-name\ndescription: Use when x\n  and y.\n---\n")
        self.assertTrue(check_description(p))

    def test_em_dash(self):
        p = self.skill("---\nname: good-name\n---\nbad " + EM_DASH + " dash\n")
        self.assertTrue(check_no_em_dash([p]))

    def test_long_skill_md(self):
        p = self.skill("---\nname: good-name\n---\n" + "line\n" * 78)
        self.assertEqual(len(p.read_text().splitlines()), 81)
        self.assertTrue(check_length(p))

    def test_missing_source_map(self):
        self.assertTrue(check_source_map(self.dir))
        (self.dir / "source-map.md").write_text("x\n")
        self.assertEqual(check_source_map(self.dir), [])

    def test_ste_lint_fails_on_violations(self):
        p = self.skill("---\nname: good-name\n---\nDo this; do that.\n")
        errors = check_ste(p)
        self.assertTrue(errors)
        self.assertIn("semicolon", errors[0])

    def test_ste_lint_clean_passes(self):
        p = self.skill("---\nname: good-name\n---\nDo this. Do that.\n")
        self.assertEqual(check_ste(p), [])

    def test_description_colon_or_hash(self):
        for desc in ("Use when x: y", "Use when x #y"):
            p = self.skill(f"---\nname: good-name\ndescription: {desc}\n---\n")
            self.assertTrue(check_description(p), desc)

    def test_blank_line_then_continuation(self):
        p = self.skill("---\nname: good-name\ndescription: Use when x\n\n  and y.\n---\n")
        self.assertTrue(check_description(p))

    def test_exactly_80_lines_passes(self):
        p = self.skill("---\nname: good-name\n---\n" + "line\n" * 77)
        self.assertEqual(len(p.read_text().splitlines()), 80)
        self.assertEqual(check_length(p), [])

    def test_debug_needs_tenet_map(self):
        d = self.dir.parent / "debug"
        d.mkdir()
        (d / "source-map.md").write_text("x\n")
        self.assertTrue(check_source_map(d))
        (d / "tenet-map.md").write_text("x\n")
        self.assertEqual(check_source_map(d), [])

    def test_planned_without_map_is_in_new_form(self):
        d = self.dir.parent / "tdd"
        d.mkdir()
        self.assertIn("tdd", new_form(self.dir.parent))

    def test_new_form_detection(self):
        self.assertEqual(new_form(self.dir.parent), [])
        (self.dir / "tenet-map.md").write_text("x\n")
        self.assertEqual(new_form(self.dir.parent), ["good-name"])

    def tree(self):
        root = self.dir.parent
        pdir = root / "principles"
        pdir.mkdir(exist_ok=True)
        (pdir / "real.md").write_text("Source: x\n")
        return root, pdir

    def test_dangling_pointer(self):
        _, pdir = self.tree()
        p = self.skill("Read ~/.agents/principles/ghost.md before this step.\n")
        self.assertTrue(check_pointers([p], pdir))
        p = self.skill("Read ~/.agents/principles/real.md before this step.\n")
        self.assertEqual(check_pointers([p], pdir), [])

    def test_index_extra_file_and_missing_file(self):
        root, pdir = self.tree()
        idx = root / "AGENTS.md"
        idx.write_text("## Principles\n- ~/.agents/principles/real.md\n## Other\n")
        self.assertEqual(check_index(idx, pdir), [])
        (pdir / "extra.md").write_text("Source: x\n")
        self.assertIn("extra.md is in no index line", check_index(idx, pdir)[0])
        idx.write_text("## Principles\n- ~/.agents/principles/real.md\n- ~/.agents/principles/gone.md\n")
        self.assertTrue(any("gone" in e for e in check_index(idx, pdir)))

    def test_index_missing_section(self):
        root, pdir = self.tree()
        idx = root / "AGENTS.md"
        idx.write_text("# none\n")
        self.assertTrue(check_index(idx, pdir))

    def test_targets_check(self):
        self.skill("Read ~/.agents/principles/real.md.\n")
        self.assertEqual(check_targets(self.dir, ["real"]), [])
        self.assertTrue(check_targets(self.dir, ["real", "other"]))
        self.skill("This text names real but has no pointer.\n")
        self.assertTrue(check_targets(self.dir, ["real"]))

    def test_principle_shape(self):
        p = self.dir / "p.md"
        p.write_text("Source: a\nbody\n")
        self.assertEqual(check_principle_shape(p), [])
        p.write_text("body\n")
        self.assertTrue(check_principle_shape(p))
        p.write_text("Source: a\n" + "x\n" * 40)
        self.assertTrue(check_principle_shape(p))
        p.write_text("Source: a\n" + EM_DASH + "\n")
        self.assertTrue(check_principle_shape(p))

    def test_repo_rules_check(self):
        self.assertEqual(check_repo_rules(self.skill("\n".join(REPO_RULES) + "\n")), [])
        self.assertEqual(len(check_repo_rules(self.skill("Do not read .env files.\n"))), 3)
        bad = REPO_RULES[0].replace("never", "Never")
        self.assertEqual(len(check_repo_rules(self.skill(bad + "\n" + "\n".join(REPO_RULES[1:])))), 1)

    def test_plugin_names(self):
        for bad in ("superpowers:tdd", "agent-skills:plan", "feature-dev:x", "a/plugins/cache/b"):
            p = self.skill(bad + "\n")
            self.assertTrue(check_plugin_refs([p]), bad)
        self.assertEqual(check_plugin_refs([self.skill("clean\n")]), [])
        p = self.skill("see superpowers `using-git-worktrees`\n")
        self.assertEqual(check_plugin_refs([p]), [])
        self.assertTrue(check_plugin_refs([p], STRICT_MARKERS))


if __name__ == "__main__":
    unittest.main()
