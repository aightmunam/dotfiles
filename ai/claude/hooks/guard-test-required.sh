#!/bin/bash
COMMAND=$(cat | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$COMMAND" ] && exit 0
if echo "$COMMAND" | grep -qE 'git\s+commit'; then
  echo "WARNING: Commit detected." >&2
  echo "Rule: run just lint and just test before any git push is done" >&2
fi
exit 0