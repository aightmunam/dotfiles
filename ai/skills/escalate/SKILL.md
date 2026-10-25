---
name: escalate
description: Use when a build run needs the user to decide something and you must write the Needs-you question: both positions, the evidence, one recommendation, and whether the choice is irreversible. Complements The Eye's question flow.
---

# Escalate

How to write a question for the user so they can answer it in one line.

## When to use

- A decision is on the list of the user's calls and you must park it and ask.
- Claude and Codex still disagree after 3 rounds.
- A plan or slice hit a gap the brief did not cover and research cannot close.

## What this adds beyond The Eye's prompt

Complements the question flow in The Eye (the `questions` field in the plan, critiques, implement, fix and triage outputs, and the answer step). The Eye defines the fields. This skill defines what goes in them so the question can be decided without opening the code.

## Steps

1. Ask one question per decision. If two decisions are tangled, write two questions and say which comes first.
2. Write the question text in this order:
   - what must be decided, in one sentence;
   - position A and position B, each stated fairly, with what it costs and what it gives;
   - the evidence: `file:line`, a test name, a doc link, or a wrapper command with its output (`prod-db-read` or `sf-read`, aggregates only);
   - one recommendation, with the reason;
   - whether the choice is irreversible, and if so what undoes it or why nothing can.
3. For a Claude and Codex disagreement, give both positions in their own words, the receipt each side has, and the round count.
4. Put the recommendation in the `recommendation` field as one of the options, so the user can reply "go with recommendation".
5. State what keeps running while the question waits.

## Hard rules

- Never phrase a recommendation as already decided ("I will", "we are going with"). It is a recommendation until the user answers.
- Never bundle two decisions into one question.
- Never hide the irreversible flag. If you do not know, say so and treat it as irreversible.
- Never give one side only, or a strawman for the other.
- Never ask for something you can find in the code, data or docs.
- Never ask for a write to Salesforce production without saying it needs double approval.
