---
name: review-orchestrate
description: Use when running the review step of a build run: choosing lenses, making the one Codex call, and attaching receipts for findings that depend on production. Complements The Eye's review prompt.
---

# Review orchestrate

Guidance for the review step: how lenses are chosen, how prod-dependent findings are proven, and how Codex must call the read wrappers.

## When to use

- You are reviewing a slice diff (The Eye's `review.md`).
- A finding depends on production data or Salesforce state.
- You are deciding how much review a slice gets.

## What this adds beyond The Eye's prompt

Complements `review.md`. It does not repeat the finding fields, the receipt rule or the read-only rules. It adds:

- lens routing when `lens-route` is installed, with the `review.md` lenses as the fallback;
- the receipt format for prod-dependent findings;
- how Codex calls the wrappers so the execution policy allows them.

## Steps

Orchestrator steps (Claude, before the Codex call):

1. Pick the risk tier. Trivial (docs, formatting, config typos): deterministic checks only, no Codex review. Normal: routed lenses in one parallel Codex call. High-risk (migrations, auth, external side effects, cross-service): routed lenses plus a deeper pass.
2. Choose the lenses. Run `command -v lens-route`. The `lens-route` interface is provisional until Plan 3.
   - If it prints a path, run `lens-route` for the diff and pass the lenses it returns to Codex, in one call.
   - If it prints nothing, pass the six lenses in `review.md`: correctness, tests, security, dead code, scope, recovery.

Codex steps (the reviewer, in a fresh context):

3. Review through the lenses you were given. Verify each suspicion by reading or by a read-only command before you report it.
4. When a finding depends on production behaviour, prove it through a wrapper and attach the exact command and its output as the receipt.
   - Database: `prod-db-read --db NAME --sql "select count(*) from orders where status is null" --max-rows 20`.
   - Salesforce: `sf-read -q "select count() from Case where Status = 'New'"`.
   - Aggregates only. Exit 3 means the query was rejected: rewrite as an aggregate. Exit 4 means an error: say the finding is unproven, and set `wants_block` to false. Exit 5 (unknown `--db`) is `prod-db-read` only; `sf-read` has no `--db` and exits 0, 2 usage, 3, 4.
   - The receipt holds the command line as run and the output, redacted as the wrapper returned it. Never paste more than the aggregate.
5. Call the wrappers as one plain command: no pipes (`|`), no redirection (`>`, `<`), no `&&` chains, no command substitution. This assumes the Codex execpolicy rule that allows `prod-db-read` and `sf-read` matches the command as written, so a pipe or redirection makes it a different command and the call fails. That assumption is not yet tested live; it is checked in Phase 7. If you need less output, use `--max-rows` and a tighter query, not `head`.
6. A finding without a receipt is a comment: `wants_block` false. Missing or invalid reviewer output counts as a block, not a pass.

## Hard rules

- Never use `psql`, `sf data`, `sf api`, `curl`, `wget` or `nc` against production. They are blocked or refused; use the wrappers.
- Never edit, create or delete a file, and never commit, during review.
- Never block on a finding with no receipt.
- Never report a prod fact from memory. Run the wrapper and attach the output.
- Never run a row-level query to "see an example". Only aggregates are allowed.
