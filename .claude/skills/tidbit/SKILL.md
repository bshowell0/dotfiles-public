---
name: tidbit
description: Capture a quick, low-friction note about an insight, idea, or future research avenue that came up but isn't worth pursuing right now, so it can be found later. Use when the user invokes /tidbit (with or without extra text), or proactively after your own substantive response surfaced a genuine tangent worth flagging. Writes to a shared vault at ~/Documents/tidbit/ of Obsidian-style markdown notes, grouped by repo then topic.
---

# Tidbit

A tidbit is a short "write it down and move on" note — not documentation, not a task. It exists so a future session can rediscover an idea that wasn't worth derailing current work to chase.

## When to invoke this yourself

Only after a response that produced a genuinely durable, non-obvious insight — an efficiency idea, a future research direction, a "huh, we should look into that later." Not for every reply. If in doubt, don't.

## How to file one

One command, then you are done:

```bash
~/bin/tidbit-conversation.sh "<pointer>"
```

It detaches and returns immediately. Acknowledge briefly ("capturing that") and carry on with whatever you were doing.

The whole point is that filing a tidbit should cost the session almost nothing, so the slow parts are deliberately not yours to do:

- **Do not summarise the conversation.** A background agent reads this session's transcript directly. Writing out a summary was the most expensive step of the previous version of this skill and it bought nothing.
- **Do not use the `Agent` tool.** The script spawns its own background worker.
- **Do not read `format.md`,** and do not write, read, or check anything in the vault. The script hands the format spec to the background agent, which owns the entire file-format question.
- **Do not resolve the repo, the timestamp, or the transcript path.** The script does all three: it finds the transcript by session id, takes the target directory from the git toplevel, and strips tool output and injected instructions out of the excerpt before handing it over.

If the command fails it explains why on stderr. Relay that to the user rather than falling back to writing the note by hand.

## The pointer

The quoted argument is the one thing the script cannot work out for itself, and it decides what the note ends up being about. The script supplies the tail of the session; the pointer says which thread in it matters. Spend a moment getting this right — it is cheap, and it is the whole of your contribution.

- **Args given**: the user's own words are the pointer. Pass them through close to verbatim. Don't generalise them into something blander, and don't substitute your framing for theirs.
- **No args**: name the specific insight from your own last substantive response, in a few words. "Shared filer latency" is a pointer. "Our conversation" is not.

Keep it to a phrase rather than a sentence — it is a subject line, not a summary. The excerpt supplies the detail.

Two cases worth handling deliberately:

- **The idea is older than the tail.** The excerpt covers only the last few turns. If you are deliberately resurrecting something from earlier in the session, say so and carry enough detail in the pointer for it to stand alone: `"earlier idea: batch the tokenizer preprocessing step"`. An unqualified pointer to something long past will find no support in the excerpt.
- **The insight is yours, not the user's.** When invoking proactively, the pointer should name the insight rather than the exchange that produced it. The note has to make sense to someone who never saw this session.

## Where tidbits live

`~/Documents/tidbit/`, with one optional layer of directories named after the repo. Nothing is ever written inside the repo itself.

This transport is the one that knows the repo exactly, from the git toplevel, so notes filed from Claude Code are always attributed to a repo directory rather than landing at the unattributed vault root. That is the deliberate difference from the voice and typed transports, which have only the words the author gave them and fall back to the root when unsure.

`format.md` in this directory is the shared format spec for every transport. It exists for the background agent, and for you to edit if the format should change — it is not something you need to read in order to file a note.
