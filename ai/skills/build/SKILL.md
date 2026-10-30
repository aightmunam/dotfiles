---
name: build
description: Use when a written plan is ready to execute. Use when the user asks you to build, execute, or implement a plan from make-plan, phase by phase.
---

# Build

## Definitions

- **Plan:** a `make-plan` plan in `thoughts/shared/plans/`. Each phase has its files, its interfaces, and its touched tests.
- **Brief:** the file that one implementer reads for one phase. You fill `brief-template.md`.
- **Red:** the new test fails on its assertion with the value that you predicted. An import error, a collection error, a syntax error, or a wrong argument count is not red.
- **Receipt:** one line under the phase in the plan: `Fail-first: <test id> expected <x> got <y>`.
- **Deviation:** one row in `## Deviations` at the end of the plan, for each decision that the plan did not make. Rows are append-only. A wrong row gets a new row that replaces it. The evidence is a pointer (SHA, `file:line`, PR number), not prose.
- **Touched tests:** the test command of the phase. The plan or the test card `~/dotfiles/ai/test-cards/<repo>.md` gives it.

You own the run. The implementer writes the code of a phase.

## The Loop

**First, read `brief-template.md`. Then open each principle file that it names, one file per call.** Steps 4 and 5 apply them. Do this also in a dry run.

1. **Read.** Read the plan once, in full. If its header does not say `status: approved`, stop and report the status. A draft is not the user's yes. Read the test card. If it is missing, take the test commands from the repo config and say so. Work in `~/wt/<repo>/<name>` off the base branch of the plan. Set the plan to `status: in-progress`.
2. **Check names.** Compare each `Consumes` line with the `Produces` line of an earlier phase. For each mismatch, pick one name. Write a Deviation row for it. Do not change the phase text.
3. **Brief.** Fill `brief-template.md` for the next phase. Add the interfaces from earlier phases and each Deviation row that touches the phase. Read each principle file that the brief names.
4. **Dispatch.** When actors might write the same state, first remove the sharing. Read ~/.agents/principles/separate-before-serializing-shared-state.md before this step. Record the base SHA. Give the brief to one fresh implementer. Run phases in parallel only when the plan gives each one a disjoint file set. Then each phase gets its own worktree.
5. **Review.** Check input at the system boundary and trust typed data inside. Keep business logic in pure functions. Read ~/.agents/principles/boundary-discipline.md before this step. Read the diff from the base SHA, not only the report. Run the touched tests yourself. Check that the receipt shows red by the definition. For each `Assumed:` line in the report, find its source in the phase text or at the cited `file:line`. An `Assumed:` line with no such source is a finding. An `Open:` line means NEEDS_CONTEXT. Answer it from the plan in a new brief. If the plan has no answer, ask the user one question, with a recommended answer.
6. **Fix.** Give each finding to a new fresh implementer. Send the brief, the report, the findings, and the branch. Stop after three fix rounds on one phase. Then write a Deviation row for each open finding.
7. **Record.** Check that the receipt is under the phase in the plan. The implementer writes it with `tdd`. Do not write it a second time. Commit the phase. `prove` ticks the plan boxes and sets `status: done`. Never do either. Go to step 3 for the next phase.
8. **Finish.** After the last phase, run the full suite once. Give the output template. Then hand off to `prove`.

## Rules

- **Touched tests per step.** The full suite runs once, at the end, before the merge point.
- **Reach the assertion.** If the new test stops before its assertion, add the smallest stub (the name, or the new parameter). Run it again. Only then write the receipt.
- **Use the sibling skills.** Each test-first step uses `tdd`. A failure with a cause that is not known uses `debug`.
- **A gamed gate is a reset.** If an implementer weakens a test or skips a check, reset the branch to the base SHA. Make the brief stricter. Dispatch again.
- **A wrong gate gets its own change.** Fix the gate in a separate commit, with a Deviation row. Never go around it.
- **Proceed on reversible work.** Only a merge or push to main/master, and a production write, need the user's OK.
- **No dispatch tool.** Do each phase yourself. The brief is your instruction. Read each principle file that it names.
- **Cannot write files.** Put each brief, command, receipt, and Deviation row in your answer.

## Output Template

```
Plan: `<path>` (status: in-progress). Worktree: `<path>` on `<branch>`.
| Phase | Commits | Receipt | Touched tests |
| P<n> | <base7>..<head7> | Fail-first: <test id> expected <x> got <y> | `<command>`: <result> |
Deviations added: <count>. <one line each, with its pointer>.
Full suite: `<command>`: <result>. It ran once.
Next: `prove` on this plan.
Principles applied: <name> -> <choice it changed>, one for each principle file that you read.
```

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- A receipt shows an import, collection, or type error. Go back to Rules (reach the assertion).
- A step ran the full suite before the last phase. Go back to step 7.
- A phase started with no brief. Go back to step 3.
- You changed the text of a phase, or edited a Deviation row. Go back to step 2.
- Your output names a principle file that you did not open in this session. Go back to the start of the loop.
- You accepted a phase from its report alone. Go back to step 5.
- You wrote phase code while a dispatch tool was there. Go back to step 4.
- You continued on a plan whose status was not `approved`. Go back to step 1.
- You ticked a plan box or set `status: done`. Go back to step 7.
- An answer with no `Principles applied:` line. Go back to step 8.
