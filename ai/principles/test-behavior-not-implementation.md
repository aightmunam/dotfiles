# Test behavior, not implementation

Source: pstack-claude plugins/pstack/skills/principle-test-behavior-not-implementation/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: A test claims what the code does for its users. Assert only what those users can see.

## Rules

- Behavior is what a caller sees. It includes return values, errors, and state they can read back.
- It also includes effects on other systems: a request sent, a row written, a message emitted.
- Implementation is what they cannot see. It includes private helpers, call order, and intermediate data.
- It also includes which collaborator did the work.
- Judge each test with two edits.
- Edit 1: break the behavior. Return a wrong value, skip an effect, or do it twice. If the test still passes, it proves nothing.
- Common causes: an assertion looser than the contract, and an expected value that the code under test computed.
- Others: a copied constant, and an assertion on data that the test built.
- Edit 2: change the internals and keep every result. If the test fails, it depends on the implementation. Rewrite or delete it.
- Drive the code through the interface users use, with a concrete input. Take the expected value from the requirement. Do not take it from a run.
- A "never called" assertion is behavior if the contract says so. Pair it with a case where the call happens.
- The payload that a mocked external service gets is behavior. A call to an internal helper is not.
- The error type that callers branch on is the contract. The exact message is not.
- A constant is behavior only if it is a promise to users, such as a documented default.
- In pytest, prefer the HTTP client and a real test database over patching internals.

## When it applies

- You write, change, or keep a test.
