"""Tests ai/claude/hooks/syntax-check.sh (stdlib unittest only)."""
import json
import subprocess
import tempfile
import unittest
from pathlib import Path

HOOK = str(Path(__file__).resolve().parent.parent / "claude" / "hooks" / "syntax-check.sh")

try:
    import yaml  # noqa: F401
    HAS_YAML = True
except ImportError:
    HAS_YAML = False


class SyntaxCheckTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)

    def _run(self, name, text):
        path = self.dir / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        payload = {"hook_event_name": "PostToolUse", "tool_name": "Edit",
                   "tool_input": {"file_path": str(path)}}
        return subprocess.run(["bash", HOOK], input=json.dumps(payload),
                              capture_output=True, text=True)

    def test_reports_a_broken_file_to_claude(self):
        for name, text in [
            ("a.py", "def f(:\n"),
            ("a.sh", "if true; then\n"),
            ("a.json", '{"a": 1,}\n'),
        ]:
            out = self._run(name, text)
            self.assertEqual(out.returncode, 2, name)
            self.assertIn(name, out.stderr)
            self.assertIn("line", out.stderr.lower(), name)

    def test_passes_a_valid_file_quietly(self):
        for name, text in [
            ("a.py", "x = 1\n"),
            ("a.sh", "echo hi\n"),
            ("a.json", '{"a": 1}\n'),
            ("notes.txt", "def f(:\n"),
        ]:
            out = self._run(name, text)
            self.assertEqual((out.returncode, out.stderr), (0, ""), name)

    def test_python_check_writes_no_bytecode(self):
        self._run("a.py", "x = 1\n")
        self.assertFalse((self.dir / "__pycache__").exists())

    def test_skips_json_with_comments(self):
        for name in ["tsconfig.json", "tsconfig.base.json", ".vscode/settings.json"]:
            out = self._run(name, '{\n  // comment\n  "a": 1,\n}\n')
            self.assertEqual(out.returncode, 0, name)

    def test_ignores_a_missing_file(self):
        payload = {"tool_input": {"file_path": str(self.dir / "gone.py")}}
        out = subprocess.run(["bash", HOOK], input=json.dumps(payload),
                             capture_output=True, text=True)
        self.assertEqual(out.returncode, 0)

    @unittest.skipUnless(HAS_YAML, "PyYAML is not installed")
    def test_yaml_with_tags_and_documents_passes(self):
        text = "a: !Ref Thing\n---\nb: !reference [x, y]\n"
        self.assertEqual(self._run("a.yaml", text).returncode, 0)

    @unittest.skipUnless(HAS_YAML, "PyYAML is not installed")
    def test_reports_broken_yaml(self):
        self.assertEqual(self._run("a.yml", "a: [1, 2\n").returncode, 2)


if __name__ == "__main__":
    unittest.main()
