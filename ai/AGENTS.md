# Agent instructions

Canonical instruction file shared across Claude Code, Gemini CLI, and Codex CLI.
Everything here applies to every agent. Tool-specific notes live in each tool's
own config, not here.

## Git worktrees

All worktrees live in one place: `~/wt/<repo>/<name>`, where `<repo>` is the
main checkout's directory name. Reviews of someone else's branch go under
`~/wt/<repo>/review/<name>`. This is the declared worktree directory preference
for any skill that asks.

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
- Write the real symbol, file, flag, or command. The codebase is the word list.
- When a rule makes a sentence worse, fix the sentence another way.
- Make every count or tree claim true at the commit that lands it.
- In chat, give the smallest complete answer first. Add no framing labels.
- For three or more moving parts, draw a short series of diagrams. Each diagram adds one part.
- In a reply that waits on the user, list only work that the user must do. Work that the agent can still do is not an action item.
- Give each action item its link, what it changes, the evidence for the pick, and its risk. Give the risk even when it is low.
- Keep an item open while it waits on the user.
- Lint strict-mode files with `python3 ai/vendor/ste-lint.py --baseline 0 <file>`.

## Skill routing

Pick the skill from this table by the situation. Read the skill before you act. Read it before any other tool call, also before a check that a named file or repo exists. The skill tells you what to do when it does not.

| Situation | Skill |
|---|---|
| Learn how code works before a change, written to thoughts, no recommendations | `research` |
| An idea is vague and needs a design before a plan | `brainstorm` |
| Make a task or a prompt deeper, not bigger, and rewrite it before the work starts | `sharpen` |
| A spec or design is ready and needs ordered, checkable tasks | `make-plan` |
| A written plan is ready to execute | `build` |
| One change, test first, with no plan | `tdd` |
| Something is broken and the cause is not known | `debug` |
| Your own change is done and runs must show it works before a PR | `prove` |
| A repo needs its own verify skill | `verifier` |
| A claim that a change is faster or slower, or a measured regression | `performance` |
| Your branch is ready for a PR, or your PR body needs an update | `pr` |
| Write the text of a reply to a review comment | `reply` |
| A reviewer asked for changes on your PR and at least one needs a code change | `address` |
| Create or change a named skill | `new-skill` |
| Deploy a branch to staging and check it | `staging` |
| A data change touches a real database or a live system | `data-op` |
| Review a colleague's PR, read-only, or review a PR's API against the Zalando rules | `review-pr` |
| End of a session: write the state for the next one | `handoff` |
| Start of a session: catch me up across sessions and repos | `recall` |
| Say the last message again in plain words | `bro` |
| What changed in this chat since my last message, and what waits on me | `ketchup` |
| Turn the lessons of a session into skill or AGENTS.md edits | `reflect` |
| Agents repeat a mistake in a repo: add a guard in that repo's code | `correct` |
| Capture or update the user's working style | `automate-me` |
| A merge or rebase stopped with conflicts | `fix-merge-conflicts` |
| A standup summary of my finished work | `what-did-i-get-done` |
| Clean AI tells out of a finished text (PR body, reply, message, doc, email) | `unslop` |
| Write, rewrite or restructure a full doc with several sections (README, RFC, guide, reference page) | `technical-writing` |
| Explain code, a change, or a subsystem in chat: how it works and why it is that way | `explain-code` |

Tie-break lines, one per set:

- reply / address: a code change is needed, `address` (it calls `reply` for the text). Text only, `reply`.
- debug / prove: the cause is not known, `debug`. The change is done and needs evidence, `prove`.
- pr / review-pr: your own branch, `pr`. Someone else's PR, `review-pr`.
- recall / ketchup / handoff: this chat since the user's last message, `ketchup`. Across sessions or repos, `recall`. Write state for a later session, `handoff`.
- reflect / correct / automate-me / new-skill: lessons from a session into skills or AGENTS.md, `reflect`. A repeated mistake guarded in a repo's own code, `correct`. The user's personal working style, `automate-me`. A named skill to write or change, `new-skill`.
- tdd / build: a plan to execute, `build` (it uses `tdd` per slice). One change with no plan, `tdd`.
- brainstorm / sharpen: an idea that needs a design doc, `brainstorm` (it asks the sharpen questions in step 1). A prompt to rewrite and hand on, with no design doc, `sharpen`.
- research / explain-code: a written study before a change, `research`. Explain code to the user in chat, `explain-code`.
- bro / ketchup: restate one message, `bro`. Catch up on many changes, `ketchup`.
- bro / unslop: say the last message again in plain words, `bro`. Clean a given finished text, `unslop`.
- recall / what-did-i-get-done: catch up so you can keep working, `recall`. A standup summary of finished work, `what-did-i-get-done`.
- prove / verifier / performance: show that your own change works, `prove`. Build a repo's own verify skill, `verifier`. A speed claim or a measured regression, `performance`.
- verifier / new-skill: a scripted way to launch, drive and prove one repo's app, `verifier`. Any other skill to write or change, `new-skill`.
- pr / unslop: write or update a PR body, `pr`. Clean a text that you already wrote, `unslop`.
- pr / address: reviewer comments that need a code change, `address`. Only the PR body changes, `pr`.
- staging / prove: Deploy a branch to staging and check it, `staging`. Prove your own change with runs in worktrees before a PR, `prove`.
- staging / data-op: Deploy a branch to staging and check it, `staging`. A data change on a real database or a live system, `data-op`.
- unslop / the writing standard: the `## Writing standard` section in this file guides text while it is written. `unslop` is a pass over a text that is already written.
- technical-writing / unslop: write or restructure a doc, `technical-writing` (it runs `unslop` at the end). Clean a given finished text and keep its structure, `unslop`.
- technical-writing / pr: a PR body, `pr`. A doc file in the repo (README, guide, RFC), `technical-writing`.
- technical-writing / the writing standard: a full doc, `technical-writing` (it adds one mode for each section, headings, live counts). A few sentences, the writing standard alone.

Not these. Use the kept skill and not a rework skill:

| Situation | Skill |
|---|---|
| Make a git commit with no Claude attribution | `commit` |
| UI work in personal apps | `design-system` |

## Principles

Each line gives the file and the moment to read it. A skill step that needs a principle names the file.

- ~/.agents/principles/attack-the-premise.md: two fixes failed the same gate, or you retry a fix with a small change.
- ~/.agents/principles/boundary-discipline.md: you add validation, error handling, or an adapter.
- ~/.agents/principles/build-the-lever.md: a change is more than a few obvious edits, or it is a data fix or a wide rename.
- ~/.agents/principles/encode-lessons-in-structure.md: you see the same mistake or correction twice.
- ~/.agents/principles/explain-the-number.md: you measure speed or memory, or you report a regression or a speedup.
- ~/.agents/principles/fix-root-causes.md: you debug a failure, or you review a fix that adds a guard or a retry.
- ~/.agents/principles/foundational-thinking.md: you pick core types, tables, or module boundaries, or you order plan phases.
- ~/.agents/principles/laziness-protocol.md: you refactor, size a diff, or want to add a layer. Rule: make the smallest change that solves the problem. Remove before you add.
- ~/.agents/principles/make-operations-idempotent.md: an operation can run again after a crash or a retry.
- ~/.agents/principles/minimize-reader-load.md: you write or review code that is hard to trace.
- ~/.agents/principles/model-the-domain.md: you write stateful logic, or you see many branches.
- ~/.agents/principles/never-block-on-the-human.md: you want to ask permission on a step that you can undo. Rule: only two actions need the user's OK. These are a merge or push to main/master (it deploys to production), and any write to production. Commits, feature-branch pushes, non-prod writes (Alembic included), and all reads (prod included) proceed without a question.
- ~/.agents/principles/prove-it-works.md: you finish a task, or you write or read a handoff.
- ~/.agents/principles/separate-before-serializing-shared-state.md: a plan runs parallel workers, or code writes state that other code writes.
- ~/.agents/principles/test-behavior-not-implementation.md: you write, change, or keep a test.
