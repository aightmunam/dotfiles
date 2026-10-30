# Capsule Template

`handoff` writes this document. `recall` gives the same contract in chat. Both skills use this file.

## Tags

Each thread line starts with exactly one tag. Run the check before you write the tag. `<base>` is the branch that the PR merges into, usually `main`.

| Tag | Write it only when this check shows it |
|---|---|
| `[merged #N]` | `gh pr view N --json state,mergedAt` shows `MERGED`. `git log <base> --oneline --grep "#N"` shows no revert of #N. |
| `[open PR #N]` | `gh pr view N --json state` shows `OPEN`. |
| `[in flight <branch>]` | The branch has commits or changes, and no PR is open or merged for it. Unchecked changes also get this tag. |
| `[verified, uncommitted]` | `git status --short` shows the change. You ran its check in this session and the check passed. Name the command. |
| `[reverted #N]` | `git log <base>` shows a commit that reverts #N. N is the PR that the commit reverted. Name the revert PR or commit on the line. |
| `[planned, not started]` | No branch, commit, or PR matches the thread. Name the searches: `git branch -a`, `git log --all --grep`, `gh pr list --state all`. |

- A local branch that exists is not a status. A branch whose PR merged gets the PR tag.
- A merged PR that a later commit reverts gets `[reverted #N]`, not `[merged #N]`.
- If `gh` fails, use the merge commits in `git log <base>`. Write the `gh` failure under Problems.
- Session memory, user notes, and an earlier capsule are candidates. When a check disagrees, write what the check shows.

## Document

```
# Handoff: <topic>

Checked: <repo> on <branch> at <short HEAD SHA>, <YYYY-MM-DD HH:MM zone>

## Capsule
- <at most 5 bullets: what this work is and where it stands overall>

## Threads
- <tag> <thread in one line>. Evidence: `<command>` -> <result>.

## Problems
- <at most 5: a symptom that recurs, or a fix that shipped and was reverted, with the reason>. Source: <PR #, commit SHA, or command>.

## Next move
<one concrete action: the command, file, or skill, and the thread that it moves>

Principles applied: prove-it-works -> <the tag or claim that a check changed>
```

## Rules

- Order: Capsule, Threads, Problems, Next move. Put more detail below them, or cut it.
- Capsule: at most 5 bullets.
- Threads: one line each. Each line has exactly one tag and its evidence.
- Problems: at most 5. Put each reverted fix here with its reason, so the next attempt starts where the last attempt failed.
- Next move: one action. Not a list.
- An adjacent feature or ticket stays out, unless it blocks this work.
- When the capsule and the thread lines are longer than one screen, cut detail. Do not cut threads.
- `recall` cites a chat finding by its chat UUID in the evidence slot.
