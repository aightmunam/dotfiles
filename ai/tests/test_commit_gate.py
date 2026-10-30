"""Tests for ai/claude/hooks/commit-gate.sh (stdlib unittest only)."""
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
HOOK = str(HERE.parent / "claude" / "hooks" / "commit-gate.sh")
FIXTURE = json.loads((HERE / "fixtures" / "post_tool_use_bash.json").read_text())


class CommitGateTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        tmp = Path(self._tmp.name)
        self.home = tmp / "home"
        self.home.mkdir()
        self.repo = tmp / "repo"
        self.repo.mkdir()
        (self.repo / "pytest.ini").write_text("[pytest]\n")
        env = {**os.environ, "HOME": str(self.home)}
        for args in (["init", "-q"], ["add", "-A"]):
            subprocess.run(["git", "-C", str(self.repo), *args], check=True, env=env)

    def _run(self, payload):
        return subprocess.run(
            ["bash", HOOK],
            input=json.dumps(payload),
            capture_output=True,
            text=True,
            env={**os.environ, "HOME": str(self.home)},
        )

    def _commit_exit(self, command, stdout, stderr=""):
        post = json.loads(json.dumps(FIXTURE))
        post["cwd"] = str(self.repo)
        post["tool_input"]["command"] = command
        post["tool_response"]["stdout"] = stdout
        post["tool_response"]["stderr"] = stderr
        self.assertEqual(self._run(post).returncode, 0)
        pre = {
            "hook_event_name": "PreToolUse",
            "tool_name": "Bash",
            "cwd": str(self.repo),
            "tool_input": {"command": "git commit -m x"},
        }
        return self._run(pre).returncode

    def test_plain_pytest_pass_stamps(self):
        self.assertEqual(self._commit_exit("pytest -q", "3 passed"), 0)

    def test_piped_pytest_does_not_stamp(self):
        self.assertEqual(
            self._commit_exit("pytest -q | tail -5", "1 failed, 2 passed"), 2
        )

    def test_piped_without_failure_text_does_not_stamp(self):
        self.assertEqual(self._commit_exit("pytest -q | tail -5", "3 passed"), 2)

    def test_piped_with_pipefail_stamps_when_output_clean(self):
        self.assertEqual(
            self._commit_exit("set -o pipefail; pytest -q | tail -5", "3 passed"), 0
        )

    def test_semicolon_true_does_not_stamp(self):
        self.assertEqual(self._commit_exit("pytest -q; true", "3 passed"), 2)

    def test_or_true_does_not_stamp(self):
        self.assertEqual(self._commit_exit("pytest -q || true", "3 passed"), 2)

    def test_failure_summary_blocks(self):
        for out in (
            "2 failed, 1 passed",
            "FAILED (failures=1)",
            "test result: FAILED. 0 passed; 1 failed",
            "--- FAIL: TestX",
        ):
            with self.subTest(stdout=out):
                self.assertEqual(self._commit_exit("pytest -q", out), 2)

    def test_failure_in_stderr_blocks(self):
        self.assertEqual(
            self._commit_exit("python3 -m unittest", "", "FAILED (failures=1)"), 2
        )

    def test_zero_failed_does_not_block(self):
        self.assertEqual(self._commit_exit("pytest -q", "3 passed, 0 failed"), 0)

    def test_runner_then_and_chain_stamps(self):
        self.assertEqual(self._commit_exit("pytest -q && echo ok", "3 passed\nok"), 0)


class CommitGateJustTest(CommitGateTest):
    """Same harness, but the repo has a justfile with lint and test recipes."""

    def setUp(self):
        super().setUp()
        (self.repo / "pytest.ini").unlink()
        (self.repo / "justfile").write_text("lint:\n    true\n\ntest:\n    true\n")
        env = {**os.environ, "HOME": str(self.home)}
        subprocess.run(["git", "-C", str(self.repo), "add", "-A"], check=True, env=env)

    # Inherited pytest tests do not apply here.
    for _name in [n for n in dir(CommitGateTest) if n.startswith("test_")]:
        locals()[_name] = None
    del _name

    def test_just_test_clean_stamps_both_needed(self):
        self.assertEqual(self._commit_exit("just lint && just test", "ok"), 0)

    def test_plain_just_test_with_lint_stamps_test(self):
        self._commit_exit("just lint", "ok")
        self.assertEqual(self._commit_exit("just test", "ok"), 0)

    def test_just_test_piped_does_not_stamp(self):
        self._commit_exit("just lint", "ok")
        self.assertEqual(self._commit_exit("just test | tail -5", "ok"), 2)

    def test_just_test_semicolon_true_does_not_stamp(self):
        self._commit_exit("just lint", "ok")
        self.assertEqual(self._commit_exit("just test; true", "ok"), 2)

    def test_just_test_or_true_does_not_stamp(self):
        self._commit_exit("just lint", "ok")
        self.assertEqual(self._commit_exit("just test || true", "ok"), 2)

    def test_just_check_semicolon_true_stamps_nothing(self):
        self.assertEqual(self._commit_exit("just check; true", "ok"), 2)

    def test_just_check_clean_stamps_both(self):
        self.assertEqual(self._commit_exit("just check", "ok"), 0)


if __name__ == "__main__":
    unittest.main()
