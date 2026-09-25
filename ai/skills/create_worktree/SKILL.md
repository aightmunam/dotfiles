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
   - Run: `wt-create <name> [branch]`
   - This handles everything: git worktree, thoughts symlink, .claude config, .env, dependency installation
   - The worktree will be created at `~/wt/<repo-name>/<name>`

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

    /implement_plan at <FILEPATH> and when you are done implementing and all tests pass, read .claude/commands/commit.md and create a commit, then read .claude/commands/describe_pr.md and create a PR

command to run:

    claude -w ~/wt/<repo-name>/<name> "/implement_plan at <FILEPATH> ..."
```

Incorporate any user feedback then:

5. **Execute**: Run the worktree creation script, then launch implementation session if requested.
