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
| Model the domain in a data structure. Name each type, table, and state machine with its file and signature. | spec 8.7 (model-the-domain, design step). sp File Structure. | P | Loop 3. Pointer. | GREEN |
| Data structures before logic. Phase 1 is scaffold and check harness. | spec 8.7 (foundational-thinking, scaffold first). fio Phase B. | P | Loop 4. Pointer. T Phase 1. | GREEN |
| Baseline from the code before the change, so a check reads old value vs new value. | fio Phase B. spec 8.4. | D | Definitions. Loop 4. T Step 1. Red flags. | GREEN |
| Riskiest unknown first. | fio Phase B. spec 8.4. | D | Loop 4. Red flags. | GREEN |
| A phase is a vertical slice, fits one fresh context window, lands green, names its blocking edges. | tt step 3 (vertical slices, one context window, blocking edges). spec 8.4. | P | Definitions. T Blocked by. | GREEN |
| A wide change is expand, migrate in batches, contract. | tt step 3 (wide refactors). spec 8.4. | P | Loop 5. | Untested. The scenario has no wide change. |
| A wide change uses a script or codemod, not hand edits. The script is a file in the plan. | spec 8.7 (build-the-lever). | D | Loop 5. Pointer. Red flags. | Untested. |
| Failure modes: transaction scope, side effects before commit, retries, idempotency. | spec 8.4 (required section). | O | Loop 6. T Failure modes. | RED: neither plan had it. |
| Shared state: Postgres row contention and parallel workers. Remove the sharing first. | spec 8.7 (separate-before-serializing-shared-state, foundational-thinking concurrency question). | D | Loop 6. Pointer. T Failure modes. Red flags. | GREEN |
| Parallel phases own disjoint file sets that the plan lists. | spec 8.4 and 8.7. fio Phase B (parallelize only across seams). | D | Loop 6. T Owns. Red flags. | Untested. The GREEN plans are linear. |
| Each failure mode names its owner phase and the test that pins it. | sp Review Focus (each line gets its test in the owning task). | O | Loop 6. T Failure modes. T self-review 4. | GREEN |
| Plan path `thoughts/shared/plans/YYYY-MM-DD-<topic>.md` of the repo where the change lands, `status: draft`. | spec 8.4 Output. old (status values). | P | Loop 7. T frontmatter. | Untested. The runs cannot write. |
| In a worktree, use the main checkout. Cannot write: the full plan in the answer, from its first `---` line. | rs Loop 6. pl (text before `---` turns off the manifest check). | P | Loop 7. T manifest rules. | GREEN |
| Manifest `kind: plan` with phases and files. `## Phase N:` headings. `**File**:` lines match the manifest. | old (manifest, phase headings, manifest rules). pl. | O | Definitions. T frontmatter. T manifest rules. | RED: neither plan had a manifest. |
| `## Before -> After` with two mermaid diagrams. | old (diagram rules). pl. | O | T Before -> After. T manifest rules. | RED: neither plan had it. |
| Header: goal, spec, base branch, required skills, test card, full suite. | spec 8.4 (header). sp Plan Document Header (goal, spec). | O | T header. | RED: no base branch in either plan. |
| Touched tests per phase. Full suite once, in the last phase. | spec 8.4. | D | Rules. T header. T Touched tests. | RED: no tests per phase. |
| Interfaces block: consumes and produces, with exact names and types. | sp Task Structure (Interfaces). | O | T Interfaces. | GREEN |
| A step is one action with a checkable result. | sp Step Granularity. | D | Rules. T steps. T self-review 2. | GREEN |
| A code step gives file, signature, values. A body only for an algorithm the tests do not fix. | sp What a Step Contains. | D | Rules. T self-review 2 and 5. | GREEN |
| No "TBD", "handle edge cases", "add validation". | sp What a Step Contains. | D | Rules. T self-review 2. | GREEN |
| Fail-first step predicts the mismatch, not an import error. | spec 8.4 build entry (fail-first receipt). sp step 2 (expected FAIL with a reason). | P | T Step 3. | GREEN |
| Self-review: spec coverage, step scan, name match, failure modes, proportion. Fix inline, no second review. | sp Self-Review. | P | Loop 8. T Self-review. | GREEN |
| Run the plan linter. Fix each line it prints. Run again until exit 0. | mpp step 6. cp. spec 8.5 (plan linter). pl. | D | Loop 8. Red flags. | GREEN: see Pressure scenarios. |
| Linter not on disk: check the manifest rules by hand and say so. | brief (live path has no `ai/bin` before merge). | P | Loop 8. Handoff template. | GREEN |
| An empty section says why. Entry points and failure modes are always present. | fcd (empty section says why). spec 8.4. | D | Rules. T intro. | GREEN |
| No humanlayer residue. | spec 8.4 (remove ENG-XXXX, thoughts/allison, npm, humanlayer sync). | D | Rules. | RED: Codex read the old `create_plan` skill. |
| Handoff: numbered questions, each with a recommended answer. No "approve?". | spec 8.4. brief (same ruling as brainstorm). tt step 4 (numbered breakdown, quiz). | O | Loop 9. Handoff template. Red flags. | RED: Claude ended "please review the plan there". |
| Each question in item form: link, change, evidence, risk. | spec 8.4. ketchup. | O | Handoff template. | GREEN |
| Drop a question that a run can answer. | spec 8.4. mpp step 2. | D | Definitions. Loop 9. Red flags. | GREEN |
| Reversible work proceeds without an answer. | never-block-on-the-human (reversible half). brief. | D | Loop 9. Handoff template. | GREEN |
| Hand back the plan path and the linter output. | mpp step 7. | O | Handoff template. | GREEN |
| Answers go into the plan, then `status: approved`. No open decision: approved at once. Next is `build`. | old (status values). brief (never-block). spec 8.1 (make-plan -> build). | P | Handoff template. | Untested. A headless run stops at the handoff. |
| `Principles applied:` line in the reply. | spec 8.7. | O | Handoff template. | GREEN |
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
- old: everything except the manifest, the diagrams, and the phase headings. The source rule (spec 8.2a) cuts its research flow, sub-task agents, `humanlayer thoughts sync`, ticket file names, and `npm` commands. It also cuts the Testing Strategy, Performance, Migration Notes, and References sections.
- old: the "Implementation Note" that pauses for manual confirmation after each phase. never-block-on-the-human overrides it.
- spec 8.4: "ste-lint flavored checks" on the plan. `ste-lint.py` has no flavored mode. The controller's own plan, which passes `plan-lint`, has 102 strict violations. Plan prose follows the AGENTS.md writing standard. `plan-lint` is the only gate.

## Principles

Four pointers, each at the step it governs, with the key sentence inline:

- model-the-domain: Loop 3 (Model).
- foundational-thinking: Loop 4 (Order).
- build-the-lever: Loop 5 (Split).
- separate-before-serializing-shared-state: Loop 6 (Failure modes).

The handoff template ends with the `Principles applied:` line.

## Pressure scenarios

Scenario: the spec 8.4 `staging` entry alone, with "Write the implementation plan for it." GREEN adds "This session cannot write files. Put the full plan in your answer."

**RED** (no skill, both CLIs, read-only, 2026-10-30):
Neither plan has a `kind: plan` manifest, `## Phase N:` headings, a Before -> After pair, an entry-points section, or a failure-modes section. Neither names a base branch or the tests for each phase. Claude writes the plan to its own plan file and ends with "please review the plan there". Codex reads the old `create_plan` skill and gives five prose steps.

**GREEN** (skill and four principles, both CLIs, read-only, 2026-10-30):
Iteration 1 failed for Claude and passed for Codex. Claude read the principles with a shell loop, and the harness counts only the file-read tool for Claude. The fix is one line at the start of the Loop: open each principle file in full with the file-read tool.
Iteration 2 passed for both. Claude cost 0.94 USD. Codex used 142,188 input tokens (121,088 cached) and 4,494 output tokens. Each plan starts at `---`, and plan-lint exits 0 on a saved copy (3 phases each, no warnings). Each plan has entry points, failure modes with owner phases, a base branch, and touched tests for each phase. Claude asks three numbered decisions in item form and keeps `status: draft`. Codex finds no open decision and sets `status: approved`. Neither asks "approve?". Each names `build` as the next step and gives the `Principles applied:` line.
