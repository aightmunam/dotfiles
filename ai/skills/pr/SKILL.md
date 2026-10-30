---
name: pr
description: Use when your own branch is ready for a PR and the user asks to open it. Use when the PR body of your own branch needs an update.
---

# PR

## Definitions

- **PR state:** the output of `gh pr list --head <branch> --state all --json number,state,title,isDraft,url,body`. It is none, OPEN, MERGED or CLOSED.
- **Prove doc:** a file in the review root with `kind: self-review` and `branch:` equal to the current branch. Take the newest `date:`. On a tie, take the newest file. It has `outcome:`, `base_sha`, `diff_hash`, a safety fact with a ladder step, and a `# Automated checks` table with an outcome word in each Notes cell. Each finding (`### <ID> - <title>`) is NOT VERIFIED and has `_Ladder step <n>: ..._`. The review root is the target of the `thoughts/shared` link plus `/reviews`. If `thoughts/shared` is not a link, it is `thoughts/shared/reviews`. In a worktree, use the main checkout (`git rev-parse --git-common-dir`, then its parent).
- **Fresh:** the first field of `git diff <base_sha> | shasum` equals `diff_hash`. Use the `base_sha` of the prove doc. This diff includes uncommitted edits, as in `prove`.
- **pr block:** the text from `<!-- pr:start -->` to `<!-- pr:end -->` in a PR body. `pr` writes only this text. All other text in the body is **hand-written text**.

## The Loop

1. **State.** Get the branch with `git branch --show-current`. On main or master, stop. Get the PR state. MERGED or CLOSED, with no OPEN PR: stop. Fill only `PR state` and `Question` in the output template. Do not create, edit, reopen or mark ready a PR.
2. **Read.** Read `git log` and `git diff` from the merge base with the base branch. Find the prove doc. Check that it is fresh. Find the repo PR template: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md` or `thoughts/shared/pr_description.md`.
3. **Reviewability.** Look for noisy commits, a stale description, unrelated changes, mechanical changes mixed with logic changes, missing tests and an unclear entry point. If notes cannot make the PR easy to review, stop. Recommend a split. Name the commits for each part.
4. **Deslop.** Look in the diff for a bare `except`, a `None` check on a value that a boundary already checked, and a narration comment. Report each hit with its `path:line`. Do not change code in this skill.
5. **Write.** Read `description-template.md`. Fill the pr block. When the repo has a template, put the pr block content under its headings. Then run the unslop skill on the prose of the block. Keep each template heading and label as the template writes it.
6. **Show.** No PR: show the title and the full body. OPEN PR: keep the hand-written text. Replace the pr block, or add the pr block at the end. Show `diff -u` of the current body and the new body.
7. **Red flags.** Read the result once for each red flag below.
8. **Push and ask.** Run `git push -u origin <branch>`. A push to a feature branch needs no OK. If it fails, report it. Do not force. Use the output template. Ask one question. Give a recommended answer.
9. **Write to GitHub, after the user's OK only.** No PR: run `gh pr create --draft --title <title> --body-file <file>`. OPEN PR: run `gh pr edit <n> --body-file <file>`.

## Rules That Shape The Body

- **One-minute briefing.** A reviewer reads the body in one minute. Link logs, runs and tables. Do not paste them.
- **No commands.** Only a runbook PR from `data-op` has commands in its body. Its commands are its content.
- **No attribution.** Do not add a line that names a tool or a model as an author. Do not add a co-author trailer.
- **`TL;DR` matches the diff.** Each claim in it has a file in the diff. List mechanical files (an Alembic revision, a generated client, a lockfile) apart from core files.
- **No hidden behavior change.** Do not put a behavior change under "cleanup", "refactor" or "chore".
- **Evidence from the prove doc only.** Copy the `outcome:`, the safety fact with its ladder step, each check with its outcome word, and each finding with its ladder step. Keep each INCONCLUSIVE check and each finding. If the prove doc is missing or not fresh, write that in Evidence, and recommend `prove` in the question. Do not invent a run.
- **Hand-written text stays.** Do not change, move or delete hand-written text. Write a full new body only when the user asks for it.
- **Title, draft state, reviewers, labels.** On an OPEN PR, change them only after a separate OK.
- **No history rewrite.** The default flow does not rebase, squash or force-push. Regroup commits only when the user asks for it. Then record `ORIGINAL_TREE=$(git rev-parse origin/<branch>^{tree})`, regroup in the order migration, core logic, wiring, API, tests, and compare `git rev-parse HEAD^{tree}` with it. If the trees differ, do not push. A force-push needs the user's explicit OK.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- A `gh pr create` when the PR state is not none. Go back to step 1.
- A `gh pr create` or `gh pr edit` before the user's OK. Go back to step 8.
- A hand-written line is missing or changed in the new body. Go back to step 6.
- A new title, draft state, reviewer or label on an OPEN PR. Go back to step 6.
- An Evidence line with no prove doc item behind it. Go back to step 5.
- A command, a pasted log, a table or a SHA list in a body that is not a runbook. Go back to step 5.
- A template heading or label is missing or renamed (`**Door:**`, `**Blast radius:**`, `**Rollback:**`). Go back to step 5.
- The output has no `Question:` line. Go back to step 8.

## Output Template

```
PR state: <none | OPEN #<n> <url> | MERGED #<n> <url>, stopped | CLOSED #<n> <url>, stopped>
Prove doc: <path>, <fresh, diff_hash <hash> | not fresh: reason | none>
Repo template: <path | none>
Push: <pushed | up to date | failed: reason>
Reviewability:
- <one finding, or none found>
Deslop:
- `<path:line>` <pattern>, or none found
Body:
<new PR: the title and the full body. OPEN PR: the diff -u of the current and the new body.>
Unslop changes:
- <one change line, as unslop wrote it, or none, or unslop file not found>

Question: <one question>. Recommended: <answer>, because <reason>.

Principles applied: none
```

## Roles

Run inline. Do not dispatch an agent. If no `unslop` skill loads, read `SKILL.md` and `rules.md` in `~/.agents/skills/unslop/`, or in the path that the user gives. If you cannot read unslop, do its checks from memory and write "unslop file not found".
