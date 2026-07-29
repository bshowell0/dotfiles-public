#!/usr/bin/env bash

# $AEROSPACE_MODE is set by the aerospace_mode_change event

if [ "$AEROSPACE_MODE" = "service" ]; then
    # Show asterisk when in service mode
    sketchybar --set "$NAME" drawing=on
else
    # Hide asterisk when in main mode
    sketchybar --set "$NAME" drawing=off
fi
