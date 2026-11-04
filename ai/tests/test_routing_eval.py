"""Tests for ai/bin/routing-eval and prompts.tsv. They bill no run."""

import importlib.machinery
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import textwrap
import time
import unittest
from unittest import mock
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "ai" / "bin" / "routing-eval"
FIXTURES = ROOT / "ai" / "tests" / "fixtures"
AGENTS = ROOT / "ai" / "AGENTS.md"
KEPT_DISTRACTORS = {"commit", "design-system"}


def load_module():
    loader = importlib.machinery.SourceFileLoader("routing_eval", str(SCRIPT))
    spec = importlib.util.spec_from_loader("routing_eval", loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


def fixture(name):
    return [json.loads(line) for line in (FIXTURES / name).read_text().splitlines() if line]


def planned_skills():
    text = (ROOT / "ai" / "tests" / "test_skills_lint.py").read_text()
    block = re.search(r"PLANNED = \{(.*?)\}", text, re.S).group(1)
    return set(re.findall(r'"([\w-]+)"', block))


def tie_break_sets():
    """Return {set name: [expected skill per side]} from the router's tie-break lines."""
    text = AGENTS.read_text()
    section = text.split("Tie-break lines", 1)[1].split("Not these", 1)[0]
    sets = {}
    for line in section.splitlines():
        match = re.match(r"- ([^:]+): ", line)
        if not match:
            continue
        keys = []
        for part in match.group(1).split("/"):
            key = re.sub(r"^the-", "", part.strip().lower().replace(" ", "-"))
            keys.append(key)
        sides = ["none" if key == "writing-standard" else key for key in keys]
        sets["/".join(keys)] = sides
    return sets


class RoutingEvalTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.re = load_module()
        cls.rows = cls.re.load_rows()

    def test_rerun_of_one_id_keeps_the_other_rows(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp)
            first = [{"id": "a", "expected": "x", "got": "error", "pass": False, "note": "capacity"},
                     {"id": "b", "expected": "y", "got": "y", "pass": True}]
            self.re.write_results(out, "codex", first, "2026-10-30")
            self.re.write_results(out, "codex", [{"id": "a", "expected": "x", "got": "x", "pass": True}], "2026-10-30",
                                  merge=True)
            lines = (out / "2026-10-30-codex.tsv").read_text().splitlines()
            self.assertEqual(lines, ["id\texpected\tgot\tpass\tnote", "a\tx\tx\tyes\t", "b\ty\ty\tyes\t"])

    def test_full_run_replaces_the_file(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp)
            self.re.write_results(out, "codex", [{"id": "stale", "expected": "x", "got": "x", "pass": True}], "2026-10-30")
            self.re.write_results(out, "codex", [{"id": "a", "expected": "x", "got": "y", "pass": False}], "2026-10-30")
            lines = (out / "2026-10-30-codex.tsv").read_text().splitlines()
            self.assertEqual(lines, ["id\texpected\tgot\tpass\tnote", "a\tx\ty\tno\t"])

    def test_merge_fills_missing_columns(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp)
            (out / "2026-10-30-claude.tsv").write_text("id\texpected\tgot\tpass\nold\tx\tx\tyes\n")
            self.re.write_results(out, "claude", [{"id": "a", "expected": "x", "got": "x", "pass": True}], "2026-10-30",
                                  merge=True)
            lines = (out / "2026-10-30-claude.tsv").read_text().splitlines()
            self.assertEqual(lines, ["id\texpected\tgot\tpass\tnote", "old\tx\tx\tyes\t", "a\tx\tx\tyes\t"])

    def test_main_merges_only_for_a_filtered_run(self):
        seen = []
        result = {"id": "a", "expected": "x", "pair": "", "got": "x", "pass": True, "note": ""}
        with tempfile.TemporaryDirectory() as tmp, \
                mock.patch.object(self.re, "run_row", return_value=([], "", "")), \
                mock.patch.object(self.re, "got_skill", return_value="tdd"), \
                mock.patch.object(self.re, "write_results", lambda *a, **k: seen.append(a[-1] if len(a) > 4 else k.get("merge"))), \
                mock.patch("sys.stdout"):
            self.re.main(["--tool", "claude", "--id", self.rows[0]["id"], "--out", tmp])
            self.re.main(["--tool", "claude", "--skill", "tdd", "--out", tmp])
            self.re.main(["--tool", "claude", "--out", tmp, "--jobs", "8"])
        self.assertEqual(seen, [True, True, False])

    def test_tsv_shape(self):
        self.assertTrue(self.rows)
        ids = [r["id"] for r in self.rows]
        self.assertEqual(len(ids), len(set(ids)))
        prompts = [r["prompt"] for r in self.rows]
        self.assertEqual(len(prompts), len(set(prompts)))
        for r in self.rows:
            self.assertTrue(r["prompt"].strip(), r["id"])
            self.assertNotIn("\u2014", r["prompt"])

    def test_tsv_covers_every_planned_skill(self):
        planned = planned_skills()
        self.assertEqual(len(planned), 28)
        plain = {r["expected"] for r in self.rows if not r["pair"] and r["id"].startswith("skill-")}
        self.assertEqual(planned - plain, set())

    def test_tsv_covers_each_pair_side(self):
        sets = tie_break_sets()
        self.assertEqual(len(sets), 20)
        for name, sides in sets.items():
            for side in sides:
                hits = [r for r in self.rows if r["pair"] == name and r["expected"] == side]
                self.assertTrue(hits, f"no row for side {side} of {name}")
        known = set(sets)
        for r in self.rows:
            if r["pair"]:
                self.assertIn(r["pair"], known, r["id"])

    def test_tsv_has_one_distractor_per_kept_skill(self):
        dist = [r for r in self.rows if r["id"].startswith("distract-")]
        self.assertEqual({r["expected"] for r in dist}, KEPT_DISTRACTORS)
        self.assertEqual(len(dist), len(KEPT_DISTRACTORS))
        nones = [r for r in self.rows if r["id"].startswith("none-")]
        self.assertEqual(len(nones), 2)
        for r in nones:
            self.assertEqual(r["expected"], "none")
        for r in dist + nones:
            self.assertEqual(r["pair"], "")

    def test_required_prompts_present(self):
        prompts = {r["prompt"]: r for r in self.rows}
        for text, expected in [
            ("Backfill a column on prod for 3k rows.", "data-op"),
            ("Delete duplicate plan rows in orders-service prod.", "data-op"),
            ("Deploy my branch to staging and check it works.", "staging"),
            ("Prove my change works before I open the PR.", "prove"),
            ("Backfill eta_date on the staging DB.", "data-op"),
        ]:
            self.assertEqual(prompts[text]["expected"], expected, text)

    def test_detection_claude_fixture(self):
        events = fixture("claude_skill_tool.jsonl")
        use_id = next(u["id"] for u in self.re.PR._claude_tool_uses(events) if u["name"] == "Skill")
        events = events + [{"type": "user", "message": {"content": [
            {"type": "tool_result", "tool_use_id": use_id, "content": "ok"}]}}]
        self.assertEqual(self.re.got_skill(events, "claude", "pressure-probe"), "pressure-probe")
        self.assertEqual(self.re.got_skill(events, "claude", "tdd"), "pressure-probe")
        self.assertEqual(self.re.got_skill(fixture("claude_result.jsonl"), "claude", "tdd"), "none")
        self.assertTrue(self.re.turn_ended(fixture("claude_result.jsonl")[-1], "claude"))

    def test_detection_codex_fixture(self):
        events = fixture("codex_command.jsonl")
        self.assertEqual(self.re.got_skill(events, "codex", "pressure-probe"), "pressure-probe")
        self.assertEqual(self.re.got_skill(events, "codex", "tdd"), "pressure-probe")
        self.assertEqual(self.re.got_skill(fixture("codex_message.jsonl"), "codex", "tdd"), "none")
        self.assertTrue(self.re.turn_ended({"type": "turn.completed"}, "codex"))

    def result(self, id, expected, got, pair=""):
        return {"id": id, "expected": expected, "got": got, "pair": pair, "pass": expected == got}

    def test_threshold_pair_miss_fails(self):
        results = [self.result("a", "tdd", "tdd"), self.result("b", "debug", "prove", "debug/prove")]
        ok, reasons = self.re.threshold(results)
        self.assertFalse(ok)
        self.assertIn("pair row missed: b", reasons[0])

    def test_threshold_two_misses_fail(self):
        results = [self.result("a", "tdd", "none"), self.result("b", "build", "none")]
        self.assertFalse(self.re.threshold(results)[0])
        self.assertTrue(self.re.threshold(results[:1])[0])
        self.assertTrue(self.re.threshold([self.result("a", "tdd", "tdd")])[0])

    def run_script(self, *args):
        return subprocess.run([sys.executable, str(SCRIPT), *args], capture_output=True, text=True)

    def test_dry_run_single_id(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / "out"
            run = self.run_script("--id", "skill-tdd", "--dry-run", "--out", str(out))
            self.assertEqual(run.returncode, 0, run.stderr)
            lines = run.stdout.strip().splitlines()
            self.assertEqual(len(lines), 2)
            self.assertTrue(all(line.startswith("skill-tdd ") for line in lines))
            self.assertIn("claude -p", lines[0])
            self.assertIn("--permission-mode plan", lines[0])
            self.assertIn("--max-budget-usd 0.3", lines[0])
            self.assertIn("--setting-sources project", lines[0])
            self.assertIn("codex exec --json", lines[1])
            self.assertIn("-s read-only", lines[1])
            self.assertFalse(out.exists(), "dry run must not write")

    def test_dry_run_live_and_budget(self):
        run = self.run_script("--id", "skill-tdd", "--tool", "claude", "--dry-run", "--live", "--budget", "0.1")
        self.assertEqual(run.returncode, 0, run.stderr)
        self.assertIn("--setting-sources user,project", run.stdout)
        self.assertIn("--max-budget-usd 0.1", run.stdout)

    def test_unknown_filter_is_setup_error(self):
        self.assertEqual(self.run_script("--id", "nope", "--dry-run").returncode, 2)

    def test_scratch_exposes_every_skill(self):
        names = {p.name for p in (ROOT / "ai" / "skills").iterdir() if p.is_dir()}
        with tempfile.TemporaryDirectory() as tmp:
            for tool, base in (("claude", ".claude"), ("codex", ".agents")):
                scratch = self.re.prepare_scratch(tool, live=False, user_dir=tmp)
                try:
                    linked = {p.name for p in (scratch / base / "skills").iterdir()}
                    self.assertEqual(linked, names)
                    self.assertTrue((scratch / "AGENTS.md").is_file())
                finally:
                    shutil.rmtree(scratch, ignore_errors=True)
        with tempfile.TemporaryDirectory() as root:
            live = self.re.prepare_scratch("claude", live=True, live_root=root)
            self.assertEqual(live.parent, Path(root))
            self.assertEqual(list(live.iterdir()), [])

    def test_live_scratch_sits_in_a_trusted_folder(self):
        """Claude skips the user CLAUDE.md @AGENTS.md import in an untrusted folder,
        so a live run in the system temp dir never sees the router."""
        live = self.re.prepare_scratch("claude", live=True)
        try:
            self.assertEqual(live.parent, self.re.LIVE_ROOT)
            self.assertFalse(str(live).startswith(tempfile.gettempdir()))
        finally:
            live.rmdir()

    def test_third_party_skills_filter(self):
        with tempfile.TemporaryDirectory() as tmp:
            user = Path(tmp)
            for name in ("plain", "debug", ".trash", "nodoc"):
                (user / name).mkdir()
            for name in ("plain", "debug", ".trash"):
                (user / name / "SKILL.md").write_text("x")
            (user / "synced").mkdir()
            got = [e.name for e in self.re.third_party_skills(user, exclude={"debug"})]
            self.assertEqual(got, ["plain"])
            self.assertEqual(self.re.third_party_skills(user / "missing"), [])
            scratch = self.re.prepare_scratch("claude", live=False, user_dir=user)
            try:
                self.assertTrue((scratch / ".claude" / "skills" / "plain").exists())
                self.assertFalse((scratch / ".claude" / "skills" / ".trash").exists())
            finally:
                shutil.rmtree(scratch, ignore_errors=True)

    def test_two_skills_in_one_event_is_a_miss(self):
        cmd = {"type": "item.completed", "item": {
            "type": "command_execution", "exit_code": 0,
            "command": "/bin/zsh -lc 'sed -n 1,80p .agents/skills/debug/SKILL.md .agents/skills/prove/SKILL.md'"}}
        self.assertEqual(self.re.got_skill([cmd], "codex", "debug"), "debug+prove")
        claude = {"type": "assistant", "message": {"content": [
            {"type": "tool_use", "id": "a", "name": "Skill", "input": {"skill": "pr"}},
            {"type": "tool_use", "id": "b", "name": "Skill", "input": {"skill": "unslop"}}]}}
        done = {"type": "user", "message": {"content": [
            {"type": "tool_result", "tool_use_id": "a", "content": "ok"},
            {"type": "tool_result", "tool_use_id": "b", "content": "ok"}]}}
        self.assertEqual(self.re.got_skill([claude, done], "claude", "pr"), "pr+unslop")

    def test_claude_load_needs_a_good_tool_result(self):
        use = {"type": "assistant", "message": {"content": [
            {"type": "tool_use", "id": "a", "name": "Skill", "input": {"skill": "data-op"}}]}}
        err = {"type": "user", "message": {"content": [
            {"type": "tool_result", "tool_use_id": "a", "is_error": True, "content": "Unknown skill"}]}}
        ok = {"type": "user", "message": {"content": [
            {"type": "tool_result", "tool_use_id": "a", "content": "loaded"}]}}
        self.assertEqual(self.re.got_skill([use], "claude"), "none")
        self.assertEqual(self.re.pending_tool_uses([use], "claude"), {"a"})
        self.assertEqual(self.re.got_skill([use, err], "claude"), "none")
        self.assertEqual(self.re.got_skill([use, ok], "claude"), "data-op")

    def test_codex_error_event_does_not_end_the_turn(self):
        self.assertFalse(self.re.turn_ended({"type": "error"}, "codex"))
        self.assertTrue(self.re.turn_ended({"type": "turn.failed"}, "codex"))

    def test_run_row_stops_and_kills_children(self):
        fake = textwrap.dedent("""\
            #!/usr/bin/env python3
            import json, subprocess, sys, time
            def emit(o):
                print(json.dumps(o)); sys.stdout.flush()
            child = subprocess.Popen(["sleep", "60"])
            open(sys.argv[0] + ".pid", "w").write(str(child.pid))
            emit({"type": "assistant", "message": {"content": [
                {"type": "tool_use", "id": "a", "name": "Skill", "input": {"skill": "tdd"}}]}})
            emit({"type": "user", "message": {"content": [
                {"type": "tool_result", "tool_use_id": "a", "content": "ok"}]}})
            time.sleep(60)
        """)
        with tempfile.TemporaryDirectory() as tmp:
            exe = Path(tmp) / "claude"
            exe.write_text(fake)
            exe.chmod(0o755)
            args = mock.Mock(live=True, budget=0.3)
            row = {"id": "x", "prompt": "p", "expected": "tdd", "pair": ""}
            with mock.patch.dict(os.environ, {"PATH": tmp + os.pathsep + os.environ["PATH"]}):
                start = time.time()
                events, raw, note = self.re.run_row("claude", row, args)
            self.assertLess(time.time() - start, 20)
            self.assertEqual(self.re.got_skill(events, "claude"), "tdd")
            self.assertEqual(note, "")
            pid = int((Path(tmp) / "claude.pid").read_text())
            time.sleep(0.5)
            with self.assertRaises(ProcessLookupError):
                os.kill(pid, 0)


if __name__ == "__main__":
    unittest.main()
