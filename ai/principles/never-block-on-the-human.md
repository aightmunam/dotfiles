# Never block on the human

Source: pstack-claude plugins/pstack/skills/principle-never-block-on-the-human/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa (reversible half only)

Key sentence: Only a merge to main/master and a production write need the user's OK.

## Rules

- The human supervises later. Make a reasonable decision, do the work, and show the result.
- Do not ask "should I do X?" on reversible work. Do X and say why.
- Reversible work includes edits to code and notes, new files in the worktree, and splits of tasks.
- Get the user's OK first for these two actions only:
  - A merge or push to main/master. It deploys to production. List the exact commits.
  - Any write to production: DB rows, Alembic migrations, deploys, Salesforce org data.
- Proceed without a question on everything else:
  - Commits, and pushes to feature branches.
  - Writes to local, test and staging environments, including Alembic.
  - Reads anywhere, prod included: DB queries, logs, configs.
- Product direction comes from the human. Execution does not wait for the human.
- The brainstorm skill keeps its hard gate. It asks before it plans.
- When you notice a problem, note it and fix it in the next round.

## When it applies

- You want to ask for permission on a step that you can undo.
- Do not use this file to skip the two OK actions above.
