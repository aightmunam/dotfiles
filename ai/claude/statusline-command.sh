#!/usr/bin/env bash
# Claude Code status line
# Shows: context bar | branch [worktree] path | PR

input=$(cat)

# ── Context window ────────────────────────────────────────────────────────────
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

build_bar() {
  local pct="${1:-0}"
  local filled=$(( pct * 10 / 100 ))
  local empty=$(( 10 - filled ))
  local bar=""
  local i
  for (( i=0; i<filled; i++ )); do bar+="█"; done
  for (( i=0; i<empty;  i++ )); do bar+="░"; done
  printf "%s" "$bar"
}

if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  bar=$(build_bar "$used_int")
  # colour: green → yellow → red
  if   [ "$used_int" -ge 85 ]; then colour="\033[31m"   # red
  elif [ "$used_int" -ge 60 ]; then colour="\033[33m"   # yellow
  else                               colour="\033[32m"   # green
  fi
  ctx_part=$(printf "${colour}[${bar} %d%%]\033[0m" "$used_int")
else
  ctx_part=""
fi

# ── Git branch & worktree ─────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
git_worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
worktree_name=$(echo "$input" | jq -r '.worktree.name // empty')

branch=""
if [ -n "$cwd" ] && [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# worktree label
wt_label=""
if [ -n "$worktree_name" ]; then
  wt_label=" \033[35m[wt:${worktree_name}]\033[0m"
elif [ -n "$git_worktree" ]; then
  wt_label=" \033[35m[wt:${git_worktree}]\033[0m"
fi

# ── Path (collapse $HOME to ~) ────────────────────────────────────────────────
display_path=""
if [ -n "$cwd" ]; then
  home=$(eval echo "~")
  display_path="${cwd/#$home/\~}"
fi

# ── Active PR ─────────────────────────────────────────────────────────────────
pr_part=""
if [ -n "$branch" ] && command -v gh >/dev/null 2>&1; then
  pr_info=$(gh pr view --json number,title,state 2>/dev/null \
            || ([ -n "$cwd" ] && cd "$cwd" && gh pr view --json number,title,state 2>/dev/null))
  if [ -n "$pr_info" ]; then
    pr_num=$(echo "$pr_info" | jq -r '.number')
    pr_state=$(echo "$pr_info" | jq -r '.state')
    pr_title=$(echo "$pr_info" | jq -r '.title' | cut -c1-40)
    case "$pr_state" in
      OPEN)   pr_colour="\033[32m" ;;
      MERGED) pr_colour="\033[35m" ;;
      CLOSED) pr_colour="\033[31m" ;;
      *)      pr_colour="\033[0m"  ;;
    esac
    pr_part=$(printf " ${pr_colour}PR#%s %s\033[0m" "$pr_num" "$pr_title")
  fi
fi

# ── Assemble ──────────────────────────────────────────────────────────────────
parts=()

[ -n "$ctx_part" ]      && parts+=("$ctx_part")

if [ -n "$branch" ]; then
  git_part=$(printf "\033[36m%s\033[0m%s \033[90m%s\033[0m" "$branch" "$wt_label" "$display_path")
  parts+=("$git_part")
elif [ -n "$display_path" ]; then
  parts+=("$(printf "\033[90m%s\033[0m" "$display_path")")
fi

[ -n "$pr_part" ] && parts+=("$pr_part")

# join with separator
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="$result \033[90m|\033[0m $part"
  fi
done

printf "%b\n" "$result"
