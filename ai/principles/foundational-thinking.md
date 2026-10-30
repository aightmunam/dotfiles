# Foundational thinking

Source: pstack-claude plugins/pstack/skills/principle-foundational-thinking/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: Get the data structures right before you write logic. Then the code that uses them is obvious.

## Rules

- Define the core types first. Trace each way the code reads them. Choose structures that fit the main paths.
- For a FastAPI and SQLAlchemy service, this means the Pydantic models, the table columns, and the constraints. Decide them before the service code.
- Remove duplication in structure, not in every line. Three similar statements are better than an early abstraction.
- Prefer explicit code to clever code.
- Concurrency question: before two actors share state, ask what happens if one changes it while the other reads it. If the answer is not "nothing", isolate the state. Examples: two workers on one row, two requests on one cache key.
- Scaffold first. If a thing helps every later phase, do it first. Test setup, lint, CI, and shared types are scaffold.
- Order work for option value: setup before features, tests before fixes.
- Keep commits small and single-purpose.
- Each increment adds one clear abstraction or deepens one. Do not spread a new capability over many callers.
- Remove dead code before you lay a foundation.

## When it applies

- You pick core types, tables, or module boundaries.
- You order the phases of a plan.
