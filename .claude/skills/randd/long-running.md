# Long-running work — detached jobs, monitoring, resumption

Read this when any single execution in an avenue is expected to exceed ~15 minutes or
needs scarce/remote hardware (a GPU, a training box). Below that, just run it inside
the chunk and wait.

The organizing rule: **the handoff is written before the job starts.** Sessions
compact, teammates get shut down, instances die. A job is only as durable as the
written state that lets a fresh agent re-attach to it — so that state exists before
the job does, not after.

## Before launch: the brief carries the handoff

The planner writes two sections into `experiments/NNN-slug/brief.md` *before*
launching:

**§ Execution**

- Exact launch command, final form, ready to copy.
- Where it runs: host, worktree path, env vars, hardware.
- Expected duration, and what "healthy" looks like early (first log lines, resource
  allocated, first checkpoint written).
- Log and artifact paths — under `experiments/NNN-slug/artifacts/` unless the repo has
  its own run-directory convention; prefer the repo's.
- Stop conditions: **done-when** (what marks completion) and **kill-if** (divergence,
  error storm, budget exceeded) — explicit enough that a monitor can check them
  without judgment.
- Resume recipe: the exact command to relaunch from the latest checkpoint/state.

**§ Analysis plan**

- What will be computed from the outputs when the job ends, and the decision rule
  ("ship if X > Y on Z"). A fresh planner must be able to close out the experiment
  from this section alone, without the original planner's context.

## Launch

Prefer the repo's native conventions when they exist (run directories, launch
scripts, log layouts) — a repo that already trains models has better mechanics than
this generic pattern. Otherwise, from the worktree:

```bash
git rev-parse HEAD > <artifacts>/base_sha.txt      # what the code actually was
# write the exact command to <artifacts>/cmd.txt — verbatim, never retyped later
setsid nohup <cmd> > <artifacts>/job-1.log 2>&1 &   # plain `nohup <cmd> &` where setsid doesn't exist (macOS)
echo $! > <artifacts>/job-1.pid
```

Then **verify startup before declaring launched**: tail the first log lines, confirm
the resource is actually held (GPU allocated, port bound, first batch processed). A
job that dies in its first minute but was reported "launched" wastes the entire
monitoring cadence that follows.

Provenance is copied, never reconstructed: the command recorded in the brief and in
`cmd.txt` is the one that ran, and `base_sha.txt` records what the worktree actually
contained — note explicitly if the tree was dirty at launch.

## Register, then go quiet

Report the launch to the orchestrator, which records the in-flight row in `ledger.md`
(row schema: the format spec) and commits docs. From that point the job's identity
lives in the ledger, not in anyone's context. The planner may end its turn or be shut
down. A worktree hosting a live job is never cleaned — its path is in the row.

## Monitoring

The orchestrator dispatches `randd-monitor` against the in-flight row at sensible
intervals — scale the cadence to the job; a 14-hour training doesn't need 5-minute
checks — or when the user asks. The monitor is read-only: it reports
RUNNING / DONE / FAILED / STUCK / ALERT / UNKNOWN with evidence and a progress
snapshot; it never kills, restarts, or edits. Acting on an ALERT — killing a diverged
run, relaunching — is an orchestrator decision executed by a planner or fresh agent,
and any kill-or-continue call *outside* the written kill-if conditions goes to the
user.

Mid-run narration (watcher notes, provisional readings) belongs in `results.md`
§ `## Log` — the section that is deleted at close-out — or nowhere.

## Completion, crash, resume

- **Done:** the same or a fresh planner executes § Analysis plan, then the normal
  close-out checklist. The in-flight row is removed in the same change.
- **Crashed / instance died:** relaunch per the resume recipe. A resume opens a new
  run segment in `results.md` — date, host, exact command, base commit — so numbers
  stay attributable to the code and state that produced them.
- **Killed on purpose:** record why in `results.md` (a kill is a result), remove the
  row, close out normally.
