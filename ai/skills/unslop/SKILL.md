---
name: unslop
description: Use when the user asks to clean, unslop or de-AI a finished text (PR body, reply, message, doc, email). Use when a skill such as reply, pr or ketchup runs a pass over a draft that is already written.
---

# Unslop

## Definitions

- **Tell:** a pattern in `rules.md`. Each tell has a stable rule number.
- **Protected span:** code, a command, a path, a backtick span, a fenced block, a quoted log, or quoted user text.
- **Fact:** a statement of what the change does, a name, a value, or a number.
- **Frame:** the words around a fact that sell it, soften it, or sign off.

## The Loop

**First, read `rules.md`.** It holds rules 3 to 33.

1. **Protect.** Mark each protected span in the input. Do not change a character in it.
2. **Facts.** List each fact in the input. The output keeps each fact, or a change line removes it under a rule number.
3. **Scan.** Read each sentence against each rule. Note the rule number of each tell.
4. **Rewrite.** Change the frame. Keep the fact. Keep the meaning and the tone. Keep the Markdown structure.
5. **Check.** Compare each protected span with the input. Compare the fact list with the output.
6. **Red flags.** Read the output once for each red flag below.
7. **Reply.** Use the output template. The template is the full answer. Write nothing before it or after it.

## Rules That Shape Output

- **Rule 13 bans only the em dash.** Use a period, a comma or parentheses. Keep each parenthesis. The writing standard in AGENTS.md wins over pstack here.
- **Rule 9 keeps the fact.** "Not just X, it is Y" becomes a direct statement. Keep X when X is a fact.
- **Rule 27 removes only empty sentences.** A sentence that names a fact, an instruction or a number stays.
- **Add nothing.** Add no fact, number, claim or advice.
- **One line for each changed pattern.** Give the rule number, the old words, and the new words.
- **The change list obeys the rules.** Use no bold label with a colon. Use no em dash.
- **Name the old em dash.** In a change line, write `<em dash>` in place of the old character.

## Red Flags

- A protected span differs from the input. Go back to step 1.
- A fact from the input is not in the output and no change line names it. Go back to step 4.
- A parenthesis from the input is gone. Go back to step 4.
- An em dash is in the answer, also in a change line. Go back to step 4.
- The answer has text after the `Principles applied:` line. Go back to step 7.
- The output has a new fact, a new number, or advice. Go back to step 4.
- A change line has no rule number. Go back to step 3.

## Output Template

```
<the cleaned text>

Changes:
- <rule number>: "<old words>" -> "<new words, or removed>"
Principles applied: none
```

## Roles

Run inline. Do not dispatch an agent. Put the output in the answer. Write a file only when the user names it. When `reply`, `pr` or `ketchup` calls this skill, return only the template.
