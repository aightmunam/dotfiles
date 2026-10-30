---
name: staging
description: Use when the user asks to deploy a branch to staging and check it. Use when the user wants an end-to-end test of a branch on staging, or asks if a staging deploy finished and works.
---

# Staging

## Definitions

- **HEAD:** the commit of the branch on origin. All checks compare against this SHA.
- **Run of record:** the deploy workflow run that put HEAD on staging. You name its id, its head SHA and its start time.
- **Serving state:** the revision that takes the traffic, and its image tag or digest. A SHA label, a `GIT_SHA` env value or a health version is not the image.
- **Proof:** a result from the live service that only the new code can give: a new route, a new field, a new log line. A SHA match alone is not proof.
- **Case list:** the staging checks in the plan file of the branch.

## The Loop

1. **Pre-flight.** Read HEAD. Check that origin has the same commit. Check that the branch contains `origin/main`. Run the repo's migration head check. Check `gh auth status` and `gcloud auth list` now, so that a login stall does not stop the loop later. Output: HEAD and each check result.
2. **Case list.** Find the plan file. The PR body can name it. Else search `thoughts/shared/plans/` for the files that the branch changes. Copy each staging case. If the plan has no cases, write one case for each new behavior in the diff, and label them `from diff`.
3. **Run of record.** A rerun must reach the same end state, and must not deploy twice. Read ~/.agents/principles/make-operations-idempotent.md before this step, as a read of that file alone. List the deploy runs of the branch. If a run for HEAD succeeded or is in progress, use it and label it `reused`. Else dispatch the manual deploy workflow for the branch. A run is yours only if its head SHA is HEAD and it started after your dispatch. Output: the run id and `reused` or `dispatched`.
4. **Watch.** Watch the run until it ends. The run conclusion is the source of truth. Read the conclusion of each job, the release job too. Read the migration lines of the release job.
5. **Serving state.** Check the real artifact, not a proxy. A same-SHA restart can let old code report the new SHA. Read ~/.agents/principles/prove-it-works.md before this step, as a read of that file alone. Read the revision that takes the traffic. Compare its image tag or digest with HEAD. Output: revision name, image, and `match` or `mismatch`.
6. **Cases.** Send each case to the staging service. Record the request, the status, a body excerpt, and the log line of that revision. Add one probe of a behavior that only HEAD has. Mark each case `pass` or `fail`.
7. **Retry or stop.** Classify a failure before you retry. A flake or an infrastructure fault gets one fresh dispatch, then go to step 3. A failure in the code of the branch: stop. After three failed rounds, stop.
8. **Report.** Fill the output template. The template is the full answer.

## Rules That Shape the Report

- **Verdict.** Write `proven` only when the run succeeded, the serving image matches HEAD, and each case passed. Else write `not proven` and the first item that failed.
- **Evidence or no claim.** Each "deployed", "serving" or "passed" cites the command and the output line that shows it.
- **One staging DB.** All branches share it. Report the migration head that the release job left on staging. Say if `main` does not have that revision, because the next deploy of `main` then fails. Propose the fix. Do not run it.
- **Staging only.** Never deploy to prod. Never merge. Never push to `main`. A green run does not let you merge.
- **The case decides.** Never change a test, a case, or an expected value to get a pass. Never use `--no-verify`.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, without in-the-moment user confirmation.
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
- The verdict is `proven` and an item failed. Go back to step 8.

## Output Template

```
Verdict: <proven | not proven: first item that failed>
Branch: <name> at HEAD <sha>. Pre-flight: <each check and result>.
Run: <id>, <reused | dispatched>, head <sha>, started <time>, <conclusion>. Release job: <conclusion>.
Serving: <revision>, image <tag or digest>, <match | mismatch> with HEAD.
Cases (from <plan path | from diff>):
| # | Case | Request | Status and body excerpt | Log line | Result |
New-only probe: <the behavior and its result>.
Staging DB: <migration head on staging>, <in main | not in main: the risk and the proposed fix>.
Next: <one action, or none>.
Principles applied: make-operations-idempotent -> <choice it changed>; prove-it-works -> <choice it changed>
```
