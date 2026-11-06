"""Tests for ai/claude/hooks/context-reminder.py (stdlib unittest only)."""
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

HOOK = str(Path(__file__).resolve().parent.parent / "claude" / "hooks" / "context-reminder.py")


def usage_line(tokens, sidechain=False):
    return json.dumps({"type": "assistant", "isSidechain": sidechain, "message": {
        "model": "claude-opus-5-5", "usage": {
            "input_tokens": 10, "cache_creation_input_tokens": 0,
            "cache_read_input_tokens": tokens - 10, "output_tokens": 50}}})


COMPACT = json.dumps({"type": "system", "subtype": "compact_boundary"})


class ContextReminderTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.dir = Path(tmp.name)
        self.transcript = self.dir / "t.jsonl"

    def _run(self, lines, session="s1"):
        self.transcript.write_text("\n".join(lines) + "\n")
        payload = {"hook_event_name": "UserPromptSubmit", "session_id": session,
                   "transcript_path": str(self.transcript), "prompt": "hi"}
        out = subprocess.run(
            ["python3", "-I", HOOK], input=json.dumps(payload), capture_output=True,
            text=True, env={**os.environ, "TMPDIR": str(self.dir)})
        self.assertEqual(out.returncode, 0, out.stderr)
        return json.loads(out.stdout) if out.stdout.strip() else {}

    def test_silent_below_100k(self):
        self.assertEqual(self._run([usage_line(90_000)]), {})

    def test_tells_the_lead_above_100k_but_not_the_user(self):
        out = self._run([usage_line(120_000)])
        ctx = out["hookSpecificOutput"]["additionalContext"]
        self.assertIn("120k", ctx)
        self.assertIn("phase boundary", ctx)
        self.assertNotIn("systemMessage", out)

    def test_tells_the_user_above_150k(self):
        out = self._run([usage_line(160_000)])
        self.assertIn("160k", out["systemMessage"])

    def test_reminds_once_per_25k_band(self):
        self.assertTrue(self._run([usage_line(110_000)]))
        self.assertEqual(self._run([usage_line(115_000)]), {})
        self.assertTrue(self._run([usage_line(126_000)]))

    def test_compaction_resets_the_count(self):
        self.assertEqual(self._run([usage_line(160_000), COMPACT]), {})

    def test_reminds_again_after_compaction_and_regrowth(self):
        self.assertTrue(self._run([usage_line(110_000)]))
        self.assertEqual(self._run([usage_line(110_000), COMPACT]), {})
        self.assertTrue(self._run([usage_line(110_000), COMPACT, usage_line(105_000)]))

    def test_ignores_subagent_usage(self):
        self.assertEqual(self._run([usage_line(50_000), usage_line(180_000, sidechain=True)]), {})

    def test_missing_transcript_is_silent(self):
        payload = {"session_id": "s", "transcript_path": str(self.dir / "nope.jsonl")}
        out = subprocess.run(["python3", "-I", HOOK], input=json.dumps(payload),
                             capture_output=True, text=True, env={**os.environ, "TMPDIR": str(self.dir)})
        self.assertEqual((out.returncode, out.stdout.strip()), (0, ""))


if __name__ == "__main__":
    unittest.main()
