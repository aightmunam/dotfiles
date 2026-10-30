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
  # Capture first: under pipefail, grep -q closing the pipe early would fail the pipeline.
  local s; s=$(cd "$ROOT" && just --summary 2>/dev/null) || return 1
  grep -qxF -- "$1" <<<"${s// /$'\n'}"
}

JUST_CI_RE='(^|[;&|[:space:]])just[[:space:]]+(check|ci)([^[:alnum:]_]|$)'
JUST_LINT_RE='(^|[;&|[:space:]])just[[:space:]]+lint([^[:alnum:]_]|$)'
JUST_TEST_RE='(^|[;&|[:space:]])just[[:space:]]+test([^[:alnum:]_]|$)'
# Bare test runners that stamp `test`.
RUNNER_RE='(^|[;&|[:space:]])(pytest|python[0-9.]*[[:space:]]+-m[[:space:]]+(pytest|unittest)|uv[[:space:]]+run[[:space:]]+pytest|tox|(npm|yarn|pnpm|bun)[[:space:]]+(run[[:space:]]+)?test|go[[:space:]]+test|cargo[[:space:]]+test)([^[:alnum:]_]|$)'

# 0 when the exit code of the test runner in $CMD is hidden: between the runner
# and the next `&&` there is a `|` (without pipefail), a `;`, or a `||`.
# $1 is the regex (with a trailing boundary group) that finds the runner.
hidden_exit() {
  [[ "$CMD" =~ $1 ]] || return 1
  # The last char of the match is the word boundary; keep it, it may be `;` or `|`.
  local m="${BASH_REMATCH[0]}" b="${BASH_REMATCH[${#BASH_REMATCH[@]}-1]}"
  local rest="$b${CMD#*"$m"}"
  rest="${rest%%&&*}"
  # Quoted strings may hold | or ; (pytest -k "a|b"); drop them first.
  rest=$(sed -E "s/\"[^\"]*\"//g; s/'[^']*'//g" <<<"$rest")
  [[ "$rest" == *"||"* || "$rest" == *";"* ]] && return 0
  if [[ "$rest" == *"|"* ]] && ! grep -q 'pipefail' <<<"$CMD"; then return 0; fi
  return 1
}

# 0 when the captured output shows a failing run, whatever the exit code was.
output_failed() {
  # Capture first: under pipefail, grep -q closing the pipe early would fail the pipeline.
  local out; out=$(jq -r '.tool_response.stdout // empty, .tool_response.stderr // empty' <<<"$INPUT")
  grep -qE '(^|[^[:alnum:]_])[1-9][0-9]* (failed|errors?)([^[:alnum:]_]|$)|^FAILED \(|test result: FAILED|^--- FAIL' <<<"$out"
}

stamp() { mkdir -p "$STATE" && fingerprint >"$STATE/$KEY-$1"; }

case "$EVENT" in
PostToolUse)
  # Only successful runs reach PostToolUse; skip interrupted ones defensively.
  [ "$(jq -r '.tool_response.interrupted // false' <<<"$INPUT")" = "true" ] && exit 0
  output_failed && exit 0
  if hidden_exit "$JUST_CI_RE"; then :; elif [[ "$CMD" =~ $JUST_CI_RE ]]; then
    stamp lint; stamp test
  fi
  if ! hidden_exit "$JUST_LINT_RE" && [[ "$CMD" =~ $JUST_LINT_RE ]]; then stamp lint; fi
  if ! hidden_exit "$JUST_TEST_RE" && [[ "$CMD" =~ $JUST_TEST_RE ]]; then stamp test; fi
  if ! hidden_exit "$RUNNER_RE" && [[ "$CMD" =~ $RUNNER_RE ]]; then stamp test; fi
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
