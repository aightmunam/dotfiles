# Python performance and concurrency

Read the project's Python version, implementation, concurrency runtime, and worker configuration.
Check supported APIs against that version before recommending them.
Keep synchronous bounded code when concurrency has no workload benefit.

## Execution and ownership

Distinguish asyncio tasks, OS threads, worker processes, and external workers.
Choose synchronization for the actors that share the state.
An `asyncio.Lock` coordinates tasks on one event loop. It does not coordinate threads or worker processes.
Do not use the GIL as the atomic boundary for a business invariant.
Trace read-await-write sequences and shared mutable objects across task boundaries.

In SQLAlchemy code, check Session ownership per thread and AsyncSession ownership per concurrent task.
When operations need one atomic transaction, serialize their access to that transaction's session.
Do not split a required transaction across independent sessions to gain concurrency.
Inspect the actual database client's ownership and checkout rules.

## Scheduling and capacity

Check blocking database, HTTP, filesystem, logging, serialization, and CPU work inside async paths.
Inspect the actual calls rather than the enclosing `async def`.
Distinguish preventing event-loop blocking from gaining CPU parallelism.
For CPU work, check GIL behavior, native extensions, and the actual build before selecting threads or processes.
Account for process startup, serialization, and resource ownership costs.

Bound task creation as well as active operations.
A semaphore inside each task does not bound tasks already created by `gather`.
Task groups also need an admission bound for large inputs.
In asyncio code, a positive `Queue.maxsize` can bound queued items. The default does not.
Account for limits and pools across all worker processes.
Check whether one large request can monopolize shared slots.

## Failure and shutdown

Choose a child-task scope that matches the required error policy.
Use TaskGroup when its version support and sibling-failure behavior match that policy.
Check `gather` failure separately from parent cancellation.
By default, `gather` propagates the first exception without cancelling the other awaitables.
Own remaining tasks until they finish or stop.
Use `try/finally` for cleanup. Propagate `CancelledError` after cleanup when caught.
Distinguish a timeout request, actual cancellation, and cleanup completion.

Cancelling an await does not prove that an offloaded thread stops.
Define cooperative stopping or bounded completion for running executor work.
Check nested waits on the same executor for deadlock.
Define shutdown admission, queued-work handling, and running-task completion.

## Verification

Use the repository's test runner and async test setup.
Use `asyncio.Event`, `threading.Event`, or barriers for the relevant actor model.
Use fake clocks or injected time where the test depends on time.
Do not use arbitrary sleeps as proof of ordering.
Test task failure, parent cancellation, stalled I/O, pool exhaustion, and cleanup.
Count pending tasks and inspect independent event-loop progress where those risks apply.
Use real database concurrency tests for database invariants. A Python lock test cannot prove cross-process safety.
Separate Python allocation evidence from process memory and native allocation evidence.
Use `tracemalloc` for Python allocation traces when relevant.
