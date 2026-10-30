---
name: handoff
description: Use when a session ends and the next session needs its state. Use when the user asks you to write a handoff, or to save where the work stands for a later session or another agent.
---

# Handoff

## Definitions

- **Thread:** one piece of work from this session. Examples: a PR, a branch, a fix, an uncommitted change, a planned item.
- **Tag:** the status of one thread. There are six tags. `capsule-template.md` gives each tag and the check that permits it.
- **Checked:** you ran the `git` or `gh` command in this session and read its output.
- **Capsule:** the handoff document. It has four sections: Capsule, Threads, Problems, Next move.

## The Loop

**First, read `capsule-template.md`.** Your document fills it in order. Open each principle file in full with your file-read tool, not with a shell command.

1. **List.** Write each thread from this session. Include the work that failed and the work that a commit reverted. Then run `git status --short`, `git branch`, and `git log --oneline -15 <base>`. Add each change or branch that your list does not have.
2. **Check.** Check the real artifact before you say that you finished a task. Do not infer from a proxy, a self-report, or "it compiles". Read ~/.agents/principles/prove-it-works.md before this step. For each thread, run the check for its tag in `capsule-template.md`. Use `gh pr view`, `gh pr list --state all`, `git log`, and `git status`. Write the command and its result next to the thread.
3. **Tag.** Give each thread the one tag that its check shows. If your memory or the user's notes disagree with a check, use the check. Write the difference under Problems.
4. **Problems.** Write at most 5. Include each symptom that recurs and each fix that a commit reverted, with the reason from the commit or PR text.
5. **Next move.** Write one concrete action. Name the command, the file, or the skill.
6. **Write.** Put the document in `thoughts/shared/handoffs/YYYY-MM-DD-<topic>.md`. `<topic>` is kebab-case, 3 to 6 words. Create the directory if it is missing. In a worktree, use the `thoughts/` of the main checkout (`git rev-parse --git-common-dir`, then its parent). If you cannot write files, put the full document in your answer and name its path.
7. **Red flags.** Read the document once for each red flag below. Then reply with the path, the Capsule section, and the `Principles applied:` line.

## Rules That Shape the Capsule

- **No check, no tag.** A tag comes from a check in this session. A memory, a note, or an old capsule does not permit a tag.
- **One tag per thread.** Pick the tag that the check shows. A branch that exists is not a status.
- **The revert stays in.** A fix that shipped and that a commit reverted is a thread with `[reverted #N]` and a Problems line.
- **Counts are limits.** At most 5 capsule bullets. At most 5 problems. Exactly one next move.
- **Do not ask.** A fact that you cannot check is a Problems line. It is not a question to the user.
- **Write only.** Read an old capsule or a transcript with `recall`. This skill writes.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- A thread has no tag, or more than one tag. Go back to step 3.
- A tag has no command and result next to it. Go back to step 2.
- `[verified, uncommitted]` with no check that you ran in this session, or with a check that does not reach the change. Go back to step 2.
- `[merged #N]` and you did not search `git log` for a revert of #N. Go back to step 2.
- A reverted fix is not in Threads or in Problems. Go back to step 1.
- The Capsule has more than 5 bullets, or Problems has more than 5 lines. Go back to step 4.
- No next move, or more than one. Go back to step 5.
- The path is not `thoughts/shared/handoffs/YYYY-MM-DD-<topic>.md`. Go back to step 6.
- The reply has no `Principles applied:` line. Go back to step 7.
