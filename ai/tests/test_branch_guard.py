"""Tests ai/claude/hooks/branch-guard.sh (stdlib unittest only)."""
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

HOOK = str(Path(__file__).resolve().parent.parent / "claude" / "hooks" / "branch-guard.sh")


def git(cwd, *args):
    subprocess.run(["git", "-C", str(cwd), *args], check=True, capture_output=True)


class BranchGuardTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        git(self.repo, "init", "-q", "-b", "master")
        git(self.repo, "-c", "user.name=t", "-c", "user.email=t@t", "commit", "-q", "--allow-empty", "-m", "x")

    def _decision(self, command, cwd=None):
        payload = {
            "hook_event_name": "PreToolUse",
            "tool_name": "Bash",
            "tool_input": {"command": command},
            "cwd": str(cwd or self.repo),
        }
        out = subprocess.run(
            ["bash", HOOK], input=json.dumps(payload), capture_output=True, text=True,
            env={**os.environ, "HOME": str(self.root)},
        )
        self.assertEqual(out.returncode, 0, out.stderr)
        if not out.stdout.strip():
            return "allow"
        return json.loads(out.stdout)["hookSpecificOutput"]["permissionDecision"]

    def test_asks_before_a_push_to_main_or_master(self):
        for command in [
            "git push",
            "git push origin",
            "git push -u origin HEAD",
            "git push origin master",
            "git push origin feat:main",
            "git push --force origin +HEAD:refs/heads/master",
            "git log -1 && git push 2>&1 | tail -1",
            f"git -C {self.repo} push",
        ]:
            self.assertEqual(self._decision(command), "ask", command)

    def test_follows_a_cd_into_another_repo(self):
        command = f"cd {self.repo} && git push"
        self.assertEqual(self._decision(command, cwd=self.root), "ask")

    def test_allows_a_push_of_a_feature_branch(self):
        git(self.repo, "checkout", "-q", "-b", "feat/x")
        for command in [
            "git push",
            "git push -u origin feat/x",
            "git push origin HEAD",
            "git status && git push",
        ]:
            self.assertEqual(self._decision(command), "allow", command)

    def test_asks_for_main_named_from_a_feature_branch(self):
        git(self.repo, "checkout", "-q", "-b", "feat/x")
        self.assertEqual(self._decision("git push origin main"), "ask")

    def test_ignores_other_commands(self):
        for command in ["git status", "git pull", "ls push", "git commit -m push"]:
            self.assertEqual(self._decision(command), "allow", command)


if __name__ == "__main__":
    unittest.main()
