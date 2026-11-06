#!/usr/bin/env python3
"""UserPromptSubmit hook: tell the lead (and the user) the real context size.

Reads the token count of the last main-session API call from the transcript.
At 100k+ it tells the lead; at 150k+ it also tells the user. It fires once per
25k band, and a compaction resets the count. Any error exits 0 with no output.
"""
import json
import os
import sys
import tempfile
from pathlib import Path

LEAD_AT, USER_AT, BAND = 100_000, 150_000, 25_000
TAIL_BYTES = 4 * 1024 * 1024


def context_tokens(path):
    with open(path, "rb") as f:
        f.seek(0, os.SEEK_END)
        f.seek(max(0, f.tell() - TAIL_BYTES))
        lines = f.read().decode("utf-8", "ignore").splitlines()
    for line in reversed(lines):
        try:
            d = json.loads(line)
        except ValueError:
            continue
        if d.get("type") == "system" and d.get("subtype") == "compact_boundary":
            return 0
        msg = d.get("message") or {}
        u = msg.get("usage") if isinstance(msg, dict) else None
        if not u or d.get("isSidechain") or msg.get("model") == "<synthetic>":
            continue
        return (u.get("input_tokens", 0) + u.get("cache_creation_input_tokens", 0)
                + u.get("cache_read_input_tokens", 0))
    return 0


def main():
    data = json.load(sys.stdin)
    tokens = context_tokens(data["transcript_path"])
    state = Path(tempfile.gettempdir()) / "claude-context-reminder" / str(data.get("session_id", "x"))
    band = tokens // BAND
    last = int(state.read_text()) if state.exists() else -1
    if tokens < LEAD_AT or band <= last:
        if band < last:
            state.write_text(str(band))
        return
    state.parent.mkdir(parents=True, exist_ok=True)
    state.write_text(str(band))
    k = f"{tokens // 1000}k"
    out = {"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": (
        f"Context is {k} tokens. The smart zone is about 150k. Do not act on this in the "
        "middle of a phase. At the next phase boundary, use this count for the list in "
        "AGENTS.md 'Context and sessions'. Continue is a valid answer.")}}
    if tokens >= USER_AT:
        out["systemMessage"] = (f"Context is {k} tokens, past the ~150k smart zone. At the "
                                "next phase boundary, the agent will suggest continue, /clear, "
                                "handoff, subagent or /compact.")
    print(json.dumps(out))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
