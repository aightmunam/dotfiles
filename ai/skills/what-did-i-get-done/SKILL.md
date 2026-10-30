---
name: what-did-i-get-done
description: Use when the user asks what they got done in a period. Use when the user wants a standup or status summary of their own finished work, for yesterday, the last 3 days or this week.
---

# What Did I Get Done

## Definitions

- **Window:** the first date and the last date that the user's words resolve to. "yesterday" is the day before today. "this week" is Monday of this week to today. "last N days" is today minus N to today. Write each date as YYYY-MM-DD.
- **Repo root:** `~/Developer`, or the directory that the user names. Each directory under it with a `.git` is a repo.
- **Authored:** a commit with the user's git email as author, or a PR with the user's `gh` login as author.
- **Reviewed PR:** a PR by another person that the user reviewed. It is not authored work.
- **Item:** one authored PR, merged or opened in the window, or one authored commit in the window that no listed PR contains.

## The Loop

1. **Resolve.** Run `date`. Resolve the user's words to the window. If the words are not clear, use the most probable window and continue.
2. **Identify.** Run `gh api user --jq .login` to get the login. In each repo, run `git -C <repo> config user.email` to get the email. Do not use an email from another directory.
3. **Commits.** In each repo, run `git -C <repo> log --all --no-merges --author=<email> --since=<first>T00:00 --until=<last>T23:59:59`. Read the diff of each commit that the message does not explain.
4. **PRs.** Run `gh search prs --author=@me --merged-at=<first>..<last>`. Run it again with `--created=<first>..<last>`. Run `gh search prs --reviewed-by=@me --updated=<first>..<last>` and remove each PR with the user as author. Read the body of each PR.
5. **Merge.** Run `gh pr view <url> --json commits` for each listed PR. Put each commit that the PR contains under that PR. Remove each item that only changes format, imports or names.
6. **Describe.** Write one line for each item. Tell what changed for the users of the code. Use the PR body, the commit message and the diff.
7. **Check.** Read the answer once for each red flag.
8. **Reply.** Use the output template. The template is the full reply.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Rules That Shape Output

- Read only. Do not run `git fetch`. Do not check out, commit, push or comment.
- Put the window as real dates in the first line.
- Group the items by repo.
- Put reviewed PRs in their own section. Do not count them as done.
- Tell the effect. Do not use a file name, a path or a function name as the description.
- Do not give a reason or a goal that the PR body or the commit message does not state.
- Use one line for each item. Write no summary paragraph.
- If a source fails, say which one. Continue with the other sources.

## Red Flags

- The first line has no real dates. Go back to step 1.
- An item has a commit by another author. Go back to step 2.
- A merge commit, a commit outside the window or a format-only commit is an item. Go back to step 3.
- A PR by another person is under a repo. Go back to step 4.
- An item names a file, a path or a function to tell what it does. Go back to step 6.
- An item gives a reason that no source states. Go back to step 6.

## Output Template

```
Window: <first> to <last> (<the user's words>)

<repo>
- <what changed for users>. <merged | opened, in review | committed, no PR> <PR URL or short SHA>

Reviewed
- <repo>#<number> <what it changes for users> (author <login>)

Not read: <each repo or source that failed, or none>
```

## Roles

Run inline. Do not dispatch an agent.
