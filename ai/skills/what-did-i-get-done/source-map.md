# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **pstack:** pstack-claude `plugins/pstack/skills/what-did-i-get-done/SKILL.md`. Line numbers are in that file.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 (what-did-i-get-done entry).
- **brief:** task 8.5 brief (interfaces, the RED scenario, the failures to look for, the four repo lines).
- **agents:** `ai/AGENTS.md`, the `## Skill routing` row and the recall / what-did-i-get-done tie-break line.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Standup or status summary of the user's own finished work. | pstack :10. agents routing row and tie-break. | P | description. | Untested here. pressure-run loads the skill by name. The routing eval (Task 8.9) tests it. |
| Resolve the user's words to real dates with `date`. Words not clear: use the most probable window and continue. | pstack :14. spec ("Resolve yesterday or this week to real dates"). brief Global Constraints (never-block-on-the-human). | P | Definitions, window. Loop 1. | GREEN-1 to GREEN-3. The unclear-words branch is untested: "yesterday" is clear. |
| Put the real dates in the first line. | pstack :18, :30. spec ("state them"). brief (failure: no stated dates). | O | Rules. Red flags. Template line 1. | GREEN-1 to GREEN-3 |
| Repos are the directories with `.git` under `~/Developer`, or the directory the user names. | spec ("across the repos in `~/Developer`"). | P | Definitions, repo root. | Named-directory branch: GREEN-1 to GREEN-3. The `~/Developer` default is untested: the scenario names the directory. |
| Commits by the user's git email, read in each repo. | pstack :15. spec (`git log --author`). | P | Definitions, authored. Loop 2. Loop 3. Red flags. | GREEN-1 to GREEN-3 |
| No merge commits. | pstack :16. | D | Loop 3 (`--no-merges`). Red flags. | GREEN-1 to GREEN-3 |
| PRs merged (`--merged-at`) and opened (`--created`) by the user, from `gh`. | spec ("PRs merged, opened and reviewed by the user"). Review I1 (`--merged` is a bool in gh). | P | Loop 4. | GREEN-3. GREEN-1 and GREEN-2 ran `--merged=<date>`, which the old fake accepted and the real gh rejects. |
| Reviewed PRs in their own section. Not counted as done. | spec (reviewed PRs). brief (failure: a reviewed PR counted as authored). | D | Definitions, reviewed PR. Loop 4. Rules. Red flags. Template. | GREEN-1 to GREEN-3 |
| Read the commits of each PR with `gh pr view <url> --json commits`. Put a commit that a listed PR contains under that PR. | pstack :17 (synthesize, information-dense). Review M1. | P | Definitions, item. Loop 5. | GREEN-3: both CLIs ran `gh pr view ... --json commits`. |
| Omit format-only, import-only and rename-only changes. | pstack :24. | D | Loop 5. Red flags. | GREEN-3: both left out `19d4799`, an import sort on `main` with no PR. GREEN-1 and GREEN-2 had only a format-only commit inside PR #57, which Loop 5 absorbs, so they do not test this rule. |
| Tell the effect for users. No file, path or function name as the description. | pstack :25 ("Describe changes functionally"). spec ("what it does for users, not by file names"). brief (failure: file names as descriptions). | D | Loop 6. Rules. Red flags. | GREEN-1 to GREEN-3 |
| No reason or goal that no source states. | pstack :25 ("Do not infer intent or motivation"). | D | Rules. Red flags. | GREEN-1 to GREEN-3 |
| One line per item. No summary paragraph. | pstack :22. | O | Rules. Template. | Items: one line each in GREEN-1 to GREEN-3. Claude added an intro line in GREEN-1 and GREEN-3. Codex passed each run. |
| The template is the full reply. | pstack :29 (one short summary). Audit: GREEN-1 Claude added text outside the template. | O | Loop 8. | GREEN-2: both passed. GREEN-3: Codex passed. Claude failed: an intro line and a note on the left-out commits. |
| Group by repo. | spec ("Groups by repo"). brief interfaces. | O | Rules. Template. | RED: neither CLI grouped by repo. GREEN-1 to GREEN-3: both group by repo. |
| A failed source is named. The run continues. | brief Global Constraints (never-block-on-the-human: reversible work proceeds without a question). | O | Rules. Template, "Not read" line. | Partial. GREEN-1 and GREEN-2 (the fake had no PR commit list): Codex named it in "Not read". Claude wrote "Not read: none" and named it outside the line. GREEN-3: no source failed, so the branch did not run. |
| Read only. No `git fetch`, checkout, commit, push or comment. | spec ("Read-only standup summary"). | D | Rules. | Untested. The scenario says "You cannot write files", so the no-write part is forced. Nothing in the scenario provokes a fetch or a comment. |
| Run inline. | pstack (whole file, no dispatch step). | O | Roles. | GREEN-1 to GREEN-3: no run dispatched an agent. |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | Untested. The runs cannot write or open a DB. |

## Cut

- pstack frontmatter description: it is not "Use when" triggers.
- pstack :16 "uncommitted changes": the spec scope is commits and PRs. Excluding them needs no rule.
- pstack :23 "Prioritize substantial behavior or architecture changes": the format-only cut (:24) and one line per item cover it. A ranking rule has no test.
- pstack :31 "2-5 bullets for major changes only": a hard count drops items in a multi-repo standup. One line per item is kept.
- The `Principles applied:` line (spec 8.7): what-did-i-get-done has no principle targets, and the line is noise in a standup. Same ruling as `bro`.

## Pressure scenarios

Scenario: "What did I get done yesterday?" with two scratch repos and a fake `gh`. The files are in `scratch-8.5/` (`scenario.txt`, `build-repos.sh`, `bin/gh`). The user is `munam` with git email `munam@example.com`. The repos hold, on 2026-10-29: an authored commit with a file-name message in each repo, a format-only commit inside PR #57, a merge commit, a commit by another author and a direct commit with no PR. They hold one authored commit on 2026-10-28 and one on 2026-10-30. From fix round 1 on, they also hold an import-sort commit on `main` with no PR (2026-10-29), and the fake `gh` rejects `--merged=<date>` like the real gh, accepts `--merged-at`, checks the `search prs` JSON fields and returns `commits` from `pr view`. The fake `gh` knows PR #57 (authored, merged on 10-29), #112 (authored, opened on 10-29, title of file names), #108 (by `dana`, reviewed by `munam`, merged on 10-29) and #55 (authored, merged on 10-28).

**RED** (no skill, both CLIs, `scratch-8.5/red/`, 2026-10-30):
Neither CLI grouped by repo. Codex left out the reviewed PR #108 and did not show the date as a range. Claude stated 2026-10-29 and kept #108 apart, but described the hotline item by `SUPPORT_PHONE` and `portal/views.py`. It added a "Waiting on you" section with advice and a reason that no source states. Failure: no repo groups, a missing reviewed section (Codex), and names and invented reasons in place of effects (Claude). The first Claude RED hit the usage limit. Its output is kept as `red/claude-limit.*`, and the RED was run again after the reset.

**GREEN-1** (skill, both CLIs, `scratch-8.5/green-1/`, 2026-10-30):
Both passed the harness. Both start with `Window: 2026-10-29 to 2026-10-29 (yesterday)`, group by repo, list #57 merged, #112 in review and the hotline commit with no PR, and put #108 under Reviewed with author dana. Neither lists #55, the merge commit, the format-only commit, Dana's commits or the 10-30 commit. No item uses a file name. Claude added an intro line and a "Left out" list outside the template. Claude cost $0.33.

**GREEN-2** (skill with "The template is the full reply", both CLIs, `scratch-8.5/green-2/`, 2026-10-30):
Both passed the harness. Both answers are the template only, with the same items and sections as GREEN-1. The "Not read" line names the missing PR commit list in both. No item uses a file, path or function name. No call used a `gh` other than the fake. Claude cost $0.28.

**GREEN-3** (fix round 1: `--merged-at`, `gh pr view <url> --json commits`, new fixture; both CLIs, `scratch-8.5/green-3/`, 2026-10-30):
Both passed the harness. Both ran `--merged-at=2026-10-29..2026-10-29` and `gh pr view ... --json commits`. Both list the same items and sections as GREEN-2, with #108 under Reviewed. Both left out the format-only commits `4158efd` (in #57) and `19d4799` (on `main`). "Not read" is `none` in both, which is correct: no source failed. No call used a `gh` other than the fake. Claude again put an intro line above the template and a note below it. Claude cost $0.29.
