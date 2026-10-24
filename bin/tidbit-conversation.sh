#!/bin/bash
#
# File a tidbit from the Claude Code session that invokes it.
#
#   tidbit-conversation.sh "shared filer latency"
#
# This exists so the /tidbit skill costs the main agent almost nothing. It used
# to hand-write a summary of the conversation into a scratch file and then
# hand-write an Agent prompt -- roughly 3,700 characters of generated prose on
# the critical path, about 26 seconds of it, before the user got their session
# back. All of that work is mechanical, so it lives here instead: the agent emits
# one short command and returns.
#
# Everything downstream is shared with the voice and typed transports via
# tidbit-file.sh. This script only gathers material.
#
# Detaches internally, so the caller does not need to remember nohup -- one less
# thing for the agent to type, and one less way for it to block by accident.

set -uo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$PATH"

# ----- config -----------------------------------------------------------
FILER="${TIDBIT_FILER:-$HOME/bin/tidbit-file.sh}"
VAULT="$HOME/Documents/tidbit"
# How much of the session tail to hand over. The excerpt is already filtered
# down to prose, so this is generous: ~8k characters is several turns.
TAIL_CHARS="${TIDBIT_TAIL_CHARS:-8000}"
# ------------------------------------------------------------------------

die() { echo "tidbit-conversation: $1" >&2; exit 1; }

[[ -x "$FILER" ]] || die "filer missing at $FILER"
command -v jq >/dev/null || die "jq not on PATH"

POINTER="$*"

# ----- locate this session's transcript ---------------------------------
# Claude Code exports the session id, and the transcript is named after it. The
# containing directory is the cwd with every non-alphanumeric character replaced
# by a dash, but reconstructing that is fiddly and easy to get subtly wrong --
# find by name instead and let the filesystem answer. Not `ls`: that is an eza
# function in this shell, and it would mangle the result.
[[ -n "${CLAUDE_CODE_SESSION_ID:-}" ]] \
  || die "CLAUDE_CODE_SESSION_ID is unset — not running inside Claude Code?"

TRANSCRIPT=$(find "$HOME/.claude/projects" -maxdepth 2 \
  -name "$CLAUDE_CODE_SESSION_ID.jsonl" 2>/dev/null | head -1)
[[ -n "$TRANSCRIPT" && -s "$TRANSCRIPT" ]] \
  || die "no transcript found for session $CLAUDE_CODE_SESSION_ID"

# ----- resolve the target directory -------------------------------------
# The repo is known exactly here, from the git toplevel, which is what makes the
# Claude Code transport repo-specific where voice and typed are not.
REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
REPO=${REPO#.}   # a leading dot would hide the folder from Obsidian and Finder
DIR="$VAULT/$REPO"

# ----- extract the conversation -----------------------------------------
# Only text and thinking blocks: tool_result content is ~80% of a transcript by
# volume and almost none of it is the idea worth keeping.
#
# isMeta filters out injected skill bodies. Without it the excerpt ends with the
# tidbit skill's own instructions, and a note gets written about how to write
# notes. Dropping it structurally beats asking the model to ignore what it sees.
STAMP=$(date +%Y-%m-%d_%H%M%S)
NOTE_FILE="/tmp/tidbit-conv-$STAMP-$$.md"
LOG="/tmp/tidbit-conv-$STAMP-$$.log"

{
  [[ -n "$POINTER" ]] && printf 'POINTER: %s\n\n' "$POINTER"
  jq -r '
    select(.isMeta != true)
    | select(.message.content != null)
    | (.message.content | if type == "array" then .[] else empty end)
    | select(.type == "text" or .type == "thinking")
    | (.text // .thinking)
  ' "$TRANSCRIPT" 2>/dev/null | tail -c "$TAIL_CHARS"
} >"$NOTE_FILE" || die "couldn't write $NOTE_FILE"

[[ -s "$NOTE_FILE" ]] || die "extracted nothing from $TRANSCRIPT"

# ----- hand off, detached ------------------------------------------------
nohup "$FILER" "$NOTE_FILE" --source conversation --dir "$DIR" --log "$LOG" \
  >/dev/null 2>&1 &

echo "capturing tidbit into ${DIR/#$HOME/~}"
