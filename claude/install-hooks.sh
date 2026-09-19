#!/usr/bin/env bash
#
# Install the Claude Code hooks that are NOT versioned in this repo because they
# come from upstream sources. Custom, user-authored hooks live in claude/hooks/
# and ARE tracked. This script restores:
#   - tool-managed hooks (rtk, herdr) that their own tools create/overwrite
#   - upstream safety hooks from yurukusa/claude-code-hooks (pinned)
# settings.json (versioned) references all of them by path under ~/.claude/hooks/.
#
# Idempotent. Run standalone or via `make install`.
set -uo pipefail

dest="$HOME/.claude/hooks"
mkdir -p "$dest"

# ---- rtk: rtk-rewrite.sh (+ .rtk-hook.sha256) -----------------------------
# --hook-only --no-patch: place ONLY the hook file; leave our versioned
# settings.json / RTK.md authoritative.
if command -v rtk >/dev/null 2>&1; then
  echo "-> rtk init -g --hook-only --no-patch"
  rtk init -g --hook-only --no-patch || echo "  rtk hook install failed"
else
  echo "  rtk not found on PATH — skipping rtk hook"
fi

# ---- herdr: herdr-agent-state.sh (herdr overwrites this on update) ---------
if command -v herdr >/dev/null 2>&1; then
  echo "-> herdr integration install claude"
  herdr integration install claude || echo "  herdr integration install failed"
else
  echo "  herdr not found on PATH — run 'make build' first, then re-run this script"
fi

# ---- yurukusa/claude-code-hooks (pinned, used verbatim) --------------------
# Upstream safety hooks. Update by bumping YURUKUSA_REF to a newer commit/tag.
YURUKUSA_REF="4e62261f5036a0b166aba65c502258710d5f8322"
YURUKUSA_BASE="https://raw.githubusercontent.com/yurukusa/claude-code-hooks/${YURUKUSA_REF}/hooks"
YURUKUSA_HOOKS=(
  activity-logger.sh auto-approve-readonly.sh branch-guard.sh cd-git-allow.sh
  comment-strip.sh context-monitor.sh decision-warn.sh destructive-guard.sh
  no-ask-human.sh proof-log-session.sh secret-guard.sh syntax-check.sh
)
echo "-> yurukusa/claude-code-hooks @ ${YURUKUSA_REF:0:7} (${#YURUKUSA_HOOKS[@]} hooks)"
if command -v curl >/dev/null 2>&1; then
  for h in "${YURUKUSA_HOOKS[@]}"; do
    if curl -fsSL "$YURUKUSA_BASE/$h" -o "$dest/$h.tmp" 2>/dev/null; then
      chmod +x "$dest/$h.tmp" && mv "$dest/$h.tmp" "$dest/$h"
    else
      echo "  failed: $h"; rm -f "$dest/$h.tmp" 2>/dev/null
    fi
  done
else
  echo "  curl not found — cannot fetch yurukusa hooks"
fi
