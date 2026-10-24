---
name: investigate
description: Investigate a question or diagnose a problem without changing anything. Use when the user asks "why is X happening", "what's causing this error", "how does X work", or otherwise wants an answer, a diagnosis, or options; not a fix. Read-only: explains the cause and recommends solutions for the user to choose from.
---

# Investigate

Answer the question. Do not change anything.

## Read-only rule

This skill is strictly investigative. Never:

- Permanently edit, create, or delete files in the user's project or config
- Run commands that mutate state (installs, `git` writes, migrations, service restarts, formatters)
- "Just quickly fix" something you found along the way, even if it's trivial and obviously correct

If a diagnostic step genuinely requires side effects, describe it and ask first. Scratch files in a temp dir are fine.

## How to investigate

Use whatever gets you to a confident answer: read the relevant files and logs, reproduce the error in a read-only way, check versions and configs, trace the code path, search the web or docs for error strings and known issues. Prefer evidence over inference; quote the line, the log entry, or the doc that proves your conclusion.

Follow the trail until you can name a specific cause. If you can't get there, say so explicitly and report what you ruled out  a narrowed-down unknown is a real result; a confident guess is not.

## What to report

Keep it proportional to the question; a short answer for a small question.

1. **Answer / diagnosis**: what's actually going on, in a sentence or two.
2. **Evidence**: the specific file:line, log line, or source that shows it.
3. **Recommendation**: if there's one clear fix, give it and say why. If it's a real tradeoff, list the options with their consequences and let the user pick.

Show the fix as a diff, snippet, or command the user can apply, but don't apply it. End by offering to implement whichever option they choose.
