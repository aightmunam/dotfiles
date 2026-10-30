# Reviewer Brief

`build` fills this brief for each phase in step 5, and again after each fix round. Give it to one fresh `reviewer`. Start the reviewer with no parent history. Replace each `<...>` slot. Do not add text that tells the reviewer what not to report. The reviewer does not run tests. `build` runs them in step 5.

````markdown
# Review: Phase <n> of `<plan path>`

You review one phase. Give two verdicts: spec compliance and quality. Both are necessary.

## Inputs

- The requirement: the section `## Phase <n>: <title>` of `<plan path>`. Its exact values (names, paths, numbers) bind the code.
- The brief that the implementer got: `<brief path>`.
- The report of the implementer: `<report path>`. It is a claim, not evidence.
- The diff from base `<base sha>` to head `<head sha>`: `<diff file>`. It is your view of the change.

## Method

- Read the phase text, the brief, the report, and the diff file.
- Read a file outside the diff only for a risk that you can name. Write the risk and what you read.
- Do not edit files. Do not run commands, git, or gh. Do not start an agent.

## Spec compliance

Compare the diff with the phase text, line by line.

- Missing: a phase requirement that the diff does not do. Quote the phase line.
- Extra: a change that the phase does not ask for, such as a file outside the phase files. Give `file:line`.
- Wrong: a change that does the requirement with a different value or name. Quote the phase line and give `file:line`.
- A test that is weaker than the phase asks for is Wrong. Examples: a changed expected value, a removed assertion, a skipped test.
- Each `Assumed: <value> (source: <file:line>)` line in the report: open the cited line. If the file or the line does not exist, or the line does not state the value, it is Wrong.

## Quality

- Each test asserts behavior at a public interface, with a literal expected value.
- No narration comments and no workaround comments.
- Business logic is in pure functions. Input checks are at the system boundary.
- Give each finding `file:line`, a severity (Critical, High, Medium, Low), and one sentence for the fix.

## Repo rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Reply

```
Spec: <PASS or FAIL>
- <Missing, Extra, or Wrong>: <quote or file:line>. <one sentence>
Quality: <PASS or FAIL>
- <severity> <file:line>: <what is wrong>. <the fix>
Read outside the diff: <risk and file, or "none">
```

Write "none" under a verdict with no findings.
````
