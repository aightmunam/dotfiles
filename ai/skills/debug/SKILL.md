---
name: debug
description: Use when something is broken and the cause is not known. Use when a test fails only some of the time, or a bug has no reliable repro. Use when a bug arrives with logs, traces, user reports or telemetry. Use when a regression, a latency spike or an error spike follows a deploy. Use during an on-call incident, or when someone asks for a quick patch to a live problem. Use when you debug code that you or another agent wrote but no longer understand. Use when a repro, a fix or a review claims to show the cause already.
---

# Debug

## Definitions

- **Fact:** a thing from outside you, such as a log, a trace, a config, a deploy, a run output, or a user report. Facts do not change.
- **Derived claim:** a hypothesis, a repro, a review, or a code reading. It must agree with every fact. One contradiction discards it.
- **Red loop:** one command that you ran at least once. It drives the real code path and asserts the user's exact symptom. It gives the same verdict on each run, in seconds, with no human.
- Code shows what can happen, not what did happen. Read it last.

## The Loop

**First, read `investigation-template.md`.** Your answer fills all of its sections in order. A section that does not apply says why.

**If you have a subagent dispatch tool, also read `subagent-roles.md`.** Give each role to a subagent. Do this also when the sources are small. Isolation from your context is the point. With no dispatch tool, do each role yourself.

1. **Red loop.** Build the red loop before you write a hypothesis or a fix. Build it from the test command and the symptom. Do not read the suspect code yet. Run the loop on the unchanged code, and show its red output, before any patch. For a flaky bug, pin the random input (seed, hash seed, clock, order), or run the trigger many times. Record the red rate. The loop output is fact F1. If real attempts give no loop, list the attempts. Then mark each cause and each fix `UNCONFIRMED (no loop)`.
2. **Facts** (gatherers). Gather read-only, and do it yourself. Prefer facts from the environment where the bug occurred. Ask a human only for a source that you cannot get to, and write each ask in the intervention log.
   - Local sources: run output, logs, local DB state, configs, and `git status`, `git log` and `git diff`.
   - Prod sources, reads only: Sentry (issue, events, release) when you have it. Cloud Logging: `gcloud logging read` with a time window and a service filter. Prod data only through read paths: Metabase and read APIs. Camunda read tools for process state. Deploy history: `gh api repos/<owner>/<repo>/deployments`, with the owner and the repo from `git remote get-url origin` (do not guess them), `gh run list` for the deploy workflow, and `gcloud run revisions list`.
   - First, list the tools that you have. Query each source that applies. Write each source that you cannot get to as a gap in template section 1. An empty result is a fact.
3. **Variable and control.** Use the best control in the data, and write its weakness.
4. **Matrix** (eliminators). Give a row to each candidate in the input, each failed fix, and each of yours. Make each fact a column. A `Y` needs no unproven mechanism.
5. **Read it.** The strongest signal is the column with the fewest `Y`. Any `N` discards a row.
6. **No row survives.** Do the tactics in order (template section 4).
7. **Too many rows survive, or the signals are weak.** Stop the hypotheses. Get the one fact that splits the rows, one layer down, cheapest first.
8. **Replay the survivor.** Run its path through the red loop against the real code, one step for each action. The loop must go red on that path, and green when you remove the cause. If not, suspect the hypothesis until you show that it is right. Then validate the survivor against every fact, noise included.
9. **Attack the premise.** When two fixes that share one premise fail the same gate, test the premise. Do not write a third fix. Count the failed fixes in the input too. Write the premise in one sentence. Look at how the failures spread, not only at their size. Read ~/.agents/principles/attack-the-premise.md before this step.
10. **Pick the fix.** Fix the fault, not the place where it showed. Ask if the state that caused the symptom is legitimate. A failure only after a restart points at saved state first. Find each place with the same fault. Name a cheap log or metric that shows the cause at first look. Read ~/.agents/principles/fix-root-causes.md before this step.
11. **Fix.** Write the regression test at the real seam. Watch it fail. Make one change. Run the test and the red loop again.
12. **Eliminate adversarially.** Use the Signals and Hypotheses reviewers always. Use the Validation reviewer when a row survives. Ask them for facts that contradict, never for agreement.
13. **Close** with the required outputs. The last line is `Principles applied:` with each principle and the choice that it changed.

## Rules That Shape Claims

- **Cite or label.** Each claim names its fact ID. A link that only code or reasoning supports gets the label `UNCONFIRMED (code-only)`. It ranks below rows that facts support.
- **Minorities are constraints.** An outlier report must fit too, or it is your strongest signal.
- **A repro is a hypothesis** until it shows the strongest real signal, line by line.
- **Redact.** Quote only the lines that carry the signal. Replace each secret, token, and item of customer personal data (names, emails, phone numbers, addresses) with `<REDACTED>`. Do this before the text goes into the answer, a subagent prompt, or a reply. Keep a credential in an env var, not in a command that you show. If the redacted text cannot show the signal, write that as a gap.
- **One change at a time.** Never put two fixes in one run.
- **Fix or mitigation.** Mitigate first if necessary. A fix with open `?` cells stays open and does not close the report.
- **Decisions belong to the user.** Give each option with its tradeoffs. Reversible work, such as a local fix or a test, needs no question. A merge or push to main/master, or a production write, needs the user's OK.
- **No user present** (a headless run, a dispatch). Do not ask and do not wait. Write each assumption in the intervention log, and continue. With a user present, ask one question in each message, with a recommended answer.

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- You wrote a hypothesis or a fix before the red loop ran. Go back to step 1.
- One command ran the loop and a patch together. Go back to step 1.
- A candidate leaves the matrix without a cited `N`. Go back to step 4.
- You left out a fact column, or you settled a disputed cell yourself. Send it to an eliminator. Go back to step 4.
- The control is "the other users", with no reason to trust it. Go back to step 3.
- A prod source applies, but the answer does not show it as a fact or as a gap. Go back to step 2.
- Quoted text holds a secret, a token, or customer personal data. Replace it with `<REDACTED>`. Go back to step 13.
- Agreement, "it reproduces", or a deadline does the work of a fact. Go back to step 4.
- You read code when you needed the splitting fact. Go back to step 7.
- You plan a third fix on the same premise. Go back to step 9.
- You had a dispatch tool, but you did a gatherer or reviewer job yourself. Go back to that step.
- You did the roles yourself because the repo, the sources or the budget is small. Size is not a reason. Go back to that step.
- Your answer ends with a question, and no user is present. Go back to step 13.
