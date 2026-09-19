#!/usr/bin/env bash
#
# Install the tool-managed Claude Code hooks that are NOT versioned in this repo.
#
# These hook files are created and OVERWRITTEN by their own tools (rtk, herdr) on
# every update, so vendoring them would produce spurious git diffs. The versioned
# settings.json already references them by path; this script just (re)places the
# files. Custom, user-authored hooks live in claude/hooks/ and ARE tracked.
#
# Run standalone or via `make install`. Requires rtk + herdr on PATH
# (herdr comes from `make build`; rtk from the post-install rtk step).
set -uo pipefail

# rtk -> claude/hooks/rtk-rewrite.sh (+ .rtk-hook.sha256).
# --hook-only --no-patch: place ONLY the hook file; do not rewrite our versioned
# settings.json or RTK.md.
if command -v rtk >/dev/null 2>&1; then
  echo "-> rtk init -g --hook-only --no-patch"
  rtk init -g --hook-only --no-patch || echo "  rtk hook install failed — run 'rtk init -g --hook-only --no-patch' manually"
else
  echo "  rtk not found on PATH — skipping rtk hook"
fi

# herdr -> claude/hooks/herdr-agent-state.sh (herdr manages/overwrites this file).
if command -v herdr >/dev/null 2>&1; then
  echo "-> herdr integration install claude"
  herdr integration install claude || echo "  herdr integration install failed — run 'herdr integration install claude' manually"
else
  echo "  herdr not found on PATH — run 'make build' first, then re-run this script"
fi
