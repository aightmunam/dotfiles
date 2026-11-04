#!/usr/bin/env bash
# branch-guard.sh: ask before a git push to a protected branch.
#
# TRIGGER: PreToolUse, MATCHER: Bash.
# Finds each `git push` in a compound command, also after `cd <dir> &&` and
# with `git -C <dir>`. The push targets a protected branch when a refspec names
# one, or when no refspec is given and the current branch is protected.
# Then it returns permissionDecision "ask", so the user confirms the push.
# Protected branches: CC_PROTECT_BRANCHES (colon list), default main:master.
# Replaces the upstream yurukusa branch-guard, which only checked commands
# that start with `git push` and never looked at the current branch.
INPUT=$(cat)
export INPUT
exec python3 - <<'PY'
import json, os, re, shlex, subprocess

try:
    data = json.loads(os.environ.get("INPUT") or "{}")
except ValueError:
    raise SystemExit(0)
command = (data.get("tool_input") or {}).get("command") or ""
if "push" not in command:
    raise SystemExit(0)
protected = set(filter(None, os.environ.get("CC_PROTECT_BRANCHES", "main:master").split(":")))
cwd = data.get("cwd") or os.getcwd()


def resolve(base, path):
    return os.path.normpath(os.path.join(base, os.path.expanduser(path)))


def current_branch(path):
    out = subprocess.run(["git", "-C", path, "rev-parse", "--abbrev-ref", "HEAD"],
                         capture_output=True, text=True)
    return out.stdout.strip() if out.returncode == 0 else ""


def words(segment):
    try:
        toks = shlex.split(segment)
    except ValueError:
        toks = segment.split()
    while toks and re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", toks[0]):
        toks.pop(0)
    return [t for t in toks if not re.search(r"[<>]", t)]


def push_target(path, args):
    rest, skip = [], False
    for a in args:
        if skip:
            skip = False
            continue
        if a in ("--all", "--mirror"):
            return "all branches"
        if a in ("-o", "--push-option", "--repo", "--receive-pack", "--exec"):
            skip = True
            continue
        if not a.startswith("-"):
            rest.append(a)
    head = current_branch(path)
    refspecs = rest[1:]
    if not refspecs:
        return head if head in protected else None
    for spec in refspecs:
        dst = spec.lstrip("+").split(":")[-1] or head
        if dst == "HEAD":
            dst = head
        dst = dst.removeprefix("refs/heads/")
        if dst in protected:
            return dst
    return None


here = cwd
for segment in re.split(r"&&|\|\||[;|\n]", command):
    toks = words(segment)
    if not toks:
        continue
    if toks[0] == "cd" and len(toks) > 1:
        here = resolve(here, toks[1])
        continue
    if toks[0] != "git":
        continue
    path, i = here, 1
    while i < len(toks) and toks[i].startswith("-"):
        if toks[i] == "-C" and i + 1 < len(toks):
            path = resolve(path, toks[i + 1])
            i += 2
        elif toks[i] == "-c":
            i += 2
        else:
            i += 1
    if i < len(toks) and toks[i] == "push":
        target = push_target(path, toks[i + 1:])
        if target:
            reason = f"git push to protected branch {target} in {path}. Confirm this push."
            print(json.dumps({"hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "ask",
                "permissionDecisionReason": reason}}))
            break
PY
