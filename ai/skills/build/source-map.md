# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **impl:** mattpocock-skills `skills/engineering/implement/SKILL.md` (tdd at seams, single test files often, full suite once at the end, commit to the branch).
- **fresh:** pstack-claude `plugins/pstack/skills/poteto-mode/SKILL.md`, Subagents section (fresh subagents with consolidated scope, review the diff yourself, never trust a "done" summary).
- **swarm:** pstack-claude `plugins/pstack/skills/swarm/SKILL.md` (every brief stands alone: goal, scope, verify, report; each worker gets its own worktree or output).
- **fio:** pstack-claude `plugins/pstack/skills/figure-it-out/SKILL.md` Phase C (verify the artifact, never a self-report; a gamed gate is a reset and a harder contract; a wrong gate is fixed in its own change).
- **smyw:** pstack-claude `plugins/pstack/skills/show-me-your-work/SKILL.md` (one row per decision, append-only, a wrong call gets a superseding row, evidence is a pointer).
- **nc:** pstack-claude `plugins/pstack/skills/no-comments/SKILL.md` (no narration comments and no workaround comments; reshape the code).
- **sdd:** superpowers `skills/subagent-driven-development` (SKILL.md and implementer-prompt.md): the review loop, the setup scan of interfaces between tasks, the dispatch contents, the four statuses, the no-subagents contract for the implementer.
- **old:** `git show 1a7029b^:ai/skills/implement/SKILL.md` (fail-first receipt: the expected error, not an import error; fix a test that fails for the wrong reason; never commit a red tree).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 build entry, 8.5 test cards, 8.7 principles.
- **brief:** Task 4.1 brief and the dispatch for it (receipt format `Fail-first: <test id> expected <x> got <y>`; only a failed assertion is red; touched tests per step, full suite once per merge point).
- **mp:** sibling `make-plan` plan template (`Consumes` and `Produces` lines, `status` values, test card path).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "Brief" is `brief-template.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Read the plan once, in full. Read the test card; if missing, use the repo config and say so. | sdd Setup (read the plan once). spec 8.5 test cards. mp Loop 2 (missing card). | P | Loop 1. | GREEN |
| Work in `~/wt/<repo>/<name>` off the base branch of the plan. | sdd Setup (isolated workspace). Global Constraints (worktree line). | P | Loop 1. Repo Rules. | GREEN |
| Set `status: in-progress` at start. Do not set `done`; `prove` sets it. | mp Manifest rules (status values). Plan Task 5.1 prove entry (sets status). | P | Loop 1. | Untested. |
| Compare each `Consumes` with an earlier `Produces`. Pick one name. Write a Deviation row. Do not change the phase text. | sdd Setup scan (one row per pair of tasks that share an interface). smyw (append-only). | D | Loop 2. Red flags. | RED, GREEN |
| One brief per phase from `brief-template.md`. The brief stands alone and names its interfaces and Deviations. | spec 8.4 (consolidated brief with hard rules). swarm Phase B (every brief stands alone). sdd Dispatch (interfaces the brief cannot know, ambiguity resolutions, report path). | P | Loop 3. Brief. Red flags. | RED, GREEN |
| One fresh implementer per phase. Fix rounds go to a new fresh implementer with consolidated scope. | spec 8.4. fresh (fresh subagents by default, consolidated scope). | D | Loop 4. Loop 6. | Untested. The scenario has no dispatch tool. |
| Parallel phases only with disjoint file sets, each in its own worktree. Otherwise one at a time. | separate-before-serializing-shared-state (parallel subagents own disjoint files). swarm Phase A (own writable output). sdd (never parallel implementers on shared files). | D | Loop 4. | Untested. |
| Review the diff from the base SHA, not the report. Run the touched tests yourself. | fresh (review the diff, do not pass through what it said). fio Phase C (inspect the artifact, never a self-report). sdd review loop. | D | Loop 5. Red flags. | GREEN |
| At most three fix rounds per phase, then a Deviation row for each open finding. | sdd fix loop (a round cap, then adjudicate and ledger each open finding). Cap 3 instead of 5: fresh implementers each round (fresh) make each round cost a full context. | P | Loop 6. | Untested. |
| A receipt under each phase: `Fail-first: <test id> expected <x> got <y>`. | brief (format). old step 1 (receipt before the fix). spec 8.4 (predicted mismatch). | O | Definitions. Loop 7. Output template. Brief Report. | RED, GREEN |
| Red is a failed assertion. Import, collection, syntax, and argument-count errors are not red. Add the smallest stub, then run again. | old step 1 (not an import error; a test that fails for the wrong reason is not a receipt, fix it first). brief (only a failed assertion). spec 8.4. | D | Definitions. Rules. Brief Hard rules. Red flags. | RED, GREEN |
| Commit each phase. Never commit a red tree. | impl (commit to the branch). old Hard rules (never commit a red tree). | P | Loop 7. Brief Hard rules. | GREEN |
| Touched tests per step. The full suite once, at the end. | impl (single test files regularly, full suite once at the end). brief. spec 8.4 (test card for touched tests). | D | Rules. Loop 8. Brief Hard rules. Red flags. | RED, GREEN |
| `tdd` for each test-first step. `debug` when a cause is not known. | impl (call tdd at seams). spec 8.4 (calls tdd and debug). | P | Rules. Brief Hard rules. | Untested. |
| A gamed gate: reset to the base SHA, make the brief stricter, dispatch again. | fio Phase C. spec 8.4. | D | Rules. Brief Hard rules. | Untested. |
| A wrong gate: fix it in its own commit with a Deviation row. Never go around it. | fio Phase C. spec 8.4. | D | Rules. | Untested. |
| Deviations: one row per decision, append-only, a wrong row gets a new row, evidence is a pointer. | smyw Format and Rules. spec 8.4. | D | Definitions. Loop 2. Loop 6. Red flags. | RED, GREEN |
| Reversible work proceeds. Only a merge or push to main/master, and a production write, need the OK. | never-block-on-the-human (reversible half). Controller ruling. sdd (continuous execution, rulings not stalls). | D | Rules. | GREEN |
| No dispatch tool: do each phase yourself, with the brief as the instruction, and read its principle files. | sdd (inline execution when no subagent tool). spec 8.7 layer 3. | P | Rules. | GREEN |
| Cannot write files: each brief, command, receipt, and Deviation row goes in the answer. | research and brainstorm (no-write fallback). | P | Rules. | GREEN |
| Hand off to `prove` after the full suite. | spec 8.1 Workflow (build, then prove). | P | Loop 8. Output template. | GREEN |
| The implementer does not dispatch subagents or reviewers. | sdd implementer-prompt (You Do Not Dispatch Subagents). | D | Brief Hard rules. | Untested. |
| Change only the files of the phase. Report NEEDS_CONTEXT for a missing file. | sdd implementer-prompt (follow the plan's file structure, report scope growth). | D | Brief Hard rules. | Untested. |
| No narration comments and no workaround comments. Reshape the code. | nc. spec 8.4 (no-comments hard rule). | D | Brief Hard rules. | Untested. |
| Report to a file. Reply with status, commits, tests, and concerns only. | sdd Dispatch (report file and short contract) and implementer-prompt (four statuses). | O | Brief Report. | Untested. |
| Principle pointers: separate-before-serializing-shared-state at dispatch, boundary-discipline at review. The brief names both plus laziness-protocol. | spec 8.7 (table and layer 3). PRINCIPLE_TARGETS in `ai/tests/test_skills_lint.py`. | D | Loop 3. Loop 4. Loop 5. Brief Principles. Output template. | GREEN |
| Four repo lines, verbatim. | Brief Global Constraints. | D | Repo Rules. Brief Hard rules. | Untested. |

## Cut

- sdd: the workspace and ledger scripts (`sdd-workspace`, `task-brief`, `review-package`). The plan holds the receipts and the Deviations, so no separate ledger is needed.
- sdd: model selection and the tier table. The harness and the user pick models. The skill text stays model-free.
- sdd: batching small same-shape tasks into one dispatch. `make-plan` sizes phases, so the batch is the plan's choice.
- sdd: resume the same implementer in fix rounds 1 to 3. fresh overrides it: each round goes to a new fresh implementer with consolidated scope.
- sdd: the separate task reviewer subagent and the scoped re-review prompt. `build` reads the diff itself (fresh: you own the subagent's work). An independent review comes from `prove` and `review-pr`.
- sdd: the final whole-branch review, the finish list of rulings, and finishing-a-development-branch. `prove` and `pr` own those steps.
- sdd: the rationalizations table and the example workflow. The red flags cover the same failures in less text.
- swarm: race, rank-all, and best-of shapes, the Models and Reasoning effort sections. A plan run is a sequence of phases, not a race.
- fio: Phases A, B, and E (frame, design the workflow, verify the whole). `make-plan` frames and designs. `prove` verifies the whole.
- smyw: the separate TSV file, the `start` rows, the transcript audit, and the cross-model trail review. The spec puts the Deviations in the plan, and `prove` reviews the result.
- old: the prod-guard rules, the wrappers, and the write-tree hash. The Eye build runs are gone. The receipt format is fixed by the brief.
- old: the list of the user's calls. The never-block-on-the-human ruling narrows it to a merge or push to main/master and a production write.
- impl: fetch a ticket from the issue tracker, and call a code-review skill at the end. The input is a `make-plan` plan. `prove` follows `build`.
- impl: run typechecking regularly. The test card holds the type command. The touched-test rule covers the loop.

## Pressure scenarios

Scenario (`scratch-4.1/scenario.txt`): execute a two-phase plan in a scratch repo `billing`. P1 produces `add_vat(net_cents, country)`. P2 consumes `gross_cents(net_cents, country)` and adds a `country` parameter to `invoice_total`. The run cannot edit files or start agents, so it writes each step in its answer.

**RED** (no skill, both CLIs, read-only, 2026-10-30):
Claude ($0.40) took the ImportError (P1) and the TypeError (P2) as red. It wrote no brief, started no implementer, changed the P2 phase text, set `status: done`, and wrote no `Fail-first:` receipt. Codex (168k input tokens) added stubs to reach the assertions, but its briefs had no hard rules and no receipt format. It also changed the plan text and set an invalid status. Failure: an import or type error counted as red, no brief, the plan text changed instead of an append-only Deviation row, and no receipt.

**GREEN** (skill loaded, both CLIs, three iterations):

- GREEN-1 (Claude $0.49, Codex 146k): both CLIs wrote one brief per phase, added a stub to reach the assertion, and wrote `Fail-first: tests.test_tax.TaxTest.test_add_vat_de expected 1190 got 1000` and `Fail-first: tests.test_invoice.InvoiceTest.test_total_gross_de expected 2380 got 2000`. Each CLI also added Deviation row D1 (`add_vat` against `gross_cents`), ran the full suite once at the end, and handed off to `prove`. Both CLIs failed the harness check because they did not read the principle files. Fix: the opening line of the loop and the red flag for an unopened principle file.
- GREEN-2 (Claude $0.48, Codex 255k): Codex PASS. Claude read both files, but with one `cat` loop in Bash. The harness counts only Read calls. Fix: open each file in its own call, with the Read tool if you have one.
- GREEN-3 (Claude $0.47, Codex 140k): Claude PASS. Codex kept the behavior of GREEN-1 (receipts, D1 to D4 append-only, full suite once, `prove`) and named each principle with the choice it changed. But its heading was "The principles change the execution as follows:", not the `Principles applied:` line, so the harness check failed. Open: the iteration cap (3) is reached. A candidate fix is "End with the output template, also in a dry run", and it is not tested.
