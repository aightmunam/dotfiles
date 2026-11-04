---
name: explain-code
description: Use when the user asks you to explain code, a change, or a subsystem in chat. Use when the user asks how something works, why it has its current form, or says teach me or help me understand. Use when the answer goes in chat and not in a doc.
---

# Explain Code

## Definitions

- **Purpose:** why the user asks. Examples are a change, a review, a bug, or a first look. Read it from the conversation. Do not ask.
- **Takeaway:** one thing that the user must understand at the end. An answer has two or three.
- **Reason:** a statement about why the code is that way. A reason has a source: a commit, a PR, a ticket, a doc, or a comment. The code alone is not a source for its own reason.
- **Part:** one component or step in the flow that you explain.

## The Loop

1. **Purpose.** Write the purpose and the takeaways for yourself. Put the depth where the question is. Skip what the user already knows.
2. **How.** Narrow question (one repo, a few files): read the code yourself. Wide question: send 2 to 4 angles to `explorer` agents in one message. Open each file that you cite.
3. **Why.** Run `git log --follow --oneline -- <file>` and `git blame -L <lines> <file>` on the lines that the question names. Run `git show` or `gh pr view` on each commit that added them. Record each search, also a search that found nothing.
4. **Answer.** Write the smallest complete answer first: one or two sentences that answer the question for the purpose. Then stop or go on to step 5.
5. **Build.** Give the plain name of the idea and what it is in general. Then tie it to this code and give the mechanism. For three or more parts, draw a series of diagrams. Each diagram redraws the last one and adds one part.
6. **Reasons.** Write each reason in the words of its tier (see the rules). Name each search that found nothing.
7. **Unslop.** Read `~/.agents/skills/unslop/rules.md`. Apply each rule to your draft yourself.
8. **Close.** Offer one or two threads to go deeper on. The last line is `Principles applied: none`, or `<name> -> <choice it changed>` for each principle file that you read.

## Rules That Shape the Answer

- **A reason with a source is plain.** Write "This exists because X" and cite the commit, PR, or `file:line` of the doc next to it.
- **Hedge a reason with no source.** Write "the code suggests" or "likely", and give the chain: "Given A and B, C is likely."
- **A missing reason is a finding.** Write "git log and blame show no reason" and name what you searched.
- **The user's guess is a candidate.** Check it against the evidence like any other reason.
- **Teach, do not list.** A list of functions and line ranges is reference. Explain the problem that each part solves and how it works.
- **No framing labels.** Do not write "in short", "the key insight", or a header or bold line for how, why, or what breaks. Let the first sentence of each paragraph carry the point. Use a short list or a table only for facts that the user will look up again.
- **Plain text diagrams.** Draw in a code fence. The chat does not render mermaid.
- **Chat only.** Write no file. If the user wants the study written to a file, use the `research` skill.

## Red Flags

- A reason with "because", "designed to", or "the format depends on" and no commit, PR, or doc next to it. Go back to step 3.
- No git command ran for a why question. Go back to step 3.
- The first paragraph has more than three sentences. Go back to step 4.
- One diagram holds all of three or more parts. Go back to step 5.
- A diagram in a series that does not repeat the diagram before it. Go back to step 5.
- A header or a bold label line for a part of the answer, or a framing label. Go back to step 7.
- No offer to go deeper, or text after the `Principles applied:` line. Go back to step 8.

## Roles

Run inline by default. The wide path sends one angle to each `explorer` agent. Each prompt holds the question, one angle, and the absolute repo path. If no `explorer` type exists, give a general-purpose agent the same prompt. With no dispatch tool, do each angle yourself.

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.
