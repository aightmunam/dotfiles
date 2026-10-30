# Minimize reader load

Source: pstack-claude plugins/pstack/skills/principle-minimize-reader-load/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: Code is hard when the reader must trace many layers or hold much hidden state. Cut both.

## Rules

- Track two axes. Layers to trace: the steps between a question and its answer. State to hold: the mutable context the reader must remember.
- The axes are independent. A flat module with 50 globals is as hard as a six-layer adapter stack.
- Collapse layers that cost more than they save. Examples: a wrapper with one caller, a repository class with no second implementation, an adapter nobody asked for. Inline them.
- A layer that repeats the same methods and arguments as the layer below adds load and gives no compression. Remove it.
- Prefer boundaries that hide a real decision. A broad interface that hides little makes the reader learn both sides.
- Shrink state scope. Prefer returns over mutation, locals over attributes, attributes over module state, and module state over globals. Derive a value. Do not keep a second copy in sync.
- State an invariant once at the boundary. Do not repeat it in each consumer.
- Before you add a layer or a piece of state, ask if it removes at least as much load elsewhere.

## The test

Can a new reader say "where does X come from?" and "what can change X?" in 30 seconds? If not, cut layers or state.

## When it applies

- You review or write code that is hard to trace.
