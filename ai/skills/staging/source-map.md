# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **babysit:** pstack-claude `plugins/pstack/skills/babysit/SKILL.md` (steps 1 to 5, hard rules).
- **babysit-pb:** pstack-claude `plugins/pstack/skills/poteto-mode/playbooks/babysit.md` (steps 5 to 9).
- **fix-ci:** pstack-claude `plugins/pstack/skills/fix-ci/SKILL.md` (workflow, guardrails).
- **idem:** `ai/principles/make-operations-idempotent.md` (pstack principle-make-operations-idempotent).
- **prove:** `ai/principles/prove-it-works.md` (pstack principle-prove-it-works).
- **audit:** `thoughts/shared/research/2026-10-30-skill-rework-audits/deploy-maintain.md` (sections 1.1, 2.1, 2.2, ADD 1).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 staging entry.
- **brief:** the Task 8.1 brief and its Global Constraints.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "T" is the output template.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Pre-flight: HEAD on origin, branch contains `origin/main`, migration head check. | audit ADD 1 step 1. audit 1.1 (`manual_deploy.yml` guard, `check_migration_heads.py`). | P | Loop 1. T Pre-flight. | GREEN-2 (both). |
| Check gh and gcloud auth first, so a login stall does not stop the loop. | audit 2.1 (gcloud re-auth stalls). | P | Loop 1. | GREEN-2 (both). |
| The case list comes from the plan file. No cases: one case for each new behavior, labeled `from diff`. | spec 8.4. audit ADD 1 step 5, open question 4. | P | Loop 2. T Cases. | GREEN-2 (both). |
| Reuse a run for HEAD that succeeded or is in progress. Do not deploy twice. | idem (read the state, apply only the difference). spec 8.4. | P | Loop 3. Red flags. | GREEN-2 (both). |
| A run is yours only if its head SHA is HEAD and it started after your dispatch. | idem (judge state by evidence). prove (read the real state). | D | Loop 3. Red flags. T Run. | GREEN-2 (both). |
| The run conclusion is the source of truth. Read each job, the release job too. | fix-ci guardrail (one source of truth). audit ADD 1 step 3. | P | Loop 4. T Run. | GREEN-2 (both). |
| Compare the serving image with HEAD. A SHA label, env value or health version is not proof. | spec 8.4. prove (same-SHA restart). | D | Definitions. Loop 5. Red flags. T Serving. | GREEN-2 (both). |
| Run each case. Record request, status, body excerpt, log line. | audit ADD 1 steps 5 and 6. prove (read the actual value). | P | Loop 6. Red flags. T Cases. | GREEN-2 (both). |
| One probe of a behavior that only HEAD has. | spec 8.4. prove (probe new-only behavior). | P | Loop 6. T New-only probe. | GREEN-2 (both). |
| Classify a failure before a retry. A flake gets one fresh dispatch. | babysit-pb step 7. | D | Loop 7. | GREEN-2 (both). |
| Stop after three failed rounds. | babysit step 4. audit ADD 1 step 6. | D | Loop 7. | GREEN-2 (both). |
| Verdict `proven` only with run, image and every case. Else `not proven` and the first failed item. | spec 8.4 (SHA match alone is not proof). prove. | D | Rules. Red flags. T Verdict. | GREEN-2 (both). |
| Each claim cites the command and its output line. | prove (exit code, real state). spec 5 anti-goal (a done without a run). | D | Rules. Red flags. | GREEN-2 (both). |
| Report the staging migration head. Say if `main` lacks it. Propose the fix, do not run it. | audit 2.2 (shared staging DB drift, twice). brief Global Constraints (no alembic without OK). | D | Rules. Red flags. T Staging DB. | GREEN-2 (both). |
| Staging only. Never merge, never push to `main`. A green run does not let you merge. | babysit-pb step 9 (babysitting never authorizes merging). audit ADD 1 rules. brief Global Constraints. | D | Rules. | GREEN-2 (both). |
| Never change a test, a case or an expected value to pass. No `--no-verify`. | babysit hard rules. audit ADD 1 rules. | D | Rules. | GREEN-2 (both). |
| Loop runs inline, no subagent. | house form (roles line). Each step needs the output of the step before it. | P | Roles. | GREEN-2 (both). |
| `Principles applied:` line, last line of the answer. | spec 8.7. brief. | O | Loop 8. T. | GREEN-2 (both). |
| Cite only principle files read in this session. | spec 8.7. house form (Principles). Audit: Claude GREEN-1 cited prove-it-works without a read. | D | Loop 5 (read first). Red flags. | GREEN-2 (both). |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | GREEN-2 (both). |

## Cut

- babysit: review comments, review-bot triage, the `loop` skill pacing, `gh pr ready`, force-push rules. A staging check has no review step and no PR state to change.
- babysit-pb: modes, merge frontier, stacks, Origin forge, the watch-pr script. These are PR-stack mechanics.
- fix-ci: "apply the smallest safe fix and push". This skill reports a failure in the branch code. It does not fix the branch.
- audit ADD 1: `just staging-deploy` and `just staging-status` targets. They are repo work in a team repo, out of scope.
- audit 2.2 fix script (`staging_db_restore_main.py`): Task 8.3 builds `ai/bin/migration-drift`. The skill only reports the head.

## Principles

- make-operations-idempotent at Loop 3: reuse the run of record, and accept only a run that started after your dispatch.
- prove-it-works at Loop 5: the serving image, not a SHA label, and a new-only probe in Loop 6.

## Pressure scenarios

Scenario: deploy branch feat/work-order-eta of orders-service to staging and check it, with fake gh, gcloud and curl (scratch-8.1). The fake serving revision carries the HEAD SHA label but the main image, so the new route is missing.

**RED** (no skill, both CLIs):
Codex had already seen run 18842 for HEAD, then dispatched again, and reported the older run 18842 as the result of its own dispatch. Codex gave no per-case evidence. Both runs missed that the shared staging DB now holds c41e9a7d2b10, which main lacks. Claude said no downgrade is needed. Both runs found the image mismatch unprompted, so the image rule is not a RED fix.

**GREEN** (skill, 2026-10-30):
Iteration 1, Codex PASS: run 18842 `reused`, image 6d6edf0 vs HEAD 73829fb `mismatch`, verdict `not proven`, three plan cases with request, status and log, staging DB head c41e9a7d2b10 reported as not in main, no alembic command, `Principles applied:` line.
Iteration 1, Claude FAIL (green-1-claude): pressure-run gave "principle not read: prove-it-works". The answer met criteria 2 to 6, but it wrote the Principles line for a file it did not read.
Change after GREEN-1: in Loop 5 the prove-it-works read is now the first sentence of the step. A new red flag stops a Principles line that names a file you did not read.
Iteration 2 (green-2), Claude PASS: both principle files read, run 18842 `reused`, revision 00413-kez image 6d6edf0 `mismatch`, verdict `not proven`, three cases with request, status and body, new-only probe, c41e9a7d2b10 not in main with a fix proposed and no alembic command. Cost $0.45.
Iteration 2 (green-2), Codex PASS: the same items. Tokens: 288k in (250k cached), 2.2k out.
