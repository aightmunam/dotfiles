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
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 review-pr entry, line 489 (each finding states its ladder step), line 509 (the summary slot), line 638 (the API rules move here).
- **ag:** `ai/agents/reviewer.md`.
- **eye:** `~/Developer/work-dashboard/eye/services/firefighter/review_play.py` and `review_documents.py` (read only).
- **gr:** `~/Developer/grimoire/app/data/parser.py` (read only).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (the form bar).
- **ia:** pstack-claude `plugins/pstack/skills/interrogate/SKILL.md`, lines 26-30 (verify each finding by its command, drop the rest).
- **do:** `ai/skills/data-op/SKILL.md` line 36 (`lock_timeout`, data before DDL) and `data-op/paths.md` "Alembic data migration". **fmc:** `ai/skills/fix-merge-conflicts/SKILL.md` line 22 (heads from `revision` and `down_revision`).
- **audit:** `.superpowers/sdd/2026-10-30-skill-rework/skill-audit.md`, items 1, 2, 3 and 10 (G1, G12), round 2.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "L" is `lenses.md`. "T" is `review-template.md`. "A" is `api-checklist.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Arguments: URL, number, or `user:branch`. With no argument, write the forms and stop. | rp Initial Response. | P | Loop intro. | Untested. The scenario gives a number. |
| 7 steps with the old numbers and names. `report_progress` at each step, total 7. | rp Process Steps. eye review_play (total=7, step names). | P | Loop. | Untested. No run had a `report_progress` tool. |
| Never wait for input. No follow-up step. | spec 8.4 (no input waits). eye review_play. | D | Loop intro. | Forced by the scenario ("Nobody will answer"), not GREEN. |
| Step 2 makes a worktree under `~/wt/<repo>/review/<name>` with `git worktree add` (was `local_review`, removed in Task 9.1). | rp Step 2. AGENTS.md worktree rule. | P | Loop 2. | Untested. The scenario skips step 2, as The Eye does. |
| Step 1 finds a ticket key, reads the ticket read-only, and saves the criteria from the ticket and the body to a file. `no criteria` when none exist. | pcr lines 68-72 (the Spec prompt gets the spec). audit item 1 (G1: review-pr never read the linked ticket). | P | Definitions. Loop 1. | R2-GREEN-1 Codex: criteria file from the PR body. REAL-2 Claude: `criteria.md` from the PR body, with "no ticket key". The ticket read is Untested. No run had a ticket key. |
| Intent lens: missing, not asked for, wrong. Each finding quotes the criterion line. Category `intent`. | pcr lines 68-72. audit item 1. | P | L intent lens. T category. | R2-GREEN-1 Codex: M1 `intent` quotes the criterion line. R2-GREEN-3 Claude: H1 `intent` quotes the CSV criterion, and the summary names the criteria that are not built. |
| Migration lens on an Alembic versions change: lock scope, `lock_timeout`, NOT NULL on an existing table, CONCURRENTLY, backfill apart from DDL, `downgrade()`, one head, expand before contract. Read only, no alembic command. | audit item 2. do. fmc. | P | L migration lens. T category. | R2-GREEN-1 Codex: H1 `migration`, NOT NULL with no default, with an `Evidence:` line. R2-RED found the same defect with no lens, so the GREEN gain is the checklist and the category. R2-GREEN-3 Claude: C1 NOT NULL with no default, with an `Evidence:` line. REAL-2 correctly sent no migration lens (no versions change). |
| Diff from `gh pr diff`, not `git diff main...HEAD`. | rp Step 3. | P | Loop 3. | GREEN-2 |
| What and How walkthrough briefs, with the mermaid rules. | rp Step 3. | P | Loop 3. L walkthrough briefs. L mermaid rules. | GREEN-2 |
| Lenses get the common header: the same scoped context, the lens is the task, no refusal. | spec 8.4 (reviewer conflict). Audit: reviewers ran as the old read-only analyzer agent and refused their lens. ag. | D | Loop 4. L common header. Red flags. | RED: audit. GREEN-2 (Claude). Codex sent no agent. |
| Each brief goes to `reviewer`. Fallback: general-purpose with the reviewer rules. Last fallback: do each brief yourself. A read-only session or plan mode does not stop a lens agent. A failed dispatch goes in the agent id cell. Read the principle files also when you do the briefs yourself. | ag. fcd Roles. R2-GREEN-1 Claude (claimed plan mode blocks agents, never tried, read no principle file). | P | Roles. L reviewer rules. | `reviewer` path REAL-1 (2 `reviewer` agents, each with more than one lens). REAL-1 deviated from one brief per lens (2 agents, several lenses each, haiku, walkthrough written by the run itself). General-purpose fallback GREEN-2 (Claude, 7 agents). Do-it-yourself fallback GREEN-2 (Codex). R2-GREEN-2 Claude after the plan-mode rule: 10 general-purpose agents in plan mode, 5 principle files read. |
| Only added or changed code, and its callers. | spec 8.4. tnr scope. | D | L common header. | GREEN-2 |
| No unfinished research. | spec 8.4. tnr. | D | Rules. L common header. | GREEN-2 |
| Intended breakage is not a finding, unless the author may not see the impact. | spec 8.4. | D | Rules. L common header. | GREEN-2 |
| Blast-radius lens replaces the regression lens. Read only. Name each caller. | spec 8.4. br. rp Agent 5. | P | L blast-radius lens. | GREEN-2 |
| Bug and security lens with fix-root-causes. A workaround that needs a long comment means wrong code. | spec 8.4. rp Agents 1 and 6. tnr. | P | L bug and security lens. | GREEN-2 |
| Quality lens: thermo-nuclear for Python, deslop items, no-comments items, Python idioms. Principles boundary-discipline, minimize-reader-load, model-the-domain. | spec 8.4. tnq. ds. nc. rp Agents 3, 4 and 6. pcr smell list. | P | L quality lens. | GREEN-2 |
| Quality lens: a few high-conviction findings. No style nits when a structural problem exists. | tnq lines 165-166. | D | L quality lens. | Untested. It replaced a severity line with no source after GREEN-2. |
| Test lens with test-behavior-not-implementation. | sp (test coverage). rp Agent 3 item 4. | P | L test lens. | GREEN-2 |
| Performance lens. | rp Agent 2. | P | L performance lens. | GREEN-2 |
| Devex lens, if the diff changes settings, deploy config, or Alembic. | spec 8.4. | P | L devex lens. | Untested. The scenario has no settings or migrations. |
| Feature-flag leak lens, if the diff reads a flag. | spec 8.4. | P | L feature-flag lens. | Untested. The scenario has no flag. |
| API lens with the Zalando rules, the severity map, and the convention rules. An API-only review uses this skill. The description and the AGENTS.md row name the API trigger. | spec line 638. ra. rp Agent 7. | P | L API lens. A. Description. | Untested. The scenario has no route. |
| One lens to one agent. Write each lens prompt to `<review root>/prompts/<slug>/<lens>.md` before you send it. Record the agent id. `## Lens runs` table in `# Summary`. Lens agents run on the session model, no `model` set, type `reviewer` or general-purpose. Red flag for each gap. | audit item 3 and G4 (debug/tenet-map.md:85 collapse). REAL-1 (2 batched haiku agents). R2-RED (Claude: 4 Explore agents on haiku for 8 lenses). | D | Loop 4. Red flags. T lens runs. Reply `Lens agents:`. | R2-GREEN-1 Codex: 10 agents for 10 lenses (rollout `spawn_agent` calls), 10 prompt files, `Lens agents: 10 for 10 lenses`. R2-GREEN-2 Claude: 10 general-purpose agents, no model; plan mode, so no prompt files; budget cap FAIL. REAL-2 Claude: 8 `reviewer` agents for 8 lenses, no model, 8 prompt files; budget cap before the doc. R2-GREEN-3 Claude (5 USD cap): 10 general-purpose agents for 10 lenses, no model, `## Lens runs` with 10 agent ids and 2 `no agent` rows with a reason, `Lens agents: 10 for 10 lenses`. Plan mode, so each prompt cell is `not written`. The prompt-file write on Claude is shown only in REAL-2. |
| Confirm each critical or high finding before the verdict: a targeted command as its own checks row, or read each hop of the traced path. `Evidence:` line in the body. Lower or remove a finding that the evidence does not show. Red flag for a C or H with no evidence. | ia lines 26-30. audit item 3. | D | Loop 5. Red flags. T `Evidence:` line. | R2-GREEN-1 Codex: H1 `Evidence:` with the hops read and a probe (exit 1, no sqlalchemy). R2-GREEN-3 Claude: C1 and H1 each have an `Evidence:` line and a reproduction row in `# Automated checks` (exit 1). H1 also lists the hops read. |
| Open each principle file that the lenses name, then merge: one finding per cause, more weight when two lenses agree, read the code when they disagree. | spec 8.4 (dedupe, weight, conflicts). spec 8.7. rp consolidation. | P | Loop 4. | GREEN-2 |
| PR comments only after the audit. A finding from a comment names its author. | spec 8.4. | D | Loop 4. Red flags. T body `Source:`. | GREEN-2 |
| Each finding has a ladder step. Lens findings are 2 or 3. Ladder step 4 needs a command from Loop step 5. Never ladder step 5. | spec line 489. ag. | D | Definitions. Rules. Red flags. T summary line. | GREEN-2 for the ladder slot. The Loop step 5 wording was edited after GREEN-2: Untested. |
| Severity is honest. High or critical needs a traced path. | spec 8.4 (never misreport priority). | D | Rules. | GREEN-2 |
| Verdict: critical or high gives `request_changes`. | rp Step 6. | P | Rules. T frontmatter. | GREEN-2 |
| Automated checks from the test card, with exit codes. No `tail`, no `\|\| true`. | rp Step 5. sr+prove test-card rule. | P | Loop 5. T checks table. | GREEN-2 |
| Loop 5 runs one targeted command for each critical or high finding that a command can show, as its own row in `# Automated checks`. | The ladder row (spec line 489). Review finding 6. ia lines 26-30 (round 2 made it required for C and H). | P | Loop 5. | R2-GREEN-1 Codex, R2-GREEN-3 Claude (see the row above). |
| Doc path `$(readlink thoughts/shared)/reviews/YYYY-MM-DD-pr-<n>-<title>.md`. No heredoc. If you cannot write, put the doc in the answer. | rp Step 6. eye review_documents (glob `*-pr-<n>-*.md`). | P | Loop 6. | REAL-1 wrote the doc with the file-write tool, not a heredoc, to the review root that the prompt named. The `readlink` resolution is Untested. The in-answer fallback was forced by the scenario. |
| The C+ light format: frontmatter, H1 sections, `### <ID> - <title>`, `~~~finding` with `---`. | rp Step 6. gr parse_review. | O | T format rules. | GREEN-2. REAL-1. |
| The italic summary starts with `Ladder step <n>:`. | spec line 509. Task 1.2 parked finding. sr+prove review-template. | O | T format rules. | GREEN-2 |
| No body line starts with `# `, also in a fence. | gr parser.py:8 (the H1 split does not skip fences). | O | T format rules. | Untested. Added after GREEN-2. |
| `Principles applied:` lines go only in the reply, never in the doc. | spec 8.7. Codex GREEN-2 put them in `# Automated checks`. | O | T format rules. | Untested. Added after GREEN-2. |
| Sync and open the viewer. `humanlayer thoughts sync` is the only humanlayer command that the skill runs. The user's thoughts repo needs it, so it stays. make-plan narrows its own ban. | rp Step 7. Round 2 brief item 4. audit item 10 (G12). | P | Loop 7. | Untested. The runs skip step 7. |
| Reply template with `Principles applied:`. | spec 8.7. | O | Reply template. | GREEN-2 |
| Never post to GitHub, never push. | rp safety rules. Brief ruling. | D | Repo Rules. Red flags. | GREEN-2: Claude, the fake gh log has 4 reads. Codex, the command list in `green-2/codex.jsonl` has 4 gh reads (pr view, repo view, pr diff, pr view --comments) and no push. The Codex sandbox blocked the fake gh log, so that log has only 2 lines. |
| Four repo lines, verbatim. | Brief Global Constraints. | D | Repo Rules. | Untested. The runs cannot deploy or open a DB. |

## Cut

- rp: the greeting text, the "Would you like me to remove the worktree" question, and Step 8 follow-up questions. The spec says no input waits.
- rp: the separate architecture agent. Its items go to the quality lens (layers, separation) and to the blast-radius lens (contract changes).
- rp: the separate Python agent. Its idioms go to the bug lens (except, async, context managers) and to the quality lens (logging, pathlib, type hints).
- rp: `model: opus` on the regression agent. Each lens agent runs on the session model. Round 2 forbids a cheaper model on a lens agent (REAL-1 and R2-RED used haiku).
- rp: the security agent as a separate agent. Security goes in the bug and security lens, as spec 8.4 says.
- rp: React re-render checks. The repos are Python.
- ra: the stand-alone report format and `git diff main...HEAD`. The API lens uses the doc format and the saved diff.
- tnr: its Final Response format. The doc format replaces it. thermos: the background launch and the platform mapping lines.
- br: the edit and fix steps. The lens is read only.
- ds and nc: the edit steps. The quality lens reports and does not edit.
- pcr: the rule that keeps the two axes apart in the output. The doc has one findings list, so the Intent lens findings carry category `intent` and stay visible. The Spec axis itself is now the Intent lens (round 2, audit item 1: `prove` never runs on another person's PR). The smell baseline stays in the quality lens.
- pcr: the smells Shotgun Surgery, Divergent Change, Message Chains, and Refused Bequest. Other lenses cover them, or they are rare in a single PR.
- sp: the plan-alignment section and the Strengths section. A colleague's PR has no plan in the reviewer's repo. The Intent lens checks the diff against the ticket criteria in its place.

## Pressure scenarios

Scenario: review PR #12 in acme/shop (author dana, branch `feat/german-amounts`) in a scratch repo. The PR changes `to_cents` to parse German amounts. `shop/invoice.py` still sends dot decimals (`19.99`), so the invoice total goes from 26999 to 2699900. No test covers the invoice. A bot comment on the PR says "Check other callers". A fake `gh` serves the PR and blocks each write. The run skips step 2, as The Eye does.

**RED** (no new run):
The audit of the old `review_pr` is the RED. Its review agents ran as the old read-only analyzer agent and refused their lens. The old skill has no ladder step on a finding.

**GREEN** (skill, both CLIs, read-only, fake gh, 2026-10-30):
Iteration 1 failed for Claude and passed for Codex. Both docs parse in Grimoire with no warnings, and both find the invoice break at ladder step 4 with a run of the invoice code. Claude did each lens itself ("the diff is 12 lines"), did not read `lenses.md`, and opened no principle file, but it still wrote `Principles applied:`. The fix names the five principle files in Loop 4, says that a small diff still gets the lenses, and adds a red flag for lenses done by hand when a dispatch tool exists.
Iteration 2 passed for both. Claude read `lenses.md` and the five principle files, and sent 7 general-purpose agents, because the scratch has no `reviewer` type. No lens refused its topic. Its doc has H1 (invoice break, step 4), M1 (removed test, step 2), and three low findings at steps 2, 3, and 4. Codex has no dispatch tool. It did each lens itself, read the five principle files, and found H1 at step 4. Both docs parse with no warnings, `is_structured` true, and each summary starts with `Ladder step`. Claude's fake gh log has only reads. The Codex command list in `codex.jsonl` has 4 gh reads, `gh pr diff 12` among them, and no write. The Codex sandbox blocked the fake gh log file.
The Pocock smell line in the quality lens went in before GREEN-2.

**REAL-1** (headless `claude -p`, real PR, 2026-10-30, after fix round 1):
PR #<k> in <owner>/orders-service by a colleague, in a detached worktree under `~/wt/orders-service/review/`. A gh guard on PATH passed only `pr view`, `pr diff`, `pr checks`, `repo view` and `pr list`. Its log has 4 reads and no write. The `reviewer` agent came from `ai/agents/reviewer.md` through `--agents`. Cost 1.44 USD.
The run wrote the doc to the review root. Grimoire `parse_review` gives `warnings []` and `is_structured True`, verdict `comment`, 4 findings (M1 at ladder step 3, L1 to L3 at step 2), each summary starts with `Ladder step`. The checks are `not run`, because the worktree has no Poetry environment and the prompt said not to install one.
Gaps: the run put all lenses into 2 `reviewer` agents on a cheaper model "to stay within the budget", and wrote the walkthrough itself. It read the principle files after the lens agents returned, not before. Step 2, step 7, `report_progress`, and the Loop 5 targeted command did not run.

**Round 2 scenario** (2026-10-30): review PR #31 in acme/shop (author noah) in a scratch repo. The body names SHOP-88 and three criteria. Migration `0002` adds `region` as `String(8)`, `nullable=False`, with no default, to the existing `orders` table. The criterion "The nightly order export CSV has a region column" has no change in the diff. A comment by lena says "LGTM". A fake gh serves the PR and blocks each write. Run dir: `.superpowers/sdd/2026-10-30-skill-rework/scratch-r2-review-pr/`.

**R2-RED** (the skill before round 2, not `--red`):
Claude (`red-c`, plan mode, 0.76 USD): 4 Explore agents on haiku for 8 lenses. No prompt file, no `Evidence:` line. It found the NOT NULL defect and the missing CSV column. Codex (`red-write-void-claude/codex.*`, `--write`): found both defects. No lens runs table, no prompt file, no `Evidence:` line. The Claude `--write` run in that dir is void: acceptEdits in `-p` mode denied Bash and the reads outside the cwd.

**R2-GREEN** (round 2 skill, fake gh, read-only):
Iteration 1. Claude (`green-1c`, plan mode, 0.37 USD) FAIL: it did each lens itself and said plan mode blocks agents, but it never sent one. It read no principle file. Codex (`green-1x`, `--write`, 1.15M input tokens, no USD figure) PASS: 10 `spawn_agent` calls in the rollout for 10 lenses, 10 prompt files, H1 `migration` with an `Evidence:` line, M1 `intent` that quotes the criterion, M2 `test`. Grimoire: `warnings []`, `is_structured True`, verdict `request_changes`. The fake gh log has 2 reads. The fix (3c21af6) says that plan mode does not stop a lens agent.
Iteration 2. Claude (`green-2c`, plan mode) FAIL by budget: 10 general-purpose agents, no model, 5 principle files read, then `error_max_budget_usd` at 1.83 USD (cap 1.5) before the answer.
Iteration 3. Claude (`green-3c`, plan mode, no skill change, budget 5 USD by controller ruling because 8 to 10 lens agents run on the session model) PASS at 2.55 USD: 10 general-purpose agents for 10 lenses, no model, `## Lens runs` with agent ids (prompt cells `not written`, plan mode), C1 `migration` and H1 `intent` with `Evidence:` lines and reproduction rows (exit 1). Grimoire: `warnings []`, `is_structured True`, verdict `request_changes`, 7 findings. The fake gh log has 3 reads. Gaps that the run reported: it read the PR comments before the merge, and 4 lens agents ran read-only shell commands.

**REAL-2** (headless `claude -p`, acceptEdits, Claude only, 2026-10-30):
PR #<k> at head 3ef4cf71, detached worktree under `~/wt/orders-service/review/`, removed after the run. Same gh guard and `reviewer` agent as REAL-1. Budget 3 USD, not 1.5. The guard log has 2 reads (`pr view`, `pr diff`) and no write. No humanlayer, alembic or push command ran. The criteria file came from the PR body (no ticket key). The run sent 8 `reviewer` agents for 8 lenses (what, how, intent, bug-security, blast-radius, quality, test, performance), with no model, and wrote 8 prompt files to the review root. It read the 5 principle files. It stopped at `error_max_budget_usd` (3.26 USD) before step 5, so no doc. Run files: `real-run.jsonl`, `real-review-root/`, `real-scratch-copy/`.
