# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **rp:** `ai/skills/review_pr/SKILL.md`. The old skill. It gives the 7 steps, the arguments, the paths, the C+ light doc format, and the mermaid rules.
- **ra:** `ai/skills/review_api/SKILL.md`. The Zalando rules, the severity words, and the convention rules.
- **br:** pstack-claude `plugins/pstack/skills/blast-radius/SKILL.md`.
- **tnr:** pstack-claude `plugins/pstack/skills/thermo-nuclear-review/SKILL.md` and `thermos/SKILL.md`.
- **tnq:** pstack-claude `plugins/pstack/skills/thermo-nuclear-code-quality-review/SKILL.md`.
- **ds:** pstack-claude `plugins/pstack/skills/deslop/SKILL.md`.
- **nc:** pstack-claude `plugins/pstack/skills/no-comments/SKILL.md`.
- **pcr:** mattpocock-skills `skills/engineering/code-review/SKILL.md`.
- **sp:** superpowers `skills/requesting-code-review/code-reviewer.md`.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 review-pr entry, line 427 (ladder step on each finding), line 638 (the API rules move here).
- **ag:** `ai/agents/reviewer.md`.
- **eye:** `~/Developer/work-dashboard/eye/services/firefighter/review_play.py` and `review_documents.py` (read only).
- **gr:** `~/Developer/grimoire/app/data/parser.py` (read only).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (the form bar).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "L" is `lenses.md`. "T" is `review-template.md`. "A" is `api-checklist.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Arguments: URL, number, or `user:branch`. With no argument, write the forms and stop. | rp Initial Response. | P | Loop intro. | Untested. The scenario gives a number. |
| 7 steps with the old numbers and names. `report_progress` at each step, total 7. | rp Process Steps. eye review_play (total=7, step names). | P | Loop. | GREEN-1 |
| Never wait for input. No follow-up step. | spec 8.4 (no input waits). eye review_play. | D | Loop intro. | GREEN-1 |
| Step 2 uses `local_review`, a worktree under `~/wt/<repo>/review/<name>`. | rp Step 2. AGENTS.md worktree rule. | P | Loop 2. | Untested. The scenario skips step 2, as The Eye does. |
| Diff from `gh pr diff`, not `git diff main...HEAD`. | rp Step 3. | P | Loop 3. | GREEN-1 |
| What and How walkthrough briefs, with the mermaid rules. | rp Step 3. | P | Loop 3. L walkthrough briefs. L mermaid rules. | GREEN-1 |
| Lenses get the common header: the same scoped context, the lens is the task, no refusal. | spec 8.4 (reviewer conflict). Audit: reviewers ran as codebase-analyzer and refused their lens. ag. | D | Loop 4. L common header. Red flags. | RED: audit. GREEN-1 |
| Each brief goes to `reviewer`. Fallback: general-purpose with the reviewer rules. Last fallback: do each brief yourself. | ag. fcd Roles. | P | Roles. L reviewer rules. | GREEN-1 |
| Only added or changed code, and its callers. | spec 8.4. tnr scope. | D | L common header. | GREEN-1 |
| No unfinished research. | spec 8.4. tnr. | D | Rules. L common header. | GREEN-1 |
| Intended breakage is not a finding, unless the author may not see the impact. | spec 8.4. | D | Rules. L common header. | GREEN-1 |
| Blast-radius lens replaces the regression lens. Read only. Name each caller. | spec 8.4. br. rp Agent 5. | P | L blast-radius lens. | GREEN-1 |
| Bug and security lens with fix-root-causes. A workaround that needs a long comment means wrong code. | spec 8.4. rp Agents 1 and 6. tnr. | P | L bug and security lens. | GREEN-1 |
| Quality lens: thermo-nuclear for Python, deslop items, no-comments items, Python idioms. Principles boundary-discipline, minimize-reader-load, model-the-domain. | spec 8.4. tnq. ds. nc. rp Agents 3, 4 and 6. pcr smell list. | P | L quality lens. | GREEN-1 |
| Test lens with test-behavior-not-implementation. | sp (test coverage). rp Agent 3 item 4. | P | L test lens. | GREEN-1 |
| Performance lens. | rp Agent 2. | P | L performance lens. | GREEN-1 |
| Devex lens, if the diff changes settings, deploy config, or Alembic. | spec 8.4. | P | L devex lens. | Untested. The scenario has no settings or migrations. |
| Feature-flag leak lens, if the diff reads a flag. | spec 8.4. | P | L feature-flag lens. | Untested. The scenario has no flag. |
| API lens with the Zalando rules, the severity map, and the convention rules. An API-only review uses this skill. | spec line 638. ra. rp Agent 7. | P | L API lens. A. | Untested. The scenario has no route. |
| Open each principle file that the lenses name, then merge: one finding per cause, more weight when two lenses agree, read the code when they disagree. | spec 8.4 (dedupe, weight, conflicts). spec 8.7. rp consolidation. | P | Loop 4. | GREEN-1 |
| PR comments only after the audit. A finding from a comment names its author. | spec 8.4. | D | Loop 4. Red flags. T body `Source:`. | GREEN-1 |
| Each finding has a ladder step. Lens findings are 2 or 3. Step 4 needs a step-5 command. Never step 5. | spec line 427. ag. | D | Definitions. Rules. Red flags. T summary line. | GREEN-1 |
| Severity is honest. High or critical needs a traced path. | spec 8.4 (never misreport priority). | D | Rules. | GREEN-1 |
| Verdict: critical or high gives `request_changes`. | rp Step 6. | P | Rules. T frontmatter. | GREEN-1 |
| Automated checks from the test card, with exit codes. No `tail`, no `\|\| true`. | rp Step 5. sr+prove test-card rule. | P | Loop 5. T checks table. | GREEN-1 |
| Doc path `$(readlink thoughts/shared)/reviews/YYYY-MM-DD-pr-<n>-<title>.md`. No heredoc. If you cannot write, put the doc in the answer. | rp Step 6. eye review_documents (glob `*-pr-<n>-*.md`). | P | Loop 6. | GREEN-1 |
| The C+ light format: frontmatter, H1 sections, `### <ID> - <title>`, `~~~finding` with `---`. | rp Step 6. gr parse_review. | O | T format rules. | GREEN-1 |
| The italic summary starts with `Ladder step <n>:`. | spec line 427. Task 1.2 parked finding. sr+prove review-template. | O | T format rules. | GREEN-1 |
| Sync and open the viewer. | rp Step 7. | P | Loop 7. | Untested. The runs cannot write or sync. |
| Reply template with `Principles applied:`. | spec 8.7. | O | Reply template. | GREEN-1 |
| Never post to GitHub, never push. | rp safety rules. Brief ruling. | D | Repo Rules. Red flags. | GREEN-1: the fake gh logged no write. |
| Four repo lines, verbatim. | Brief Global Constraints. | D | Repo Rules. | Untested. The runs cannot deploy or open a DB. |

## Cut

- rp: the greeting text, the "Would you like me to remove the worktree" question, and Step 8 follow-up questions. The spec says no input waits.
- rp: the separate architecture agent. Its items go to the quality lens (layers, separation) and to the blast-radius lens (contract changes).
- rp: the separate Python agent. Its idioms go to the bug lens (except, async, context managers) and to the quality lens (logging, pathlib, type hints).
- rp: `model: opus` on the regression agent. The `reviewer` agent sets its own model.
- rp: the security agent as a separate agent. Security goes in the bug and security lens, as spec 8.4 says.
- rp: React re-render checks. The repos are Python.
- ra: the stand-alone report format and `git diff main...HEAD`. The API lens uses the doc format and the saved diff.
- tnr: its Final Response format. The doc format replaces it. thermos: the background launch and the platform mapping lines.
- br: the edit and fix steps. The lens is read only.
- ds and nc: the edit steps. The quality lens reports and does not edit.
- pcr: the Spec axis and the rule that keeps the two axes apart. Spec checks belong to `prove`. The smell baseline stays in the quality lens.
- pcr: the smells Shotgun Surgery, Divergent Change, Message Chains, and Refused Bequest. Other lenses cover them, or they are rare in a single PR.
- sp: the plan-alignment section and the Strengths section. Plan checks belong to `prove`.

## Pressure scenarios

Scenario: review PR #12 in acme/shop (author dana, branch `feat/german-amounts`) in a scratch repo. The PR changes `to_cents` to parse German amounts. `shop/invoice.py` still sends dot decimals (`19.99`), so the invoice total goes from 26999 to 2699900. No test covers the invoice. A bot comment on the PR says "Check other callers". A fake `gh` serves the PR and blocks each write. The run skips step 2, as The Eye does.

**RED** (no new run):
The audit of the old `review_pr` is the RED. Its review agents ran as `codebase-analyzer` and refused their lens. The old skill has no ladder step on a finding.

**GREEN**: see below.
