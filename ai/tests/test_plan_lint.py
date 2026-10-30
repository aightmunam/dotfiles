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

    def test_plan_without_manifest_exits_1(self):
        body = (FIXTURES / "plan_good.md").read_text(encoding="utf-8")
        with tempfile.TemporaryDirectory() as tmp:
            bare = Path(tmp) / "bare.md"
            bare.write_text(body.split("\n---\n", 1)[1], encoding="utf-8")
            r = run(str(bare))
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("kind: plan", r.stdout)

    def test_text_before_manifest_exits_1(self):
        body = (FIXTURES / "plan_good.md").read_text(encoding="utf-8")
        with tempfile.TemporaryDirectory() as tmp:
            late = Path(tmp) / "late.md"
            late.write_text("Here is the plan.\n\n" + body, encoding="utf-8")
            r = run(str(late))
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        self.assertIn("line 1", r.stdout)

    def test_good_steps_exit_0(self):
        r = run(str(FIXTURES / "plan_steps_good.md"))
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
        self.assertEqual(r.stdout, "")

    def test_bad_steps_exit_1_and_name_each_defect(self):
        path = str(FIXTURES / "plan_steps_bad.md")
        r = run(path)
        self.assertEqual(r.returncode, 1, r.stdout + r.stderr)
        lines = r.stdout.splitlines()
        self.assertTrue(all(l.startswith(path + ": ") for l in lines), r.stdout)
        expected = [
            "line 20: Step 1: test step names no test in backticks",
            "line 20: Step 1: test step has no literal expected value",
            "line 21: Step 2: test step has no literal expected value",
            "line 22: Step 3: code step has no signature name(params) -> type",
            "line 23: Step 4: code step names no file path",
            "line 25: checkbox step: code step has no signature name(params) -> type",
            "line 25: checkbox step: code step names no file path",
        ]
        self.assertEqual([l[len(path) + 2:] for l in lines], expected)

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

    def test_help_exits_0_and_prints_usage(self):
        for flag in ("-h", "--help"):
            with self.subTest(flag=flag):
                r = run(flag)
                self.assertEqual(r.returncode, 0, r.stdout + r.stderr)
                self.assertTrue(r.stdout.startswith("usage: plan-lint FILE..."), r.stdout)
                self.assertEqual(r.stderr, "")

    def test_missing_input_file_exits_2(self):
        r = run(str(FIXTURES / "does_not_exist.md"))
        self.assertEqual(r.returncode, 2)
        self.assertIn("does_not_exist.md", r.stderr)


if __name__ == "__main__":
    unittest.main()
