# Model the domain

Source: pstack-claude plugins/pstack/skills/principle-model-the-domain/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: Put the real domain in a data structure. Do not scatter it over conditionals.

## Rules

- A fitting structure makes invalid states impossible and cuts branches. It is cheap to choose when you write the code. It is costly to recover later.
- Use a state machine (an Enum plus a table of allowed moves) instead of loose booleans and status strings.
- Use a typed model (Pydantic, dataclass, or SQLAlchemy model) instead of loose parameters or a repeated dict shape.
- Use a dict, a registry, or a tagged union instead of branches spread over files.
- Use a command or event model instead of ad hoc state changes.
- Organize a module around one body of domain knowledge. Do not organize it as load, validate, transform, save. Order of execution is not ownership.
- Use a queue, an index, a tree, or a normal-form table when the access pattern needs it.
- If no structure fits, ask what the code must never allow and how code reads the data. Then find the structure that encodes it.
- Do not force an abstraction. Keep plain code if it is clear, local, and unlikely to grow.
- Doubt an abstraction that adds indirection and removes no branch, no copied rule, and no invalid state.

## Signs you skipped it

- A feature adds one more branch to an if/else chain.
- A second boolean must stay in sync with the first.
- Modules named for phases repeat the same domain rule.

## When it applies

- You write stateful logic, or you see many branches or a repeated shape assumption.
