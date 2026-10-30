---
name: unslop
description: Use when the user asks to clean, unslop or de-AI a finished text (PR body, reply, message, doc, email). Use when a skill such as reply, pr or ketchup runs a pass over a draft that is already written.
---

# Unslop

## Definitions

- **Tell:** a pattern in `rules.md`. Each tell has a stable rule number.
- **Protected span:** code, a command, a path, a backtick span, a fenced block, a quoted log, or quoted user text.
- **Fact:** a claim that a reader can check. Examples are a negation ("not a refactor"), a limit, a scope, a name, a value and a number. A modal strength ("never", "must", "only", "all") is part of its fact.
- **Not a fact:** praise words with no mechanism ("fast, safe, and reliable"), a sign-off, or flattery.
- **Frame:** the words around a fact that sell it, soften it, or sign off.
- **Changed pattern:** one tell at one place in the text.

## The Loop

**First, read `rules.md`.** It holds rules 3 to 33.

1. **Protect.** Mark each protected span in the input. Do not change a character in it.
2. **Facts.** List each fact in each input sentence, with its strength.
3. **Scan.** Read each sentence against each rule. Note each changed pattern and the one rule whose text describes it.
4. **Rewrite.** Change only how a fact is said. Keep each fact at its strength. Keep the tone. Keep each heading, list and code block, unless a rule names that structure.
5. **Check.** Compare each protected span with the input. Compare each input sentence with the output.
6. **Red flags.** Read the output once for each red flag below.
7. **Reply.** Use the output template. The template is the full answer. Write nothing before it or after it.

## Rules That Shape Output

- **Keep every fact.** No rule removes a fact or makes it weaker or stronger. A rule changes only the words.
- **Rule 13 bans only the em dash.** Use a period, a comma or parentheses. Keep each parenthesis. The writing standard in AGENTS.md wins over pstack here.
- **Rule 9 keeps the fact.** "Not X, it is Y" becomes a direct statement. Keep X and the negation when they are facts.
- **Rule 27 removes only a sentence with no fact.**
- **Add nothing.** Add no fact, number, claim or advice.
- **One line for each changed pattern.** Each line has exactly one rule number, the old words, and the new words.
- **Cite the rule that describes the change.** Rule 17 changes the case of a heading. It does not remove a heading.
- **The change list obeys the rules.** Use no bold label with a colon. Use no em dash.
- **Name the old em dash.** In a change line, write `<em dash>` in place of the old character.

## Red Flags

- A protected span differs from the input. Go back to step 1.
- An input sentence has a fact that is missing from the output. Go back to step 4.
- A fact is weaker or stronger in the output. For example, "never" became "reduce". Go back to step 4.
- A heading, list or code block from the input is gone, and no rule names that structure. Go back to step 4.
- A parenthesis from the input is gone. Go back to step 4.
- An em dash is in the answer, also in a change line. Go back to step 4.
- The output has a new fact, a new number, or advice. Go back to step 4.
- A change line cites a rule whose text does not describe the change. Go back to step 3.
- A change line has no rule number, or more than one. Split it. Go back to step 3.
- The answer has text after the `Principles applied:` line. Go back to step 7.

## Output Template

```
<the cleaned text>

Changes:
- <one rule number>: "<old words>" -> "<new words, or removed>"
Principles applied: none
```

## Roles

Run inline. Do not dispatch an agent. Put the output in the answer. Write a file only when the user names it. When `reply`, `pr` or `ketchup` calls this skill, return only the template.
