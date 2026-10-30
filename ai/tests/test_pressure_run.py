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

    def test_no_principles_needs_no_line(self):
        skill = fixture("claude_skill_tool.jsonl")
        answer = [claude_text("One question. Recommended: A.")]
        self.assertEqual(self.pr.check("claude", skill + answer, "pressure-probe", []), [])

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
            self.assertIn("--setting-sources project", run.stdout)
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


    # Detection counts only successful readers.
    def test_codex_failed_or_non_reader_not_counted(self):
        def cmd(command, code):
            return {"type": "item.completed", "item": {"type": "command_execution", "command": command,
                                                       "exit_code": code, "status": "completed"}}
        failed_ls = [cmd("/bin/zsh -lc 'ls ~/.agents/principles/x.md'", 1)]
        failed_cat = [cmd("/bin/zsh -lc 'cat ~/.agents/principles/x.md'", 1)]
        grep = [cmd("/bin/zsh -lc 'grep -n foo .agents/skills/tdd/SKILL.md'", 0)]
        started = [{"type": "item.started", "item": {"type": "command_execution",
                    "command": "cat .agents/skills/tdd/SKILL.md", "exit_code": None}}]
        for events in (failed_ls, failed_cat, grep, started):
            self.assertEqual(self.pr.principles_read(events, "codex"), set())
            self.assertEqual(self.pr.skill_loaded(events, "codex"), set())
        ok = [cmd("/bin/zsh -lc 'sed -n 1,20p .agents/skills/tdd/SKILL.md'", 0)]
        self.assertEqual(self.pr.skill_loaded(ok, "codex"), {"tdd"})

    def test_claude_read_error_not_counted(self):
        use = {"type": "assistant", "message": {"content": [
            {"type": "tool_use", "id": "t1", "name": "Read",
             "input": {"file_path": "/h/.agents/principles/x.md"}}]}}
        err = {"type": "user", "message": {"content": [
            {"type": "tool_result", "tool_use_id": "t1", "is_error": True, "content": "File does not exist"}]}}
        self.assertEqual(self.pr.principles_read([use, err], "claude"), set())
        self.assertEqual(self.pr.principles_read([use], "claude"), {"x"})

    def test_claude_bash_reader_counted(self):
        use = {"type": "assistant", "message": {"content": [
            {"type": "tool_use", "id": "b1", "name": "Bash",
             "input": {"command": "cat /h/.agents/principles/a.md /h/.agents/principles/b.md"}}]}}
        err = {"type": "user", "message": {"content": [
            {"type": "tool_result", "tool_use_id": "b1", "is_error": True, "content": "No such file"}]}}
        self.assertEqual(self.pr.principles_read([use], "claude"), {"a", "b"})
        self.assertEqual(self.pr.principles_read([use, err], "claude"), set())
        ls = {"type": "assistant", "message": {"content": [
            {"type": "tool_use", "id": "b2", "name": "Bash", "input": {"command": "ls /h/.agents/principles/a.md"}}]}}
        self.assertEqual(self.pr.principles_read([ls], "claude"), set())

    # Run errors are exit 2 with the cause, not exit 1.
    def test_run_error_causes(self):
        budget = {"type": "result", "subtype": "error_max_budget_usd", "is_error": True}
        self.assertIn("error_max_budget_usd", self.pr.run_error([budget], "claude"))
        self.assertIsNone(self.pr.run_error(fixture("claude_result.jsonl"), "claude"))
        self.assertIn("turn.completed", self.pr.run_error(fixture("codex_message.jsonl"), "codex"))
        self.assertIsNone(self.pr.run_error(fixture("codex_message.jsonl") + [{"type": "turn.completed"}], "codex"))

    def _run_main_with_fake_cli(self, stdout, returncode, tool="claude"):
        import contextlib, io
        from unittest import mock
        done = subprocess.CompletedProcess([], returncode, stdout=stdout, stderr="boom")
        with tempfile.TemporaryDirectory() as tmp:
            scenario = Path(tmp) / "s.md"
            scenario.write_text("x")
            err = io.StringIO()
            with mock.patch.object(self.pr.subprocess, "run", return_value=done), \
                    mock.patch.object(self.pr.shutil, "which", return_value="/bin/x"), \
                    contextlib.redirect_stderr(err), contextlib.redirect_stdout(io.StringIO()):
                code = self.pr.main(["--scenario", str(scenario), "--tool", tool, "--red", "--out", str(Path(tmp) / "o")])
            return code, err.getvalue()

    def test_budget_stop_exits_two_with_cause(self):
        line = json.dumps({"type": "result", "subtype": "error_max_budget_usd", "is_error": True})
        code, err = self._run_main_with_fake_cli(line + "\n", 1)
        self.assertEqual(code, 2)
        self.assertIn("error_max_budget_usd", err)

    def test_cli_nonzero_exit_is_setup_error(self):
        line = json.dumps({"type": "result", "subtype": "success", "is_error": False, "result": "ok"})
        code, err = self._run_main_with_fake_cli(line + "\n", 1)
        self.assertEqual(code, 2)
        self.assertIn("exited 1", err)

    def test_command_sources_flag(self):
        self.assertIn("project", self.pr.claude_command("p"))
        cmd = self.pr.claude_command("p", sources="user,project")
        self.assertEqual(cmd[cmd.index("--setting-sources") + 1], "user,project")

    def test_scratch_has_router_and_red_has_no_skill(self):
        import shutil
        for tool, base in (("claude", ".claude"), ("codex", ".agents")):
            green = self.pr.prepare_scratch(tool, "tdd", red=False)
            red = self.pr.prepare_scratch(tool, "tdd", red=True)
            try:
                self.assertEqual((green / base / "skills" / "tdd").readlink(), self.pr.SKILLS_DIR / "tdd")
                self.assertFalse((red / base).exists())
                for d in (green, red):
                    self.assertTrue((d / "AGENTS.md").is_file() and not (d / "AGENTS.md").is_symlink())
                    self.assertEqual((d / "AGENTS.md").read_text(), (ROOT / "ai" / "AGENTS.md").read_text())
                    self.assertEqual((d / "CLAUDE.md").read_text(), "@AGENTS.md\n")
            finally:
                shutil.rmtree(green, ignore_errors=True)
                shutil.rmtree(red, ignore_errors=True)

    def test_red_note_names_user_level_skill(self):
        with tempfile.TemporaryDirectory() as home:
            self.assertEqual(self.pr.red_note("debug", home), [])
            (Path(home) / ".agents" / "skills" / "debug").mkdir(parents=True)
            self.assertEqual(self.pr.red_note("debug", home), [Path(home) / ".agents" / "skills" / "debug"])


    def test_reads_split_on_newlines_and_expand_braces(self):
        def cmd(command, code=0, out=""):
            return [{"type": "item.completed", "item": {"type": "command_execution", "command": command,
                                                        "exit_code": code, "aggregated_output": out}}]
        multi = "/bin/zsh -lc 'ls /x\ncat /h/.agents/principles/a.md'"
        self.assertEqual(self.pr.principles_read(cmd(multi), "codex"), {"a"})
        brace = "/bin/zsh -lc 'cat /h/.agents/principles/{a,b}.md'"
        self.assertEqual(self.pr.principles_read(cmd(brace), "codex"), {"a", "b"})
        use = {"type": "assistant", "message": {"content": [
            {"type": "tool_use", "id": "b3", "name": "Bash",
             "input": {"command": "cat /h/.agents/principles/a.md\nhead /h/.agents/principles/b.md"}}]}}
        self.assertEqual(self.pr.principles_read([use], "claude"), {"a", "b"})

    def test_failed_call_counts_reads_that_did_not_fail(self):
        def cmd(command, out):
            return [{"type": "item.completed", "item": {"type": "command_execution", "command": command,
                                                        "exit_code": 1, "aggregated_output": out}}]
        later_ls = "/bin/zsh -lc 'cat /h/.agents/principles/a.md; ls /nope'"
        out = "text of a\nls: /nope: No such file or directory\n"
        self.assertEqual(self.pr.principles_read(cmd(later_ls, out), "codex"), {"a"})
        two = "/bin/zsh -lc 'cat /h/.agents/principles/a.md /h/.agents/principles/b.md'"
        out = "text of a\ncat: /h/.agents/principles/b.md: No such file or directory\n"
        self.assertEqual(self.pr.principles_read(cmd(two, out), "codex"), {"a"})
        self.assertEqual(self.pr.principles_read(cmd(two, ""), "codex"), set())
        use = {"type": "assistant", "message": {"content": [
            {"type": "tool_use", "id": "b4", "name": "Bash",
             "input": {"command": "cat /h/.agents/principles/a.md; ls /nope"}}]}}
        err = {"type": "user", "message": {"content": [
            {"type": "tool_result", "tool_use_id": "b4", "is_error": True,
             "content": "Exit code 1\ntext of a\nls: /nope: No such file or directory"}]}}
        self.assertEqual(self.pr.principles_read([use, err], "claude"), {"a"})

    def test_codex_compound_commands(self):
        def cmd(command, code=0):
            return [{"type": "item.completed", "item": {"type": "command_execution", "command": command,
                                                        "exit_code": code}}]
        for command in ("/bin/zsh -lc 'cd /x && cat .agents/skills/tdd/SKILL.md'",
                        "/bin/zsh -lc 'ls x; cat .agents/skills/tdd/SKILL.md'",
                        "/bin/zsh -lc 'ls x;cat .agents/skills/tdd/SKILL.md'"):
            self.assertEqual(self.pr.skill_loaded(cmd(command), "codex"), {"tdd"}, command)
        for command in ("/bin/zsh -lc 'cd /x && ls .agents/skills/tdd/SKILL.md'",
                        "/bin/zsh -lc 'cd /x && grep a .agents/skills/tdd/SKILL.md | wc -l'"):
            self.assertEqual(self.pr.skill_loaded(cmd(command), "codex"), set(), command)
        self.assertEqual(self.pr.skill_loaded(cmd("/bin/zsh -lc 'cd /x && cat .agents/skills/tdd/SKILL.md'", 1), "codex"), set())


if __name__ == "__main__":
    unittest.main()
