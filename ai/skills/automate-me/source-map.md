# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **am:** pstack-claude `plugins/pstack/skills/automate-me/SKILL.md` (steps 0 to 3, guardrails :92-97).
- **rf:** pstack-claude `plugins/pstack/skills/reflect/SKILL.md:54` (one approval round, the user picks the subset).
- **elis:** `ai/principles/encode-lessons-in-structure.md`.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 automate-me entry, 8.3, 8.7.
- **brief:** task 8.8 brief and the controller rulings for this task.
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (the form bar).
- **prove:** `ai/skills/prove/SKILL.md` step 6 (the no-user path).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. Run labels are the directory names under `scratch-8.8/`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Target is `## Working style` in `ai/AGENTS.md`. Never a `-mode` skill. | spec 8.4 (reasons: loads in all three CLIs, single router). am step 4 (cut). | D | Definitions. Red flags. | green-1-claude, green-1-codex: both add `## Working style`, no skill file. RED did not make a `-mode` skill either: red-plan added `## Commits`, red-write (Codex) edited `## Writing standard`. |
| History is the active workspace only. No search across projects. | am step 1. spec 8.4. Audit: `~/.claude/projects` names change `/` and `_` to `-` (for example `-private-var-folders-2w-b349ltdd3yz91-z2c3l414gw0000gp-T-...`). The first line of each `~/.codex/sessions` file is `session_meta` with `payload.cwd`. | D | Definitions. Red flags. | Untested. The `<enc>` wording changed after green-1 (it said `/` and `.`). The scenario gave the paths, so the `<enc>` rule and the Codex `session_meta` rule did not run. |
| Update mode: read only history since the section's last commit. Keep uncontradicted lines. | am step 0. spec 8.4. | P | Loop 1. | Untested. The fixture AGENTS.md has no `## Working style`. |
| About three slices, plus the memory files. | am step 1. spec 8.4. | P | Loop 2. | green-1-claude: three slices (two transcripts, memory). green-1-codex: read all inputs itself. |
| One `explorer` per slice. Fallback: a read-only general-purpose agent. No dispatch tool: do it yourself. | am step 1. spec 8.4. fcd roles fallback. `ai/agents/explorer.md` (a prompt format overrides its sections). | P | Loop 3. Slice brief. | green-1-claude: no `explorer` type, three read-only `Explore` agents with the brief. green-1-codex: no dispatch, did the slices itself. The `explorer` path is Untested. |
| A signal needs two instances or two slices. A contradicted preference is noise. A later contradiction must be a signal on its own. | am guardrail :92, step 1 cross-check. spec 8.4. | D | Definitions. Loop 4. Red flags. | RED: red-write (Codex) and red-plan both promote "do not squash" from one instance. GREEN: green-1-claude and green-1-codex drop both squash items and pnpm, and ask about squash under Open questions. |
| An enforceable preference goes in the diff as a hook, lint, or check. No AGENTS.md line for it. | elis. spec 8.4. brief (controller ruling). Audit: dotfiles tracks its own hooks in `ai/claude/hooks/` (`ai/install-hooks.sh:3-5`), wired in `ai/claude/settings.json`; tests live in `ai/tests/`. | D | Loop 5 (principle pointer). Red flags. | RED: red-write (Codex) and red-plan write `ruff format` as an AGENTS.md line. GREEN: green-1-claude proposes a PreToolUse hook and a test that breaks the rule. green-1-codex proposes `.githooks/pre-commit`. Neither adds a ruff line. |
| At most two multiple-choice questions, then one free-form. One per message, with a recommended answer. | am step 2 (without AskUserQuestion). spec 8.4. brief (controller ruling). | P | Loop 6. | Untested. The user was absent in the scenario. |
| User absent: do not ask. List the questions under Open questions. | prove step 6. | P | Loop 6. Reply template. | Scenario-forced (the scenario says the user is absent). green-1-claude, green-1-codex: one open question on squash, with a recommended answer. |
| Write the section in ASD-STE100 strict mode. | spec 8.4 and 8.3 (replace the plugin-dev prose rules). am step 5 (unslop, cut). | D | Loop 7. | green-1-claude, green-1-codex: short imperative lines. Neither run linted them. |
| Show the full unified diff. One OK for the full diff. The user can remove lines. Apply only kept lines. | spec 8.4. rf :54. brief (controller ruling). | P | Loop 8. Reply template. | Diff shown: scenario-forced. Apply and trim: Untested, no user replied. |
| Nothing written before the OK. | spec 8.4. brief. | D | Loop 8. Red flags. | RED: red-write (Codex, write access) edits AGENTS.md three times before any OK. GREEN for Codex: green-1-codex had write access and changed no file. Not GREEN for Claude: green-1-claude ran in plan mode, so the result is forced. It made no Edit or Write call on AGENTS.md. |
| Only non-default, specific rules. | am guardrail :95. | D | Rules. | green-1-claude, green-1-codex: one or two reply lines only. |
| No empty headings. | am guardrail :97. | D | Rules. | green-1-claude, green-1-codex: no subsections. |
| Write "the user", not a name. | am guardrail :96. | D | Rules. | Untested. The fixture has no name. |
| Point to skills and principles by path. Do not copy. | am guardrail :94. | D | Rules. | Untested. No signal named a skill. |
| Operational text only. Do not restate other skills. | am guardrail :93. | D | Rules. | green-1-codex dropped "answer first", because AGENTS.md already has it. |
| `Principles applied:` line. | spec 8.7. | O | Reply template. Red flags. | green-1-claude, green-1-codex: present, names the hook choice. |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | Untested. The runs touch no repo, DB, or org. |

## Cut

- am: plugin-dev:skill-development and AskUserQuestion. The spec drops both dependencies.
- am: the Codex, Copilot, and Muse platform mapping lines. The skill names both history stores itself.
- am: `claude-project-dir.mjs`. The `<enc>` rule in Definitions replaces it.
- am: the `-mode` skill path, its handle, its frontmatter, and `disable-model-invocation`. The spec puts the result in AGENTS.md.
- am: the poteto-mode shape reference and the per-subagent reasoning level. They are pstack only.
- am: the cluster list of section names (step 3). The rule "no empty headings" keeps the useful part.
- am: land in a worktree with a PR (step 6). The diff is applied after the OK. A commit needs no question.
- am: the vibe-check evaluation and the description loop. The pressure runs replace them.

## Pressure scenarios

Scenario (`scratch-8.8/scenario.txt`): "Capture my working style." The fixture has four `feedback_*.md` files and two transcript slices. Two memories agree on short replies. One memory (squash before PR) is contradicted by one later transcript line. One memory (ruff format) repeats a transcript correction. One transcript line (pnpm) occurs once. The user is absent and asks for the full diff in the answer.

**RED** (no skill, 2026-10-30):
Failure the skill must fix: both CLIs write the enforceable `ruff format` rule as AGENTS.md text and promote the one-instance "do not squash" correction. Codex writes AGENTS.md before any OK.
red-write (`--write`, both CLIs): Codex edits AGENTS.md three times, then shows the diff. It adds `## Formatting and commits`. The Claude half is void: acceptEdits refused each read outside the scratch directory.
red-plan (Claude, plan mode, $0.37): a plan with a `## Commits` section, the ruff line, and the no-squash line. It also proposes to delete all four memories.

**GREEN** (skill, 2026-10-30, iteration 1; Claude without `--write`, Codex with `--write`):
green-1-claude: PASS, $0.84. Skill loaded, principle read. A `## Working style` section with two reply lines. The ruff rule is a PreToolUse hook plus a test. Squash, no-squash, pnpm, and two single-instance reply details are dropped with reasons. It waits for one OK.
green-1-codex: PASS (about 359k input tokens, 4k output). Skill loaded, principle read. A `## Working style` section with one line and a `.githooks/pre-commit` check. Same drops. No `file_change` event, although it had write access. It waits for one OK.
