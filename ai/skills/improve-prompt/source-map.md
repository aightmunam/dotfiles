# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **sh:** pstack-claude `plugins/pstack/skills/sharpen/SKILL.md` (four questions, rewrite, leave the user's choices open).
- **changes:** pstack-claude `CHANGES.md` 0.9.86 and the sync that returned sharpen to upstream's prompt ("rewrites the prompt and does not do the task").
- **audit:** `thoughts/shared/research/2026-10-30-pstack-gap-audit.md:239-242`. Its SKIP reason (`be-ambitious` covers it) became stale when `4c82134` removed `be-ambitious`.
- **user:** the request of 2026-11-04 to add sharpen as a separate skill and also as a part of brainstorm.

Form key. P is a procedure step. D is a discipline with a red flag. O is an output.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Read the prompt and the files that it names. | user (a prompt for this repo). | P | Loop 1. | RED: both read the code. Kept as a guard. |
| What a top professional does that the prompt does not ask for. | sh question 1. | P | Loop 2. | RED: neither said to measure where the time goes first. |
| The rawest material, not a summary. | sh question 2. | P | Loop 3. | RED: neither asked for real timings of the dashboard. |
| Methods and tools. | sh question 3. | P | Loop 4. | RED: no method named for the material. |
| An outside check, not the agent or the user. | sh question 4. | P, D | Loop 5. Red flags. | RED: Claude's check was its own request count. |
| Leave the user's choices open. | sh last line. | P, D | Loop 6. Red flags. | RED: both fixed the key and the TTL (60 s) for the user. |
| Deeper, not bigger. Keep goal and scope. | sh first line. | D | Loop 7. Rules. Red flags. | RED: Claude wrote a 50-line spec with a test list. Codex fixed the cache contract. |
| Rewrite the prompt and do not do the task. | changes. | P, D | Loop 8. Red flags. | RED: neither did the task. Kept as a guard. |
| `Principles applied: none` as the last line. | house form. Spec 8.7 lists no principle for this skill. | O | Output template. | GREEN |
| Four repo lines, verbatim. | house form. | D | Repo Rules. | Untested. |

## Cut

- changes: the Codex prompt wrapper and `poteto-mode` tool mapping. Skills here load the same way under both CLIs.
- audit SKIP verdict: its reason no longer holds, and the user asked for the skill.

## Pressure scenarios

RED (2026-11-04, no skill, `--tool both`, fixture `nc/repo`): make "Add caching to fetch_invoices so the dashboard loads faster" deeper, not bigger, and rewrite the prompt.
Failure: both made the task bigger. Claude wrote a 50-line spec with a 60 s TTL, a `client_id` key and six fixed tests. Codex fixed the cache contract. Neither asked to measure where the time goes first, or for real dashboard timings.

GREEN-1 (2026-11-04, same scenario, `--skill sharpen --tool both`). claude PASS. codex PASS.
RED failure gone: both put "measure first" and real request timings in the prompt, fixed no TTL or key, and left the staleness limit as an open question. Claude's prompt is 14 lines and says "If most of the time goes somewhere else, tell me before you build a cache."
