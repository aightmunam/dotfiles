# Agent instructions

Canonical instruction file shared across Claude Code, Gemini CLI, and Codex CLI.
Everything here applies to every agent. Tool-specific notes live in each tool's
own config, not here.

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

## rtk (Rust Token Killer)

A token-optimizing CLI proxy (60-90% savings on dev operations).

Meta commands, run directly:
- `rtk gain`: token-savings analytics
- `rtk gain --history`: command usage history with savings
- `rtk discover`: analyze history for missed opportunities
- `rtk proxy <cmd>`: run a raw command without filtering (debugging)

Verify install: `rtk --version`, `rtk gain`, `which rtk`. Name collision: if
`rtk gain` fails you may have reachingforthejack/rtk (Rust Type Kit) installed
instead.

On Claude Code a hook auto-rewrites other commands through rtk (e.g. `git status`
becomes `rtk git status`, transparently, at 0 token overhead). On agents without
that hook, invoke `rtk <cmd>` explicitly to get the savings.
