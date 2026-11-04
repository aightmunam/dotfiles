#!/bin/bash
# sf-prod-guard.sh: block Salesforce CLI commands against a prod org.
#
# TRIGGER: PreToolUse, MATCHER: Bash.
# The prod org aliases come from the gitignored work overlay, on the line
#   - Prod Salesforce orgs: `alias-1`, `alias-2`
# in ~/.agents/local/work.md (see ai/local.example/work.md).
# Blocks (exit 2) an `sf` or `sfdx` command that names one of those aliases,
# also with --help. With no overlay, the hook allows everything.

OVERLAY="$HOME/.agents/local/work.md"
[[ -r "$OVERLAY" ]] || exit 0

COMMAND=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[[ -n "$COMMAND" ]] || exit 0

# Only Salesforce CLI commands.
echo "$COMMAND" | grep -qE '(^|[;&|([:space:]])(sf|sfdx)[[:space:]]' || exit 0

# shellcheck disable=SC2016  # literal backticks
ORGS=$(grep -m1 -E '^- Prod Salesforce orgs:' "$OVERLAY" | grep -oE '`[^`]+`' | tr -d '`')
[[ -n "$ORGS" ]] || exit 0

# An org name matches only as a whole token: `acme-prod` does not match `acme-prod-sandbox`.
while IFS= read -r org; do
  [[ -n "$org" ]] || continue
  # shellcheck disable=SC2016  # literal regex chars
  re=$(printf '%s' "$org" | sed 's/[.[\*^$()+?{}|]/\\&/g')
  if echo "$COMMAND" | grep -qE "(^|[^A-Za-z0-9_-])${re}([^A-Za-z0-9_-]|$)"; then
    echo "BLOCKED: this sf command names the prod Salesforce org '$org'. Give the user the command to run." >&2
    exit 2
  fi
done <<< "$ORGS"
exit 0
