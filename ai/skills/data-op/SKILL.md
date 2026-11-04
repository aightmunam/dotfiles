---
name: data-op
description: Use when a data change touches a real database or a live system. Use when the user asks to backfill, delete, fix, or move rows or records in prod or staging, in a service DB or in Salesforce.
---

# Data Op

## Definitions

- **Prod write:** any change to prod data. The user has no direct write access to prod. Only a deployed path writes to prod.
- **Deployed path:** an API-driven CLI, an Alembic data migration in the release, or a one-off script in the release Cloud Run job.
- **Target:** the table and the rows to change. Name the entity file, the constraints, and the cascades.
- **Invariant:** a count that you read before the change and assert after it.
- **Pure read:** a statement that takes no row lock. `SELECT ... FOR UPDATE` and a rolled-back `DELETE` are not pure reads.

You build the tool and run it on staging. A staging run proceeds without a question. The user runs each prod step. You read prod only through read paths: Metabase and read APIs. For Salesforce prod data, give the user the read query. You run no command against a prod org.

## The Loop

**First, read the three principle files that steps 3, 4 and 7 name.** Read each file in full now, with its own command. Do this also in plan mode or a read-only session. A plan also needs them.

1. **Target.** Find the entity file and the table in the repo. Write the rule that selects the rows as a SQL count. An unclear rule is one question with a recommended answer. Read-only counts go on while you wait.
2. **Path.** Read `paths.md`. Pick the row of the path table that fits the change. Write the row and the reason. Go on with your pick. The user can change it.
3. **Build.** When work is not trivial, build the tool that does it or proves it. Do not do it by hand. Read ~/.agents/principles/build-the-lever.md before this step, as a read of that file alone. Write the script or the migration as `paths.md` gives it for your path. A `verify` command gets one seeded known-bad change for each output that it compares. Missing input gives "inconclusive", never "match".
4. **Rerun.** Each operation must reach the same end state however many times it runs and wherever the last run stopped. Read ~/.agents/principles/make-operations-idempotent.md before this step, as a read of that file alone. Answer the three questions in the output: What happens if it runs twice in a row? What happens if the last run crashed at each possible point? Does a repeat reach the same end state? A tool that writes a file writes a temporary path and renames it into place.
5. **Test.** Write integration tests against a Postgres testcontainer. Run the script against a local prod snapshot. Run the tests. Run the tool on staging. Do a pure-read dry run first, then the real staging run. Neither needs the user's OK. A prod run needs it.
6. **Runbook.** Write the PR body as the runbook. It holds the exact prod commands, the log query, and the expected counts. It also holds the SQL for Metabase that reads the result, and the follow-ups. The prod commands go only in the runbook.
7. **Report.** Check the real artifact before you say that a step finished. Read ~/.agents/principles/prove-it-works.md before this step, as a read of that file alone. Each report line reads the real state and the exit code. Empty or fake output gives "inconclusive", never "passed".
8. **Hand off.** Fill the output template, also for a plan that did not run. The template is the full answer. Put it in your final answer, also when a plan file holds a copy. Its last line is the `Principles applied:` line.

## Rules That Shape the Op

- **No prod write connection.** No command that you run holds a prod connection string, a prod `DATABASE_URL`, or a prod write token.
- **Scope is explicit.** Target IDs or a filter are inline in the script. Rows in progress or completed stay out unless the user asks.
- **A revert path comes first.** State the downgrade, the revert file, the backup table, or fail-forward before the first write.
- **Bound the lock time.** Set `lock_timeout`. Put data statements before DDL.

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Output Template

```
Target: <table>, <entity file>, <row rule as SQL count>, <count or "not read" and why>.
Path: <A | Alembic | B>. Row: <path table row>. Reason: <fact>.
Files: <each file and its purpose>.
Invariant: <count before, assertion after>. Revert: <path>.
Rerun: twice <answer>. crash <answer>. converges <answer>.
Evidence: <tests, staging run, each with its exit code or "inconclusive">.
Runbook: <the PR body, or its path>.
For the user: <each prod step, in order>.
Principles applied: <name> -> <choice it changed>, only for each principle file that you read in this session.
```

## Red Flags

- A command that you run connects to prod with write access. Go back to step 6.
- The prod dry run on a busy table takes row locks. Go back to step 3.
- An Alembic migration for a busy table. Go back to step 2.
- The target is not in the repo, or you guessed the store. Go back to step 1.
- A step says "passed" from output that you did not read. Go back to step 7.
- You did not read a principle file that a step names. Go back to that step.
- The answer does not fill the template, or it has no `Principles applied:` line. Go back to step 8.
