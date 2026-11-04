# Layers

Source: pstack-claude `plugins/pstack/skills/technical-writing/SKILL.md` (see `source-map.md`).
The sentence rules that `ste-lint` or `unslop` already enforce are not here.

## Pick the mode (Diátaxis)

Ask two questions. Does the text serve action or understanding? Does it serve learning or work?

| | Learning | Work |
|---|---|---|
| Action | tutorial | how-to |
| Understanding | explanation | reference |

- **Tutorial.** Say what the reader will build. Each step gives a visible result. Say what the reader should see: the output, the prompt, the log line. Keep the explanation to one clause and a link.
- **How-to.** Solve one problem that a reader has. Assume skill. Give action only. Link to background. Allow a fork: "If you want x, do y." Name the guide by the task: "Set up a new machine", not "Machine setup".
- **Reference.** Describe only. Give no instruction and no opinion. Be complete and sure. Follow the structure of the thing that it describes, so that a reader can move between the code and the doc.
- **Explanation.** Answer one real "why" question. Give the design decisions, the limits and the alternatives. An opinion is allowed here and in no other mode.

Do not mix modes. Put no reference table inside a tutorial. Put no argument inside a how-to. Split the section and link the parts.

A README is usually a how-to (set up and use) with one reference section (what is where). Put each "why" paragraph in its own explanation section.

## Sentences to the reader

- Write to the reader as "you", in the present tense. Use "will" only for a later event.
- Write each instruction as a command. Put the condition first: "To delete the doc, click **Delete**."
- Put the common case first and the exceptions after it.
- Do not write "simply", "easy", "quickly" or "please" in a step.
- Do not announce work that is not done ("we will soon support").
- Write link text that names the target. Do not write "click here".
- A heading states the point. Use sentence case. A task heading is a verb phrase. A concept heading is a noun phrase. Use one h1 for each page. Do not skip a level.
- Use a numbered list for a sequence. Use bullets for other lists. Start a list with a full sentence. Keep the items parallel.
- Put code, paths and commands in code font. Put UI elements in bold. Use the serial comma. Do not write "etc.". Say first that the list is partial.

## No second reading (Global English)

- Put "only" and "not" next to the word that they change. "only fails on growth" and "fails only on growth" are different claims.
- Break up a long noun string. "the proto import budget check script" becomes "the script that checks the proto-import budget".
- Make each "it", "they" and "this" point at one noun. Do not let "this" or "which" point at a full clause.
- Give each clause its verb. "Phase 1 moves the converters and Phase 2 the runtime" has no verb for Phase 2.
- Keep "that" where it shows the structure: "Make sure that the switch is off."
- Repeat the article in a series of two things: "the client and the host".
- Make the scope of "and" and "or" clear. Use "both ... and", "either ... or" and "if ... then".
- Write a full clause in parentheses, or make it a sentence. Do not write a plural as "(s)".
- Do not use a slash for "or". Write "a, b, or both".
- Use one name for one thing in the full doc. Do not rename what did not change.
- Do not use idioms or Latin abbreviations.

## Facts in docs

- Use the codebase words. Write the real symbol, file, flag or command, not a description of it.
- Do not make new jargon. Use the word that a developer says out loud. When you use a named pattern, define it the first time.
- Make each count and each tree true at the commit that adds it. Give the command that makes the count again.

## Worked example

Before:

> Configuration of the proto import ratchet budget script parameters is performed via budget.json. Note that it's important to remember that running with --write, which updates the committed budget to reflect the current count, should only be done when lowering it. If exceeded, CI fails.

After:

> `budget.mjs` reads the committed budget from `budget.json` and counts the files that import protos. If the count exceeds the budget, CI fails. Run `budget.mjs --write` only to lower the budget.
