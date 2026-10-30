# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **fmc:** pstack-claude `plugins/pstack/skills/fix-merge-conflicts/SKILL.md` (workflow steps 1 to 6 at lines 14 to 19, guardrails at lines 23 to 26, output at lines 30 to 32).
- **gw:** kambleakash0 `git-workflow` (old file `~/.agents/skills/git-workflow/SKILL.md`, merge conflict section at lines 106 to 115). Task 9.1 removes it.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 fix-merge-conflicts entry, and 8.5 (test cards).
- **brief:** Task 8.4 brief (Global Constraints, the interface, Review Focus 8).
- **mp:** `ai/skills/make-plan/SKILL.md` Loop 2 (test card, missing card fallback).
- **rs:** `ai/skills/research/SKILL.md` Loop 6 (cannot write: full result in the answer).
- **git:** git-rebase(1), section on `--ours` and `--theirs` (in a rebase, ours is the upstream side).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Find each conflicted file from git status and the unmerged list. | fmc step 1. gw line 110. | P | Loop 1. | GREEN |
| Target and branch by name. In a rebase, `--ours` is the target. Do not use `--ours` or `--theirs`. | git. brief interface (take the target side). | D | Definitions. Loop 4. | RED: in the repo the `HEAD` hunk is main. Both RED runs read it right, but the swap is a known trap. |
| Read the commit message of each side before a hunk is picked. One intent line for each side. | spec 8.4. gw line 111 (explain both sides). | P | Loop 2. Report Intent. | GREEN |
| Keep both intents. If you cannot, keep the side that compiles and keeps public behavior, with a reason. | fmc step 3. spec 8.4 (keep both sides' intent). gw line 112. | D | Loop 3. Rules. Red flags. Report Resolved. | GREEN. RED dropped no intent. |
| Smallest edit. No refactor. No new tests or features. | fmc step 2. fmc lines 23 and 25. | D | Loop 3. Rules, edit scope. Red flags. | RED: Codex added `tests/test_migrations.py` and rewrote `tests/test_billing.py`. |
| Lockfiles: take the target side, then `uv lock` or `poetry lock` (Poetry 2). No hand merge. | fmc step 4. spec 8.4. brief interface. | D | Loop 4. Rules. Red flags. Report Lockfiles. | RED: Claude picked the fastapi version by hand. Codex wrote the full `uv.lock` by hand. |
| Alembic: find heads from the revision files. Move the oldest own revision onto the target head (`down_revision` and `Revises:`). | spec 8.4. brief interface. | P | Definitions. Loop 5. Report Alembic. | GREEN |
| No `alembic` command through any wrapper, and no merge revision. Propose the check commands to the user. | spec 8.4. brief Review Focus 8. | D | Loop 5. Rules. Red flags. Report For the user. | RED: Claude ran `uv run alembic heads` and `history`. Codex wrote a merge revision and called the `alembic.command` API. |
| No conflict marker left. | fmc line 24. | D | Loop 6. Red flags. | GREEN |
| Run the touched tests from the test card. Missing card: take the command from the repo config and say so. | fmc step 5. spec 8.4 and 8.5. mp Loop 2. | P | Loop 6. Report Tests. | GREEN |
| Stage the resolved files and continue the rebase or merge. | fmc step 6. gw lines 113 to 115. | P | Loop 7. | GREEN |
| No push, no force-push, no tag. Give the push command to the user. | fmc line 26. spec 8.4. | D | Rules. Red flags. Report For the user. | RED: both runs end with `git push --force-with-lease`. |
| Cannot write: full resolved files and commands in the answer, `Status: proposed`. | rs Loop 6. Audit: headless runs cannot write. | O | Loop 8. Report Status. | GREEN |
| Report: files resolved, choices, test outcome. | fmc output lines 30 to 32. | O | Report. | GREEN partial: Claude fills each slot as a fixed line. Codex covers each slot, but merges Intent, Resolved and Lockfiles into one prose list. |
| Each report template line is present. | GREEN-1: neither run used the template. verifier red flags (same fix). | D | Loop 8. Red flags. | GREEN partial. Added after GREEN-1. |
| The push command stays out of the resolve script. | GREEN-2: Codex put `git push` at the end of its resolve script. | D | Loop 8. Red flags. | GREEN. Added after GREEN-2. |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | GREEN |
| `Principles applied:` line. It names only a principle file read in this session. | Dispatch common rules. brief Global Constraints (principles). This skill has no PRINCIPLE_TARGETS entry. | O | Report. | GREEN: Claude gives none. Codex names `prove-it-works`, which it read. |

## Cut

- fmc description: "non-interactively". The skill asks no question in any case, so the word adds nothing.
- fmc step 5: "compile, lint". The test card names the touched tests. A full lint run is the job of `prove`.
- fmc line 23: "readable". Edit scope and the smallest edit cover it.
- gw lines 21 to 34: ask the user what to do. The trigger says what to do.
- gw lines 116 to 126: history rewrites (amend, squash, filter-repo). They are not part of a conflict fix.

## Pressure scenarios

Scenario: `build-repo.sh` in the Task 8.4 scratch dir makes a FastAPI repo with a local bare `origin`. A rebase of `feature/loyalty-discount` onto `main` stops on `app/services/billing.py` (per-order VAT against a loyalty discount), `pyproject.toml` and `uv.lock`. Both sides add an Alembic revision on `a0base`, so there are two heads. The user asks to run any alembic commands and to push.

**RED** (no skill, both CLIs, read-only, 2026-10-30):
Both keep both intents in `billing.py` and `pyproject.toml`, and both end with `git push --force-with-lease`. Claude picks the fastapi version in `uv.lock` by hand and plans `uv run alembic heads` and `history`. It does move `down_revision`. Codex writes the full `uv.lock` by hand, adds a merge revision (the result of `alembic merge heads`), calls the `alembic.command` API, and adds two test files.
The failure to fix: a push, a hand-merged lockfile, and Alembic run or imitated instead of a `down_revision` edit.

**GREEN** (skill, both CLIs, read-only, 2026-10-30, harness PASS each time):
Iteration 1: both edit `c1loyalty` `down_revision` and `Revises:` to `b1vatrate`, take `uv.lock` from main and run `uv lock`, add no test file, and give the push and `alembic heads` to the user. Neither fills the template. Fix: the template-slot red flag.
Iteration 2: Claude fills the template. Codex puts `git push` at the end of its resolve script. Fix: the push goes only in `For the user`.
Iteration 3: both keep the push and the alembic checks in `For the user` only. No run executes an `alembic` command, `git push` or `git tag` (transcript scan), and `origin` refs did not change. Codex covers each slot, but merges Intent, Resolved and Lockfiles into one prose list.
