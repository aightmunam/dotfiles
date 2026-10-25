---
name: triage-findings
description: Use when triaging review findings in a build run: verify each one, rule valid, invalid or your_call, and keep evidence a reviewer can rerun. Complements The Eye's triage prompt.
---

# Triage findings

Guidance for ruling on review findings without obeying them blindly and without dismissing them.

## When to use

- You received review findings from Codex or from a lens (The Eye's `triage.md`).
- You are about to reject a finding.
- A finding touches something that may be the user's call.

## What this adds beyond The Eye's prompt

Complements `triage.md`. It does not repeat the verdict fields or the decision log shape. It adds the evidence standard for each verdict and the order of checks.

## Steps

1. For each finding, reproduce it or read the code before ruling. Run the failing input, or open the `file:line` in the receipt. Never rule from the finding's title.
2. Check the finding against the list of the user's calls. If it touches any of these, rule `your_call`, add the matching question with options and a recommendation, and do not fix it:
- public API or data-model changes
- migrations and anything hard to reverse
- a new dependency or service
- scope changes
- security trade-offs
- ambiguous requirements where Claude would have to pick an interpretation
- anything Claude and Codex still disagree on after 3 rounds (unless "decide for me")
- any write to SF production (double approval, always)
- fail-forward on hard-to-reverse changes
3. Before rejecting a finding, check the lens's known-false-positive list if the lens has one (provisional until Plan 3: `lens-route` may show which lenses ran, when it is installed). A finding that matches an entry still needs the check in step 4, but you must cite the entry in the evidence.
4. Rule.
   - `valid`: fix it, rerun tests and lint, commit, set `fixed` true. The evidence says how you confirmed it.
   - `invalid`: the evidence must be something the reviewer can rerun: a command and its output, a test name, a `file:line`, or a doc link. "I read it and it is fine" is not evidence. The reviewer sees it next round and may push back, so write it for them.
   - `your_call`: only for the list above. Not for a finding that is hard or unclear. Investigate until it is valid or invalid.
5. For a finding that depends on production, rerun the read: `prod-db-read --db NAME --sql "select count(*) from orders where status is null"` or `sf-read -q "select count() from Case"`. Aggregates only. Attach the output to the evidence.
6. Log every verdict as a decision. A rejection is a decision.
7. Count rounds. After 3 rounds of disagreement on the same finding, it goes to the user as a question unless "decide for me" is set and the change is reversible.

## Hard rules

- Never rule `invalid` without evidence a reviewer can rerun.
- Never rule `valid` and skip the fix.
- Never decide an item on the list of the user's calls.
- Never reject because the finding is inconvenient or the fix is large.
- Never rule on a finding you have not reproduced or read.
- Never run raw `psql` or `sf` against production to check a finding. Use the wrappers.
