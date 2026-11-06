# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **cvs:** pstack-claude `plugins/pstack/skills/create-verification-skill` (SKILL.md and `references/feature-map-example/`).
- **mvs:** pstack-claude `plugins/pstack/skills/maintain-verification-skill/SKILL.md`.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 verifier entry.
- **brief:** Task 5.2 brief and the dispatch for it (Global Constraints, the interface, the `prove` note).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (removed after eec5ad9; read it in git history) (the form bar).
- **rig-plan:** `thoughts/shared/plans/2026-11-05-rig-cli.md`, Phase 10 Steps 1 and 2, Global constraints, and Deviation 20.
- **rig-cli:** `src/rig/__init__.py` in `aightmunam/rig`, `load_config`, `check_config`, `placeholders`, `verify_root`, and `cache_root`; command help.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "T" is `verify-template.md`. "M" is `maintain.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| The output is `~/.agents/verify/<repo name>/SKILL.md` with `name: verify`, local only, linked from the main checkout. Monorepo: `<repo name>-<package>`. | cvs intro and step 2, moved out of the repo by user choice (2026-11-04). | P | Definitions. Loop 6. T frontmatter. | Migrated 4 repos. |
| Write for an agent that never saw the app. | cvs intro. | D | Definitions. | GREEN |
| Evidence is a body or a second read of state. A log line, status code, or "saved" alone is not. | cvs step 2 Evidence. cvs create-note Gotchas. spec 8.4. brief (`prove` reads it). | D | Definitions. Rules, proof is a body. Red flags. T Evidence. | RED: Claude's proof is HTTP 200 per route. |
| Proven means ran once end to end, and evidence exists after cleanup. A draft is not a deliverable. | cvs step 4. spec 8.4 (counts after one run). | D | Definitions. Loop 5. Red flags. Report Status. | RED: neither run ran a skill. |
| An existing verify skill gets the maintain pass. | mvs step 0. | P | Loop 1. M. | Untested. Grimoire has no verify skill. |
| Interview the repo, not the user: surface, run, drive, observe, isolate. | cvs step 1. | P | Loop 2. | GREEN |
| Launch via the repo command (just, make, compose). | cvs step 1 Run. spec 8.4. | P | Loop 2. T Launch. | GREEN partial: the Codex draft starts uvicorn from its own `run.py`. The manual skill uses `run.sh`. |
| Never drive an instance that you did not start. | cvs step 1 Isolate. cvs feature map README. | D | Loop 2. Rules, own instance. Red flags. | RED: Claude found the live 8790 instance itself. |
| Fix or report a broken base before you write. | cvs step 1. | P | Loop 3. | Untested. The grimoire base was never broken. |
| Real commands, no placeholders. | cvs step 2 (no placeholders, real selectors). | D | Loop 4. Red flags. T intro. | GREEN |
| Sections Launch, Doctor, Drive, Evidence, Cleanup, Helpers. | cvs step 2. | P | T. | GREEN |
| Ready means usable. Launch works from an empty data dir. | cvs step 2 Launch. | P | T Launch. | GREEN |
| Doctor is one read-only check, before the first drive and after a failed drive. | cvs step 2 Doctor. mvs step 4 invariant 1. | P | T Doctor. M step 4. | GREEN partial: the Codex doctor does two list reads. |
| Real user path, no test-only endpoints. Mocks only at a production boundary. Observe dry-runs. | cvs step 2 Evidence. | D | Rules, real user path. T Evidence. | GREEN |
| Stop only your PID. Never kill by name. | cvs step 2 Cleanup. | D | Rules, own instance. T Cleanup. | GREEN |
| Cleanup keeps the evidence. Read it after cleanup. | cvs step 2 Cleanup, step 4. mvs invariant 2. | D | Loop 5. Rules. Red flags. T Cleanup. | GREEN |
| Helpers are executable and their call is in the skill. | cvs step 2 Helpers. | P | T Helpers. | GREEN partial: the Codex draft shows the call of `run.py`, but the file is mode 644. |
| Feature map: README plus 3 to 5 files, four H2s in order. | cvs step 3. cvs feature-map-example. | P | Loop 4. T feature files. | GREEN |
| Never weaken a journey. Put the reason in Gotchas. | cvs step 3. | D | Rules. | Untested. |
| Run cleanup after each failed try. | cvs step 4. mvs invariant 3. | P | Loop 5. M step 4. | Untested. No try failed in GREEN or in the manual run. |
| Name each stand-in step that the real target does not get. | cvs step 4. | O | Rules. Report Stand-in gaps. | Untested in GREEN. The manual run named one gap (`.venv` provisioning). |
| Leave the skill uncommitted for review. | brief interface. | D | Loop 6. Rules, never commit. | RED: Claude planned a commit. |
| Cannot write or run: full skill in the answer, `Status: draft`. A draft is a fallback, never `proven`. | research Loop 6 (cannot write). Audit: headless runs cannot write or start a process. | O | Definitions. Loop 6. Report. | GREEN partial: both give `Status: draft`. Codex gives the full files. Claude gives a plan. |
| Maintain: edit only the verify skill directory. | mvs Edit scope. | D | M Edit scope. | Untested. |
| Maintain: index, source read per feature, missing features, live pass, triage. Read each changed file again before you stop. | mvs steps 1 to 6. | P | M Steps. | Untested. |
| Maintain: unreachable needs its precondition and the route tried. | mvs step 4. cvs feature-map README. | D | M. T README. | Untested. |
| Maintain outcome clean, changed, or blocked. | mvs Outcomes. | O | M Outcome. | Untested. |
| `Principles applied:` line. | Dispatch common rules. verifier has no PRINCIPLE_TARGETS entry. | O | Report. Red flags. | Untested. No GREEN final answer has the line. The harness checks it only with `--principle`. |
| Each report template line is present. | Review M1 (task-5.2-review.md): GREEN-2 Claude gave only `Status:`. | D | Red flags. | Untested. Added after GREEN. |
| Evidence slot: the first 5 to 15 lines of the saved body. | cvs step 4 (confirm the evidence exists). Review M3. | O | Report Evidence. | GREEN (manual run printed the body). |
| Run `git check-ignore -v` on each written path. Report the ignore source and the `git add -f` command. Never run `git add -f`. | Audit: `~/.gitignore_global:41` ignores `.claude/`. Review I2 and controller ruling. | O | Loop 6. Report Ignored. | Untested. Added after GREEN. |
| Do not remove a worktree that holds ignored verify files. | Audit: `git worktree remove` deletes ignored files without `--force`. Review I2. | D | Red flags. | Untested. Added after GREEN. |
| The generated `description:` starts with `Use when`. | Review M4. Dispatch common rules (description form). | D | T frontmatter. Red flags. | GREEN partial: the Codex draft does not. Red flag added after GREEN. |
| Four repo lines, verbatim. | Brief Global Constraints. | D | Repo Rules. | GREEN |
| Write `rig.toml` with the skill and feature map. Keep launch and drive configuration there. | rig-plan Step 1. rig-cli. | P | Loop 4. T configuration reference and template. | P10 create: RED Claude invented unsupported keys. |
| Use the actual rig command arguments and `Driving it with rig` headings. | rig-plan Step 1. rig-cli command help. cvs step 3. | P | Loop 4. T Drive, Evidence, and feature template. | P10 create and maintain. |
| Add a helper only when configuration cannot express the behavior. Call it from `rig.toml` with checkout-relative placeholders. | rig-plan Step 1 and Global constraints. rig-cli placeholders. | D | Loop 4. T Select helpers. M step 5. | P10 create and maintain reject lifecycle scripts. |
| Run `rig check` before live proof. Capture the evidence path before cleanup and read the saved proof after cleanup. | rig-plan Step 1. cvs step 4. rig-cli info and cleanup. | P | Loop 5. T Launch and Cleanup. M step 4. | P10 create and maintain. |
| Maintain with rig. Fix configuration or a configured helper for new actions. Keep raw curl and lifecycle scripts out of recipes. | rig-plan Step 2. mvs steps 4 and 5. | P | M Edit scope and steps 4 and 5. | P10 maintain: both baseline answers already chose configuration. |

## Cut

- cvs and mvs: the Codex, Copilot, and Muse platform-mapping lines. The house form has no platform files.
- cvs: the `/create-verification-skill` and `/maintain-verification-skill` slash names, and the Claude Code 2.1.200 link. This skill is `verifier`. The note about the bundled `/verify` gives no instruction.
- cvs step 1: browser, CDP, and tmux recipes as defaults. The spec targets HTTP services. Drive keeps "existing harnesses first".
- cvs step 1: verification scaffolding for a missing asset. Loop 3 covers it as "fix the cause".
- cvs step 5: the cadence offer. The maintain pass is a branch of this skill.
- mvs step 6: one PR of corrections. The brief says the verify skill stays uncommitted for review.
- mvs: run notes in a scratch location. The report holds the coverage.
- P10: duplicate lifecycle scripts and raw curl recipes. Shared rig commands hold that mechanism.
- P10: a second configuration validator. `rig check` already enforces the configuration boundary.

## Pressure scenarios

Scenario: Make a verify skill for `~/Developer/grimoire`.

**RED** (no skill, both CLIs, read-only, 2026-10-30):
Claude plans a verify skill whose proof is `make check` plus HTTP 200 from six routes. It never runs the skill, and it plans a commit on a new branch. Codex stops with nothing. It says the session is read-only.
The failure to fix: no verify skill ran, and the planned proof is a status code, not a body.

**GREEN** (skill, both CLIs, 2026-10-30):
Iteration 1 (`--write`) passed the harness for both. Claude could not read the repo outside the scratch dir, so it wrote nothing and reported `Status: blocked`. Codex wrote a draft in its scratch dir and only linked it. The fix: Loop 6 asks for the full text of each file in the answer.
Iteration 2 (read-only) passed for both. Both report `Status: draft`, and neither claims a pass. Both plan proof as saved response bodies plus a second read, keep the live 8790 instance out, and leave the files uncommitted. Codex gives the full files. Claude gives a plan, because plan mode routes it to a plan file.
Manual proof: the Codex draft, saved as-is in a trial worktree, ran once and passed. Its evidence holds full response bodies and survives cleanup. The implementer also wrote a verify skill with this skill, and it ran once. Its telemetry read-back found that `/api/events` returns ok for a dropped event.

**Maintain pass, RED with the current skill** (both CLIs, 2026-11-04). The source is pstack `maintain-verification-skill`. The test checked 4 pstack rules that `maintain.md` does not state.
Scenario 1 (plan the pass for 6 features, a renamed `make` target, a failed helper, teardown): both drive in dependency order on one instance, fix the launch drift and relaunch, drive the feature again after the helper fix, and tear down after the last drive.
Scenario 2 (doctor fails again after the drift fix): both triage once and stop as `blocked` with no commit.
No failure, so no text was added. Routing rows `skill-verifier-maintain` and `pair-verifier_new-skill-verifier-maintain` pass under both CLIs.

### Phase 10 rig scenarios

Evidence root: `~/.cache/build/2026-11-05-rig-cli/phase-10/pressure/`.
`create-direct.txt` and `maintain-direct.txt` are read-only fixture scenarios. Each RED and GREEN pair uses the same prompt.

**RED:** `red-create/claude.txt` invents unsupported configuration keys. The extracted configuration fails `rig check` with unknown keys.
`red-create-direct/claude.txt` repeats the schema gap. Codex leaves the complete configuration pending. Both maintenance baselines already select configuration.

**GREEN:** both saved answers in `green-create-direct/` and `green-maintain-direct/` pass the harness and were read.
Both create answers use supported configuration, no helper, rig drives, and a post-cleanup evidence read. Both extracted configurations pass `rig check`.
Both maintenance answers fix probes in `rig.toml`, keep the item journey, and reject new lifecycle scripts.
Claude cost: create $0.371195; maintain $0.430687. Codex cost is unavailable. No live fixture proof ran.

The first GREEN runs used shell loops that the harness could not recognize as skill reads.
The direct-read repeats retain the same task and add a literal skill-read instruction. Original runs remain in the evidence root.
Descriptions, routing, and eval prompts stay unchanged because the triggers did not change.
