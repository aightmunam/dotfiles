# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **how:** pstack-claude `plugins/pstack/skills/how` (SKILL.md, explorer-prompt.md, explainer-prompt.md).
- **why:** pstack-claude `plugins/pstack/skills/why` (SKILL.md, investigator-prompt.md, epistemics.md, synthesizer-prompt.md).
- **tw:** pstack-claude `plugins/pstack/skills/technical-writing` (the Diataxis section).
- **pocock:** mattpocock-skills `skills/engineering/research/SKILL.md`.
- **rc:** `ai/skills/research_codebase/SKILL.md` (only the thoughts path and the frontmatter).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 research entry and section 10.
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (removed after eec5ad9; read it in git history) (the form bar).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "T" is `document-template.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Tag each claim `verified` or `inferred`. | spec 8.4. why epistemics (five tiers, cut to two). | D | Definitions. Rules, tag or cut. Red flags. T tag format. | RED: no tags in both runs. |
| Describe. Do not recommend. | spec 8.4. rc Scope. tw reference mode. | D | Definitions. Rules. Red flags, word list. | RED: Claude added "Optional fixes". |
| Record `origin_main` for each repo. | spec 8.4, spec 10 (several repos). | P | Loop 2. T frontmatter. Red flags. | RED: both cite HEAD, not origin/main. |
| Claims describe the local HEAD. Record `origin_main` always and `head` when it differs. | why step 2 (code anchor). Audit: in GREEN-3, HEAD was 749 commits ahead of `origin/main`. | P | Loop 2. T frontmatter. Red flags. | GREEN-4: both docs record `head` and `origin_main`. |
| State your reading of the question. | how step 1. why step 1. | P | Loop 1. T Question. | GREEN |
| Narrow question: read it yourself. Wide question: 2 to 4 angles in one message. | how steps 1 and 2. | P | Loop 3. | GREEN: both runs took the narrow path. |
| Explorers return a fixed set of sections. | how explorer-prompt. spec 8.4. `ai/agents/explorer.md`. | P | Loop 3. T explorer sections. | Untested. No run took the wide path. |
| No `explorer` type: a general-purpose agent gets the sections. No dispatch tool: do it yourself. | fcd Loop. Audit: the pressure scratch and Codex have no `explorer`. | P | Loop 3. T explorer sections. | Untested. No run dispatched an agent. |
| Open each file that you cite. | how explainer (check the code yourself). why synthesizer step 6. | D | Loop 4. Red flags. | GREEN |
| Cite path, line, and symbol. | spec 8.4. `ai/agents/explorer.md`. | P | Rules. T tag format. | GREEN |
| History from git log, blame, and PRs. Record each search, also empty ones. | why step 2. why investigator loop 5. spec 8.4. | P | Loop 5. T History. Rules. | GREEN: both runs cite commit 68cefe6. |
| Code shows what runs, not why. | why investigator-prompt (mechanics are not motivation). | D | Rules. Red flags. | GREEN |
| The user's guess is a candidate. | why epistemics (the sycophancy trap). | D | Rules. | Untested. The scenario has no guess. |
| Constraints for the change are facts. | spec 8.4. why output (Preserve, Avoid, Risk). | O | T Constraints for the change. | RED: Codex gave one constraint, untagged. |
| Doc at `thoughts/shared/research/YYYY-MM-DD-<topic>.md` with frontmatter. | rc steps 5 and 6. spec 8.4. | P | Loop 6. T frontmatter. | GREEN |
| In a worktree, use the main checkout's `thoughts/`. | spec 8.4 (path works from a worktree). Audit: `thoughts/` is not tracked in git. | P | Loop 6. | Untested. No run was in a worktree. |
| Cannot write: the full doc goes in the answer with its path. | pocock step 3 (say where). | P | Loop 6. | GREEN: both runs gave the doc and its path. |
| Inline by default. Fresh agent: path and at most 5 bullets. | spec 8.4. spec 10. pocock (fresh context). | O | Loop 8. T reply shapes. | GREEN: inline only. Fresh-agent mode untested. |
| `Principles applied:` line in the reply. | spec 8.7. | O | Loop 8. T reply shapes. | GREEN-1 failed. GREEN-2 and GREEN-3 passed. |
| Four repo lines, verbatim. | Brief Global Constraints. | D | Repo Rules. | Untested. The runs cannot write, deploy, or open a DB. |

## Cut

- rc: the greeting, humanlayer sync and status, permalinks, `ENG-XXXX` names, the follow-up protocol, `thoughts/searchable` rules, and the fields `researcher`, `git_commit`, `branch`, `tags`, `last_updated`. The spec keeps only the path and the frontmatter.
- how: the separate explainer agent, models, effort, and platform lines. The spec runs research inline.
- why: the seven MCP categories, the source playbooks, and the five tiers. The spec keeps two tags.
- pocock: the background agent on every run. It is the fresh-agent mode here.

## Pressure scenarios

Scenario: in `~/Developer/work-dashboard`, how does a review run get its skill list, and what breaks if someone renames the skill? Write it up. (The run used the brief wording.)

**RED** (no skill, both CLIs, read-only):
Both runs answer in chat with no `verified` or `inferred` tags. Both record HEAD `d09880a` as the anchor, not `origin/main` (`e25ee05`). Claude adds a section "Optional fixes" with three proposals. Neither writes frontmatter or a `thoughts/shared/research/` path.

**GREEN** (skill, both CLIs, read-only, 2026-10-30):
Iteration 1 failed for both. The documents passed, but the replies had no `Principles applied:` line. The fix puts that last line in Loop 8.
Iteration 2 passed for both. Each document has the frontmatter with `origin_main: e25ee05...`. It notes that the run did not update the remote ref. It tags each claim (Claude 38 `verified` and 1 `inferred`, Codex 28 `verified`). Neither has a fix or a "should". Each gives the intended thoughts path, because the run cannot write files.
Iteration 3 ran after the repo lines and the SHA-only anchor went in. It passed for both. Each `origin_main` value is the bare SHA `e25ee05...`. Each anchor note is in the Question section. Claude has 47 `verified` and 3 `inferred` tags. Codex has 27 `verified` tags. Neither document has a fix or a "should".
Iteration 4 ran after the `head` rule went in. It passed for both. Each document records `origin_main` (`e25ee05...`) and `head` (`d09880a...`), and says the claims describe `head`. Neither run could update the remote ref, because the harness allows no writes. Each anchor note says so.
