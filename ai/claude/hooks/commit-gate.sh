#!/usr/bin/env bash
# commit-gate: block `git commit` unless lint and tests passed on the exact
# working tree being committed. Replaces verify-before-commit, verify-before-done,
# test-before-commit and guard-test-required (all warn-only or broken).
#
# One script, two events (register it on both, matcher "Bash"):
#   PostToolUse: a successful lint/test command stamps a marker with a
#                fingerprint of the working tree (a git tree hash).
#   PreToolUse:  `git commit` is blocked (exit 2) unless the required markers
#                exist and still match the current fingerprint.
# A fingerprint (not an mtime or an Edit hook) means edits made by any route,
# Edit/Write or sed, invalidate the evidence, and staging alone does not.
#
# Required checks: `just lint` / `just test` when the justfile has those recipes
# (`just check` / `just ci` count as both); otherwise any test runner below.
# Repos with neither a justfile nor a recognisable test setup are not gated.
set -uo pipefail

INPUT=$(cat)
EVENT=$(jq -r '.hook_event_name // empty' <<<"$INPUT")
CMD=$(jq -r '.tool_input.command // empty' <<<"$INPUT")
[ -z "$CMD" ] && exit 0

STATE="$HOME/.claude/state/commit-gate"

# Resolve the directory the command runs in: hook cwd, or a leading `cd X &&`.
DIR=$(jq -r '.cwd // empty' <<<"$INPUT"); [ -z "$DIR" ] && DIR=$PWD
if [[ "$CMD" =~ ^[[:space:]]*cd[[:space:]]+([^[:space:];&|]+)[[:space:]]*\&\& ]]; then
  target="${BASH_REMATCH[1]/#\~/$HOME}"
  [[ "$target" = /* ]] || target="$DIR/$target"
  DIR="$target"
fi
ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null) || exit 0
KEY=$(printf '%s' "$ROOT" | shasum | cut -c1-12)

# Tree hash of the whole working tree (tracked + untracked, .gitignore honoured),
# built in a throwaway index so the real index is untouched. Independent of HEAD,
# so one tested tree can be split into several commits.
fingerprint() {
  local idx; idx=$(mktemp) || return
  cp "$(git -C "$ROOT" rev-parse --absolute-git-dir)/index" "$idx" 2>/dev/null
  GIT_INDEX_FILE="$idx" git -C "$ROOT" add -A >/dev/null 2>&1
  GIT_INDEX_FILE="$idx" git -C "$ROOT" write-tree 2>/dev/null
  rm -f "$idx"
}

has_recipe() {
  [ -f "$ROOT/justfile" ] || [ -f "$ROOT/Justfile" ] || return 1
  (cd "$ROOT" && just --summary 2>/dev/null) | tr ' ' '\n' | grep -qx "$1"
}

stamp() { mkdir -p "$STATE" && fingerprint >"$STATE/$KEY-$1"; }

case "$EVENT" in
PostToolUse)
  # Only successful runs reach PostToolUse; skip interrupted ones defensively.
  [ "$(jq -r '.tool_response.interrupted // false' <<<"$INPUT")" = "true" ] && exit 0
  if grep -qE '(^|[;&|[:space:]])just[[:space:]]+(check|ci)\b' <<<"$CMD"; then
    stamp lint; stamp test
  fi
  grep -qE '(^|[;&|[:space:]])just[[:space:]]+lint\b' <<<"$CMD" && stamp lint
  grep -qE '(^|[;&|[:space:]])(just[[:space:]]+test|pytest|python[0-9.]*[[:space:]]+-m[[:space:]]+(pytest|unittest)|uv[[:space:]]+run[[:space:]]+pytest|tox|(npm|yarn|pnpm|bun)[[:space:]]+(run[[:space:]]+)?test|go[[:space:]]+test|cargo[[:space:]]+test)\b' <<<"$CMD" && stamp test
  exit 0
  ;;
PreToolUse)
  grep -qE '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit\b' <<<"$CMD" || exit 0
  # Fixups that change no code (message rewording) need no fresh evidence.
  grep -qE 'commit[[:space:]].*--amend[[:space:]].*--only|--allow-empty' <<<"$CMD" && exit 0

  need=()
  if [ -f "$ROOT/justfile" ] || [ -f "$ROOT/Justfile" ]; then
    has_recipe lint && need+=(lint)
    has_recipe test && need+=(test)
  elif [ -f "$ROOT/pyproject.toml" ] || [ -f "$ROOT/pytest.ini" ] || [ -f "$ROOT/go.mod" ] \
       || [ -f "$ROOT/Cargo.toml" ] || { [ -f "$ROOT/package.json" ] && grep -q '"test"' "$ROOT/package.json"; }; then
    need+=(test)
  fi
  [ ${#need[@]} -eq 0 ] && exit 0

  now=$(fingerprint) missing=()
  for n in "${need[@]}"; do
    [ "$(cat "$STATE/$KEY-$n" 2>/dev/null)" = "$now" ] || missing+=("$n")
  done
  [ ${#missing[@]} -eq 0 ] && exit 0

  {
    echo "BLOCKED by commit-gate: no passing ${missing[*]} for the current working tree of $ROOT."
    echo "Run them (e.g. 'just ${missing[0]}') and commit again; any edit after a run invalidates it."
    echo "If they cannot run here (missing services, known-red suite), stop and ask the user instead of retrying."
  } >&2
  exit 2
  ;;
esac
exit 0
