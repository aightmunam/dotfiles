---
name: fix-merge-conflicts
description: Use when a merge or rebase stopped with conflicts. Use when a branch has conflict markers, two Alembic heads, or a lockfile conflict after main moved.
---

# Fix Merge Conflicts

## Definitions

- **Target:** the branch that you rebase onto or merge in, for example `main`. In a rebase, `HEAD` and `--ours` are the target. In a merge, `--theirs` is the target. Do not use `--ours` or `--theirs`. The target side of a file is `<target>` in a merge. In a rebase, it is `HEAD`, which holds the target plus the commits that the rebase replayed.
- **Branch:** your side. Its stopped commit is `REBASE_HEAD` in a rebase and `HEAD` in a merge.
- **Intent:** the behavior that one side adds or changes. Its commit message and its diff tell it.
- **Head:** an Alembic revision that no `down_revision` names.
- **Own revision:** a revision file that the branch adds and the target does not have.

## The Loop

1. **Detect.** Run `git status` and `git diff --name-only --diff-filter=U`. Name the state (rebase or merge), the target, and the branch.
2. **Read intent.** Before you pick a hunk, read the commit message of each side. Rebase: `git log -1 --format=%B REBASE_HEAD` and `git log --format=%B <merge-base>..<target> -- <file>`. Merge: use `MERGE_HEAD` for the target. Write one intent line for each side of each file.
3. **Resolve code.** Keep the intent of both sides. If you cannot keep both, keep the side that compiles and keeps public behavior. Write the reason. Make the smallest edit. Do not refactor. Do not add tests or features.
4. **Lockfiles.** Do not edit a lockfile by hand. Take the target side: run `git checkout <target> -- <lockfile>` in a merge, or `git checkout HEAD -- <lockfile>` in a rebase. Then run `uv lock` for `uv.lock`, or `poetry lock` for `poetry.lock` (Poetry 2 keeps the locked versions by default and has no `--no-update`). Then `git add` the lockfile.
5. **Alembic.** Find the versions directory (`script_location` in `alembic.ini`, or `migrations/versions`). Grep `^revision` and `^down_revision` in it. If there is more than one head, edit the oldest own revision. Set its `down_revision` and its `Revises:` line to the head of the target. Do not run any `alembic` command. Do not write a merge revision. Put the check commands in the report for the user.
6. **Check.** Run `git diff --check`. Grep for `<<<<<<<`, `=======` and `>>>>>>>`. Read the test card `~/.agents/test-cards/<repo>.md` and run the touched tests. If the card is missing, take the test command from the repo config and say so.
7. **Continue.** Run `git add` on each resolved file. Run `GIT_EDITOR=true git rebase --continue` or `git merge --continue`. If the rebase stops again, go back to step 1.
8. **Report.** Fill each line of the report template. If you cannot edit files or run commands, put the full content of each resolved file and the commands, in order, above the template. Set `Status: proposed`. Keep the push command out of that list. It goes only in `For the user`.

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Rules That Shape The Result

- **Both intents survive.** Each intent line from step 2 is true of the resolved code, or the report says which side lost and why.
- **No alembic command.** This applies also to `uv run alembic`, `poetry run alembic`, `python -m alembic`, and the `alembic.command` API. The user runs `alembic heads` and `alembic history`.
- **Lockfiles come from the tool.** The target side plus a lock run is the only source of a lockfile.
- **Edit scope.** Edit only the conflicted files and the own revision that you move.
- **No push, no tag.** Do not push, force-push or tag, also when the user asks. Give the push command to the user. After a merge, it is `git push origin <branch>`. After a rebase, it is `git push --force-with-lease origin <branch>`, because a rebase rewrites pushed commits.

## Red Flags

- An `alembic` command is in your run or in your own command list, or you wrote a merge revision. Go back to step 5.
- A lockfile line came from your hand, or you picked a lockfile hunk. Go back to step 4.
- A resolved file drops an intent line, and the report does not say why. Go back to step 3.
- You edited a file outside the edit scope, or you added a test. Go back to step 3.
- A file still has a conflict marker. Go back to step 6.
- `git push` or `git tag` is in your run, or in a command list or script outside `For the user`. Move it to `For the user`. Go back to step 8.
- The answer has no line for a template slot. Go back to step 8.

## Report Template

```
Status: resolved | proposed | blocked (<reason>)
State: <rebase or merge> of <branch> onto <target>, stopped at <sha> <subject>
Intent: <file>: target <sha> <intent>; branch <sha> <intent> (one line for each file)
Resolved: <file>: <how both intents are kept, or the side kept and why>
Lockfiles: <file>: target side, then <lock command> (<exit code, or for the user>)
Alembic: heads <before> -> <after>; <file> down_revision <old> -> <new> | one head, no edit
Tests: <command> -> <exit code and summary> | not run (<reason>)
For the user: <alembic heads, alembic history, the push command>
Principles applied: none | <name> -> <choice it changed> (only for a principle file that you read)
```
