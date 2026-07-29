# Split clock.sh into two so the whole thing wouldn't move since this dumbass font isn't actually monospace??

sketchybar --set "$NAME" \
  label="$(date '+%a %m/%d')" \
  click_script='open -a "Calendar"'
