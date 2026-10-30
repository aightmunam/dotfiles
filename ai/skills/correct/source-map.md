# Source Map

`ai/sources.lock` pins the sources. pstack paths are under `~/Developer/ref/pstack-claude/plugins/pstack/skills/`.

- **pc:** `correct/SKILL.md` (all of it: the agent model, find classes, the five levels, fix and prove, the rule table, the reply).
- **elis:** `ai/principles/encode-lessons-in-structure.md` (key sentence, "use only the structure", "test the new guard").
- **tbni:** `ai/principles/test-behavior-not-implementation.md` (key sentence, two edits, patching internals).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 correct entry, section 8.7 (principle pointers).
- **brief:** task 8.7 brief (Interfaces: test card, fix order, proof on a real past mistake, no alembic, the verbatim repo lines) and Global Constraints.
- **ctl:** controller rulings in `parallel-dispatch.md` and the task 8.7 dispatch (one question per message, never-block-on-the-human, principle pointer form, four repo lines, "test card" is the target repo's own `AGENTS.md` or `CLAUDE.md`).
- **prove:** `ai/skills/prove/SKILL.md` Rules ("The exit code counts").

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output. "Loop N" is a step in SKILL.md.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Each contributor is an agent: it sees only opened files, copies the nearest example, takes the shortest path. | pc intro. | P | Definitions. | Untested. No answer shows this model at work. |
| A class counts after two cases. Evidence: commits, reverts, review comments, agent instruction files, workaround comments. | pc Find the mistake classes. spec 8.4. | D | Definitions. Loop 2. Red flags. | GREEN-2: both listed the three fix SHAs and the case at HEAD. RED: neither listed evidence SHAs. |
| Read the test card: the target repo's own `AGENTS.md` or `CLAUDE.md`. Missing: take the commands from the repo config and say so. | brief Interfaces. ctl (test card ruling). spec 8.4. | P | Definitions. Loop 1. Reply template. | GREEN-2: both wrote `Test card: AGENTS.md`. |
| Read the CI config. Record HEAD. | spec 8.4 (same command local and in CI). | P | Loop 1. Reply template. | GREEN-2: both recorded HEAD 2d9d7a5 and named the CI step. |
| Level order: architecture, types, lint or CI check, test, docs. Stop at the first level that makes the mistake fail. | pc Fix each class. spec 8.4. brief Interfaces (fix order). | D | Definitions. Loop 3. Red flags. | GREEN-2: both gave a reason for levels 1 and 2. RED: neither did. |
| Principle pointer encode-lessons-in-structure at the level step. | elis. spec 8.4 (the core principle). spec 8.7. ctl. | P | Loop 3. Red flags. Reply template. | GREEN-2: both read the file (harness PASS). |
| Level 1: one owner, one supported way, hide internals, remove old ways and dead code. | pc level 1. | P | Loop 3. | GREEN-2: both judged level 1 (a helper cannot hide stdlib `datetime`). |
| Level 2: make the bad state a type error. | pc level 2. | P | Loop 3. | GREEN-2: both judged level 2 (types cannot tell naive from aware). |
| Level 3: the check error names what to use. Prefer a rule the repo linter has. A common pattern fails only on new cases. | pc level 2 second half. spec 8.4. elis (a ruff rule first in the list). | P | Loop 3. Rules. | Partial. GREEN-2: both used ruff `DTZ`, and its help line names the `tz` argument. RED picked the same rule, so this held already. Untested: fail only on new cases. |
| Principle pointer test-behavior-not-implementation at level 4. A test that patches the clock or a helper is not a guard. | tbni. pc level 3. spec 8.4. spec 8.7. ctl. | D | Loop 3. Red flags. Reply template. | GREEN-2: both read the file. Claude's test reads the offset from the HTTP response. No run patched the clock. RED also did not, so this held already. |
| Level 5: docs only for a judgment call. A docs change for a class that a check can catch is a failure. | pc level 4. elis ("use only the structure"). | D | Loop 3. Rules. Red flags. | GREEN-2: both removed the `AGENTS.md` text rule. RED: Claude kept the text rule and added a sentence. |
| Most frequent classes first, one commit each. | pc Fix and prove. | P | Loop 4. | Untested. The fixture has one class and the runs cannot commit. |
| The CI runs the same command as the local check. | pc Fix and prove. spec 8.4. | D | Loop 4. Rules. | GREEN-2: both kept `ruff check .`, the CI command. |
| Exceptions on the offending line with a reason, an expiry date, and the approver. | pc Fix and prove. | P | Loop 4. | Untested. The fixture needs no exception. |
| Prove each new check on a past evidence SHA, without a change to the checkout. Then it passes at HEAD with the change. | pc Fix and prove. elis ("break the rule on purpose"). brief Interfaces. spec 8.4. | D | Definitions. Loop 5. Rules. Red flags. Reply template. | GREEN-2: both ran `git show e6f3445:app/routers/shipments.py \| ruff check ... -` and got exit 1, DTZ005 at line 10. Claude also ran 2bdb86c and 254a5b1. RED: no run touched a past commit. |
| Touched tests only. Read each exit code. | spec 8.4 (touched tests per step). prove Rules. | P | Loop 5. | Partial. GREEN-2: Claude ran the suite, exit 0. Codex ran it and got exit 1 (no `fastapi` in its sandbox), and it said so. |
| Rule table (rule, enforced by) in the agent instruction file. The row points to the enforcer. Remove the text rule that the structure replaces. Remove a row when the mistake cannot happen. | pc Keep the rule table. spec 8.4. elis ("do not add a text rule beside it"). | P | Loop 6. Red flags. Reply template. | GREEN-2: both replaced the text rule with a table row that names ruff `DTZ`. |
| Reply: each class with evidence, level, why a higher level did not work, the proof run. | pc Reply. spec 8.4. | O | Reply template. | Partial. GREEN-2: Claude used the template. Codex gave the same facts in prose. |
| No write access: each change as a full diff in the answer. | ctl (headless runs cannot write). | P | Loop 7. | Not GREEN. The scenario asks for full diffs. |
| Four repo lines, verbatim. | brief Global Constraints. ctl. | D | Repo Rules. | Untested. The fixture has no Salesforce, DB, or `.env`. |
| A `Principles applied:` line for a file not opened goes back to step 3. | Audit: in GREEN-1, Claude wrote both `Principles applied:` lines and opened neither file. prove Red flags. | D | Red flags. | GREEN-2: both opened both files (harness PASS). |
| Commits need no question. A merge or push to main or master lists the commits and waits for the OK. | ctl (never-block-on-the-human). brief Global Constraints. | D | Repo Rules. | Untested. The runs cannot commit. |

## Resolved conflict

pc keeps a rule table of text rules in the agent instruction file. elis says: when a structure enforces a rule, add no text rule beside it. The skill keeps the table as an index. Each row names the rule in a few words and points to its enforcer. The prose rule that the structure replaces goes away in the same change.

## Cut

- pc: "Repeat this each time the operator corrects you" and "When the operator corrects you, fix the mistake and add the rule". The description carries the trigger ("the user corrects a mistake that happened before"). `reflect` owns lessons from a session into skills or `AGENTS.md` (`ai/AGENTS.md` tie-break line).
- pc: "If the rule was already there and nothing enforces it, that's a repeat". The class definition (two cases) and Loop 2 cover it.
- pc: "Use for /correct". The router row in `ai/AGENTS.md` owns the trigger.
- pc: "Replace hand-synced lists with one source of truth". It is a case of "one owner" in level 1. The SKILL.md length limit cut the example.

## Principles

- encode-lessons-in-structure: pointer at Loop 3 (pick the level), key sentence inline.
- test-behavior-not-implementation: pointer at Loop 3 level 4 (the test level), key sentence inline.

## Pressure scenarios

Scenario (`scratch-8.7/scenario.txt`, the same text for RED and GREEN): the git repo `scratch-8.7/repo` (`build-history.sh`, HEAD 2d9d7a5) is a FastAPI service. Three commits fix a bare `datetime.now()` (7f387a1, 37a0b92, 9a57964). The second fix added a text rule to `AGENTS.md`. The last commit (2d9d7a5) adds one more. The user line: "Agents keep making this mistake here. Stop it." The runs cannot write, so the diffs go in the answer.

**RED** (no skill, both CLIs, read-only, 2026-10-30, budget 1.5):
- Failure: neither run proved the check on a past commit. Claude ran it only at HEAD. Codex ran it on a made-up snippet.
- Neither listed evidence SHAs or said why a higher level did not work. Claude kept the `AGENTS.md` text rule beside the lint.
- Both picked ruff `DTZ`, both kept CI as is, and neither mocked the clock.
- Cost: claude 0.30 USD. codex 511k input tokens (479k cached), 5.2k output tokens.

**GREEN-1** (`--principle encode-lessons-in-structure --principle test-behavior-not-implementation`, budget 1.5): claude FAIL, neither principle file read, yet the answer had both `Principles applied:` lines. Its proof ran at 7f387a1^, 37a0b92^, and 9a57964^. Codex did not run (model at capacity). Fix: both pointers at Loop 3 with their key sentences, and a red flag for a principle line with no file read. Cost: claude 0.37 USD.

**GREEN-2** (same flags, budget 1.5):
- Harness: claude PASS, codex PASS.
- Both ran the check against e6f3445 with `git show <sha>:<path> \| ruff check --stdin-filename ...`: exit 1, DTZ005 at `shipments.py:10:58`. Claude also ran 2bdb86c and 254a5b1. The RED failure is gone.
- Both picked level 3 with reasons for levels 1 and 2, removed the `AGENTS.md` text rule, and added a rule table row.
- Gaps: Codex did not use the reply template. Codex could not run the suite (no `fastapi` in its sandbox).
- Cost: claude 0.40 USD. codex 207k input tokens (190k cached), 2.8k output tokens.
