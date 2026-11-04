"""Tests for ai/claude/hooks/sf-prod-guard.sh (stdlib unittest only)."""
import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path

HOOK = str(Path(__file__).resolve().parent.parent / "claude" / "hooks" / "sf-prod-guard.sh")
OVERLAY = "# Work overlay\n\n- Prod Salesforce orgs: `acme-prod`, `acme-legacy`\n"


class SfProdGuardTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.home = Path(tmp.name)

    def _overlay(self, text=OVERLAY):
        local = self.home / ".agents" / "local"
        local.mkdir(parents=True)
        (local / "work.md").write_text(text)

    def _exit(self, command):
        payload = {"hook_event_name": "PreToolUse", "tool_name": "Bash",
                   "tool_input": {"command": command}}
        return subprocess.run(
            ["bash", HOOK], input=json.dumps(payload), capture_output=True, text=True,
            env={**os.environ, "HOME": str(self.home)},
        ).returncode

    def test_blocks_sf_commands_that_name_a_prod_org(self):
        self._overlay()
        for command in [
            "sf data query -q 'SELECT Id FROM Case' -o acme-prod",
            "sf org display --target-org acme-legacy --help",
            "cd x && sfdx force:data:soql:query -u acme-prod -q 'x'",
            "SF_TARGET_ORG=acme-prod sf data query -q 'x'",
            "sf data query -q 'x' --target-org=acme-prod",
        ]:
            self.assertEqual(self._exit(command), 2, command)

    def test_allows_other_orgs_and_other_tools(self):
        self._overlay()
        for command in [
            "sf data query -q 'x' -o acme-uat",
            "sf org list",
            "grep acme-prod notes.md",
            "sf data query -q 'x' -o acme-prod-sandbox",
        ]:
            self.assertEqual(self._exit(command), 0, command)

    def test_allows_everything_without_an_overlay(self):
        self.assertEqual(self._exit("sf data query -q 'x' -o acme-prod"), 0)


if __name__ == "__main__":
    unittest.main()
