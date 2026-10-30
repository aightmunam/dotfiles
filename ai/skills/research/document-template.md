# Document Template

Fill each section in this order. If a section does not apply, write why. History is the only optional section.

```markdown
---
date: YYYY-MM-DD
topic: <the question, one line>
repos: [<repo>, <repo>]
origin_main:
  <repo>: <full SHA of origin/main, and nothing else>
status: complete
---

# Research: <topic>

## Question

<The question as the user asked it. Then your reading of it in one sentence.>

<Anchor note: did a fetch run? Which commit did you read, if not origin_main?>

## Summary

<3 to 6 tagged claims that answer the question.>

## Components

- <name> (`path`): <what it does>. [verified path:line symbol]

## Flow

1. <step from the entry point to the result>. [verified path:line symbol]

## Boundaries

<Inputs, outputs, and the other systems that this area touches. Tagged.>

## Non-obvious things

<Hidden state, order, side effects, names that do not match. Tagged.>

## Constraints for the change

- <What the change must keep true> - depends on it: <path:line symbol>. [verified ...]
- <What breaks if X changes> - where: <path:line symbol>. [verified ...]

## History (optional)

- <Reason, quoted from a commit, PR, ticket, or comment> - <SHA, PR number, or ticket ID>.
- Searched: <each command or query, also the ones that found nothing>.

## Open questions

<What you could not find or confirm, and where you looked.>

## Key files

<5 to 10 files, one short phrase each.>

## Files read

<Each file that you opened.>
```

Tag format: `[verified path:line symbol]` for a line that you read or a command that you ran. `[inferred: reason]` for all other claims.

## Explorer report sections

When you give an angle to a general-purpose agent, put these rules in its prompt. Read only, cite `path:line` and the symbol, tag each claim `verified` or `inferred`, no advice. It returns these sections in this order: Components, Flow, Files Read, Boundaries, Non-Obvious Things, Open Questions, Key Files (5 to 10).

## Reply shapes

Inline run:

```text
Research: <path of the document>
origin_main: <repo> <short SHA>, one for each repo
<2 lines: the answer in short>
Principles applied: none
```

Fresh-agent run:

```text
<path of the document>
- <at most 5 bullets, each one tagged>
Principles applied: none
```

If you used a principle file, write `Principles applied: <name> -> <choice it changed>` instead of `none`. Name only files that you read in this session.
