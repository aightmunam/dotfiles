#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Find Thought
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon :brain:
# @raycast.argument1 { "type": "text", "placeholder": "search query", "optional": true }
# @raycast.packageName HumanLayer

# Documentation:
# @raycast.description Fuzzy search HumanLayer thoughts
# @raycast.author Munam Mubashir

query="${1:-}"
thoughts_repo="$HOME/thoughts"

if [[ ! -d "$thoughts_repo" ]]; then
  echo "No thoughts repository found at $thoughts_repo"
  exit 1
fi

echo "Searching thoughts for: ${query:-'(all files)'}"
echo "---"

if [[ -n "$query" ]]; then
  # Content search
  results=$(rg --files-with-matches --no-messages "$query" "$thoughts_repo" 2>/dev/null | head -15)
else
  # List recent files
  results=$(find "$thoughts_repo" -type f -name "*.md" -not -path "*/\.*" 2>/dev/null | \
    xargs ls -t 2>/dev/null | head -15)
fi

if [[ -z "$results" ]]; then
  echo "No thoughts found"
  exit 0
fi

echo "$results" | while read -r file; do
  # Get relative path from thoughts repo
  relpath="${file#$thoughts_repo/}"
  # Get first non-empty line as title
  title=$(grep -m1 -E "^#|^[A-Za-z]" "$file" 2>/dev/null | head -1 | sed 's/^#* *//')
  if [[ -n "$title" ]]; then
    echo "$relpath  ->  $title"
  else
    echo "$relpath"
  fi
done
