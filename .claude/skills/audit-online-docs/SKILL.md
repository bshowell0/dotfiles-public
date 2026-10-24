---
name: audit-online-docs
description: Use when documentation that lives outside this repo — pasted into the conversation, quoted from a wiki/Confluence/API portal, or referenced by URL — turns out to be out of date relative to the codebase or other known-current info. Also use when the user invokes /audit-online-docs manually. NOT for docs that live in this repo (README.md, CLAUDE.md, inline comments) — those are trivial to fix directly, just edit them. Gathers context, hands it to a background agent to research and draft a replacement, and writes the result to ~/Documents/notes/docs/ as a new file — read-only, never pushes anything live (see the update-online-docs skill for that).
---

# Audit online docs

Some documentation isn't yours to edit directly — it lives in a wiki, a Confluence page, a vendor's API portal, a Slack canvas, wherever. When that content turns out to be stale, you can't fix it in place. This skill produces a clearly-marked patch (old → new, with reasoning) that the user can apply themselves — either by hand, or via the `update-online-docs` skill if the source is a system with a write integration available.

This skill only reads and drafts. It never modifies the source doc, even when a tool to do so exists.

## When this applies

- Someone pastes doc text (or an excerpt) into the conversation that contradicts the current codebase or other established facts.
- The user invokes `/audit-online-docs` manually, with or without pasted text.
- Never for docs that live in this repo — README, CLAUDE.md, code comments, etc. Just edit those directly; this skill would be pure overhead.

## Determine what info you actually have

Two sources feed the rewrite. Either or both may apply — note which:

- **The outdated doc itself** — text pasted directly, or already visible earlier in the conversation. Capture it verbatim, don't paraphrase from memory.
- **Codebase truth** — current behavior/config/API/commands defined in this project that contradicts the doc.

Sometimes the doc describes something with no codebase footprint at all (a third-party service, a process, an org policy) — in that case the codebase isn't a source, and the "new" content has to come from what the user told you directly. Don't invent codebase grounding that isn't there.

Also note the doc's **source system**, if identifiable: a Confluence URL/page reference, a Jira issue key, or something else (vendor portal, Slack canvas, generic wiki). This doesn't change what this skill does, but it matters for whoever applies the patch afterward.

## Delegate the work to a background agent

Do not write the update yourself inline, and don't block whatever the user is currently doing. Spawn a background `Agent` (general-purpose, `run_in_background` default — do not wait on it) with everything it needs; it starts with zero memory of this conversation.

1. Write a scratch context file (use a temp dir, e.g. `mktemp`) containing:
   - The full outdated doc text, verbatim, if any was given.
   - The doc's source/URL, if known.
   - What you suspect is stale and why — e.g. "this describes the old `/v1/login` flow, but `auth/routes.ts` now uses `/v2/session`."
   - Pointers to specific files or areas worth checking, if you already know them.
2. Spawn `Agent` with a self-contained prompt that gives it:
   - The path to the scratch context file to read.
   - An instruction to verify independently — grep/read the codebase itself to confirm current behavior rather than trusting the main agent's suspicion at face value.
   - If the source looks like a Confluence page or Jira issue, an instruction to also read it live via the Atlassian MCP tools (e.g. `getConfluencePage`, `searchConfluenceUsingCql`, `getJiraIssue`) to ground the "old" text in the actual current page/issue rather than trusting a possibly-already-stale pasted excerpt. This is a read-only lookup — the agent must NOT call any Atlassian write tool (`updateConfluencePage`, `createConfluencePage`, `editJiraIssue`, `addCommentToJiraIssue`, comment-creation tools, etc.). Applying the fix live is a separate skill (`update-online-docs`) invoked later, with explicit user confirmation.
   - The output format spec below, pasted in full (don't paraphrase it — the agent needs the exact structure).
   - An explicit instruction: never stop and ask, and never withhold the file over an open question. Write everything that's confidently known, and put anything incomplete or ambiguous into the "Open questions" section of the file itself (see format below) so the user resolves it directly in the file, not through a round-trip.
   - An explicit instruction that its final report back (to whoever spawned it) must be minimal: the file path, and a one-line note of whether open questions remain. No need to restate content or questions in the report — they live in the file.
3. Acknowledge briefly to the user (e.g. "kicking off a doc audit in the background") and move on to whatever else is in progress — don't wait on it.
4. When the agent's completion notification arrives, just pass along the file path and whether it flagged open questions — one line, no elaboration. Don't re-ask its questions yourself; the user reads and resolves them straight from the file whenever they get to it. If they want it pushed live afterward, that's the `update-online-docs` skill, working from this same file.

## Output format

File: `~/Documents/notes/docs/<kebab-case-relevant-title>.md`. Create the directory if it doesn't exist.

Structure it as a patch, not a fresh rewrite — every change must show old and new side by side so the user (or the `update-online-docs` skill) can find-and-replace in the real doc system:

```markdown
# <Doc title> — update

Source: <url, or "pasted by user in conversation on <date>">
Reason: <one-line summary of why this is stale>
Live source: <if Confluence/Jira and confirmed via MCP — space key + page ID/URL + page version, or Jira issue key. Omit this line entirely if the source isn't Atlassian or couldn't be confirmed live.>

## <Section / topic 1>

**Old:**
> <exact old text>

**New:**
> <replacement text>

**Why:** <what changed — reference the codebase file:line if that's the source of truth>

## <Section / topic 2>
...

## Open questions

- <anything unresolved — be specific enough that the user can answer without re-reading the source doc or the codebase: what's unclear, what you checked, what the answer would change.>
```

Omit the "Open questions" section entirely if there aren't any. Only include changed sections — don't reproduce or rewrite parts of the doc that are still accurate.

## If information is insufficient

Never withhold the file or stop to ask. Write everything you're confident about, and drop anything incomplete or ambiguous into "Open questions" instead of guessing — specific enough that the user can resolve it later by reading the file alone, with no need to reconstruct context from this conversation. The file is always the deliverable, complete or not; the report back to the spawning agent is always just the path plus whether questions remain.
