# Tidbit format

The shared format spec for every tidbit, whatever the transport. Follow it exactly.

## Where tidbits live

The vault root is `~/Documents/tidbit/`.

```
~/Documents/tidbit/
├── caching-strategies.md          ← unattributed: no known repo
├── prompt-eval-ideas.md
├── ingest-pipeline/               ← one layer, named for the repo
│   ├── backfill-throughput.md
│   └── schema-drift.md
└── listings-api/
    └── auth-token-refresh.md
```

- **Exactly one optional layer of directories.** A directory name is a repo name. Never nest
  deeper than that.
- **Directory names never start with a dot.** A repo called `.dotfiles` becomes `dotfiles/` — a
  dot-prefixed folder is hidden from Obsidian and Finder, so anything inside it is lost.
- **The vault root is the unattributed tier.** Anything with no known repo goes there, flat.
  The root is also the browse surface, so an unrouted note stays visible rather than
  disappearing into a folder nobody opens.
- **`needs-filing.md` is not a topic.** The filer writes raw, unprocessed text there itself when
  the Claude call fails (out of tokens, network down). Never route a tidbit into it, never match
  against it, and leave its contents alone.

## Routing

- **Known repo** — file into `<repo>/`, creating the directory if it doesn't exist.
- **Unknown repo** — file at the vault root.

Route on evidence, never on inference. A note in the wrong directory is lost silently; a note at
the root is merely unfiled, and unfiled is findable. When unsure, the root is the correct answer.

What counts as evidence depends on the transport:

- **`/tidbit` in Claude Code** — the repo is known exactly, from the git toplevel. No inference
  needed.
- **Voice memo** — only the words in the transcript. If the speaker names a project, repo, or
  subject that clearly matches an existing directory, use it. Otherwise the root. Do not guess
  from timing, recency, ordering, or vibes.

## Topic matching

Match **within the target directory only** — never across the whole vault. A tidbit routed to
`ingest-pipeline/` is matched against the files in `ingest-pipeline/`, and nothing else.

Look at the existing filenames and H1 headers there. If the new tidbit clearly relates to one,
append to it. Otherwise create a new file. Default to appending when reasonably related — don't
fragment near-duplicate topics into separate files.

While you are reading those existing notes, leave them as they are. A note that doesn't follow
this spec may well have been edited by hand on purpose — don't reformat it, reword it, or
otherwise "fix" it. Only the entry you are adding has to follow the spec.

## File format

One file per topic, kebab-case, e.g. `fine-tuning-efficiency.md`.

A **new file** gets a single H1 header in Title Case (the filename stays kebab-case). Capitalise
each significant word — not sentence case:

```markdown
# Fine Tuning Efficiency
```

**Each entry** is an H2 dated block appended to the bottom of the file:

```markdown
## 2026-08-03 14:32
**Working on:** training the v3 fine-tune run
**Tidbit:** could batch the tokenizer preprocessing step instead of per-sample; likely cuts prep time meaningfully. See [[tokenizer-pipeline]].
```

The H2 timestamp is `YYYY-MM-DD HH:MM`.

Keep it to a few lines. Add an extra line only if something specific genuinely adds value (a
caveat, a link, a number) — otherwise stop at "Working on" + "Tidbit".

### `**Working on:**`

Records the task in hand, which the directory can't capture — the directory says which repo, this
says what you were doing in it.

**Omit the line entirely when the source is a voice memo and the speaker didn't say what they were
doing.** Don't invent one. A fabricated "working on" is worse than an absent one.

### Wikilinks

Obsidian-style `[[wikilinks]]` to other tidbit files are welcome when a note genuinely relates to
another topic. Obsidian resolves links vault-wide, so a link works across directories without
qualification.
