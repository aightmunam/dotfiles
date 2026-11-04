---
name: recall
description: Use when a session starts and you must rebuild the working state from earlier sessions. Use when the user asks you to catch them up on a topic across sessions or repos. Use when the user asks what they were doing or where they stopped.
---

# Recall

## Definitions

- **Scope:** the window, the topic, and the workspace of the search. The default window is the last 7 days.
- **Workspace:** the exact cwd of this session. A chat or session is in the workspace only when its cwd is that path or a path under `<cwd>/`. A string prefix never matches: `/x/repo-other` is not under `/x/repo`. A sibling worktree or a parent directory is another workspace.
- **Chat:** one transcript of an earlier session. Its ID is the file name without `.jsonl`.
- **Shared record:** git history, PRs, tickets, and error trackers. It holds the work that your chats do not.
- **Capsule, thread, tag, checked:** as in the `handoff` skill. The capsule has four sections: Capsule, Threads, Problems, Next move.

## The Loop

**First, read `capsule-template.md` of the `handoff` skill.** It is in `../handoff/` next to the real directory of this skill (use `realpath`). Line 1 of your answer is `Scope: <topic>, <window>, <workspace>`. Then comes the title `# Recall: <topic>`. Then comes the Document section of the template, in chat.

1. **Route.** If the user gave you a full capsule (paths, branch, the change), use it. Do step 2, then go to step 5.
2. **Scope.** Before you search, set the window, the topic, and the workspace. Write them as line 1 of the answer. Read only the transcripts of the workspace. Read another workspace only when the user asks. A request "across repos" from the user counts as the user asking. Each repo is then its own workspace. If you narrow "all" to "the recent N", say so.
3. **Mine your history.** Read in this order. Stay in the scope.
   - The newest capsule for the topic in `thoughts/shared/handoffs/`.
   - Claude chats in `~/.claude/projects/<encoded-cwd>/`. `<encoded-cwd>` is the workspace path with each character that is not an ASCII letter or digit changed to `-`. Use only the directory with that exact name. Do not match names in `~/.claude/projects/` by a glob or a prefix. Order the chats by `ls -t`, not by name.
   - Codex sessions in `~/.codex/sessions/YYYY/MM/DD/`, only the day directories in the window. One day directory holds the sessions of all projects. Read only line 1 of each file to get its `cwd`. Do this before any other read or search of that file. Skip each file whose `cwd` is not in the workspace.
   - `git log`, `git branch -a`, `gh pr list --state all`, the plans in `thoughts/shared/plans/`, and the build ledger in `.superpowers/sdd/<plan>/`.
   - Search each chat in the workspace for the topic first. Then read only the matching parts. Skip this chat and subagent, eval, and test chats.
   - One or two chats: read them yourself. More: give each `explorer` agent a slice. Each returns one block per chat: topic, goal, decisions, open threads, corrections, and artifacts, with the chat ID. If no `explorer` type exists, use a general-purpose agent. With no dispatch tool, read the slices yourself.
4. **Sweep the shared record.** Do this step when the topic names a feature, a file, a subsystem, or a bug. Use the History method of `research`: `git log`, `gh pr view`, and Jira or Sentry when you have them. Ask what is the state now, what failed, and what users still report. Skip a source that is not available and say so. An empty search is a finding. Before you say that a thing was never recorded, search each place that the project rules name.
5. **Check live state.** Check the real artifact before you say that you finished a task. Do not infer from a proxy, a self-report, or "it compiles". Read ~/.agents/principles/prove-it-works.md before this step. For each PR, branch, and ticket from the capsule or from steps 3 and 4, run the check for its tag in `capsule-template.md`. For the revert search, read each hit and keep only reverts of #N.
6. **Write.** Fill the Document section in chat. Each thread gets the tag that its check shows, with the Command form and a chat ID or source. Quote each check command and its output, the revert searches too. Put the difference between a capsule or chat and a check under Problems. Quote a ruling of the user and cite its chat.
7. **Red flags.** Read the answer once for each red flag below. Then send it.

## Rules That Shape the Answer

- **Scope first.** Line 1 is `Scope: <topic>, <window>, <workspace>`. The title comes after it.
- **An old capsule is a candidate.** Its tags are claims. The check in this session wins.
- **Read-only.** Do not write files, commit, comment, or change a ticket. Jira, Sentry, Slack, and `gh` are reads only.
- **No data out.** Send no transcript content to Jira, Sentry, GitHub, or any other service. A query carries only IDs and terms that the user or the capsule gave.
- **Redact.** Quote only the lines that carry the signal. Replace each secret, token, and item of customer personal data (names, emails, phone numbers, addresses) with `<REDACTED>`. Do this before the text goes into the answer or an agent prompt. Do this also when you quote a ruling or a chat.
- **Stay on topic.** An adjacent feature stays out unless it blocks this work.
- **Do not ask.** A fact that you cannot check is a Problems line.

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- The answer does not start with the `Scope:` line. Go back to step 2.
- You read a transcript from another workspace and the user did not ask. Go back to step 2 and remove its findings.
- You searched or read a whole Codex day directory, or read past line 1 of a session whose `cwd` is not in the workspace. Go back to step 3 and remove its findings.
- A query to a service holds transcript text. Go back to step 4.
- Quoted text holds a secret, a token, or customer personal data. Replace it with `<REDACTED>`. Go back to step 6.
- A thread tag that you copied from a capsule or a chat, with no check in this session. Go back to step 5.
- A thread with no tag, or with no Command form. A check that you describe in words and do not quote. Go back to step 5.
- You did not read ~/.agents/principles/prove-it-works.md in this session. Go back to step 5.
- A Problems line with no `Source:`. Go back to step 6.
- "Never recorded" with no search of the places that the project rules name. Go back to step 4.
- Capsule over 5 bullets, Problems over 5 lines, or not exactly one next move. Go back to step 6.
- No `Principles applied:` line at the end. Go back to step 6.
