# Review Doc Template

Grimoire and The Eye parse this doc. Keep each rule below, or the doc does not render.

## Format rules

- The frontmatter is YAML. `pr_number` is an integer. Put quotes around `head_sha`. `repo` and `head_sha` are mandatory.
- `repo` comes from `gh repo view --json nameWithOwner -q .nameWithOwner`. `head_sha` is `headRefOid` from step 1.
- Each H1 heading stays as written. Grimoire splits the doc on H1 only. `##` headings inside an H1 section are fine.
- Each finding heading is `### <ID> - <title>`. The ID is `C`, `H`, `M`, or `L` and a number: `C` critical, `H` high, `M` medium, `L` low. Use a plain hyphen. Each ID occurs one time.
- The next line is the italic summary. It starts with the ladder step: `_Ladder step <n>: <what breaks and when, in plain words>_`. Write it to the author in one sentence of at most 25 words. No rule numbers, no paths.
- Then the `~~~finding` block: a YAML head, a line that is only `---`, then the comment fence, then the detail. `line` is an integer on the right side of the diff. Put a fix in a `suggestion` fence after the detail. Never put `~~~` in the body. Never start a body line with `# `, also in a fence. Grimoire reads that line as a new H1 section. Indent a Python comment, or remove it.
- No other `###` heading goes in `# Review findings`.
- The comment fence is the text that Grimoire posts on the PR line. The detail stays in the doc. Write the comment to the author, as one colleague to another, in 1 to 3 sentences. Say what is wrong and the fix. Ask a question when the fix is a choice for the author. Start a low finding with `nit: `. Do not put ladder steps, lens names, severity words, or `Evidence:` in the comment. Do not put a fence inside it. The suggestion fence gives the code.
- Each comment obeys the unslop rules (`~/.agents/skills/unslop/rules.md`). Grimoire warns about a finding with no comment fence and about an em dash in a comment.
- Severity is `critical`, `high`, `medium`, or `low`. Put an info item in `low`.
- In `# Automated checks`, the Status cell is `pass` or `fail`. Use a different word, for example `not run`, when the check did not finish. Never put `|` in a table cell. Grimoire drops that row with no warning.
- Each mermaid block obeys the mermaid rules in `lenses.md`. If a diagram breaks a rule, fix it. Do not remove its slot.
- `# What was done` has the Before / After table and the user flow. `# How it was done` has the architecture, the primary flow, and the reading order.
- No placeholder text stays in the doc.
- `Principles applied:` lines go only in the reply, never in the doc.
- `## Lens runs` stays at the end of `# Summary`. Under `# Automated checks`, Grimoire reads each 3-column row as a check. Grimoire does not show an H1 that it does not know.
- `## Lens runs` has one row for each lens: the lens, the prompt file, and the agent id. A lens that you did yourself has `self` and the reason. A lens that did not run has `no agent` and the reason. With no file write, the prompt cell is `not written`.
- A critical or high finding has an `Evidence:` line in its body: the command and its exit code, or the file:line hops that you read.

## Writing rules outside the comment fences

The user reads the doc to understand the PR. Only the comment fences go to the author. Apply `~/.agents/skills/technical-writing/layers.md` to the rest.

- **The verdict comes first.** `# Summary` starts with the verdict list from the template. Then write 2 to 4 sentences: what the PR does and what is solid. Put nothing else before `## Lens runs`. The severity counts and the doc path go in the reply.
- **One mode for each H1.** `# What was done` is explanation. `# How it was done` is reference and follows the order of the code. `# Review findings` and `# Automated checks` are reference. `# Questions for author` is a list.
- **The finding detail is a list, not paragraphs.** Grimoire renders markdown with `breaks: false`, so two label lines with no list marker merge into one paragraph. Use the labels in the template. Put each hop of a traced failure path on its own numbered line, with its `file:line`. Leave out `Failure path:` when the finding traces no path.
- **The fix has its own label.** Do not put the severity reason or the author's context in `Fix:`.
- **Each sentence reads once.** Make each "it", "this" and "they" point at one noun. Break up long noun strings. Put "only" and "not" next to the word that they change.

## Template

````markdown
---
date: <YYYY-MM-DD>
reviewer: <your model>
repo: <owner/name>
pr_number: <integer>
pr_title: "<title>"
pr_author: "@<login>"
branch: <head branch>
head_sha: "<headRefOid>"
verdict: <approve | request_changes | comment>
status: review_complete
---

# Summary

- **Verdict:** `<approve | request_changes | comment>`. <one clause: the reason>
- **Fix before merge:** <finding ids, or "none">
- **Not checked:** <each check that did not run, or "none">

<2 to 4 sentences: what the PR does and what is solid>

## Lens runs

| Lens | Prompt file | Agent id |
|---|---|---|
| <lens> | <path, or not written> | <agent id, or self: reason, or no agent: reason> |

# What was done

<TL;DR from the What brief>

## Before / After

<table from the What brief>

## User flow

<mermaid diagram from the What brief>

## Surface changes

<bullets from the What brief>

# How it was done

## Architecture

<mermaid flowchart from the How brief>

## Primary flow

<mermaid sequenceDiagram from the How brief>

## Read the code in this order

<table from the How brief>

## Data model / contracts

<mermaid erDiagram, or "No data-model or contract changes.">

## Design notes

<bullets from the How brief>

# Review findings

### H1 - <short title>
_Ladder step <n>: <what breaks and when, in plain words>_

~~~finding
severity: <critical | high | medium | low>
category: <correctness | regression | security | performance | quality | test | devex | flag | api | intent | migration>
file: <repo-relative path>
line: <integer>
side: RIGHT
---
```comment
<1 to 3 sentences to the author: what is wrong and the fix, or a question. Low: start with "nit: ">
```

- **Problem:** <what is wrong, in 1 or 2 sentences>
- **Failure path:**
  1. `<file:line>`: <what happens at this hop>
  2. `<file:line>`: <the next hop, up to the visible failure>
- **Severity:** <why this level, and the author's context if it lowers it>
- **Fix:** <the change, in 1 or 2 sentences>
- **Lenses:** <lens names>. **Source:** <"review", or "comment by @<login>">
- **Evidence:** <for critical or high: the command and exit code, or the file:line hops that you read>

```suggestion
<optional replacement code for that line>
```
~~~

# Automated checks

| Check | Status | Notes |
|---|---|---|
| <name> | <pass or fail> | `<command with no pipe>`. Exit <code>. <short note> |
| REST API guidelines | <PASS, WARN or FAIL> | <only if the API lens ran: counts> |

# Questions for author

- <question, or "None.">
````
