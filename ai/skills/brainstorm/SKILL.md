---
name: brainstorm
description: Use when an idea is vague and needs a design before a plan. Use when the user asks you to help design a feature, a tool, or a change before anyone builds it.
---

# Brainstorm

## Definitions

- **Fact:** a thing that code, a file, a log, or a run can show. Facts are your job.
- **Decision:** a choice that only the user can make. Its answer changes what gets built.
- **Recommended answer:** your pick for a decision, with one reason. "Yes" from the user accepts it.
- **Build:** product code, scaffolds, dependency installs, new projects, or an implementation skill. Reads and exploration are not builds.

## The Loop

1. **Explore.** Before your first question, find the code and the files that the idea touches. If the user names a system, search `~/Developer` for its repo. Read what exists now. Write each fact with its path.
2. **Split.** List the open points. Mark each point as a fact or a decision. Get each fact yourself. Read the code, or run a command. A throwaway script in a scratch directory outside the repo is also exploration. Ask the user only for decisions.
3. **Ask.** Use the question template. Ask about one decision. Pick the decision that most other decisions depend on. Wait for the answer.
4. **Play back.** When you understand one part, describe it back in 200 to 300 words. Mark each guess as your guess. Put the next question from step 3 at the end. Then do step 3 again for the next part.
5. **Write.** When no decision is open, write the design doc from the template below. Put it in `thoughts/shared/specs/YYYY-MM-DD-<topic>-design.md` with `status: draft`. In a worktree, use the `thoughts/` of the main checkout. If you cannot write files, put the full doc in your answer and name its path.
6. **Builder check.** Read `builder-check.md` and do it. Put each "answered" and "minor" result into the doc. Ask each "theirs" question with step 3, one per message.
7. **Gate.** Give the doc path and the list of your calls. Ask the user to approve the doc. When the user approves, set `status: approved`. Then hand off to `make-plan`.

## Hard Gate

Nothing gets built until the user approves the design doc. This gate stays when other rules say to proceed without the user. A throwaway script from step 2 stays outside the repo. To keep it is a new request, and it comes back through this gate.

## Rules That Shape Questions

- **One question per message.** The message ends with that question.
- **Always a recommended answer.** Word the question so that "yes" accepts it.
- **Facts are yours.** Do not ask the user for a fact that code, a file, or a run can show.
- **Say your defaults.** Each default goes in the doc as "your call", a decision that you made and the user did not make.
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

## Roles

**Builder:** a fresh agent reads the doc as a builder (`builder-check.md`). With no dispatch tool, you read the doc as the builder.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- Your message has more than one question. Go back to step 3.
- A question has no recommended answer. Go back to step 3.
- A question asks for a fact that code, a file, or a run can show. Go back to step 2.
- You asked before you explored. Go back to step 1.
- The doc has a guess that is not marked as your call. Go back to step 5.
- You wrote, scaffolded, or installed something in the repo before approval. Stop. Go back to step 7.
