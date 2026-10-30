# Separate before serializing shared state

Source: pstack-claude plugins/pstack/skills/principle-separate-before-serializing-shared-state/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: When actors might write the same state, first remove the sharing. Serialize only when one shared writer is a real invariant.

## Rules

- Instructions and conventions are not concurrency control.
- Step 1. List the shared mutable state: rows two workers update, files two agents edit, branches two agents push to, a cache key two requests write.
- Step 2. Default: remove the shared write target. Ask if the actors need one object or only publish separate facts. Give each actor its own file, row, key, or branch. Merge at the read side.
- Two workers that write their own last-run field into one JSON file still share a write. Two files, one for each worker, do not.
- For parallel subagents, give each a disjoint set of files. The plan lists the set.
- Step 3. Serialize only if one write target is a real invariant. Use a structure: a row lock (SELECT ... FOR UPDATE), a unique constraint, an advisory lock, a single-writer task, or compare-and-swap with a version column.
- Treat "we need a lock" as a design smell. Check it before you accept it.
- Postgres rows: if many requests update one counter row, ask if they can insert separate rows and sum them.

## When it applies

- A plan runs parallel workers or subagents.
- A change adds code that writes to a row, a file, or a key that other code writes.
