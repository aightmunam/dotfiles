---
name: performance
description: Use when assessing performance or concurrency risks in a design, plan, or code change. Use when checking latency, throughput, memory, resource use, or a speed claim.
---

# Performance

## Definitions

- **Assessment:** a trace of work and resource use, with risks, decisions, and checks. It does not establish a speedup.
- **Measurement:** a comparison from real runs. It follows `measurement.md`, including its evidence rules and report contract.
- **Workload:** input sizes, request frequency, concurrency, and completion requirements, with sources or explicit gaps.
- **Resource:** finite capacity that work uses or holds, including connections, locks, workers, memory, and I/O.
- **Invariant:** a condition that must remain true when operations overlap, fail, or run again.

## The Loop

1. **Choose the mode.** Use assessment for design choices or code risks. Use measurement when the request needs measured results.
2. **Separate evidence from guesses.** Find what limits a measured number before you trust it. Rule out skipped or different work.
   Read ~/.agents/principles/explain-the-number.md before this step, as a read of that file alone.
3. **Assess.** Read `assessment.md`. Trace the changed path through completion. Produce its assessment report. Keep the assessment read-only.
4. **Measure.** For measurement requests, read `measurement.md` and follow its full loop instead of step 3. Keep its report labels.
5. **Return.** Give decisions and checks to the caller. When another skill owns the output format, use that format.
   For direct reports, keep template labels as written, including `Principles applied:`.

## Rules That Shape the Assessment

- **Trace causes.** Show where work grows or resources stay occupied. Rank risks by workload, impact, and evidence.
- **Keep the contract.** Preserve outputs, ordering, consistency, error behavior, and cancellation when comparing choices.
- **Protect invariants.** Trace competing actors and the atomic boundary that protects shared state before increasing concurrency.
- **State uncertainty.** Separate code facts, workload assumptions, and unmeasured risks. Name evidence that would change the decision.
- **Use the simplest sufficient design.** Lazy evaluation, async execution, concurrency, caches, and indexes need a workload reason.
- **Check interactions.** A local saving can increase resource hold time, contention, pending work, or failure cost elsewhere.
- **Keep one source.** Planning and review use this assessment. They do not keep separate performance checklists.

## Assessment Report Template

```
Mode: assessment. Scope: <changed path and affected callers>.
Workload: <sourced sizes, frequency, concurrency, completion contract, and gaps>.
Invariants: <required conditions, competing actors, atomic boundaries, or an inapplicable reason>.
Retry budget: <the owner table from load-and-failure.md, or an inapplicable reason>.
| Path and evidence | Work or resource cost | Risk or acceptable bound | Decision | Verification |
|---|---|---|---|---|
| <path:line or spec source> | <growth, occupancy, memory, I/O, or scheduling> | <condition and impact> | <choice and trade-off> | <test or probe with expected result> |
Unresolved evidence: <facts to discover, or none>.
Keep: <necessary work and existing bounds worth retaining>.
Principles applied: explain-the-number -> <how facts and hypotheses stayed separate>
```

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- A design assessment ends with an empty benchmark report. Go back to step 1.
- An assessment calls a hypothesis a measured limiter or speedup. Go back to step 2.
- A resource is eventually closed, but its occupancy is not traced. Go back to step 3.
- A retry bound omits a caller, wrapper, SDK, transport, or redelivery layer. Go back to step 3.
- A proposal changes semantics to save work. Go back to step 3.
- A choice says async, lazy, indexed, or parallel without a causal trace. Go back to step 3.
- A measured claim skips the existing measurement loop. Go back to step 4.
