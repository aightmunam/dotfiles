# Make operations idempotent

Source: pstack-claude plugins/pstack/skills/principle-make-operations-idempotent/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: Each operation must reach the same end state however many times it runs and wherever the last run stopped.

## Rules

- For each operation that changes state, ask two questions. What happens if it runs twice? What happens if the last run crashed halfway?
- Derive each step from the state that exists. Read the state, compare it with the goal, and apply only the difference.
- Examples: INSERT ... ON CONFLICT DO NOTHING or DO UPDATE, a unique constraint, "UPDATE ... WHERE value is not the goal", and an idempotency key on an API call.
- A backfill or data fix must be safe to run again on the rows it already changed.
- A lock, a temp file, a half-written row, or a claimed job must be seen as stale by the next run. Judge staleness by evidence that is true wherever the last run stopped.
- Write to a temporary path and rename it into place. Compare artifacts by content, not by creation order.
- Run a batch in transactions that you can repeat. Log which batch finished.

## The test

1. Run it twice in a row. What changes?
2. Crash it at each possible point. What does the next run do?
3. Does a repeat reach the same end state?

If an answer is "it depends on state that the last run left", add a reconciliation step.

## When it applies

- A command, a task, a data operation, or a deploy step can run again after a crash or a retry.
