#!/usr/bin/env bash
#
# WorktreeRemove hook, paired with worktree-create.sh. Exit 0 means "removed",
# so only succeed once the directory is really gone; on failure the worktree
# stays on disk rather than being force-deleted with uncommitted work in it.
set -uo pipefail

dir=$(jq -r '.worktree_path')
[ -e "$dir" ] || exit 0

common=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
if [ -n "$common" ]; then
  git -C "$(dirname "$common")" worktree remove --force "$dir" >&2
fi

if [ -e "$dir" ]; then
  echo "worktree-remove: could not remove $dir" >&2
  exit 1
fi
rmdir "$(dirname "$dir")" 2>/dev/null || true   # drop ~/wt/<repo> once empty
exit 0
