---
name: implement
description: Use when implementing one slice or fixing triaged findings in a build run. Adds the fail-first receipt format, when to log decisions, and how to read and obey a prod guard block. Complements The Eye's implement and fix prompts.
---

# Implement

Guidance for the implementation and fix steps of a build run, one slice at a time.

## When to use

- You are implementing a slice (The Eye's `implement.md`).
- You are fixing findings that triage marked valid (`fix.md`).
- A command was blocked and the message starts with `BLOCKED by prod-guard`.

## What this adds beyond The Eye's prompt

Complements `implement.md` and `fix.md`. It does not repeat their step lists or output schema. It adds:

- what a fail-first receipt must contain;
- when decisions are written down;
- how to read a guard block and what to do next.

## Steps

1. Build the fail-first receipt before any fix. It has three parts:
   - the failing command, exactly as run;
   - an output excerpt that shows the expected error (not a typo, import error or unrelated failure);
   - the write-tree hash taken before the fix, from a temporary index so the real index stays untouched: `GIT_INDEX_FILE=$(mktemp -u) sh -c 'git add -A && git write-tree'`.
   A test that fails for the wrong reason is not a receipt. Fix the test first.
2. Record decisions in the plan file as they happen, not at the end. Each entry has the decision, why, alternatives, evidence and rollback. If you notice you made a choice an hour ago and did not log it, log it now with the evidence you have.
3. Check each choice against the list of the user's calls: public API or data-model changes, migrations and anything hard to reverse, a new dependency or service, scope changes, security trade-offs, ambiguous requirements, writes to SF production, fail-forward on hard-to-reverse changes. If one applies, ask with options and a recommendation, and keep working on what the question does not affect.
4. On a guard block, read the first stderr line: `BLOCKED by prod-guard (<rule>): <reason>`. These rules are currently in force, and the rule name tells you what to do:
   - `db-raw`: a raw database client call. Use `prod-db-read --db NAME --sql "select count(*) from orders where created_at > now() - interval '1 day'"`.
   - `sf-raw-read`: a raw Salesforce read. Use `sf-read -q "select count() from Case"`.
   - `sf-write`: fires for a Salesforce write, for a read on a prod org that is not on the read allowlist, and for curl to a Salesforce host. Read the reason. If it says to use `sf-read` and you were reading, use `sf-read`. A real write to production is the user's call with double approval: stop and ask through the escalate skill.
   - `oversize`: the command was too large to inspect. Do not retry it in another form. Stop and ask through the escalate skill.
   - Any other rule name: read the reason and do not retry in another form. If the reason names a tool, use that tool. If it names none, stop and ask through the escalate skill.
   Wrappers accept aggregate queries only. Exit 3 means rewrite the query; exit 4 means a connection or query error; exit 5 (unknown `--db`) is `prod-db-read` only, and `sf-read` has no `--db`.
5. Run the wrappers as plain commands. No pipes, no redirection, no command substitution around them.
6. Commit the passing tree only. No attribution lines in the message.

## Hard rules

- Never retry a blocked command in another form: another quoting, another path to the binary, a variable, `bash -c`, a script file, an alias. A block is an answer.
- Never use a raw `psql`, `sf` or `curl` against production.
- Never commit a red tree.
- Never skip the receipt because the test "obviously" fails.
- Never widen a slice. If it outgrows the plan, stop and ask.
- Never write to Salesforce production.
