---
name: reply
description: Use when the user asks for the text of a reply to a PR review comment, and no code change is needed. Use when the address skill needs the reply text for a thread.
---

# Reply

## Definitions

- **Thread:** one review comment and its replies.
- **Draft:** the reply text for one thread. The user can post it with no edit.
- **Fix:** a code change for the comment. A fix has a commit SHA.
- **Decline:** a decision not to make the change. It has one reason and one cost.
- **Answer:** a reply to a question. It gives the fact that answers it.
- **Run:** a test or command that showed the bug. Only a run permits "Good catch".
- **Given fact:** a fact from the user, from `address`, or from a file that you read.

## The Loop

1. **Classify.** Mark each thread as fix, decline or answer. One thread can need two classes.
2. **Check facts.** List the given facts for each thread. A fix with no SHA is a gap. Ask the user about one gap in each message. Give a recommended answer.
3. **Draft.** Write the outcome in the first sentence. Use 1 to 3 sentences. Use only given facts.
4. **Unslop.** Run the unslop skill on each draft. Use its cleaned text as the new draft.
5. **Red flags.** Read each draft once for each red flag below.
6. **Reply.** Use the output template. Write nothing before it or after it.

## Rules That Shape Each Draft

- **Outcome first.** A fix starts with "Fixed in `<sha>`." A decline starts with the decision. An answer starts with the fact that answers the question.
- **One SHA for each fix.** Put the SHA in backticks.
- **Backticks for each identifier.** This includes a function, a file, a test, a rule code and a SHA.
- **Decline with one reason and its cost.** Give the reason that decides it. Then give what the decision costs.
- **No thanks.** Do not thank the reviewer for the review or for the comment.
- **"Good catch" needs a run.** Write it only when a run showed the bug. Then name the run.
- **No list.** Write prose. A draft has no bullet, number or heading.
- **No chat frame.** Unslop rule 20 (chatbot phrases) and rule 22 (flattery) apply.
- **No filler.** Unslop rule 23 (filler phrases) and rule 24 (too much hedging) apply.
- **Add no fact.** Do not invent a SHA, a test result or a reason.

## Red Flags

- A draft thanks the reviewer. Go back to step 3.
- A draft has more than 3 sentences, or a list. Go back to step 3.
- A fix has no SHA. Go back to step 2.
- A SHA is not in backticks. Go back to step 3.
- "Good catch" with no run. Go back to step 3.
- A decline with no reason or no cost. Go back to step 2.
- An identifier with no backticks. Go back to step 3.
- A draft did not go through unslop. Go back to step 4.
- A draft has a curly quote or a curly apostrophe (unslop rule 19). Go back to step 4.
- An unslop change line is inside a draft. Go back to step 6.
- Text after the `Principles applied:` line. Go back to step 6.

## Output Template

```
Thread <n> (<reviewer>, `<path>:<line>`)

<the draft>

Unslop changes:
- <one unslop change line, as unslop wrote it, or none>

Principles applied: none
```

Repeat the block before `Principles applied:` for each thread.

## Roles

Run inline. Do not dispatch an agent. Do not post a reply. The user or `address` posts it after the user says yes. When `address` calls this skill, return only the template. If no `unslop` skill loads, read `SKILL.md` and `rules.md` in `~/.agents/skills/unslop/`, or in the path that the caller gives.
