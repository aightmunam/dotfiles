# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **pstack:** pstack-claude `plugins/pstack/skills/unslop/SKILL.md` (one file, rules 3 to 33).
- **agents:** `ai/AGENTS.md`, the `## Writing standard` section and the `## Skill routing` rows.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 unslop entry.
- **brief:** task 6.2 brief (output shape, the rule 13 conflict, the RED scenario).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (removed after eec5ad9; read it in git history) (the form bar).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "R" is `rules.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Rules 3 to 33 with the pstack numbers. A removed rule leaves a gap. | pstack (all rules). spec 8.4. | D | R. Loop 3. | GREEN-2 cited the wrong rule 17 for a removed heading. GREEN-3: each cited rule matches its change. |
| Rule 13 bans only the em dash. Parentheses stay. | Conflict: pstack rule 13 bans parentheses too. agents writing standard allows them and wins. spec 8.4. brief. | D | R 13. Rules. Red flags. | RED: Codex removed `(default 5)`. |
| Do not change code, commands, paths, quoted logs or quoted user text. | spec 8.4. brief. | D | Definitions. Loop 1. Loop 5. Red flags. | RED and GREEN: the pytest command stayed. |
| Keep the meaning and the tone. | pstack intro. spec 8.4. | D | Loop 2. Loop 4. Red flags. | RED: both removed the flag rename. |
| Keep every fact at its strength. A negation, a limit and a modal word are facts. No rule removes or weakens a fact. | pstack intro (keep the meaning). Audit: RED removed facts. Review C1: GREEN-2 Codex removed "not a refactor" and changed "never" to "reduce". | D | Definitions. Loop 2. Loop 4. Loop 5. Rules. Red flags. R intro. | GREEN-3: both keep "not a refactor" and "never". |
| Rule 9 keeps X and the negation when they are facts. | pstack 9. Audit: RED removed the rename. Review C1. | D | R 9. Rules. | GREEN-3 |
| Rule 27 removes only a sentence with no fact, instruction or number. | pstack 27. | D | R 27. Rules. | RED: both removed "a reliability fix". |
| Add nothing. | pstack intro (edit, do not add). Audit: RED Claude added advice. | D | Rules. Red flags. | RED: Claude added "add them" advice. |
| Output: the cleaned text, then one line for each changed pattern with its rule number. | brief interfaces. | O | Loop 7. Output template. | RED: no run gave rule numbers. |
| One line for each changed pattern, with exactly one rule number. | brief interfaces. Review I2: GREEN-2 Codex put four rules on one line. | O | Rules. Red flags. Output template. | GREEN-3: one number on each line. |
| Cite the rule whose text describes the change. Keep headings, lists and code blocks. | Review I1: GREEN-2 Claude removed a heading under rule 17. | D | Loop 3. Loop 4. Rules. Red flags. | GREEN-3: headings kept, citations match. |
| R 5 keeps the claim when the text gives no source. | pstack 5 says name the source or remove the claim. The no-fact-loss ruling (fix round 1) wins. | D | R 5. | Untested. |
| The change list obeys the rules. | pstack 13 and 16. Audit: RED Claude used bold labels with colons. | D | Rules. Red flags. | RED |
| `Principles applied:` line. | spec 8.7. unslop has no principle targets. | O | Output template. | GREEN |
| Write `<em dash>` for an old em dash in a change line. | brief (no em dash left). Audit: GREEN-1 quoted the old em dashes. | D | Rules. Red flags. | GREEN-1 failed. GREEN-2 passed. |
| The template is the full answer. | brief interfaces. Audit: GREEN-1 Claude added advice after the template. | O | Loop 7. Red flags. | GREEN-1 failed. GREEN-2 passed. |
| Run inline. Called by `reply`, `pr` or `ketchup`: return only the template. | spec 8.4 (reply runs it on each draft). | O | Roles. | Untested. No run called it from a skill. |

## Cut

- pstack frontmatter description: it is not "Use when" triggers.
- pstack rule 13, the bans on parentheses, en dashes and hyphen substitutes: the agents writing standard allows parentheses and wins (spec 8.4).
- pstack rule 14, the long example: R 14 keeps the rule.
- pstack rules 26, 27, 30 and 32, the long examples: the STE lint flags them. R keeps each rule and the word lists. R keeps each limit ("abstract", "as a metaphor", "as a noun") and the detection cue of rule 29.
- pstack rule 5, the removal of the claim: no rule removes a fact (fix round 1).
- The four repo lines: unslop edits text in the answer. It does not work in a repo.

## Pressure scenarios

Scenario: "Clean this PR body". The text has two em dashes, "delve", and a "doesn't just X, it's Y" frame. It has a "not X, it's Y" line, two three-item lists, and a closing offer of help. It has the command `python -m pytest tests/test_retry.py -k backoff --maxfail=1` and one parenthesis `(default 5)`. The file is `scratch-6.2/scenario.txt`.

**RED** (no skill, both CLIs, read-only):
Codex changed `(default 5)` to ", with a default of 5,". Both runs removed the flag rename and "a reliability fix" with no reason, so the meaning changed. Neither listed changes by rule number. Claude added advice and used bold labels with colons. Both kept the command and removed the em dashes.

**GREEN** (skill, both CLIs, read-only, 2026-10-30):
Iteration 1 passed the harness for both. It failed the brief check: both change lists quoted the old em dashes. Claude also added advice after the template. The fix adds the `<em dash>` rule and makes the template the full answer.
Iteration 2 passed for both. Each answer has 0 em dashes, the command byte for byte, and `(default 5)`. Each keeps the flag rename and the reliability fix, and cites rule numbers on each change line. Claude removed the `## Summary` heading and cited rule 17 for it. Codex changed "not a refactor" to "fixes retry reliability".
Iteration 3 ran after review fix round 1 (`scratch-6.2/unslop-green/`). It passed for both. Each answer has 0 em dashes, the command byte for byte, and `(default 5)`. Each keeps all headings, the flag rename, "never" and "not a refactor". Each change line cites one rule, and each rule matches its change. Codex wrote one rule 13 line for the two em dashes ("removed in both places").
