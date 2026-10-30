---
name: research
description: Use when you must learn how code works before a change. Use when the user asks how X works or what breaks if X changes, and wants it written up. Use when a question spans several repos or needs the history of code that a change will touch.
---

# Research

## Definitions

- **Claim:** one statement about the code or its history.
- **verified:** you read the cited line, or you ran the command, in this session.
- **inferred:** you concluded it but did not read or run it. Write the reason.
- **Constraint:** a verified fact that a change must keep true, with the code that depends on it.
- **Recommendation:** a fix, an option, or a "should". The document has none.

## The Loop

**First, read `document-template.md`.** Your document fills it in order.

1. **Scope.** Write your reading of the question in one sentence. Name each repo and the repo where the change lands.
2. **Anchor.** For each repo, run `git fetch origin`, then `git rev-parse origin/main` (or `origin/master`) and `git rev-parse HEAD`. Claims describe the local HEAD. Record the SHA as `origin_main` always, and as `head` when HEAD differs. If the fetch fails, say so in the Question section.
3. **Gather.** A narrow question (one repo, a few files): read the code yourself. A wide question: give 2 to 4 angles per repo to `explorer` agents in one message. Each prompt holds the question, one angle, the absolute repo path, and the HEAD SHA. If no `explorer` type exists, give a general-purpose agent the explorer report sections from the template. With no dispatch tool, do each angle yourself.
4. **Verify.** Open each file that you cite. A claim that you did not read is `inferred`.
5. **History (optional).** Do this step when the change touches code with an unclear reason. Use `git log`, `git blame`, `gh pr view`, and Jira or Sentry when you have them. Record each search, also the searches that found nothing.
6. **Write.** Fill the template. Put the doc in `thoughts/shared/research/YYYY-MM-DD-<topic>.md` of the repo where the change lands. `<topic>` is kebab-case, 3 to 6 words. Create the directory if it is missing. In a worktree, use the `thoughts/` of the main checkout (`git rev-parse --git-common-dir`, then its parent). If you cannot write files, put the full document in your answer and name its path.
7. **Red flags.** Read the document once for each red flag below.
8. **Reply.** Runs inline by default. If a caller dispatched you as a fresh agent, reply with the document path and at most 5 bullets. Use the reply shapes in the template, and nothing else. The last line of each reply is `Principles applied: none`, or one `<name> -> <choice it changed>` for each principle file that you read.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Rules That Shape Claims

- **Tag or cut.** Each claim ends with `[verified path:line symbol]` or `[inferred: reason]`.
- **Describe, do not recommend.** The document is reference and explanation. A risk is a fact about what breaks, with its file and line, and not a fix.
- **Code shows what runs, not why.** A reason in History comes from a commit, PR, ticket, or comment text. Quote it and cite it.
- **The user's guess is a candidate.** Verify it against the code like any other claim.
- **An empty search is a finding.** Write what you searched: History searches under History, all others under Open questions.

## Red Flags

- A claim with no tag.
- "should", "recommend", "consider", "better", "fix", or "option" in your own sentences (not in quotes or code spans).
- No `origin_main`, or HEAD differs from `origin_main` and `head` is missing.
- A cited file that you did not open in this session.
- A History reason that you read from the code.
- An explorer claim that you copied and did not verify at its file and line.

Any of these: go back to the step that owns it (anchor: step 2, History: step 5, all others: step 4) and change the document.
