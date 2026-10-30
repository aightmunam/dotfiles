# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **sp:** superpowers `skills/writing-plans/SKILL.md` (the only file in that directory).
- **tt:** mattpocock-skills `skills/engineering/to-tickets/SKILL.md`.
- **mpp:** pstack-claude `plugins/pstack/skills/poteto-mode/playbooks/multi-phase-plan.md`.
- **cp:** pstack-claude `plugins/pstack/skills/poteto-mode/scripts/check-plan.mjs` (the pstack plan linter).
- **fio:** pstack-claude `plugins/pstack/skills/figure-it-out/SKILL.md`, Phase B.
- **old:** `ai/skills/create_plan/SKILL.md`, only the manifest frontmatter (`kind: plan`), the `## Before → After` mermaid contract, and the `## Phase N:` headings.
- **pl:** `ai/bin/plan-lint` and Grimoire `app/data/plan_parser.py` (what the lint checks).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 make-plan entry, 8.5 (test cards, plan linter), 8.7 (principles).
- **brief:** Task 3.6 brief and the controller notes for it (handoff ruling, same as brainstorm).
- **rs:** `ai/skills/research/SKILL.md` (worktree path, no-write fallback, explorer fallback).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (the form bar: an empty section says why).
- **ketchup:** `ai/AGENTS.md` writing standard (item format: link, change, evidence, risk).
- **review:** Task 3.6 review and the controller rulings for fix round 1.
- **audit:** `.superpowers/sdd/2026-10-30-skill-rework/skill-audit.md` items 9 and 10, and final-review M3 (round 2).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "T" is `plan-template.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| You own the plan, not the code. Do not implement. | mpp (opening line). | D | Definitions. Red flags. | GREEN: no run wrote product code. |
| One or two files with an obvious approach: say so, name `tdd`, stop. | mpp step 1. Router tie-break tdd / build. | P | Loop 1. | Untested. The scenario is a multi-step change. |
| Several independent subsystems: one plan for each. | sp Scope Check. | P | Loop 1. | Untested. |
| Copy the exact values of the spec. | sp Global Constraints (exact values, verbatim). | P | Loop 1. T Global constraints. | GREEN |
| Explore the code. Facts are yours. If a run can answer a question, run it. | mpp step 2 (settle by prototype, ask only what no run settles). tt step 2. | D | Loop 2. Red flags. | GREEN |
| Read the repo test card. Missing card: take commands from the repo config and say so. | spec 8.5 (test cards). brief Interfaces. | P | Loop 2. T header. | GREEN |
| List the entry points: HTTP, events, jobs, test endpoints, consumers. | spec 8.4 (required section). mpp step 3 (explorers return entry points). | O | Loop 2. T Entry points. Rules. | RED: neither plan had it. |
| Wide spec: 2 to 4 angles to `explorer` agents. No dispatch tool: do each angle yourself. | mpp step 3 (explore in subagents, return pointers). rs Loop 3. | P | Loop 2. | Untested. |
| Model the domain in a data structure. Name each type, table, and state machine with its file and signature. | spec 8.7 (model-the-domain, design step). sp File Structure. review M4. | P | Loop 3. Pointer. T Domain model. | GREEN |
| Data structures before logic. Phase 1 is scaffold and check harness. | spec 8.7 (foundational-thinking, scaffold first). fio Phase B. | P | Loop 4. Pointer. T Phase 1. | GREEN |
| Baseline from the code before the change, so a check reads old value vs new value. | fio Phase B. spec 8.4. | D | Definitions. Loop 4. T Step 1. Red flags. | GREEN |
| Riskiest unknown first. | fio Phase B. spec 8.4. | D | Loop 4. Red flags. | GREEN |
| A phase is a vertical slice, fits one fresh context window, lands green, names its blocking edges. | tt step 3 (vertical slices, one context window, blocking edges). spec 8.4. | P | Definitions. T Blocked by. | GREEN |
| Cut the work into phases, each with its `Blocked by` line. | tt step 3. review M1. | P | Loop 4. T Blocked by. | GREEN |
| A wide change is expand, migrate in batches, contract. | tt step 3 (wide refactors). spec 8.4. | P | Loop 5. | Untested. The scenario has no wide change. |
| A wide change uses a script or codemod, not hand edits. The script is a file in the plan. | spec 8.7 (build-the-lever). | D | Loop 5. Pointer. Red flags. | Untested. |
| Failure modes: transaction scope, side effects before commit, retries, idempotency. | spec 8.4 (required section). | O | Loop 6. T Failure modes. | RED: neither plan had it. |
| Shared state: Postgres row contention and parallel workers. Remove the sharing first. | spec 8.7 (separate-before-serializing-shared-state, foundational-thinking concurrency question). | D | Loop 6. Pointer. T Failure modes. Red flags. | GREEN |
| Two phases are parallel when neither blocks the other, directly or through a chain. Parallel phases have no shared path in their manifest `files` lists. | spec 8.4 and 8.7. fio Phase B (parallelize only across seams). review M2. | D | Loop 6. T manifest rules. Red flags. | Untested. The GREEN plans are linear. |
| Each failure mode names its owner phase and the test that pins it. | sp Review Focus (each line gets its test in the owning task). | O | Loop 6. T Failure modes. T self-review 4. | GREEN |
| One row per mode per write path. A row for each other input or failure that the spec implies. | sp Review Focus (input classes the spec implies). review M5. | O | Loop 6. T Failure modes. | GREEN |
| Plan path `thoughts/shared/plans/YYYY-MM-DD-<topic>.md` of the repo where the change lands, `status: draft`. | spec 8.4 Output. old (status values). | P | Loop 7. T frontmatter. | Untested. The runs cannot write. |
| In a worktree, use the main checkout. Cannot write: the full plan in the answer, from its first `---` line. | rs Loop 6. pl (text before `---` turns off the manifest check). | P | Loop 7. T manifest rules. | GREEN |
| Manifest `kind: plan` with phases and files. `## Phase N:` headings. `**File**:` lines match the manifest. | old (manifest, phase headings, manifest rules). pl. | O | Definitions. T frontmatter. T manifest rules. | RED: neither plan had a manifest. |
| `## Before -> After` with two mermaid diagrams. | old (diagram rules). pl. | O | T Before -> After. T manifest rules. | RED: neither plan had it. |
| Header: goal, spec, base branch, required skills, test card, full suite. Required skills are the skills this plan needs. | spec 8.4 (header). sp Plan Document Header (goal, spec). review M3. | O | T header. | RED: no base branch in either plan. |
| Base branch: the one that the user or the spec names, else the default branch from `git symbolic-ref refs/remotes/origin/HEAD`. Write it and its source in the header. | spec 8.4 (header: `build` branches from it, `pr` targets it). mpp step 4 (the execution playbook owns base selection, so the plan must name the base that it uses). review I1 (controller ruling). | D | Loop 2. T frontmatter and header. Handoff template. Red flags. | GREEN fix round 1: see Pressure scenarios. |
| Touched tests per phase. Full suite once, in the last phase. | spec 8.4. | D | Rules. T header. T Touched tests. | RED: no tests per phase. |
| Interfaces block: consumes and produces, with exact names and types. | sp Task Structure (Interfaces). | O | T Interfaces. | GREEN |
| A step is one action with a checkable result. | sp Step Granularity. | D | Rules. T steps. T self-review 2. | GREEN |
| A code step gives file, signature, values. A body only for an algorithm the tests do not fix. | sp What a Step Contains. | D | Rules. T self-review 2 and 5. | GREEN |
| A test step names a test and a literal expected value. A code step (title starts with Implement) names a signature `name(params) -> type` and a file path. `plan-lint` exits 1 for each miss. | sp What a Step Contains (sp/writing-plans:140-161). audit item 9. `ai/tests/test_plan_lint.py`. | D | `ai/bin/plan-lint`. Loop 8. Rules. T Step rules. | Unit tests. GREEN round 2: see Pressure scenarios. |
| No "TBD", "handle edge cases", "add validation". | sp What a Step Contains. | D | Rules. T self-review 2. | GREEN |
| Fail-first step predicts the mismatch, not an import, collection, or missing-file error. | spec 8.4 build entry (fail-first receipt). sp step 2 (expected FAIL with a reason). | P | T Step 3. | GREEN |
| Self-review: spec coverage, step scan, name match, failure modes, proportion. Fix inline, no second review. | sp Self-Review. | P | Loop 8. T Self-review. | GREEN |
| Run the plan linter. Exit 1: fix each line it prints and run again. | mpp step 6. cp. spec 8.5 (plan linter). pl. | D | Loop 8. Red flags. | GREEN: see Pressure scenarios. |
| plan-lint exits 1 when line 1 is not `---` or the frontmatter has no `kind: plan`. Exit 0 counts only then. | pl (the parser checks only a structured file). review I2 (controller ruling). `ai/tests/test_plan_lint.py`. | D | `ai/bin/plan-lint`. Loop 8. T manifest rules. Red flags. | Unit tests. |
| Exit 2 is a setup error: stop, do not run again, report the code and message in the handoff. | pl (exit 2 on setup error). review I3 (controller ruling). | D | Loop 8. Handoff template. Red flags. | Untested. The runs had no file to lint. |
| Exit 2, no file, or linter not on disk: check the manifest rules by hand and say so. | brief (live path has no `ai/bin` before merge). | P | Loop 8. Handoff template. | GREEN |
| An empty section says why. Entry points and failure modes are always present. | fcd (empty section says why). spec 8.4. | D | Rules. T intro. | GREEN |
| No humanlayer command except `humanlayer thoughts sync`. | spec 8.4 (remove ENG-XXXX, thoughts/allison, npm). audit item 10 (one rule across skills: review-pr runs `humanlayer thoughts sync`, so make-plan allows it). | D | Rules. | Untested. Edited in round 2. No run used a humanlayer command. |
| Handoff: numbered questions, each with a recommended answer. No "approve?". | spec 8.4. brief (same ruling as brainstorm). tt step 4 (numbered breakdown, quiz). | O | Loop 9. Handoff template. Red flags. | RED: Claude ended "please review the plan there". |
| Each question in item form: link, change, evidence, risk. | spec 8.4. ketchup. | O | Handoff template. | GREEN |
| Drop a question that a run can answer. | spec 8.4. mpp step 2. | D | Definitions. Loop 9. Red flags. | GREEN |
| Reversible work proceeds without an answer. | never-block-on-the-human (reversible half). brief. | D | Loop 9. Handoff template. | GREEN |
| Hand back the plan path and the linter output. | mpp step 7. | O | Handoff template. | GREEN |
| Answers go into the plan, then `status: approved`. No open decision: approved at once. Next is `build`. | old (status values). brief (never-block). spec 8.1 (make-plan -> build). | P | Handoff template. | Untested. A headless run stops at the handoff. |
| `Principles applied:` line in the reply. | spec 8.7. | O | Handoff template. | GREEN |
| Read all four principle files in full, also when a step does not apply. One read command for each file, with its full path, and no loop or variable for the path. | spec 8.7 and section 9 (the transcript must show the principle file read). review I4. Round 2: Claude read the files in a shell loop over `$f` (green-2). | D | Loop intro. Red flags. | GREEN round 2: green-3 (Claude), green-4 (Codex). |
| Four repo lines, verbatim. | Brief Global Constraints. | D | Repo Rules. | Untested. The runs cannot write, deploy, or open a DB. |

## Cut

- sp: the announce line, the `docs/superpowers/plans/` path, and the header line that names the plugin execution skills. The spec puts plans in `thoughts/shared/plans/`, `build` runs them, and the lint forbids plugin names.
- sp: the execution-method question (subagent-driven or native). `build` owns how it runs a plan. The question would also be an "approve?" in another form.
- sp: Review Focus as its own section. Its mechanism (each failure mode gets a test in the owning phase) moved into Failure modes, so the plan has one list, not two.
- sp: full test code in each step. sp itself limits it to the test name and assertions. The template keeps that limit.
- tt: "avoid specific file paths". The Grimoire manifest needs each path, and `plan-lint` fails without them.
- tt: publish to a tracker, one file per ticket, and the triage label. The output is one plan file in `thoughts/shared/plans/`.
- tt: "iterate until the user approves the breakdown". The ruling replaces approval with numbered decisions. Reversible work proceeds.
- mpp: the program checklist, owners, and the hourly tick. Also the ten live lanes, the swarm, the perf gate, the review gate with video, and the agent store path. They belong to pstack's own run model, not to a plan that `build` runs.
- mpp: "execution starts on the operator's explicit go". never-block-on-the-human overrides it for reversible work.
- cp: its checks for pstack sections, the mid-sentence colon rule (it conflicts with `**File**:` lines), and the curly quote rule. The house lint for plans is `plan-lint`. The long dash rule stays as the house no-em-dash rule.
- fio: architect and arena runs, the hypothesis loop, and the decision trail. They belong to `build` and its `## Deviations` section (spec 8.4 build entry).
- old: everything except the manifest, the diagrams, and the phase headings. The source rule (spec 8.2a) cuts its research flow, sub-task agents, ticket file names, and `npm` commands. Audit item 10 keeps `humanlayer thoughts sync` (see Rules). It also cuts the Testing Strategy, Performance, Migration Notes, and References sections.
- old: the "Implementation Note" that pauses for manual confirmation after each phase. never-block-on-the-human overrides it.
- spec 8.4: "ste-lint flavored checks" on the plan. `ste-lint.py` has no flavored mode. The controller's own plan, which passes `plan-lint`, has 102 strict violations. Plan prose follows the AGENTS.md writing standard. `plan-lint` is the only gate. Controller ruling: the cut stands (review M7).

## Principles

Four pointers, each at the step it governs, with the key sentence inline:

- model-the-domain: Loop 3 (Model).
- foundational-thinking: Loop 4 (Order).
- build-the-lever: Loop 5 (Wide changes).
- separate-before-serializing-shared-state: Loop 6 (Failure modes).

The handoff template ends with the `Principles applied:` line.

## Pressure scenarios

Scenario: the spec 8.4 `staging` entry alone, with "Write the implementation plan for it." GREEN adds "This session cannot write files. Put the full plan in your answer."

**RED** (no skill, both CLIs, read-only, 2026-10-30):
Neither plan has a `kind: plan` manifest, `## Phase N:` headings, a Before -> After pair, an entry-points section, or a failure-modes section. Neither names a base branch or the tests for each phase. Claude writes the plan to its own plan file and ends with "please review the plan there". Codex reads the old `create_plan` skill and gives five prose steps.

**GREEN** (skill and four principles, both CLIs, read-only, 2026-10-30):
Iteration 1 failed for Claude and passed for Codex. Claude read the principles with a shell loop, and the harness counts only the file-read tool for Claude. The fix is one line at the start of the Loop: open each principle file in full with the file-read tool.
Iteration 2 passed for both. Claude cost 0.94 USD. Codex used 142,188 input tokens (121,088 cached) and 4,494 output tokens. I saved each plan from the answer to a copy that starts at `---`. Plan-lint exits 0 on each copy (3 phases each, no warnings). Each plan has entry points, failure modes with owner phases, a base branch, and touched tests for each phase. Claude asks three numbered decisions in item form and keeps `status: draft`. Codex finds no open decision and sets `status: approved`. Neither asks "approve?". Each names `build` as the next step and gives the `Principles applied:` line.

**Known gap** (review M8, iteration 2): Codex's plan passes plan-lint, but many steps decide little. Some steps have no test names and no exact values. Its `spec:` field is prose, not a path. "Decide, do not transcribe" and the step scan did not hold under Codex. This round does not change the skill for it. Closed in round 2 for test and code steps (see below). The `spec:` field is still not checked.

**GREEN fix round 1** (same scenario, both CLIs, 2026-10-30):
Run 1 failed for both. Without the file-read sentence, Claude read only two of the four principle files. Codex read all four in one `cat` with a brace list, which the harness does not parse.
Run 2 added "Read each principle file in full at the step that names it." It failed the same way. Claude skipped build-the-lever and separate-before-serializing-shared-state.
Run 3 passed for both. The Loop intro now says to read all four files, also when a step does not apply, with each full path in the read command. Claude cost 1.07 USD. Codex used 158,135 input tokens (129,536 cached) and 4,686 output tokens. The new plan-lint exits 0 on each extracted plan. Each plan has a `## Domain model` section and a failure-modes table with a write-path column.
Base branch: Codex chose `master` from `origin/HEAD`. Claude found the full spec on disk, and its section 7 names `skill-rework` as the build branch, so Claude chose `skill-rework`. Each choice follows the rule and names its source. The runs differ because only Claude read the full spec.

**Round 2** (audit items 9 and 10, final-review M3, both CLIs, 2026-10-30). Run dirs are under `.superpowers/sdd/2026-10-30-skill-rework/scratch-r2-make-plan/`.
New rule: `plan-lint` checks each checkbox step. A test step (title starts with Write or Add and names a test) needs a backticked test name and a literal expected value. A code step (title starts with Implement) needs a signature and a backticked file path. The old Codex plan from fix round 3 still exits 0, because its steps are bare checkboxes such as "Define the domain records" that neither class matches. The rule does not catch a vague step of another kind.
green-1 (`--write`, the scenario names the worktree linter, because `~/dotfiles/ai/bin/plan-lint` does not exist before the merge): Codex PASS. It wrote `plan.md` and ran the new plan-lint in the same command: exit 0, no output. Its test step names `test_same_sha_old_code` and expects `dispatch_count == 1`. Claude FAIL from the harness: `--write` runs in acceptEdits, so Claude could not read outside the scratch dir and could not run plan-lint ("This command requires approval").
green-2 (read-only scenario, Claude only): FAIL. Claude read the four principle files in one shell loop over `$f`, and the harness counts only the file-read tool. Fix: one read command for each file, no loop or variable.
green-3 (read-only, Claude, after the fix): PASS, 0.95 USD. The extracted plan exits 0 under the new plan-lint (not run in the loop, the session cannot write). Each code step has a backticked signature and path, and each test step a name and a value.
green-4 (`--write`, Codex, after the fix): PASS. 361,462 input tokens (310,656 cached), 11,335 output tokens. Codex read the plan-lint usage, wrote the plan, and ran plan-lint: exit 0, no output. Its code step is `validate_evidence(record: dict) -> list[str]` in `ai/skills/staging/scripts/check_evidence.py`. Its test steps name each test and the expected exit code.
Concern: Claude used Implement steps for Markdown edits, with forced signatures such as `Definitions(Case kind, Run key) -> 2 bullets`. The rule passes them. A prose edit is not code, and the template does not yet say which title to use for it.
