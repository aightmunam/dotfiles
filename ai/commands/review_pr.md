---
description: Review PRs locally with comprehensive code analysis (strictly local, no GitHub actions)
model: opus
---

# Review PR

You are tasked with reviewing a pull request from a colleague. This command uses `/local_review` to set up the environment, then performs comprehensive code review using parallel subagents.

**CRITICAL SAFETY RULES - NEVER VIOLATE**:
- NEVER push any code to GitHub
- NEVER post comments on the PR
- NEVER make any changes to the remote repository
- NEVER take any GitHub action without EXPLICIT user approval, even if permission bypass is enabled
- ALL review work happens strictly locally

## Initial Response

When invoked:
1. **Parse PR identifier**:
   - PR URL: `https://github.com/owner/repo/pull/123`
   - PR number: `123` or `#123`
   - Username:branch: `username:branch-name`

2. **If no parameter**:
```
I'll help you review a PR locally.

Please provide one of:
- PR URL: https://github.com/owner/repo/pull/123
- PR number: 123 or #123
- Username:branch: colleague:feature-branch

I will:
1. Set up a local worktree (via /local_review)
2. Analyze the PR's feature (what it does) and implementation (how it's built)
3. Perform comprehensive code review
4. Generate a review document and open it in the review viewer

**Note**: All work is strictly local. I will NEVER push or comment on GitHub.
```

## Process Steps

### Step 1: Get PR Information

1. **For PR number or URL, fetch details**:
   ```bash
   gh pr view [NUMBER] --json number,title,body,headRefName,author,files,additions,deletions,commits
   ```

2. **Extract and present summary**:
   ```
   PR #123: [Title]
   Author: @username
   Branch: feature-branch
   Files: 15 changed (+342, -89)

   Setting up review environment...
   ```

### Step 2: Set Up Environment via /local_review

1. **Invoke /local_review** via Skill tool with format `username:branch-name`

2. **Wait for worktree setup to complete**

3. **Note the worktree path** (typically `~/wt/[repo]/[identifier]`)

### Step 3: PR Feature Walkthrough (What + How)

Before diving into code quality, always establish **what** the feature does before thinking about **how** it was built. This always runs (no opt-in gate) and its output feeds directly into the review document's `# What was done` and `# How it was done` sections (Step 6).

1. **Capture the diff ONCE (orchestrator step — the command has Bash; the analyst agents do not).** Run `gh pr diff [PR_NUMBER] --repo [owner/repo]` and save it to a temp file OUTSIDE the repo (your scratchpad) as `[DIFF_PATH]`. Do NOT use `git diff main...HEAD` — the worktree's local `main` may be stale and over-report. You already have the changed-file list and PR body from Step 1.

2. Spawn **2 parallel Task agents** using **`codebase-analyzer`** (keep it — it Reads/Greps the code, which is exactly the job; do NOT downgrade to a generic agent), each with `Working directory: [worktree_path]`. Pass each agent the `[DIFF_PATH]`, the changed-file list, and (for the What-analyst) the PR body text — the agent **Reads** those and the source files; it never runs `git`/`gh`. If an agent returns empty or does no work (0 tool uses), re-dispatch it before continuing:

   **What-analyst:**
   ```
   Determine WHAT this PR does from a product / user-facing perspective.
   1. The PR title and body are provided here: [PR_BODY]. Read them fully.
   2. Read the authoritative PR diff at [DIFF_PATH], then Read the changed files AND their tests (listed in [CHANGED_FILES]). Do NOT run git/gh — everything you need is on disk.
   3. Explain in plain language: what can a user now do that they couldn't before?
   4. Identify before → after behavior, entry points, and any UI/API surface changes.
   5. Note any screenshots, mockups, or examples referenced in the PR body.
   Return a structured narrative of the feature's behavior and intent (NO implementation detail).
   ```

   **How-analyst:**
   ```
   Determine HOW this PR is implemented.
   1. Read the authoritative PR diff at [DIFF_PATH] (do NOT run git/gh). The changed files are listed in [CHANGED_FILES]; Read them from the worktree for full context.
   2. Map the architecture: which layers/modules changed and how they connect.
   3. Trace the primary data/control flow through the changed code.
   4. List the key files and functions in the order a reader should follow them.
   5. Note new dependencies, data-model / API-contract changes, and notable design choices.
   Return a structured implementation walkthrough.
   ```

3. **Keep both narratives** — the What-analyst's return value becomes the review document's `# What was done` section; the How-analyst's return value becomes `# How it was done` (Step 6 writes them in verbatim, lightly edited for markdown flow).

### Step 4: Comprehensive Code Review

Make sure you review the wt and NOT the current path. Mention the PATH you are currently reviewing the PR on by 
leaving a comment for the user, something like:

```
Reviewing branch `branch-name` in repo `repo-name` via worktree located at `worktree_path`
```

**Orchestrator step first (the command has Bash; the agents do not):** reuse the `[DIFF_PATH]` diff file saved in Step 3 (NOT `git diff main...HEAD`, which over-reports when local `main` is stale).

Then spawn **5 parallel Task agents** using **`codebase-analyzer`** (keep it — Reading/Greping the code is exactly its job; do NOT downgrade to a generic agent) with specialized prompts. Give every agent the `[DIFF_PATH]` and the changed-file list `[CHANGED_FILES]`; the agent **Reads** those and the source files and never runs `git`/`gh`. If an agent returns empty (0 tool uses), re-dispatch it.

#### Agent 1: Change Analysis
```
Analyze all changed files in this PR. Working directory: [worktree_path]

1. Read the authoritative PR diff at [DIFF_PATH] and the changed files listed in [CHANGED_FILES] (do NOT run git/gh)
2. Categorize changes: new features, bug fixes, refactoring, config changes
3. Identify main areas of impact
4. Summarize what changed and why

Return a structured summary of changes by component/area.
```

#### Agent 2: Security Review
```
Perform a security-focused review of changed files. Working directory: [worktree_path]

Check for:
1. Hardcoded secrets, API keys, or credentials
2. Missing input validation on user-facing code
3. SQL injection vulnerabilities (non-parameterized queries)
4. XSS vulnerabilities in frontend code
5. Authentication/authorization issues
6. Sensitive data exposure in logs or responses
7. Insecure dependencies or configurations

Return findings with severity (Critical/High/Medium/Low) and file:line references.
```

#### Agent 3: Performance Review
```
Perform a performance-focused review of changed files. Working directory: [worktree_path]

Check for:
1. N+1 query patterns in database code
2. Unbounded loops or recursion
3. Expensive operations in hot paths
4. Missing database indexes for new fields
5. Memory leaks (unclosed resources, growing collections)
6. Unnecessary re-renders in React components
7. Large payload sizes or missing pagination

Return concerns with impact assessment and recommendations.
```

#### Agent 4: Code Quality Review
```
Perform a code quality review of changed files. Working directory: [worktree_path]

Evaluate:
1. Adherence to existing codebase patterns and conventions
2. Code duplication
3. Error handling completeness
4. Test coverage for new code
5. Naming conventions and clarity
6. Type safety (TypeScript strict mode, Go types)
7. Comment quality and documentation

Return findings with specific suggestions for improvement.
```

#### Agent 5: Architecture Review
```
Assess the architectural impact of changes. Working directory: [worktree_path]

Evaluate:
1. Alignment with existing architecture patterns
2. New dependencies introduced
3. Separation of concerns
4. API contract changes
5. Backwards compatibility
6. Potential for future maintenance issues

Return assessment with specific concerns if any.
```

### Step 5: Run Automated Checks

Execute in the worktree:
```bash
cd [worktree_path] && make check test 2>&1
```

Capture: build status, lint results, test results, type checking.

### Step 6: Generate Review Document

**Ensure the output directory exists** by running:
```bash
mkdir -p "$(readlink thoughts/shared)/reviews"
```

This resolves the symlink to the actual thoughts repo location.

**Capture PR metadata for the frontmatter** (orchestrator step — Bash):
```bash
gh pr view [NUMBER] --json headRefOid -q .headRefOid   # -> head_sha
gh repo view --json owner,name -q '.owner.login + "/" + .name'   # -> repo, as "owner/name"
```

**File naming convention:**
- Filename: `thoughts/shared/reviews/YYYY-MM-DD-pr-NNN-title.md`
- Format: `YYYY-MM-DD-pr-NNN-title.md` where:
  - YYYY-MM-DD is today's date
  - NNN is the PR number
  - title is a brief kebab-case description from the PR title
- Examples:
  - `2025-01-08-pr-123-add-user-authentication.md`
  - `2025-01-15-pr-456-fix-memory-leak.md`
- The review-viewer identifies each review by its **slug**: the filename without `.md` (e.g. `2025-01-08-pr-123-add-user-authentication`).

Use this template — this is the "C+ light" format the review-viewer parses. Follow the format rules below the template exactly:

```markdown
---
date: [ISO date]
reviewer: Claude
repo: [owner/name from gh repo view]
pr_number: [number]
pr_title: "[title]"
pr_author: "@[username]"
branch: [branch]
head_sha: [headRefOid from gh pr view]
verdict: [approve | request_changes | comment]
status: review_complete
---

# Summary

[OPTIONAL — leave a short placeholder line inviting the reviewer's own words, e.g. an HTML comment `<!-- optional: your own summary of the PR -->`, OR a 1-2 sentence high-level take. This section is for the human; keep it short or empty.]

# What was done

[What-analyst narrative from Step 3 — product/user-facing. Markdown prose, tables, lists; mermaid diagrams are OK.]

# How it was done

[How-analyst narrative from Step 3 — implementation walkthrough + "read the code in this order" list.]

# Review findings

### C1 — [short title]
_[one-line plain-English summary]_

~~~finding
severity: critical
category: [security|correctness|performance|quality|architecture|api|observability|test|...]
file: [repo-relative path]
line: [integer line in the diff]
side: RIGHT
---
[Full rationale in markdown. Explain the problem and why it matters.]

```suggestion
[optional: the exact replacement code for that line/range]
```
~~~

### H1 — [short title]
_[one-liner]_

~~~finding
severity: high
category: [...]
file: [...]
line: [...]
side: RIGHT
---
[rationale]
~~~

[...more findings, consolidated from all 5 review agents, ids grouped by severity: C#, H#, M#, L#...]

# Automated checks

| Check | Status | Notes |
|---|---|---|
| ruff lint | pass | [notes] |
| mypy --strict | pass | [notes] |
| tests | pass | [notes] |

# Questions for author

- [optional questions that arose during review]
```

**Format rules the skill MUST follow (so the viewer parses it):**
- Frontmatter is real YAML; `pr_number` and `line` are integers; `head_sha` and `repo` MUST be present (needed for the viewer's one-click GitHub pending-comment feature).
- Severities are exactly `critical` / `high` / `medium` / `low` — fold anything that would have been "Info" into `low`.
- Each finding: an `### <ID> — <title>` heading (ID matches `[CHML]\d+`, e.g. `C1`, `H2`, `M3`, `L1`; the `—` is an em dash but a hyphen also parses), then an optional italic `_summary_` line, then a `~~~finding` block (tilde fence) with a small YAML head, a line that is exactly `---`, then the markdown body. Put any ```` ```suggestion ```` fix INSIDE the finding body.
- `# Automated checks` and `# Questions for author` are H1 sections (NOT `##`) so the viewer's H1 section-splitter captures them. Same for `# Summary`, `# What was done`, `# How it was done`, `# Review findings`.
- Every finding field the GitHub pending-comment needs — `file`, `line`, `side` — must be accurate to the diff.
- Set `verdict` in the frontmatter to `approve`, `request_changes`, or `comment` based on the consolidated findings (Critical/High present → `request_changes`; otherwise `approve` or `comment` as appropriate).

### Step 7: Sync and Present Review

1. **Sync the thoughts directory**:
   - Run `humanlayer thoughts sync` to sync the newly created review document
   - This ensures the review is properly indexed and available

2. **Open the review in the review-viewer**:
   - The slug is the review filename without `.md` (e.g. `2025-01-08-pr-123-add-user-authentication`)
   - Run `open "http://review/r/[slug]"`

3. **Present the review**:
   ```
   Review Complete!

   Document: thoughts/shared/reviews/YYYY-MM-DD-pr-NNN-title.md
   Opened: http://review/r/[slug]

   Verdict: [approve / request_changes / comment]

   Key Findings:
   - Critical: [count]
   - High: [count]
   - Medium: [count]
   - Low: [count]

   REMINDER: This review is strictly local.
   - NO comments have been posted to GitHub
   - NO code has been pushed
   - To share feedback, use the review-viewer's staging flow or manually copy from the review document

   Would you like me to remove the review worktree?
   ```

### Step 8: Handle Follow-up Questions

If the user has follow-up questions or wants additional analysis:

1. **Update the existing review document** rather than creating a new one
2. **Update frontmatter fields**:
   - Add/update `last_updated: [Current date in YYYY-MM-DD format]`
   - Add/update `last_updated_by: Claude`
   - Add `last_updated_note: "Added follow-up analysis for [brief description]"`
3. **Add a new section**: `## Follow-up Analysis [timestamp]`
4. **Spawn additional sub-agents** as needed for deeper investigation
5. **Re-sync**: Run `humanlayer thoughts sync` after updates

## Important Notes

- This command is READ-ONLY regarding GitHub
- All findings are written to a local document
- User must manually share feedback with PR author (or use the review-viewer's staging flow)
- Always remind user that no GitHub actions were taken
- Run all 5 review agents in parallel for efficiency
- **PR feature walkthrough (Step 3)**: always runs, no opt-in gate; the What-analyst and How-analyst narratives feed the review document's `# What was done` / `# How it was done` sections directly
- Always sync thoughts directory after writing the review document
- **File reading**: When reviewing PR details or related files, read them FULLY (no limit/offset parameters)
- **Critical ordering**: Follow the numbered steps exactly
  - ALWAYS run the What-analyst and How-analyst (Step 3) before the review document is written
  - ALWAYS wait for all 5 review agents to complete before synthesizing findings (Step 4)
  - ALWAYS run automated checks before generating the review document (Step 5 before Step 6)
  - ALWAYS open the review in the review-viewer after syncing (Step 7)
  - NEVER write the review document with placeholder values
- **Frontmatter consistency**:
  - Always include frontmatter at the beginning of review documents
  - Keep frontmatter fields consistent across all review documents
  - Update frontmatter when adding follow-up analysis
  - Use snake_case for multi-word field names (e.g., `pr_number`, `pr_title`, `pr_author`)
