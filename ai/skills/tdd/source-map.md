# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **poc:** mattpocock-skills `skills/engineering/tdd` (SKILL.md, tests.md, mocking.md).
- **sp:** superpowers `skills/test-driven-development` (SKILL.md, writing-good-tests.md).
- **receipt:** the old implement skill, `git show 1a7029b^:ai/skills/implement/SKILL.md`, step 1 and the hard rules.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 7 (DB-backed test seams), section 8.4 (tdd and build entries), section 8.7.
- **brief:** task 4.2 brief and the controller dispatch (receipt line format, red definition).
- **tbni:** `ai/principles/test-behavior-not-implementation.md`.
- **bd:** `ai/principles/boundary-discipline.md`.
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (the form bar).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Test only at seams that the user confirms. Propose each seam with what it catches and what it misses. | poc Seams. spec 8.4 tdd. brief manual check. | P | Definitions. Loop 2, Loop 3. Red flags. Question template. | RED: both runs picked a pure function and the route with no question. |
| Gate: no test, code change, or command before a user's yes, sourced `Assumed:` lines, or `Open:` lines and a stop. The answer starts with these lines. The question message has no test, no code, and no command. A request for all steps in one answer does not confirm a seam. | spec 8.4 tdd. brief manual check. Review 4.2 C1. Controller ruling C1. | D | Definitions (Gate). Loop 3. Red flags. | GREEN-1 to GREEN-3 held for Claude. GREEN-3 Codex failed. Fix round: Claude held in 3 of 3. Codex failed in 2 of 4 runs before the Gate line and held in 2 of 2 after it (see Pressure scenarios). |
| No user (headless or delegated run): write `Assumed: <value> (source: <file:line or spec section>)` and continue. With no source for the seam or a fact that the first test needs, stop and report `Open: <question>`. Never assume in silence. | Controller ruling C1. ai/principles/never-block-on-the-human.md (make a reasonable decision and show it; product direction comes from the human). | D | Loop 3. Roles. Red flags. Report template (`Assumed:`, `Open:`). | Fix round GREEN-3: one Codex run used an `Open:` line and stopped. No run took the `Assumed:` path. |
| Each domain fact needs a source. Your reading of the user's words is not a source. | spec 8.4 tdd. Review 4.2 M1 (Codex GREEN-2 used its own reading of "above"). | D | Definitions. Loop 1, Loop 3. Red flags. Report template. | RED: both assumed "strictly above 100", the subtotal, and half-up rounding. |
| One question per message, with a recommended answer. The first case rides in the answer. | Controller ruling (parallel-dispatch). | P | Loop 3. Question template. | GREEN |
| Red is an assertion failure with the predicted mismatch. Import, collection, or fixture errors are not red. | sp Verify RED. receipt step 1. spec 8.4 build. brief. | D | Definitions. Loop 4. Red flags. | RED: the Claude first red was an ImportError at collection. The Codex first red was "does not exist". |
| Receipt line `Fail-first: <test id> expected <x> got <y>`. | receipt step 1. brief (format used by `build`). | O | Definitions. Loop 4. Report template. | GREEN |
| The receipt in the plan replaces a red commit. Never commit a red tree. | spec 8.4 tdd. receipt hard rules. | P | Loop 7. | Untested. The runs cannot commit. |
| A missing symbol gets the smallest stub (the signature and a wrong constant result), so the first red is an assertion. | sp Verify RED ("Test errors? Fix error, re-run until it fails correctly"). Audit: Claude RED first red was an ImportError. | P | Loop 4. Red flags. | Fix round GREEN: every Codex run that wrote tests added a stub and predicted an assertion red (`12.00` vs `0`). Claude runs stopped at the question. |
| Name the code change that makes the test fail before the body. | sp writing-good-tests (Name the Break). | P | Loop 4. | GREEN |
| The expected value is a literal from the requirement. Never from a run, never computed like the code. | poc Tautological. sp writing-good-tests. tbni. spec 8.4 tdd. | D | Loop 4. Rules. Red flags. | GREEN |
| Two-edit check. | tbni. spec 8.4 tdd. | D | Rules. | GREEN |
| A "never called" assertion pairs with a case that makes the call. | tbni. spec 8.4 tdd. | D | Rules. | Untested. The scenario has no call. |
| The error type is the contract. The message is not. | tbni. spec 8.4 tdd. | D | Rules. | Untested. The scenario has no error. |
| The payload that a mocked external service gets is behavior. | tbni. spec 8.4 tdd. | D | Rules. | Untested. The scenario has no external service. |
| DB seam tests are normal tests. Assert the row or the message at an external boundary. Do not mock the DB when a test DB exists. With no fixture, propose one in step 3. Repo CLAUDE.md wins for external services. | spec section 7. tbni (a row written is behavior). Review 4.2 M4. | D | Rules. Red flags. | RED: neither run mocked the DB. The scratch app has a test DB fixture. |
| Mock only what you do not own. Never assert that a mock exists. | poc mocking.md. sp writing-good-tests (Principle 2). | D | Rules. | GREEN |
| Seam hint: logic that can be a pure function goes in one, and the test goes there. | bd (two questions). spec 8.4 tdd. | P | Loop 2. | GREEN |
| One test per cycle, vertical slices. More than one new test before green is a red flag. | poc Horizontal slicing, Rules of the loop. Review 4.2 M2. | P | Loop 6. Red flags. | RED: Claude wrote four cases in its first red. Fix round: a Codex run that broke the gate also added a parametrized pair in one cycle. |
| Least code to pass. | poc Red before green. sp GREEN. | P | Loop 5. | GREEN |
| Refactor is left to review. With no review step, each refactor idea goes on a `Refactor:` line in the report. | poc Rules of the loop. Review 4.2 M3. | P | Loop 6. Report template. | Untested. |
| Delete code that you wrote before its test. | sp Iron Law. | D | Rules. Red flags. | Untested. |
| Run only the touched tests per step. | spec 8.4 build (repo test card). Brief Global Constraints (touched tests per task). | P | Loop 4, Loop 5. | GREEN |
| `build` runs tdd per slice. The approved plan confirms the seams and facts that it names. | spec 8.4 build ("Calls tdd"). AGENTS.md tie-break tdd / build. fcd roles with a fallback. | P | Roles. | Untested. No run came from `build`. |
| Open each principle file first, in its own read, with the Read tool when it exists. | spec 8.7. Audit: GREEN-1 Claude skipped the files, GREEN-2 Claude read them in one Bash `cat` that the harness does not count. | P | Loop 2. Red flags. | GREEN-3: both runs read both files. |
| `Principles applied:` line in both templates. | spec 8.7. | O | Question template. Report template. | GREEN |
| Four repo lines, verbatim. | Brief Global Constraints. | D | Repo Rules. | Untested. The runs cannot write. |

## Cut

- poc: "verifying through a side channel (querying the database) is an anti-pattern", and the tests.md example "createUser saves to database" marked BAD. Spec section 7 (user decision) makes a row assertion valid at an external boundary.
- poc: GLOSSARY.md, ADRs, and the `codebase-design` skill call. These files and that skill do not exist in this setup.
- poc: TypeScript examples in tests.md and mocking.md. The principle files carry the Python form.
- sp: the REFACTOR step inside the loop. poc puts the refactor in review, and `build` has a review step.
- sp: "run the project's full suite before done". The user runs only touched tests per step. The full suite runs at merge points (brief Global Constraints).
- sp: the rationalization table, the dot graph, and the long red flag list. The short red flags send the agent back to a step.
- sp: "ask your human partner" exceptions (prototypes, generated code, config). No source row in this setup needs them.
- receipt: the failing command, the output excerpt, and the write-tree hash. The controller fixed the receipt as one line that `build` reads.
- sp: Verify GREEN "output pristine", the Verification Checklist, the When Stuck table, and Debugging Integration. Output checks belong to `prove` and `verifier`, and stuck runs go to `debug`.
- sp writing-good-tests: "keep test-only code out of production classes" and "understand a dependency's side effects before mocking it". The rule "mock only what you do not own" covers the second. The first is a design rule for `review-pr`, not the test loop.
- poc: "Don't anticipate future tests". Loop 5 "least code that makes the test pass" carries it.
- receipt: the guard block rules, the decision log, and the user's-call list. They belong to `build` and the plan, not to the test loop.

## Principles

- test-behavior-not-implementation: pointer at Loop 2 (the seam step), as spec 8.4 requires. Rules carry the two-edit check, the literal expected value, the no-call pair, the error type, and the mocked payload.
- boundary-discipline: pointer at Loop 2 as the seam hint.

## Pressure scenarios

Scenario (`scratch-4.2/scenario.txt`): add a `discount_for(order)` rule to the scratch FastAPI app (`scratch-4.2/shop`, SQLAlchemy, a SQLite test DB fixture): 10 percent off above 100 EUR. Work test first. The run cannot edit files, so the answer carries the tests and the code.

**RED** (no skill, both CLIs, read-only, 2026-10-30):
Neither run asked a question. Both picked the seams themselves: a pure `discount_for` test and a POST `/orders` test with a row assertion. Both assumed three domain facts with no source: "strictly above 100", the subtotal as the base, and half-up rounding to cents. The Claude first red was an ImportError at collection, and the Codex first red was "discount_for does not exist". Neither mocked the DB. Codex read the old `incremental-tdd` skill from the user store.
The failure: tests at unconfirmed seams, domain facts with no source, and a first red that is an import error.

**GREEN** (skill, both CLIs, read-only, 2026-10-30, `--principle test-behavior-not-implementation --principle boundary-discipline`):
Iteration 1 failed the harness for both. Both runs asked which seam before any test, and both listed the facts with sources. Claude did not open the principle files. Neither answer had a `Principles applied:` line. The fix: open the principle files first in Loop 2, end the question with the line, and a red flag for both.
Iteration 2: Codex passed. Claude failed the harness only on "principle not read". The transcript shows that Claude read both files with one `cat` in a Bash loop, but the harness counts only the Read tool for Claude. The fix: open each principle file in its own read, with the Read tool when it exists.
Iteration 3: the harness passed both. Claude asked one seam question with a case that fixes only the rate, and named the open facts (exactly 100.00, rounding). Codex read the skill and both principles but did not ask. It assumed "strictly above 100" with no source, then wrote the whole loop. It did add a stub so that the first red is an assertion (`12.00` expected, `0.00` got), not an import error. The Codex seam gate held in iterations 1 and 2 and failed in iteration 3. The iteration limit is reached, so this stays open.

**Fix round 1** (review 4.2 C1, I1, I2; same scenario and flags, both CLIs, budget 1.5):
Change A (no-user rule with `Assumed:` and `Open:`, no code in the question message, a stub for a missing symbol, the new red flags): Claude asked one seam question in 1 of 1. Codex asked in 1 of 2. The other Codex run wrote "I interpret ... `subtotal > 100`" with no source and gave the full loop.
Change B (silent "I interpret" named, no test that needs an `Open:` fact): Claude asked in 1 of 1. Codex asked in 1 of 2. The other wrote "Exactly EUR 100 receives no discount. The return convention is an assumption." and gave the full loop.
Change C (a Gate definition: no test, code, or command before a yes, sourced `Assumed:` lines, or `Open:` and a stop; the answer starts with these lines): the harness passed all runs. Claude asked in 1 of 1. Codex held in 2 of 2: one asked a Decision question, one led with an `Open:` line and stopped. No run wrote a test. A later STE split of the Gate sentence did not change its words or order and was not rerun.
Across the fix round, Claude held the gate in 3 of 3 runs. Codex held in 2 of 2 runs with the final text. Two Codex runs is a small sample. Treat the Codex gate as likely, not proven.
