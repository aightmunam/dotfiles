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


def count(n: int, noun: str) -> str:
    return f"{n} {noun}" if n == 1 else f"{n} {noun}s"


def main() -> None:
    workspaces = herdr("workspace", "list")["workspaces"]
    agents = herdr("agent", "list")["agents"]
    labels = {w["workspace_id"]: w["label"] for w in workspaces}
    agents_per_space = Counter(a["workspace_id"] for a in agents)

    for agent in agents:
        # One token, so herdr doesn't put its " · " separator between logo and name
        head = " ".join(filter(None, [logo(agent["agent"]), labels.get(agent["workspace_id"], "")]))
        report("pane", agent["pane_id"], "head", head)

    for space in workspaces:
        summary = f"{count(space['tab_count'], 'tab')} · {count(agents_per_space[space['workspace_id']], 'agent')}"
        report("workspace", space["workspace_id"], "summary", summary)


main()
