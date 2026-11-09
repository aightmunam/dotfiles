# Shared state and progress

## Identify the atomic boundary

Name each invariant, its state, and every actor that can change it.
Include overlapping requests, tasks, processes, retries, jobs, and other services.
Prefer removing unnecessary sharing before adding coordination.
Trace check-then-act, `read-modify-write`, duplicate claims, and stale reads.
Identify the point where one competing operation wins.

Check constraints, conditional updates, version checks, locks, and transaction isolation against the actual invariant.
Protect related state changes within the same required atomic boundary.
A transaction alone does not establish that its isolation level prevents the relevant anomaly.
Retry the complete transaction when the database requires that recovery.
Check side effects before retrying aborted work.

Test conservation and uniqueness, not only local field bounds.
For inventory, nonnegative stored stock alone does not prove that accepted reservations reconcile with the stock reduction.

## Check progress

Trace lock and permit acquisition order across all callers.
Identify cycles, nested executor waits, and a task waiting on work that needs its own occupied resource.
Record hold time, wait bounds, and recovery after deadlock or conflict.
Keep unrelated slow work outside ownership scopes when consistency permits.
Check starvation and fairness under skewed workloads.

## Distributed ownership

Use this section only when ownership crosses process or service boundaries.
Check lease expiry, process pauses, network delays, clock assumptions, and delayed writes.
A prior lease check does not prove that a later write still has authority.
Check whether the protected storage rejects stale owners through fencing or another verified conditional-write mechanism.
Distinguish duplicate-work avoidance from correctness protection.
Prefer existing verified coordination mechanisms over a new lock protocol.

## Verification

Pause competing actors at the read or claim boundary.
Release both actors and check the committed invariant.
Repeat across worker processes when they share state.
Inject conflict, rollback, duplicate delivery, restart, and stale-owner writes when applicable.
Keep external effects and durable state consistent across those failures.
