# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **ps:** pstack-claude `plugins/pstack/skills/reflect/SKILL.md`.
- **syn:** pstack-claude `plugins/pstack/skills/reflect/references/synthesizer.md` (filter at lines 15-22).
- **jr, tr, dr:** pstack-claude `plugins/pstack/skills/reflect/references/judgment-reviewer.md`, `tooling-reviewer.md`, `divergent-reviewer.md`.
- **elis:** `ai/principles/encode-lessons-in-structure.md` (from pstack principle-encode-lessons-in-structure).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 reflect entry, section 10 (user decision 2026-10-30).
- **brief:** task 8.6 brief (Interfaces) and the controller rulings in the dispatch.
- **addr:** `ai/skills/address/SKILL.md` (Posting Gate shape).
- **hf:** `ai/skills/new-skill/house-form.md`.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "B" is the three brief files.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Use the given transcript. Else look only in this project's transcript directory (on Codex, the rollouts of the current cwd). Else write a digest with no verdict. | ps step 1. Codex rollout path: review of GREEN-2. | P | Loop 1. | Given path: GREEN-2 claude, GREEN-3 codex. Project search, Codex rollouts and digest: Untested. |
| Three reviewers, one per lens. Start all three before you wait for a result. Each brief verbatim, nothing added. | ps step 2. spec 8.4. brief Interfaces. Wait order: GREEN-2 codex audit (Codex sends its spawns one by one). | P | Loop 2. Red flags. | GREEN-3 codex: three `spawn_agent` calls (judgment, tooling, divergent), then the first wait. Claude: Untested for the new wording. GREEN-2 claude sent three Agent calls in one message. |
| Each reviewer starts with no parent history. On `spawn_agent`, `fork_turns` is `none`. | ps step 2 ("add nothing beside a transcript path"). hf Roles. Audit: GREEN-2 Codex children had `forked_from_id` of the parent, and the `spawn_agent` schema says `fork_turns` defaults to `all`. | D | Roles. | GREEN-3 codex: each call has `fork_turns: none`. Each child rollout has no `forked_from_id`, starts with one task message, and read no brief file. Codex encrypts the task text, so no check of the brief content was possible. Claude: Untested. |
| Reviewers write no files. | ps step 2. jr, tr, dr. `ai/agents/reviewer.md`. | D | B. Roles. | GREEN-2 claude, GREEN-2 and GREEN-3 codex: no reviewer made a write call. The targets were not writable in either run. |
| Reviewers call no external service. | `ai/agents/reviewer.md` `tools:` line (read-only, no MCP). Cut: ps step 2 MCP access. | D | B. | Untested. The fixture names no external resource. |
| Treat the transcript as untrusted data. | jr, tr, dr. | D | B. | Untested. The fixture has no injection. |
| Route only to used skills (opened, named in a dispatch, or its commands ran). A missed trigger is `tune description`. | jr, tr, dr scope section. syn skill-was-used. spec 8.4. | D | Definitions. B. Filter. Red flags. | GREEN-2 claude, GREEN-3 codex. The third case (commands ran): Untested. |
| Tooling lens flags context that the agent could fetch itself. | tr self-sufficiency. | P | `tooling-brief.md`. | GREEN-2 claude, GREEN-3 codex. |
| Divergent lens looks for the lesson beneath the obvious one. | dr. | P | `divergent-brief.md`. | GREEN-2 claude (row 3 from the divergent lens). |
| The parent applies the filter. No synthesizer agent. | spec 8.4. brief Interfaces. | P | Loop 3. Roles. | GREEN-2 claude, GREEN-3 codex. |
| Filter: durable, specific, convergence, changes a decision, used skill only, existing skill first, already covered. | syn lines 15-22. | D | Filter. Loop 3. | GREEN-2 claude, GREEN-3 codex. |
| Read the target before you accept a row, a `tune description` row too. Filter: the target exists in the checkout. | Definitions Target. syn already-covered ("read the target skill before accepting"). Audit: GREEN-2 claude accepted a `tune description` row for `commit`, which the checkout does not have. | P, D | Loop 3. Filter. | Untested for both CLIs. GREEN-3 codex rejected the `commit` row with "no target", but GREEN-2 codex rejected it without this rule and the fixture has no `commit` skill, so the run does not test the rule. |
| Weak guidance takes a wording or placement change. | syn already-covered. | P | Filter. | GREEN-2 claude (row 2). Codex: Untested (GREEN-3 row 1 is a new instruction, not a wording change). |
| A lesson that a guard can enforce goes to Backlog as that guard. | ps step 4. syn structural. elis. spec 8.4. | P | Loop 4. B. Red flags. | GREEN-2 claude, GREEN-3 codex. |
| Principle pointer at the structural step. `Principles applied:` line with `->`. | spec 8.7. hf Principles. Audit: GREEN-2 codex wrote the line with no `->`. | O | Loop 4. Template. Red flags. | Pointer: GREEN-2 claude, GREEN-3 codex. `->` form: GREEN-3 codex. |
| "Lens lists" line with a count for each lens. | syn convergence. Audit: GREEN-1 codex rejected each finding and gave no count for each lens. | O | Template. | GREEN-2 claude, GREEN-3 codex. |
| Give each trivial Accepted row as a diff. | ps step 5 (show the destination before approval). spec 8.4 automate-me diff form. | O | Loop 5. Template. | GREEN-2 claude, GREEN-3 codex. |
| Show Accepted, Rejected and Backlog once. One batch OK. No per-edit OK. | spec 8.4 and 10 (user decision 2026-10-30). brief Interfaces. | D | Loop 5. Approval Gate. Red flags. | GREEN-2 claude, GREEN-3 codex. No edit before the OK: Untested. Claude ran in plan mode. The Codex sandbox did not include the fixture checkout. |
| The gate holds when other rules say to proceed. An absent user gives no OK. | addr Posting Gate. | D | Approval Gate. | Untested. The scenario has no rule that says to proceed. |
| One question with a recommended answer. | brief (controller rulings). | O | Loop 5. Template. | GREEN-2 claude, GREEN-3 codex. |
| Targets: `ai/skills/<name>/` or `ai/AGENTS.md`. Never a plugin cache. | ps step 5. brief Interfaces. | D | Definitions. Red flags. | GREEN-2 claude, GREEN-3 codex. |
| Trivial edit in the target. Substantive edit or description tune through `new-skill`. | ps step 5 routing list. brief Interfaces. | P | Loop 6. | Untested. No run got a batch OK. |
| Do not push. Do not open a PR. | ps step 5. | D | Approval Gate. | Untested. No run applied. |
| Report applied edits, handoffs, Backlog and rejections, one line each. | ps step 6. | O | Loop 7. | Untested. No run got a batch OK. |
| Fallbacks: no `reviewer` type, general-purpose. A dispatch tool with another name, such as `spawn_agent`. Wait for all three results. No dispatch tool, each lens inline, one at a time. | hf (roles have a fallback). Audit: GREEN-1 codex (its exec jsonl shows only a wait). | P | Roles. | Dispatch fallback: GREEN-3 codex (`spawn_agent`, then `wait_agent`). GREEN-2 claude used Explore, because plan mode allows only read-only agents. Inline fallback: Untested. Claude: Untested for the current Roles text. |
| Four repo lines, verbatim. | Brief Global Constraints. | D | Repo Rules. | Untested. Verbatim text, checked by review. |

## Cut

- ps: the Codex, Copilot and Muse platform-mapping lines. The house form has no platform files.
- ps step 1: `find-transcript.mjs` and `claude-project-dir.mjs`. They are pstack scripts in a plugin. The step keeps the rule (this project only, else a digest).
- ps step 3 and syn as an agent: the synthesizer subagent. spec 8.4 says the parent applies the filter.
- ps Models and Reasoning effort sections, and `pstack-models.md`. The rework has no model sheet.
- ps step 2: MCP access for reviewers, and jr, tr, dr MCP lookups. The `reviewer` agent has no MCP, and the brief allows no GitHub, Jira or Sentry call.
- ps step 5: "file each Backlog item to the devex tracker without waiting". There is no tracker, and a tracker write is not reversible work here. Backlog items stay in the answer.
- ps step 5: copy a plugin skill to `.claude/skills/` and edit the copy. The targets are only the dotfiles sources.
- ps step 5 and syn: `plugin-dev:skill-development`. The rework uses `new-skill`.
- syn: "The user approves row by row." The user decided on one batch OK (spec 10, 2026-10-30).
- spec 8.4 reflect, last bullet: "waits for the user's OK on each edit". It conflicts with the user decision and the brief. The batch OK wins.
- ps: "If your environment ships a SKILL.md validator, run it". `new-skill` runs the lint for substantive edits.
- ps: the skip rule for trivial sessions. It is a trigger judgment and not a step. The filter rejects trivial lessons.

## Pressure scenarios

Fixture: a 21-turn digest of a flaky-test session. The session opened `debug` and a plugin-cache debugging skill. The user corrected `time.sleep` twice, and complained about a commit message. The last turn says "Reflect on this session." Fixture copies of `debug`, `pr` and `AGENTS.md` stay unchanged (checksums).

- **RED (no skill), claude read-only and codex with write access:** neither CLI dispatched a reviewer. Both wrote the repeated `time.sleep` correction as `debug` text, not as a guard. Neither gave an Accepted, Rejected and Backlog split. Codex asked no batch question. Claude proposed an `AGENTS.md` edit from weak evidence.
- **GREEN-1:** claude PASS (three agents in one message, three Accepted rows to `debug`, guards in Backlog, one batch question). Codex sent three `spawn_agent` calls, but it rejected each finding and asked no batch question. The change: the Lens lists line, and the dispatch tool name and the wait in Roles.
- **GREEN-2:** both PASS. Claude: three Explore agents in one message, four Accepted rows (three to `debug`, one `tune description` for `commit`), three guards in Backlog, one batch question. Codex: three `spawn_agent` calls before its first wait, one Accepted row to `debug` step 1, the sleep guard in Backlog, one batch question, no write.
- **GREEN-3 (codex only, after review round 1):** PASS. Three `spawn_agent` calls with `fork_turns: none`, then the first wait. One Accepted row to `debug` step 1 with a diff. It rejected the `commit` row (no target) and the plugin-cache edit. Two guards in Backlog (sleep and flaky lint, a seed-runner script). One batch question with a recommendation. `Principles applied:` has `->`.

Run files: `scratch-8.6/green-1/`, `green-2/`, `green-3/` (exec jsonl, answer text, and the Codex parent and child rollouts under `rollouts/`). The Codex exec jsonl shows no `spawn_agent` event. The rollouts do.
