---
name: automate-me
description: Use when the user asks to capture, update, or refresh their working style or preferences. Use when the user says automate me.
---

# Automate Me

## Definitions

- **Target:** the `## Working style` section of `~/dotfiles/ai/AGENTS.md`. Put it after `## Writing standard`. Never make a `-mode` skill.
- **History:** the transcripts and the `feedback_*.md` memory files of the active workspace. `<enc>` is the absolute workspace path with each character that is not a letter, a digit, or `-` changed to `-`. Claude transcripts: `~/.claude/projects/<enc>/*.jsonl`. Memory: `~/.claude/projects/<enc>/memory/feedback_*.md`. Codex: each `~/.codex/sessions/**/*.jsonl` whose first line has `payload.cwd` equal to the workspace path. Do not search other projects.
- **Instance:** one user message or one memory file that states a preference. An agent message is not an instance.
- **Signal:** a preference with two instances, or with instances in two slices.
- **Noise:** a preference with one instance, or a preference that a later instance contradicts. A later instance that contradicts it must be a signal on its own.
- **Enforceable:** a hook, a lint, a test, or a script can hold the preference.

## The Loop

1. **Mode.** Find `## Working style` in the target. If it exists, use update mode. Get its last commit date with `git -C ~/dotfiles log -1 --format=%cI -s -L '/^## Working style/,/^## /:ai/AGENTS.md'`. Read only history after that date. For a memory file, use its `date:` field. If it has none, use its mtime. Keep each line that no new instance contradicts.
2. **Slice.** Split the transcripts of the last four weeks into three date ranges. The memory files are a fourth slice. If the user gives other history paths, use only those paths.
3. **Mine.** Give each slice to one `explorer` agent in one message. Use the brief below. If no `explorer` type exists, give the brief to a read-only general-purpose agent. With no dispatch tool, do each slice yourself with the same brief.
4. **Cross-check.** Merge the slice lists. Keep each signal. Drop each noise item and write its reason. Ask about a contradiction that has no winner (step 6).
5. **Classify.** When you write the same instruction a second time, encode it as a lint, a check, or a script. Do not write more text. Read ~/.agents/principles/encode-lessons-in-structure.md before this step. Put each enforceable signal in the diff as a new hook, lint, or check file. Use `~/dotfiles/ai/claude/hooks/` with `~/dotfiles/ai/claude/settings.json`, or `~/dotfiles/ai/tests/`. If only one repo can hold the check, do not write it. Name `correct` under `Open questions`. Do not add an AGENTS.md line for it. Each other signal becomes one line in the target.
6. **Ask.** Ask at most two multiple-choice questions, then one free-form question. Ask one question per message. Give your recommended answer with each question. If the user is not present, do not ask. Put the questions under `Open questions`.
7. **Draft.** Write the section in ASD-STE100 strict mode. Make a unified diff of each file that you change. Show the full diff in your reply.
8. **Approve.** Ask for one OK for the full diff. The user can remove lines from it. Apply only the lines that the user keeps. Do not write a file before the OK. With no OK, write nothing. Commit the kept lines. Do not push to master without a separate OK that lists the commits.

## Slice Brief

```
Read only these files: <paths>. Do not edit or run anything.
Find each user message or memory file that states a preference or corrects the agent.
Classes: replies, autonomy, delegation, verification, code and prose, process, skills.
Agent messages are not evidence.
Return one row for each: preference (user's words) | class | file and line or timestamp | later contradiction (file and line, or none).
```

## Rules That Shape the Section

- **Only non-default rules.** Write a rule only when it is specific. "Communicate clearly" is not a rule.
- **No empty headings.** Add a subsection only when it has a rule.
- **Write "the user".** Do not write the user's name.
- **Point, do not copy.** Name a skill or a principle file by its path. Do not paste its text.
- **Operational text only.** No metaphors. Do not restate other skills.

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- A rule in the diff with one instance, or a rule that a later instance contradicts. Go back to step 4.
- An enforceable signal written as an AGENTS.md line. Go back to step 5.
- A `-mode` skill or a new skill file in the diff. Go back to step 7.
- A read outside the history paths. Go back to step 2.
- A file outside `~/dotfiles` in the diff. Go back to step 5.
- An edit or a write before the OK. Undo it. Go back to step 8.
- No `Principles applied:` line. Go back to step 5.

## Reply Template

```
Diff: <unified diff of each file, or "no change">
Signals: <rule> | <instances: file and line> | <AGENTS.md line or check file>
Dropped: <preference> | <reason: one instance, or contradicted by file and line>
Open questions: <one question and its recommended answer, or "none">
Approval: <waiting for one OK on the full diff, or "applied: <lines kept>">
Principles applied: encode-lessons-in-structure -> <choice it changed>
```
