# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **pocock:** mattpocock-skills `skills/engineering/pr/SKILL.md` (body template: Summary, Evidence, Merge Danger; the Summary visual menu; Evidence before and after; one-way and two-way door; blast radius).
- **mper:** pstack-claude `plugins/pstack/skills/make-pr-easy-to-review/SKILL.md` (workflow steps 2 and 3, History Cleanup, Reviewer Guidance, Guardrails).
- **deslop:** pstack-claude `plugins/pstack/skills/deslop/SKILL.md` (focus areas, in the Python form that spec 8.4 gives).
- **tw:** pstack-claude `plugins/pstack/skills/technical-writing/SKILL.md` line 93 (a PR body is a one-minute briefing; link, do not paste).
- **dpr:** `ai/skills/describe_pr/SKILL.md` step 1, the repo PR template lookup. Nothing else.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 pr entry (flow, existing PR, closed or merged PR, body rules, runbook exception, regroup), section 8.4 prove entry and section 12 (prove doc fields), section 8.4 unslop entry (`pr` may point to unslop).
- **brief:** task 6.1 brief (interfaces, Review Focus 4 and 7) and the Global Constraints (four repo lines, OK only for main/master and prod).
- **unslop:** `ai/skills/unslop/SKILL.md` (output contract: one change line for each changed pattern).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (the form bar).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "tpl" is `description-template.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Get the PR state with `--state all`. None, OPEN, MERGED or CLOSED. | spec 8.4 (`gh pr view` returns one for the branch). dpr step 2 (check for a PR on the branch). | P | Definitions. Loop 1. | GREEN-2: both ran `gh pr list --head feat/retry-backoff --state all`. |
| A MERGED or CLOSED PR with no OPEN PR: stop and report. No create, edit, reopen or ready. | spec 8.4 ("stop and report, do not reopen"). brief Review Focus 4. | D | Loop 1. Output template (a stop fills PR state and Question). | GREEN-merged: both stopped at step 1. Neither transcript has `gh pr create`, `edit`, `reopen` or `ready`. |
| PR exists: no second PR. | spec 8.4. | D | Loop 1. Red flags. | GREEN-2: no `gh pr create`. RED also made no second PR, so this run shows the rule holds, not a fix. |
| On main or master, stop. | Global Constraints (a push to main/master needs the user's OK). | D | Loop 1. | Untested. The branch in the scenario is a feature branch. |
| Read log and diff from the merge base. | mper workflow step 2 (inspect commits, diff size, paths). | P | Loop 2. | GREEN-2: both read the merge-base diff. |
| Repo PR template lookup: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `thoughts/shared/pr_description.md`. Its headings win. | dpr step 1. | P | Loop 2. tpl. | Untested. The scratch repo has no template. |
| Prove doc: newest `kind: self-review` file in `thoughts/shared/reviews/`. Fresh when `git diff <head_sha> HEAD \| shasum` equals `diff_hash`. | spec 8.4 pr (Evidence from the prove doc). spec 8.4 prove and section 12 (`base_sha`, `head_sha`, diff hash, `kind: self-review`, review root). task 5.1 brief (`diff_hash` is `git diff \| shasum`). | P | Definitions. Loop 2. | GREEN-2: both found the doc and ran the hash check (fresh). RED Codex called the same doc stale. |
| Reviewability pass: noisy commits, stale description, unrelated changes, mixed mechanical and logic changes, missing tests, unclear entry point. | mper workflow step 3. spec 8.4. | P | Loop 3. Output template. | GREEN-2: both flagged the unrelated lockfile commit and the missing raising-job test. |
| Too large for notes: stop and recommend a split. | mper Guardrails. spec 8.4. | D | Loop 3. | Untested. The scenario diff is small. |
| Deslop check in Python form: bare `except`, `None` check after a boundary check, narration comment. Report `path:line`. Do not change code. | deslop focus areas. spec 8.4 (Python form). mper (reviewability without behavior changes). | P | Loop 4. Red flags. Output template. | GREEN-2: both reported `worker/retry.py:19` (bare `except`) and `worker/retry.py:10` (narration comment), and changed no code. |
| Body template: `TL;DR`, Summary, Evidence, Merge Danger with door, blast radius and rollback. | pocock template. spec 8.4 (adds rollback). mper Reviewer Guidance (`TL;DR`). | O | Loop 5. tpl. | GREEN-2: both bodies have all four sections and the three Merge Danger labels. |
| Summary: the smallest visual that makes the point. | pocock Summary and Guidance. | P | tpl. | GREEN-2: Claude a diff sketch, Codex pseudocode. |
| pr block markers. `pr` writes only between them. All other text is hand-written. | brief Review Focus 7 (only add or update its own sections). spec 8.4 (keep text added by hand). | D | Definitions. Loop 6. tpl. Red flags. | GREEN-2: both appended one marked block. Every hand-written line is unchanged in the diff. |
| Run unslop on the prose of the block. | spec 8.4 unslop entry (`pr` body may point to it). brief interfaces. | P | Loop 5. Roles. Output template. | GREEN-2: both read unslop `SKILL.md` and `rules.md` at the given path. |
| Show before any write. New PR: title and full body. OPEN PR: `diff -u` of current and new body. | spec 8.4 (show it, then on OK; show the new body as a diff). brief manual check. | P | Loop 6. Output template. | GREEN-2: both showed `diff -u` with one append-only hunk. RED Claude showed a full new body. The scenario asks for any body in the answer, so showing is partly forced. The diff form is not. |
| One question with a recommended answer. | Controller ruling (one question per message, with a recommended answer). | O | Loop 8. Output template. | GREEN-2: both. GREEN-1 Codex had no question. The red flag came before GREEN-2. |
| Push and `gh pr create --draft`, or `gh pr edit --body-file`, only after the user's OK. | spec 8.4 flow. | D | Loop 9. Red flags. | Partial. GREEN-2 transcripts have no push, create or edit, and both named the OK. Plan mode and the read-only sandbox also block writes, so this is not clean GREEN evidence. |
| Read the body back after a write. | dpr step 9 ("Confirm the update was successful"). | P | Loop 9. | Untested. No run reached a write. |
| One-minute briefing. Link logs and tables, do not paste them. | tw line 93. spec 8.4. | D | Rules. Red flags. | GREEN-2: both bodies link the prove doc and paste no log. |
| No commands in the body, except a `data-op` runbook PR. | spec 8.4 (runbook exception). brief interfaces. | D | Rules. Red flags. | GREEN-2: neither body has a command. RED Claude put no command in the body but proposed a `gh pr edit --title` command. |
| No attribution line, no co-author trailer. | `ai/skills/commit/SKILL.md` lines 36 to 39 (no attribution). RED: Claude added a tool attribution footer to the body. | D | Rules. | GREEN-2: no attribution line in either body. The rule wording changed during GREEN-1, before GREEN-2. |
| `TL;DR` matches the diff. Mechanical files apart from core files. | mper Reviewer Guidance. spec 8.4. | D | Rules. tpl. | GREEN-2: both list `requirements.lock` as a mechanical file. |
| No hidden behavior change under "cleanup". | mper Guardrails. spec 8.4. | D | Rules. | GREEN-2: both `TL;DR`s state the catch-all `except`. |
| Evidence from the prove doc only. Copy each status. Keep INCONCLUSIVE and NOT VERIFIED. No fresh doc: say so, recommend `prove`. | spec 8.4 pr (Evidence from the prove doc). spec 8.4 prove ("Inconclusive is not a pass"). pocock Evidence (before and after). | D | Rules. tpl. Red flags. | GREEN-2: both copied the three statuses and kept INCONCLUSIVE finding 3. RED Claude had no Evidence section. Both runs also found that finding 2 does not reproduce (a fixture slip) and flagged it, not hid it. |
| Hand-written text stays. A full new body only on the user's ask. | spec 8.4. brief Review Focus 7. | D | Rules. Red flags. | GREEN-2: Dana's note and the old `TL;DR` are unchanged. RED Claude rewrote the full body. |
| Title, draft state, reviewers, labels change only after a separate OK. | spec 8.4. | D | Rules. Red flags. | GREEN-2: no title change. RED Claude proposed a new title in its edit command. |
| New PR title: the commit subject for one commit, else the `TL;DR`. | spec 8.4 flow (`gh pr create` needs a title). The `gh pr create --fill` default (one commit gives its subject). | P | Rules. | Untested. The scenario PR exists. |
| No history rewrite by default. Regroup only on the user's ask, with the `ORIGINAL_TREE` check. Force-push needs explicit OK. | mper History Cleanup. spec 8.4. | D | Rules. | Untested. |
| Four repo lines. | Global Constraints. | D | Repo Rules. | Untested. The scenario touches no Salesforce, DB or .env. |
| Run inline. unslop fallback path. | spec 8.4 (pr runs in the chat that built the change). reply Roles (same unslop fallback). | O | Roles. | GREEN-2: both ran inline and read unslop at the given path. The fallback path is Untested. |
| Unslop keeps template headings and labels. Red flag for a missing or renamed label. | GREEN-1: Codex unslop renamed "Merge Danger" and dropped the three labels. tpl. | D | Loop 5. Red flags. | GREEN-2: Codex kept all labels. |
| Red flag: no `Question:` line. | GREEN-1: Codex ended with no question. Controller ruling (one question). | D | Red flags. | GREEN-2: both ask one question. |
| `Principles applied:` line. | spec 8.7. `pr` has no principle targets. | O | Output template. | Partial. GREEN-2 Claude wrote `none`. Codex wrote `prove-it-works`, from a user-level Codex skill it loaded. |

## Cut

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

Scenario: "Open a PR for this branch." in a scratch repo (acme/billing-worker, branch feat/retry-backoff, three commits: retry backoff with a bare `except` and a narration comment, and an unrelated lockfile bump). A fake `gh` (`scratch-6.1/fake_gh.py`) is first on PATH. It reports PR #57, OPEN, with a hand-written body (a stale `TL;DR` and the line "Ops note from Dana: deploy only after the Thursday freeze ends."). A prove doc with `kind: self-review`, `head_sha` at the merge base and a matching `diff_hash` is in `thoughts/shared/reviews/`. The scenario says the run cannot write files and nobody answers. GREEN adds the unslop path. The MERGED rerun changes only the PATH to `bin-merged`. Files: `scratch-6.1/scenario*.txt`. PR writes were read from the transcripts (`scratch-6.1/calls.py`). The fake gh call log stays empty under the Codex read-only sandbox, so it is a second signal only.

**RED** (no skill, both CLIs, `scratch-6.1/red/`):
Neither made a second PR. Claude rewrote the full body, proposed a title change in a `gh pr edit --title` command, added a tool attribution footer, showed a full body and no diff, and used nothing from the prove doc. Codex loaded describe_pr, wrote no body, and called the fresh prove doc stale. The failure: a full-body rewrite with a title change, and no Evidence from the prove doc.

**GREEN** (skill, both CLIs, read-only, 2026-10-30):
Iteration 1 (`scratch-6.1/green-1/`): harness PASS for both (Claude $0.49). Both appended a marked block, kept every hand-written line, showed `diff -u`, and kept the title. Codex unslop dropped the Merge Danger labels and Codex asked no question. Two red flags were added.
Iteration 2 (`scratch-6.1/green-2/` for Codex, `scratch-6.1/green-2-claude/` for Claude, rerun alone after a Claude usage limit): harness PASS for both (Claude $0.50). No push, create or edit in either transcript. Both bodies have the four sections and labels, the INCONCLUSIVE finding, and no command or attribution. Both ask one question with a recommended answer.
MERGED rerun (`scratch-6.1/green-merged/` for Codex, `scratch-6.1/green-merged-claude/` for Claude): harness PASS for both (Claude $0.24). Both stopped at step 1 with PR state MERGED #57. Neither transcript has `create`, `edit`, `reopen` or `ready`.
