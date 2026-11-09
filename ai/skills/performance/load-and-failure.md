# Load and failure

## Deadlines and retries

Trace the complete operation budget through admission, queue waits, connection setup, calls, retries, and cleanup.
Check what each timeout actually covers and what work continues after expiry.
Choose one coordinated retry policy for the relevant call chain.
Record every retry owner, including callers, application wrappers, SDKs, transports, and queue redelivery.
Include explicit retry loops and policies inside called clients as separate owners.
Trace each retrying call to its callee before reporting the total.
Fill the owner table below before calculating the bound.
Convert retry counts to total attempts before calculating the possible combined demand.
For nested retry layers, multiply their total attempt bounds unless a shared budget reduces them.
For example, three layers with three total attempts each permit up to 27 deepest-layer attempts.
Label that figure as a possible work bound, not observed traffic.

Define retryable failures, backoff, jitter, attempt bounds, and the remaining deadline.
Check whether a timeout can follow successful remote effects.
Use a stable operation identity and atomic deduplication where duplicate execution would violate the contract.
Define identity scope, payload conflicts, retention, and replay behavior.

## Retry budget template

```
| Retry owner | Source | Calls | Total attempts per invocation |
|---|---|---|---|
| <loop, client, transport, or redelivery owner> | <path:line or policy source> | <next owner> | <initial attempt plus retries, or unknown> |
Combined bound: <product along the nested call chain, reduced only by a verified shared budget>.
Unknown layers: <owner and evidence needed, or none>.
```

Give every retry owner its own row, including separate owners within the same service.
Keep unknown layers explicit. Do not claim a closed numeric bound while a nested layer remains unknown.

## Admission and recovery

Bound active work, pending work, and queue age.
State whether admission blocks, rejects, expires, or degrades work when capacity is full.
Distinguish rate limits from concurrency limits.
Check per-tenant and per-dependency isolation when they share capacity.
Include slow consumers, hot keys, and uneven request sizes.
Check recovery and backlog drain after overload, not only peak throughput.
Define handling for expired or repeatedly failing queued work.

## Cache behavior

Name freshness requirements, key scope, size bounds, eviction, and invalidation ownership.
Check cold start, cache loss, concurrent misses, and simultaneous refresh.
Consider coalescing repeated refresh work where it preserves the contract.
Check whether a fallback to the origin can overload that origin.
Do not authorize a durable state change from a stale cache value alone.
Check format compatibility during mixed-version deployments.

## Durable handoff

Use this section when a database change requires a separate message or external effect.
Trace crashes before commit, after commit, before send, and after remote acceptance.
When the contract requires atomic publication intent, consider a transactional outbox or an existing durable handoff.
Define relay recovery, duplicate handling, ordering scope, and acknowledgement boundaries.
Do not infer end-to-end exactly-once effects from a queue's delivery guarantee.

## Evidence

Check latency distributions and separate successful work from errors, timeouts, and rejections.
Record queue age, resource wait time, retry attempts, saturation, and cleanup completion.
Test cold caches, slow dependencies, uneven workloads, cancellation, and overload recovery when applicable.
Use controlled events and injected failures to check duplicate and crash behavior.
Keep hardware cache contention and other platform tuning conditional on profile evidence.
