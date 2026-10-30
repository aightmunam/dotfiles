# Capsule Template

`handoff` writes this document. `recall` gives the same contract in chat. Both skills use this file.

## Tags

Each thread line starts with exactly one tag. Run the check before you write the tag. `<base>` is the branch that the PR merges into, usually `main`.

| Tag | Write it only when this check shows it |
|---|---|
| `[merged #N]` | `gh pr view N --json state,mergedAt` shows `MERGED`. No revert of #N: `git log <base> --oneline -E --grep "#N([^0-9]|$)" --grep "This reverts commit"` and `gh pr list --state all --search "Revert"` show none. The two `--grep` flags match any revert, so read each hit and keep only reverts of #N. |
| `[open PR #N]` | `gh pr view N --json state` shows `OPEN`. |
| `[in flight <branch>]` | The branch has commits or changes, and no PR is open or merged for it. Unchecked changes also get this tag. |
| `[verified, uncommitted]` | `git status --short` shows the change. You ran its check in this session and the check passed. The check fails on the old code and passes on the new. A check that passes on the old code is not its check. Name the command. |
| `[reverted #N]` | `git log <base>` shows a commit that reverts #N. N is the PR that the commit reverted. Name the revert PR or commit on the line. |
| `[planned, not started]` | No branch, commit, or PR matches the thread. Name the searches: `git branch -a`, `git log --all --grep`, `gh pr list --state all`. |

- A local branch that exists is not a status. A branch whose PR merged gets the PR tag.
- A merged PR that a later commit reverts gets `[reverted #N]`, not `[merged #N]`.
- A branch with an open or merged PR gets the PR tag. Write its uncommitted changes in the line text.
- If `gh` fails, use the merge commits in `git log <base>`. Write the `gh` failure under Problems.
- Session memory, user notes, and an earlier capsule are candidates. When a check disagrees, write what the check shows.

## Document

```
# Handoff: <topic>

State: <repo> on <branch> at <short HEAD SHA>[; <repo> on <branch> at <short HEAD SHA>]..., <YYYY-MM-DD HH:MM zone>

## Capsule
- <at most 5 bullets: what this work is and where it stands overall>

## Threads
- <tag> <thread in one line>. Evidence: <evidence>.

## Problems
- <at most 5: a symptom that recurs, or a fix that shipped and was reverted, with the reason>. Source: <evidence>.

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
- `State:` lists each repo and branch in scope, one entry per repo, separated by `;`.

## Evidence Forms

`<evidence>` in Threads and `Source:` in Problems use one or more of these forms, separated by `;`. A thread with a tag must include the Command form.

| Source | Form | Example |
|---|---|---|
| Command | `` `<command>` -> <output> `` | `` `gh pr view 41 --json state` -> MERGED `` |
| PR | `PR #<N>` | `PR #44` |
| Commit | `commit <short SHA>` | `commit 0f26dce` |
| Ticket | `ticket <ID>` | `ticket ENG-2166` |
| Chat | `chat <uuid>`: the transcript file name without `.jsonl`, 8-4-4-4-12 hex | `chat 3f2a9c1e-7b4d-4e2a-9c1f-0a1b2c3d4e5f` |
| Chat permalink | `permalink <URL>` | `permalink https://acme.slack.com/archives/C01/p1730000000` |
| Error tracker | `issue <tracker>:<ID>` | `issue sentry:BILLING-1A2` |
