#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  if     [ "$VOLUME" -ge 100 ]; then ICON="󰕾 󰪥"
    elif [ "$VOLUME" -ge 82 ]; then ICON="󰕾 󰪤"
    elif [ "$VOLUME" -ge 70 ]; then ICON="󰕾 󰪣"
    elif [ "$VOLUME" -ge 58 ]; then ICON="󰕾 󰪢"
    elif [ "$VOLUME" -ge 45 ]; then ICON="󰕾 󰪡"
    elif [ "$VOLUME" -ge 32 ]; then ICON="󰕾 󰪠"
    elif [ "$VOLUME" -ge 20 ]; then ICON="󰕾 󰪟"
    elif [ "$VOLUME" -gt 0  ]; then ICON="󰕾 󰪞"
    else                            ICON="󰖁 󰄰"
  fi

  sketchybar --set "$NAME" icon="$ICON" label.drawing=off
fi
