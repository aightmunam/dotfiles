# Source Map

`ai/sources.lock` pins the sources. pstack paths are under `~/Developer/ref/pstack-claude/plugins/pstack/skills/`.

- **pc:** `correct/SKILL.md` (all of it). Labels: "pc intro" is the agent model. "pc classes", "pc levels", "pc proof" and "pc table" are the four sections in order. "pc Reply" is the last line.
- **elis:** `ai/principles/encode-lessons-in-structure.md` (key sentence, "use only the structure", "test the new guard").
- **tbni:** `ai/principles/test-behavior-not-implementation.md` (key sentence, two edits, patching internals).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 correct entry, section 8.7 (principle pointers).
- **brief:** task 8.7 brief and its Global Constraints. Interfaces: the test card, the level order, and a proof on a real past mistake. Also: no alembic, and the verbatim repo lines.
- **ctl:** controller rulings in `parallel-dispatch.md` and the task 8.7 dispatch. They cover one question per message, never-block-on-the-human, the principle pointer form, and the four repo lines. "Test card" is the target repo's own `AGENTS.md` or `CLAUDE.md`.
- **prove:** `ai/skills/prove/SKILL.md` Rules ("The exit code counts").
- **r2:** round 2 harness brief (`round2/briefs.md`, section harness) and the task 8.7 parked item: Codex reports a proof that it never ran. `ai/bin/pressure-run --expect-command` checks that a matching shell command ran.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output. "Loop N" is a step in SKILL.md.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Each contributor is an agent: it sees only opened files, copies the nearest example, takes the shortest path. | pc intro. | P | Definitions. | Untested. No answer shows this model at work. |
| A class counts after two cases. Evidence: commits, reverts, review comments, agent instruction files, workaround comments. | pc classes. spec 8.4. | D | Definitions. Loop 2. Red flags. | GREEN-3: both listed 7f387a1, 37a0b92, and 9a57964. RED: neither listed evidence SHAs. |
| Read the test card: the target repo's own `AGENTS.md` or `CLAUDE.md`. Missing: take the commands from the repo config and say so. | brief Interfaces. ctl (test card ruling). spec 8.4. | P | Definitions. Loop 1. Reply template. | Partial. GREEN-3: both used the `AGENTS.md` commands. Only Codex wrote the `Test card:` line. |
| Read the CI config. Record HEAD. | spec 8.4 (same command local and in CI) for the CI config. prove Loop 1 (record `head_sha`) for HEAD. | P | Loop 1. Reply template. | GREEN-3: both named HEAD 2d9d7a5 and said CI runs `ruff check .`. |
| Level order: architecture, types, lint or CI check, test, docs. Stop at the first level that makes the mistake fail. | pc levels. spec 8.4. brief Interfaces (level order). | D | Definitions. Loop 3. Red flags. | GREEN-3: both gave a reason for levels 1 and 2. RED: neither did. |
| Principle pointer encode-lessons-in-structure at the level step. | elis. spec 8.4 (the core principle). spec 8.7. ctl. | P | Loop 3. Red flags. Reply template. | GREEN-3: both opened the file (Claude and Codex transcripts). |
| Level 1: one owner, one supported way, hide internals, remove old ways and dead code. | pc level 1. | P | Loop 3. | GREEN-3: both judged level 1 (a clock helper does not stop a direct `datetime.now()`). |
| Level 2: make the bad state a type error. | pc level 2. | P | Loop 3. | GREEN-3: both judged level 2 (types cannot tell naive from aware). |
| Level 3: the check error names what to use. Prefer a rule the repo linter has. A common pattern fails only on new cases. | pc level 2 second half. spec 8.4. elis (a ruff rule first in the list). | P | Loop 3. Rules. | Partial. GREEN-3: both used ruff `DTZ`, and its help line names the `tz` argument. RED picked the same rule, so this held already. Untested: fail only on new cases. |
| Principle pointer test-behavior-not-implementation at level 4. A test that patches the clock or a helper is not a guard. | tbni. pc level 3. spec 8.4. spec 8.7. ctl. | D | Loop 3. Red flags. Reply template. | GREEN-3: both opened the file. Neither added a test that patches the clock. RED also did not, so this held already. |
| Level 5: docs only for a judgment call. A docs change for a class that a check can catch is a failure. | pc level 4. elis ("use only the structure"). | D | Loop 3. Rules. Red flags. | GREEN-3: both removed the `AGENTS.md` text rule. RED: Claude kept the text rule and added a sentence. |
| Most frequent classes first, one commit each. | pc proof. | P | Loop 4. | Untested. The fixture has one class and the runs cannot commit. |
| The CI runs the same command as the local check. | pc proof. spec 8.4. | D | Loop 4. Rules. | GREEN-3: both kept `ruff check .`, the CI command. |
| Exceptions on the offending line with a reason, an expiry date, and the approver. | pc proof. | P | Loop 4. | Untested. The fixture needs no exception. |
| Prove each new check on a past evidence SHA, without a change to the checkout. Then it passes at HEAD with the change. | pc proof. elis ("break the rule on purpose"). brief Interfaces. spec 8.4. | D | Definitions. Loop 5. Rules. Red flags. Reply template. | GREEN, both CLIs, r2-GREEN-3 (Codex: one sample after 4 fails. Harness `--expect-command`, checked by hand). Claude ran `git show 7f387a1^:app/routers/invoices.py \| ruff check ... -` and a loop at 37a0b92^ and 9a57964^, exit 1 each. Codex ran `git show e6f3445...:app/routers/shipments.py \| ruff check --select DTZ005 ... -; printf 'exit %s'`, output DTZ005 at 10:58 and `exit 1`. Before: Codex stated this run with no command behind it in GREEN-2, GREEN-3, r2-GREEN-1 and r2-GREEN-2 (harness FAIL on `--expect-command`). Not GREEN: "without a change to the checkout" (the read-only run forced it). |
| Touched tests only. Read each exit code. | spec 8.4 (touched tests per step). prove Rules. | P | Loop 5. | Partial. GREEN-3: Claude ran the suite and got `OK`, but did not read the exit code. Codex ran it and got exit 1 (no `fastapi` in its sandbox), and it said so. |
| Rule table (rule, enforced by) in the agent instruction file. The row points to the enforcer. Remove the text rule that the structure replaces. Remove a row when the mistake cannot happen. | pc table. spec 8.4. elis ("do not add a text rule beside it"). | P | Loop 6. Red flags. Reply template. | GREEN-3: both replaced the text rule with a table row that names ruff `DTZ`. |
| Reply: each class with evidence, level, why a higher level did not work, the proof run. | pc Reply. spec 8.4. | O | Reply template. | Partial. r2-GREEN-3: Claude used the template with `Proof at`, `Output:` and both `Principles applied:` lines. Codex wrote the same facts in prose (HEAD, test card, evidence, level reason, proof command, "Actual output" block, a `Principles applied:` line), not the template labels. |
| No write access: each change as a full diff in the answer. | ctl (headless runs cannot write). | P | Loop 7. | Not GREEN. The scenario asks for full diffs. |
| Design the repo so that a change that looks right in one file is right for the whole repo. | pc intro. | P | Definitions. | Untested. No answer shows it. |
| Correct or remove each test that passes when its behavior breaks, or fails when only the internals change. | pc level 3. tbni (two edits). | P | Loop 3 level 4. | Untested. The fixture has no weak test. |
| Copy the error line from the run output. Do not write it from the source. A proof line with no command run in this session goes back to step 5. | Review 8.7 C1: in GREEN-2, Codex wrote a proof at e6f3445 that it never ran. elis ("test the new guard"). | D | Loop 5. Red flags. Reply template. | GREEN, both CLIs, r2-GREEN-3 (Codex: one sample after 4 fails). Each copied error line matches the output of its own run (Claude 10:14, Codex 10:58). The red flag alone did not stop Codex (GREEN-3, r2-GREEN-1). |
| Four repo lines, verbatim. | brief Global Constraints. ctl. | D | Repo Rules. | Untested. The fixture has no Salesforce, DB, or `.env`. |
| A `Principles applied:` line for a file not opened goes back to step 3. | Audit: in GREEN-1, Claude wrote both `Principles applied:` lines and opened neither file. prove Red flags. | D | Red flags. | GREEN-3: both opened both files. Claude then left out the `Principles applied:` line. |
| A check on the current files, or a diff from `git log -p`, is not a proof. Before the reply, find each `Proof at` command in the session's shell commands, or run it now. | r2 (8.7 parked item). Review 8.7 C1. elis ("test the new guard"). | D | Loop 5. Loop 7. | Not shown alone. Added in r2 text change 1. r2-GREEN-2 (this text): Claude PASS, Codex FAIL ("actually run" proof at 2bdb86c, no such command). It stays in the r2-GREEN-3 text, which passed on both. |
| The proof is one shell tool call that prints its exit code (`; echo "exit $?"`). Step 6 waits until it returns. The template copies the command as it ran and the code from its exit line. | r2 (8.7 parked item). prove Rules ("The exit code counts"). | D | Loop 5. Reply template. | GREEN, both CLIs, r2-GREEN-3 (Codex: one sample after 4 fails): both ran the proof with an exit line (Claude `echo "exit $?"`, Codex `printf 'exit %s'`). |
| Reversible work, such as a commit on a branch, needs no question. A merge or push to main/master, or a production write, needs the user's OK. List the exact commits first. | ctl (never-block-on-the-human, review round 1 ruling I3). brief Global Constraints. `ai/skills/debug/SKILL.md` Rules (wording). | D | Rules. | Untested. The runs cannot commit. |

## Resolved conflict

pc keeps a rule table of text rules in the agent instruction file. elis says: when a structure enforces a rule, add no text rule beside it. The skill keeps the table as an index. Each row names the rule in a few words and points to its enforcer. The prose rule that the structure replaces goes away in the same change.

## Cut

- pc: "Repeat this each time the operator corrects you" and `When the operator corrects you, fix the mistake and add the rule`. The correction trigger overlaps `reflect`, which owns lessons from a session (`ai/AGENTS.md` tie-break line). The description keeps only the routing row trigger (review round 1 ruling I4).
- pc: "If the rule was already there and nothing enforces it, that's a repeat". The class definition (two cases) and Loop 2 cover it.
- pc: "Use for /correct". The router row in `ai/AGENTS.md` owns the trigger.
- pc: "Replace hand-synced lists with one source of truth". Level 1 "give each piece of state one owner" covers it. A hand-synced list is state with two owners.

## Principles

- encode-lessons-in-structure: pointer at Loop 3 (pick the level), key sentence inline.
- test-behavior-not-implementation: pointer at Loop 3 (pick the level), key sentence inline. Level 4 applies it.

## Pressure scenarios

Scenario (`scratch-8.7/scenario.txt`, the same text for RED and GREEN): the git repo `scratch-8.7/repo` (`build-history.sh`, HEAD 2d9d7a5) is a FastAPI service. Three later commits remove a bare `datetime.now()` (7f387a1, 37a0b92, 9a57964). The second of them added a text rule to `AGENTS.md`. The last commit (2d9d7a5) adds one more. The user line: "Agents keep making this mistake here. Stop it." The runs cannot write, so the diffs go in the answer.

**RED** (no skill, both CLIs, read-only, 2026-10-30, budget 1.5):
- Failure: neither run proved the check on a past commit. Claude ran it only at HEAD. Codex ran it on a made-up snippet.
- Neither listed evidence SHAs or said why a higher level did not work. Claude kept the `AGENTS.md` text rule beside the lint.
- Both picked ruff `DTZ`, both kept CI as is, and neither mocked the clock.
- Not a clean baseline: RED Codex opened the live `~/.agents/principles/encode-lessons-in-structure.md` through the global `AGENTS.md` index. This can explain why no docs-only change showed in RED.
- Cost: claude 0.30 USD. codex 511k input tokens (479k cached), 5.2k output tokens.

**GREEN-1** (`--principle encode-lessons-in-structure --principle test-behavior-not-implementation`, budget 1.5): claude FAIL, neither principle file read, yet the answer had both `Principles applied:` lines. Its proof ran at 7f387a1^, 37a0b92^, and 9a57964^. Codex did not run (model at capacity). Change: both pointers at Loop 3 with their key sentences, and a red flag for a principle line with no file read. Cost: claude 0.37 USD.

**GREEN-2** (same flags, budget 1.5):
- Harness: claude PASS, codex PASS.
- Claude ran the check at e6f3445, 2bdb86c, and 254a5b1: exit 1, DTZ005 each time.
- Codex claimed exit 1 at e6f3445 (`shipments.py:10:58`), but ran no command on a past commit. It read the line from `git log -p`. The harness does not check this (review 8.7 C1).
- Both picked level 3 with reasons for levels 1 and 2, removed the `AGENTS.md` text rule, and added a rule table row.
- Cost: claude 0.40 USD. codex 207k input tokens (190k cached), 2.8k output tokens.

**GREEN-3** (review round 1 skill, same flags, budget 1.5). Changes: a red flag for a proof line with no run, and "copy the error line from the output" in Loop 5. The template has an `Output:` line. The two pstack rules from review I2 are in, and the decision rule moved to Rules.
- Harness: claude FAIL (no `Principles applied:` line), codex PASS.
- Claude ran the check at 7f387a1^, 37a0b92^, and 9a57964^: exit 1, DTZ005 each time, with the `-->` lines copied into a table. It wrote the principles in prose and did not use the reply template.
- Codex again claimed a run at e6f3445 with "Actual output". Its transcript has `ruff check --select DTZ005 .` at HEAD and a stdin loop over the current files, and no command on a past commit. The new red flag did not stop it.
- Both removed the `AGENTS.md` text rule and added a rule table row.
- Cost: claude 0.38 USD. codex 208k input tokens (166k cached), 2.7k output tokens.
- Result: not GREEN. This was the third GREEN run, the limit.

**Round 2** (harness `--expect-command`, `scratch-8.7/r2-green-<n>/`, both principles, budget 1.5, expect regex `(?s)^(?=.*\bshow\b)(?=.*ruff check)(?=.*\b(?!2d9d7a5)[0-9a-f]{7,40}[~^]?\d*:[\w./]+\.py)`). The regex on the saved runs: Claude passes GREEN-1 to GREEN-3, Codex fails GREEN-2 and GREEN-3, RED fails on both.
- r2-GREEN-1 (skill as after GREEN-3): claude PASS, codex FAIL on `--expect-command`. Codex again stated a run at e6f3445 ("run this session") with no such command. Cost: claude 0.28 USD. codex 233k input (211k cached), 2.5k output.
- r2-GREEN-2 (text change 1). A check on current files or a `git log -p` diff is not a proof. Check each `Proof at` command before the reply. Result: claude PASS, codex FAIL. Codex wrote "actually run" at 2bdb86c with no such command. Cost: claude 0.32 USD. codex 204k input (183k cached), 2.7k output.
- r2-GREEN-3 (text change 2). The proof is one shell tool call with `; echo "exit $?"`. Step 6 waits for it. The template copies the command and the exit line. Result: claude PASS, codex PASS. Codex ran the proof at e6f3445 and copied its output. Claude used the full template. Cost: claude 0.30 USD. codex 234k input (213k cached), 2.7k output.
