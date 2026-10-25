---
name: fact-constrained-debugging
description: Use when debugging code you or another agent wrote but no longer understand, when a bug arrives with logs, traces, user reports or telemetry, when a regression, latency or error spike appears after a deploy, during an on-call incident or a request for a quick patch to a live problem, when a bug is intermittent with no reliable repro, or when a repro, proposed fix, or review is presented as already confirming the cause.
---

# Fact-Constrained Debugging

## Overview

**Facts** come from outside you (logs, traces, configs, deploys, user reports) and are fixed. Everything you derive (hypotheses, repros, reviews, code readings) must satisfy **every** fact; one contradiction discards it. Code shows what *can* happen, not what *did*: read it last.

Adapted from Cindy Sridharan (2026). Complements superpowers:systematic-debugging's root-cause phase.

## The Loop

**First, read `investigation-template.md`.** Your answer fills all seven sections in order; one that does not apply says why.

**If you have a subagent dispatch tool, also read `subagent-roles.md`.** Every role runs as a subagent however small the sources; isolation from your context is the point. Without one, run each role yourself.

1. **Facts** (gatherers). Gather read-only yourself; ask a human only for what you cannot reach, and log the ask.
2. **Variable and control.** "No control" is not an option: use the best case in the data and state its weakness.
3. **Matrix** (eliminators). Every candidate in the input plus yours; every fact a column. `Y` only without an unconfirmed mechanism, same standard on every row.
4. **Read it.** Strongest signal: the column with fewest `Y`. Any `N` discards a row.
5. **No row survives:** run the tactics in order (template section 4).
6. **Too many survive, or signals are weak:** stop hypothesising. Get the one fact that splits the rows, one layer down, cheapest first.
7. **Validate** the survivor against every fact, noise included.
8. **Eliminate adversarially** (Signals and Hypotheses reviewers always; Validation when a row survives). Ask for contradicting facts, never agreement.
9. **Close** with the required outputs.

## Rules That Shape Claims

- **Cite or label.** Every claim names its fact ID. A link supported only by code or reasoning is `UNCONFIRMED (code-only)` and ranks below fact-backed rows.
- **Minorities are constraints.** An outlier report must be satisfied too, or it is your strongest signal.
- **A repro is a hypothesis** until it shows the strongest real signal, line by line.
- **Fix vs mitigation.** Mitigate first if needed. A fix with open `?` cells is unconfirmed and never closes the report.
- **Decisions belong to humans.** Present every option with tradeoffs.

## Red Flags

- A candidate disappears without a cited `N`.
- A fact column is left out of the reading, or a disputed cell is resolved by you instead of re-sent to an eliminator. Inconsistent cells mean re-check, never exclude.
- The control is "the other customers" with no reason to trust it.
- Agreement, "it reproduces", or a deadline is doing a fact's work.
- Reading code instead of getting the splitting fact.
- You had a dispatch tool and did a gatherer or reviewer's job yourself.

Any of these: return to the matrix.
