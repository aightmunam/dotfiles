"""Lint for the orchestration skills under ai/skills (stdlib only).

Every skill in SKILLS is required on disk.
"""

import glob
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SKILLS = ["build", "plan-advise", "implement", "review-orchestrate", "triage-findings", "escalate"]
COMMANDS = ["eye-build", "prod-db-read", "sf-read", "build-preflight", "lens-route"]
# May be absent: reported as skip, not failure.
OPTIONAL_COMMANDS = {"lens-route"}
# Installed on PATH from outside this repo (The Eye, the private agent-guards dir).
EXTERNAL_COMMANDS = {"eye-build", "prod-db-read", "sf-read", "build-preflight"}
EM_DASH = chr(0x2014)
PRONOUNS = re.compile(r"\b(he|she|his|her|him)\b", re.IGNORECASE)


def frontmatter(text):
    m = re.match(r"---\n(.*?)\n---\n", text, re.DOTALL)
    if not m:
        return None
    fields = {}
    for line in m.group(1).splitlines():
        if ":" in line and not line.startswith((" ", "\t")):
            key, _, value = line.partition(":")
            fields[key.strip()] = value.strip()
    return fields


def command_resolves(cmd):
    return cmd in EXTERNAL_COMMANDS or (ROOT / "ai" / "bin" / cmd).is_file()


def pronoun_hits(text):
    """Sentences that mention the user and use one of he/she/his/her/him."""
    hits = []
    for sentence in re.split(r"(?<=[.!?])\s+|\n\s*\n", text):
        if re.search(r"\bthe user\b", sentence, re.IGNORECASE) and PRONOUNS.search(sentence):
            hits.append(sentence.strip())
    return hits


class SkillsLint(unittest.TestCase):
    def check_skill(self, name):
        path = ROOT / "ai" / "skills" / name / "SKILL.md"
        self.assertTrue(path.is_file(), f"{name}: ai/skills/{name}/SKILL.md is missing")
        text = path.read_text(encoding="utf-8")

        fm = frontmatter(text)
        self.assertIsNotNone(fm, f"{name}: missing frontmatter")
        self.assertEqual(fm.get("name"), name, f"{name}: frontmatter name must equal directory")
        desc = fm.get("description", "")
        self.assertTrue(desc, f"{name}: missing description")
        self.assertLess(len(desc), 1024, f"{name}: description too long")

        for heading in ("## When to use", "## Hard rules"):
            self.assertRegex(text, rf"(?m)^{re.escape(heading)}\s*$", f"{name}: missing {heading}")
        self.assertTrue(
            re.search(r"(?m)^## (Steps|Procedure)\s*$", text), f"{name}: missing ## Steps or ## Procedure"
        )

        self.assertNotIn(EM_DASH, text, f"{name}: contains an em dash")

        for token in sorted(set(re.findall(r"\bai/[\w./*-]*[\w/*]", text))):
            self.assertTrue(glob.glob(str(ROOT / token)), f"{name}: path does not exist: {token}")

        spans = " \n".join(re.findall(r"`([^`\n]+)`", text))
        for cmd in COMMANDS:
            if not re.search(rf"(?<![\w-]){re.escape(cmd)}(?![\w-])", spans):
                continue
            if command_resolves(cmd):
                continue
            if cmd in OPTIONAL_COMMANDS:
                print(f"skip {name}: command {cmd} not available")
                continue
            self.fail(f"{name}: command `{cmd}` not found in ai/bin/")

        self.assertEqual(pronoun_hits(text), [], f"{name}: use they/them for the user")


def _make(name):
    return lambda self: self.check_skill(name)


for _name in SKILLS:
    setattr(SkillsLint, "test_" + _name.replace("-", "_"), _make(_name))


class PronounCheck(unittest.TestCase):
    def test_detects_and_ignores(self):
        self.assertTrue(pronoun_hits("The user said he agrees."))
        self.assertTrue(pronoun_hits("Ask the user. Never answer for the user when her day is busy."))
        self.assertFalse(pronoun_hits("The user decides. He is the reviewer."))
        self.assertFalse(pronoun_hits("Never answer on the user's behalf; they decide."))


if __name__ == "__main__":
    unittest.main()
