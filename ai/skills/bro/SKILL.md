---
name: bro
description: Use when the user says bro, or asks you to say the last message again in plain words.
---

# Bro

## Definitions

- **Last message:** your most recent message to the user in this chat.
- **Jargon:** a word that a person outside the field does not know. Examples are a tool name, an id, a flag, a command, a code name and an acronym.

## The Loop

1. **Read.** Read your last message. List its main point and each choice it gives the user.
2. **Restate.** Say the same point and the same choices in plain words. Write as one person talks to another.
3. **Check.** Read the answer once for each red flag.
4. **Reply.** Use the output template.

## Rules That Shape Output

- Use fewer words than the last message.
- Use no jargon. Tell what a command or an id does in plain words. Do not quote it.
- Write plain sentences. Use no heading, list, bold text or code block.
- Add nothing. Add no fact, step, advice or recommendation.
- Keep the main point and each choice.

## Red Flags

- The answer has the same number of words as the last message, or more. Go back to step 2.
- The answer has jargon, a command or an id. Go back to step 2.
- The answer has a fact, step, advice or recommendation that the last message does not have. Go back to step 2.
- A choice from the last message is missing. Go back to step 1.

## Output Template

```
<the plain restatement>
Principles applied: none
```

## Roles

Run inline. Do not dispatch an agent. Do not read a file or run a command.
