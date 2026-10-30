# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **ws:** superpowers `skills/writing-skills/SKILL.md`.
- **tsw:** superpowers `skills/writing-skills/testing-skills-with-subagents.md`.
- **abp:** superpowers `skills/writing-skills/anthropic-best-practices.md` (descriptions, progressive disclosure, checklist).
- **wfa:** mattpocock-skills `skills/productivity/writing-for-agents/SKILL.md`.
- **mech:** mattpocock-skills `skills/productivity/writing-for-agents/SKILL-MECHANICS.md`.
- **syn:** pstack-claude `plugins/pstack/skills/reflect/references/synthesizer.md` (the filter criteria) and `reflect/SKILL.md` step 4.
- **elis:** pstack-claude `plugins/pstack/skills/principle-encode-lessons-in-structure/SKILL.md`, adapted in `ai/principles/encode-lessons-in-structure.md`.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, sections 8.2 (naming), 8.2a (source rule), 8.3a (house form), 8.3 (STE), 8.4 new-skill entry, 8.5 (router, routing eval, pressure harness, plugin lint), 8.7 (principles).
- **brief:** Task 6.5 brief and its Global Constraints (repo lines, description shape, skill task template).
- **fcd:** `ai/skills/fact-constrained-debugging/` (the form bar).
- **mp:** `ai/skills/make-plan/SKILL.md` (fallback when a tool is not on disk, repo lines).
- **lint:** `ai/tests/test_skills_lint.py` (what the lint checks).
- **pr:** `ai/bin/pressure-run` (what GREEN checks).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "HF" is `house-form.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Guard first. If a lint, test, or script can enforce a rule, use only the guard. | elis (corollary). spec 8.4 new-skill entry. ws When to Create (mechanical constraints: automate it). | D | Definitions. Loop 1. Pointer. Red flags. | RED: both runs wrote the reminder as prose. |
| No part needs judgment: write no skill. | elis. ws Don't create for. | P | Loop 1. Output Guard line. | GREEN |
| Name: full words, kebab-case, no prefix. Check built-ins, bundled, installed, and plugin skills. Longer name on a collision. | spec 8.2. brief (naming collision check). review 6.5 M3 (headless built-in check). | P | Loop 2. HF Name check. Output Name check. | RED: neither run checked the name. GREEN 4: both drafts wrote `Built-in check: unverified` (headless). |
| A rule for one repo goes in that repo's AGENTS.md or a guard. | ws Don't create for (project-specific conventions). | P | HF Name check. | Untested. No run hit this branch. |
| An existing skill covers the case: change that skill. | syn (existing-skill-first, already-covered). | P | Loop 2. | Untested. |
| Read the primary sources in full and start from their mechanisms. | spec 8.2a. | P | Loop 3. HF Source rule. | Partial. Only Codex GREEN 3 read a source in full. |
| Each rule traces to a source row. A rule with none is cut. Cut rules are listed with a reason. | spec 8.2a. brief. fcd tenet-map. | D | Definitions. Loop 3. Loop 5. Red flags. HF Source rule. | RED: neither run had a source map. |
| The filter: durable, changes a decision, no guard can enforce it, not already said. | syn (durability, decision-changing, structural-mechanism, already-covered). spec 8.4. wfa Pruning (no-ops). | D | Rules. Loop 3. | GREEN |
| RED before skill text. Remove text written before RED. For an edit, revert only your change. | ws Iron Law. tsw RED phase. review 6.5 I3. | D | Definitions. Loop 4. Red flags. HF Tests. | RED: neither run wrote a scenario or ran a baseline. |
| An edit gets RED with the old skill. | ws Iron Law (applies to edits). | P | Definitions. | Untested. The scenario is a new skill. |
| A pressure scenario is a real task with real paths that asks the agent to act. | tsw Key Elements of Good Scenarios. | P | Definitions. | GREEN |
| One failure line from the saved answers. | tsw Verify RED (capture exact failures). spec 9. | O | Loop 4. Output RED line. | Untested. All runs: failure pending. |
| GREEN under both CLIs with each principle. Rerun until both pass. Judge from the saved answers. | spec 8.5 (pressure harness). tsw GREEN and REFACTOR. pr. brief. | D | Definitions. Loop 7. Red flags. HF Tests. | Untested. All runs: GREEN not run. |
| Record RED and GREEN in `## Pressure scenarios`. | spec 8.3a (source map holds RED and GREEN). brief step 5. | O | Loop 8. HF Tests. | Partial. The section exists, with only commands. |
| Description: triggers only, starts with `Use when`, one line, no `"`. | ws SDO 1 (description is when, not what). spec 8.2. brief. lint. | D | Rules. Red flags. HF SKILL.md. | RED: both descriptions summarize the procedure. Codex has no `Use when`. |
| Description matches the routing row. | spec 8.5 (single router). brief. | P | HF SKILL.md. HF Routing. | GREEN |
| SKILL.md about 50 lines, at most 80. Detail in reference files read at a named step. | spec 8.3a. lint (80 lines). wfa Information hierarchy. | D | HF SKILL.md. | GREEN |
| Disclose by branch. | wfa Progressive disclosure (inline what every branch needs). abp Progressive disclosure. | D | Rules. HF SKILL.md. | GREEN |
| Definitions first. Numbered loop. Red flags send back to a step. Output template. Roles with a fallback. | spec 8.3a. fcd. | O | HF SKILL.md. | Partial. Neither GREEN 3 draft has Roles. |
| Each step ends on a checkable result. | wfa Steps and completion criteria. | D | HF SKILL.md. | Untested. |
| Match the form to the failure. | ws Match the Form to the Failure. | D | Rules. | GREEN |
| State the target. A prohibition is a guardrail next to its target. | wfa Negation. ws (positive recipe over prohibition). | D | Rules. | Untested. |
| STE strict, 0 violations. No em dash. | spec 8.3 (new-skill enforces strict mode). lint. | D | Loop 8. HF Writing. | Partial. GREEN 4: both ran ste-lint on the draft prose (0 violations). Neither ran it on a file on disk. |
| One word for one meaning. Each meaning in one place. Do not copy a fact the environment gives. | wfa Leading words, Pruning (single source of truth, environment is a source). abp (consistent terminology). | D | HF Writing. | Untested. |
| Principle pointer at the governed step: key sentence inline, then the Read line. `Principles applied:` line. | spec 8.7 layers 1, 4 and 5. lint. | O | Loop 1. Output template. HF Principles. | GREEN |
| Routing row, tie-break lines, and eval prompts for each new skill. | spec 8.5 (router, routing eval). brief. | P | Loop 6. HF Routing. Output Routing line. | RED: Codex added no row. Claude only suggested one. |
| No plugin skill name and no plugin store path. | spec 8.5 (plugin lint). lint. | D | HF SKILL.md. | Untested. |
| Run the lint and ste-lint. | brief step 6. spec 8.3. | P | Loop 8. HF Tests. | Partial. GREEN 4: ste-lint on the draft prose only. The unittest lint needs files on disk. |
| Run each command from the dotfiles root. Name a scratch `--out` dir. | review 6.5 I4 (runs in a temp dir said the tools did not exist). | P | Loop intro. Loops 4 and 7. HF intro. | Partial. GREEN 4: Claude went to the worktree root and gave `<scratch>` out dirs. |
| `pressure-run` is the fresh agent. Not at the dotfiles root: a fresh agent with the scenario only. No dispatch tool: scenario and commands in the handoff, status `untested`. | tsw (subagent with no skill). fcd (roles isolated, fallback). mp (tool not on disk, say so). | P | Roles. | Partial. Only the no-dispatch fallback ran (GREEN 4 both CLIs); the fresh-agent and not-at-root paths are Untested. |
| No test, no status. `green` only from two saved GREEN answers. | ws (deploying untested skills). tsw. | D | Rules. Red flags. Output Status. | GREEN |
| `skill-creator` for trigger evals when the user asks. | spec 8.4 new-skill entry. | P | HF Tests. | Untested. |
| `## Repo Rules` with the four lines, verbatim, in each skill. No exception. | brief Global Constraints. review 6.5 I1. | D | Repo Rules. Red flags. HF SKILL.md. | Failed in GREEN 3: Codex cut the lines. GREEN 4 after the red flag: both drafts have the four lines. |

## Cut

- ws: the TDD sub-skill as required background, the cross-reference markers, and the plugin skill names. The lint forbids plugin names. The loop holds the cycle.
- ws: the rationalization table, "violating the letter is violating the spirit", and 3+ combined pressures. The house form uses red flags that send back to a step (spec 8.3a). A discipline skill may add a pressure line to its own scenario.
- ws: word count targets (150, 200, 500 words). The house limit is lines (80), set by the lint.
- ws: the SKILL.md sections Overview, When to Use, Quick Reference, Common Mistakes, Real-World Impact. The house form replaces them (spec 8.3a).
- ws: flowcharts, graphviz conventions, `render-graphs.js`, and gerund names. The house form uses numbered loops. spec 8.2 sets the names.
- ws: micro-tests with 5+ reps per variant and a control. The gate is one `pressure-run` per CLI (spec 8.5). Too slow for each skill task.
- ws: deployment (push to a fork, contribute back). The user owns the skills (spec 8.2). Commits follow the repo rules.
- tsw: meta-testing ("how could the skill be clearer"). The GREEN loop changes the skill and reruns. No source in the house form asks for it.
- abp: "the description says what the skill does and when". ws and spec 8.3a say triggers only, from a measured failure. ws wins.
- abp: tests with Haiku, Sonnet and Opus, and three evaluations. The gate is both CLIs (spec 8.5).
- abp: utility script guidance, MCP tool names, and Windows paths. Not a failure seen here.
- persuasion-principles.md: authority and commitment wording. The house form shapes claims with red flags, not persuasion.
- wfa and mech: user-invoked skills, `disable-model-invocation`, and router skills. The AGENTS.md table is the single router (spec 8.5). Every skill keeps a description.
- syn: three reviewers, the convergence criterion, and the Accepted, Rejected and Backlog lists. They belong to `reflect`. new-skill uses only the filter.
- syn: skill-was-used. It applies to session lessons, which `reflect` routes.

## Principles

One pointer, at the step it governs, with the key sentence inline:

- encode-lessons-in-structure: Loop 1 (Guard first).

The output template ends with the `Principles applied:` line.

## Pressure scenarios

Scenario A (guard branch): "Write a skill that reminds me to update the changelog. This session cannot write files. Put each file of the skill in full in your answer."

- RED (2026-10-30, no skill, both CLIs): neither run wrote a scenario or ran a baseline. Both descriptions summarize the procedure, and the Codex one has no "Use when". Neither has a source map or a source for a rule. Both keep the reminder as prose. Neither checks the name. Claude cost $0.25. Codex used 147,567 input tokens and 1,255 output tokens.
- GREEN 1: FAIL on both. Claude wrote no skill and skipped the template, so it had no Principles line. Codex put the principle file and a missing path in one `cat`, so the read did not count. Fix: Loop 1 says to read the principle with its own command (this did not change Claude: it combined the reads in GREEN 2 and GREEN 3), Loop 2 uses `~/dotfiles/ai/AGENTS.md`, Loop 9 makes the template the full answer, and a red flag sends a missing Principles line to Loop 9.
- GREEN 2: PASS on both. Claude passed the read check only because its combined `cat` ended in `| head`, so the exit code was 0. Both put the guard first (a check script, a hook and CI), wrote no text reminder, filled the template with status `untested`, and ended with the Principles line. Claude cost $0.30. Codex used 143,661 input tokens and 2,524 output tokens.

Scenario B (judgment branch): "Write a skill that drafts the changelog entry for my change, in words that users understand, in the style of the repo's CHANGELOG.md." Same no-write line.

- GREEN 3: Codex PASS on the harness checks, but its draft has no Repo Rules and is not STE strict. Claude FAIL, only on the read check: it read the principle inside a combined `cat`, against Loop 1. Both wrote a skill with a trigger-only description, a source map with a Cut list, a scenario, routing lines, eval prompts and status `untested`. Claude cost $0.45. Codex used 197,812 input tokens and 3,153 output tokens. Not rerun: the brief allows three GREEN iterations.

Fix round 1 (review 6.5): Repo Rules have no exception and a red flag. The house-form read moved to Loop 2. Loop 1 reads the principle "as a read of that file alone". Commands run from the dotfiles root with a scratch `--out`. The built-in check has a headless path.

- GREEN 4 (scenario B): PASS on both. Claude read the principle as a read of that file alone. Both drafts have `## Repo Rules`, a trigger-only description, a source map with a Cut list, `Built-in check: unverified`, and status `untested`. Neither draft has a Roles section (neither skill has a subagent). Codex used a fresh agent for its RED and GREEN, not pressure-run, and labeled them as such. Claude cost $0.76. Codex used 636,295 input tokens and 5,972 output tokens.
