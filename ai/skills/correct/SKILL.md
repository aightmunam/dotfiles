---
name: correct
description: Use when agents repeat the same mistake in a repo and you must add a guard in that repo's code.
---

# Correct

## Definitions

- **Agent:** each contributor. It sees only the files that it opened. It copies the nearest example. It takes the shortest path that compiles. Design the repo so that a change that looks right in one file is right for the whole repo.
- **Class:** one kind of mistake. A class counts when it happened two times or more.
- **Evidence:** a commit SHA, a revert, a review comment, a line in an agent instruction file, or a code comment that explains a workaround.
- **Level:** 1 architecture, 2 types, 3 lint or CI check, 4 test, 5 docs. Level 1 is the highest.
- **Test card:** the test and lint commands that the repo's own `AGENTS.md` or `CLAUDE.md` states. If neither file states them, take them from the repo config and say so.
- **Proof:** the output of the new check, run against the file as it was at a past commit that had the mistake.

## The Loop

1. **Frame.** Read the test card. Read the CI config. Record HEAD with `git rev-parse HEAD`.
2. **Find classes.** Read `git log` and the diffs of recent corrections and reverts. Read review comments, agent instruction files, and workaround comments. Group the mistakes into classes. For each class, list each evidence SHA. Drop a class with one case.
3. **Pick the level.** When you write the same instruction a second time, encode it as a lint, a check, or a script. Do not write more text. Read ~/.agents/principles/encode-lessons-in-structure.md before this step. A test claims what the code does for its users. Assert only what those users can see. Read ~/.agents/principles/test-behavior-not-implementation.md before this step. Try each level from 1 down. Stop at the first level that makes the mistake fail.
   - Level 1: give each piece of state one owner and each task one supported way. Hide internals so that the wrong import fails. Remove old ways and dead code that an agent can copy.
   - Level 2: make the bad state a type error.
   - Level 3: use a lint or CI check whose error names the file, type, or function to use. Prefer a rule that the repo linter has. If the pattern is common, fail only on new cases.
   - Level 4: a test that drives the code through its users' interface. A test that patches the clock or an internal helper is not a guard. Correct or remove each test that passes when its behavior breaks, or fails when only the internals change.
   - Level 5: docs only for a judgment call. Nothing fails when an agent skips a doc.
4. **Correct.** Correct the most frequent classes first. Make one commit for each class. The CI must run the same command as the local check. Correct the current cases that the check finds. An exception goes on the offending line with a reason, an expiry date, and the name of the human who approved it.
5. **Prove.** Run the new check against one evidence SHA. Do not change the checkout. Make one shell tool call for this step. In it, pipe the old file into the check and print the exit code, for example `git show <sha>:<path> | ruff check --select <rule> --stdin-filename <path> -; echo "exit $?"`. Do not go to step 6 before this call returns. A check on the current files is not a proof. A diff from `git log -p` is not a proof. The check must fail and name the line. Copy the error line from the output. Do not write it from the source. Then run it at HEAD with your change. It must pass. Run the touched tests from the test card. Read each exit code.
6. **Rule table.** In the repo agent instruction file, keep a table with the columns rule and enforced by. Add one row for each class. Remove the old text rule that the structure replaces. Remove a row when its mistake cannot happen.
7. **Reply.** Use the reply template. If you cannot write files, put each change in your answer as a full diff. Before you send, find each `Proof at` command in your shell commands of this session. If it is not there, run it now.

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Rules That Shape the Change

- **Structure, not text.** A docs change for a class that a check can catch is a failure.
- **A proof is a run.** A check with no failing run at an evidence SHA is not proven. If you cannot run it, write the exact command and "not run: <reason>".
- **The error names the right way.** A check message that says only "bad" makes the next agent guess.
- **The same command runs in CI.** A local check that CI does not run is not a guard.
- **Decisions belong to the user.** Reversible work, such as a commit on a branch, needs no question. A merge or push to main/master, or a production write, needs the user's OK. List the exact commits first.

## Red Flags

- A class with one evidence SHA. Go back to step 2.
- A docs-only change, or a level picked with no reason why a higher level failed. Go back to step 3.
- A test that mocks the clock or asserts a call to an internal helper. Go back to step 3.
- A new check with no proof at an evidence SHA. Go back to step 5.
- A proof line with no command that ran in this session. Run it, or write `not run: <reason>`. Go back to step 5.
- A text rule left beside the check that enforces it. Go back to step 6.
- A `Principles applied:` line for a principle file that you did not open in this session. Go back to step 3.

## Reply Template

```
HEAD: <sha>. Test card: <file, or "repo config">
Class: <name>
  Evidence: <sha> <one line>, <sha> <one line>, ...
  Level: <n> <name>. Higher level not used: <reason for each higher level>
  Check: <command>. Error text: <what it says>
  Proof at <sha>: <command, as it ran in your tool call> -> exit <code from its "exit" line>
  Output: <error line copied from the run>   (or "not run: <reason>")
  At HEAD with the change: exit <code>
  Rule table row: <rule> | <enforced by>
Principles applied: encode-lessons-in-structure -> <choice it changed>
Principles applied: test-behavior-not-implementation -> <choice it changed>
```
