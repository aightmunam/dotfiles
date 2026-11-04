---
name: technical-writing
description: Use when you write, rewrite or restructure a full doc with several sections. Examples are a README, an RFC, a guide and a reference page. A few sentences are not a full doc. Use when the user asks for a doc that a new reader can follow on the first read.
---

# Technical Writing

## Definitions

- **Mode:** the one job of a section. The four modes are tutorial, how-to, reference and explanation. `layers.md` defines each mode.
- **Fact:** a claim that a reader can check. Examples are a path, a command, a count, a version and a default.
- **Live count:** a number that changes when the repo changes. An example is the number of skills in `ai/skills/`.

## The Loop

**First, read `layers.md`.** It holds the mode rules, the sentence rules and a worked example.

1. **Facts.** Read each file, target and script that the doc names. List each fact with its source path.
2. **Modes.** Give each planned section one mode. Write the mode list before the text.
3. **Write.** Write each section in its mode. Use the real path, flag or command as the word for each thing.
4. **Counts.** For each live count, add the command that gives it, or remove the count.
5. **Lint.** Run `python3 ai/vendor/ste-lint.py <file>` on the doc. Fix each finding, or keep it and give the reason.
6. **Unslop.** Run the `unslop` skill on the draft. Keep each fact from step 1.
7. **Reply.** Fill the output template.

## Rules That Shape the Doc

- **One mode for each section.** A how-to section gives steps only. Put the reason for a step in an explanation section and link to it.
- **A heading states the point.** Write "Edit a config without a rebuild", not "Live editing". A task heading starts with a verb.
- **The common case comes first.** Put the exception after it.
- **The condition comes before the step.** Write "To update herdr, change the tag", not the reverse.
- **Each fact has a source.** Write no fact that step 1 did not read. Remove a claim that you cannot check, and say so in the reply.
- **Each pronoun points at one noun.** Repeat the noun when "it", "this" or "they" can point at two things.
- **Vary the length.** A doc in reference mode stays dry. Other modes can mix short and long sentences.

## Red Flags

- A section gives steps and a reason for them in one block. Go back to step 2.
- A heading names a topic and no point. Go back to step 3.
- A number in the doc has no command and can change. Go back to step 4.
- The doc has a fact with no source path in your list. Go back to step 1.
- The doc has an em dash. Go back to step 6.
- The reply has text after the `Principles applied:` line. Go back to step 7.

## Output Template

```
<the doc, or the path of the file that you wrote>

Modes: <each section and its mode>
Facts removed: <each claim that you could not check, or "none">
Lint: <ste-lint result, and each finding that you kept with its reason>
Principles applied: none
```

## Roles

Run inline. Do not dispatch an agent. Write the doc to a file only when the user names the file.

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.
