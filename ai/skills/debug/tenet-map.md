# Tenet Map

This file keeps its name because The Eye reads `SKILL.md`, `investigation-template.md`, `subagent-roles.md` and `tenet-map.md` (work-dashboard `eye/services/build/skill.py:9`). It is the source map of the `debug` skill.

Sources (pinned in `ai/sources.lock`, paths under `~/Developer/ref/` unless noted):

- **sridharan:** Cindy Sridharan, "How to effectively debug when you no longer understand the code" (Medium, Oct 2026). The base. Table 1.
- **fcd:** `ai/skills/fact-constrained-debugging/` (SKILL.md, investigation-template.md, subagent-roles.md, tenet-map.md). Copied as the base, per spec 8.2a.
- **pocock:** mattpocock-skills `skills/engineering/diagnosing-bugs/SKILL.md` (Phase 1 feedback loop, Phase 5 seam).
- **sp:** superpowers `skills/systematic-debugging/SKILL.md`. Only rules that Table 1 does not cover.
- **statechart:** pstack-claude `plugins/pstack/skills/statechart/SKILL.md`, the Hand off section (replay rule only).
- **old-debug:** the old `ai/skills/debug/SKILL.md` (read-only look at local logs, DB state and git history).
- **atp / frc:** `ai/principles/attack-the-premise.md`, `ai/principles/fix-root-causes.md` (spec 8.7).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md` section 8.4 debug entry. **brief:** the Task 4.3 brief and its dispatch.

"Loop N" and "Rules" refer to SKILL.md. "TN" refers to section N of investigation-template.md. In Table 1, "G" items are the fcd GREEN checks against three pressure scenarios (export latency, webhook duplicates, mobile sync spinner). They ran with the skill passed by path, so description-based discovery is untested there. Table 2 rows cite the Task 4.3 scenario (flaky tag order).

Form key: **P** = procedure (recipe/template slot), **D** = discipline (prohibition + rationalization counter), **O** = end-of-investigation output, **X** = out of scope for a single agent skill (infrastructure), noted only.

## Table 1: Sridharan tenets (from fcd)

| # | Tenet (paraphrased) | Form | Enforced by | Tested by |
|---|---|---|---|---|
| 1 | Name the **variable** (the broken case), the **control** (a comparison case differing ideally in one suspected factor), and **signals** (any data point that might explain the bug). | P | Loop 3; T2 | G1: S1, S2 pass; S3 partial; S3 rechecked pass; subagent round S1 x2 pass |
| 2 | Every hypothesis worth pursuing starts from a high-fidelity signal. | D | Loop 5, 7; red flags | G5: S1-S3 pass |
| 3 | Lean on agent strengths: huge data volumes, cross-referencing layers, knowing every tool/format, tirelessly re-testing, writing throwaway tooling. Don't imitate human-only habits (e.g. pattern-matching old incidents first). | P | Loop 2 (gather yourself, numbers); T1; subagent-roles 1 (one gatherer per source) | G13: partial (gatherers dispatched per source in S1 x2, split-S2); live-system parts untested |
| 4 | Guard against agent weaknesses: narratives built on thin evidence, fixating on rare edge cases, walking past your own earlier best finding. | D | Rules: cite or label; red flags | G6: S2 pass; S1, S3 partial; S3 rechecked pass; subagent round S1 x2 pass |
| 5 | Code is an unreliable narrator: it shows what *can* happen, not what *did*. Reading code to form hypotheses is the last step, after evidence is collected. | D | Overview; Loop 2; rules: cite or label | G6 |
| 6 | Treat debugging as constraint satisfaction, not open-ended hypothesis generation. | P | Overview; Loop 4 | G4: S1-S3 pass |
| 7 | Factual tier: gather broadly from every source (logs, crashes, stacks, profiles, telemetry, traces, kernel, DNS, configs, flags, versions, VCS history, deploy config, user reports). Facts come from outside the agent. | P | Loop 2; T1 | G2: S1-S3 pass |
| 8 | Facts are immutable. The agent may analyse or request facts, or flag doubts about how one was gathered to the person who gathered it, but never alters, disputes away, or invents a fact. | D | T1 note (never edited, raise doubts) | G2: S2 flagged log merge without discarding it |
| 9 | Derivative tier (hypotheses, conclusions, narratives) is where the agent sounds most convincing and is most often wrong; it gets the most scrutiny. | D | Overview; rules: cite or label | G6 |
| 10 | Every fact is a constraint. A hypothesis is valid only if it satisfies all of them; one contradiction discards it. | D | Loop 4, 5 (any N discards) | G4: S2 discarded batch-ack and retries on cited N |
| 11 | Multi-cause hypotheses are allowed only if the combination satisfies every fact and each cause is strictly necessary (removing it leaves a fact unexplained). Never invent complexity to explain away inconvenient facts. | P | Loop 6 tactic 4; T4 | G7: S2 split; combine path untested |
| 12 | Don't validate every hypothesis; steer toward the one most likely to satisfy every fact, early. | P | Loop 5 (column reading) | G5 |
| 13 | Step 1: isolate high-fidelity signals by comparing variable vs control. Present in variable but not control = signal. Present in both = noise. | P | Loop 3 (signal/noise) | G3: S1-S3 pass |
| 14 | Noise can eliminate hypotheses but never tells you where to look. | P | Loop 3 | G3 |
| 15 | Control choice: happy path for simple bugs; for tricky ones a "sad path" that fails differently and more loudly, often the cheapest because it already exists in the data. A control is only as good as your confidence it isn't broken the same way. | P | Loop 3 (trust statement, in-data fallback) | G1 |
| 16 | Step 2: never boil the ocean or pick a random hypothesis; isolate a small set of promising ones. | D | Loop 4 (every candidate gets a row) | G4: S1 #812 row present (missing in RED) |
| 17 | A signal is strong when very few hypotheses (ideally one) satisfy it. Build a hypotheses-by-fact matrix; read it by column to find strong signals. | P | Loop 4, 5; T3 | G4, G5 |
| 18 | SLOs/SLIs and aggregate symptoms are usually weak signals. | P | Loop 5 (aggregates weak) | G5: S1 called P99 weak |
| 19 | When no matrix row is all-satisfied, apply five tactics in order: (1) re-verify how facts were gathered, (2) split coarse hypotheses, (3) merge over-fine ones, (4) combine complementary ones, (5) only then a new hypothesis, guided only by existing facts. | P | Loop 6; T4 | G7: S2 split shown; order 1-5 never fully exercised |
| 20 | Progressive signal discovery: if all signals are weak, or all hypotheses still fail after the tactics, stop generating hypotheses and gather facts from one layer down. Start with what is already available/cheapest. | D | Loop 7; T5; red flags | G8: S1-S3 pass |
| 21 | Stop descending at the first strong signal: the goal is the strongest signal, not the deepest. | P | Loop 7; T5 | G8 |
| 22 | Step 3: validate the candidate against every fact, including the noise. When too few facts exist, several hypotheses survive and cannot be told apart. | P | Loop 8 | G4: S3 report 6 column (missing in RED) |
| 23 | Fat on facts, thin on hypotheses: many source types, and the same data type from several instances of the bug. Repeating patterns across instances (absent from the control) are real signals. Turn comparisons into arithmetic (counts, bytes, lookups, latencies). | P | T1 (instances, numbers) | G2: instance counts present |
| 24 | A fat derivative tier means too few constraints or constraints that are too weak. | P | Loop 7 (too many rows means missing facts) | G8: S1 'too many survivors' |
| 25 | Still attempt a reproduction, especially when the report gives steps. | D | Rules: repro is a hypothesis | G9: S3 pass (repro attempt proposed) |
| 26 | A repro is a hypothesis, not a fact. It proves *a* bug exists, not *the* bug. Facts outrank it. Accept a repro only if it reproduces the strongest signal from the real reports; otherwise treat it as noise. Be extra sceptical of synthetic harnesses and non-production repros. | D | Rules: repro; T6 repro check | G9: S3 line-by-line parity |
| 27 | Adversarial review can't vouch that the factual tier is complete; an absent fact is invisible to it. | D | T6 reviews; subagent-roles 3 (reviewers get artifacts, not conclusions) | G10: S3 pass; G13: isolated reviewers flagged weak controls in S1 x2, split-S2 |
| 28 | A reviewer with the same model, context and data is one opinion counted twice. Use reviews to eliminate (find a contradicting fact), never to corroborate. | D | Loop 12; red flags; subagent-roles intro and 2 (eliminators see one hypothesis, never the ranking) | G10: S3 pass; G13: isolated reviewers caught asymmetric grading (S1 x2) and a circular N (split-S2) |
| 29 | Reviewer per step. S1: are signals also in the control? is the control broken the same way? how was each fact gathered? S2: how many hypotheses fit each signal? read rows; were tactics 2-4 tried before a new hypothesis? was descending a layer justified? S3: find one contradicting fact; demand citations; for combined hypotheses, name the failing part and remove each cause to test necessity. | P | Loop 12; T6; subagent-roles 3 (one reviewer per step) | G10: S1-S3 ran checklist; G13: separate reviewers in S1 x2; merged once in split-S2 (L5), separate after fix |
| 30 | Every claim cites the fact it rests on; uncited claims are culled. | D | Rules: cite or label | G6 |
| 31 | Every human intervention is a gap the agent should have closed itself (control, constraint, check). Count and record them. | O | T7 intervention log | G11: S1-S3 pass (absent in RED) |
| 32 | Optimize the factual tier for agents: prefer raw, unaggregated data over dashboards. | P | Loop 2 (raw over dashboards) | G2 partial: S1 asked for split, not raw |
| 33 | Humans own decisions with risk/accountability (rollback, escalation to another team, dropping support). When several fixes exist, present every option with tradeoffs and reasoning; don't pick silently. Turn such decisions into reusable policy. | O | Rules: decisions; T7 | G11, G12: S1-S3 pass |
| 34 | Data access is read-only by default, scoped to the investigation, time-limited, load/rate-limit aware, privacy-scrubbed, auditable. | D | Loop 2 (read-only) | untested (no live systems) |
| 35 | Designing verification beats understanding code: after the fix, propose how the winning signal becomes a check. | O | T7 verification | G11 |
| 36 | Data collection beats code comprehension. | D | Overview; red flags (reading more code) | G6 |
| 37 | Emit the strongest signal at the shallowest layer by default (e.g. log the count that cracked the case) so the next investigation needs no descent. | O | T7 emit the signal | G11: S1-S3 pass |
| 38 | Humans are policy setters, not meat proxies: the agent runs commands and gathers data itself when it has access, and asks a human only for what it truly cannot reach. | D | Loop 2 (ask only for what you cannot reach) | untested (no live systems) |
| 39 | "Skill issue" to "infrastructure issue": the agent should go as far as it can unprompted (set up the control, reproduce, constrain by report facts, cite) instead of waiting to be told. | D | Loop 2; Loop 3 (no-control not an option) | untested beyond S3 control fallback |
| 40 | Prefer facts from the environment where the bug was observed over a local "full stack in a box"; local harness facts are lower fidelity. | D | Loop 2 (gather where it happened) | untested |
| 41 | Repurpose the framework into tests/deploy gates: check parity of high-fidelity signals against a known-good run, not just pass/fail. | O | T7 verification as signal parity | G11: S2, S3 parity checks (pass/fail in RED) |
| 42 | Default (always-on) data collection over on-demand; dedicated production slices for agent experimentation; develop against isolated production slices. | X | n/a: platform investment; surfaced via #37 and #41 recommendations | n/a |
| 43 | Don't treat the agent as an oracle; trade understanding for a rigorous verification process. | D | Overview; rules: fix vs mitigation | G12: S1-S3 pass |

## Table 2: rules added in Task 4.3

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Build one red-capable command (real code path, the user's exact symptom) and run it before any hypothesis or fix. | pocock Phase 1 (completion criterion). spec 8.4 debug. | D | Definitions (red loop). Loop 1. T1 red loop block. Red flags (fix before loop). | RED: both runs read `tags.py` and named the cause before any command went red. GREEN-3: both ran the loop on unchanged code before they read `tags.py`. |
| Flaky bug: pin what varies, or loop the trigger. Report the red rate. | pocock Phase 1 (tighten the loop, non-deterministic bugs). | P | Loop 1. T1. subagent-roles 4. | GREEN |
| No loop after real attempts: list the attempts, mark each cause and fix `UNCONFIRMED (no loop)`, and continue. | pocock Phase 1 (cannot build a loop), changed for headless runs. brief (no-input path). | P | Loop 1. T1. | Untested. The scenario always allows a loop. |
| Replay the survivor through the red loop against the real code. If it does not reproduce, suspect the hypothesis. | statechart Hand off (replay each bug path, think the model is wrong). spec 8.4. | P | Loop 8. T7 fix status. | GREEN |
| After two failed fixes on one premise, test the premise. No third fix. Look at how failures spread. | atp key sentence. sp Phase 4.5 (3+ fixes: question the architecture). spec 8.4. | D | Loop 9. T3 failed fixes table. Red flags (third fix). | GREEN: all Codex runs and Claude GREEN-1, GREEN-2 and the headless run named the shared premise (CI environment) and tested it with the seed loop. Claude GREEN-3 skipped the principle file. |
| Failed fixes get a matrix row. | atp. fcd (every candidate gets a row). | P | Loop 4. T3. | GREEN |
| Ask if the triggering state is legitimate. Restart-only failures point at saved state. Fix the pattern, not the instance. Name a cheap always-on signal. | frc key sentence and rules. spec 8.4. | P | Loop 10. T7 root cause, emit the signal. | GREEN |
| Regression test at the real seam. Watch it fail. One change. Rerun the test and the loop. | pocock Phase 5. sp Phase 4 (failing test first, one change). | P | Loop 11. Rules (one change at a time). T7 fix status. | GREEN |
| Gather read-only from run output, logs, local DB state, configs and git state. | old-debug (Environment, Step 2 tasks 1 to 3). | P | Loop 2. | Untested. The scenario has no logs or DB. |
| No user present: do not ask, do not wait. Write each assumption in the intervention log, and continue. | brief (The Eye runs `/debug` headless, `eye/config.py:15`). never-block-on-the-human. | D | Rules (no user present). T7 assumptions. Red flags (ends with a question). | GREEN: no answer in 8 headless runs ends with a question. Claude lists its assumptions under T7. |
| With a user: one question per message, with a recommended answer. | brief (controller ruling). | D | Rules (no user present). | Untested. Both runs are headless. |
| Reversible work needs no question. Main/master merge or push and production writes need the OK. | brief Global Constraints (never-block-on-the-human, reversible half). | D | Rules (decisions). | GREEN |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | Untested. The scenario has no Salesforce, DB, or .env. |
| `Principles applied:` line last. | spec 8.7. | O | Loop 13. T7 last line. | GREEN |

## Cut

- pocock: the Redact section (fcd gathers read-only and reports facts, and the repo rules forbid .env reads), the HITL loop script (no script ships with this skill), and "stop and ask the user, do not hypothesise without a loop". The last one blocks a headless run of The Eye. Loop 1 marks causes `UNCONFIRMED (no loop)` instead.
- pocock: Phase 2 minimise, Phase 3 "3 to 5 ranked hypotheses, show them to the user", Phase 4 instrument, Phase 6 cleanup. The fcd matrix, layer descent and emit-the-signal cover them. Showing the list to the user conflicts with never-block-on-the-human.
- sp: read errors, reproduce, check recent changes, find working examples, trace data flow. Table 1 rows 1, 7, 13, 20 and 25 cover them. The rationalizations table and the partner signals. The red flags cover the same failures.
- sp: "discuss with your human partner before more fixes". The premise test replaces it, and the user still owns the decision through Rules (decisions).
- sp: the links to its TDD and verification skills. The new skill names no plugin skill.
- statechart: TLA+, TLC, Mermaid charts and the view module. Only the replay rule applies to debugging.
- old-debug: the greeting templates, "always require a problem description", the Debug Report template and "no file editing". A headless run has no user to ask, and the investigation template replaces the report. Fixes are reversible work.
- fcd: the line that names a superpowers skill in SKILL.md and subagent-roles.md (lint rule, spec 8.5).

## Pressure scenarios

Scenario (scratch repo `scratch-4.3/tags`, read-only): `unique_tags` returns `list(set(tags))`, so `test_export_line_keeps_user_order` fails on about 7 of 10 hash seeds. The user already tried two fixes on one premise (CI reruns, a bigger runner). A teammate proposes a flaky mark or a sort in the test. There is a release deadline.

**RED** (no skill, both CLIs, 2026-10-30): both runs read `tags.py` first and named set order as the cause. The seed sweep came after the hypothesis, to support it. Claude had no fact table, no premise step and no `Principles applied:` line. Codex saw the live fact-constrained-debugging skill (the red-note), so its answer has a fact table and a premise check. Neither treated the two failed fixes as matrix rows. Failure to fix: the hypothesis comes from code reading, before a loop goes red.

**GREEN** (skill, `--principle attack-the-premise --principle fix-root-causes`, both CLIs, budget 1.5):
Iteration 1: Codex PASS. Claude FAIL on the harness check: it read both principle files with `cat` in Bash, and pressure-run counts only the Read tool. Claude still read `tags.py` before its loop. Fix: open files with the file-read tool, and build the loop from the test command and the symptom, not the suspect code.
Iteration 2: same harness result. Claude ran the loop and an in-memory patch in one command. Fix: run the loop on unchanged code first, and a red flag for a loop and patch in one command.
Iteration 3 and a second run on the same scenario: Codex PASS twice. Claude FAIL twice on the harness check (cat again, and once no principle read and `Principles applied: none`). In both Claude runs the loop ran red on unchanged code (16 of 20 seeds) before Claude read `tags.py`, and only then came the fix. No answer in any run ends with a question. Claude cost about 0.38 to 0.41 USD per run. Claude ran every role inline and gave the small repo as the reason.
