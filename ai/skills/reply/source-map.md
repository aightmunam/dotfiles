# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **pstack:** pstack-claude `plugins/pstack/skills/unslop/SKILL.md`, rules 20, 22, 23 and 24 (the reply-specific rules). `reply` cites them by number. Their text lives only in `ai/skills/unslop/rules.md`.
- **sp-rcr:** superpowers `skills/receiving-code-review/SKILL.md`, the forbidden responses, "Acknowledging Correct Feedback" ("Fixed. [what]", no gratitude), "When To Push Back" (technical reasoning).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 reply entry, and section 7 (reply voice evidence).
- **brief:** task 6.3 brief and dispatch (unslop interface, voice ruling: outcome first in 1 to 3 sentences, a SHA for each fix, past replies are not a style model).
- **unslop:** `ai/skills/unslop/SKILL.md` (output contract: one change line for each changed pattern, with one rule number).
- **agents:** `ai/AGENTS.md`, the `## Skill routing` row and the reply / address tie-break.
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (the form bar).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Classify each thread as fix, decline or answer. | sp-rcr (response pattern, evaluate then respond). spec 8.4. | P | Definitions. Loop 1. | GREEN: three threads, three classes. |
| Use only given facts. A fix with no SHA is a gap. Ask about one gap in each message, with a recommended answer. | brief (SHA per fix). Controller ruling (one question, recommended answer). sp-rcr ("I can't verify this without [X]"). | D | Loop 2. Rules. Red flags. | Untested. The scenario gives every SHA. |
| Outcome first. A fix starts with "Fixed in `<sha>`." An answer starts with the fact. | sp-rcr ("Fixed. [what]"). spec 8.4 (outcome first). brief voice ruling. | D | Loop 3. Rules. | GREEN |
| 1 to 3 sentences. No list. | spec 8.4. brief voice ruling. | D | Loop 3. Rules. Red flags. | RED: both wrote 4-sentence replies. |
| One SHA for each fix, in backticks. | spec 8.4 and section 7 (only the commit reference habit stays). brief. | D | Rules. Red flags. | RED: both left `abc1234` bare. |
| Backticks for each identifier. | spec 8.4. | D | Rules. Red flags. | RED: SHA and rule code bare. |
| A curly quote sends the draft back to unslop. | pstack 19. RED and GREEN-1: Codex kept a curly apostrophe. | D | Red flags. | GREEN-2: no curly quote. |
| Decline with one reason and its cost. | spec 8.4 (push back with the decision plus one reason, a decline states its cost). sp-rcr (technical reasoning). | D | Definitions. Rules. Red flags. | RED and GREEN: both gave the UP032 reason and the mixed-style cost. |
| No thanks. | sp-rcr ("ANY gratitude expression" is forbidden). spec 8.4. | D | Rules. Red flags. | RED: Claude wrote "Good catch, thanks." |
| "Good catch" needs a run, and names it. | spec 8.4. sp-rcr ("Good catch - [specific issue]"). | D | Definitions. Rules. Red flags. | RED: allowed in thread 1 (the scenario gives a failing test). |
| Unslop rules 20 and 22 (chatbot phrases, flattery). | pstack 20, 22. sp-rcr (forbidden "You're absolutely right!", "Great point!"). | D | Rules. Loop 4. | GREEN |
| Unslop rules 23 and 24 (filler, too much hedging). | pstack 23, 24. | D | Rules. Loop 4. | GREEN |
| Run the unslop skill on each draft. `reply` keeps no copy of the rule text. | brief interfaces. spec 8.4. | P | Loop 4. Red flags. Roles. | RED: no run made a pass. GREEN: both read unslop. |
| Output: each draft apart from the unslop change lines, as unslop wrote them. | unslop output contract (one line, one rule number). spec 8.4 (`address` posts the draft that the user OKs, so the draft stands alone). Audit: RED Claude used bold labels with colons (unslop rule 16). | O | Output template. Red flags. | GREEN |
| Add no fact. | unslop (add nothing). sp-rcr (verify before claim). | D | Rules. | RED: Claude added a note after the drafts. |
| Never post. The user or `address` posts after the user says yes. | spec 8.4 (address posting after the user OKs it). dispatch. | D | Roles. | RED and GREEN: no post. |
| Run inline. Return only the template to `address`. Fallback path for unslop. | spec 8.4 (used by `address` and on its own). | O | Roles. | GREEN: unslop at a given path. |
| `Principles applied:` line. | spec 8.7. reply has no principle targets. | O | Output template. | GREEN |

## Cut

- The user's past PR replies (login aightmunam) as a style model: spec section 7 and the voice ruling. Only the SHA habit stays.
- sp-rcr frontmatter description: it is not "Use when" triggers.
- sp-rcr implementation order, YAGNI grep, clarify all items first, one fix at a time with tests: these belong to `address`, which makes code changes.
- sp-rcr `gh api .../replies` posting line: posting belongs to `address` after the user says yes.
- sp-rcr "Gracefully correcting your pushback" and the uncomfortable pushback advice: `reply` drafts from given facts and does not change a decision.
- pstack rules other than 20, 22, 23 and 24: `unslop` applies all of them in Loop 4. `reply` names only the rules that shape the reply voice.
- The four repo lines: `reply` runs no command in a repo. `address` does the repo work.

## Pressure scenarios

Scenario: three review comments on acme/billing #42. Thread 1 is a valid bug, confirmed by a failing test and fixed in `abc1234`. Thread 2 is a style request (f-strings to `.format()`) that the user declines because ruff UP032 fails CI. Thread 3 is a question about `Decimal` and float. The file is `scratch-6.3/scenario.txt`. GREEN adds one line with the unslop path (`scratch-6.3/scenario-green.txt`).

**RED** (no skill, both CLIs, read-only):
Claude wrote "Good catch, thanks." and added a note after the drafts. Both wrote 4-sentence replies and left `abc1234` and UP032 without backticks. Codex used a curly apostrophe and a passive ("are converted"). Neither ran an unslop pass. The failure: thanks, too many sentences, and a bare SHA.

**GREEN** (skill, both CLIs, read-only, 2026-10-30):
Iteration 1 (`scratch-6.3/reply-green-1/`) passed the harness for both. Both read unslop `SKILL.md` and `rules.md`. No draft thanks the reviewer, each has 1 to 3 sentences, and each SHA and identifier is in backticks. Codex kept a curly apostrophe ("I’m"), and its unslop pass listed no change. The fix adds a rule 19 red flag.
Iteration 2 (`scratch-6.3/reply-green-2/`) passed for both. Each draft starts with its outcome, has at most 3 sentences, no list and no thanks. Each fix names `abc1234`. The decline gives the `UP032` reason and the mixed-style cost. Neither answer has a curly quote.
After iteration 2, a review tightened the wording with no rerun. An answer now starts with its fact (Claude put it in sentence 3 of thread 3). Loop 2 asks about one gap in each message. The SHA red flag splits into a missing SHA (step 2) and a bare SHA (step 3).
