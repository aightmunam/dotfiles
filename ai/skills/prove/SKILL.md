---
name: prove
description: Use when you finished your own change and runs must show that it works before a PR. Use when the user asks you to prove a finished change, or to close out its plan.
---

# Prove

## Definitions

- **Change:** `git diff <base_sha>`: the commits since the base branch plus the uncommitted edits. `base_sha` is `git merge-base <base> HEAD`, where `<base>` is the `base` field of the plan (`base_branch` in an older plan). `head_sha` is `git rev-parse HEAD`. `diff_hash` is the first field of `git diff <base_sha> | shasum`.
- **Check:** one claim and the command that tests it. It ends as VERIFIED, NOT VERIFIED, or INCONCLUSIVE. INCONCLUSIVE is not a pass.
- **Finding:** a failure that a command shows. It has the command, the output, the output that the intent needs, and a ladder step.
- **Ladder:** 1 you said so. 2 you cite the line. 3 you walk the bad case and it does not reach. 4 you run real code. 5 you reproduce it in the running app.
- **Safety fact:** the one fact that makes the change safe.

## The Loop

1. **Frame.** Read the plan and the task. If you have new untracked files, run `git add -N <file>` for each. Read `git diff <base_sha>` and `git log <base_sha>..HEAD`. Record `base_sha`, `head_sha`, and `diff_hash`. Read the test card `~/dotfiles/ai/test-cards/<repo>.md`. If it is missing, take the test commands from the repo config and say so. Write the intent in one sentence. List each claim: each plan box and each claim in the task.
2. **Blast radius.** Find each caller and consumer of each changed symbol. Look past grep: data files, wire formats, DB columns, flags. Name the safety fact. Prove it at ladder step 4 with a command that calls the real code. If you cannot, write "unproven".
3. **Run checks.** Check the real artifact before you say that you finished a task. Do not infer from a proxy, a self-report, or "it compiles". Read ~/.agents/principles/prove-it-works.md before this step. Run the touched tests from the test card. Read the exit code. If `.claude/skills/verify/SKILL.md` exists, do its Launch, Doctor, Drive, Evidence, and Cleanup for the feature that the diff touches. For a speed claim, give `performance` a prompt whose first words are "The prove skill dispatched you". Copy its `Outcome:`, `Command:`, `Before SHA:`, `After SHA:`, and `Profiler:` lines. With no dispatch tool, do the `performance` skill yourself.
4. **Adversaries.** Read `roles.md`. Do what it says.
5. **Rerun findings.** Run each adversary command again yourself. Replay each counterexample one step at a time against the real code. Keep a finding only when your run shows the failure and the failure breaks the intent. Drop the others, with the reason. Merge findings that have one cause.
6. **Decide.** A fix that stays inside the plan and has one clear form: make it, run the affected checks again, and record the new `diff_hash`. A fix with two forms, or a fix that changes the plan: ask the user. Ask one question per message, in the decision template. With no user, write `Assumed: <value> (source: <file:line or spec section>)` only for a value with a source. Otherwise write `Open: <question>` and do not fix.
7. **Write the doc.** Read `review-template.md` and fill it. The doc goes in `<review root>/YYYY-MM-DD-self-<topic>.md`. The review root is the target of the `thoughts/shared` link plus `/reviews`. If `thoughts/shared` is not a link, it is `thoughts/shared/reviews`. In a worktree, use the main checkout (`git rev-parse --git-common-dir`, then its parent). Do not write the doc with a shell heredoc. A shell hook removes each line whose first character is `#`. If you cannot write files, put the full doc in your answer and name its path.
8. **Close the plan.** Tick each box that a VERIFIED check in the doc covers. Put the check name after the box. Add `## Deviations` if it is missing. Add one row for each difference between the plan and the change. Use the Deviation row of `build/SKILL.md`: rows are append-only, and the evidence is a pointer (SHA, `file:line`, PR number), not prose. Set `status: done` only when you ticked each box, no finding stays, and both adversaries ran. Otherwise set `status: in-progress`. If you cannot write files, put the plan edits in your answer.
9. **Reply.** Use the reply template.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Rules That Shape the Verdict

- **No command, no claim.** Each check and each finding has its exact command and its output. "Tests pass" with no command is not a check.
- **The exit code counts.** `| tail`, `; true`, and `|| true` hide it. Run the command again without them.
- **A gap is not a pass.** A check that you could not run is INCONCLUSIVE. Name the gap.
- **Record the SHA and the method.** Each check names the `diff_hash` that it ran against. After a fix, run the check again.
- **Outcome:** any finding that stays gives NOT VERIFIED. Else any INCONCLUSIVE check or an unproven safety fact gives INCONCLUSIVE. Else you give VERIFIED.

## Red Flags

- A check or a finding with no command or no output. Go back to step 3.
- No safety fact, or a safety fact below ladder step 4 with no "unproven". Go back to step 2.
- A finding that you did not run again yourself. Go back to step 5.
- A ticked box with no VERIFIED check. Go back to step 8.
- A fix with two forms that you made with no question. Go back to step 6.
- No `Principles applied:` line, or a principle file that you did not open. Go back to step 3.
- You did the adversary brief yourself, but you could make the worktrees and dispatch. Cost and time are not reasons. Go back to step 4.
- Only the inline fallback ran, and the plan says `status: done`. Write `adversary: inline` on the Outcome line. Go back to step 8.

## Decision Template

```
<the finding id, what the fix changes, the evidence for your pick, the risk>
**Decision:** <one question, worded so that yes accepts the recommendation>?
**Recommended:** <your pick>. <one reason>.
```

## Reply Template

```
Doc: <path>
Outcome: <VERIFIED | NOT VERIFIED | INCONCLUSIVE> at base_sha <sha>, diff_hash <hash>, adversary: <claude and codex | inline (<reason>) | <name> missing>
Safety fact: <fact>, ladder step <n>
Findings: <ids, or "none verified">. Dropped: <count and why>
Plan: <path>, status <status>, <ticked>/<total> boxes ticked
Open: <question>     (one line each, or the decision template)
Principles applied: prove-it-works -> <choice it changed>
```
