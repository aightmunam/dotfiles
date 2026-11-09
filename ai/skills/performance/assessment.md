# Performance Assessment

## Establish the workload

Read the changed path, its callers, and applicable configuration.
Trace from entry through full consumption, serialization, delivery, and cleanup.
Record input sizes, frequency, concurrency, resource limits, and completion requirements.
Record correctness invariants and the actors that can change their state.
Use supplied or observed values. Mark missing values as unknown.
Separate worst-case growth from measured latency.

## Trace work and resources

Consider each dimension below. Record an inapplicable dimension with its reason.
Join related dimensions into one causal risk instead of repeating findings.

| Dimension | Questions to resolve |
|---|---|
| Work growth | What repeats per item, request, batch, or retry? Which nested loops multiply independent input sizes? Which bounds already suffice? |
| Data access | How many queries or remote calls run? What does each fetch, scan, sort, or transfer? What bounds batches and pages? |
| Access paths | Do predicates, joins, and ordering match existing indexes? What does the actual query plan show? What writes maintain indexes? |
| Resource lifetime | When is each resource acquired, first used, last needed, and released? What unrelated work occurs while it stays occupied? |
| Materialization | When does deferred work execute? Who consumes it? What does the consumer retain, copy, or cache until consumption ends? |
| Scheduling | What actually blocks a thread, event loop, or worker? Which operations can overlap without changing the contract? |
| Shared state | Which decisions span a read and a write? What atomic boundary protects each invariant across all competing actors? |
| Progress | What is the acquisition order for locks and permits? Can work deadlock or starve while resources remain available? |
| Capacity | What bounds active and pending work? Are limits per task, process, tenant, or service? What happens under overload? |
| Failure | What survives cancellation or failure? What is the total retry budget across every caller, wrapper, SDK, transport, and redelivery layer? |

For Python paths, read `python.md` before choosing execution and synchronization mechanisms.
For shared state or coordination, read `shared-state.md`.
For dependencies, queues, retries, or caches, read `load-and-failure.md`.
For isolated bounded computation, record why those branches do not apply.

Read resource implementations when a lifetime depends on them.
Distinguish a session object's lifetime, a transaction's lifetime, and a checked-out connection's lifetime.
Apply the same reasoning to cursors, files, sockets, locks, permits, and workers.
Check slow external calls, computation, and streaming inside resource ownership scopes.
Release resources before unrelated work when the contract permits it.
When consistency requires ownership, state the bound and its capacity cost.

## Compare choices

Trace where each choice moves work, memory, waiting, and resource ownership.
A generator can reduce allocation while retaining a cursor during slow consumption.
Materialization can release that cursor sooner while increasing memory.
Use bounded batches when they preserve the required consistency and order.
Check that batching does not change partial-failure behavior or delivery guarantees.

Inspect actual calls before choosing sync or async execution.
An async function can still block on synchronous I/O or CPU work.
Offloading work does not prove that cancellation stops its worker.
Bound parallel work and pending work by downstream capacity.
Keep required ordering and resource ownership explicit.

Check existing access paths before adding indexes.
Treat nested loops by their input bounds, not their syntax.
Preserve necessary work and adequate existing limits.
Choose a cache only with bounds, ownership, and a correctness policy.
Give each recommendation a causal trace and a trade-off.
Do not invent a dominant limiter or timing from code alone.

## Choose verification

Use deterministic checks for resource lifetime, work counts, bounds, and output equivalence when possible.
For ownership risks, pause unrelated slow work and check whether another consumer can acquire the scarce resource.
Exercise failure and cancellation, not only successful completion.
Control competing operations with events or barriers. Check the invariant after both operations finish.
For deferred work, consume the complete result before declaring the check complete.
For scheduling risks, check independent work while the slow operation waits.
For access-path risks, inspect the actual query plan with representative data.
Use realistic size and concurrency to check memory, queue growth, and resource occupancy.
Record latency distributions, resource wait times, errors, and recovery under overload.
Set expected results from requirements or observed baselines. Mark missing budgets as unknown.
Use `measurement.md` before reporting a measured improvement or regression.

## Return to the caller

In planning, assign each accepted decision and check to its owner phase.
In review, report only supported findings in the caller's finding format.
Keep open workload questions separate from established defects.
For a direct assessment, use the template in `SKILL.md`.
