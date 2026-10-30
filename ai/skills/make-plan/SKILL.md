---
name: make-plan
description: Use when a spec or design is ready and needs ordered, checkable tasks. Use when brainstorm hands off an approved design doc, or when the user asks for an implementation plan, phases, or tickets for a change.
---

# Make Plan

## Definitions

- **Phase:** a vertical slice that fits one fresh context window and lands green. It names the phases that block it.
- **Manifest:** the `kind: plan` frontmatter. Grimoire reads it. Each `**File**:` line in a phase body matches one manifest entry.
- **Baseline:** the value that a check reads on the code before the change. A check then reads "old value vs new value".
- **Decision:** a choice that only the user can make. A fact that code, a file, or a run can show is not a decision.

You own the plan, not the code. Do not implement.

## The Loop

**First, read `plan-template.md`.** Your plan fills it in order. Steps 3 to 6 each name one principle file. Read all four files in full, also when a step does not apply. Write the full path of each file in the read command, so that the transcript shows each read.

1. **Read.** Read the design doc or spec in full. Copy its exact values (names, limits, paths). For one or two files with an obvious approach, say so, name `tdd`, and stop. For several independent subsystems, write one plan for each.
2. **Explore.** Read the code that the spec touches. Read the test card `~/dotfiles/ai/test-cards/<repo>.md`. If it is missing, take the test commands from the repo config and say so. List the entry points: HTTP routes, events, jobs, test endpoints, and other consumers. For a wide spec, give 2 to 4 angles to `explorer` agents. With no dispatch tool, do each angle yourself. If a run can answer a question, run it. Find the base branch. Use the branch that the user or the spec names. Otherwise use the repo default branch from `git symbolic-ref refs/remotes/origin/HEAD`. Write the branch and its source in the plan header.
3. **Model.** Put the real domain in a data structure. Do not scatter it over conditionals. Read ~/.agents/principles/model-the-domain.md before this step. Name each new type, table, and state machine, with its file and signature.
4. **Order.** Get the data structures right before you write logic. Read ~/.agents/principles/foundational-thinking.md before this step. Phase 1 is the scaffold and the check harness, with a baseline from the code before the change. Then put the riskiest unknown first. Cut the rest into phases as in Definitions. Each phase has its `Blocked by` line.
5. **Wide changes.** When work is not trivial, build the tool that does it. Do not do it by hand. Read ~/.agents/principles/build-the-lever.md before this step. A change across many files has three steps. Add the new form. Move the callers in batches with a script or codemod. Then remove the old form. The script is a file in the plan.
6. **Failure modes.** When actors might write the same state, first remove the sharing. Read ~/.agents/principles/separate-before-serializing-shared-state.md before this step. For each write path, write a row for each of five modes: transaction scope, side effects before commit, retries, idempotency, and shared state. Shared state includes Postgres row contention and parallel workers. Add a row for each other input or failure that the spec implies. Each row names the phase and the test that pins it. Two phases are parallel when neither one blocks the other, directly or through a chain. The manifest `files` lists of two parallel phases do not share a path.
7. **Write.** Fill the template. Put the plan in `thoughts/shared/plans/YYYY-MM-DD-<topic>.md` of the repo where the change lands, with `status: draft`. In a worktree, use the main checkout (`git rev-parse --git-common-dir`, then its parent). If you cannot write files, put the full plan in your answer, from its first `---` line, and name its path.
8. **Check.** Do the self-review in the template. Run `~/dotfiles/ai/bin/plan-lint <plan>`. It exits 1 when line 1 of the file is not `---` or the frontmatter has no `kind: plan`. It also exits 1 for a test step with no test name or no literal value. It exits 1 for a code step with no signature or no file path. Exit 1: fix each line that it prints, and run it again. Exit 2 is a setup error. Stop. Do not run it again. Put the exit code and the message in the handoff. With exit 2, no file, or no script on disk, check the manifest rules by hand and say so in the handoff.
9. **Hand off.** Use the handoff template. Ask only decisions. Reversible work does not wait for an answer.

## Rules That Shape the Plan

- **A step is one action with a checkable result.** The builder can write exactly one reasonable thing from it.
- **Decide, do not transcribe.** A test step gives the test name and a literal expected value. A code step gives the file, the signature, and the exact values. It gives a body only for an algorithm that the tests do not fix.
- **No empty lines.** "TBD", "handle edge cases", and "add validation" decide nothing. Replace each with the decision.
- **Tests per phase.** Each phase runs only its touched tests. The full suite runs once, in the last phase.
- **An empty section says why.** Entry points and failure modes are always present.
- **No old-tool residue.** No ticket ids such as `ENG-XXXX`, no `thoughts/allison`, no `npm` commands in a repo without npm, and no `humanlayer` command except `humanlayer thoughts sync`.

## Handoff Template

```
Plan: `<path>` (status: draft). plan-lint: <exit 0, or exit 1 with each printed line, or exit 2 with its setup message, or "not run" with the reason>. Base: `<branch>` (<user, spec, or origin/HEAD>).
Phases: P1 <title>, P2 <title> (blocked by P1), ...

1. **<Decision, worded so that yes accepts the recommendation>?**
   Recommended: <answer>. Link: `<path:line>`. Change: <what the answer changes>. Evidence: <the fact behind the pick>. Risk: <the risk, also when low>.

Proceeds without an answer: <work, or "nothing">. Next: `build` on this plan.
Principles applied: <name> -> <choice it changed>, one for each principle file that you read.
```

When the user answers, put each answer into the plan and set `status: approved`. With no open decision, set `status: approved` at once.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- The handoff asks "approve?", or a question has no recommended answer. Go back to step 9.
- A question asks for a fact that code, a file, or a run can show. Go back to step 2.
- A check has no baseline, or the riskiest unknown comes late. Go back to step 4.
- The plan edits many files by hand. Go back to step 5.
- Two parallel phases touch the same file, row, or key. Go back to step 6.
- plan-lint printed a line that you did not fix. Go back to step 8.
- You trust exit 0 on a file whose line 1 is not `---` or that has no `kind: plan` manifest. Go back to step 7.
- You ran plan-lint again after exit 2, or you edited the plan to fix a setup error. Go back to step 8.
- The base branch is not the one that the user or the spec names, or the `origin/HEAD` branch. Go back to step 2.
- The transcript does not show a read of a principle file that a step names, with its full path. Go back to that step.
- You wrote product code. Stop. You own the plan.
