---
name: review-pr
description: Use when the user asks you to review a colleague's PR or someone else's branch, read-only. Use when the user asks for an API review of a PR against the Zalando rules. Use when The Eye starts a PR review.
---

# Review PR

## Definitions

- **PR:** a pull request of another person. The argument is a PR URL, a number (`123` or `#123`), or `user:branch`.
- **Diff:** the output of `gh pr diff <number>`, saved once to a file.
- **Lens:** one review angle. Each lens is a brief in `lenses.md`.
- **Ladder:** 1 you said so. 2 you cite the file and line. 3 you trace the failure path through the code. 4 you ran real code. 5 you reproduced it in the running app.
- **Finding:** one problem with a file and line, a ladder step, and a severity (critical, high, medium, low).

## The Loop

If a `report_progress` tool exists, call it at the start of each step: `step` is the step number, `total` is 7, `label` is the step name. Never wait for input. With no argument, write the three argument forms and stop.

1. **PR info.** Run `gh pr view <number> --json number,title,body,headRefName,headRefOid,author,files,additions,deletions,commits`.
2. **Environment.** Use the `local_review` skill with `user:branch`. It makes a worktree under `~/wt/<repo>/review/<name>`. Review that worktree, not your current directory. Write one line with the branch, the repo, and the worktree path.
3. **Walkthrough.** Save the diff. Do not use `git diff main...HEAD`, because a stale local `main` adds unrelated changes. Send the What brief and the How brief from `lenses.md` to two `reviewer` agents in one message.
4. **Code review.** First read `lenses.md` and each principle file: ~/.agents/principles/fix-root-causes.md, ~/.agents/principles/boundary-discipline.md, ~/.agents/principles/minimize-reader-load.md, ~/.agents/principles/model-the-domain.md, ~/.agents/principles/test-behavior-not-implementation.md. You use them to merge the findings. Send each lens that `lenses.md` marks "always" and each lens whose predicate matches, in one message. Each prompt has the common header, the lens brief, the diff path and the changed files. Add the code excerpts that the lens needs to judge without a guess. Send the lenses also for a small diff. A small diff does not make a lens unnecessary. If an agent returns no work, send it again. Merge the findings: one finding per cause, more weight when two lenses report it. When two lenses disagree, read the code and decide. Only after that, read the PR comments with `gh pr view <number> --comments`. A finding that you take from a comment names its author.
5. **Automated checks.** In the worktree, run the lint and unit tests from `~/dotfiles/ai/test-cards/<repo>.md`. If that file is missing, use the repo config and say so. For a suspect finding, you can run one targeted command that shows the failure. Put it in `# Automated checks` as its own row. Record each command and its exit code. Do not pipe a test command into `tail`, and do not add `|| true`.
6. **Write-up.** Read `review-template.md` and fill it. The doc goes in `<review root>/YYYY-MM-DD-pr-<number>-<title>.md`. The review root is `$(readlink thoughts/shared)/reviews`. Create it if it is missing. Do not write the doc with a shell heredoc. A shell hook removes each line that starts with `#`. If you cannot write files, put the full doc in your answer and name its path.
7. **Sync.** Run `humanlayer thoughts sync`. Run `open "http://review:6937/r/<slug>"`. The slug is the file name without `.md`. Reply with the reply template.

## Roles

Each brief goes to a `reviewer` agent. If no `reviewer` type exists, send a general-purpose agent the brief and the reviewer rules from `lenses.md`. With no dispatch tool, do each brief yourself, one at a time.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.
- Never post to GitHub. Do not run `gh pr comment`, `gh pr review`, a `gh api` write, or `git push`.

## Rules That Shape Findings

- **Each finding has a ladder step.** A lens finding is step 2 or 3. Ladder step 4 needs a command from Loop step 5 and its output. Never claim ladder step 5.
- **No unfinished research.** If the code that decides a finding is readable, read it first. Do not write "if X handles it, this is fine".
- **Intended breakage is not a finding.** When the PR goal is the break, skip it, unless the author may not see the full impact.
- **Severity is honest.** A high or critical finding needs a traced failure path.
- **Verdict.** Any critical or high finding gives `request_changes`. Else give `approve` or `comment`.

## Red Flags

- A lens that refused its topic or did no work. Go back to step 4.
- A finding with no ladder step, or step 4 with no command. Go back to step 4.
- A finding that you took from a PR comment with no author. Go back to step 4.
- A doc that breaks a format rule in `review-template.md`. Go back to step 6.
- A `gh` write command or a push in your plan. Stop. Remove it.
- No `Principles applied:` line, or a principle file that you did not open. Go back to step 4.
- You did the lenses yourself, but a dispatch tool exists. Go back to step 4.

## Reply Template

```
Review: <doc path>
Viewer: http://review:6937/r/<slug>
Verdict: <approve | request_changes | comment>
Findings: critical <n>, high <n>, medium <n>, low <n>. Ladder steps: 2 <n>, 3 <n>, 4 <n>
Lenses: <lens names that ran>. Comments used: <authors, or none>
Local only: nothing was posted to GitHub and nothing was pushed.
Principles applied: <name> -> <choice it changed>     (one line for each principle file you opened)
```
