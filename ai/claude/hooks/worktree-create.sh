#!/usr/bin/env bash
#
# WorktreeCreate hook: put every Claude Code worktree (--worktree, EnterWorktree,
# subagent isolation, background sessions) at ~/wt/<repo>/<name>, the same place
# /create_worktree and /local_review use, instead of <repo>/.claude/worktrees/.
#
# Contract: JSON on stdin ({cwd, name, ...}); print the absolute worktree path as
# the LAST stdout line; everything else goes to stderr. A hook replaces native
# creation entirely, so this also mirrors what native does: branch from
# origin/<default> (worktree.baseRef "fresh") and copy .worktreeinclude files.
set -euo pipefail

input=$(cat)
cwd=$(jq -r '.cwd' <<<"$input")
# Native turns "/" in names into "+" (e.g. feat/x -> feat+x); keep that.
name=$(jq -r '.name' <<<"$input" | tr '/' '+')

common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
  echo "worktree-create: $cwd is not inside a git repository" >&2
  exit 1
}
main=$(dirname "$common")   # main checkout, even when cwd is itself a linked worktree
repo=$(basename "$main")
dir="$HOME/wt/$repo/$name"
branch="worktree-$name"

# Resuming a session whose worktree already exists: hand it back unchanged.
if git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "$dir"
  exit 0
fi

mkdir -p "$(dirname "$dir")"

if git -C "$main" show-ref --verify --quiet "refs/heads/$branch"; then
  git -C "$main" worktree add "$dir" "$branch" >&2
else
  base=HEAD
  default=$(git -C "$main" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
  if [ -n "$default" ]; then
    git -C "$main" fetch --quiet origin "${default#origin/}" >&2 || true
    base=$default
  fi
  git -C "$main" worktree add --no-track -b "$branch" "$dir" "$base" >&2
fi

# Copy gitignored local files the repo opts into (.env etc.), like native does.
if [ -f "$main/.worktreeinclude" ]; then
  (cd "$main" && git ls-files --others --ignored --exclude-from=.worktreeinclude -z) |
    while IFS= read -r -d '' f; do
      mkdir -p "$dir/$(dirname "$f")"
      cp -p "$main/$f" "$dir/$f"
    done
fi

# Same convention as /create_worktree: share thoughts/ with the main checkout.
if [ -d "$main/thoughts" ] && [ ! -e "$dir/thoughts" ]; then
  ln -s "$main/thoughts" "$dir/thoughts"
fi

echo "$dir"
