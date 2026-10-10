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

ok()   { echo "   ✓ $1"; }
skip() { echo "   • $1"; }
warn() { echo "   ⚠️  $1"; }

# Real failures (install/fetch errors, not benign skips) bump this; the script
# exits non-zero when it is set so `make post-install`'s `|| warn` surfaces it.
fail_total=0

dest="$HOME/.claude/hooks"
mkdir -p "$dest"
echo "==> Claude hooks -> $dest"

# --- tool-managed hooks -----------------------------------------------------
echo "-> rtk hook (rtk init -g --hook-only --no-patch)"
if ! command -v rtk >/dev/null 2>&1; then
  skip "rtk not on PATH — skipped (post-install installs rtk earlier)"
elif rtk init -g --hook-only --no-patch >/dev/null 2>&1; then
  ok "installed/updated"
else
  warn "rtk hook install failed — run: rtk init -g --hook-only --no-patch"; fail_total=$((fail_total + 1))
fi

echo "-> herdr hook (herdr integration install claude)"
if ! command -v herdr >/dev/null 2>&1; then
  skip "herdr not on PATH — run 'make build' first, then re-run"
elif herdr integration install claude >/dev/null 2>&1; then
  ok "installed/updated"
else
  warn "herdr integration install failed — run: herdr integration install claude"; fail_total=$((fail_total + 1))
fi

# --- helper: fetch a list of hook files from a raw base URL -----------------
fetch_hooks() {
  local label="$1" base="$2"; shift 2
  local total=$#
  echo "-> $label ($total hooks)"
  if ! command -v curl >/dev/null 2>&1; then warn "curl not found — skipped"; fail_total=$((fail_total + total)); return 0; fi
  local h got=0 fails=()
  for h in "$@"; do
    if curl -fsSL "$base/$h" -o "$dest/$h.tmp" 2>/dev/null; then
      chmod +x "$dest/$h.tmp" && mv "$dest/$h.tmp" "$dest/$h"; got=$((got + 1))
    else
      rm -f "$dest/$h.tmp" 2>/dev/null; fails+=("$h")
    fi
  done
  if [ "${#fails[@]}" -eq 0 ]; then
    ok "$got/$total fetched"
  else
    warn "$got/$total fetched — failed: ${fails[*]}"; fail_total=$((fail_total + ${#fails[@]}))
  fi
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

# --- portability patches -----------------------------------------------------
# The pinned upstreams use GNU-only `stat -c %Y`; macOS ships BSD stat, which
# rejects -c, and the `|| echo 0` fallback then silently yields mtime 0. In
# verify-before-commit.sh that makes every test marker look epoch-old, so the
# guard fail-closes and blocks EVERY commit; in proof-log-session.sh it just
# logs an absurd session duration. Rewrite the call to try BSD `stat -f %m`
# first with the GNU form as fallback. Idempotent: files already containing the
# BSD form are skipped. Drop this once fixed upstream and the *_REF pins move.
echo "-> portability patches (BSD/GNU stat)"
for f in verify-before-commit.sh proof-log-session.sh; do
  if [ ! -f "$dest/$f" ]; then
    warn "$f missing — fetch failed above?"
  elif grep -q 'stat -f %m' "$dest/$f"; then
    skip "$f already portable"
  elif sed -i.bak -E 's/stat -c %Y ("[^"]+") 2>\/dev\/null/stat -f %m \1 2>\/dev\/null || &/' "$dest/$f" \
       && grep -q 'stat -f %m' "$dest/$f"; then
    rm -f "$dest/$f.bak"; ok "$f: stat mtime lookup made BSD+GNU portable"
  else
    rm -f "$dest/$f.bak" 2>/dev/null
    warn "$f: expected GNU stat pattern not found — upstream changed? review manually"; fail_total=$((fail_total + 1))
  fi
done

# destructive-guard.sh needs two more fixes (multi-line, so a pinned diff via
# `patch` instead of sed):
#   (a) Check 1's regex has no word boundary, so `rm\s+~/` matches INSIDE words
#       ("wezterm ~/x" blocks any innocent command mentioning a ~/ path);
#   (b) GNU-only `grep -oP ...\K` errors on BSD grep, printing usage noise and
#       silently disabling the NFS-mount check (GitHub #36640 protection).
# Applied to a temp copy so a failed hunk never leaves a half-patched guard.
f="destructive-guard.sh"
if [ ! -f "$dest/$f" ]; then
  warn "$f missing — fetch failed above?"
elif ! grep -q 'grep -oP' "$dest/$f"; then
  skip "$f already portable"
elif ! command -v patch >/dev/null 2>&1; then
  warn "$f: 'patch' not found — guard left with GNU-only regexes"; fail_total=$((fail_total + 1))
elif cp "$dest/$f" "$dest/$f.tmp" && patch -s "$dest/$f.tmp" <<'GUARD_EOF'
--- destructive-guard.sh
+++ destructive-guard.sh
@@ -60,7 +60,8 @@
 SAFE_DIRS="${CC_SAFE_DELETE_DIRS:-node_modules:dist:build:.cache:__pycache__:coverage:.next:.nuxt:tmp}"

 # --- Check 1: rm -rf on dangerous paths ---
-if echo "$COMMAND" | grep -qE 'rm\s+(-[rf]+\s+)*(\/$|\/\s|\/[^a-z]|\/home|\/etc|\/usr|\/var|~\/|~\s*$|\.\.\/|\.\.\s*$)'; then
+# Word boundary: a bare `rm\s+` also matched inside words ("wezterm ~/x").
+if echo "$COMMAND" | grep -qE '(^|[;&|[:space:]])rm\s+(-[rf]+\s+)*(\/$|\/\s|\/[^a-z]|\/home|\/etc|\/usr|\/var|~\/|~\s*$|\.\.\/|\.\.\s*$)'; then
     # Exception: safe directories
     SAFE=0
     IFS=':' read -ra DIRS <<< "$SAFE_DIRS"
@@ -75,7 +76,8 @@
     # Why: GitHub #36640 — rm -rf on a dir with NFS mount deleted production data
     if (( SAFE == 0 )); then
         # Extract the target path from the rm command
-        TARGET_PATH=$(echo "$COMMAND" | grep -oP 'rm\s+(-[rf]+\s+)*\K\S+')
+        # BSD grep has no -P/\K; extract the rm target with portable sed.
+        TARGET_PATH=$(echo "$COMMAND" | sed -nE 's/.*(^|[;&|[:space:]])rm[[:space:]]+(-[rf]+[[:space:]]+)*([^[:space:];&|]+).*/\3/p')
         if [ -n "$TARGET_PATH" ] && command -v findmnt &>/dev/null; then
             if findmnt -n -o TARGET --submounts "$TARGET_PATH" 2>/dev/null | grep -q .; then
GUARD_EOF
then
  mv "$dest/$f.tmp" "$dest/$f" && chmod +x "$dest/$f"
  rm -f "$dest/$f.tmp.orig" 2>/dev/null  # BSD patch leaves a backup of the tmp copy
  ok "$f: word-boundary + BSD grep fixes applied"
else
  rm -f "$dest/$f.tmp" "$dest/$f.tmp.orig" "$dest/$f.tmp.rej" 2>/dev/null
  warn "$f: patch did not apply — upstream changed? review manually"; fail_total=$((fail_total + 1))
fi

if [ "$fail_total" -ne 0 ]; then
  echo "==> hooks: $fail_total item(s) failed — see warnings above; re-run: bash ai/install-hooks.sh" >&2
  exit 1
fi
echo "==> hooks done."
