"""Tests for ai/bin/migration-drift. A fake alembic on PATH stands in for the real one."""

import os
import subprocess
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

    def run_script(self, repo_heads, staging_heads):
        env = dict(os.environ)
        env["PATH"] = f"{self.bin}{os.pathsep}{env['PATH']}"
        env["FAKE_ALEMBIC_HEADS"] = repo_heads
        return subprocess.run(
            [str(SCRIPT), str(self.repo), staging_heads],
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


if __name__ == "__main__":
    unittest.main()
