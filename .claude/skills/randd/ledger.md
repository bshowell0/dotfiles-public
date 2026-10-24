# The randd ledger — format spec

Shared by every randd role. The ledger is the run's memory: teammates don't survive
`/resume` and contexts get compacted, so anything not written here is lost. Write as
you go, not at the end.

## Two modes, one layout

`<root>` below is one of:

- **Committed mode** — `randd/` at the repo root, committed to `main` and pushed. For
  fork/research repos where the user has confirmed free-reign committing. All git
  duties in this spec apply.
- **Ephemeral mode** — `.randd/`, gitignored. No git operations on the ledger; it dies
  with the run. For repos where committing research isn't appropriate.

Mode is detected, never inferred: `randd/CLAUDE.md` exists → committed (read it — it
records the policy); `.randd/` exists → ephemeral; neither → the orchestrator asks the
user once and scaffolds. In committed mode, **git history is the archive**: deleted
prose is recoverable, so delete freely — the doc classes below say when.

```
<root>/
  CLAUDE.md      committed mode only — auto-loads for any agent touching the dir
  README.md      what this directory is, for a human who finds it
  .gitignore     committed mode only: experiments/**/artifacts/, *.pid, *.log, *.out
  ledger.md      the index — metric, constraints, priorities, in-flight jobs, cycle log
  gotchas.md     numbered operational traps, rule-first
  avenues/NNN-slug.md        one per proposed avenue
  experiments/NNN-slug/      one per avenue actually attempted
    brief.md     what the planner decided and how it split the work — written first
    results.md   what happened, in prose
    metrics.json the numbers, machine-readable
    artifacts/   job logs, pids, launch scripts (never committed)
```

`NNN` is a zero-padded counter, allocated in order across the ledger's whole lifetime
(all runs in this repo) and never reused. An experiment and its git branch
(`exp/NNN-slug`) take the number of the avenue they came from — branch name, avenue
file, and experiment dir are one namespace.

## Doc classes

Every file has a class that says how it may be edited:

- **REFERENCE** (`README.md`, `CLAUDE.md`, `gotchas.md`) — rewrite in place; a
  correction *replaces* the wrong text, never a dated "Update:" layer. Gotcha numbers
  are stable once assigned — other files cite them; never renumber.
- **STATE** (`ledger.md`) — what's true right now. The priorities and in-flight tables
  are current-only. Cycle-log entries older than ~3 cycles collapse to their
  **Learned** line.
- **PLAN → RECORD** (`avenues/NNN`) — live while proposed/queued/in progress; frozen
  at close. The only edit to a closed avenue is a supersession banner at the **top**.
- **RECORD** (`brief.md`, `results.md`) — `brief.md` is written before implementation
  and not rewritten after (a surprising result must be interpretable against what was
  actually planned). `results.md` freezes at close-out, except its `## Log` section,
  which is *deleted* then — see below.

All lifecycle rules are **same-change** rules: "clean it up later" demonstrably never
happens. The cleanup lands in the same edit (and, in committed mode, the same commit)
as the event that triggers it.

## Who writes what, who commits what

| File | Content writer | Committer (committed mode) |
|---|---|---|
| `avenues/`, research half of `ledger.md` | researcher | orchestrator |
| `experiments/NNN/` | planner for avenue NNN | orchestrator |
| `gotchas.md`, priorities + in-flight tables | orchestrator | orchestrator |
| source, on `exp/NNN-slug` | implementors build it; planner commits | planner |

The orchestrator is the **sole committer of docs** (one committer = no index races);
each avenue's files have a **single content writer** (no content conflicts). Planners
and the researcher write docs into the **primary checkout**, never a worktree's stale
copy. Implementors never run git write operations. No commit ever mixes `<root>/**`
with source paths — that separation is what makes promotion (source-only diffs) and
sync-back (conflict-free merges) mechanical.

## Reading lists (load exactly this, not the whole tree)

| Task | Read |
|---|---|
| Pick up a dead or resumed run | `ledger.md` |
| Ground a research cycle | `ledger.md` + `gotchas.md` (+ the analyzed experiment's files, later cycles) |
| Plan avenue NNN | `ledger.md` + `gotchas.md` + `avenues/NNN-slug.md` |
| Analyze a finished experiment | its `brief.md` + `metrics.json` + `results.md` |
| Monitor a job | its in-flight row, nothing else |

If a list outgrows ~10k tokens of reading, split the target doc — don't grow the list.

## `README.md`

Written once at scaffold. Verbatim is fine:

> This directory is the working memory of `randd` R&D runs — an agent team's ranked
> research avenues, experiment briefs, and measured results. Nothing here is required
> to build or run this project. `ledger.md` is the index and the place to start.

## `CLAUDE.md` (committed mode)

Scaffolded from this template, bracketed knobs filled in with the user. It is the
durable record of the repo's mode and git policy, auto-loading for any agent that
touches the directory:

```markdown
# randd/ — R&D ledger (committed mode)

Working memory of `randd` R&D runs. Format spec and role duties:
`~/.claude/skills/randd/ledger.md`. Start at `ledger.md`.

## Git policy (this repo)

- **Doc paths:** [randd/**] — commits touching only these paths may land on `main`
  autonomously. Verify before every commit; never mix doc and source paths in one
  commit.
- **Source never reaches `main` autonomously.** It arrives only by sync from
  [upstream remote: upstream] after a human-merged PR [no upstream: by the human
  merging an exp branch].
- **`exp/NNN-slug`** (NNN = avenue number) is the autonomous namespace: branch,
  commit, push, and exp→exp merges without asking. Anything targeting any other
  branch asks the human. Default-deny.
- **`feat/<slug>`** promotion branches are rebuilt from [upstream]/main, source-only;
  the human opens PRs.
- Finished or dead exp branches: tag `archive/exp/NNN-slug`, then delete the branch.

## Sync rules

The priorities and in-flight tables in `ledger.md` are derived state — update the row
in the same change as the file it points to. Close-out checklist: format spec above.
```

## `ledger.md`

The index. Anyone picking up a dead run must be able to read only this file and know
where things stand — including how to re-attach to a still-running job.

```markdown
# R&D ledger — <one-line problem statement>

**Target metric:** <what "better" means, numerically, and how it's measured>
**Constraints:** <hard limits that disqualify an avenue>

## Current priorities (cycle N)

| # | Avenue | Evidence | Cost | Payoff | Status |
|---|--------|----------|------|--------|--------|
| 003 | <short name> | speculative | trivial (~20 min) | high | in progress |
| 001 | <short name> | proven | heavy (~6 GPU-h) | medium | queued |
| 004 | <short name> | emerging | moderate | medium | parked — run when <trigger> |
| 002 | <short name> | emerging | moderate | low | rejected — see avenues/002 |

## In flight

| Exp | Job | Where | Launched | ETA | Log | Check | Stop conditions | Resume | Worktree |
|-----|-----|-------|----------|-----|-----|-------|-----------------|--------|----------|
| 003 | train-v1 | <host> | <date> | ~14 h | <path> | `<exact command>` | <done-when / kill-if> | brief.md § Execution | <path> |

## Cycle log

### Cycle 1 — <date>
Brief: <what was asked>
Researched: <N avenues proposed, M disqualified>
Attempted: 001, 003
Result: <the headline numbers, including the ones that got worse>
Learned: <the thing that changed what to try next — this is the valuable line>
```

A row in either table is a **pointer, not an abstract** — ideally one sentence; the
avenue/experiment file owns the detail. Update rows in the same change as the files
they point to; a finished run still reading "in progress" is the failure mode.

The **Learned** line is the point of the whole file. A cycle that moved no metric but
ruled something out is a successful cycle; write down what it ruled out.

## `gotchas.md`

How measurement and operations lie *in this repo*: the warm cache, the shared box, the
flag that silently changes what's measured, the benchmark that means nothing on this
hardware. Rule-first: each entry is the actionable rule, one line of origin ("origin:
exp 003 — first run measured a cold cache"), and a link to the full story. Planners
and implementors flag candidate gotchas in their reports; the orchestrator writes
them; the researcher reads this file when grounding. This is the run's institutional
memory — in committed mode it is the artifact most worth keeping when a run ends.

## `avenues/NNN-slug.md`

One per proposed avenue, including disqualified ones — a rejected avenue is a record
that stops a later cycle from proposing it again.

```markdown
# NNN — <name>

**Status:** proposed | queued | in progress | done | rejected | parked | unverified
**Evidence:** proven | emerging | speculative
**Cost to test:** trivial | moderate | heavy — plus real units when estimable
  (wall-clock, GPU-hours, scarce hardware)
**Expected payoff:** low | medium | high
**Proposed:** cycle N

## Hypothesis
<what you think will happen and why — one paragraph, falsifiable>

## Evidence
- <claim> — "<direct quote from the source>" — <url> (primary | secondary | blog | forum)

## Applicability to this repo
<why it fits here specifically, referencing real files or constraints>

## Panel verdict
<disqualified with a concrete reason, or survived with the reservations raised>
```

**Every avenue carries a direct quote.** An avenue with no quote is a hunch — allowed,
but label it `speculative` and say the source is your own reasoning.

Three closed-ish statuses that are not the same; never merge them:

- **`rejected`** — killed on merit: already tried and failed per the ledger, violates
  a stated constraint, or the quote doesn't support the avenue.
- **`parked`** — viable but gated on something that doesn't exist yet (hardware, data,
  tooling). Must carry a one-line run-trigger: "run if/when …". Parked is
  parked-with-conditions, not abandoned — it costs one row and preserves the option.
- **`unverified`** — the panel couldn't reach a verdict because agents errored or
  rate-limited. An infrastructure failure, not a finding; it stays a live candidate.
  A round where everything came back unverified found nothing out — say exactly that.

## `experiments/NNN-slug/`

Created by the planner when an avenue is attempted.

**`brief.md`** — written *before* implementing: how the work was split, which chunks
went to which model and why, and what base the branch was cut from (`main`, or another
exp branch for a stacked avenue — the metrics then measure the stack; say so). Tag
every design decision made by fiat rather than derived from a source as
`[Arbitrary: <one-line rationale>]` — when a result surprises, the untagged silent
choice is the first suspect, and it is otherwise unrecoverable. For any long-running
chunk, brief.md also carries § Execution and § Analysis plan (see
`~/.claude/skills/randd/long-running.md`) — the handoff is written before the job
starts.

**`results.md`** — what happened, in prose: what was built, measured, surprising,
broken. Failures at full strength — a tidied-up failure gets retried next cycle. An
optional `## Log` section holds mid-run narration (watcher notes, provisional
readings); it is **deleted at close-out** — write it knowing it dies. Interim claims
later found wrong are deleted, not layered under corrections.

**`metrics.json`** — flat and machine-readable, so cycles compare without re-reading
prose. Measurements are a list — several metrics, checkpoints, or configs per
experiment are the norm:

```json
{
  "avenue": "007", "cycle": 2, "branch": "exp/007-slug", "base": "main @ <sha>",
  "measurements": [
    {"name": "throughput", "baseline": 1234.5, "result": 1490.1, "unit": "req/s",
     "direction": "higher-is-better", "n": 10,
     "protocol": "wrk 30s ×10, warm cache, same host",
     "config": {"threads": 8}}
  ],
  "notes": "single machine, no thermal control — treat <5% as noise"
}
```

`protocol` is what keeps numbers comparable across cycles — record *how*, not just
what. Record the baseline **as measured in this run, in this worktree** — never as
remembered from an earlier cycle or quoted from the ledger; machines and dependencies
drift, and a stale baseline is the easiest way to manufacture a result that isn't
there.

## Close-out checklist (same change, every item)

Flipping an avenue to done / rejected / superseded requires, in that same change:

1. Verdict into the avenue file: status + ≤5 lines (asked, found, decided).
2. `results.md` finalized; `## Log` deleted; retracted interim claims removed.
3. `metrics.json` written.
4. Priorities row updated — status *and* the pointer sentence.
5. In-flight row removed, if any.
6. New gotchas recorded in `gotchas.md`.
7. **Prose sweep**: grep the avenue number/slug *and the question it answered* across
   `<root>`; fix stale framing in prose, not just checkboxes — a hypothesis still
   reading "unknown", a plan still saying "the winner will…". A reader who stops
   mid-file must not get the pre-close framing.
8. Committed mode: branch dispatched — promotion recommended, or tagged
   `archive/exp/NNN-slug` and deleted — and the orchestrator commits the docs on
   `main` with a verdict-line message: `randd: 007 SHIP — +14% throughput`
   (`git log --oneline -- randd/` then reads as the chronological verdict log).
