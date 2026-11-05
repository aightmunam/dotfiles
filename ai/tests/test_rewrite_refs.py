"""CLI tests for rewrite-refs, using only the standard library."""
import json
import os
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
        receipts = tempfile.TemporaryDirectory()
        self.addCleanup(receipts.cleanup)
        self.cache = Path(receipts.name) / "receipts"
        self.env = dict(os.environ, REWRITE_REFS_CACHE_DIR=str(self.cache))

    def run_rewrite(self, *files, dry_run=False):
        self.assertTrue(SCRIPT.exists(), "rewrite-refs not found")
        return subprocess.run(
            [str(SCRIPT), *(["--dry-run"] if dry_run else []),
             str(self.map), *map(str, files or (self.file,))],
            capture_output=True, text=True, env=self.env,
        )

    def run_interrupted(self, *files):
        launcher = (
            "import os, runpy, sys\nfrom unittest.mock import patch\n"
            "script = sys.argv.pop(1)\nblocked = sys.argv.pop(1)\n"
            "replace = os.replace\n"
            "def interrupt(source, target):\n"
            "    if str(target) == blocked:\n"
            "        raise OSError('interrupted batch')\n"
            "    return replace(source, target)\n"
            "with patch('os.replace', side_effect=interrupt):\n"
            "    runpy.run_path(script, run_name='__main__')\n")
        return subprocess.run(
            [sys.executable, "-c", launcher, str(SCRIPT), str(files[-1].resolve()),
             str(self.map), *map(str, files)],
            capture_output=True, text=True, env=self.env)

    def test_retry_does_not_repeat_substitutions(self):
        for row, source, target in (
                ("a\tba\n", b"a\n", b"ba\n"),
                (r"re:call (\S+)" + "\t" + r"rig call \1" + "\n",
                 b"call /a\n", b"rig call /a\n")):
            with self.subTest(row=row):
                self.map.write_text(row)
                self.file.write_bytes(source)
                first = self.run_rewrite()
                self.assertEqual(first.returncode, 0, first.stderr)
                self.assertEqual(self.file.read_bytes(), target)
                result = self.run_rewrite()
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(result.stdout, "total 0\n")
                self.assertEqual(self.file.read_bytes(), target)

    def test_retry_after_partial_batch_skips_completed_file(self):
        for row, source, target in (
                ("a\tba\n", b"a\n", b"ba\n"),
                (r"re:call (\S+)" + "\t" + r"rig call \1" + "\n",
                 b"call /a\n", b"rig call /a\n")):
            with self.subTest(row=row):
                self.map.write_text(row)
                self.file.write_bytes(source)
                other = self.root / "other.md"
                other.write_bytes(source)
                first = self.run_interrupted(self.file, other)
                self.assertEqual(first.returncode, 1, first.stdout + first.stderr)
                self.assertEqual(self.file.read_bytes(), target)
                self.assertEqual(other.read_bytes(), source)
                result = self.run_rewrite(self.file, other)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.file.read_bytes(), target)
                self.assertEqual(other.read_bytes(), target)
                self.assertEqual(result.stdout, f"{other}: 1 changes\ntotal 1\n")
                repeated = self.run_rewrite(self.file, other)
                self.assertEqual(repeated.returncode, 0, repeated.stderr)
                self.assertEqual(repeated.stdout, "total 0\n")

    def test_capture_output_requires_exact_prior_evidence(self):
        row = r"re:old (\d+)" + "\t" + r"rig \1"
        for text in (b"rig abc\n", b"rig 12\n"):
            with self.subTest(text=text):
                self.map.write_text("a.sh up\trig up\n" + row + "\n")
                self.file.write_bytes(b"a.sh up\n" + text)
                result = self.run_rewrite()
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertIn(row, result.stderr)
                self.assertNotIn("Traceback", result.stderr)
                self.assertEqual(result.stdout, "")
                self.assertEqual(self.file.read_bytes(), b"a.sh up\n" + text)
                self.assertFalse(self.cache.exists())

    def test_capture_presence_uses_observed_expansion(self):
        row = r"re:old (\d+)" + "\t" + r"rig \1"
        self.map.write_text(row + "\n")
        self.file.write_bytes(b"old 12\n")
        first = self.run_rewrite()
        self.assertEqual(first.returncode, 0, first.stderr)
        self.assertEqual(self.file.read_bytes(), b"rig 12\n")
        self.file.write_bytes(b"rig 12\nnotes\n")
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "total 0\n")
        self.assertEqual(self.file.read_bytes(), b"rig 12\nnotes\n")
        for text in (b"rig abc\nnotes\n", b"rig 34\nnotes\n"):
            with self.subTest(text=text):
                self.file.write_bytes(text)
                result = self.run_rewrite()
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertIn(row, result.stderr)
                self.assertEqual(self.file.read_bytes(), text)

    def test_partial_retry_accepts_consumed_intermediate_expansions(self):
        self.map.write_text(
            r"re:call (\d+)" + "\t" + r"send \1" + "\n" +
            r"re:send (\d+)" + "\t" + r"rig \1" + "\nremaining\tdone\n")
        self.file.write_bytes(b"call 12\n")
        other = self.root / "other.md"
        other.write_bytes(b"remaining\n")
        first = self.run_interrupted(self.file, other)
        self.assertEqual(first.returncode, 1, first.stdout + first.stderr)
        self.assertEqual(self.file.read_bytes(), b"rig 12\n")
        self.assertEqual(other.read_bytes(), b"remaining\n")
        result = self.run_rewrite(self.file, other)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, f"{other}: 1 changes\ntotal 1\n")
        self.assertEqual(self.file.read_bytes(), b"rig 12\n")
        self.assertEqual(other.read_bytes(), b"done\n")
        repeated = self.run_rewrite(self.file, other)
        self.assertEqual(repeated.returncode, 0, repeated.stderr)
        self.assertEqual(repeated.stdout, "total 0\n")

    def test_receipt_evidence_is_scoped_by_map_and_input_paths(self):
        row = r"re:old (\d+)" + "\t" + r"rig \1" + "\n"
        self.map.write_text(row)
        self.file.write_bytes(b"old 12\n")
        first = self.run_rewrite()
        self.assertEqual(first.returncode, 0, first.stderr)
        other = self.root / "other.md"
        other.write_bytes(b"rig 12\n")
        different_path = self.run_rewrite(other)
        self.assertEqual(different_path.returncode, 1, different_path.stdout + different_path.stderr)
        self.assertEqual(other.read_bytes(), b"rig 12\n")
        self.map.write_text(r"re:different (\d+)" + "\t" + r"rig \1" + "\n")
        different_map = self.run_rewrite()
        self.assertEqual(different_map.returncode, 1, different_map.stdout + different_map.stderr)
        self.assertEqual(self.file.read_bytes(), b"rig 12\n")
        self.map.write_text(row)
        restored = self.run_rewrite()
        self.assertEqual(restored.returncode, 0, restored.stderr)
        self.assertEqual(restored.stdout, "total 0\n")

    def test_dry_run_does_not_create_or_change_receipts(self):
        self.map.write_text("a\tba\n")
        self.file.write_bytes(b"a\n")
        preview = self.run_rewrite(dry_run=True)
        self.assertEqual(preview.returncode, 0, preview.stderr)
        self.assertEqual(self.file.read_bytes(), b"a\n")
        self.assertFalse(self.cache.exists())
        first = self.run_rewrite()
        self.assertEqual(first.returncode, 0, first.stderr)
        before = {path.name: path.read_bytes() for path in self.cache.iterdir()}
        self.assertTrue(before)
        self.file.write_bytes(b"a\n")
        preview = self.run_rewrite(dry_run=True)
        self.assertEqual(preview.returncode, 0, preview.stderr)
        self.assertIn("-a\n+ba\n", preview.stdout)
        self.assertEqual(self.file.read_bytes(), b"a\n")
        self.assertEqual({path.name: path.read_bytes() for path in self.cache.iterdir()}, before)
        retry = self.run_rewrite()
        self.assertEqual(retry.returncode, 0, retry.stderr)
        self.assertEqual(self.file.read_bytes(), b"ba\n")

    def test_rejects_receipts_without_required_keys_or_object_root(self):
        self.map.write_text("a\tba\n")
        self.file.write_bytes(b"a\n")
        first = self.run_rewrite()
        self.assertEqual(first.returncode, 0, first.stderr)
        receipt_path, = self.cache.glob("*.json")
        receipt = json.loads(receipt_path.read_bytes())
        invalid = [None, False, 1, "receipt", [], {}]
        invalid.extend({key: value for key, value in receipt.items() if key != missing}
                       for missing in receipt)
        for payload in invalid:
            with self.subTest(payload=payload):
                self.file.write_bytes(b"a\n")
                before = json.dumps(payload).encode("utf-8")
                receipt_path.write_bytes(before)
                result = self.run_rewrite()
                self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                self.assertNotIn("Traceback", result.stderr)
                self.assertIn("fix:", result.stderr)
                self.assertIn(str(receipt_path), result.stderr)
                self.assertEqual(result.stdout, "")
                self.assertEqual(self.file.read_bytes(), b"a\n")
                self.assertEqual(receipt_path.read_bytes(), before)

    def test_rejects_invalid_receipt_fields_before_writes_or_completed_retry(self):
        self.map.write_text("a\tba\nc\tdc\ndc\tdc\n")
        self.file.write_bytes(b"a\n")
        other = self.root / "other.md"
        other.write_bytes(b"c\n")
        first = self.run_rewrite(self.file, other)
        self.assertEqual(first.returncode, 0, first.stderr)
        receipt_path, = self.cache.glob("*.json")
        receipt = json.loads(receipt_path.read_bytes())
        invalid = [(field, value) for field in ("sources", "targets", "expansions")
                   for value in (None, False, 1, "wrong", {})]
        invalid.extend((field, value) for field in ("sources", "targets", "expansions")
                       for value in ([], receipt[field][:1], receipt[field] + receipt[field][:1]))
        invalid.extend((field, [value, receipt[field][1]])
                       for field in ("sources", "targets")
                       for value in (None, False, 1, {}, [], "", "a" * 63, "a" * 65,
                                     "g" * 64, "A" * 64, "a" * 64 + "\n"))
        invalid.extend(("expansions", [value, *receipt["expansions"][1:]])
                       for value in (None, False, 1, {}, "ba", [None], [False], [1], [{}], [[]]))
        for field, value in invalid:
            for originals in ((b"a\n", b"c\n"), (b"ba\n", b"dc\n")):
                for dry_run in (False, True):
                    with self.subTest(field=field, value=value, originals=originals, dry_run=dry_run):
                        self.file.write_bytes(originals[0])
                        other.write_bytes(originals[1])
                        before = json.dumps(receipt | {field: value}).encode("utf-8")
                        receipt_path.write_bytes(before)
                        result = self.run_rewrite(self.file, other, dry_run=dry_run)
                        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
                        self.assertNotIn("Traceback", result.stderr)
                        self.assertIn("fix:", result.stderr)
                        self.assertIn(str(receipt_path), result.stderr)
                        self.assertEqual(result.stdout, "")
                        self.assertEqual(self.file.read_bytes(), originals[0])
                        self.assertEqual(other.read_bytes(), originals[1])
                        self.assertEqual(receipt_path.read_bytes(), before)

    def test_rewrites_each_pair(self):
        self.map.write_text("a.sh up\trig up\n", encoding="utf-8")
        self.file.write_text("run a.sh up\n", encoding="utf-8")
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_text(), "run rig up\n")
        self.assertEqual(result.stdout, f"{self.file}: 1 changes\ntotal 1\n")
        self.assertEqual(result.stderr, "")

    def test_regex_row_uses_groups(self):
        self.map.write_text(r"re:curl -sS (\S+)" + "\t" + r"rig call x GET \1" + "\n")
        self.file.write_text("curl -sS /a\n")
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_text(), "rig call x GET /a\n")
        self.assertEqual(result.stdout, f"{self.file}: 1 changes\ntotal 1\n")

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

    def test_second_run_changes_nothing(self):
        self.map.write_text("a.sh up\trig up\n")
        self.file.write_text("run a.sh up\n")
        first = self.run_rewrite()
        self.assertEqual(first.returncode, 0, first.stderr)
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "total 0\n")
        self.assertEqual(self.file.read_bytes(), b"run rig up\n")

    def test_preserves_line_endings_and_unicode(self):
        self.map.write_text("a.sh up\trig up\n", encoding="utf-8")
        self.file.write_bytes("café\r\na.sh up\r\nlast".encode("utf-8"))
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_bytes(), "café\r\nrig up\r\nlast".encode("utf-8"))

    def test_dry_run_writes_nothing(self):
        self.map.write_text("a.sh up\trig up\n")
        self.file.write_bytes(b"run a.sh up\n")
        result = self.run_rewrite(dry_run=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_bytes(), b"run a.sh up\n")
        self.assertIn(f"--- {self.file}\n+++ {self.file}\n@@ -1 +1 @@\n", result.stdout)
        self.assertIn("-run a.sh up\n+run rig up\n", result.stdout)
        self.assertTrue(result.stdout.endswith(f"{self.file}: 1 changes\ntotal 1\n"))

    def test_regex_second_run_changes_nothing(self):
        self.map.write_text(r"re:curl -sS (\S+)" + "\t" + r"rig call x GET \1" + "\n")
        self.file.write_text("curl -sS /a\ncurl -sS /b\n")
        first = self.run_rewrite()
        self.assertEqual(first.returncode, 0, first.stderr)
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "total 0\n")
        self.assertEqual(self.file.read_bytes(), b"rig call x GET /a\nrig call x GET /b\n")

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

    def test_failed_replace_keeps_original_bytes(self):
        self.map.write_text("a.sh up\trig up\n")
        self.file.write_bytes(b"a.sh up\n")
        result = self.run_interrupted(self.file)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        self.assertEqual(self.file.read_bytes(), b"a.sh up\n")
        self.assertEqual(sorted(path.name for path in self.root.iterdir()), ["guide.md", "map.tsv"])
        self.assertEqual(len(list(self.cache.glob("*.json"))), 1)

    def test_regex_identity_second_run_changes_nothing(self):
        self.map.write_text(r"re:(rig \S+)" + "\t" + r"\1" + "\n")
        self.file.write_bytes(b"rig up\n")
        result = self.run_rewrite()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "total 0\n")
        self.assertEqual(self.file.read_bytes(), b"rig up\n")

    def test_dry_run_handles_missing_final_newline(self):
        self.map.write_text("a.sh up\trig up\n")
        self.file.write_bytes(b"a.sh up")
        result = self.run_rewrite(dry_run=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.file.read_bytes(), b"a.sh up")
        self.assertIn("-a.sh up\n\\ No newline at end of file\n", result.stdout)
        self.assertIn("+rig up\n\\ No newline at end of file\n", result.stdout)
        self.assertTrue(result.stdout.endswith(f"{self.file}: 1 changes\ntotal 1\n"))

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
