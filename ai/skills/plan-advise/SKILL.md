---
name: plan-advise
description: Use when writing or critiquing a plan for a build run, shaping slices, deciding what to ask the user, or checking a plan assumption against production data. Adds slice shape, the list of the user's calls and the prod check procedure on top of The Eye's plan and critique prompts.
---

# Plan advise

Guidance for the planning step and the plan critique step of a build run. The Eye's prompt tells you the output schema and the environment rules. This skill tells you what a good plan contains.

## When to use

- You are writing a plan (The Eye's `plan.md` step) or critiquing one (`critique.md`).
- You must decide whether a choice is yours or the user's.
- A plan assumption depends on what production data looks like.

## What this adds beyond The Eye's prompt

Complements `plan.md` and `critique.md`. It does not repeat their schema, mode rules or gap report. It adds:

- the shape every slice must have;
- the exact list of the user's calls (the templates carry a copy; this one is the reference);
- how to check a plan assumption against production without guessing.

## Steps

1. Shape each slice.
   - One behaviour per slice. If the goal needs the word "and" between two behaviours, split it.
   - Name the fail-first test: the test file and test name that will fail before the code exists, and the error it should fail with.
   - Give a recovery path that says exactly how: `rollback` (revert, migration downgrade, flag off) or `fail_forward`. Fail-forward on anything hard to reverse is a question, not a decision.
   - When a change spans repos, state the deploy order: which repo ships first, what the other repo must tolerate in between (old reader with new writer, and the reverse), and what turns the change on.
2. Sort every choice. If it matches the list below, it is the user's call: put it in `questions` with both options and a recommendation, and do not decide it. Everything else you decide and log.
- public API or data-model changes
- migrations and anything hard to reverse
- a new dependency or service
- scope changes
- security trade-offs
- ambiguous requirements where Claude would have to pick an interpretation
- anything Claude and Codex still disagree on after 3 rounds (unless "decide for me")
- any write to SF production (double approval, always)
- fail-forward on hard-to-reverse changes
3. Work not affected by a pending question stays in the plan and goes ahead.
4. Check a plan assumption about production data in two steps.
   - First run the query with `--check`: `prod-db-read --db NAME --sql "select count(*) from orders where created_at > now() - interval '1 day'" --check`. This validates the query and reaches no data. Exit 3 means rejected: rewrite it as an aggregate. Exit 5 means the `--db` name is unknown.
   - Then run it live without `--check`, still an aggregate, with a small `--timeout` and `--max-rows`. Only aggregate queries are allowed; row-level reads are rejected.
   - For Salesforce use `sf-read -q "select count() from Case where CreatedDate = TODAY"` (add `--tooling` for metadata). Output is JSON and redacted.
   - Exit codes: 0 ok, 3 rejected, 4 connection or query error for both wrappers; 2 is a usage error for both; 5 (unknown `--db`) is `prod-db-read` only, because `sf-read` has no `--db`. On 4, report the error in the plan as unverified. Do not retry around it.
   - Put the command and the output in the decision's `evidence`. An assumption with no output stays marked unverified.
5. When critiquing, name the assumptions the plan did not check and say which could be checked with the steps above. Do not rewrite the plan.

## Hard rules

- Never decide an item on the list of the user's calls.
- Never run `psql`, `sf data`, `sf api` or `curl` against production. A guard blocks them; use the wrappers.
- Never put a row-level query, a customer value or a credential into a plan.
- Never claim a production fact without the command and its output.
- Do not duplicate the plan template. If this skill and the prompt disagree on the schema, the prompt wins.
