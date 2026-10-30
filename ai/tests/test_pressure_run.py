"""Tests for ai/bin/pressure-run. They use saved event lines and bill no run."""

import importlib.machinery
import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "ai" / "bin" / "pressure-run"
FIXTURES = ROOT / "ai" / "tests" / "fixtures"


def load_module():
    loader = importlib.machinery.SourceFileLoader("pressure_run", str(SCRIPT))
    spec = importlib.util.spec_from_loader("pressure_run", loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


def fixture(name):
    return [json.loads(line) for line in (FIXTURES / name).read_text().splitlines() if line]


def claude_text(text):
    return {"type": "result", "subtype": "success", "is_error": False, "result": text}


class PressureRunTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.pr = load_module()

    def test_claude_skill_tool_detected(self):
        events = fixture("claude_skill_tool.jsonl")
        self.assertEqual(self.pr.skill_loaded(events, "claude"), {"pressure-probe"})
        self.assertEqual(self.pr.skill_loaded([], "claude"), set())

    def test_claude_read_of_skill_md_detected(self):
        events = [
            {
                "type": "assistant",
                "message": {
                    "content": [
                        {
                            "type": "tool_use",
                            "name": "Read",
                            "input": {"file_path": "/wt/dotfiles/ai/skills/tdd/SKILL.md"},
                        }
                    ]
                },
            }
        ]
        self.assertEqual(self.pr.skill_loaded(events, "claude"), {"tdd"})
        self.assertEqual(self.pr.files_read(events, "claude"), {"/wt/dotfiles/ai/skills/tdd/SKILL.md"})

    def test_codex_command_detected(self):
        events = fixture("codex_command.jsonl")
        self.assertEqual(self.pr.skill_loaded(events, "codex"), {"pressure-probe"})
        self.assertIn(".agents/skills/pressure-probe/SKILL.md", self.pr.files_read(events, "codex"))

    def test_principle_read_detected(self):
        claude = fixture("claude_read_principle.jsonl")
        codex = fixture("codex_principle_read.jsonl")
        self.assertEqual(self.pr.principles_read(claude, "claude"), {"attack-the-premise"})
        self.assertEqual(self.pr.principles_read(codex, "codex"), {"attack-the-premise"})
        # A skill read is not a principle read.
        self.assertEqual(self.pr.principles_read(fixture("codex_command.jsonl"), "codex"), set())

    def test_missing_principles_line_fails(self):
        skill = fixture("claude_skill_tool.jsonl")
        read = fixture("claude_read_principle.jsonl")
        ok = skill + read + [claude_text("Done.\nPrinciples applied: attack-the-premise -> kept the scope")]
        bad = skill + read + [claude_text("Done. No such line.")]
        self.assertEqual(self.pr.check("claude", ok, "pressure-probe", ["attack-the-premise"]), [])
        failures = self.pr.check("claude", bad, "pressure-probe", ["attack-the-premise"])
        self.assertEqual(len(failures), 1)
        self.assertIn("Principles applied", failures[0])
        # Unread principle and unloaded skill are each reported.
        failures = self.pr.check("claude", [claude_text("Principles applied: x -> y")], "tdd", ["boundary-discipline"])
        self.assertEqual(len(failures), 2)

    def test_final_answer(self):
        self.assertEqual(self.pr.final_answer(fixture("claude_result.jsonl"), "claude"), "PROBE-LOADED")
        self.assertEqual(self.pr.final_answer(fixture("codex_message.jsonl"), "codex"), "PROBE-LOADED")

    def test_dry_run_prints_both_commands(self):
        with tempfile.TemporaryDirectory() as tmp:
            scenario = Path(tmp) / "s.md"
            scenario.write_text("Do the thing.\n")
            out = Path(tmp) / "out"
            run = subprocess.run(
                [sys.executable, str(SCRIPT), "--scenario", str(scenario), "--skill", "tdd",
                 "--tool", "both", "--out", str(out), "--dry-run"],
                capture_output=True, text=True,
            )
            self.assertEqual(run.returncode, 0, run.stderr)
            self.assertIn("claude -p", run.stdout)
            self.assertIn("--permission-mode plan", run.stdout)
            self.assertIn("--max-budget-usd", run.stdout)
            self.assertIn("codex exec --json", run.stdout)
            self.assertIn("-s read-only", run.stdout)
            self.assertFalse(out.exists(), "dry run must not write")

    def test_write_flag_changes_modes(self):
        claude = self.pr.claude_command("p", write=True, budget=0.25)
        codex = self.pr.codex_command("p", Path("/x"), write=True)
        self.assertIn("acceptEdits", claude)
        self.assertIn("workspace-write", codex)

    def test_setup_errors_exit_two(self):
        with tempfile.TemporaryDirectory() as tmp:
            run = subprocess.run(
                [sys.executable, str(SCRIPT), "--scenario", str(Path(tmp) / "none.md"),
                 "--out", str(Path(tmp) / "o"), "--dry-run"],
                capture_output=True, text=True,
            )
            self.assertEqual(run.returncode, 2)


if __name__ == "__main__":
    unittest.main()
