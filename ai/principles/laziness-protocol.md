# Laziness protocol

Source: pstack-claude plugins/pstack/skills/principle-laziness-protocol/SKILL.md and plugins/pstack/skills/principle-subtract-before-you-add/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: Make the smallest change that solves the problem. Remove before you add.

## Rules

- Consolidate decisions. Do not repeat one choice in many places. Keep one source of truth and pass the result as a simple value.
- Minimize the diff. Fewer lines are better than elegant boilerplate.
- Remove first. Remove dead code, redundant validators, and stub references before you build on the base.
- Cut before you polish. Reach the minimum, then improve quality.
- Design for the use that you see. Do not design for edge cases that no one met.
- Add no validator, parser, or guard that the spec does not need.
- If a reference or a file has no new content, remove it. Do not leave a stub.
- Leave the design a little simpler than you found it, with the same or a smaller surface.
- Do not add an abstraction, a layer, or a flag that only one caller uses.

## When it applies

- You refactor, size a diff, or sequence an addition or a rewrite.
- You want to add a layer, a wrapper, or a new parameter.
