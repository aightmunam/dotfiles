---
name: staging
description: Use when the user asks to deploy a branch to staging and check it. Use when the user wants an end-to-end test of a branch on staging, or asks if a staging deploy finished and works.
---

# Staging

## Definitions

- **HEAD:** the commit of the branch on origin. All checks compare against this SHA.
- **Run of record:** the deploy workflow run that put HEAD on staging. You name its id, its head SHA and its start time.
- **Serving state:** the revision that takes the traffic, and its image digest. The deploy uses `<registry url>@<digest>`, so the image has no git SHA. A SHA label, a `GIT_SHA` env value or a health version is not the image.
- **Release job:** the Cloud Run job that runs the migrations. The workflow has one GitHub job, `build_and_deploy`. Its `Deploy to Cloud Run` step starts the release job with `gcloud run jobs execute <job> --wait`. The alembic lines are in Cloud Logging, not in the GitHub run log.
- **Proof:** a result from the live service that only the new code can give: a new route, a new field, a new log line. A SHA match alone is not proof.
- **Case list:** the staging checks in the plan file of the branch.

## The Loop

1. **Pre-flight.** Read HEAD. Check that origin has the same commit. Check that the branch contains `origin/main`. Run the repo's migration head check. Check `gh auth status` and `gcloud auth list` now, so that a login stall does not stop the loop later. Output: HEAD and each check result.
2. **Case list.** Find the plan file. The PR body can name it. Else search `thoughts/shared/plans/` for the files that the branch changes. Copy each staging case. If the plan has no cases, write one case for each new behavior in the diff, and label them `from diff`.
3. **Run of record.** A rerun must reach the same end state, and must not deploy twice. Read ~/.agents/principles/make-operations-idempotent.md before this step, as a read of that file alone. List the deploy runs of the branch. If a run for HEAD succeeded or is in progress, use it and label it `reused`. Else dispatch: `gh workflow run manual_deploy.yml --ref <branch> -f environment=staging`. A run is yours only if its head SHA is HEAD and it started after your dispatch. A queued run is in progress only if its head SHA is HEAD. Staging runs go one at a time, so a run of another branch can keep your run queued. Then report the other run and wait. Do not cancel it. Output: the run id and `reused` or `dispatched`.
4. **Watch.** Watch the run until it ends. The run conclusion is the source of truth. Read each step result of `build_and_deploy`, and the `Deploy to Cloud Run` step too. Get the release job name from the `Run release job` step of the run log (its `JOB_NAME` env value). Find the execution of this run: `gcloud run jobs executions list --job <job> --region europe-west3`. Read its migration lines: `gcloud logging read 'resource.type="cloud_run_job" AND labels."run.googleapis.com/execution_name"="<execution>"'`. Then compare the staging head with `main`: `~/dotfiles/ai/bin/migration-drift <main checkout> <staging head>`. Use a checkout of `origin/main`, not of the branch, because the branch has the new revision. Find one with `git worktree list`. If there is none, add one: `git worktree add --detach ~/wt/<repo>/origin-main origin/main`. Output: the release execution, the staging head, and the exit code and output line of the script.
5. **Serving state.** Read ~/.agents/principles/prove-it-works.md before this step, as a read of that file alone. Its key sentence: check the real artifact, not a proxy. A same-SHA restart can let old code report the new SHA. Read the image of the revision that takes the traffic: `gcloud run revisions describe <revision> --region europe-west3 --format='value(spec.containers[0].image)'`. Read the digest of the HEAD image: `gcloud artifacts docker images describe <registry url>:<HEAD> --format='value(image_summary.digest)'`. Write `match` only when the two digests are the same. Output: revision name, serving digest, HEAD digest, and `match` or `mismatch`.
6. **Cases.** Send each case to the staging service. Record the request, the status, a body excerpt, and the log line of that revision. Add one probe of a behavior that only HEAD has. Mark each case `pass` or `fail`.
7. **Retry or stop.** Classify a failure before you retry. A flake or an infrastructure fault gets one fresh dispatch, then go to step 3. A failure in the code of the branch: stop. After three failed rounds, stop.
8. **Report.** Fill the output template. The template is the full answer.

## Rules That Shape the Report

- **Verdict.** Write `proven` only when the run succeeded, the serving image matches HEAD, and each case passed. Else write `not proven` and the first item that failed.
- **Evidence or no claim.** Each "deployed", "serving" or "passed" cites the command and the output line that shows it.
- **One staging DB.** All branches share it. Report the migration head that the release job left on staging. `staging ahead: <rev>` from migration-drift means that `main` does not have that revision. Then the next staging deploy of each branch without that revision fails at the release job. Propose the fix. Do not run it. `staging behind: <rev>` means that the head of `main` is not the staging head. It shows together with `staging ahead` when the staging head comes after the `main` head. Alone, it means that the next release job applies that revision. It is not a failure. Report each line that the script prints. Exit 2, or no script on disk, means that the script cannot judge. Then write `drift: unknown` with the exit code and the message. Do not guess.
- **Staging only.** Never deploy to prod. Never merge. Never push to `main`. A green run does not let you merge.
- **The case decides.** Never change a test, a case, or an expected value to get a pass. Never use `--no-verify`.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Roles

The loop runs inline. It uses no subagent, because each step reads the output of the step before it.

## Red Flags

- You dispatched, and a run for HEAD already succeeded or was in progress. Go back to step 3.
- You report a run that started before your dispatch as your deploy. Go back to step 3.
- Your proof of the deploy is a SHA label, an env value, or a health version. Go back to step 5.
- A case has no request, no status, or no output line. Go back to step 6.
- The report has no staging migration head. Go back to step 4.
- The drift verdict has no migration-drift line and is not `unknown`. Go back to step 4.
- You cancelled a run of another branch. Stop and tell the user.
- The verdict is `proven` and an item failed. Go back to step 8.
- The `Principles applied:` line names a principle file that you did not read in this session. Go back to its step and read it.

## Output Template

```
Verdict: <proven | not proven: first item that failed>
Branch: <name> at HEAD <sha>. Pre-flight: <each check and result>.
Run: <id>, <reused | dispatched>, head <sha>, started <time>, <conclusion>. Release job: <execution>, <result>.
Serving: <revision>, digest <serving digest>. HEAD image digest <digest>. <match | mismatch>.
Cases (from <plan path | from diff>):
| # | Case | Request | Status and body excerpt | Log line | Result |
New-only probe: <the behavior and its result>.
Staging DB: <migration head on staging>. migration-drift: <exit code and line | drift: unknown>. <the risk and the proposed fix | no drift>.
Next: <one action, or none>.
Principles applied: make-operations-idempotent -> <choice it changed>; prove-it-works -> <choice it changed>
```
