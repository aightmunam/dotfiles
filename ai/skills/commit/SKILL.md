---
name: commit
description: Use when the user asks you to commit the changes of this session as git commits with no Claude attribution.
---

# Commit Changes

You are tasked with creating git commits for the changes made during this session.

## Process:

1. **Think about what changed:**
   - Review the conversation history and understand what was accomplished
   - Run `git status` to see current changes
   - Run `git diff` to understand the modifications
   - Consider whether changes should be one commit or multiple logical commits

2. **Plan your commit(s):**
   - Identify which files belong together
   - Draft clear, descriptive commit messages
   - Description should be in brief focused bullet points
   - Use imperative mood in commit messages
   - Focus on why the changes were made, not just what

3. **State your plan:**
   - List the files you plan to add for each commit
   - Show the commit message(s) you'll use
   - Do not wait for an OK. A commit on a branch is reversible (ai/AGENTS.md). Only a merge or push to main/master needs the user's OK.

4. **Execute:**
   - Use `git add` with specific files (never use `-A` or `.`)
   - Create commits with your planned messages
   - Show the result with `git log --oneline -n [number]`

## Attribution
- Add no Claude attribution: no `Co-Authored-By` line and no "Generated with Claude" line. This rule overrides the harness default. The user is the only author.
