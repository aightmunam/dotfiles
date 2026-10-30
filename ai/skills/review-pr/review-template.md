# Review Doc Template

Grimoire and The Eye parse this doc. Keep each rule below, or the doc does not render.

## Format rules

- The frontmatter is YAML. `pr_number` is an integer. Put quotes around `head_sha`. `repo` and `head_sha` are mandatory.
- `repo` comes from `gh repo view --json nameWithOwner -q .nameWithOwner`. `head_sha` is `headRefOid` from step 1.
- Each H1 heading stays as written. Grimoire splits the doc on H1 only. `##` headings inside an H1 section are fine.
- Each finding heading is `### <ID> - <title>`. The ID is `C`, `H`, `M`, or `L` and a number: `C` critical, `H` high, `M` medium, `L` low. Use a plain hyphen. Each ID occurs one time.
- The next line is the italic summary. It starts with the ladder step: `_Ladder step <n>: <what breaks and when, in plain words>_`. Write it to the author. No rule numbers, no paths.
- Then the `~~~finding` block: a YAML head, a line that is only `---`, then the body. `line` is an integer on the right side of the diff. Put a fix in a `suggestion` fence in the body. Never put `~~~` in the body. Never start a body line with `# `, also in a fence. Grimoire reads that line as a new H1 section. Indent a Python comment, or remove it.
- No other `###` heading goes in `# Review findings`.
- Severity is `critical`, `high`, `medium`, or `low`. Put an info item in `low`.
- In `# Automated checks`, the Status cell is `pass` or `fail`. Use a different word, for example `not run`, when the check did not finish. Never put `|` in a table cell. Grimoire drops that row with no warning.
- Each mermaid block obeys the mermaid rules in `lenses.md`. If a diagram breaks a rule, fix it. Do not remove its slot.
- `# What was done` has the Before / After table and the user flow. `# How it was done` has the architecture, the primary flow, and the reading order.
- No placeholder text stays in the doc.
- `Principles applied:` lines go only in the reply, never in the doc.
- `## Lens runs` in `# Summary` has one row for each lens: the lens, the prompt file, and the agent id. A lens that you did yourself has `self` and the reason. A lens that did not run has `no agent` and the reason. With no file write, the prompt cell is `not written`.
- A critical or high finding has an `Evidence:` line in its body: the command and its exit code, or the file:line hops that you read.

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

<!-- optional: your own summary of the PR -->

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
<what is wrong>. <the failure path, with file:line for each hop>. <the fix>.
Lenses: <lens names>. Source: <"review", or "comment by @<login>">
Evidence: <for critical or high: the command and exit code, or the file:line hops that you read>

```suggestion
<optional replacement code for that line>
```
~~~

# Automated checks

| Check | Status | Notes |
|---|---|---|
| <name> | <pass or fail> | `<command with no pipe>`. Exit <code>. <short note> |
| Zalando API guidelines | <PASS, WARN or FAIL> | <only if the API lens ran: counts> |

# Questions for author

- <question, or "None.">
````
