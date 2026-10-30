# Never block on the human

Source: pstack-claude plugins/pstack/skills/principle-never-block-on-the-human/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa (reversible half only)

Key sentence: Reversible work inside a worktree proceeds without a question.

## Rules

- The human supervises later. Make a reasonable decision, do the work, and show the result.
- Do not ask "should I do X?" on reversible work. Do X and say why.
- Reversible work includes edits to code and notes, new files in the worktree, and splits of tasks.
- Always get the user's OK first for these actions:
  - Merges.
  - Pushes.
  - Prod actions.
  - Alembic upgrades and downgrades.
  - DB writes.
- Product direction comes from the human. Execution does not wait for the human.
- The brainstorm skill keeps its hard gate. It asks before it plans.
- When you notice a problem, note it and fix it in the next round.

## When it applies

- You want to ask for permission on a step that you can undo.
- Do not use this file to skip the confirm list above.
