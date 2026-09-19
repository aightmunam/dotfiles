#!/bin/bash
# Notification DJ. Plays a song matching Claude's state.
# Uses custom files from ~/Music/claude-dj/ if present,
# otherwise falls back to macOS system sounds.

MSG=$(jq -r '.message // empty' 2>/dev/null)
CUSTOM="$HOME/Music/claude-dj"
SYS="/System/Library/Sounds"

play() {
  local custom="$CUSTOM/$1"
  local fallback="$SYS/$2"
  if [[ -f "$custom" ]]; then
    afplay "$custom" >/dev/null 2>&1 &
  elif [[ -f "$fallback" ]]; then
    afplay "$fallback" >/dev/null 2>&1 &
  fi
}

case "$MSG" in
  *permission*|*approval*|*waiting*) play "should-i-stay.m4a"   "Funk.aiff"  ;;  # The Clash
  *error*|*failed*)                  play "highway-to-hell.m4a" "Basso.aiff" ;;  # AC/DC
  *complete*|*done*|*finished*)      play "champions.m4a"       "Hero.aiff"  ;;  # Queen
  *)                                 play "default-ding.m4a"    "Tink.aiff"  ;;
esac

exit 0
