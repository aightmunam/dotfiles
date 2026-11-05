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
- **ket:** `catch-up/SKILL.md` (item: link, change, evidence, risk, pick).
- **sp:** `~/Developer/ref/superpowers/skills/verification-before-completion/SKILL.md` (the gate: identify, run, read, then claim).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 prove entry, section 8.5 (adversary is a brief in `roles.md`), section 10 (uncommitted change, `kind: self-review`, base SHA plus diff hash). Section 10 also puts the ladder step in the italic summary line.
- **brief:** task 5.1 brief (files, frontmatter keys, `git diff | shasum`, `~/wt/<repo>/prove-<n>`, Grimoire parse) and the controller dispatch (interfaces of `performance`, `verifier`, `tdd`).
- **rpr:** old `ai/skills/review_pr/SKILL.md` (removed after eec5ad9. Read it in git history) Step 6 (review root, C+ light format rules, no shell heredoc).
- **perf:** `ai/skills/performance/SKILL.md` (dispatch line and report labels).
- **ver:** `ai/skills/verifier/verify-template.md` (Launch, Doctor, Drive, Evidence, Cleanup).
- **tdd:** `ai/skills/tdd/SKILL.md` Loop 3 (`Assumed:` and `Open:` lines).
- **piw:** `ai/principles/prove-it-works.md`.
- **mp:** `ai/skills/make-plan/` (test card path, plan `status` values, main-checkout rule).
- **ctl:** controller rulings in `parallel-dispatch.md` (one question per message with a recommended answer, never-block-on-the-human, principle pointer form, four repo lines).
- **fr1:** controller rulings for fix round 1 of task 5.1. C1: the change is the diff from the merge-base. I1: `add -N` in the worktree. I2: no pipe in a cell. M4: the Deviation row of `build`.
- **bld:** `ai/skills/build/SKILL.md` Definitions (Deviation row: append-only, the evidence is a pointer).
- **audit:** `.superpowers/sdd/2026-10-30-skill-rework/skill-audit.md` G8 (prove's adversaries Untested. Proposed red flag: only the inline fallback ran, write `adversary: inline`, not `done`).
- **rig-plan:** `thoughts/shared/plans/2026-11-05-rig-cli.md`, Phase 10 Step 3, Global constraints, and Deviation 20.
- **rig-cli:** `ai/bin/rig`, command help, `verify_root`, `cache_root`, `info`, and `cleanup`.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output. "Loop N" is a step in SKILL.md. "T" is `review-template.md`. "R" is `roles.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| The change is `git diff <base_sha>`, with `base_sha` the merge-base of the plan `base` and HEAD. It holds the committed phases and the uncommitted edits. Record `base_sha`, `head_sha`, and `diff_hash`. | spec 10. fr1 C1 (build commits each phase). brief. sw Phase A step 4 (record SHAs). | P | Definitions. Loop 1. T frontmatter. Reply template. | RED: neither doc had a diff hash or the frontmatter keys. GREEN-2: both used the merge-base `5e853ae` and `diff_hash` 413eb95e (committed phase plus edit), not the working-tree hash c3700d22. |
| `git add -N` each new file, so that the diff and the adversary patch hold it. In the adversary worktree, `git add -N .` after the apply. | spec 10 (worktree with the diff applied). fr1 I1. | P | Loop 1. R Set up. | Untested. The scenarios add no file. The reviewer reproduced the worktree hash mismatch and the `add -N .` fix by hand. |
| Read the plan, the task, the diff, and the test card. A missing card: take the commands from the repo config and say so. | spec 8.4 (consumes the plan, the diff, the test card). mp Loop 2. | P | Loop 1. | GREEN |
| State the intent in one sentence. A finding must break the intent. | int `Frame` and `Verify`. | P | Loop 1, Loop 5. T Summary. | GREEN |
| Ladder of five steps. Each finding carries its step. | br How sure are you. spec 8.4, spec 10 (italic summary line). | O | Definitions. T finding summary. | RED: no run gave a ladder step. |
| Name the one safety fact. Prove it at ladder step 4, or write "unproven". | br Steps 2 and 5. spec 8.4. | D | Definitions. Loop 2. Red flags. Outcome rule. | RED: no run named a safety fact. |
| Look past grep: data files, wire formats, DB columns, flags. | br Step 3. | P | Loop 2. R brief. | GREEN |
| Principle pointer at Loop 3. | piw. spec 8.7. ctl. | P | Loop 3. Red flags. Reply template. T last line. | GREEN |
| Read the principle alone at Loop 3. Include the reply template's principle line in partial reports. | piw (prove the process). ctl pointer form. P10 review finding and reference-only Claude failure. | P, O | Loop 3. Reply template. | P10 fix 1: legacy and main scenarios pass under both models. |
| Read the exit code. `\| tail`, `; true`, `\|\| true` hide it. | piw ("Output cut by \| tail -1 ... prove nothing"). brief Review Focus 1. | D | Rules. | GREEN |
| Run the repo `verify` skill when it exists: Launch, Doctor, Drive, Evidence, Cleanup. | spec 8.4. cvs section 2. ver. | P | Loop 3. | Untested. The scratch repo has no `verify` skill. |
| A speed claim goes to `performance`. The prompt opens with "The prove skill dispatched you". Copy its five labels. With no dispatch, do the skill yourself. | spec 8.4. bc (owned by perf). perf Loop 7. | P | Loop 3. | Untested. The scenario has no speed claim. |
| Two blind adversaries, one Claude and one Codex, each in `~/wt/<repo>/prove-<n>` at `base_sha` with the change applied. They get the diff, the plan, the task, and not the session reasoning. | spec 8.4, spec 8.5, spec 10. brief. int Fan out. | P | Loop 4. R. | Partial (round 2, `prove-green-2`, both CLIs, 2026-10-30). Claude made both worktrees under `~/wt/<repo>/prove-<n>`, dispatched a general-purpose adversary, and ran `codex exec` for the Codex one. The Codex adversary found the planted bug (`shipping_cents(5000)` gave 495). The Claude adversary ran no command, because headless permissions denied its `cd <dir> && git` Bash call. Codex made both worktrees and spawned its adversary. `claude -p` failed in the Codex sandbox (not logged in). Each run had one working adversary. Both in one run: Untested. `prove-green-1` (before the red flags below): Claude did not dispatch, "because of the budget cap". |
| Adversary brief: break the change and prove each finding with a run. Report the command, the output, and the needed output. Leave out each finding with no run. No findings is valid. | int brief. | P | R Brief. | GREEN for the Codex adversary (`prove-green-2`, both CLIs): it ran a repro and reported the command, the output (495), and the needed output (0). Untested for the Claude adversary (see the row above). |
| Fallback: no worktree or no dispatch, run the brief yourself, label it inline, flag it under Attention. One adversary missing: go on, record the gap. | sw Phase B (proceed with N-1, note it). sw Phase C (a gap is not a pass). Form bar (roles with a fallback). | P | R Fallback. | GREEN (round 2, `prove-green-2`): one adversary missing. Both CLIs went on with the other, named the gap, gave INCONCLUSIVE, and kept `status: in-progress`. Earlier: GREEN for the inline fallback. |
| Set `status: done` only when both adversaries ran. With the inline fallback or one adversary, write `adversary: inline (<reason>)` or `<name> missing` on the Outcome line and keep `status: in-progress`. | audit G8 (if the adversaries never run, "done" means the same model read it again). sw Phase C (a gap is not a pass). | D | Loop 8. Red flags. Reply template. | Partial (`prove-green-2`): Claude wrote `adversary: claude missing` on the Outcome line. Both CLIs kept `status: in-progress`, but the INCONCLUSIVE outcome and the older one-adversary-missing rule already force that, so the run does not test this clause. Codex named the missing adversary in prose, not on the Outcome line. Untested: a VERIFIED outcome with one adversary missing (the only case this clause decides), and the inline-only case and its red flag. |
| Do the adversary brief yourself only for a reason in the fallback. Cost and time are not reasons. | int Fan out (the adversaries are the second view). audit G8. | D | Red flags. | RED: in `prove-green-1` Claude skipped the dispatch "because of the budget cap" and gave VERIFIED. GREEN (`prove-green-2`): Claude dispatched both. |
| Rerun each finding command. Keep only failures that break the intent. Drop the rest with the reason. Merge findings with one cause. | int `Verify`. spec 8.4 (the parent reruns every command, and unrun findings drop). | D | Loop 5. Red flags. T Dropped. | GREEN (`prove-green-2`): Claude ran the Codex adversary repro again and kept H1. Earlier: GREEN with the inline fallback only. |
| Replay each counterexample one step at a time against the real code. | sc Hand off. spec 8.4. | P | Loop 5. | GREEN (inline fallback only). No run shows a step-by-step replay. |
| A clear fix inside the plan: make it, rerun, new `diff_hash`. | spec 8.4 (fixes in the same session, each fix reruns the affected checks). | D | Loop 6. | GREEN (round 2, `prove-green-1` and `prove-green-2`, both CLIs): each changed `>` to `>=`, added a threshold test that failed first, and ran the checks again. Claude recorded the new `diff_hash`. |
| A fix with two forms or a plan change: ask, one question per message, with a recommended answer and the catch-up item parts. | spec 8.4 (stops for user decisions). ctl (never-block, one question). ket. | D | Loop 6. Decision template. Red flags. | GREEN |
| No user: `Assumed:` with a source, else `Open:` and no fix. | tdd Loop 3. brief dispatch. | D | Loop 6. Reply template. | Partial (round 2): Claude wrote `Open:` lines with a source and made no fix for them in `prove-green-1` and `prove-green-2`. No run needed an `Assumed:` line. Codex gave no `Open:` line. |
| Review root: the `thoughts/shared` link target plus `/reviews`, else `thoughts/shared/reviews`. Main checkout in a worktree. File `YYYY-MM-DD-self-<topic>.md`. | rpr Step 6. mp Loop 7. brief (review root that review_pr writes). | P | Loop 7. | Untested. The runs cannot write. |
| No shell heredoc for the doc. A hook removes lines whose first character is `#`. | rpr Step 6. | D | Loop 7. | Untested. The runs cannot write. |
| C+ light doc: `kind: self-review`, quoted SHAs, H1 sections, `### <ID> - <title>`, italic ladder summary, `~~~finding` block, Status cell `pass`, `fail`, or `inconclusive`. | rpr format rules. brief (Grimoire parse with no warnings). spec 10. | O | T. | RED: neither doc parsed as structured (`is_structured` False, 0 findings). GREEN: both docs parse. |
| No `\|` in a table cell. A command that holds one goes in a fenced block under the table. | fr1 I2 (Grimoire `_CHECK_ROW` drops the row with no warning). | O | T Format rules. T checks. | GREEN-2: codex put `git diff <sha> \| shasum` in a fenced block. Each table row parsed (row counts match). |
| `# Attention` names the reviewing model and lists flags as pointers. | smyw Cross-model review. spec 8.4. | O | T Attention. | Partial. Claude wrote "reviewed by". Codex wrote only `adversary: inline (...)`. GREEN-2 after the template change: both wrote `reviewed by <model> (adversary: inline, <reason>)`. Untested with real adversaries. |
| Close the plan: tick boxes with a VERIFIED check, name the check, add `## Deviations` with the Deviation row of `build` (append-only, evidence is a pointer), set `status`. | spec 8.4 (closes the plan). brief. smyw Rules (append-only). bld. fr1 M4. mp (status values). | P | Loop 8. Red flags. Reply template. | RED: both rewrote the plan steps and boxes. GREEN-2: both wrote Deviation rows with pointer evidence (`<sha> file:line`). |
| Each check has its command and output. "Tests pass" with no command is not a check. | int Output. piw. sp verification-before-completion (gate). spec 8.4. | D | Rules. Red flags. | RED: both runs gave commands, so this held already. |
| A gap is not a pass. An unrun check is INCONCLUSIVE. | sw Phase C. fio Phase C. spec 8.4. | D | Definitions. Rules. | GREEN |
| Outcome from the checks: any finding gives NOT VERIFIED, then INCONCLUSIVE, then VERIFIED. | fio Phase C. spec 8.4. | O | Rules. T frontmatter. Reply template. | GREEN |
| Each check names the `diff_hash` that it ran against. Rerun after a fix. | sw Phase A step 4 (SHAs and method). spec 10 (each fix reruns the affected checks). | D | Rules. | GREEN for Claude (`prove-green-2`: the Outcome line names the `diff_hash` after the fix). Untested for Codex. |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. R Brief (three of them). | Untested. The runs do not touch prod. |
| A local `rig.toml` selects `rig check`, `rig up`, `rig doctor`, the touched feature recipes, and `rig cleanup`. | rig-plan Step 3 and Global constraints. | P | Loop 3. | P10 prove and prove-legacy. Both baseline answers already selected rig. |
| Record the evidence path before cleanup. Read the saved evidence after cleanup on success or failure. | rig-plan Step 3. piw. cvs step 4. rig-cli info and cleanup. | P | Loop 3. | P10 prove-legacy: RED Claude deferred the evidence lookup until after its exit cleanup. |
| Use `RIG_VERIFY_DIR` and `RIG_CACHE_DIR` for isolated fixtures. Read the verifier configuration reference for rig details. Retain the app-skill fallback when no `rig.toml` exists. | rig-plan Step 3. ver configuration reference. rig-cli roots. | P | Loop 3. | P10 prove-legacy: first GREEN Codex invented `RIG_VERIFY_ROOT`. |

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
- rpr: the What and How analyst sections, Mermaid diagrams, the REST API guidelines check, and `humanlayer thoughts sync`. A self-review needs no PR walkthrough. spec 8.4 make-plan removes the humanlayer residue.
- rpr: "Write the review document with the Write tool". A controller ruling forbids a sentence that tells the agent to use a specific file-read tool. The heredoc warning stays.
- P10: manual lifecycle steps beside a configured rig app. The existing `rig.toml` selects the shared lifecycle.

## Principles

- prove-it-works: pointer at Loop 3 (the check step), with its key sentence inline. The Rules carry "the exit code counts" and "no command, no claim".

## Pressure scenarios

Scenario 1 (`scratch-5.1/scenario.txt`, RED and GREEN-1): the git repo `scratch-5.1/repo` has one commit and an uncommitted change. `to_cents` now parses German amounts (`1.234,56`), and the updated `tests/test_money.py` passes. The caller `shop/invoice.py` reads `data/lines.csv` with dot amounts (`19.99`), so its total goes from 26999 to 2699900. No test covers the caller. The plan `thoughts/shared/plans/2026-10-30-german-amounts.md` has `status: in-progress` and a manual box for callers. The runs cannot write, so the doc and the plan edits go in the answer.

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
- Gaps: codex did not use the Reply template (no `Doc:`, `Safety fact:`, `Findings:`, or `Plan:` line). Codex also wrote "Replace the plan content with the following" and put free paragraphs under Deviations. For codex, the RED failure "rewrote the plan" is only partly gone.
- Cost: claude 0.46 USD. codex 229k input tokens (201k cached), 5.3k output tokens.

**GREEN-2** (fix round 1 skill, both CLIs, read-only, 2026-10-30, `--principle prove-it-works`, budget 1.5). Scenario 2 (`scratch-5.1/scenario-2.txt`): `scratch-5.1/repo2` is on branch `feat/german-amounts`. Commit d4a7066 holds phase 1 (the same German parser and tests). One more test has no commit. The plan has `base: main`. Plain `git diff` shows only the new test.
- Harness: claude PASS, codex PASS.
- Both gave NOT VERIFIED with `base_sha` 5e853ae (the merge-base), `head_sha` d4a7066, and `diff_hash` 413eb95e. Both found the invoice caller break (H1) in the committed phase.
- Both docs parse in Grimoire with warnings `[]`, `is_structured` True, and one finding. No check row dropped.
- Both wrote `reviewed by <model> (adversary: inline, <reason>)` and Deviation rows with pointer evidence.
- Gaps: codex again did not use the Reply template, and again added a `fix-root-causes` principle line. Codex gave the plan as full replacement text, but it kept each step and ticked boxes with check names.
- Cost: claude 0.45 USD. codex 228k input tokens (201k cached), 5.0k output tokens.

## Round 2 pressure scenarios

Agent-execution runs in a tiny `shop` fixture repo, 2026-10-30, budget 1.5 USD. Run dirs: `round2/scratch-build-tdd-prove/runs/<name>/`. Codex counts are parent tokens (input/cached/output).

- `prove-green-1` (text before the G8 rows): Claude $0.49 skipped both adversaries "because of the budget cap" and gave VERIFIED. RED. Codex 445k/419k/6.3k could not make a worktree (sandbox), ran the inline fallback, and gave INCONCLUSIVE.
- `prove-green-2` (G8 rows): harness PASS on both. Claude $0.78 made `~/wt/<repo>/prove-1` and `prove-2`. Its Claude adversary could not run Bash (headless denies `cd X && git` in sub-agents). It ran Codex as the second adversary, which found H1 (5000 gave 495). Claude reran H1, fixed it in 8df5b07, and gave INCONCLUSIVE with `adversary: claude missing`. Codex 788k/751k/9.2k made both worktrees and spawned a Codex adversary. `claude -p` from the Codex sandbox was not logged in, so the Claude adversary was missing. INCONCLUSIVE, plan in-progress.
- Untested on Codex: a Claude adversary (no Claude login in its sandbox). Untested on both: two adversaries that both run to the end.

## Phase 10 pressure scenarios

Evidence root: `~/.cache/build/2026-11-05-rig-cli/phase-10/pressure/`.
The fixture scenarios `prove-direct.txt` and `prove-legacy-direct.txt` permit reads only. Each RED and GREEN pair uses the same prompt.

**RED:** both baselines select rig, including beside legacy manual instructions. The new conditional has a plan source, not a baseline failure.
`red-prove-legacy/` and `red-prove-legacy-direct/` include the unsupported `RIG_VERIFY_ROOT` variable. Some answers defer evidence lookup until after cleanup.

**GREEN main:** both saved answers in `green-prove-final/` pass the harness. The worker read both saved answers.
Both use `RIG_VERIFY_DIR`, `RIG_CACHE_DIR`, rig lifecycle commands, touched-feature proof, and evidence reads after cleanup.
Both report INCONCLUSIVE because the evaluation cannot launch the app. The root-variable failure is gone.

**Earlier legacy follow-up:** both answers in `green-prove-legacy-final/` select rig over manual steps and use the supported root variables.
The harness still fails: Claude omits the principle line. Codex omits the principle read and line. Codex also reports the sibling reference absent.
The record retains these evaluation gaps. No claim that every pressure run passes applies to this scenario.

The first GREEN runs also had skill reads hidden in shell loops. Direct-read repeats make loading observable.
The main scenario covers Loop 3 only. No live fixture proof, adversary pass, or plan closure ran.
Descriptions, routing, and eval prompts stay unchanged because the triggers did not change.

### Phase 10 fix 1 closes the legacy gate

Evidence root: `~/.cache/build/2026-11-05-rig-cli/phase-10-fix1/`.
`premise.json` shows that both original scratch layouts lack the sibling verifier reference, while the worktree source exists.
The cache-only `reference-run.py` adds `skills/verifier/verify-template.md` beside the selected prove skill in each isolated setup.
It uses the existing pressure-run model commands, main function, and checks. The scenario and every assertion stay unchanged.

**Reference-only control:** `legacy-reference-only/` uses the unchanged public skill at `9139eda`.
Codex passes. Claude still omits the principle read and line. Reference exposure alone does not close the gate.
Claude costs $0.3487979. Codex usage is 147657 input, 127232 cached input, and 1904 output tokens.

**GREEN legacy:** both saved answers in `legacy-green-1/claude.txt` and `legacy-green-1/codex.txt` pass the existing harness.
Both transcripts show successful separate principle reads and sibling-reference reads. Both answers include `Principles applied:`.
Both select rig over legacy manual instructions, use the supported roots, preserve cleanup and evidence rereads, and report INCONCLUSIVE.
Claude costs $0.3198186. Codex usage is 176698 input, 139392 cached input, and 1578 output tokens.

**GREEN main:** the affected main scenario also passes under both models in `main-green-1/` after the skill change.
Both answers retain the same proof decisions, principle reads, and principle lines. Claude costs $0.35820399999999997.
Codex usage is 174094 input, 153216 cached input, and 1503 output tokens. Codex dollar prices are unavailable.
Each run's `inspection.json` records exact answer and transcript paths, hashes, checks, model argv, costs, and usage.
`transcript-evidence.json` records the read calls, results, and transcript line numbers. This worker read all saved answers.
The earlier failures remain evidence. These evaluations cover read-only Loop 3 decisions, not live app proof or plan closure.
