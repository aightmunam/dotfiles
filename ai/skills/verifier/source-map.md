# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **cvs:** pstack-claude `plugins/pstack/skills/create-verification-skill` (SKILL.md and `references/feature-map-example/`).
- **mvs:** pstack-claude `plugins/pstack/skills/maintain-verification-skill/SKILL.md`.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 verifier entry.
- **brief:** Task 5.2 brief and the dispatch for it (Global Constraints, the interface, the `prove` note).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (the form bar).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "T" is `verify-template.md`. "M" is `maintain.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| The output is `<repo>/.claude/skills/verify/SKILL.md` with `name: verify`. Monorepo: the touched package. | cvs intro and step 2. brief interface. | P | Definitions. T frontmatter. | GREEN |
| Write for an agent that never saw the app. | cvs intro. | D | Definitions. | GREEN |
| Evidence is a body or a second read of state. A log line, status code, or "saved" alone is not. | cvs step 2 Evidence. cvs create-note Gotchas. spec 8.4. brief (`prove` reads it). | D | Definitions. Rules, proof is a body. Red flags. T Evidence. | RED: Claude's proof is HTTP 200 per route. |
| Proven means ran once end to end, and evidence exists after cleanup. A draft is not a deliverable. | cvs step 4. spec 8.4 (counts after one run). | D | Definitions. Loop 5. Red flags. Report Status. | RED: neither run ran a skill. |
| An existing verify skill gets the maintain pass. | mvs step 0. | P | Loop 1. M. | Untested. Grimoire has no verify skill. |
| Interview the repo, not the user: surface, run, drive, observe, isolate. | cvs step 1. | P | Loop 2. | GREEN |
| Launch via the repo command (just, make, compose). | cvs step 1 Run. spec 8.4. | P | Loop 2. T Launch. | GREEN partial: the Codex draft starts uvicorn from its own `run.py`. The manual skill uses `run.sh`. |
| Never drive an instance that you did not start. | cvs step 1 Isolate. cvs feature map README. | D | Loop 2. Rules, own instance. Red flags. | RED: Claude found the live 8790 instance itself. |
| Fix or report a broken base before you write. | cvs step 1. | P | Loop 3. | GREEN |
| Real commands, no placeholders. | cvs step 2 (no placeholders, real selectors). | D | Loop 4. Red flags. T intro. | GREEN |
| Sections Launch, Doctor, Drive, Evidence, Cleanup, Helpers. | cvs step 2. | P | T. | GREEN |
| Ready means usable. Launch works from an empty data dir. | cvs step 2 Launch. | P | T Launch. | GREEN |
| Doctor is one read-only check, before the first drive and after a failed drive. | cvs step 2 Doctor. mvs step 4 invariant 1. | P | T Doctor. M step 4. | GREEN partial: the Codex doctor does two list reads. |
| Real user path, no test-only endpoints. Mocks only at a production boundary. Observe dry-runs. | cvs step 2 Evidence. | D | Rules, real user path. T Evidence. | GREEN |
| Stop only your PID. Never kill by name. | cvs step 2 Cleanup. | D | Rules, own instance. T Cleanup. | GREEN |
| Cleanup keeps the evidence. Read it after cleanup. | cvs step 2 Cleanup, step 4. mvs invariant 2. | D | Loop 5. Rules. Red flags. T Cleanup. | GREEN |
| Helpers are executable and their call is in the skill. | cvs step 2 Helpers. | P | T Helpers. | GREEN |
| Feature map: README plus 3 to 5 files, four H2s in order. | cvs step 3. cvs feature-map-example. | P | Loop 4. T feature files. | GREEN |
| Never weaken a journey. Put the reason in Gotchas. | cvs step 3. | D | Rules. | Untested. |
| Run cleanup after each failed try. | cvs step 4. mvs invariant 3. | P | Loop 5. M step 4. | GREEN |
| Name each stand-in step that the real target does not get. | cvs step 4. | O | Rules. Report Stand-in gaps. | Manual run used a worktree. |
| Leave the skill uncommitted for review. | brief interface. | D | Loop 6. Rules, never commit. | RED: Claude planned a commit. |
| Cannot write or run: full skill in the answer, `Status: draft`. | research Loop 6 (cannot write). Audit: headless runs cannot write or start a process. | O | Loop 6. Report. | GREEN |
| Maintain: edit only the verify skill directory. | mvs Edit scope. | D | M Edit scope. | Untested. |
| Maintain: index, source read per feature, missing features, live pass, triage. | mvs steps 1 to 5. | P | M Steps. | Untested. |
| Maintain: unreachable needs its precondition and the route tried. | mvs step 4. cvs feature-map README. | D | M. T README. | Untested. |
| Maintain outcome clean, changed, or blocked. | mvs Outcomes. | O | M Outcome. | Untested. |
| `Principles applied:` line. | Dispatch common rules. verifier has no PRINCIPLE_TARGETS entry. | O | Report. | GREEN |
| Four repo lines, verbatim. | Brief Global Constraints. | D | Repo Rules. | GREEN |

## Cut

- cvs and mvs: the Codex, Copilot, and Muse platform-mapping lines. The house form has no platform files.
- cvs: the `/create-verification-skill` and `/maintain-verification-skill` slash names, and the Claude Code 2.1.200 link. This skill is `verifier`. The note about the bundled `/verify` gives no instruction.
- cvs step 1: browser, CDP, and tmux recipes as defaults. The spec targets HTTP services. Drive keeps "existing harnesses first".
- cvs step 1: verification scaffolding for a missing asset. Loop 3 covers it as "fix the cause".
- cvs step 5: the cadence offer. The maintain pass is a branch of this skill.
- mvs step 6: one PR of corrections. The brief says the verify skill stays uncommitted for review.
- mvs: run notes in a scratch location. The report holds the coverage.

## Pressure scenarios

Scenario: Make a verify skill for `~/Developer/grimoire`.

**RED** (no skill, both CLIs, read-only, 2026-10-30):
Claude plans a verify skill whose proof is `make check` plus HTTP 200 from six routes. It never runs the skill, and it plans a commit on a new branch. Codex stops with nothing. It says the session is read-only.
The failure to fix: no verify skill ran, and the planned proof is a status code, not a body.

**GREEN** (skill, both CLIs, 2026-10-30):
Iteration 1 (`--write`) passed the harness for both. Claude could not read the repo outside the scratch dir, so it wrote nothing and reported `Status: blocked`. Codex wrote a draft in its scratch dir and only linked it. The fix: Loop 6 asks for the full text of each file in the answer.
Iteration 2 (read-only) passed for both. Both report `Status: draft`, and neither claims a pass. Both plan proof as saved response bodies plus a second read, keep the live 8790 instance out, and leave the files uncommitted. Codex gives the full files. Claude gives a plan, because plan mode routes it to a plan file.
Manual proof: the Codex draft, saved as-is in a trial worktree, ran once and passed. Its evidence holds full response bodies and survives cleanup. The implementer also wrote a verify skill with this skill, and it ran once. Its telemetry read-back found that `/api/events` returns ok for a dropped event.
