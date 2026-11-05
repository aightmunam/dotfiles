"""CLI tests for rewrite-refs, using only the standard library."""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "bin" / "rewrite-refs"


class RewriteRefsTest(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.map = self.root / "map.tsv"
        self.file = self.root / "guide.md"

    def run_rewrite(self, *files, dry_run=False):
        self.assertTrue(SCRIPT.exists(), "rewrite-refs not found")
        return subprocess.run(
            [str(SCRIPT), *(["--dry-run"] if dry_run else []),
             str(self.map), *map(str, files or (self.file,))],
            capture_output=True, text=True,
        )

    # Adding the CLI and literal substitution makes this test pass.
    def test_rewrites_each_pair(self):
        self.map.write_text("a.sh up\trig up\n", encoding="utf-8")
        self.file.write_text("run a.sh up\n", encoding="utf-8")
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_text(), "run rig up\n")
        self.assertEqual(result.stdout, f"{self.file}: 1 changes\ntotal 1\n")
        self.assertEqual(result.stderr, "")

    # Regex substitution must expand replacement groups.
    def test_regex_row_uses_groups(self):
        self.map.write_text(r"re:curl -sS (\S+)" + "\t" + r"rig call x GET \1" + "\n")
        self.file.write_text("curl -sS /a\n")
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_text(), "rig call x GET /a\n")
        self.assertEqual(result.stdout, f"{self.file}: 1 changes\ntotal 1\n")

    # Validate every row across every file before the first write.
    def test_refuses_when_a_row_matches_nothing(self):
        row = "missing.sh\trig absent"
        self.map.write_text("a.sh up\trig up\n" + row + "\n")
        self.file.write_bytes(b"run a.sh up\n")
        other = self.root / "other.md"
        other.write_bytes(b"a.sh up again\n")
        result = self.run_rewrite(self.file, other)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn(row, result.stderr)
        self.assertEqual(self.file.read_bytes(), b"run a.sh up\n")
        self.assertEqual(other.read_bytes(), b"a.sh up again\n")
        self.assertEqual(result.stdout, "")

    # Accept replacement text as proof that a literal row was applied.
    def test_second_run_changes_nothing(self):
        self.map.write_text("a.sh up\trig up\n")
        self.file.write_text("run a.sh up\n")
        first = self.run_rewrite()
        self.assertEqual(first.returncode, 0, first.stderr)
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "total 0\n")
        self.assertEqual(self.file.read_bytes(), b"run rig up\n")

    # Preserve untouched bytes when replacing text in a CRLF file.
    def test_preserves_line_endings_and_unicode(self):
        self.map.write_text("a.sh up\trig up\n", encoding="utf-8")
        self.file.write_bytes("café\r\na.sh up\r\nlast".encode("utf-8"))
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_bytes(), "café\r\nrig up\r\nlast".encode("utf-8"))

    # Add dry-run diff output without changing the input bytes.
    def test_dry_run_writes_nothing(self):
        self.map.write_text("a.sh up\trig up\n")
        self.file.write_bytes(b"run a.sh up\n")
        result = self.run_rewrite(dry_run=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_bytes(), b"run a.sh up\n")
        self.assertIn(f"--- {self.file}\n+++ {self.file}\n@@ -1 +1 @@\n", result.stdout)
        self.assertIn("-run a.sh up\n+run rig up\n", result.stdout)
        self.assertTrue(result.stdout.endswith(f"{self.file}: 1 changes\ntotal 1\n"))

    # Recognize expanded regex replacement text when the old pattern is gone.
    def test_regex_second_run_changes_nothing(self):
        self.map.write_text(r"re:curl -sS (\S+)" + "\t" + r"rig call x GET \1" + "\n")
        self.file.write_text("curl -sS /a\ncurl -sS /b\n")
        first = self.run_rewrite()
        self.assertEqual(first.returncode, 0, first.stderr)
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "total 0\n")
        self.assertEqual(self.file.read_bytes(), b"rig call x GET /a\nrig call x GET /b\n")

    # Validate map syntax before any output or write.
    def test_invalid_map_row_is_reported_without_traceback(self):
        row = "missing tab"
        self.map.write_text("a.sh up\trig up\n" + row + "\n")
        self.file.write_bytes(b"a.sh up\n")
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        self.assertIn(row, result.stderr)
        self.assertIn("fix:", result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertEqual(self.file.read_bytes(), b"a.sh up\n")

    # Reject invalid regexes and templates before any file write.
    def test_invalid_regex_rows_leave_all_files_unchanged(self):
        for row in ("re:[\trig call", r"re:(missing)" + "\t" + r"rig \2"):
            with self.subTest(row=row):
                self.map.write_text("a.sh up\trig up\n" + row + "\n")
                self.file.write_bytes(b"a.sh up\n")
                result = self.run_rewrite()
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertNotIn("Traceback", result.stderr)
                self.assertIn(row, result.stderr)
                self.assertIn("fix:", result.stderr)
                self.assertEqual(result.stdout, "")
                self.assertEqual(self.file.read_bytes(), b"a.sh up\n")

    # Recognize Python named and explicit numeric replacement references.
    def test_regex_named_and_escaped_replacements_are_idempotent(self):
        self.map.write_text(
            r"re:curl (?P<path>\S+)" + "\t" + r"rig \g<path> \g<1> \\literal\n" + "\n")
        self.file.write_text("curl /a")
        first = self.run_rewrite()
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(self.file.read_bytes(), b"rig /a /a \\literal\n")
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "total 0\n")

    # Surface file errors at the CLI boundary and do not write other files.
    def test_missing_input_leaves_other_files_unchanged(self):
        self.map.write_text("a.sh up\trig up\n")
        self.file.write_bytes(b"a.sh up\n")
        missing = self.root / "absent.md"
        result = self.run_rewrite(self.file, missing)
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        self.assertIn(str(missing), result.stderr)
        self.assertIn("fix:", result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertEqual(self.file.read_bytes(), b"a.sh up\n")

    # Count changed matches, apply rows in order, and accept corpus-wide presence.
    def test_applies_rows_in_order_and_counts_only_changes(self):
        self.map.write_text(
            r"re:curl (\S+)" + "\t" + r"send \1" + "\n"
            "send /a\trig call /a\nrig call /a\trig call /a\n")
        self.file.write_text("curl /a\ncurl /a\n")
        other = self.root / "other.md"
        other.write_bytes(b"unrelated\n")
        result = self.run_rewrite(self.file, other)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_bytes(), b"rig call /a\nrig call /a\n")
        self.assertEqual(other.read_bytes(), b"unrelated\n")
        self.assertEqual(result.stdout, f"{self.file}: 4 changes\ntotal 4\n")

    # A failed atomic rename must leave the old file and no temporary file.
    def test_failed_replace_keeps_original_bytes(self):
        self.map.write_text("a.sh up\trig up\n")
        self.file.write_bytes(b"a.sh up\n")
        launcher = (
            "import runpy, sys\nfrom unittest.mock import patch\n"
            "script = sys.argv.pop(1)\n"
            "with patch('os.replace', side_effect=OSError('rename failed')):\n"
            "    runpy.run_path(script, run_name='__main__')\n")
        result = subprocess.run(
            [sys.executable, "-c", launcher, str(SCRIPT), str(self.map), str(self.file)],
            capture_output=True, text=True)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        self.assertEqual(self.file.read_bytes(), b"a.sh up\n")
        self.assertEqual(sorted(path.name for path in self.root.iterdir()), ["guide.md", "map.tsv"])

    # No-op regex matches must not rewrite files or report changes.
    def test_regex_identity_second_run_changes_nothing(self):
        self.map.write_text(r"re:(rig \S+)" + "\t" + r"\1" + "\n")
        self.file.write_bytes(b"rig up\n")
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "total 0\n")
        self.assertEqual(self.file.read_bytes(), b"rig up\n")

    # Unified diff lines need separators when input has no final newline.
    def test_dry_run_handles_missing_final_newline(self):
        self.map.write_text("a.sh up\trig up\n")
        self.file.write_bytes(b"a.sh up")
        result = self.run_rewrite(dry_run=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_bytes(), b"a.sh up")
        self.assertIn("-a.sh up\n\\ No newline at end of file\n", result.stdout)
        self.assertIn("+rig up\n\\ No newline at end of file\n", result.stdout)
        self.assertTrue(result.stdout.endswith(f"{self.file}: 1 changes\ntotal 1\n"))

    # Atomic writes must follow input links and preserve target permissions.
    def test_rewrites_symlink_target_and_preserves_mode(self):
        self.map.write_text("a.sh up\trig up\n")
        target = self.root / "target.md"
        target.write_bytes(b"a.sh up\n")
        target.chmod(0o751)
        self.file.symlink_to(target.name)
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.file.is_symlink())
        self.assertEqual(target.read_bytes(), b"rig up\n")
        self.assertEqual(target.stat().st_mode & 0o777, 0o751)


if __name__ == "__main__":
    unittest.main()
