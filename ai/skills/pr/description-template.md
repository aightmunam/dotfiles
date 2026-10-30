# PR Body Template

Fill the pr block below. Keep the two marker lines. GitHub does not show them. They tell a later run which text `pr` wrote.

When the repo has a PR template, keep its headings and their order. Put each part of the pr block under the nearest heading. Put a part with no heading at the end, inside the markers.

```markdown
<!-- pr:start -->
## TL;DR

<1 to 3 sentences: what changes and why. Each claim has a file in the diff.>

## Summary

<one small visual, from the list below>

Core files:
- `<path>`: <what changes in it>

Mechanical files:
- `<path>`: <generated client, lockfile or Alembic revision>, or none

## Evidence

Prove doc: `<path>`, fresh at `<head_sha>`. <or: no prove doc | prove doc not fresh: reason>
- <finding title>: <VERIFIED | NOT VERIFIED | INCONCLUSIVE>, ladder step <n>. Before: <the test or behavior before>. After: <the test or behavior after>.

## Merge Danger

**Door:** <one-way | two-way>. <one sentence: why>
**Blast radius:** <one word>. <the fact from the prove doc that makes the change safe, and who feels a break>
**Rollback:** <revert the merge commit, or the steps for a one-way door>
<!-- pr:end -->
```

## Summary Visual

Use the smallest view that makes the key point clear. Use one visual. Use two only when one cannot show the point.

- Logic or an algorithm: pseudocode.
- Runtime control flow: a call tree.
- File responsibility or a broad refactor: a shallow file tree.
- Interaction or data flow: a Mermaid diagram.
- A change to a shape that exists: a `diff` block in the shape of the topic (call tree, file tree or control flow).

Keep only the calls, files, states and boundaries that a reviewer needs.

## Evidence

- Each line comes from one prove doc finding. Copy its status and its ladder step.
- Before and after: name the test or the behavior. Show a test in pseudocode, not as a command.
- Do not paste the prove doc output. Link to the doc.

## Merge Danger

- **Two-way door:** a revert undoes the change.
- **One-way door:** a destructive action or a decision that is hard to reverse, for example a data migration, a deleted column or a public API change.
- **Blast radius:** think about all consumers. Examples: callers in other modules, API clients, jobs, dashboards.
