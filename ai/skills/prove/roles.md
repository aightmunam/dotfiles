# Adversary Roles

Two blind adversaries try to break the change: one Claude, one Codex. Each gets the diff, the plan, the task, and the intent. Do not give them your reasoning, your checks, or your findings.

## Set up each worktree

For adversary `<n>` (1 is Claude, 2 is Codex), run from the repo root:

```
git worktree add --detach ~/wt/<repo>/prove-<n> <base_sha>
git diff --binary <base_sha> | git -C ~/wt/<repo>/prove-<n> apply
git -C ~/wt/<repo>/prove-<n> add -N .
git -C ~/wt/<repo>/prove-<n> diff | shasum
```

The worktree then holds the same change as `git diff <base_sha>`. The `add -N` line makes the diff show new files. The last hash must equal `diff_hash`. If it differs, the worktree is wrong. Fix it before the dispatch.

## Dispatch

Send both in one message.

- **Claude:** a general-purpose agent. On Codex, run `claude -p "<brief>"` from `~/wt/<repo>/prove-1`.
- **Codex:** run `codex exec -C ~/wt/<repo>/prove-2 -s workspace-write "<brief>"`. On Codex, spawn an agent in that worktree.

## Brief

> Break this change. The worktree `<path>` is at `<base_sha>` with the diff applied (`diff_hash` `<hash>`). The intent: `<one sentence>`. The plan: `<path>`. The task: `<text>`.
> Prove each finding with a run against the real code: a failing test, a repro script, or a command whose output shows the wrong behavior. Look past the diff: callers, data files, wire formats, DB columns, flags.
> Keep repros in your worktree. Do not touch any other directory.
> For each finding, report a title, the exact command, the output that it printed, and the output that the intent needs. Leave out anything that you did not run: style, names, structure, and risks that need a future change.
> No findings is a valid result. Give your model name on the first line.
> never touch a prod Salesforce org, not even --help. No alembic upgrade or downgrade, and no DB mutation. Do not read .env files.

## Fallback

You cannot make a worktree, or you have no dispatch tool and no shell for the other CLI: do the brief yourself after step 3. Use only the diff, the plan, and the task. Write `adversary: inline (<reason>)` in the doc. Add a flag for it under `# Attention`.

One adversary fails or gives no result: go on with the other. Write the gap under `# Attention`. A missing adversary is not a pass.

## Cleanup

After step 5, run `git worktree remove --force ~/wt/<repo>/prove-<n>` for each worktree. Keep each repro that a finding uses: copy it into the doc first.
