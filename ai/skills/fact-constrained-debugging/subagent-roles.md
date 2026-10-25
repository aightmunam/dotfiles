# Subagent Roles

You are the orchestrator. You own the fact table and the matrix; subagents feed facts in and send verdicts back. There are only two kinds of job: **gather** and **eliminate**. No subagent is ever asked to confirm, rank, or agree.

Every prompt you send contains only what is listed for its role. It never contains your narrative, your ranking, your favourite hypothesis, or which hypothesis you expect to survive. A subagent that sees your conclusion is one opinion counted twice.

One subagent per source, per hypothesis, per reviewer row. Never put two roles, two sources, or two reviewers in one prompt: a combined reviewer sees every artifact and loses the scoping.

Dispatch independent subagents of the same role together, in one message, so they run in parallel. For the general mechanics of parallel dispatch, see superpowers:dispatching-parallel-agents.

## 1. Fact gatherer (one per source)

**When:** loop step 1, once per source: each log set, each config, each trace or metric, each report bundle, change history. A source you cannot reach goes in the intervention log, not to a gatherer.

**Prompt contains, in order:**
1. The one source to read (path, query, or command), and that access is read-only.
2. The output contract below.
3. "Report what the source shows. Do not explain it, do not guess causes, do not suggest fixes."

**Returns:** rows of `fact | source | how gathered | instances`. "How gathered" says exactly how the gatherer got it (file read, query text, sorted or unsorted, sampled or complete). Anything odd about the source itself (gaps, ordering, truncation) is its own row.

**You then:** copy rows into the fact table verbatim and assign IDs. A row with a cause, a guess, or a missing "how gathered" goes back to the gatherer.

## 2. Hypothesis eliminator (one per matrix row)

**When:** after you build the matrix (step 3), once per row not already discarded by a cited `N`. Also for every candidate from the input you think is irrelevant.

**Prompt contains, in order:**
1. The full fact table.
2. One hypothesis, stated neutrally. Not the other rows, not your ranking.
3. "Find a fact in this table that contradicts the hypothesis. Mark each fact Y, N, or ?. A Y that needs an unconfirmed mechanism is ?, naming the mechanism. Cite fact IDs."

**Returns:** one cell per fact, and either a cited `N` or "no contradicting fact found", listing every fact checked. Put this legend in the prompt verbatim: `Y` = the hypothesis explains this fact with no unconfirmed mechanism; `N` = this fact contradicts the hypothesis; `?` = not decidable from the table, naming the missing fact or mechanism.

**You then:** fill the row from the returned cells. If you disagree with a cell, the disagreement is about a fact: re-check that fact, don't overrule the cell.

## 3. Step reviewer (one per step, at loop step 8)

**When:** once the survivor is validated. Three reviewers, each scoped to one step and given only that step's artifact.

| Reviewer | Gets | Asked to find |
|---|---|---|
| Signals | Fact table, variable, control, signal/noise marks | A "signal" also present in the control; a reason the control may be broken the same way; a fact whose "how gathered" makes it unreliable |
| Hypotheses | Fact table, full matrix | A signal more rows fit than claimed; tactics 2 to 4 skipped before a new hypothesis; a layer descent without cause |
| Validation | Fact table, the surviving hypothesis, its citations | One contradicting fact; an uncited claim; for a combined hypothesis, a cause that can be removed without leaving a fact unexplained |

**Returns:** each finding with the fact ID it rests on, or "nothing found" with the list of what was checked.

**You then:** any finding sends you back to the step it names. A row a reviewer adds goes to a new eliminator; a cell a reviewer disputes goes back to an eliminator with the reviewer's cited fact. The matrix only holds cells an eliminator returned.

## 4. Repro runner (only when the input gives steps to reproduce, or a repro is offered)

**Prompt contains:** the steps, the strongest signal from the real reports, written as the exact observable (log line, value, sequence), and read-only or sandbox limits.

**Returns:** the repro's output and a line-by-line comparison with the strongest signal: present, absent, or different.

**You then:** a repro without signal parity is a separate bug. Record it as such, not as confirmation.
