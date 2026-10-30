"""Tests for ai/bin/migration-drift. A fake alembic on PATH stands in for the real one."""

import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "ai" / "bin" / "migration-drift"

FAKE_ALEMBIC = """#!/bin/sh
# Fake alembic: prints the heads in FAKE_ALEMBIC_HEADS, one per line.
[ "$1" = "heads" ] || { echo "unexpected alembic call: $*" >&2; exit 99; }
printf '%s\\n' "$FAKE_ALEMBIC_HEADS"
"""


class MigrationDriftTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.bin = Path(tmp.name) / "bin"
        self.bin.mkdir()
        fake = self.bin / "alembic"
        fake.write_text(FAKE_ALEMBIC)
        fake.chmod(0o755)
        self.repo = Path(tmp.name) / "repo"
        self.repo.mkdir()

    def run_script(self, repo_heads, *staging, repo=None, path=None):
        env = dict(os.environ)
        env["PATH"] = path or f"{self.bin}{os.pathsep}{env['PATH']}"
        env["FAKE_ALEMBIC_HEADS"] = repo_heads
        return subprocess.run(
            [sys.executable, str(SCRIPT), str(repo or self.repo), *staging],
            capture_output=True, text=True, env=env,
        )

    def test_in_sync(self):
        r = self.run_script("abc123 (head)", "abc123")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(r.stdout.strip(), "in sync")

    def test_staging_behind(self):
        r = self.run_script("abc123 (head)\ndef456 (head)", "abc123")
        self.assertEqual(r.returncode, 1, r.stderr)
        self.assertEqual(r.stdout.strip(), "staging behind: def456")

    def test_staging_ahead(self):
        r = self.run_script("abc123 (head)", "abc123\nzzz999")
        self.assertEqual(r.returncode, 1, r.stderr)
        self.assertEqual(r.stdout.strip(), "staging ahead: zzz999")

    def test_drift_both_directions(self):
        r = self.run_script("abc123 (head)", "zzz999".replace("z", "f"))
        self.assertEqual(r.returncode, 1, r.stderr)
        self.assertEqual(
            r.stdout.strip().splitlines(),
            ["staging behind: abc123", "staging ahead: fff999"],
        )

    def test_multiple_heads_in_sync(self):
        r = self.run_script("abc123 (head)\ndef456 (head)", "def456\nabc123")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(r.stdout.strip(), "in sync")

    def test_comma_and_whitespace_separated_heads(self):
        r = self.run_script("abc123 (head)\ndef456 (head)", "abc123, def456")
        self.assertEqual(r.stdout.strip(), "in sync")
        r = self.run_script("abc123 (head)\ndef456 (head)", "abc123  def456")
        self.assertEqual(r.stdout.strip(), "in sync")

    def test_unquoted_argv_words_are_joined(self):
        r = self.run_script("abc123 (head)\ndef456 (head)", "abc123", "def456")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(r.stdout.strip(), "in sync")

    def test_blank_lines_ignored(self):
        r = self.run_script("\nabc123 (head)\n\n", "\n\nabc123\n\n")
        self.assertEqual(r.stdout.strip(), "in sync")

    def test_pasted_psql_output(self):
        psql = " version_num \n--------------\n abc123\n(1 row)\n"
        r = self.run_script("abc123 (head)", psql)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(r.stdout.strip(), "in sync")

    def test_info_words_ignored(self):
        r = self.run_script("INFO [alembic.runtime.migration] Context\nabc123 (head)", "abc123")
        self.assertEqual(r.stdout.strip(), "in sync")

    def test_missing_dir_exits_2(self):
        r = self.run_script("abc123", "abc123", repo=self.repo / "nope")
        self.assertEqual(r.returncode, 2)

    def test_alembic_failure_exits_2(self):
        (self.bin / "alembic").write_text("#!/bin/sh\necho boom >&2\nexit 1\n")
        r = self.run_script("abc123", "abc123")
        self.assertEqual(r.returncode, 2)
        self.assertIn("boom", r.stderr)

    def test_alembic_missing_exits_2(self):
        empty = self.bin.parent / "empty"
        empty.mkdir()
        r = self.run_script("abc123", "abc123", path=str(empty))
        self.assertEqual(r.returncode, 2)

    def test_empty_repo_heads_exits_2(self):
        r = self.run_script("", "")
        self.assertEqual(r.returncode, 2)
        r = self.run_script("", "abc123")
        self.assertEqual(r.returncode, 2)

    def test_empty_staging_exits_2(self):
        r = self.run_script("abc123 (head)", "version_num\n(0 rows)")
        self.assertEqual(r.returncode, 2)


if __name__ == "__main__":
    unittest.main()
