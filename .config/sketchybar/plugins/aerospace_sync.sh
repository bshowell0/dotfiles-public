#!/usr/bin/env bash
set -euo pipefail

# Reconcile the workspace chips against AeroSpace's live workspace list.
#
# aerospace.toml sets config-version = 2 with persistent-workspaces = [], so empty
# workspaces are destroyed on the fly and `list-workspaces --all` is already the exact
# set worth showing: deduped, sorted, and spanning every monitor. That means no
# per-monitor merging, no sorting and no hide-pass are needed here.
#
# We reconcile deltas rather than rebuilding from scratch: removing every chip and
# re-adding it on each workspace change makes the row visibly flicker. On a plain
# workspace switch the chip set is unchanged, so all that goes out is a couple of
# drawing toggles.

# Find aerospace (GUI shells often miss Homebrew PATH)
AEROSPACE_BIN="${AEROSPACE_BIN:-/opt/homebrew/bin/aerospace}"
if ! command -v "$AEROSPACE_BIN" >/dev/null 2>&1; then
  AEROSPACE_BIN="$(command -v aerospace || true)"
fi
[ -x "${AEROSPACE_BIN:-}" ] || exit 0

FOCUSED="${FOCUSED_WORKSPACE:-$("$AEROSPACE_BIN" list-workspaces --focused 2>/dev/null || true)}"

wanted="$("$AEROSPACE_BIN" list-workspaces --all)"

# Scrape the chip names straight out of the bar query with bash's own regex rather
# than piping to jq. This runs on every workspace switch, and the chips visibly lag
# the app-name label if it gets slow, so the whole path avoids subprocesses where it
# reasonably can -- see in_list below for the same reason.
existing="$(sketchybar --query bar | while IFS= read -r line; do
  [[ $line =~ \"space\.([A-Za-z0-9_-]+)\" ]] && printf '%s\n' "${BASH_REMATCH[1]}" || true
done)"

# Pure-bash membership test; a printf|grep here costs two processes per call, and it
# gets called once per workspace on both lists.
in_list() { case $'\n'"$2"$'\n' in *$'\n'"$1"$'\n'*) return 0 ;; *) return 1 ;; esac; }

args=()

# Drop chips whose workspace no longer exists. Removing an item leaves the relative
# order of the survivors untouched, so this needs no repositioning afterwards.
for sid in $existing; do
  if ! in_list "$sid" "$wanted"; then
    args+=( --remove "space.$sid" )
  fi
done

# Create chips for workspaces that don't have one yet. New items land at the end of
# the left region, so each new chip -- and only it -- gets a single --move into its
# sorted slot, anchored to whichever chip precedes it. Walking $wanted in order means
# that anchor is always already on the bar by the time the move applies.
prev="separator"
for sid in $wanted; do
  if ! in_list "$sid" "$existing"; then
    args+=(
      --add item "space.$sid" left
      --set "space.$sid"
        padding_left=2 padding_right=2
        background.color=0x44ffffff background.corner_radius=5 background.height=20
        background.drawing=off
        label="$sid" label.padding_left=5 label.padding_right=5
        click_script="$AEROSPACE_BIN workspace $sid"
      --move "space.$sid" after "$prev"
    )
  fi
  prev="space.$sid"
done

# Show every chip except the focused one (the pill already shows that)
for sid in $wanted; do
  if [ "$sid" = "$FOCUSED" ]; then
    args+=( --set "space.$sid" drawing=off )
  else
    args+=( --set "space.$sid" drawing=on )
  fi
done

if [ -n "$FOCUSED" ]; then
  args+=( --set focused_workspace label="$FOCUSED" )
fi

sketchybar "${args[@]}"
