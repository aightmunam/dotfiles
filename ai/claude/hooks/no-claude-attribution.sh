#!/usr/bin/env bash
# no-claude-attribution.sh
# PreToolUse (Bash) guard.
#
# Blocks any `git commit`, `gh pr create/edit`, or `gh api` command whose payload
# carries Claude / Anthropic / model attribution:
#   - a "Co-Authored-By: Claude ..." trailer
#   - the "🤖 Generated with [Claude Code]" footer
#   - a Claude-Session: trailer or claude.ai/claude.com session/code link
#   - the noreply@anthropic.com author address
#
# It is CONTENT-TARGETED, not keyword-based: it never blocks a legitimate commit
# that merely mentions the word "claude" (e.g. "Fix Claude API integration").
# It only fires when a commit/PR-authoring verb AND an attribution signature are
# both present. On anything else it exits 0 silently so the rest of the Bash
# hook pipeline runs unchanged.

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
else
  # Fallback: scan the whole payload. Slightly less precise but safe (the
  # attribution regex below is specific enough that false positives are unlikely).
  cmd=$input
fi

# 1. Only inspect commands that author a commit or PR.
if ! printf '%s' "$cmd" | grep -qiE 'git[[:space:]]+commit|gh[[:space:]]+pr[[:space:]]+(create|edit)|gh[[:space:]]+api'; then
  exit 0
fi

# 2. Look for an attribution signature (case-insensitive, precise).
attr_re='co-authored-by:[[:space:]]*claude|co-authored-by:.*anthropic|generated with[[:space:]]*\[?claude|🤖[[:space:]]*generated|claude-session:|claude\.(ai|com)/[a-z-]*(code|session)|noreply@anthropic\.com'
if printf '%s' "$cmd" | grep -qiE "$attr_re"; then
  cat <<'EOF'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Blocked by no-claude-attribution guard: this commit/PR carries Claude/model attribution (a Co-Authored-By: Claude trailer, a 'Generated with Claude Code' footer, a claude.ai/claude.com session link, or noreply@anthropic.com). Per the user's standing preference, NEVER attribute Claude/Anthropic/a model name anywhere. Remove the attribution line(s) entirely and retry the command."}}
EOF
  exit 0
fi

exit 0
