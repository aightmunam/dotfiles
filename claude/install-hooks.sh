#!/usr/bin/env bash
#
# Install the Claude Code hooks that are NOT versioned in this repo because they
# come from upstream sources. Custom, user-authored hooks live in claude/hooks/
# and ARE tracked. This script restores everything else into ~/.claude/hooks/,
# which settings.json (versioned) references by path:
#   - tool-managed hooks (rtk, herdr) that their own tools create/overwrite
#   - upstream safety hooks from yurukusa/claude-code-hooks (pinned)
#   - upstream safety hooks from yurukusa/cc-safe-setup      (pinned)
#
# Upstream hooks are plain shell scripts (they read hook JSON via jq/python3/node),
# so they are fetched as raw files rather than through the interactive installer,
# keeping this non-interactive and leaving our versioned settings.json authoritative.
#
# Idempotent. Run standalone or via `make install`. Bump the *_REF pins to update.
set -uo pipefail

dest="$HOME/.claude/hooks"
mkdir -p "$dest"

# --- tool-managed hooks -----------------------------------------------------
if command -v rtk >/dev/null 2>&1; then
  echo "-> rtk init -g --hook-only --no-patch"
  rtk init -g --hook-only --no-patch || echo "  rtk hook install failed"
else
  echo "  rtk not found on PATH — skipping rtk hook"
fi

if command -v herdr >/dev/null 2>&1; then
  echo "-> herdr integration install claude"
  herdr integration install claude || echo "  herdr integration install failed"
else
  echo "  herdr not found on PATH — run 'make build' first, then re-run this script"
fi

# --- helper: fetch a list of hook files from a raw base URL -----------------
fetch_hooks() {
  local label="$1" base="$2"; shift 2
  echo "-> $label ($# hooks)"
  if ! command -v curl >/dev/null 2>&1; then echo "  curl not found — skipping"; return 1; fi
  local h
  for h in "$@"; do
    if curl -fsSL "$base/$h" -o "$dest/$h.tmp" 2>/dev/null; then
      chmod +x "$dest/$h.tmp" && mv "$dest/$h.tmp" "$dest/$h"
    else
      echo "  failed: $h"; rm -f "$dest/$h.tmp" 2>/dev/null
    fi
  done
}

# --- yurukusa/claude-code-hooks (pinned) ------------------------------------
CCH_REF="4e62261f5036a0b166aba65c502258710d5f8322"
fetch_hooks "yurukusa/claude-code-hooks @ ${CCH_REF:0:7}" \
  "https://raw.githubusercontent.com/yurukusa/claude-code-hooks/${CCH_REF}/hooks" \
  activity-logger.sh auto-approve-readonly.sh branch-guard.sh cd-git-allow.sh \
  comment-strip.sh context-monitor.sh decision-warn.sh destructive-guard.sh \
  no-ask-human.sh proof-log-session.sh secret-guard.sh syntax-check.sh

# --- yurukusa/cc-safe-setup (pinned, examples/) -----------------------------
CCS_REF="07f676f8960cffca8e16767e1b1c90ef813905e9"
fetch_hooks "yurukusa/cc-safe-setup @ ${CCS_REF:0:7}" \
  "https://raw.githubusercontent.com/yurukusa/cc-safe-setup/${CCS_REF}/examples" \
  auto-approve-compound-git.sh auto-approve-docker.sh auto-approve-python.sh \
  auto-approve-test.sh auto-git-checkpoint.sh backup-before-refactor.sh \
  env-source-guard.sh loop-detector.sh max-session-duration.sh \
  memory-write-guard.sh no-sudo-guard.sh notify-waiting.sh prefer-builtin-tools.sh \
  prompt-injection-detector.sh protect-claudemd.sh scope-guard.sh skill-gate.sh \
  test-before-commit.sh verify-before-commit.sh verify-before-done.sh
