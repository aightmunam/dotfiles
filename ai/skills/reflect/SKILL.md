---
name: reflect
description: Use when the user says reflect, or asks to turn the lessons of a session into skill or AGENTS.md edits.
---

# Reflect

## Definitions

- **Lens:** one reviewer brief. The three lenses are `judgment-brief.md`, `tooling-brief.md` and `divergent-brief.md`.
- **Finding:** one lesson from a reviewer, with its evidence (a turn or a quote) and its routing.
- **Used skill:** a skill whose `SKILL.md` the session opened, whose path a dispatch prompt named, or whose documented commands a tool call ran. A skill in the catalog that did not fire when it should have is a **missed trigger**.
- **Target:** a file under `ai/skills/<name>/`, or `ai/AGENTS.md`, in the dotfiles checkout. A file in a plugin cache is never a target.
- **Batch OK:** one user reply that accepts the Accepted list, or a part of it that the user keeps.

## The Loop

1. **Find the session.** Use the transcript path that the user gives. Else look only in the transcript directory of the current project. On Codex, look only in the rollouts of the current cwd. If you find no transcript, write a digest in turn order. It has each user prompt and correction, each tool call and its result, and each file touched. A digest has no diagnosis and no verdict.
2. **Dispatch three reviewers.** Send three `reviewer` dispatches, one for each lens. Start all three before you wait for a result. Give each its brief verbatim, with the transcript path or the digest in its slot. Add nothing else.
3. **Synthesize.** Apply the filter below to each finding. Group the findings that state one lesson, and record the lenses of each group. Before you accept a row, read its target. This includes a `tune description` row.
4. **Structural check.** When you write the same instruction a second time, encode it as a lint, a check, or a script. Read ~/.agents/principles/encode-lessons-in-structure.md before this step, as a read of that file alone. Move each Accepted row that a lint, test, hook or script can enforce to Backlog, as that guard.
5. **Show once.** Fill the output template. Give each trivial Accepted row as a diff. Ask for the batch OK in one question. Then stop.
6. **Apply.** After the batch OK, apply only the rows that the user kept. Make a trivial edit (one line, a tighter sentence, a stale fact) in the target. Give a substantive edit (a new section, more than 10 lines) or a description tune to `new-skill`.
7. **Report.** One line for each applied edit, each `new-skill` handoff, each Backlog item, and each rejected finding with its reason.

## Approval Gate

Apply no edit before the batch OK. Ask one OK for the whole Accepted list. Never ask one OK for each edit. This gate stays when other rules say to proceed without the user. An absent user does not give an OK. Do not push. Do not open a PR.

## Filter

- **Durable.** It stays true when paths, SHAs and versions change.
- **Specific.** It applies across tasks, and an agent can see when it applies.
- **Convergence.** A lesson from two or three lenses has more weight. A lesson from one lens must pass each other rule clearly.
- **Changes a decision.** A future agent acts differently because of the edit.
- **Used skill only.** A body edit goes only to a used skill. A missed trigger goes to `tune description: <skill path>`.
- **Existing skill first.** Propose a new skill only when no skill is a real home and the pattern repeats.
- **Target exists.** The routed file is in the checkout. Else reject it, with the reason "no target".
- **Already covered.** The target says it clearly: reject. The target says it weakly or in a place that is easy to miss: accept a wording or placement change, not a second copy.

A finding that fails a rule goes to Rejected with that rule as its reason.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- You wrote an edit before the batch OK. Undo it. Go back to step 5.
- You asked for an OK on one edit. Go back to step 5.
- You dispatched fewer than three reviewers, or you waited for a result before all three started. Go back to step 2.
- A body edit routes to a skill that the session did not use. Go back to step 3.
- A target is in a plugin cache. Route it to `ai/skills/<name>/`, or reject it. Go back to step 3.
- An Accepted text rule that a guard can enforce. Go back to step 4.
- The Principles applied line has no `->`. Go back to step 5.

## Output Template

```
Session: <transcript path, or "digest">. Reviewers: <dispatch type, or "inline">.
Lens lists: judgment <n> findings, tooling <n> findings, divergent <n> findings.
## Accepted
| # | Problem | Proposal | Routing | Lenses |
<one row per lesson; Routing is a target path and section, `tune description: <path>`, or `new-skill: <name>`>
Diffs: <a unified diff for each trivial row; "via new-skill" for the others>
## Rejected
- <lesson>. Reason: <the filter rule>.
## Backlog
- <pattern>. Hit: <turn>. Guard: <lint, test, hook or script>.
Nothing is applied. Reply OK to apply all Accepted rows, or name the rows to drop. Recommended: <answer>.
Principles applied: encode-lessons-in-structure -> <choice it changed>
```

## Roles

Dispatch `reviewer` agents. If no `reviewer` type exists, give each brief to a general-purpose agent. A dispatch tool can have another name, such as `spawn_agent`. Start each reviewer with no parent history. On `spawn_agent`, set `fork_turns` to `none`. Wait for all three results. With no dispatch tool, do each lens yourself, one at a time. Write its numbered list in your answer before the next lens. Write "inline" in the Reviewers line. You do the synthesis yourself.
