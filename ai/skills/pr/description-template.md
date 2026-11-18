# PR body template

## Drafting steps

1. Read `~/.agents/skills/unslop/SKILL.md` and `~/.agents/skills/unslop/rules.md`.
2. Complete `api-contract.md` when an endpoint changes. Use its stop rule for an unresolved contract gap.
3. Draft the body below from the verified facts.
4. Apply `unslop` to the finished draft. Keep the bullets and the field labels. Keep its change list outside the body.

## Body

Write for a reviewer who has not seen the chat. Simplicity comes first.
Each section opens with at most one lead line. Write everything else as bullets.
Put one fact in each bullet. Fragments are fine. Split a bullet over 25 words.
Use nested bullets for the parts of one item, such as the field rules of one endpoint.
Use the repository terms. Cut a word when the bullet keeps its meaning without it.
Keep each crucial detail: each API change and its status codes, each verification gap,
the merge danger, and each prod step. Do not cut these to save words.
State a fact once. A flow block that shows the status codes needs no bullet that repeats them.
A small change can be one lead line and three bullets.

On an update, rewrite the pr block from the current facts. Replace each stale line.
Do not append a sentence about the newest change to an older line.

Keep the markers. A later run uses them to preserve text written by the user.
Keep repository template headings and their order when a template exists.
Map the content below to those headings. Omit optional sections that add no useful fact.

```markdown
<!-- pr:start -->
## Summary

<One lead line: what changes. Add the before when it explains why.>

- <How it works, one fact per bullet. Include a decision the diff alone does not explain.>

<Call-flow sketch when runtime order or error mapping needs explanation.>

<API contract section in the form required by `api-contract.md`.>

<Optional Evidence section under the conditions below.>

## Merge danger

- **Door:** <one-way or two-way, with the reason>
- **Blast radius:** <affected callers and behavior>
- **Rollback:** <the actual rollback path or its limit>
- **Prod:** <each step or risk of the prod deploy as a sub-bullet, or omit when there is none>
<!-- pr:end -->
```

## Visual choice

Read `show-me.md` before choosing a visual. Use the installed `show-me` skill when available.
The local reference keeps this workflow usable when that skill is absent.

Keep only the calls, files, states, and boundaries needed to understand the change.
Label a sketch as conceptual when it is not the actual code.
Use Markdown that GitHub can render. Keep HTML explainers outside the body.
A visual must replace repeated prose.
For endpoint changes, show call order and error mapping in a compact call tree when they matter.
Keep that tree alongside the OpenAPI change. Each explains a different part.
Use the actual call names. Keep annotations for validation, upstream calls, and shared helpers.

## Evidence and risk

Use an Evidence section only for a concrete before and after, or a material verification limit.
Omit routine unit-test, integration-test, lint, build, and contract-test pass summaries and links.
A useful note can show a staging flow, a manual reproduction, a measured result, or a missing check.
Keep the note only when CI does not already show it.
State the observed behavior. Make the note self-contained.
Omit Evidence when routine CI results are the only evidence.
Keep a failed check or a material coverage gap visible even when CI reports it.
Use the prove doc as internal input. Keep its name, path, links, and terminology outside the PR body.
Keep each unresolved finding and inconclusive check visible in plain words.
Distinguish observed behavior from a test run. Never invent a before run.
Translate internal outcome labels and finding IDs into plain descriptions.
Keep proof hashes, ladder steps, safety fields, and full check tables outside the body.
Add screenshots for visual changes only when captured evidence exists.
Link screenshots or specific diagnostic evidence only when reviewers can access them. Never invent an upload URL.
Keep each material limitation in the body. A private document cannot replace that explanation.

Read `api-contract.md` for the API section. Use its existing, new, or removed endpoint branch.
Describe migration order, affected consumers, or rollback limits when they affect the merge decision.
State observed compatibility changes. Do not invent client behavior.
Keep repair instructions and generator discovery steps outside the body.
Name the unresolved contract gap in the body.
Keep the Merge danger section. State the door type, affected callers, and the rollback path.
Put each prod step in its own sub-bullet under **Prod:**, not inside Blast radius.
A two-way door is reversible. A one-way door includes changes that a code revert cannot undo.
Keep these fields and labels through `unslop`. Use concrete facts instead of a generic risk rating.
Name an important file when it helps review. Omit a full file inventory.
Keep required repository template fields, even when the default would omit them.

## Example

This example combines a call tree with an OpenAPI change. Routine CI results need no section.

The summary explains why the endpoint exists. The tree explains its runtime behavior.
The API note explains the schema change that a caller needs.

Adds a GET route so the planning app can open a saved heizbruder version with its project document.

```text
GET .../heizbruder/projects/{bv}/versions/{id}     (path patterns -> 422 before any upstream call)
  HeizbruderProjectUseCase.get_version
    _resolve_project_id(bv)          GET {heizbruder}/projects?reference_number=  (none -> 404 project)
    HeizbruderClient.get_version     GET {heizbruder}/projects/{project_id}/versions/{id}  (404 -> 404 version)
    _version_detail                  shared with submit; bad JSON -> 502
  version_detail_response            shared with POST .../versions
```

This GET is a new endpoint. Give a brief overview using `api-contract.md`.
Give its main inputs, response, and important errors as bullets. Keep the detailed schema in the spec.

The Merge danger section for this example:

```markdown
## Merge danger

- **Door:** two-way. Adds a read route. No data migration.
- **Blast radius:** new GET callers, and submit, which now shares the response and error mapping.
- **Rollback:** revert the PR.
```
