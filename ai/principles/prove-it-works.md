# Prove it works

Source: pstack-claude plugins/pstack/skills/principle-prove-it-works/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: Check the real artifact before you say that you finished a task. Do not infer from a proxy, a self-report, or "it compiles".

## Rules

- Run the feature. Read the actual value. Read the actual diff.
- Check a process directly. Do not infer it from derived state such as a file time.
- When a check fails, doubt the way you observed before you doubt the system.
- Before you say "merged", "sent", or "started", read the real state and the exit code. Output cut by "| tail -1" and your own echo prove nothing.
- Prove the process too. A right result can come from a broken process. For each fact you used, name the record it came from. Make sure that it is the record that the project rules point to.
- Red is a colour, not a measurement. A failing test proves the test only if the failure is the mismatch you predicted. An ImportError, an empty list, and a real mismatch all print red.
- Quote the assertion diff (for example "Extra items in the right set"). Do not quote only "assert a == b".
- A probe must use behavior that only the new artifact has. A same-SHA restart can let old code report the new SHA.
- Script the check when you can. A script gives output that a reviewer can run again.
- Keep the output visible to the human. Commit it only for large work that needs an audit trail.

## When it applies

- After a task, before you say "done".
- When you write a handoff or read one: check its claims against the repo.
