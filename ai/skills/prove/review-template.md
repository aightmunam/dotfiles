# Review Doc Template

Grimoire parses this doc. Keep each rule below, or the doc does not render.

## Format rules

- The frontmatter is YAML. Put quotes around each SHA and hash.
- Each H1 heading stays as written. Grimoire splits the doc on H1 only.
- Each finding heading is `### <ID> - <title>`. The ID is `C`, `H`, `M`, or `L` and a number: `C` critical, `H` high, `M` medium, `L` low. Use a plain hyphen.
- The next line is the italic summary. It starts with the ladder step: `_Ladder step <n>: <what breaks and when, in plain words>_`.
- Then the `~~~finding` block: a YAML head, a line that is only `---`, then the body. `line` is an integer. Put command output in backtick fences. Never put `~~~` in the body.
- No other `###` heading goes in `# Review findings`.
- In `# Automated checks`, the Status cell is `pass` for VERIFIED, `fail` for NOT VERIFIED, and `inconclusive` for INCONCLUSIVE. Put the outcome word in Notes.
- Never put `|` in a table cell. Grimoire drops that row with no warning. Put a command that holds `|` in a fenced block under the table, and name its check in Notes.

## Template

````markdown
---
kind: self-review
date: <YYYY-MM-DD>
reviewer: <your model>
repo: <owner/name, or the directory name>
branch: <branch>
base_sha: "<git merge-base <base> HEAD>"
head_sha: "<git rev-parse HEAD>"
diff_hash: "<first field of git diff <base_sha> | shasum>"
plan: <plan path>
outcome: <VERIFIED | NOT VERIFIED | INCONCLUSIVE>
verdict: <approve if VERIFIED | request_changes if NOT VERIFIED | comment if INCONCLUSIVE>
status: review_complete
---

# Summary

<outcome in one sentence>. Intent: <one sentence>.

# What was done

<2 to 4 sentences: what the diff changes, also the part that the diff does not show>

## Safety fact

<the fact>. Ladder step <n>.
Command: `<command>`
```
<output>
```

## Blast radius

- <caller or consumer, file:line>: <cleared or broken>, <check name or finding id>

# Review findings

### H1 - <short title>
_Ladder step <n>: <what breaks and when, in plain words>_

~~~finding
severity: <critical | high | medium | low>
category: <correctness | regression | test | api | performance | security | quality>
file: <repo-relative path>
line: <integer>
side: RIGHT
---
Command: `<exact command>`

```
<output that it printed>
```

Expected: <output that the intent needs>
Outcome: NOT VERIFIED
Found by: <adversary models, or "parent">. Rerun by parent: <yes, at diff_hash>
~~~

# Automated checks

| Check | Status | Notes |
|---|---|---|
| <name> | <pass, fail, or inconclusive> | `<command with no pipe>`, or "command below". Exit <code>. <VERIFIED, NOT VERIFIED, or INCONCLUSIVE>. <gap, if any> |

<name>:
```
<command that holds a pipe>
```

# Questions for author

- <decision template from SKILL.md step 6, one item each, or "None.">

# Dropped

- <adversary>: <count> dropped. <reason for each>

# Attention

reviewed by <model of each adversary>, or: reviewed by <your model> (adversary: inline, <reason>)

- <flag> -> <finding id, check name, or section>

Principles applied: prove-it-works -> <choice it changed>
````
