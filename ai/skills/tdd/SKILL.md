---
name: tdd
description: Use when you make one change test first and no plan exists. Use when the user asks for red-green, a failing test before the fix, or a test-first feature or bug fix. Use when `build` runs one slice of a plan.
---

# TDD

## Definitions

- **Seam:** the public interface where a test drives the code and reads the result. Examples are an HTTP route, a public function, and a CLI command. The user confirms each seam.
- **Domain fact:** a business value that a test assumes. Examples are a threshold, an inclusive or exclusive limit, rounding, and the amount that a rule uses. Each fact needs a source: the user, a ticket, a spec, or a line of code. Your reading of the user's words is not a source.
- **Red:** a test run that fails on an assertion with the mismatch that you predicted. An import error, a collection error, a fixture error, or a typo is not red.
- **Receipt:** one line, `Fail-first: <test id> expected <x> got <y>`. The test id is the pytest node id.
- **Gate:** no test, code change, or command comes before one of these. One: the user's yes. Two: `Assumed:` lines with a source for the seam and each fact that the test needs. Three: `Open:` lines and a stop. The answer starts with these lines.

## The Loop

1. **Read.** Read the code that the change touches, its tests, and the repo test command. Find the public interface. Write each domain fact with its source, or with "no source".
2. **Seams.** First, open each principle file below in its own read. Logic that can be a pure function goes in a pure function that the shell calls. Test it there. Read ~/.agents/principles/boundary-discipline.md before this step. A test asserts only what the users of the code can see. Read ~/.agents/principles/test-behavior-not-implementation.md before this step. Then propose the seams. Give each seam one line: what it catches and what it misses.
3. **Ask.** Use the question template. Ask which seam, and put the first concrete case in the recommended answer. A "yes" then confirms the seam and the facts in that case. Ask each fact that the case does not fix in a later message. The question message has no test, no code change, and no command. A request for all steps in one answer does not confirm a seam. When a user can answer, wait for the answer.
   - **No user** (a headless or delegated run): for each seam and fact, write `Assumed: <value> (source: <file:line or spec section>)`. Then continue. An existing test that drives the code is a source for its seam. If the seam or a fact that the first test needs has no source, stop before the first test. Report `Open: <question>`. "I interpret" or "I assume" with no source is a silent assumption. Never assume in silence.
4. **Red.** Write one test at a confirmed or sourced seam. Before the body, name the code change that makes it fail. Take the expected value from the requirement, as a literal. If the symbol does not exist, add the smallest stub: the signature and a wrong constant result. Then the run reaches the assertion. Run only that test. Get red, then write the receipt.
5. **Green.** Write the least code that makes the test pass. Run the test, then the other touched tests.
6. **Repeat.** Do steps 4 and 5 for the next case. One test per cycle. Leave the refactor to review. With no review step, put each refactor idea on a `Refactor:` line in the report.
7. **Commit.** Commit only a passing tree. The receipt goes in the plan slice when a plan exists. Otherwise it goes in the report. Never commit a red tree.
8. **Report.** Use the report template.

## Rules That Shape Tests

- **DB seams are normal tests.** A test that reads and writes the test database is not an integration test. At an external boundary, assert the row that the code wrote or the message that it sent. Do not mock the database when the repo has a test database fixture. If the repo has no fixture, propose one in step 3. The repo CLAUDE.md wins for calls to external services.
- **Mock only what you do not own.** Mock an external service, time, or randomness. The payload that a mocked external service gets is behavior. Never assert that a mock exists.
- **Two edits.** Break the behavior: the test must fail. Change the internals and keep each result: the test must pass.
- **Write the expected value as a literal.** Never take it from a run. Never compute it the way the code does.
- **A "never called" assertion has a pair.** Add a case where the call happens.
- **The error type is the contract.** Do not assert the exact message.
- **Delete code that you wrote before its test.** Write the test, then write the code again.

## Roles

Runs inline. When `build` runs you for a slice, the approved plan confirms the seams and the facts that it names. For a seam or a fact that the plan does not name, ask, or use the no-user rule in step 3.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- You are about to write a test, no user confirmed the seam, and no `Assumed:` line cites a source for it. Stop. Go back to step 3.
- A domain fact with no source and no `Open:` line, or a test that needs a fact on an `Open:` line. Go back to step 3.
- A mock of the database where a row assertion fits. Go back to step 4.
- The first run passes, or it fails with an import or collection error. Go back to step 4.
- More than one new test before green. Go back to step 4.
- An expected value that came from a run or from the code under test. Go back to step 4.
- Code that you wrote before its test. Delete it. Go back to step 4.
- A message to the user with no `Principles applied:` line, or a principle that you did not open. Go back to step 2.

## Question Template

```
<1 to 3 lines: the seams, each with what it catches and misses, and the facts with their sources>
**Decision:** <one question, worded so that yes accepts the recommendation>?
**Recommended:** <seam and first case, for example "POST /orders, subtotal 120.00 gives total 108.00">. <one reason>.
Principles applied: <name> -> <choice it changed>
```

## Report Template

```
Seams: <each confirmed seam>
Facts: <each fact> (source: <user, ticket, spec, or path:line>)
Assumed: <seam or fact> (source: <file:line or spec section>)     (no-user runs only)
Open: <question>     (one line per seam or fact with no source)
Fail-first: <test id> expected <x> got <y>     (one line per cycle)
Green: <command> -> <result>
Refactor: <idea>     (only when no review step follows)
Principles applied: <name> -> <choice it changed>
```
