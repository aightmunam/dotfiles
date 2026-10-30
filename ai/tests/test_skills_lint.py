"""Lint for new-form skills and new agents (stdlib only).

Checks run on NEW_FORM (skill dirs with source-map.md or tenet-map.md, minus
LEGACY) and on the NEW_AGENTS files that exist.
"""

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SKILLS_DIR = ROOT / "ai" / "skills"
AGENTS_DIR = ROOT / "ai" / "agents"
STE_LINT = ROOT / "ai" / "vendor" / "ste-lint.py"

EM_DASH = chr(0x2014)
MAX_SKILL_LINES = 80
# Excluded until P9 removes them.
# The old `debug` is replaced in Task 4.3, which removes it from LEGACY.
LEGACY = {"fact-constrained-debugging", "debug"}
PLANNED = {
    "research", "brainstorm", "make-plan", "build", "tdd", "debug", "prove", "verifier",
    "performance", "pr", "reply", "address", "new-skill", "staging", "data-op", "review-pr",
}
NEW_AGENTS = {"reviewer", "explorer"}


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
SKILLS_UNDER_TEST = [n for n in NEW_FORM if n not in LEGACY]


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


class SkillsLint(unittest.TestCase):
    def each(self, check):
        for name in SKILLS_UNDER_TEST:
            with self.subTest(skill=name):
                errors = check(SKILLS_DIR / name)
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


if __name__ == "__main__":
    unittest.main()
