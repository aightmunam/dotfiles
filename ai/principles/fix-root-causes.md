# Fix root causes

Source: pstack-claude plugins/pstack/skills/principle-fix-root-causes/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: Fix the fault, not the place where it showed. The root cause is the first place the system did something wrong.

## Rules

- Reproduce first. Use a failing pytest case if you can.
- Ask "why" until the answer is a wrong decision in the code. Stop when the answer is only a result of an earlier step.
- When you are stuck, add instrumentation. Read the real error and the real state. Do not guess.
- Ask if the state that caused the symptom is legitimate. If the system can be in that state, the code that broke on it is the root cause. Handle the state there.
- If the state must never exist, a guard where it broke hides the bug. Find what made the state.
- Guards, retries, swallowed exceptions, clamped values, and dropped rows are the usual ways to hide a bug.
- If a failure shows only after a restart, suspect saved state first: config, caches, lock files, and rows in the database.
- Look for the pattern. Find every place with the same fault and fix all of them.
- If a workaround needs a long comment, the code is wrong. Fix the code.
- If the key fact took a long search, propose a cheap log or metric that shows it at first look.

## When it applies

- You debug a failure, a flaky test, or an incident.
- You review a fix that adds a guard, a retry, or a try/except.
