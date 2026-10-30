---
name: address
description: Use when a reviewer asked for changes on your PR and each comment must be fixed, pushed back or answered. Use when the user asks you to address the review or the failing checks on a reviewed PR.
---

# Address

## Definitions

- **Thread:** one review comment and its replies. The first comment `id` names the thread.
- **Check:** one CI check on the PR head. A failing check is an item with no thread.
- **Class:** each item has one class. **fix:** you change the code. **push back:** you keep the code, for a reason. **ask:** only the user can decide. **done:** the head already has the change.
- **Run:** a test or a command that you ran in this session. Its output shows a claim true or false.
- **Decision item:** a security, data, migration, schema or plan change. It is always ask.
- **Round:** fix, push, then fetch the checks again.
- **Post:** any GitHub write. This includes a reply, `gh pr comment`, `gh pr review`, `gh pr ready` and a resolve mutation.

## The Loop

1. **Fetch.** Record the head SHA with `gh pr view <n> --json headRefOid,url`. Fetch all review threads with `gh api`. Fetch the failing checks with `gh pr checks <n>` and their failed logs. Read all items before you act.
2. **Test claims.** Do a run for each bug claim before you agree with it. A run that disproves the claim makes the item push back. Before a "do it properly" change, grep the callers. No caller makes the item push back.
3. **Classify.** Give each item one class. An unclear comment is ask. Do not change the code that an unclear comment touches until the answer comes.
4. **Find repeats.** When you write the same instruction a second time, encode it as a lint, a check, or a script. Read ~/.agents/principles/encode-lessons-in-structure.md before this step. Always do this step, also in round 1. Look for one pattern in two or more items, or in an earlier round. Write each repeat, or none. For each repeat, add an ask item that proposes a lint, a test or a script. Propose an AGENTS.md sentence only when no guard can hold the rule.
5. **Fix.** Fix one item at a time. Use the `tdd` skill for a behavior bug. Run the touched tests. Commit each fix and record its SHA. Quote the comment in the commit message.
6. **Draft.** Run the `reply` skill for each thread. It gives one draft. Give it the class, the run and the SHA as given facts. Draft a fix only after its commit exists. Do not draft an ask item.
7. **Count rounds.** When two fixes that share one premise fail the same gate, test the premise. Read ~/.agents/principles/attack-the-premise.md before this step. Always do this step, also in round 1. Write the premise that this round's fixes share. Push the fixes to the PR branch, then fetch the checks again. After round 3, stop. Write the premise that the failed rounds shared. Then report.
8. **Show.** Use the output template. Show all drafts and all ask items. Then wait for the user.
9. **Post.** Post each draft that the user OKs in its own thread with `gh api repos/{o}/{r}/pulls/{pr}/comments/{id}/replies -f body=...`. Never resolve a thread with no reply.

## Posting Gate

Post nothing until the user OKs that draft in this chat. This gate stays when other rules say to proceed without the user. An absent user does not give an OK.

## Hard Rules

- Do not change an expected test value to make a test pass. Change it only when the behavior changed on purpose.
- Never use `--no-verify`. Never mark a failing check as not required.
- Do not force-push without the user's OK. Never push to main or master.
- Stop after three rounds. Report each SHA.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- You agreed with a bug claim with no run. Go back to step 2.
- You changed a decision item or unclear code before the answer. Undo it. Go back to step 3.
- A fix with no touched-test run, or a commit message with no quote. Go back to step 5.
- A draft that did not come from `reply`. Go back to step 6.
- You did not read the principle file at step 4 or step 7. Go back to that step.
- An ask item with no link, change, evidence, risk or pick. Go back to step 8.
- A post before the user's OK. Stop. Tell the user what you posted.

## Output Template

```
PR <url> at `<head sha>`, round <n> of 3. <one sentence: what waits on the user, or nothing>

Waits on you:
- <link>: <what it changes>. Evidence: <run or path:line>. Risk: <risk, also when low>. Pick: <recommended answer>.

Handled:
- <link or check name>: <class>. <run and its result>. <SHA, or "pending" and the diff with its commit message>.

Repeats: <each repeat and its proposed guard, or none>
Premise: <the premise that this round's fixes share>

Drafts (nothing posted):
<the reply output for each drafted thread, without its Principles applied line>

Principles applied: attack-the-premise -> <choice it changed>, encode-lessons-in-structure -> <choice it changed>
```

## Roles

Run inline. If no `reply` skill loads, read `SKILL.md` in `~/.agents/skills/reply/`, or in the path that the caller gives. Give `reply` the `unslop` path too. If you cannot edit or commit, show each fix as a diff with its commit message. Mark it pending.
