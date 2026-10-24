---
name: update-online-docs
description: Use when a doc-update patch file already exists (typically drafted by the audit-online-docs skill, in ~/Documents/notes/docs/) and the user wants it actually applied to the live system — e.g. "push this to Confluence", "apply that doc update", "/update-online-docs". Reads the patch, re-checks the live page/issue hasn't drifted, shows the exact change, and only calls the Atlassian MCP write tools after explicit user confirmation. If the doc has no Atlassian identifiers, explains there's no direct-push path and the user must paste it in by hand. NOT for finding or drafting doc staleness in the first place — that's audit-online-docs.
---

# Update online docs

`audit-online-docs` finds stale external documentation and drafts a patch file — read-only, never touches the live doc. This skill is the other half: it takes one of those patch files and actually applies it, for doc sources with a write integration available (currently: Confluence pages and Jira issues, via the Atlassian MCP).

Pushing a live, shared doc is a real action with real blast radius — visible to whoever reads that page next, not easily undone by the user the way a local file is. Never call an Atlassian write tool without an explicit go-ahead from the user in this conversation, given after they've seen the exact change.

## When this applies

- The user asks to push, apply, publish, or "actually update" a doc-update patch file — whether or not they name the file directly.
- The user invokes `/update-online-docs` manually, with or without a file path.
- Not for detecting or drafting staleness in the first place — if there's no patch file yet, that's `audit-online-docs`; run that first (or tell the user to).

## Step 1: Find the patch file

- If the user names a file or path, use it.
- Otherwise, look in `~/Documents/notes/docs/` for the most recently modified file, or one whose title matches what the user is referring to. If more than one plausible candidate exists and it's not obvious which, ask — don't guess at which live doc gets written to.
- Read the file in full.

## Step 2: Check what it can actually apply to

Look for the `Live source:` line the file's header (per `audit-online-docs`'s output format — e.g. `Confluence page "<title>", space <KEY>, page ID <id>, version <n> — <url>` or `Jira issue <KEY> — <url>`).

- **No `Live source:` line** — this doc has no known write integration (vendor portal, Slack canvas, generic wiki, or the audit couldn't confirm the live page). Tell the user there's no direct-push path available; they need to copy the patch into the real system by hand. Stop here.
- **Has a `Live source:` line** — continue.

## Step 3: Re-check for drift before touching anything

Fetch the page/issue again live (`getConfluencePage` for the recorded page ID, or `getJiraIssue` for the issue key). Compare its current version/content against what the patch file's "Old" text and recorded version assumed.

- If the version matches (or the "Old" text is still present as recorded): proceed to confirmation.
- If it's changed since the patch was drafted: stop and tell the user the live doc has moved on since the draft was written — show what's different — and let them decide whether to re-draft (via `audit-online-docs`) or proceed anyway. Never silently overwrite a page that's changed underneath the draft.

## Step 4: Confirm, then apply

Show the user the exact change(s) about to be made — old vs. new, per section, same as the patch file already has it — and ask for explicit confirmation before writing anything. If the file has multiple sections, one confirmation covering all of them is fine unless the user wants to review section by section.

On confirmation:

- **Confluence**: apply via `updateConfluencePage`. If the patch is more naturally a comment/annotation rather than an edit to the page body (the drafted content reads as commentary rather than replacement text), consider `createConfluenceFooterComment` / `createConfluenceInlineComment` instead — use judgment, and if it's ambiguous, ask which the user wants.
- **Jira**: apply via `editJiraIssue` for a field/description change, or `addCommentToJiraIssue` if it's more naturally a comment.

Do not batch this into a background agent — it needs the confirmation gate in the foreground, in this conversation.

## Step 5: Report the result

State plainly what was changed and where: the updated page/issue URL, and its new version number if Confluence returns one. If the write call fails, report the error as-is — don't retry silently or fall back to a different tool without telling the user.

## If MCP calls fail entirely

If the Atlassian MCP tools aren't reachable (connection error, permission error, etc.), say so plainly and fall back to telling the user to apply the patch by hand — don't treat it as a reason to keep retrying or to invent a workaround.
