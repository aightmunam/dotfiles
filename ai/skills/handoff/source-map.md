# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **recall:** pstack-claude `plugins/pstack/skills/recall/SKILL.md`, the output contract at lines 32 to 35, line 30 (order), line 37 (scope and length), and line 25 (verify against live state).
- **pw:** `ai/principles/prove-it-works.md` (from pstack `principle-prove-it-works`), live at `~/.agents/principles/prove-it-works.md`.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 handoff entry, section 8.7 table (handoff row), and the never-block-on-the-human row.
- **ch:** `ai/skills/create_handoff/SKILL.md`, only the `thoughts/shared/handoffs/` path.
- **rs:** `ai/skills/research/SKILL.md` Loop 6 (topic form, worktree path, no-write fallback).
- **brief:** Task 6.6 brief and its Global Constraints.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "Template" is `capsule-template.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Four sections in order: Capsule, Threads, Problems, Next move. | recall lines 30 and 32 to 35. spec 8.4. | O | Definitions. Template (Document, Rules). | RED: see Pressure scenarios. |
| Capsule: at most 5 bullets. | recall line 32. spec 8.4. | D | Rules. Template. Red flags. | RED |
| Threads: one line each, exactly one of six tags. A thread with no tag is not done. | recall line 33. spec 8.4. | D | Loop 3. Rules. Template (Tags). Red flags. | RED |
| Each tag is checked with `git` and `gh` before it is written. The command and result go on the line. | spec 8.4 (principle prove-it-works). recall line 25. pw (name the record for each fact). | D | Loop 2. Rules. Template (Tags, Document). Red flags. | GREEN |
| A check per tag: merged means `MERGED` and no revert in `git log`. Verified means a check ran in this session. Planned means the searches found nothing. | pw (read the real state before "merged"; do not infer from a proxy or a self-report). recall line 33 (tag list). | D | Template (Tags). Red flags. | GREEN |
| Verified means the check fails on the old code and passes on the new. A check that passes on the old code is not its check. | pw (a probe must use behavior that only the new artifact has). | D | Template (Tags). Red flags. | Partly shown in Fix round 1: both runs kept jitter . Neither ran a test. |
| A branch with an open or merged PR gets the PR tag. Its uncommitted changes go in the line text. | recall line 33 (exactly one tag). Review M2. | D | Template (Tags). | Untested. |
| Revert search: `#N` with a non-digit after it, `This reverts commit`, and `gh pr list --search Revert`. | pw (read the real state before "merged"). Review M3. | P | Template (Tags). | Untested. |
| Evidence forms: command, PR, commit, ticket, chat UUID, chat permalink, error-tracker issue. One list for Threads and Problems. `State:` lists each repo in scope. | recall line 37 (cite chat findings by UUID, shared-record findings by PR #, ticket ID, chat permalink, error-tracker issue). spec 8.4 recall (Jira and Sentry). Review I3. | O | Template (Evidence Forms, Document). | Untested for recall forms. |
| A branch that exists is not a status. | pw (do not infer from derived state). | D | Rules. Template (Tags). | GREEN |
| Memory, user notes, and an old capsule are candidates. The check wins. Write the difference under Problems. | pw (when you write a handoff, check its claims against the repo; a self-report proves nothing). | D | Loop 3. Rules. Template (Tags). | GREEN |
| `gh` fails: use the merge commits in `git log`, and write the failure under Problems. | pw (doubt the way you observed). spec never-block-on-the-human (no question for reversible work). | P | Template (Tags). | Untested. |
| Problems: at most 5. Include symptoms that recur and fixes that were reverted, with the reason. | recall line 34. spec 8.4. | D | Loop 4. Rules. Template. Red flags. | RED |
| Next move: one concrete action. | recall line 35. spec 8.4. | D | Loop 5. Rules. Template. Red flags. | RED |
| List the threads from the session and from `git status`, `git branch`, `git log`. Include failed and reverted work. | recall line 25 (take the branches and PRs, check them). spec 8.4 (problems include reverted fixes). | P | Loop 1. Red flags. | GREEN |
| Adjacent work stays out unless it blocks. Cut detail before threads. | recall line 37. | D | Template (Rules). | Untested. |
| Path `thoughts/shared/handoffs/YYYY-MM-DD-<topic>.md`. | spec 8.4. ch (the `thoughts/shared/handoffs/` directory). | O | Loop 6. Red flags. | RED |
| Topic is kebab-case, 3 to 6 words. Main checkout `thoughts/` in a worktree. No write access: the document goes in the answer. | rs Loop 6. | P | Loop 6. | GREEN (no-write fallback). |
| `State:` header line with repo, branch, HEAD SHA, and time. | pw (for each fact, name the record it came from). | O | Template (Document). | GREEN |
| No question to the user. A fact that cannot be checked is a Problems line. | spec never-block-on-the-human row. Controller ruling (reversible work proceeds). | D | Rules. | GREEN |
| Writes only. Reading a capsule back is `recall`. | spec 8.4 ("Writes only"). | D | Rules. | Untested. |
| One template file, shared with `recall`. | Task 6.6 dispatch (recall reuses the capsule format). recall lines 32 to 35. | O | `capsule-template.md`. | Untested. |
| Principle pointer at the check step. `Principles applied:` line in the document and the reply. | spec 8.7 (handoff row). brief (Principles). | P | Loop 2. Loop 7. Template. Red flags. | GREEN |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | Untested. |

## Cut

- ch: YAML frontmatter (researcher, tags, status, type, last_updated). The spec takes only the path from create_handoff. The header line keeps repo, branch, and SHA.
- ch: the ticket subdirectory and the `HH-MM-SS` timestamp in the file name. The spec path is `YYYY-MM-DD-<topic>.md`.
- ch: `humanlayer thoughts sync` and the `/resume_handoff` reply. `recall` replaces resume_handoff. Sync is outside the spec entry.
- ch: "more information, not less" and the free sections (Learnings, Artifacts, Other Notes). The spec sets limits: 5 bullets, 5 problems, one next move.
- recall lines 16 to 24: transcript mining, the subagent fan-out, the shared-record sweep, and the epistemics of human rulings. They read context at the start of a session. That is `recall`.
- recall line 37: write the brief through `unslop`, and sanitize private context before public output. The capsule is skill output in STE. It is not public text.
- recall line 37: cite chat findings by UUID. `handoff` cites commands. The template keeps the UUID slot for `recall`.

## Principles

prove-it-works (spec 8.7, lint `PRINCIPLE_TARGETS`). The pointer is at Loop 2. The document and the reply end with `Principles applied: prove-it-works -> <the tag or claim that a check changed>`.

## Pressure scenarios

Scenario file: `.superpowers/sdd/2026-10-30-skill-rework/scratch-6.6/scenario.txt` in the skill-rework worktree. It uses a scratch git repo (`scratch-6.6/repo`) and a fake `gh` script (`scratch-6.6/bin/gh`) that the scenario names. In the repo, PR #41 is merged, PR #43 is merged and then reverted by PR #44, and `feat/retry-jitter` has one uncommitted change. The user's notes in the prompt say #41 waits for review and #43 fixed the alerts.

**RED** (no skill, both CLIs, read-only, 2026-10-30):
Both runs loaded the old `create_handoff` skill. Both checked `git` and `gh`, because the scenario names them. Both caught the merged #41 and the revert of #43. Neither wrote the capsule contract: no status tags, no 5-bullet capsule, and 5 or 6 next steps in place of one next move. Both used the old path `handoffs/general/<date>_<time>_<topic>.md` with YAML frontmatter. Claude cost $0.34.
The failure: no tagged threads, no capsule limits, no single next move, and the old path.

**GREEN** (skill, both CLIs, read-only, 2026-10-30):
Iteration 1: Codex PASS. Claude wrote a correct capsule, but the harness failed it with "principle not read". Claude read the principle with `cat` in Bash, and `pressure-run` counts only the Read tool for Claude. A Claude-only rerun (iteration 2, no change) failed the same way.
Iteration 3 added a sentence that told the agent to open principle files with the file-read tool. The review removed it (a harness artifact), and the harness now counts shell reads. Both PASS (Claude $0.39, Codex 169k input and 2.0k output tokens). Both answers have four threads: `[merged #41]`, `[reverted #43]` with #44 named, the jitter change, and `[planned, not started]` for the metric. Claude tagged jitter `[verified, uncommitted]` after it ran `python3 -m unittest` in the session. Codex tagged it `[in flight feat/retry-jitter]`. Both tags match the template. Each tag has its command and result. Capsules have 5 bullets, Problems 5 and 3 lines, and one next move each. Both answers name the stale notes and the revert reason. `git status` of the scratch repo is unchanged.
After iteration 3, the `[verified, uncommitted]` row got the rule that the check must fail on the old code (pw).

**Fix round 1** (both CLIs, read-only, 2026-10-30, harness from a9161bd that counts shell reads):
The file-read sentence is gone. Both PASS (Claude $0.30, Codex 105k input and 2.3k output tokens). Tags match the fake `gh` and `git status`: `[merged #41]`, `[reverted #43]` with #44, `[in flight feat/retry-jitter]`, `[planned, not started]`. Both used the new revert search and the `State:` header. Neither ran a test. Claude wrote that a test with the default `jitter=0.0` passes on the old code, so it kept `[in flight]`. The fail-on-old half of the verified rule is still not shown by a run that ran a test.
