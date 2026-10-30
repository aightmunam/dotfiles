# Brief Template

`build` fills one brief for each phase and gives it to one fresh implementer. The brief stands alone. It holds the goal, the scope, how to verify, and what to report. Replace each `<...>` slot. Keep each heading. Put the brief in a file next to the plan run, for example `.superpowers/sdd/<plan>/phase-<n>-brief.md`, and give the implementer its path.

````markdown
# Brief: Phase <n> of `<plan path>`

## Goal

<One line: where this phase fits in the plan, and what it makes true.>

Read the section `## Phase <n>: <title>` of the plan. It is your requirement. Use its exact values (names, paths, numbers). Do not read the other phases.

Work in `<worktree path>` on branch `<branch>`. The base SHA is `<sha>`.

## Interfaces from earlier phases

- <name(params) -> type> in `<path>`, made by P<m> in commit `<sha7>`.
- <Or "None.">

## Deviations that touch this phase

- <The row from `## Deviations` of the plan, for example: P2 consumes `add_vat`, not `gross_cents`.>
- <Or "None.">

## Hard rules

- Do all the work yourself. Do not start a subagent, and do not start a reviewer. `build` reviews your diff.
- Change only the files of this phase. In the plan, add only the receipt lines under `## Phase <n>`. Do not change other plan text, and do not tick boxes. If the phase needs a file that it does not list, stop and report NEEDS_CONTEXT.
- Write each test first with `tdd`. Write each receipt under `## Phase <n>` in the plan, as `tdd` says. If a cause is not known, use `debug`.
- Red is a failed assertion with the value that you predicted. An import error, a collection error, a syntax error, or a wrong argument count is not red. If the test stops before its assertion, add the smallest stub (the name, or the new parameter), then run it again.
- Run only the touched tests: `<command>`. Do not run the full suite.
- Do not weaken a test, skip a check, or change a gate to make it pass. If you think that a gate is wrong, stop and report it.
- No comments that tell what the code does, and no comments that explain a workaround. Change the shape of the code instead.
- Commit the green tree with the message `<message>`. No attribution lines.
- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Principles

Read each file before you write code:

- Read ~/.agents/principles/boundary-discipline.md before this step. Check input at the system boundary and trust typed data inside. Keep business logic in pure functions.
- Read ~/.agents/principles/separate-before-serializing-shared-state.md before this step. When actors might write the same state, first remove the sharing.
- Read ~/.agents/principles/laziness-protocol.md before this step. Make the smallest change that solves the problem. Remove before you add.

## Report

Write the full report to `<report path>`:

- What you changed, with the files.
- The receipt: `Fail-first: <test id> expected <x> got <y>`, with the command and the output lines that show it. It is also under `## Phase <n>` in the plan.
- Each `Assumed: <value> (source: <file:line or spec section>)` line that `tdd` wrote. Or "None."
- Each `Open: <question>` line that `tdd` wrote. Or "None."
- The touched-test command and its result after the change.
- Principles applied: <name> -> <choice it changed>, one for each principle file that you read.
- Each concern.

Then reply with only these lines:

- Status: DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, or BLOCKED. An `Open:` line makes the status NEEDS_CONTEXT.
- Commits: <sha7> <subject>.
- Tests: <one line>.
- Concerns: <one line each, or "none">.
````
