#!/bin/bash
#
# Called in the background by voice-memo.sh with the recording path.
# Transcribes it, then hands the transcript to tidbit-file.sh, which routes and
# files it. Everything downstream of the transcript is shared with the typed
# `tidbit` command and lives in the filer, not here.

set -uo pipefail

# ~/.local/bin is where the claude CLI lives on this machine.
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

# ----- config -----------------------------------------------------------
MODEL="$HOME/.whisper/ggml-base.en.bin"
WHISPER_BIN="whisper-cli"                          # brew whisper-cpp 1.9.2
FILER="$HOME/bin/tidbit-file.sh"
KEEP_AUDIO=true                                    # false to delete the .m4a after processing
# ------------------------------------------------------------------------

FILE="${1:?usage: memo-process.sh <audio-file>}"
# Absolute from here on: the filer cds into the vault, so every path derived from
# BASE (transcript, logs) has to survive that.
[[ "$FILE" = /* ]] || FILE="$PWD/$FILE"
BASE="${FILE%.*}"

notify() {
  osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1
}

fail() {
  notify "Tidbit" "$1"
  echo "$1" >&2
  exit 1
}

command -v "$WHISPER_BIN" >/dev/null || fail "$WHISPER_BIN not on PATH."
[[ -s "$MODEL" ]]                   || fail "Whisper model missing at $MODEL."
[[ -x "$FILER" ]]                   || fail "Tidbit filer missing at $FILER."

# whisper.cpp wants 16 kHz mono PCM
ffmpeg -nostdin -loglevel error -y -i "$FILE" -ar 16000 -ac 1 "$BASE.wav" \
  || fail "Couldn't decode the recording."

"$WHISPER_BIN" -m "$MODEL" -f "$BASE.wav" -otxt -of "$BASE" \
  || fail "Transcription failed. Check the model path."

rm -f "$BASE.wav"

TRANSCRIPT="$BASE.txt"
[[ -s "$TRANSCRIPT" ]] || fail "Transcript was empty — check your mic input."

# The filer reads the transcript, routes it, files it and sends the "Filed:"
# notification. It cds into the vault, which is why $BASE.claude.log has to be
# the absolute path established at the top of this script.
"$FILER" "$TRANSCRIPT" --source voice --log "$BASE.claude.log" \
  || exit 1

[[ "$KEEP_AUDIO" == true ]] || rm -f "$FILE"
