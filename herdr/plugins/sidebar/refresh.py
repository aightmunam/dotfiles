import json
import os
import subprocess
from collections import Counter

HERDR = os.environ.get("HERDR_BIN_PATH", "herdr")
SOURCE = "sidebar"

# Herdr Agent Icons Max codepoints, in herdr-bar's order (U+E1A0 + index)
VENDORS = [
    "claude", "codex", "opencode", "omp", "cline", "mastracode", "kimi", "kilo", "maki", "pi",
    "hermes", "cursor", "copilot", "deepseek", "gemini", "gpt", "qwen", "grok", "agy", "kiro",
    "amp", "devin", "qodercli", "glm",
]
ALIASES = {"github_copilot": "copilot", "open_code": "opencode"}


def herdr(*args: str) -> dict:
    out = subprocess.run([HERDR, *args], capture_output=True, text=True, check=True).stdout
    return json.loads(out)["result"]


def report(kind: str, target: str, token: str, value: str) -> None:
    subprocess.run(
        [HERDR, kind, "report-metadata", target, "--source", SOURCE, "--token", f"{token}={value}"],
        capture_output=True,
        check=False,
    )


def logo(agent: str) -> str:
    name = ALIASES.get(agent, agent)
    return chr(0xE1A0 + VENDORS.index(name)) if name in VENDORS else ""


# Most urgent first; idle agents are left out of the summary
STATUS_LABELS = {"blocked": "need you", "working": "working", "done": "done"}


def summary(statuses: Counter[str]) -> str:
    parts = [f"{statuses[s]} {label}" for s, label in STATUS_LABELS.items() if statuses[s]]
    return " · ".join(parts) or "all idle"


def main() -> None:
    workspaces = herdr("workspace", "list")["workspaces"]
    agents = herdr("agent", "list")["agents"]
    labels = {w["workspace_id"]: w["label"] for w in workspaces}
    statuses_per_space: dict[str, Counter[str]] = {w["workspace_id"]: Counter() for w in workspaces}

    for agent in agents:
        statuses_per_space.setdefault(agent["workspace_id"], Counter())[agent["agent_status"]] += 1
        # One token, so herdr doesn't put its " · " separator between logo and name
        head = " ".join(filter(None, [logo(agent["agent"]), labels.get(agent["workspace_id"], "")]))
        report("pane", agent["pane_id"], "head", head)
    for space in workspaces:
        report("workspace", space["workspace_id"], "summary", summary(statuses_per_space[space["workspace_id"]]))


main()
