# Encode lessons in structure

Source: pstack-claude plugins/pstack/skills/principle-encode-lessons-in-structure/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: When you write the same instruction a second time, encode it as a lint, a check, or a script. Do not write more text.

## Rules

- A repeated correction is a missing guard. The text instruction is the symptom.
- Choose the structure: a ruff rule, a mypy setting, a pytest test, a pre-commit hook, a CI step, a database constraint, or a script.
- If a structure can enforce the rule, use only the structure. Do not add a text rule beside it.
- If the lesson needs judgment, a structure cannot hold it. Make the instruction more visible. Add one example of the failure.
- Test the new guard. Break the rule on purpose and check that the guard fails.

## When it applies

- You see the same review comment, mistake, or user correction twice.
- You are about to add a sentence to an instruction file to stop a mistake.
