#!/usr/bin/env bash
set -euo pipefail

# Find aerospace (GUI shells often miss Homebrew PATH)
AEROSPACE_BIN="${AEROSPACE_BIN:-/opt/homebrew/bin/aerospace}"
if ! command -v "$AEROSPACE_BIN" >/dev/null 2>&1; then
  AEROSPACE_BIN="$(command -v aerospace || true)"
fi
[ -x "${AEROSPACE_BIN:-}" ] || exit 0

FOCUSED="${FOCUSED_WORKSPACE:-$("$AEROSPACE_BIN" list-workspaces --focused 2>/dev/null || true)}"

# Collect non-empty workspaces across monitors
MONS="$("$AEROSPACE_BIN" list-monitors | awk '{print $1}')"
wanted_raw="$(
  for m in $MONS; do
    "$AEROSPACE_BIN" list-workspaces --monitor "$m" --empty no || true
  done | awk 'NF'
)"
# Dedupe + add focused (if not already present), then sort alphanumerically
wanted="$(printf '%s\n%s\n' "$wanted_raw" "${FOCUSED:-}" \
         | awk 'NF' | sort -uV)"   # -V = version sort, handles 1,2,10 and A,B,C

has_item() { sketchybar --query "space.$1" >/dev/null 2>&1; }

args=()

# 1) Ensure every "wanted" chip exists (start hidden) and is anchored after the separator
for sid in $wanted; do
  if ! has_item "$sid"; then
    args+=(
      --add item "space.$sid" left
      --set "space.$sid"
        padding_left=2 padding_right=2
        background.color=0x44ffffff background.corner_radius=5 background.height=20
        background.drawing=off
        label="$sid" label.padding_left=5 label.padding_right=5
        click_script="$AEROSPACE_BIN workspace $sid"
        drawing=off
    )
  fi
done

# 2) Visibility: hide all known, then show wanted-minus-focused
#    (get all known SIDs from AeroSpace; we only "set" for ones that already exist)
all_sids="$(
  for m in $MONS; do
    "$AEROSPACE_BIN" list-workspaces --monitor "$m" --empty yes || true
  done | awk 'NF' | sort -uV
)"
# Hide everything
for sid in $all_sids; do
  args+=( --set "space.$sid" drawing=off )
done
# Show all wanted except the focused
visible_sorted="$(printf '%s\n' "$wanted" | awk -v f="$FOCUSED" '$0!=f')"
for sid in $visible_sorted; do
  args+=( --set "space.$sid" drawing=on )
done

# 3) Order: move chips in alphanumeric order to appear right of the separator
prev="separator"
for sid in $visible_sorted; do
  args+=( --move "space.$sid" after "$prev" )
  prev="space.$sid"
done

# 4) Keep the pill label synced & make sure focused chip stays hidden
[ -n "${FOCUSED:-}" ] && args+=( --set focused_workspace label="$FOCUSED" )
[ -n "${FOCUSED:-}" ] && args+=( --set "space.$FOCUSED" drawing=off )

# Fire once
[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
