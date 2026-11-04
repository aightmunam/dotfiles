# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **teach:** pstack-claude `plugins/pstack/skills/teach/SKILL.md`.
- **how:** pstack-claude `plugins/pstack/skills/how` (SKILL.md, explorer-prompt.md, explainer-prompt.md).
- **why:** pstack-claude `plugins/pstack/skills/why` (SKILL.md, epistemics.md, synthesizer-prompt.md).
- **old:** the kept `explain_code` skill before 2026-11-04 (read it in git history). Only the chat scope and the plain text diagrams.
- **research:** `ai/skills/research/` (the shared gather step and the claim rules).
- **agents:** `ai/AGENTS.md`, `## Writing standard` (smallest answer first, no framing labels, diagram series).
- **user:** the request of 2026-11-04 to bring `explain_code` on par with how, why and teach.

Form key. P is a procedure step. D is a discipline with a red flag. O is an output.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Read the purpose and pick the takeaways. Do not quiz. | teach step 1. | P | Definitions. Loop 1. | RED: both answers explain every part at the same depth. |
| Narrow question: read it yourself. Wide: 2 to 4 explorer angles. | how steps 1 and 2. research Loop 3. | P | Loop 2. Roles. | RED: neither used the old skill's 3 forced explorers. |
| Open each file that you cite. | how explainer (check the code yourself). | P | Loop 2. | RED: both did. Kept as a guard. |
| Narrow why: git log, blame and the PR of the lines in question. Record empty searches. | why step 2. teach step 2 (keep why narrow). epistemics "When Evidence Is Missing". | P, D | Loop 3. Red flags. | RED: no git command in either run. |
| Code is not a source for its own reason. | why epistemics, synthesizer check 6. | D | Definitions. Red flags. | RED: Claude "The format depends on this", from the code. |
| Three wordings: sourced is plain, unsourced is hedged, missing is named. | why epistemics tiers (five cut to three wordings). research tags (verified, inferred). | D | Rules. Loop 6. | RED: both state reasons with no hedge and no source. |
| The user's guess is a candidate. | why epistemics (sycophancy trap). | D | Rules. | Untested. The scenario has no guess. |
| Smallest complete answer first. | teach step 3. agents writing standard. | P, D | Loop 4. Red flags. | RED: Claude opened well. Both then wrote 700 to 940 words. |
| Plain definition, then this code, then the mechanism. Teach, not list. | teach step 3. how explainer (prose, concrete). | P, D | Loop 5. Rules. | RED: both list functions with line ranges under section headers. |
| Diagram series for three or more parts. | teach step 5. agents writing standard. | P, D | Loop 5. Red flags. | RED: Claude drew one diagram with all parts. |
| Plain text diagrams in a fence. | old (ASCII). Audit: the T3 and terminal chat do not render mermaid. | D | Rules. | Untested. |
| No framing labels or step headers. | teach step 3 and style rules. agents writing standard. | D | Rules. Red flags. | RED: Claude used 4 headers, Codex 0 headers but 4 tables. |
| Apply the unslop rules yourself. | teach ("write through unslop"). | P | Loop 7. | Untested. |
| Offer one or two threads to go deeper. | teach step 4 and Reply. old step 5. | O | Loop 8. Red flags. | RED: no offer in either run. |
| Chat only. A written study goes to `research`. | old scope. AGENTS.md tie-break. | D | Rules. | Untested. |
| `Principles applied: none` as the last line. | house form. Spec 8.7 lists no principle for this skill. | O | Loop 8. Red flags. | GREEN |
| Four repo lines, verbatim. | house form. | D | Repo Rules. | Untested. |

## Cut

- old fixed answer template (Overview, Architecture, Data Flow, Edge Cases table, Questions, Further Reading): teach calls a fixed layout of labels a report, not teaching.
- old `model: opus` and three forced explorers: how sizes the gather to the question. The user's `/usage` showed subagents as the top cost.
- old Go examples: the skill is for any language.
- teach "run `how` and `why` as skill invocations": no `how` or `why` skill exists here. Loop 2 and Loop 3 hold their steps.
- teach image generation for spatial ideas: no image tool in the chat clients here.
- teach "no quizzes" and "no pacing theater": the RED runs showed neither. The no framing labels rule covers the pacing phrases.
- how explainer agent: the main agent explains. A second agent adds one more handoff.
- why seven evidence categories and parallel investigators: teach keeps why narrow. Jira or Sentry fit `research` step 5.
- why fixed output sections (What We Found, Competing Hypotheses, Sources Consulted, Confidence Summary): they are a report. The three wordings carry the confidence in chat.
- why "Claims about human decisions": rare in a code explanation. `research` is the place for a ruling with a scope.

## Pressure scenarios

RED (2026-11-04, old `explain_code`, `--tool both`, scenario: explain in chat how grimoire `app/data/parser.py` parses a review doc and why it splits on H1 only, for a user who will add a new H1 section).
Failure: neither run used git. Both gave the why from the code in confident words ("The format depends on this").
Both wrote 700 to 940 words of reference, with headers or tables. Claude drew one all-at-once diagram. Neither offered to go deeper.

GREEN-1 (2026-11-04, same scenario, `--tool both --expect-command 'git (log|blame)'`). claude PASS. codex PASS.
RED failure gone for the why: both ran git log, blame and show, cited `d2d4e28` and `a7d8d04`, and named the empty search. Both offered to go deeper.
Gaps: Claude drew three diagrams that did not redraw, and used bold label lines. Codex cited `prove-it-works`, a file that it read. Fix: two red flags and the principles line.

GREEN-2 (2026-11-04, same command). claude PASS. codex PASS. Both diagram series redraw and add one part. No headers or label lines.
Gap kept: Claude opens the why with an unsourced "because", then hedges it two sentences later. Both answers stay at 800 to 900 words, which teach allows for a one-shot run with no live user.
