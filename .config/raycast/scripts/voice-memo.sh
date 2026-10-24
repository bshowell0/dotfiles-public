#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Voice Tidbit
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎙️
# @raycast.packageName Tidbit
# @raycast.description Toggle recording. Stops, transcribes, and files a tidbit.

set -uo pipefail

# Raycast hands us a stripped PATH, and nohup'd children inherit it.
# ~/.local/bin is where the claude CLI lives on this machine.
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

# ----- config -----------------------------------------------------------
MEMO_DIR="$HOME/VoiceMemos"
PROCESSOR="$HOME/bin/memo-process.sh"

# Device *name*, not index. avfoundation indices renumber when you plug or
# unplug a webcam, which silently swaps which mic records; names don't.
# List them with: ffmpeg -f avfoundation -list_devices true -i ""
# Swap to ":Logitech BRIO" to record from the webcam mic instead.
AUDIO_DEVICE=":MacBook Pro Microphone"
# ------------------------------------------------------------------------

PIDFILE="/tmp/voice-memo.pid"
CURRENT="/tmp/voice-memo.current"

notify() {
  osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1
}

mkdir -p "$MEMO_DIR"

# ----- if already recording, stop -----
if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
  PID=$(cat "$PIDFILE")
  FILE=$(cat "$CURRENT" 2>/dev/null)

  # SIGINT, not SIGKILL — ffmpeg needs to finalise the container or the
  # file ends up unplayable with a missing moov atom.
  kill -INT "$PID"
  for _ in {1..50}; do
    kill -0 "$PID" 2>/dev/null || break
    sleep 0.1
  done

  rm -f "$PIDFILE" "$CURRENT"

  if [[ -z "${FILE:-}" || ! -s "$FILE" ]]; then
    notify "Tidbit" "Recording failed — nothing captured."
    exit 1
  fi

  notify "Tidbit" "Saved. Transcribing…"

  # Detach the slow part so the hotkey returns instantly.
  nohup "$PROCESSOR" "$FILE" >/tmp/voice-memo.log 2>&1 &
  exit 0
fi

# ----- otherwise, start -----
FILE="$MEMO_DIR/memo-$(date +%Y-%m-%d_%H%M%S).m4a"
echo "$FILE" >"$CURRENT"

nohup ffmpeg -nostdin -loglevel error \
  -f avfoundation -i "$AUDIO_DEVICE" \
  -c:a aac -b:a 128k \
  "$FILE" >/tmp/voice-memo-ffmpeg.log 2>&1 &

echo $! >"$PIDFILE"
notify "Tidbit" "Recording… press the hotkey again to stop."
