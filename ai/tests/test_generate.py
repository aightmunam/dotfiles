"""Tests ai/generate.sh link cleanup (stdlib unittest only)."""
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

AI = Path(__file__).resolve().parent.parent


class GenerateCleanupTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        root = Path(tmp.name).resolve()
        self.ai = root / "repo" / "ai"
        shutil.copytree(AI, self.ai, ignore=shutil.ignore_patterns("__pycache__", "local", "tests"))
        self.home = root / "home"
        self.home.mkdir()
        (self.home / ".codex" / "skills").mkdir(parents=True)  # a real dir: per-skill links

    def generate(self):
        # PATH has no claude, gemini or codex, so the MCP step skips each tool.
        env = {"HOME": str(self.home), "PATH": "/usr/bin:/bin"}
        out = subprocess.run(["bash", str(self.ai / "generate.sh")], env=env,
                             capture_output=True, text=True)
        self.assertEqual(out.returncode, 0, out.stderr)

    def test_a_renamed_skill_leaves_no_old_link_or_command(self):
        self.generate()
        (self.ai / "skills" / "catch-up").rename(self.ai / "skills" / "old-name-test")
        self.generate()
        (self.ai / "skills" / "old-name-test").rename(self.ai / "skills" / "catch-up")
        self.generate()
        for path in [self.home / ".agents/skills/old-name-test",
                     self.home / ".codex/skills/old-name-test",
                     self.home / ".gemini/commands/old-name-test.toml"]:
            self.assertFalse(os.path.lexists(path), path)
        self.assertTrue((self.home / ".agents/skills/catch-up/SKILL.md").exists())
        self.assertTrue((self.home / ".gemini/commands/catch-up.toml").exists())

    def test_keeps_a_command_that_it_did_not_write(self):
        commands = self.home / ".gemini" / "commands"
        commands.mkdir(parents=True)
        (commands / "mine.toml").write_text('description = "x"\nprompt = "y"\n')
        self.generate()
        self.assertTrue((commands / "mine.toml").exists())


if __name__ == "__main__":
    unittest.main()
