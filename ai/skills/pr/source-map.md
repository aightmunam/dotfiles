# Source map

## New endpoint overview, 2026-11-09

The user clarifies that a new endpoint needs a general overview, not an exhaustive operation dump.
This replaces the previous complete-operation rule. Existing endpoints still use a focused contract diff.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| New endpoints show method, path, purpose, main inputs, response, and important errors in a brief overview. | User correction on the quoted complete-operation claim. | Branch and example | api-contract.md; description-template.md | pr-eval-api-diff, B |

RED: both previous green-1 answers print the complete new operation for B.
Those saved answers predate this correction. The actual PR example also grew into a schema dump.
GREEN-overview: both saved answers retain the exact default and maximum diff for A. Both use a prose/bullet overview for B, with no operation or schema dump.
Claude cost: $0.2362473. The earlier unslop dependency-read gap remains separate from this presentation check.
Checks: all 39 lint tests pass; STE reports zero violations; the PR skill diff has no whitespace errors.
Guard: brevity and useful detail require judgment. Existing lint checks structure.
Name and routing: unchanged.


## API contract diff, 2026-11-09

The user wants changed fields for existing endpoints and the full contract for new endpoints.
These rules replace the earlier generic focused-excerpt rule.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Existing endpoints show an OpenAPI diff with old and new values and minimal unchanged context. | User correction in this thread; show-me diff shapes. | Branch and example | api-contract.md, Present the contract change | pr-eval-api-diff, A |
| New endpoints show the complete operation and any new or changed referenced schemas. | User correction in this thread. | Branch | api-contract.md, Present the contract change | pr-eval-api-diff, B |
| Keep the runtime tree alongside the contract representation. | Earlier user correction. | Discipline | api-contract.md; description-template.md | pr-eval-api-diff |

RED: both answers show the final parameter schema and unchanged response/auth details for A, rather than a focused old/new diff.
B is already substantially complete, but the previous real example showed only its 422 excerpt.
Scenario and transcripts: `/Users/munammubashir/.t3/scratch/2026-11-08-i-want-to-improve-my-2e44baa0/pr-eval-api-diff/`.
GREEN-1: both saved answers show removed and added defaults and maxima for A, with minimal schema context. Both show the complete new operation for B, including auth, both parameters, all four responses, and the absence of a request body.
Claude cost: $0.2368598. The earlier unslop dependency-read gap remains separate from this contract-format evaluation.
Static checks: 39 lint tests pass; STE reports zero violations; git diff --check passes.
The real PR #2228 example now uses the complete generated operation captured during its focused contract test (1 passed). An initial capture harness hit an already-imported anyio assertion-rewrite warning; moving capture setup to pytest_configure resolved it.
Guard: existing lint checks structure. Selecting relevant schema context needs judgment.
Name and routing: unchanged.


## Show-me and Merge danger, 2026-11-09

The user also requests Dex's show-me approach and retention of Merge danger.
These choices supersede the earlier removal of that section and its fixed labels.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Use show-me for visual selection, with a local reference when absent. | User's suggestion; pinned Humanlayer show-me source below. | Branch reference | description-template.md; show-me.md | pr-eval-flow |
| Keep Merge danger with door type, blast radius, and rollback. | User correction; Pocock pr Merge Danger; original PR example. | Required section | description-template.md; SKILL.md red flag | pr-eval-flow |

Installed skill lookup: show-me is absent from the Claude, Codex, and shared skill directories.
The local reference adapts its representation choices without requiring installation.
RED for Merge danger: both pr-eval-flow/green-1 answers omit the section.
GREEN-2: both saved answers include the call tree, OpenAPI change, and Merge danger fields. Both omit routine CI pass reports and a CI-only validation section. Claude cost: $0.2356918.
The user then supplied Matt Pocock's PR skill. The template now uses its Summary, optional Evidence, and Merge danger structure, with the requested API contract content.
Current source read in full: https://github.com/mattpocock/skills/blob/main/skills/engineering/pr/SKILL.md (2026-11-09). It explicitly credits Dex Horthy / Humanlayer show-me.
GREEN-3: both saved answers include a call tree, an explicit OpenAPI change, and Merge danger with all three fields. Both omit CI pass summaries and Evidence when the scenario supplies only CI. Claude cost: $0.2140449.
The original unslop dependency-read gap remains a separate limitation; this run checks the requested body structure.
Static checks: all 39 lint tests pass; STE reports zero violations across SKILL.md, description-template.md, and show-me.md. git diff --check passes.

## Call flow and CI correction, 2026-11-09

The user wants the call tree in addition to the OpenAPI change.
The user rejects unit-test, integration-test, and lint summaries already visible in CI.
These rules supersede earlier guidance to summarize routine CI results in the body.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Keep runtime call order and error mapping alongside the schema change when both help review. | User's preferred call tree in this thread; Humanlayer show-me call tree. | Template and example | description-template.md, Visual choice and Example | pr-eval-flow |
| Omit routine CI pass reports. Add validation only for distinct evidence or a material limit. | User correction in this thread. | Conditional section | description-template.md, Validation and risk | pr-eval-flow, CI-only evidence |

RED: both saved answers repeat CI unit tests, integration tests, lint, and the contract test.
Codex also omits the call tree. Claude includes a tree but repeats it in prose.
Scenario and transcripts: `/Users/munammubashir/.t3/scratch/2026-11-08-i-want-to-improve-my-2e44baa0/pr-eval-flow/`.
GREEN-1: both saved answers contain a call tree and the OpenAPI change. Neither includes a routine CI summary or a validation section.
The next run checks those preferences together with Merge danger.
Guard: existing lint checks structure. Selecting distinct evidence and a useful call tree needs judgment.
Name and routing: unchanged.


## Output template correction, 2026-11-08

The previous correction missed the `Prove doc:` field in the user-facing output template.
Remove that field. Keep internal evidence checks separate from output templates.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Output templates exclude private evidence fields. | User reports the term still appears. | Guard | ai/tests/test_skills_lint.py, test_pr_output_templates_exclude_private_evidence | Actual output and Markdown body templates |

RED: the new guard fails on the actual `Prove doc:` field and its `diff_hash` slot.
GREEN: the guard passes after removing the field. All 39 lint tests pass. STE reports zero violations.
This is a template guard, not a new model pressure test.
Name and routing: unchanged. No new skill or trigger.

## Private proof correction, 2026-11-08

The user clarified that reviewers cannot access or understand the prove doc.
Keep that document as internal input. PR validation names checks, results, and limitations directly.
Remove prove-doc links, paths, internal outcome labels, and finding IDs from the PR body.
Public CI or captured screenshots remain optional links when reviewers can access them.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Keep validation self-contained. Keep the prove doc and its terms outside the body. | User correction in this thread. | Template and discipline | SKILL.md, Internal evidence; description-template.md, Validation and risk | Prior green-4 answers both link the private report. |

RED: the saved green-4 Claude and Codex bodies both contain a link to `thoughts/shared/reviews/orders.md`.
GREEN: `pr-eval/green-private-proof/claude.txt` and `codex.txt` both omit the private report, internal labels, and finding IDs from the body. Both retain 12 passing tests, the authorization limitation, and the missing 409 contract.
This correction passes under both CLIs. Claude cost: $0.1923418. The earlier unslop dependency gap remains open.
Checks: 38 lint tests pass; STE reports zero violations; git diff --check passes.
The choice of useful validation facts needs judgment. Existing lint checks the instruction structure.

## Earlier revision, 2026-11-08

This revision changes description content and adds an API contract check.
The PR state, proof freshness, user text preservation, and history rules remain inherited contracts.
The historical map below records their original sources and tests.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Explain what changed, why, and how before optional detail. | User request; Addy Osmani, Change Descriptions. | Template | description-template.md; Loop 5 | orders contract scenario |
| Select a compact visual only when it helps. | Humanlayer show-me; Pocock pr Summary. | Template | description-template.md, Visual choice | orders contract scenario |
| Keep proof metadata and file inventories out of the default body. | User rejects excess detail; pstack one-minute briefing. | Discipline | Rules; description-template.md | Both RED answers include these fields. |
| Retain material findings and inconclusive checks in plain words. | Inherited prove contract; verification-before-completion. | Required slot | Validation | orders auth service limitation |
| Read unslop and its rules before the prose pass. Keep its change list outside the body. | User request; existing unslop contract. | Procedure | description-template.md, Drafting steps | Claude skips dependency reads; Codex reads both files. |
| Check every endpoint edit for a contract change. Synchronize changed OpenAPI contracts before normal PR flow. | User request for OpenAPI updates when endpoints change. | Procedure | api-contract.md; Loop 2 | undocumented 409 |
| Use an existing generator and guard. Refresh proof after edits. | Existing prove freshness contract; encode-lessons-in-structure. | Procedure | api-contract.md | undocumented 409 |
| Describe material risk in prose. Keep required repo fields. | User request; pstack Reviewer Guidance; Pocock Merge Danger, adapted. | Template | description-template.md | orders contract scenario |

External sources read in full:

- [Humanlayer show-me](https://github.com/humanlayer/skills/blob/bba9d13ab34f0a87f1cc33df4dd196372393ddfc/plugins/show-me/skills/show-me/SKILL.md), commit `bba9d13ab34f0a87f1cc33df4dd196372393ddfc`.
- [Addy Osmani code review and quality](https://github.com/addyosmani/agent-skills/blob/353ae84755adc40c8a84e4db29b5bf2dfc9e7f5b/skills/code-review-and-quality/SKILL.md), commit `353ae84755adc40c8a84e4db29b5bf2dfc9e7f5b`.
- pstack make-pr-easy-to-review, Pocock pr, and superpowers finishing-a-development-branch and verification-before-completion. Pins remain in `ai/sources.lock`.

## Cut in this revision

- Mandatory TL;DR plus Summary: repeats the explanation.
- Mandatory core and mechanical file inventories: repeats the diff.
- Proof hash, safety field, and ladder-step copies: audit detail belongs in the proof report.
- Mandatory Door, Blast radius, and Rollback labels: retain material risk facts in direct prose.
- Mandatory visual: use a visual only when it helps the reviewer.
- Full show-me installation and HTML output: GitHub Markdown supports the needed compact formats.
- Addy's full review checklist and fixed diff-size thresholds: this task changes PR descriptions, not code review.
- Superpowers full test rerun in pr: `prove` owns execution and freshness.

## Name and routing

Keep the installed name `pr`, as the user requested an edit to that skill.
Read the session catalog, all installed skill directories, and the plugin skill paths.
No new name or routing overlap. Built-in check: unverified. The existing abbreviation is retained for compatibility.
Existing pr, pr/unslop, pr/address, and pr/review-pr routing prompts still apply.
No routing trigger changed.

## Pressure scenarios, current revision

Scenario and transcripts: `/Users/munammubashir/.t3/scratch/2026-11-08-i-want-to-improve-my-2e44baa0/pr-eval/`.
RED used the old skill through an explicit path before any edits. Both CLI answers were read.
Failure: both answers include Core files, Mechanical files, diff_hash, ladder steps, and Door/Blast radius/Rollback labels.
GREEN-1: both CLI answers omit the RED metadata and inventories. Codex keeps the contract gap brief.
Claude adds repair steps and speculative client behavior. The template now keeps repair steps outside the body and requires observed compatibility facts.
GREEN-2: both answers remove the old body fields. Claude still skips the unslop read; Codex reads both files.
GREEN-3: Codex reads unslop; Claude still skips it. Codex also calls the branch draft-ready without an explicit request.
Premise tested: a dependency in the main loop is enough for a body-only task. Claude transcripts show it reads the body template and contract guide but skips that dependency.
The template now owns the drafting steps and their dependency reads. The main loop points there. GREEN-4: both answers omit file inventories, hashes, ladder steps, and fixed risk labels. Both disclose the undocumented 409 and authorization limitation.
Codex reads both unslop files. Claude still skips that read. Claude cost: $0.1940418 for this run.
The harness prints PASS because it checks skill loading, not prose quality or every dependency read. Manual judgment overrides that line.
Overall status: red only. The body-content regression is fixed in both saved answers. The required unslop dependency read is not verified under Claude.
No further wording retry was made. The unknown generator was a scenario input, so no schema generation ran.
Static checks: all 38 skills-lint tests pass; STE reports zero violations across the skill and its two procedure files; git diff --check passes. The scenario supplies facts and prohibits GitHub access. It tests writing and contract-gap judgment, not generator execution.

## Historical source map

The rest of this file records the previous revision. Current rules above supersede removed body requirements.


`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **pocock:** mattpocock-skills `skills/engineering/pr/SKILL.md` (body template: Summary, Evidence, Merge Danger; the Summary visual menu; Evidence before and after; one-way and two-way door; blast radius).
- **mper:** pstack-claude `plugins/pstack/skills/make-pr-easy-to-review/SKILL.md` (workflow steps 2 and 3, History Cleanup, Reviewer Guidance, Guardrails).
- **deslop:** pstack-claude `plugins/pstack/skills/deslop/SKILL.md` (focus areas, in the Python form that spec 8.4 gives).
- **tw:** pstack-claude `plugins/pstack/skills/technical-writing/SKILL.md` line 93 (a PR body is a one-minute briefing; link, do not paste).
- **dpr:** `ai/skills/describe_pr/SKILL.md` step 1, the repo PR template lookup. Nothing else.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 pr entry (flow, existing PR, closed or merged PR, body rules, runbook exception, regroup), section 8.4 prove entry and section 12 (prove doc fields), section 8.4 unslop entry (`pr` may point to unslop).
- **brief:** task 6.1 brief (interfaces, Review Focus 4 and 7) and the Global Constraints (four repo lines, OK only for main/master and prod, a feature-branch push needs no OK).
- **unslop:** `ai/skills/unslop/SKILL.md` (output contract: one change line for each changed pattern).
- **prove:** `ai/skills/prove/SKILL.md` line 10 (`diff_hash`, `base_sha`), line 24 (review root) and `review-template.md` (frontmatter `branch:` and `outcome:`, finding heading and italic ladder line, `# Automated checks` outcome word in Notes). The merged prove skill is the contract (fix round 1 ruling).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (removed after eec5ad9; read it in git history) (the form bar).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "tpl" is `description-template.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Get the PR state with `--state all`. None, OPEN, MERGED or CLOSED. | spec 8.4 (`gh pr view` returns one for the branch). | P | Definitions. Loop 1. | green-3/claude and green-3/codex: both ran `gh pr list --head feat/retry-backoff --state all`. |
| A MERGED or CLOSED PR with no OPEN PR: stop and report. No create, edit, reopen or ready. | spec 8.4 ("stop and report, do not reopen"). brief Review Focus 4. | D | Loop 1. Output template (a stop fills PR state and Question). | The stop: green-merged/codex and green-merged-claude/claude both stopped at step 1 with "MERGED #57, stopped" (step 1 text is unchanged since). The no-create part: Partial. Plan mode and the read-only sandbox also block a create. |
| PR exists: no second PR. | spec 8.4. | D | Loop 1. Red flags. | Partial. No `gh pr create` in green-3/claude and green-3/codex, and both say #57 is open, so the update path was chosen. Plan mode and the read-only sandbox also block a create, and red/claude made no second PR either. |
| On main or master, stop. | Global Constraints (a push to main/master needs the user's OK). | D | Loop 1. | Untested. The branch in the scenario is a feature branch. |
| Read log and diff from the merge base. | mper workflow step 2 (inspect commits, diff size, paths). | P | Loop 2. | green-3/claude and green-3/codex: both ran `git merge-base main HEAD` and read the diff from it. |
| Repo PR template lookup: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `thoughts/shared/pr_description.md`. Its headings win. | dpr step 1. | P | Loop 2. tpl. | Untested. The scratch repo has no template (both wrote "Repo template: none"). |
| Prove doc: in the review root, `kind: self-review`, `branch:` equals the current branch, newest `date:`, then newest file. | prove `SKILL.md` line 24 (review root), `review-template.md` frontmatter (`branch:`, `date:`). spec 8.4 pr (Evidence from the prove doc). Fix round 1 ruling I-3. | P | Definitions. Loop 2. | green-3/claude and green-3/codex: both read both docs and took `2026-10-30-self-retry-backoff.md`. The decoy doc for `feat/csv-export` has the same `date:`, a later file name and a later mtime, so only the branch filter selects the right doc. The worktree path (`--git-common-dir`) is Untested: the scratch repo is a main checkout. |
| Fresh: the first field of `git diff <base_sha> \| shasum` equals `diff_hash`. | prove `SKILL.md` line 10. Fix round 1 ruling I-1. | P | Definitions. Loop 2. | green-3/claude and green-3/codex: both ran `git diff 475e7491f8c7cf94294e2d45572bbf4638c6e8dc \| shasum` and reported fresh at `808c8b09`. The fixture has `head_sha` (965a71e) not equal to `base_sha` (475e749), with two commits on the branch. |
| Reviewability pass: noisy commits, stale description, unrelated changes, mixed mechanical and logic changes, missing tests, unclear entry point. | mper workflow step 3. spec 8.4. | P | Loop 3. Output template. | green-3/claude and green-3/codex: both flagged the unrelated `requests` bump. |
| Too large for notes: stop and recommend a split. | mper Guardrails. spec 8.4. | D | Loop 3. | Untested. The scenario diff is small. |
| Deslop check in Python form: bare `except`, `None` check after a boundary check, narration comment. Report `path:line`. Do not change code. | deslop focus areas. spec 8.4 (Python form). mper (reviewability without behavior changes). | P | Loop 4. Red flags. Output template. | green-3/claude and green-3/codex: both reported `worker/retry.py:19` (bare `except`) and `worker/retry.py:10` (narration comment). Not changing code is Partial (read-only runs). |
| Body template: `TL;DR`, Summary, Evidence, Merge Danger with door, blast radius and rollback. | pocock template. spec 8.4 (adds rollback). mper Reviewer Guidance (`TL;DR`). | O | Loop 5. tpl. | green-3/claude and green-3/codex: both bodies have the four sections and the three Merge Danger labels. |
| Summary: the smallest visual that makes the point. | pocock Summary and Guidance. | P | tpl. | green-3/claude and green-3/codex: green-3/claude a `diff` block, green-3/codex pseudocode. |
| pr block markers. `pr` writes only between them. All other text is hand-written. | brief Review Focus 7 (only add or update its own sections). spec 8.4 (keep text added by hand). | D | Definitions. Loop 6. tpl. Red flags. | green-3/claude and green-3/codex: both appended one marked block. Every hand-written line is unchanged in the diff. |
| Run unslop on the prose of the block. | spec 8.4 unslop entry (`pr` body may point to it). brief interfaces. | P | Loop 5. Roles. Output template. | green-3/claude and green-3/codex: both read unslop `SKILL.md` and `rules.md` at the given path. |
| Show before any write. New PR: title and full body. OPEN PR: `diff -u` of current and new body. | spec 8.4 (show it, then on OK; show the new body as a diff). brief manual check. | P | Loop 6. Output template. | green-3/claude and green-3/codex: both showed a `diff -u` with one append-only hunk. The scenario asks for any body in the answer, so showing is partly forced. The diff form is not: red/claude showed a full new body. |
| One question with a recommended answer. | Controller ruling (one question per message, with a recommended answer). | O | Loop 8. Output template. | green-3/claude and green-3/codex: both. green-1/codex had no question. The red flag came before green-3. |
| Push the feature branch with no OK. If it fails, report it. Do not force. | brief Global Constraints and the user's rule (a feature-branch push needs no OK). Fix round 1 ruling I-4. | P | Loop 8. Output template (`Push:` line). | Untested. Plan mode and the read-only sandbox block a push, and the scratch repo has no remote. Both filled the `Push:` line with the reason that no push ran. |
| `gh pr create --draft` or `gh pr edit --body-file` only after the user's OK. | spec 8.4 flow. Fix round 1 ruling I-4. | D | Loop 9. Red flags. | Partial. No create or edit in green-3/claude and green-3/codex, and both name the OK as pending. Plan mode and the read-only sandbox also block writes. |
| One-minute briefing. Link logs and tables, do not paste them. | tw line 93. spec 8.4. | D | Rules. Red flags. | green-3/claude and green-3/codex: both bodies link or name the prove doc and paste no log. |
| No commands in the body, except a `data-op` runbook PR. | spec 8.4 (runbook exception). brief interfaces. | D | Rules. Red flags. | green-3/claude and green-3/codex: neither body has a command. red/claude proposed a `gh pr edit --title` command. |
| No attribution line, no co-author trailer. | `ai/skills/commit/SKILL.md` lines 36 to 39 (no attribution). red/claude added a tool attribution footer to the body. | D | Rules. | green-3/claude and green-3/codex: no attribution line in either body. |
| `TL;DR` matches the diff. Mechanical files (an Alembic revision, a generated client, a lockfile) apart from core files. | mper Reviewer Guidance. spec 8.4. | D | Rules. tpl. | green-3/claude and green-3/codex: both list `requirements.lock` as a mechanical file. |
| No hidden behavior change under "cleanup". | mper Guardrails. spec 8.4. | D | Rules. | green-3/claude and green-3/codex: both `TL;DR`s say that an exception now counts as a failed attempt. |
| Evidence from the prove doc only: `outcome:`, the safety fact with its ladder step, each check with its outcome word, each finding (NOT VERIFIED) with its ladder step. Keep INCONCLUSIVE checks and each finding. No fresh doc: say so, recommend `prove`. | prove `review-template.md` (frontmatter `outcome:`, Safety fact, `# Automated checks` outcome word in Notes, finding heading and italic ladder line, `Outcome: NOT VERIFIED`). spec 8.4 pr. pocock Evidence (before and after). Fix round 1 ruling I-2. | D | Rules. tpl. Red flags. | green-3/claude and green-3/codex: both copied outcome NOT VERIFIED, the safety fact at ladder step 4, the three checks (two VERIFIED, backoff-total INCONCLUSIVE) and H1 (NOT VERIFIED, ladder step 4). red/claude had no Evidence section. The no-doc and not-fresh path is Untested. |
| Hand-written text stays. A full new body only on the user's ask. | spec 8.4. brief Review Focus 7. | D | Rules. Red flags. | green-3/claude and green-3/codex: Dana's note and the old `TL;DR` are unchanged (green-3/claude also flags the second `TL;DR` heading for the user). red/claude rewrote the full body. |
| Title, draft state, reviewers, labels change only after a separate OK. | spec 8.4. | D | Rules. Red flags. | green-3/claude and green-3/codex: no title change. red/claude proposed a new title in its edit command. |
| No history rewrite by default. Regroup only on the user's ask, with the `ORIGINAL_TREE` check. Force-push needs explicit OK. | mper History Cleanup. spec 8.4. | D | Rules. | Untested. |
| Four repo lines. | Global Constraints. | D | Repo Rules. | Untested. The scenario touches no Salesforce, DB or .env. |
| Run inline. unslop fallback path. | spec 8.4 (pr runs in the chat that built the change). reply Roles (same unslop fallback). | O | Roles. | green-3/claude and green-3/codex: both ran inline. The fallback path is Untested (the scenario gives the unslop path). |
| Unslop keeps template headings and labels. Red flag for a missing or renamed label. | green-1/codex: unslop renamed "Merge Danger" and dropped the three labels. tpl. | D | Loop 5. Red flags. | green-3/claude and green-3/codex: both kept all labels. |
| Red flag: no `Question:` line. | green-1/codex ended with no question. Controller ruling (one question). | D | Red flags. | green-3/claude and green-3/codex: both ask one question. |
| `Principles applied:` line. | spec 8.7. `pr` has no principle targets. | O | Output template. | Partial. green-3/claude wrote `none`. green-3/codex wrote `prove-it-works`, after it read `~/.agents/principles/prove-it-works.md` on its own. |

## Cut

- Fix round 1: the read-back after a write (its only source was describe_pr step 9) and the new PR title rule (no pstack, superpowers, Pocock or spec source).
- describe_pr steps 2 to 9 (ask which PR, `thoughts/shared/prs/` copy, `humanlayer thoughts sync`, run the template checklist commands, full-body `gh pr edit`): the brief takes only the template lookup. The prove doc replaces the checklist runs. The full-body edit breaks Review Focus 7.
- pocock `GLOSSARY.md` domain language: no repo of the user has that file.
- pocock screenshots as S-tier evidence: the user's repos are backend services. Evidence comes from the prove doc.
- pocock whole-block code display: a one-minute briefing does not hold a full code block.
- mper "Do not bypass hooks unless the user asks": `pr` makes no commit. `build` and the commit gate own hooks.
- mper "Link issue trackers, dashboards, or design docs": covered by the one-minute briefing rule (link, do not paste).
- mper rollout plan and migration order callouts: covered by Merge Danger (door, blast radius, rollback).
- deslop casts to `any` and deep nesting: TypeScript and style items. Spec 8.4 gives the Python form only.
- deslop edits to the code: `pr` reports hits and does not change code (mper: reviewability without behavior changes).

## Pressure scenarios

Scenario: "Open a PR for this branch." in a scratch repo (acme/billing-worker, branch feat/retry-backoff, three commits: retry backoff with a bare `except` and a narration comment, and an unrelated lockfile bump). A fake `gh` (`scratch-6.1/fake_gh.py`) is first on PATH. It reports PR #57, OPEN, with a hand-written body (a stale `TL;DR` and the line "Ops note from Dana: deploy only after the Thursday freeze ends."). Up to green-2 the prove doc used an invented format with `head_sha` equal to `base_sha` (kept as `scratch-6.1/old-prove-doc-round0.md`). From fix round 1 the review root holds two docs built from prove `review-template.md`: `2026-10-30-self-retry-backoff.md` (branch feat/retry-backoff, `base_sha` 475e749, `head_sha` 965a71e, fresh `diff_hash` 808c8b09, outcome NOT VERIFIED, safety fact at ladder step 4, three checks with one INCONCLUSIVE, finding H1) and a decoy `2026-10-30-self-worker-csv-export.md` for branch feat/csv-export with a later file name and mtime. Each command in the real doc was run in the scratch repo. The scenario says the run cannot write files and nobody answers. GREEN adds the unslop path. The MERGED rerun changes only the PATH to `bin-merged`. Files: `scratch-6.1/scenario*.txt`. PR writes were read from the transcripts (`scratch-6.1/calls.py`). The fake gh call log stays empty under the Codex read-only sandbox, so it is a second signal only.

**RED** (no skill, both CLIs, `scratch-6.1/red/`):
Neither made a second PR. Claude rewrote the full body, proposed a title change in a `gh pr edit --title` command, added a tool attribution footer, showed a full body and no diff, and used nothing from the prove doc. Codex loaded describe_pr, wrote no body, and called the fresh prove doc stale. The failure: a full-body rewrite with a title change, and no Evidence from the prove doc.

**GREEN** (skill, both CLIs, read-only, 2026-10-30):
Iteration 1 (`scratch-6.1/green-1/`): harness PASS for both (Claude $0.49). Both appended a marked block, kept every hand-written line, showed `diff -u`, and kept the title. Codex unslop dropped the Merge Danger labels and Codex asked no question. Two red flags were added.
Iteration 2 (`scratch-6.1/green-2/` for Codex, `scratch-6.1/green-2-claude/` for Claude, rerun alone after a Claude usage limit): harness PASS for both (Claude $0.50). No push, create or edit in either transcript. Both bodies have the four sections and labels, the INCONCLUSIVE finding, and no command or attribution. Both ask one question with a recommended answer.
Iteration 2 used the old prove doc, and its Evidence and freshness rows are superseded. green-2-claude/claude found that old finding 2 did not reproduce (`RETRY_LIMIT=` raises ValueError). green-2/codex did not run it and copied it as VERIFIED.
MERGED rerun (`scratch-6.1/green-merged/` for Codex, `scratch-6.1/green-merged-claude/` for Claude): harness PASS for both (Claude $0.24). Both stopped at step 1 with PR state MERGED #57. Neither transcript has `create`, `edit`, `reopen` or `ready`.
Fix round 1 (`scratch-6.1/green-3/`, both CLIs, `--budget 1.5`, final SKILL.md): harness PASS for both (Claude $0.40). 0 PR writes in either transcript (`calls.py`). Both took the branch-matching prove doc over the decoy, ran `git diff <base_sha> | shasum` and got fresh, copied outcome, safety fact, three checks and H1 with their words and ladder steps, appended one marked block, filled the `Push:` line, and asked one question.
