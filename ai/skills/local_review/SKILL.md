---
name: local_review
description: Set up worktree for reviewing colleague's branch
---

# Local Review

You are tasked with setting up a local review environment for a colleague's branch.
This command is **repo-agnostic** — it auto-detects the repository.

## Process

When invoked with a parameter like `gh_username:branchName`:

1. **Parse the input**:
   - Extract GitHub username and branch name from the format `username:branchname`
   - If no parameter provided, ask for it in the format: `gh_username:branchName`

2. **Extract ticket information**:
   - Look for ticket patterns in the branch name (e.g., `eng-1696`, `ENG-1696`, `fr-400`, `FR-400`, `sales-332`)
   - Use this to create a short worktree directory name prefixed with `review/`
   - If no ticket found, use `review/<sanitized-branch-name>`

3. **Determine the repo name**:
   - Auto-detect from current git repository: `basename $(git rev-parse --show-toplevel)`

4. **Set up the remote and fetch**:
   - Check if the remote already exists: `git remote -v`
   - Prefer using remote 'origin'
   - If not, add it: `git remote add <USERNAME> git@github.com:<USERNAME>/<REPO_NAME>.git`
   - Fetch from the remote: `git fetch <USERNAME>`

5. **Create the worktree**:
   - create a worktree at ~/wt
   - This handles all setup: thoughts symlink, .claude config, .env, dependency installation

## Error Handling

- If worktree already exists, inform the user they need to remove it first
- If remote fetch fails, check if the username/repo exists
- If dependency installation fails, provide the error but the worktree is still usable

## Example Usage

```
/local_review mamghaderi:FR-400-new-feature
```

This will:
- Auto-detect the current repo name
- Add 'mamghaderi' as a remote (if not already present)
- Create worktree at `~/wt/<repo-name>/review/fr-400`
- Set up the full environment (thoughts, .claude, .env, deps)
