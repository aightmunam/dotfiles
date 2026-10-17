# Investigation Template

Your answer is this template, filled in, with these seven numbered headings in this order. A short summary for the reader (the channel reply, the recommendation) may go above heading 1; it never replaces a section. Leave a section empty only by writing why.

## 1. Facts

| ID | Fact | Source | How gathered | Instances | Signal / Noise |
|---|---|---|---|---|---|
| F1 | | | | | |

- Rows come from gatherer output, copied verbatim, one row per returned row, all six columns filled (see `subagent-roles.md`). Do not merge, condense or drop rows; the row count matches what the gatherers returned. A row with an empty Source or How gathered cell is not a fact yet: send it back or re-gather it.
- How gathered is concrete: "read file X, unsorted", "query Q over 24h", "customer's own words in ticket". "From the ticket" alone names a source, not a method.
- What code *says* is not a fact about what *ran*. Code readings go in the matrix as hypotheses, never in this table.
- Facts are never edited or argued away. If you doubt how one was gathered, say so to whoever gathered it and keep the row.
- Same fact type from several instances beats one instance. Turn comparisons into numbers: counts, bytes, latencies, timestamps.

**Facts I still need** (each one tied to the rows it would split):

| Needed fact | Cheapest source | Splits rows |
|---|---|---|

## 2. Variable and control

- **Variable:** the failing case.
- **Control:** a case that works, or fails differently and more loudly. Prefer one already present in the data.
- **Why the control is trustworthy:** how its facts were gathered, and why it is not broken the same way.
- **No clean control?** Use the best case already in the data (an outlier report, a run that fails differently) and state its weakness.
- Mark each fact **signal** (variable only) or **noise** (both). Noise can eliminate a hypothesis but never suggests one.

## 3. Matrix

| Hypothesis | F1 | F2 | ... | Verdict |
|---|---|---|---|---|
| H1 (from input) | Y | N (F2: ...) | ? | discarded |

- One row per changed component, proposed cause, repro, and review conclusion in the input, plus your own. A candidate you think is irrelevant still gets a row and leaves only by a cited `N`.
- `N` cells cite the fact. `?` cells name the fact needed.
- `Y` needs no unconfirmed mechanism; if it does, write `?` and name the mechanism. Same standard on every row.
- Every cell is one an eliminator returned. A row added after review gets its own eliminator; a cell a reviewer disputes goes back to an eliminator with the reviewer's cited fact. You never change a cell yourself, and you never drop a fact column from the reading to get around inconsistent cells: re-send every disputed row.
- Strongest signal (column with fewest `Y`): ...

## 4. Tactics (only if no row is all `Y`)

1. Re-checked how facts were gathered: ...
2. Split: ...
3. Merged: ...
4. Combined (show that removing each cause leaves a fact unexplained): ...
5. New hypothesis, and the facts it is built from: ...

## 5. Layer descent (only if signals are weak or rows remain tied)

Layers, shallow to deep: report and metrics, then request logs and traces, then component logs and config, then process state (thread dumps, profiles), then system (kernel, network, DNS). Go one layer at a time, cheapest first, and stop at the first strong signal.

## 6. Adversarial checklist

- **Signals:** Is any "signal" also present in the control? Could the control be broken the same way? How was each fact gathered?
- **Hypotheses:** How many rows fit each signal? Were tactics 2 to 4 tried before a new hypothesis? Was going a layer deeper justified?
- **Validation:** Name one fact that would contradict the survivor and check it. Does every claim cite a fact? For combined hypotheses, remove each cause in turn: does a fact go unexplained?
- **Repro:** Does it show the strongest real signal, line for line?
- **Reviews:** Did the reviewer see the facts, or only the conclusion? Same model and context means one opinion.

**Reviewer findings** (one row per finding, from every reviewer):

| Reviewer | Finding (cites fact) | Re-sent to | Returned | Matrix change |
|---|---|---|---|---|

- Re-sent to names the eliminator dispatched for it: a new row's eliminator, or the disputed row's eliminator with the reviewer's cited fact. Returned is that eliminator's cells. A finding about facts or the control is re-sent to a gatherer instead.
- "Pending", "open" and "not re-run" are not valid values. Section 7 is written only after every row here has a Returned cell.

## 7. Required outputs

- **Conclusion:** confirmed cause with fact citations, or the surviving rows and the fact that would decide between them.
- **Decision points for a human:** every option (mitigate, fix, roll back, escalate) with tradeoffs and what each assumes. Note any decision that should become standing policy.
- **Fix status:** confirmed, or unconfirmed with its open `?` cells.
- **Verification:** how the winning signal becomes a check, as signal parity against a known-good run, not just pass/fail.
- **Emit the signal:** what to log or measure at the shallowest layer so the next investigation sees this signal without descending.
- **Intervention log:** every point where a human had to supply a fact, a control, or a correction, and what would have let you do it yourself.
  - **Dispatch:** each role run as a subagent (role, scope, verdict), and each role done inline with the reason.
