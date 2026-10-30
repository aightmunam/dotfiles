---
name: verifier
description: Use when a repo needs its own verify skill. Use when the user asks to make or update a scripted way to launch, drive, and prove the app of a repo.
---

# Verifier

## Definitions

- **Verify skill:** `<repo>/.claude/skills/verify/SKILL.md` plus `features/`. In a monorepo, put it in the package that the user touches. You write it for an agent that never saw the app.
- **Evidence:** a response body, a DB row, a file, or an event that a second read shows. A log line, a status code, or a "saved" message alone is not evidence.
- **Proven:** the verify skill ran end to end once in this session, and its evidence exists after cleanup.
- **Draft:** a verify skill that did not run. A draft is a fallback, never `proven`.

## The Loop

1. **Find the target.** If `.claude/skills/verify/` exists, read `maintain.md` and do that pass. Else continue here.
2. **Interview the repo.** Find each answer in the code. Ask the user only what the code cannot show. Surface: what the user touches (HTTP API, UI, CLI). Run: the repo command (just, make, compose, README). Drive: existing harnesses first, then plain HTTP. Observe: bodies, DB rows, events. Isolate: port, data dir, state dir. Find each running instance of the app. Never drive one that you did not launch.
3. **Try the base.** Launch the app as-is. If it does not launch, fix the cause or report it exactly. Do not write a skill for a broken base.
4. **Write.** Read `verify-template.md`. Write `SKILL.md` and `features/` from it. Use real commands, routes, and names from this repo. Leave no placeholder.
5. **Prove.** Do the verify skill once: launch, doctor, drive one feature, capture evidence, clean up. Then read the evidence at its named path. After each failed try, run its cleanup, fix the skill, and try again.
6. **Hand over.** Leave the files uncommitted for the user to review. Run `git check-ignore -v` on each written path. Do not run `git add -f`. Fill each line of the report template. If you cannot write to the repo or launch a process, put the full text of each file in your answer. A link to a file outside the repo is not enough. Set `Status: draft`, and list the commands that prove it.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Rules That Shape The Skill

- **Proof is a body.** Each proof saves a response body or a read-back of the changed state. A status code alone does not prove a feature.
- **Real user path.** Drive the routes, commands, or UI that a user uses. Do not call internal setters or test-only endpoints.
- **Own instance only.** Launch on a free port with scratch data and state dirs. Stop only the PID that you launched. Never kill by process name.
- **Cleanup keeps the evidence.** Cleanup removes instances and scratch data. It does not remove the evidence directory.
- **Never weaken a journey.** If seed data lacks a precondition, the journey fails. Write the reason in that feature's `Gotchas`.
- **Name the stand-in.** If you proved it in a stand-in (a worktree, a container, a local stack), list each setup step that the real target does not get.
- **Never commit.** The user reviews and commits the verify skill.

## Red Flags

- You report the skill as done, and it did not run. Go back to step 5.
- A proof is a log line, a status code, or "ok". Go back to step 4.
- The skill can drive or stop an instance that it did not launch. Go back to step 2.
- Cleanup removes the evidence, or you did not read the evidence after cleanup. Go back to step 5.
- A placeholder such as `<port>` or "for example" is in the verify skill, or its `description:` has no `Use when` as its first words. Go back to step 4.
- The report has no line for a template slot. Go back to step 6.
- You remove a worktree that holds ignored verify files. Stop. Copy the files out first, or keep the worktree. Then go back to step 6.

## Report Template

```
Status: proven | draft | blocked (<reason>)
Files: <each path written, uncommitted>
Run: <launch, doctor, drive, and cleanup commands, each with its exit code>
Evidence: <path>, then the first 5 to 15 lines of the saved body
After cleanup: <evidence path still exists: yes or no>, <port free: yes or no>
Ignored: <file:line from git check-ignore, or no>; to commit: git add -f <paths>
Stand-in gaps: <steps the real target did not get, or none>
Principles applied: none
```
