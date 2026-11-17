# Plan Template

Fill each section in order. Keep each heading. Replace each `<...>` slot. An empty section says why.

````markdown
---
kind: plan
title: <Feature name>
repo: <repo directory name>
date: YYYY-MM-DD
status: draft
spec: <path to the design doc or spec>
base: <the branch that the user or the spec names, else the origin/HEAD branch>
phases:
  - id: P1
    title: <Scaffold and check harness>
    files:
      - {path: "<path/to/file.py>", change: new}
  - id: P2
    title: <Phase title>
    files:
      - {path: "<path/to/other.py>", change: modified}
---

# <Feature name> plan

**Goal:** <one sentence>.
**Spec:** `<path>`.
**Base branch:** `<branch>`. Source: <the user, the spec, or `git symbolic-ref refs/remotes/origin/HEAD`>.
**Required skills:** <the skills that this plan needs, for example `build`, `tdd`, `data-op`, `staging`, and what each one runs>.
**Test card:** `~/.agents/test-cards/<repo>.md`.
**Full suite:** `<command>`. It runs once, in the last phase.

## Global constraints

- <A project-wide rule from the spec, one line, with the exact value copied.>

## Spec coverage

| Requirement and source | Owner phase | Observable result and check |
|---|---|---|
| <Exact requirement, with source path and line or user message> | P<n> | <Expected behavior and named test or command> |

**Added work:** <Work not stated in the spec, with the concrete risk that requires it, or none>.

## Review decisions

Use `review-checks.md`. Give each angle a row. An inapplicable angle gives its reason.
Keep standards evidence separate from spec coverage. Reference failure-mode rows instead of copying them.

| Angle | Evidence | Decision | Owner phase | Verification |
|---|---|---|---|---|
| <Angle> | <Source path and line, repo rule, or observed baseline> | <Concrete choice, or inapplicable with reason> | P<n> | <Named test, command, or inspection with expected result> |

## Before -> After

### Before
```mermaid
flowchart LR
  a["Existing part"] --> b["Existing part"]
```

### After
```mermaid
flowchart LR
  a["Existing part"] --> c["New part"]
  c --> b["Existing part"]
```

## Entry points

- <HTTP route, event, job, test endpoint, or consumer>: `<path:line>`. <What reaches the change through it.>

## Domain model

- `<Type, table, or state machine>` in `<path>`: `<signature or fields>`.

## Failure modes

| Write path | Mode | What happens | Owner phase | Test that pins it |
|---|---|---|---|---|
| <path> | Transaction scope | <what commits together, what does not> | P<n> | `<test id>` |
| <path> | Side effect before commit | <event, HTTP call, or file written before the commit> | P<n> | `<test id>` |
| <path> | Retry | <what a second run does> | P<n> | `<test id>` |
| <path> | Idempotency | <the key or the state check> | P<n> | `<test id>` |
| <path> | Shared state | <row, file, key, or branch that two actors write, and how the plan removes the sharing> | P<n> | `<test id>` |
| <path> | Partial failure | <for each external call: what stays in the other system when a later step fails. List each field that the next attempt does not write again, and its value after a retry. A field whose value differs between attempts (a new generated id, a lookup that failed the first time) is stale.> | P<n> | `<test id>` |
| <path> | Lifecycle | <each record that the code finds or reuses: its canceled, deleted, superseded, or other-owner state, and what the code does for each. Reuse of a canceled or deleted record, or a state change that brings it back, needs a decision in the handoff. Today's behavior is not a reason.> | P<n> | `<test id>` |
| <path> | Blocked retry | <each leftover record (reservation, number, lock row) whose owner is gone after a rollback, a delete, or a cancel, and why a later retry still passes> | P<n> | `<test id>` |
| <path> | Reporting | <each exception: retry, drop, 4xx, or 5xx, and its log level. An expected retry logs a warning and does not reach Sentry> | P<n> | `<test id>` |
| <path or input> | <Other input or failure that the spec implies> | <what happens> | P<n> | `<test id>` |

## Phase 1: <Scaffold and check harness>

**Blocked by:** none.
**Touched tests:** `<command for this phase only>`.

**File**: `<path/to/file.py>`

**Interfaces:**
- Consumes: <names and signatures from earlier phases, or none>.
- Produces: <names, parameters, and return types that later phases use>.

- [ ] **Step 1: Baseline.** Run `<check>` on the code before the change. Record the value: `<value>`.
- [ ] **Step 2: Write the failing test** `<test id>`. Assert `<exact value from the spec>`.
- [ ] **Step 3: Run it.** Expected: FAIL with `<the predicted mismatch>`, not an import, collection, or missing-file error.
- [ ] **Step 4: Implement** `<name>(<params>) -> <type>` in `<path>`.
- [ ] **Step 5: Run the touched tests.** Expected: PASS.
- [ ] **Step 6: Commit** with message `<message>`.

#### Automated verification
- [ ] `<touched-test command>` passes.

#### Manual verification
- [ ] <A check that only a person or a live run can do, or "None." with the reason.>

## Phase 2: <Phase title>

**Blocked by:** P1.
**Touched tests:** `<command>`.

**File**: `<path/to/other.py>`

<Same blocks as Phase 1. The last phase also runs the full suite once.>
````

## Manifest rules

Grimoire renders the plan from the manifest and flags each drift. `plan-lint` prints each drift as one line.

- Each phase has `## Phase N: <title>`, and its id in the manifest is `PN`. Keep a title to about 40 characters.
- Each `**File**:` line has one backticked path. Write the colon after the bold marks, as in the template.
- Each `**File**:` path in a phase is in that phase's manifest `files`, and each manifest path is in the body. A file that two phases change is in both.
- `change` is `new`, `modified`, or `deleted`. `status` is `draft`, `approved`, `in-progress`, or `done`.
- Paths are relative to the repo. A file in another repo starts with `~/`.
- `## Before -> After` holds `### Before` and `### After`, each with one mermaid block. Each diagram shows only the parts that the plan touches, at most about 12 nodes. A new part is only in After. A removed part is only in Before. Use `flowchart LR`, quote each label, and do not start a label with `/`.
- The file starts with the `---` line. With text before it, Grimoire does not read the manifest and does not check it. `plan-lint` exits 1 for this, and for a frontmatter without `kind: plan`.
- The manifest `files` list of a phase is the file set that it owns. Two parallel phases do not share a path.

## Step rules

`plan-lint` checks each checkbox step. Each rule below is one line of its output when the step breaks it.

- Write each step as `- [ ] **Step N: <title>**`.
- A test step writes or changes a test. `plan-lint` finds it by its title (Write or Add with test, or the word test or tests) or by a sentence that starts with Test. Name each test in backticks, for example `test_parse_limit`. Give a literal expected value in backticks, for example `parse_limit("5") == 5`.
- A code step writes or changes code. `plan-lint` finds it by an Implement title, by a source file in backticks (`.py`, `.sh`, `.js`, `.ts`, `.go`, `.rs`, `.nix`) or by a fenced `def`, `func` or `class`. Give the signature in backticks as `name(params) -> type`. Give the file path in backticks.
- A prose edit (only `.md` or other non-source files) is not a code step. Do not give it a signature.
- A verification step gives the command and the output that means it passed.

## Self-review

The self-review is a technical audit. Its goal is a plan that is sound before the build starts.
Walk the planned code and the code that it touches. Do not check the form of the plan.
Fix each issue in a phase, with a test or a check in that phase. Do not review again.

1. **Requirements.** Trace each requirement to its phase and observable result. Find missing, partial, or incorrect behavior. Cut work with no requirement or concrete risk.
2. **Retry and idempotency.** For each write path, walk one failed attempt and then its retry.
   - Find what stays in the other system, and each field that is stale after the retry.
   - Find each leftover record that blocks the retry after a rollback, a delete, or a cancel.
   - Name the idempotency key or the state check. Find what a second delivery of the same event does.
3. **Transactions and concurrency.** Find each side effect before the commit. Find each row, key, or file that two workers write. Name the lock or the unique constraint, or give each row one writer.
4. **Lifecycle.** Find what the code does with a canceled, deleted, or superseded record that it finds or reuses.
5. **Queries and indexes.** For each new or changed query, name the index that it uses on the real database dialect.
   - Find N+1 loops, result sets with no limit, and full scans on large tables.
   - A migration names its lock, its lock timeout, and its effect on existing rows.
6. **External calls.** For each call, name the timeout, the retry policy, and the limits of the other system. Find what happens when a call times out after the other system wrote the record.
7. **Errors and reporting.** For each exception, name its outcome: retry, drop, 4xx, or 5xx. An expected retry logs a warning and does not reach Sentry. Find each path that fails loudly today and becomes quiet.
8. **Data and deploy.** Find stored rows, running process instances, and queued events in the old shape. Find version skew between stage and prod. Find each rule that config checks at deploy time and code checks at runtime.
9. **Contracts.** Each name, type, and signature in a later phase matches its first use. Find each caller of a changed signature, schema, or event. Find doc text and comments that the change makes false.
10. **Tests.** Each risk above has a test that fails without its fix. A test pins behavior, not call order.
