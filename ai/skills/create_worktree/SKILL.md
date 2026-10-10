---
name: create_worktree
description: Create worktree and launch implementation session for a plan
---

# Create Worktree

You are tasked with creating a git worktree and optionally launching an implementation session.
This command is **repo-agnostic** — it auto-detects the repository name, package manager, and thoughts setup.

## Process

1. **Determine worktree parameters**:
   - Worktree name (short identifier, e.g., `fr-400` or `fix-auth-bug`)
   - Branch name (defaults to worktree name)
   - Plan file path (if launching an implementation session)

2. **Create the worktree**:
   - Run: `git worktree add ~/wt/<repo-name>/<name> -b <branch>`
   - Copy untracked env files (`.env`) from the main checkout; if the main checkout has a `thoughts/` directory, symlink it into the worktree
   - Install dependencies with the repo's install command (e.g. `poetry install`)
   - Never copy `.claude/` recursively — it can be gigabytes

3. **Determine launch details** (if implementing a plan):
   - Path to plan file (use relative path only)
   - Launch prompt
   - Command to run

**IMPORTANT PATH USAGE:**
- The thoughts/ directory is synced between the main repo and worktrees via symlink
- Always use ONLY the relative path starting with `thoughts/shared/...` without any directory prefix
- Example: `thoughts/shared/plans/my-feature.md` (not the full absolute path)
- This works because thoughts are symlinked and accessible from the worktree

4. **Confirm with the user**:

```
Based on the input, I plan to create a worktree with the following details:

worktree path: ~/wt/<repo-name>/<name>
branch name: <BRANCH_NAME>
path to plan file: <FILEPATH>
launch prompt:

    /implement_plan at <FILEPATH>. When all phases pass, run /commit, push the branch, open a draft PR with gh pr create, then run /describe_pr on it.

command to run:

    cd ~/wt/<repo-name>/<name> && claude "/implement_plan at <FILEPATH> ..."
```

Incorporate any user feedback then:

5. **Execute**: Create the worktree as above, then launch implementation session if requested.
