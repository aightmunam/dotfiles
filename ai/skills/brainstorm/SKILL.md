---
name: brainstorm
description: Use when an idea is vague and needs a design before a plan. Use when the user asks you to help design a feature, a tool, or a change before anyone builds it.
---

# Brainstorm

## Definitions

- **Fact:** a thing that code, a file, a log, or a run can show. Facts are your job.
- **Decision:** a choice that only the user can make. Its answer changes what gets built. Intent, success, and anti-goals are always decisions.
- **Recommended answer:** your pick for a decision, with one reason. "Yes" from the user accepts it.
- **Build:** product code, scaffolds, dependency installs, new projects, or an implementation skill. Reads and exploration are not builds.

## The Loop

1. **Explore.** Before your first question, find the code and the files that the idea touches. If the user names a system, search `~/Developer` for its repo. Read what exists now. Write each fact with its path. If the idea is several independent projects, say so. Ask which project comes first, with a recommended order. Then do the loop for one project at a time.
2. **Split.** List the open points. Mark each point as a fact or a decision. Get each fact yourself. Read the code, or run a command. A throwaway script in a scratch directory outside the repo is also exploration. To keep it is a new request through the hard gate. Ask the user only for decisions.
3. **Ask.** Use the question template. Ask about one decision. Pick the decision that most other decisions depend on. Before you recommend, think of several options privately. Drop each option that is weak or that fights the user's why. Wait for the answer.
4. **Play back.** When you understand one part, describe it back in 200 to 300 words. Mark each guess as your guess. Write "Correct any part of this." Then put the next question from step 3 at the end. Then do step 3 again for the next part.
5. **Write.** When no decision is open, write the design doc from the template below. Put it in `thoughts/shared/specs/YYYY-MM-DD-<topic>-design.md` with `status: draft`. Use the `thoughts/` of the repo where the change lands. In a worktree, use the main checkout (`git rev-parse --git-common-dir`, then its parent). If you cannot write files, do the builder check yourself first. Then put the full doc in your answer and name its path.
6. **Builder check.** Read `builder-check.md`. Give it to a fresh agent. With no dispatch tool, read the doc as the builder yourself. Put each "answered" and "minor" result into the doc. Ask each "theirs" question with step 3, one per message. Put each answer into the doc.
7. **Gate.** Give the doc path and the list of your calls. Ask the user to approve the doc, with the question template. When the user approves, set `status: approved`. Then hand off to `make-plan`.

## Hard Gate

Nothing gets built until the user approves the design doc. This gate stays when other rules say to proceed without the user. The design doc and the throwaway scripts from step 2 are not builds.

## Rules That Shape Questions

- **One question per message.** The message ends with that question.
- **Always a recommended answer.** Word the question so that "yes" accepts it.
- **Facts are yours.** Do not ask the user for a fact that code, a file, or a run can show.
- **Say your defaults.** Only a how-it-gets-made choice (tool, library, structure) can be "your call". Mark each one in the doc.
- **The why is the user's.** Intent, success, and anti-goals come from the user. Never write a guessed why into the doc.
- **Approval covers what the user saw.** "Sounds good" to an idea does not approve a doc that the user did not read.

## Question Template

```
<1 to 3 lines: the facts that you found, with paths>

**Decision:** <one question, worded so that yes accepts the recommendation>?
**Recommended:** <your answer>. <one reason>.
```

## Design Doc Template

```
---
status: draft
date: YYYY-MM-DD
topic: <topic>
---
# <Topic> design
## Intent and why
## Goals, non-goals, anti-goals
## Constraints        (facts, each with its path)
## Decisions          (each: question, answer, "user" or "your call")
## Left to the builder
```

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- Your message has more than one question. Go back to step 3.
- A question has no recommended answer. Go back to step 3.
- A question asks for a fact that code, a file, or a run can show. Go back to step 2.
- You asked before you explored. Go back to step 1.
- The doc has an unmarked guess, or a why that the user did not give. Go back to step 3.
- You wrote product code, a scaffold, or an install before approval. Stop. Go back to step 7.
