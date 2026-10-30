"""Tests for ai/bin/plan-lint (stdlib unittest only)."""
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
SCRIPT = str(HERE.parent / "bin" / "plan-lint")
FIXTURES = HERE / "fixtures"
GRIMOIRE = Path(os.environ.get("GRIMOIRE_DIR", Path.home() / "Developer" / "grimoire"))
HAVE_GRIMOIRE = (GRIMOIRE / ".venv" / "bin" / "python").exists()


def run(*args, **env):
    return subprocess.run(
        [SCRIPT, *args],
        capture_output=True,
        text=True,
        env={**os.environ, **env},
    )


@unittest.skipUnless(HAVE_GRIMOIRE, "Grimoire venv not installed")
class PlanLintTest(unittest.TestCase):
    def test_good_plan_exits_0(self):
        r = run(str(FIXTURES / "plan_good.md"))
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(r.stdout, "")

    def test_bad_plan_exits_1_and_names_each_defect(self):
        path = str(FIXTURES / "plan_bad_path.md")
        r = run(path)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        for text in (
            "ai/example/bare.py, not mentioned in the body",
            "ai/example/ghost.py, not mentioned in the body",
            "unknown change",
            'has no "## Phase 2" section',
        ):
            with self.subTest(text=text):
                self.assertIn(text, r.stdout)
        self.assertTrue(r.stdout.strip())
        self.assertTrue(all(l.startswith(path + ": ") for l in r.stdout.splitlines()))

    def test_non_utf8_file_exits_2(self):
        with tempfile.TemporaryDirectory() as tmp:
            bad = Path(tmp) / "latin1.md"
            bad.write_bytes(b"\xff\xfe not utf8 \x80")
            r = run(str(bad))
        self.assertEqual(r.returncode, 2, r.stdout + r.stderr)
        self.assertIn("internal error", r.stderr)


class PlanLintEnvTest(unittest.TestCase):
    def test_missing_grimoire_exits_2(self):
        with tempfile.TemporaryDirectory() as tmp:
            r = run(str(FIXTURES / "plan_good.md"), GRIMOIRE_DIR=tmp)
        self.assertEqual(r.returncode, 2)
        self.assertIn("Grimoire", r.stderr)

    def test_grimoire_without_parser_exits_2(self):
        with tempfile.TemporaryDirectory() as tmp:
            bindir = Path(tmp) / ".venv" / "bin"
            bindir.mkdir(parents=True)
            (bindir / "python").symlink_to(shutil.which("python3"))
            r = run(str(FIXTURES / "plan_good.md"), GRIMOIRE_DIR=tmp)
        self.assertEqual(r.returncode, 2, r.stdout + r.stderr)
        self.assertIn("internal error", r.stderr)

    def test_missing_input_file_exits_2(self):
        r = run(str(FIXTURES / "does_not_exist.md"))
        self.assertEqual(r.returncode, 2)
        self.assertIn("does_not_exist.md", r.stderr)


if __name__ == "__main__":
    unittest.main()
