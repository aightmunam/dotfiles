# Agent instructions

Canonical instruction file shared across Claude Code, Gemini CLI, and Codex CLI.
Everything here applies to every agent. Tool-specific notes live in each tool's
own config, not here.

## Git worktrees

All worktrees live in one place: `~/wt/<repo>/<name>`, where `<repo>` is the
main checkout's directory name. Reviews of someone else's branch go under
`~/wt/<repo>/review/<name>`. This is the declared worktree directory preference
for any skill that asks (e.g. superpowers `using-git-worktrees`).

- Never create worktrees in `/tmp`, as siblings of the repo (`../<repo>-x`),
  or in project-local `.worktrees/` / `worktrees/` dirs, whatever a skill's
  example or default says.
- On Claude Code, native worktrees (`--worktree`, `EnterWorktree`, subagent
  isolation) are already routed to `~/wt` by a WorktreeCreate hook; prefer
  them. Elsewhere use `git worktree add ~/wt/<repo>/<name> -b <branch>`.
- Use `/` -> `+` in names derived from branches (`feat/x` -> `feat+x`).

## Context7 for library docs

Use the Context7 MCP to fetch current documentation whenever the user asks about
a library, framework, SDK, API, CLI tool, or cloud service, even well-known ones
like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. This
covers API syntax, configuration, version migration, library-specific debugging,
setup instructions, and CLI tool usage. Use it even when you think you know the
answer; training data may not reflect recent changes. Prefer it over web search
for library docs.

Do not use it for: refactoring, writing scripts from scratch, debugging business
logic, code review, or general programming concepts.

Steps:
1. Start with `resolve-library-id` using the library name and the user's
   question, unless the user gives an exact ID in `/org/project` format.
2. Pick the best match by exact name, description relevance, code-snippet count,
   source reputation (High/Medium preferred), and benchmark score. If results
   look off, try alternate names or rephrase (e.g. "next.js" not "nextjs"). Use
   version-specific IDs when a version is mentioned.
3. `query-docs` with the selected ID and the user's full question (not single
   words).
4. Answer using the fetched docs.

## Writing standard

Write in ASD-STE100 Simplified Technical English. There are two modes.

- Strict mode: skills, agent prompts, tool descriptions, and subagent briefs.
- Flavored mode: chat replies, plans, reviews, and PR text.
- Use short sentences. Use one instruction for each sentence. Use the active voice.
- Use one word for one meaning. Use the same word again for the same thing.
- Use the imperative for steps. Put each step on its own line.
- Strict mode follows the STE word list and the 20-word limit for instruction sentences.
- Flavored mode keeps the structure but allows project terms and natural phrasing.
- Never use an em dash. This rule overrides STE. Use a period, a comma, or parentheses.
- Lint strict-mode files with `python3 ai/vendor/ste-lint.py --baseline 0 <file>`.

## Skill routing

Pick the skill from this table by the situation. Read the skill before you act.

| Situation | Skill |
|---|---|
| You must learn how code works before a change, and you must not recommend | `research` |
| An idea is vague and needs a design before a plan | `brainstorm` |
| A spec or design is ready and needs ordered, checkable tasks | `make-plan` |
| A written plan is ready to execute | `build` |
| You must write code with a test first, one slice at a time | `tdd` |
| Something is broken and the cause is not known | `debug` |
| A claim, fix, or bug must be shown to be true by a run | `prove` |
| A repo needs its own verify skill generated | `verifier` |
| Speed, memory, or load is a concern, or a regression was measured | `performance` |
| Your branch is ready for a pull request | `pr` |
| You must write a reply to a review comment or a thread | `reply` |
| A reviewer asked for changes and you must fix each one | `address` |
| You must create or change a skill | `new-skill` |
| A change must be checked in the staging environment | `staging` |
| A data change touches a real database or a live system | `data-op` |
| Someone else's pull request needs a review | `review-pr` |
