# Attack the premise

Source: pstack-claude plugins/pstack/skills/principle-attack-the-premise/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: When two fixes that share one premise fail the same gate, test the premise. Do not write a third fix.

## Rules

- Write the premise as one sentence. It is the belief that every failed fix assumed. Example: "The slow query is slow because of a missing index."
- Find an observation that comes out different if the premise is false. Make that observation before the next fix.
- Look at how the failures are spread. Do not look only at how large they are. Example: do all the failing pytest cases share one fixture, one tenant, or one Postgres version?
- Make the check rerunnable, as a script or a pytest case.
- If the evidence contradicts the premise, look for what the failures have in common.
- If the evidence supports the premise, ask the next "why". The earlier fixes may have treated a consequence.
- If one part always loses, remove the condition that puts it there. Do not add a cleanup that runs each time.

## When it applies

- Two or more fixes failed the same test, the same CI gate, or the same review.
- You are about to retry a fix with a small change.
- Write down the premise and test it before you start the next fix.
