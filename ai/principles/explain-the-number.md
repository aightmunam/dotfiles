# Explain the number

Source: pstack-claude plugins/pstack/skills/principle-explain-the-number/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: Before you trust, report, or act on a measured number, find what limits it. Rule out that it measured something else.

## Rules

- Write the decision before you run. Name the result that would change the decision. Name the noise floor.
- Stop when the spread between runs is larger than the effect.
- Ask "why not double?" Name the limit: a core, a lock, a connection pool, the disk, the network, or the load generator. Get it from a profile or from counters taken during the run.
- A guess from reading code is not a limit.
- List what else the number could measure. Rule out each one with evidence. Common causes: errors, cached or skipped work, and code that never ran. Others: a side left on default settings, noise, and a piece too small to matter end to end.
- For an API or a query, check status codes, row counts, and the query plan (EXPLAIN) during the run.
- Keep the run count, the spread, and the limit with the number.

## When it applies

- You measure speed, latency, memory, or throughput.
- You report a regression or a speedup.
- You did not apply it if the number has no run count, no spread, or no named limit.
