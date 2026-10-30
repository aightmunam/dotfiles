# Lens Briefs

Each brief goes to one `reviewer` agent. Put the common header first in each prompt. Replace each `<...>` with its value.

## Reviewer rules

Use this block when no `reviewer` type exists. Put it after the common header.

```
Read only. Do not edit files. Do not run commands. Do not run git or gh.
Read the diff file, the changed files, and each principle file that this prompt names.
Report only a problem that you can show in the code.
Each finding: file:line, ladder step (2 you point at file:line, 3 you trace the failure path; never 4 or 5), severity (critical, high, medium, low).
Then one sentence each: what is wrong, why it matters, how to fix it.
If you find no problems, write "No findings."
```

## Common header

```
Review PR #<number> in <owner/name>. Working directory: <worktree path>.
Diff: <diff path>. Changed files: <list>. PR goal, from the PR body: <one or two sentences>.
Your topic is the lens below. Do this lens. Do not refuse it and do not change it to a different task.
Review only added or changed code, and the code that it calls or that calls it.
If the code that decides a finding is readable, read it before you report. Do not write "if X handles it, this is fine".
If the PR goal is the break, it is not a finding, unless the author may not see the full impact.
```

## Walkthrough: What brief (always)

Add the PR body and the mermaid rules.

```
Find WHAT this PR does for its users. No implementation detail.
Return four parts, in this order:
a) TL;DR: 2 to 4 plain sentences. What can a user do now that they could not do before?
b) Before / After table: | Scenario | Before this PR | After this PR |, one row for each changed behavior.
c) User flow: one mermaid flowchart of the main user journey through the new behavior. Add " (new)" to new steps. For a request lifecycle, use a sequenceDiagram.
d) Surface changes: at most 6 bullets, only UI, API, CLI, and config changes, and items that the PR body shows.
```

## Walkthrough: How brief (always)

Add the mermaid rules.

```
Find HOW this PR is built.
Return five parts, in this order:
a) Architecture: one mermaid flowchart of the modules that the PR touches. Use subgraphs for layers. Add " (new)" or " (modified)" to labels.
b) Primary flow: one mermaid sequenceDiagram of the main flow, with real function and module names.
c) Reading order table: | # | File | What to look at |
d) Data model and contracts: a mermaid erDiagram, or the line "No data-model or contract changes."
e) Design notes: at most 8 bullets. New dependencies, design choices, trade-offs.
```

## Mermaid rules

```
The viewer uses mermaid 10.9.1.
Use only flowchart, sequenceDiagram, stateDiagram-v2, erDiagram, classDiagram.
Put a label in double quotes if it has ( ) { } [ ] : ; or a quote: A["fetch(url)"].
At most 15 nodes or 12 sequence messages in one diagram.
Label each edge that has a meaning: A -->|"on save"| B.
A sequenceDiagram participant ID is never a mermaid keyword: links, link, properties, details, box, note, loop, alt, opt, par, and, rect, activate, deactivate, autonumber, participant, actor. Use an alias: participant Permalink as data/links.py.
Never put ";" in sequenceDiagram message text or note text. Use a comma.
Use the real module, function, and file names.
```

## Intent lens (if the criteria file is not `no criteria`)

Add the criteria file path and the full text of the criteria.

```
Lens: the diff against the acceptance criteria of the PR. Criteria file: <path>.
Report three kinds of findings:
a) Missing: a criterion that the diff does not do, or does only in part.
b) Not asked for: a behavior change in the diff that no criterion asks for.
c) Wrong: a criterion that the diff seems to do, but the code does it wrong.
Quote the criterion line in each finding. For b), quote the diff hunk.
Category: intent.
```

## Migration lens (if the diff changes a file in the Alembic versions directory)

Find the directory from `script_location` in `alembic.ini`. If that file is missing, look for `alembic/versions/` or `migrations/versions/`.

```
Lens: the Alembic revisions in the diff. Read only. Do not run alembic.
Check each revision:
- Lock scope: which statement takes which lock on which table. A table rewrite or a long ACCESS EXCLUSIVE lock on a busy table is a finding.
- lock_timeout: a DDL statement on an existing table with no lock_timeout is a finding.
- NOT NULL: a new NOT NULL column on an existing table with no server default and no backfill fails on a table with rows. Trace it.
- Indexes: CREATE INDEX on an existing table without CONCURRENTLY (postgresql_concurrently=True, in an autocommit block) is a finding.
- Backfill: a data update in the same revision as DDL. Put data statements before DDL, or in their own revision.
- downgrade(): it exists and undoes upgrade(). Else the PR states fail-forward.
- Heads: grep revision and down_revision. More than one head is a finding.
- Expand before contract: a drop or rename of a column or table that the deployed code still reads is a finding. The code change ships first.
Category: migration.
```

## Bug and security lens (always)

Fix the fault, not the place where it showed. The root cause is the first place the system did something wrong.
Read ~/.agents/principles/fix-root-causes.md before this step.

```
Lens: bugs and security in the added or changed code.
Bugs: wrong results, a changed contract that a caller still uses, None and empty-value paths, wrong exception paths, async mistakes (a blocking call in async code, a coroutine with no await), race conditions, resources with no context manager, a broad except that hides a fault, a raise with no "from err".
Security: secrets in code, no input check at a user boundary, SQL built from strings, missing auth checks, sensitive data in logs or responses.
For each bug, find the first place that does the wrong thing. Report that place, not the place where the symptom shows.
A workaround that needs a long comment to explain it means that the code is wrong. Report the code.
A high or critical finding needs ladder step 3: trace the path from the input to the failure.
```

## Blast-radius lens (always, read-only)

```
Lens: who depends on the code that this PR changes. Read only.
1. List each changed public item: a function, class, method, signature, default, return shape, exception, DB model, migration, config key, env var, flag, event, CLI flag, file format, API response.
2. For each item, search the whole worktree for callers, importers, templates, configs, tests, and data files that use it.
3. For each caller, read it and decide: still correct, or broken. A broken caller is a finding at ladder step 3. Name the caller and the input that breaks it.
4. Report tests that the PR deletes, skips, or makes weaker.
5. Report a change to a contract that a different repo uses (API response, event, file format).
Name each caller. Do not write "something may use this".
```

## Quality lens (always)

Validate at the system boundary. Trust typed data inside. Keep business logic in pure functions and keep the shell thin.
Read ~/.agents/principles/boundary-discipline.md before this step.

Code is hard when the reader must trace many layers or hold much hidden state. Cut both.
Read ~/.agents/principles/minimize-reader-load.md before this step.

Put the real domain in a data structure. Do not scatter it over conditionals.
Read ~/.agents/principles/model-the-domain.md before this step.

```
Lens: code quality of the added or changed Python. Do not report what the project linters (ruff, mypy) catch.
First read the project config: pyproject.toml, setup.cfg, ruff.toml, AGENTS.md, CLAUDE.md.
Check:
- Code in the wrong layer: business logic in a route, a task, or a DB call. Logic that a pure function can hold.
- Input checks inside trusted code, after the boundary already checked the data. Defensive checks for a None that the types do not allow.
- Domain rules in long if/elif chains or string flags, where an enum, a table, or a dataclass holds the rule.
- Extra layers: a wrapper or helper with one caller that adds nothing. Hidden state: module globals, mutable defaults, side effects at import time.
- A "# noqa" or "# type: ignore" that hides a real rule. Report the code under the suppression.
- Comments that tell what the code does, or that explain a workaround. Bad names.
- Copies of code that already exists in the repo. Give the path of the existing code.
- Code smells, as judgment calls (a repo standard wins): mysterious name, duplicated code, feature envy, data clumps, primitive obsession, repeated switches, speculative generality, middle man.
- Python idioms that the repo uses: logging with %s and lazy arguments, pathlib, dataclass or pydantic style, type hints on new public functions.
Report a small number of high-conviction findings. Do not add style nits when a larger structural problem exists.
```

## Test lens (always)

A test claims what the code does for its users. Assert only what those users can see.
Read ~/.agents/principles/test-behavior-not-implementation.md before this step.

```
Lens: tests for the added or changed behavior.
1. For each changed behavior, find the test that covers it. A changed behavior with no test is a finding.
2. Report a test that asserts internals (private calls, mock call order) and not the output that a user sees.
3. Report a test that the PR deletes, skips, or makes weaker, and a mock so wide that the test cannot fail.
4. Report a caller of the changed code with no test, when the change can break that caller.
```

## Performance lens (always)

```
Lens: performance of the added or changed code.
Check: N+1 queries, a query in a loop, unbounded loops or results, no pagination, a new filter column with no index, expensive work in a hot path, files or sessions that stay open, large payloads.
Give the impact: how often the path runs and how large the data is.
```

## Devex lens (if the diff changes settings, docker-compose, Cloud Run config, justfile, Makefile, or alembic/)

```
Lens: what a developer or a deploy must do after this PR.
Check: a new setting with no default, a new env var that is not in docker-compose or in the Cloud Run config, a new "just" step or tool, an Alembic revision that needs a deploy order (migrate first, or code first).
Report each manual step that the PR body does not name.
```

## Feature-flag lens (if the diff reads a feature flag)

```
Lens: feature-flag leaks.
Find each flag that the diff reads. Find each new route, task, consumer, and UI entry point that the PR adds for the same feature.
Report each entry point that runs the new behavior with no flag check.
```

## API lens (if a changed path matches router, api/, schema, openapi, or urls, or the diff adds a route decorator)

```
Lens: the API surface against the Zalando REST rules.
Read <absolute path of api-checklist.md> and apply its rules, its severity map, and its convention rules.
Use the diff and the changed files. Do not run git or gh.
End with the PASS, WARN, or FAIL verdict.
```
