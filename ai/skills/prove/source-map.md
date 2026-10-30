# Source Map

`ai/sources.lock` pins the sources. pstack paths are under `~/Developer/ref/pstack-claude/plugins/pstack/skills/`.

- **int:** `interrogate/SKILL.md` (adversaries, the brief, rerun each finding, Dropped).
- **br:** `blast-radius/SKILL.md` (the ladder, the one safety fact, look where grep stops, Cleared).
- **cvs:** `create-verification-skill/SKILL.md` (the `verify` sections, proof standards).
- **bc:** `benchmark-checklist/SKILL.md` (speed claims, only through `performance`).
- **sw:** `swarm/SKILL.md` (record the SHA and the method, a gap is not a pass, a worker that drops out).
- **sc:** `statechart/SKILL.md` Hand off (replay each bug path against the real code).
- **fio:** `figure-it-out/SKILL.md` Phase C (VERIFIED, NOT VERIFIED, INCONCLUSIVE. Inconclusive is not a pass.).
- **smyw:** `show-me-your-work/SKILL.md` (Attention section with the reviewer model and flags as pointers. Append-only rows.).
- **ket:** `ketchup/SKILL.md` (item: link, change, evidence, risk, pick).
- **sp:** `~/Developer/ref/superpowers/skills/verification-before-completion/SKILL.md` (the gate: identify, run, read, then claim).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 prove entry, section 8.5 (adversary is a brief in `roles.md`), section 10 (uncommitted change, `kind: self-review`, base SHA plus diff hash). Section 10 also puts the ladder step in the italic summary line.
- **brief:** task 5.1 brief (files, frontmatter keys, `git diff | shasum`, `~/wt/<repo>/prove-<n>`, Grimoire parse) and the controller dispatch (interfaces of `performance`, `verifier`, `tdd`).
- **rpr:** old `ai/skills/review_pr/SKILL.md` Step 6 (review root, C+ light format rules, no shell heredoc).
- **perf:** `ai/skills/performance/SKILL.md` (dispatch line and report labels).
- **ver:** `ai/skills/verifier/verify-template.md` (Launch, Doctor, Drive, Evidence, Cleanup).
- **tdd:** `ai/skills/tdd/SKILL.md` Loop 3 (`Assumed:` and `Open:` lines).
- **piw:** `ai/principles/prove-it-works.md`.
- **mp:** `ai/skills/make-plan/` (test card path, plan `status` values, main-checkout rule).
- **ctl:** controller rulings in `parallel-dispatch.md` (one question per message with a recommended answer, never-block-on-the-human, principle pointer form, four repo lines).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output. "Loop N" is a step in SKILL.md. "T" is `review-template.md`. "R" is `roles.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Work on the uncommitted diff. Record `base_sha`, `head_sha`, and `diff_hash` (`git diff \| shasum`). | spec 10. brief. sw Phase A step 4 (record SHAs). | P | Definitions. Loop 1. T frontmatter. Reply template. | RED: neither doc had a diff hash or the frontmatter keys. |
| `git add -N` each new file, so that the diff and the adversary patch hold it. | spec 10 (worktree at HEAD with the diff applied). | P | Loop 1. | Untested. The scenario adds no file. |
| Read the plan, the task, the diff, and the test card. A missing card: take the commands from the repo config and say so. | spec 8.4 (consumes the plan, the diff, the test card). mp Loop 2. | P | Loop 1. | GREEN |
| State the intent in one sentence. A finding must break the intent. | int Frame and Verify. | P | Loop 1, Loop 5. T Summary. | GREEN |
| Ladder of five steps. Each finding carries its step. | br How sure are you. spec 8.4, spec 10 (italic summary line). | O | Definitions. T finding summary. | RED: no run gave a ladder step. |
| Name the one safety fact. Prove it at ladder step 4, or write "unproven". | br Steps 2 and 5. spec 8.4. | D | Definitions. Loop 2. Red flags. Outcome rule. | RED: no run named a safety fact. |
| Look past grep: data files, wire formats, DB columns, flags. | br Step 3. | P | Loop 2. R brief. | GREEN |
| Principle pointer at Loop 3. | piw. spec 8.7. ctl. | P | Loop 3. Red flags. Reply template. T last line. | GREEN |
| Read the exit code. `\| tail`, `; true`, `\|\| true` hide it. | piw ("Output cut by \| tail -1 ... prove nothing"). brief Review Focus 1. | D | Rules. | GREEN |
| Run the repo `verify` skill when it exists: Launch, Doctor, Drive, Evidence, Cleanup. | spec 8.4. cvs section 2. ver. | P | Loop 3. | Untested. The scratch repo has no `verify` skill. |
| A speed claim goes to `performance`. The prompt opens with "The prove skill dispatched you". Copy its five labels. With no dispatch, do the skill yourself. | spec 8.4. bc (owned by perf). perf Loop 7. | P | Loop 3. | Untested. The scenario has no speed claim. |
| Two blind adversaries, one Claude and one Codex, each in `~/wt/<repo>/prove-<n>` at HEAD with the diff applied. They get the diff, the plan, the task, and not the session reasoning. | spec 8.4, spec 8.5, spec 10. brief. int Fan out. | P | Loop 4. R. | Untested. The headless runs cannot make a worktree. |
| Adversary brief: break the change and prove each finding with a run. Report the command, the output, and the needed output. Leave out each finding with no run. No findings is valid. | int brief. | P | R Brief. | Untested (see the row above). The inline fallback ran in GREEN. |
| Fallback: no worktree or no dispatch, run the brief yourself, label it inline, flag it under Attention. One adversary missing: go on, record the gap. | sw Phase B (proceed with N-1, note it). sw Phase C (a gap is not a pass). Form bar (roles with a fallback). | P | R Fallback. | GREEN |
| Rerun each finding command. Keep only failures that break the intent. Drop the rest with the reason. Merge findings with one cause. | int Verify. spec 8.4 (the parent reruns every command, and unrun findings drop). | D | Loop 5. Red flags. T Dropped. | GREEN |
| Replay each counterexample one step at a time against the real code. | sc Hand off. spec 8.4. | P | Loop 5. | GREEN |
| A clear fix inside the plan: make it, rerun, new `diff_hash`. A fix with two forms or a plan change: ask, one question per message, with a recommended answer and the ketchup item parts. | spec 8.4 (stops for user decisions, fixes in the same session, each fix reruns the affected checks). ctl (never-block, one question). ket. | D | Loop 6. Decision template. Red flags. | GREEN |
| No user: `Assumed:` with a source, else `Open:` and no fix. | tdd Loop 3. brief dispatch. | D | Loop 6. Reply template. | GREEN |
| Review root: the `thoughts/shared` link target plus `/reviews`, else `thoughts/shared/reviews`. Main checkout in a worktree. File `YYYY-MM-DD-self-<topic>.md`. | rpr Step 6. mp Loop 7. brief (review root that review_pr writes). | P | Loop 7. | Untested. The runs cannot write. |
| No shell heredoc for the doc. A hook removes lines whose first character is `#`. | rpr Step 6. | D | Loop 7. | Untested. The runs cannot write. |
| C+ light doc: `kind: self-review`, quoted SHAs, H1 sections, `### <ID> - <title>`, italic ladder summary, `~~~finding` block, Status cell `pass`, `fail`, or `inconclusive`. | rpr format rules. brief (Grimoire parse with no warnings). spec 10. | O | T. | RED: neither doc parsed as structured (`is_structured` False, 0 findings). |
| `# Attention` names the reviewing model and lists flags as pointers. | smyw Cross-model review. spec 8.4. | O | T Attention. | GREEN |
| Close the plan: tick boxes with a VERIFIED check, name the check, add `## Deviations` from `git log` plus the diff, never change an old row, set `status`. | spec 8.4 (closes the plan). brief. smyw Rules (append-only). mp (status values). | P | Loop 8. Red flags. Reply template. | RED: both rewrote the plan steps and boxes. |
| Each check has its command and output. "Tests pass" with no command is not a check. | int Output. piw. sp verification-before-completion (gate). spec 8.4. | D | Rules. Red flags. | RED: both runs gave commands, so this held already. |
| A gap is not a pass. An unrun check is INCONCLUSIVE. | sw Phase C. fio Phase C. spec 8.4. | D | Definitions. Rules. | GREEN |
| Outcome from the checks: any finding gives NOT VERIFIED, then INCONCLUSIVE, then VERIFIED. | fio Phase C. spec 8.4. | O | Rules. T frontmatter. Reply template. | GREEN |
| Each check names the `diff_hash` that it ran against. Rerun after a fix. | sw Phase A step 4 (SHAs and method). spec 10 (each fix reruns the affected checks). | D | Rules. | Untested. No run made a fix. |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. R Brief (three of them). | Untested. The runs do not touch prod. |

## Cut

- int: the Models and Reasoning effort sections, the four pstack reviewer models, and arena Phases C to E. This setup has two fixed adversaries: one Claude, one Codex (spec 8.4).
- int: "Report the findings. Do not apply fixes." The spec says fixes happen in the same session (spec 8.4).
- br: the `why` and `how` skill calls, the `arena` run for a wide change, and the `unslop` pass. The two adversaries cover the second view. `unslop` is for text that goes public, and the doc stays in thoughts.
- br: "Before you merge: the cheapest test". The finding body carries the command that catches the bug.
- cvs: sections 1, 3, 4, and 5 (interview, feature map, prove the generated skill, maintenance). `verifier` owns them. prove only runs an existing `verify` skill.
- bc: the seven questions. `performance` owns them. prove copies its report labels.
- sw: the todolist, race shapes (`first pass`, `rank all`, `best-of`), and the model sheet. prove has two fixed workers and no race.
- sc: the TLA+ model, the chart, and TLC. Only the replay rule survives.
- smyw: the TSV log, `log.sh`, and the transcript audit. The plan `## Deviations` section holds the trail (spec 8.4 build). The adversaries are the cross-model view.
- fio: Phases A, B, D, and E. `make-plan` and `build` own the playbook. Only the three outcomes survive.
- rpr: the What and How analyst sections, Mermaid diagrams, the Zalando check, and `humanlayer thoughts sync`. A self-review needs no PR walkthrough. spec 8.4 make-plan removes the humanlayer residue.
- rpr: "Write the review document with the Write tool". A controller ruling forbids a sentence that names a file tool. The heredoc warning stays.

## Principles

- prove-it-works: pointer at Loop 3 (the check step), with its key sentence inline. The Rules carry "the exit code counts" and "no command, no claim".

## Pressure scenarios

Scenario (`scratch-5.1/scenario.txt`): the git repo `scratch-5.1/repo` has one commit and an uncommitted change. `to_cents` now parses German amounts (`1.234,56`), and the updated `tests/test_money.py` passes. The caller `shop/invoice.py` reads `data/lines.csv` with dot amounts (`19.99`), so its total goes from 26999 to 2699900. No test covers the caller. The plan `thoughts/shared/plans/2026-10-30-german-amounts.md` has `status: in-progress` and a manual box for callers. The runs cannot write, so the doc and the plan edits go in the answer.

**RED** (no skill, both CLIs, read-only, 2026-10-30, budget 1.5):
- Both CLIs found the caller break with commands (2699900 against 26999). The failure is the form, not the finding.
- Neither doc parsed as structured in Grimoire `parse_review` (`is_structured` False, 0 findings). Neither had `kind: self-review`, `base_sha`, or `diff_hash`.
- Neither named a safety fact or a ladder step. Neither ran an adversary pass.
- Both rewrote the plan steps and boxes. Neither ticked boxes with evidence or added `## Deviations`.
- Cost: claude 0.35 USD. codex 434k input tokens (391k cached), 4.8k output tokens.

**GREEN** (skill, both CLIs, read-only, 2026-10-30, `--principle prove-it-works`, budget 1.5):
- Harness: claude PASS, codex PASS (skill loaded, principle read, `Principles applied:` line in the answer).
- Both gave NOT VERIFIED at base_sha 5e853ae, diff_hash 51a907a3. Both found H1 at ladder step 4 with the command and its output, and named the safety fact.
- Both docs parse in Grimoire `parse_review` with warnings `[]`, `is_structured` True, one finding, and pass and fail check rows.
- Both used the inline adversary fallback and flagged it under `# Attention`. Both asked one decision with a recommended answer. Both left the plan `in-progress`, ticked 4 of 5 boxes with check names, and added `## Deviations`.
- Gaps: codex added a second `Principles applied:` line for `fix-root-causes` (it read that file), and its Attention line has no "reviewed by".
- Cost: claude 0.46 USD. codex 229k input tokens (201k cached), 5.3k output tokens.
