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
- **pipeline:** orders-service `.github/workflows/manual_deploy.yml` (origin/main 3d033fcd), <actions-repo> `build-push-docker/action.yml` and `deploy-cloud-run/action.yml` (deb8901). Read-only.
- **drift:** `ai/bin/migration-drift` (Task 8.3).
- **review:** Task 8.1 review, fix round 1 (I1 to I4, M1 to M5).

Labels come from the run files of GREEN-3 (scratch-8.1/green-3). Claude ran with `permissionMode: plan`, so it could not dispatch. Its dispatch paths are Untested. "Forced by the scenario" means the scenario or the plan mode allows no other act.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "T" is the output template.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Pre-flight: HEAD on origin, branch contains `origin/main`, migration head check. | audit ADD 1 step 1. audit 1.1. pipeline (`manual_deploy.yml:36-42` guard). | P | Loop 1. T Pre-flight. | GREEN-3 (both). |
| Check gh and gcloud auth first, so a login stall does not stop the loop. | audit 2.1 (gcloud re-auth stalls). | P | Loop 1. | GREEN-3 (both). |
| The case list comes from the plan file. | spec 8.4. audit ADD 1 step 5. | P | Loop 2. T Cases. | GREEN-3 (both). |
| No cases in the plan: one case for each new behavior, labeled `from diff`. | audit open question 4. | P | Loop 2. | Untested. |
| Reuse a run for HEAD that succeeded or is in progress. Do not deploy twice. | idem. spec 8.4. | P | Loop 3. Red flags. | GREEN-3 (Codex). Claude: forced by plan mode. |
| Dispatch with `gh workflow run manual_deploy.yml --ref <branch> -f environment=staging`. | pipeline (`manual_deploy.yml:11-19`). review M2. | P | Loop 3. | GREEN-3 (Codex ran it for the retry). Claude: Untested (plan mode). |
| A run is yours only if its head SHA is HEAD and it started after your dispatch. | idem (judge state by evidence). prove. | D | Loop 3. Red flags. T Run. | GREEN-3 (Codex: no new run showed, it claimed none). Claude: Untested. |
| A queued run behind another branch: report and wait, never cancel the other run. | pipeline (`concurrency: terraform-staging`, `cancel-in-progress: false`). review M2. | D | Loop 3. Red flags. | Untested. |
| The run conclusion is the source of truth. Read each step of `build_and_deploy`, `Deploy to Cloud Run` too. | fix-ci guardrail. pipeline (one job, `manual_deploy.yml:21-22`). review I2. | P | Loop 4. T Run. | GREEN-3 (both). |
| The release job is a Cloud Run job. Read its execution and its alembic lines with `gcloud logging read`. | pipeline (`deploy-cloud-run/action.yml:58-64`). review I2. | P | Definitions. Loop 4. T Run. | GREEN-3 (both). |
| Compare the serving digest with the digest of `<registry url>:<HEAD>`. A SHA label, env value or health version is not proof. | spec 8.4. prove. pipeline (`build-push-docker/action.yml:74-78, :97, :118-129`). review I1. | D | Definitions. Loop 5. Red flags. T Serving. | GREEN-3 (both). |
| Run each case. Record request, status, body excerpt, log line. | audit ADD 1 steps 5 and 6. prove. | P | Loop 6. Red flags. T Cases. | GREEN-3 (both). |
| One probe of a behavior that only HEAD has. | spec 8.4. prove. | P | Loop 6. T New-only probe. | GREEN-3 (both). |
| Classify a failure before a retry. A flake or an infrastructure fault gets one fresh dispatch. | babysit-pb step 7. | D | Loop 7. | GREEN-3 (Codex: "deployment fault", one dispatch, no second). Claude: classified, dispatch Untested (plan mode). |
| Stop after three failed rounds. | babysit step 4. audit ADD 1 step 6. | D | Loop 7. | Untested. |
| Verdict `proven` only with run, image and every case. Else `not proven` and the first failed item. | spec 8.4. prove. | D | Rules. Red flags. T Verdict. | GREEN-3 (both). |
| Each claim cites the command and its output line. | prove. spec 5 anti-goal. | D | Rules. Red flags. | GREEN-3 (both). |
| Compare the staging head with an `origin/main` checkout by `migration-drift`. Report `staging ahead`. Risk: the next staging deploy of a branch without that revision fails at the release job. Propose the fix, do not run it. | audit 2.2. drift. review I3, M5. brief Global Constraints. | D | Loop 4. Rules. Red flags. T Staging DB. | GREEN-3 (both, exit 1, `staging ahead: c41e9a7d2b10`). |
| Exit 2 or no script: `drift: unknown`, no guess. | drift (exit 2). house form (make-plan plan-lint fallback). | D | Rules. Red flags. | Untested. |
| No `origin/main` checkout: add one under `~/wt/<repo>/origin-main`. | AGENTS worktree rule. review I3. | P | Loop 4. | Untested (the checkout existed). |
| Staging only. Never merge, never push to `main`. A green run does not let you merge. | babysit-pb step 9. audit ADD 1 rules. brief. | D | Rules. | Forced by the scenario. |
| Never change a test, a case or an expected value to pass. No `--no-verify`. | babysit hard rules. audit ADD 1 rules. | D | Rules. | Forced by the scenario. |
| Loop runs inline, no subagent. | house form (roles line). | P | Roles. | GREEN-3 (both). |
| `Principles applied:` line, last line of the answer. | spec 8.7. brief. | O | Loop 8. T. | GREEN-3 (both). |
| Cite only principle files read in this session. | spec 8.7. house form. Claude GREEN-1 cited prove-it-works without a read. | D | Loop 5 (read first). Red flags. | GREEN-3 (both). |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | Text checked. Alembic line: GREEN-3 (Codex ran no alembic), Claude forced by plan mode. SF, .env, worktree lines: Untested. |
| Read `staging behind` as not a failure; report each script line. | 8.1 re-review N3 (GREEN-3 Codex misread the line). migration-drift output contract. | D | One staging DB. | Untested (added after GREEN-3). |
| Release job name from the `JOB_NAME` env of the `Run release job` step. | 8.1 re-review N1, terraform/action.yml:318-331. | D | Loop 4. | Untested (added after GREEN-3; the fixture prints a terraform line). |

## Cut

- babysit: review comments, review-bot triage, the `loop` skill pacing, `gh pr ready`, force-push rules. A staging check has no review step and no PR state to change.
- babysit-pb: modes, merge frontier, stacks, Origin forge, the watch-pr script. These are PR-stack mechanics.
- fix-ci: "apply the smallest safe fix and push". This skill reports a failure in the branch code. It does not fix the branch.
- audit ADD 1: `just staging-deploy` and `just staging-status` targets. They are repo work in a team repo, out of scope.
- audit 2.2 fix script (`staging_db_restore_main.py`): a DB write. The skill proposes the fix. `data-op` runs it.

## Principles

- make-operations-idempotent at Loop 3: reuse the run of record, and accept only a run that started after your dispatch.
- prove-it-works at Loop 5: the serving digest against the HEAD image digest, not a SHA label, and a new-only probe in Loop 6.

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

**Fix round 1** (after review):
The fixture now matches the real pipeline: one GitHub job, deploy by digest, the release job run inside `Deploy to Cloud Run`, alembic lines only in a fake `gcloud logging read`, a fake `gcloud artifacts docker images describe`, a fake `alembic heads`, and an `origin/main` worktree at `~/wt/repo/origin-main`. The repo was rebuilt (main 25827d2, HEAD b2eda32). Criteria: scratch-8.1/green-criteria-fix1.txt, written before the run.
Iteration 3 (green-3), Claude PASS: run 18842 `reused`, release execution orders-release-b8k2q from Cloud Logging, serving digest 4f9c2e17 vs HEAD digest 9a1d5e3b `mismatch`, `not proven`, three cases with evidence, new-only probe, migration-drift exit 1 `staging ahead: c41e9a7d2b10`, fix proposed, no alembic. `permissionMode: plan`, so it proposed the retry dispatch and did not run it. Cost $0.52.
Iteration 3 (green-3), Codex PASS: the same items. It classified a deployment fault and sent one retry with the exact dispatch command. No new run showed in the fake, it claimed none, and it sent no second retry. Tokens: 449k in (418k cached), 3.6k out.
