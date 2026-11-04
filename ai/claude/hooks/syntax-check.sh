#!/usr/bin/env bash
# syntax-check.sh: report a syntax error to Claude right after an edit.
#
# TRIGGER: PostToolUse, MATCHER: Edit|Write.
# Checks .py, .sh/.bash, .json, .yaml/.yml and .js/.mjs/.cjs files.
# On an error it prints the checker message to stderr and exits 2, so Claude
# sees it in the tool result. A valid or unknown file exits 0 with no output.
# Skips JSON with comments (tsconfig*.json, .vscode/). YAML accepts custom
# tags (!Ref) and several documents. The Python check writes no bytecode.
# Replaces the upstream yurukusa syntax-check, which always exited 0 and sent
# the checker message to stdout, so Claude never saw an error.
INPUT=$(cat)
export INPUT
exec python3 - <<'PY'
import json, os, shutil, subprocess, sys

try:
    data = json.loads(os.environ.get("INPUT") or "{}")
except ValueError:
    raise SystemExit(0)
path = (data.get("tool_input") or {}).get("file_path") or ""
if not path or not os.path.isfile(path):
    raise SystemExit(0)
name = os.path.basename(path)
ext = name.rsplit(".", 1)[-1].lower() if "." in name else ""


def fail(kind, message):
    print(f"SYNTAX ERROR ({kind}) in {path}:\n{message.strip()}", file=sys.stderr)
    raise SystemExit(2)


def run(kind, cmd):
    out = subprocess.run(cmd, capture_output=True, text=True)
    if out.returncode != 0:
        fail(kind, out.stderr or out.stdout)


def read():
    with open(path, encoding="utf-8", errors="replace") as f:
        return f.read()


if ext == "py":
    try:
        compile(read(), path, "exec", dont_inherit=True)
    except SyntaxError as e:
        fail("Python", f"line {e.lineno}: {e.msg}")
elif ext in ("sh", "bash"):
    run("Shell", ["bash", "-n", path])
elif ext == "json":
    if name.startswith("tsconfig") or "/.vscode/" in path:
        raise SystemExit(0)
    try:
        json.loads(read())
    except ValueError as e:
        fail("JSON", str(e))
elif ext in ("yaml", "yml"):
    try:
        import yaml
    except ImportError:
        raise SystemExit(0)

    class Loader(yaml.SafeLoader):
        pass

    Loader.add_multi_constructor("", lambda loader, suffix, node: None)
    try:
        for _ in yaml.load_all(read(), Loader=Loader):
            pass
    except yaml.YAMLError as e:
        fail("YAML", str(e))
elif ext in ("js", "mjs", "cjs") and shutil.which("node"):
    run("JavaScript", ["node", "--check", path])
PY
