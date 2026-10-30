"""Tests for ai/bin/routing-eval and prompts.tsv. They bill no run."""

import importlib.machinery
import importlib.util
import json
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "ai" / "bin" / "routing-eval"
FIXTURES = ROOT / "ai" / "tests" / "fixtures"
AGENTS = ROOT / "ai" / "AGENTS.md"
KEPT_DISTRACTORS = {"explain_code", "commit", "be-ambitious", "asd-ste100", "design-system", "find-skills"}


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
        self.assertEqual(len(planned), 26)
        plain = {r["expected"] for r in self.rows if not r["pair"] and r["id"].startswith("skill-")}
        self.assertEqual(planned - plain, set())

    def test_tsv_covers_each_pair_side(self):
        sets = tie_break_sets()
        self.assertEqual(len(sets), 16)
        for name, sides in sets.items():
            for side in sides:
                hits = [r for r in self.rows if r["pair"] == name and r["expected"] == side]
                self.assertTrue(hits, f"no row for side {side} of {name}")
        known = set(sets)
        for r in self.rows:
            if r["pair"]:
                self.assertIn(r["pair"], known, r["id"])

    def test_tsv_has_six_distractors(self):
        dist = [r for r in self.rows if r["id"].startswith("distract-")]
        self.assertEqual({r["expected"] for r in dist}, KEPT_DISTRACTORS)
        self.assertEqual(len(dist), 6)
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
        for tool, base in (("claude", ".claude"), ("codex", ".agents")):
            scratch = self.re.prepare_scratch(tool, live=False)
            try:
                linked = {p.name for p in (scratch / base / "skills").iterdir()}
                self.assertEqual(linked, names)
                self.assertTrue((scratch / "AGENTS.md").is_file())
            finally:
                import shutil
                shutil.rmtree(scratch, ignore_errors=True)
        live = self.re.prepare_scratch("claude", live=True)
        try:
            self.assertEqual(list(live.iterdir()), [])
        finally:
            live.rmdir()


if __name__ == "__main__":
    unittest.main()
