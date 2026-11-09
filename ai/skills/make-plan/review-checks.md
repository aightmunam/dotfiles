# Review Checks Before Build

Use these checks to decide the plan before implementation.
Apply them to planned changes and directly affected consumers.
Record decisions, not findings about code that does not exist.

## Spec coverage

Quote each requirement with its source.
Map it to a phase and an observable result.
Check for missing, partial, and incorrect behavior.
Trace added work to a requirement or a concrete risk.
Cut work that has neither source.
Keep this check separate from repo standards.

## Review decisions

Read applicable repo instructions and standards before you choose interfaces.
Include `CODING_STANDARDS.md`, `CONTRIBUTING.md`, and scoped instructions when present.
Find other standards through repo links and configuration.
Cite each applicable rule by file and line.
Keep documented standards separate from design heuristics.
Use repo standards when a heuristic conflicts with them.
Leave checks that tooling enforces to that tooling.

Consider each angle below.
For each applicable angle, record evidence, the decision, its owner phase, and its verification.
For an inapplicable angle, record the reason.
Reference existing failure-mode rows instead of copying them.

| Angle | Planning decision |
|---|---|
| Standards | Name applicable rules and the files that must follow them. Apply them in each changed language. |
| Quality | Choose boundaries, names, and domain types. Reuse existing logic. Keep unrelated responsibilities separate. |
| Structure | Check scattered edits, long navigation chains, and inheritance that discards its contract. Justify any structural change. |
| Callers | Find consumers of changed signatures, defaults, schemas, settings, events, and file formats. Name compatibility or migration for each. |
| Bugs | Trace normal, empty, invalid, and failed paths. Name exception behavior, async boundaries, and resource lifetime. |
| Security | Name trusted identities, authorization, tenant isolation, input checks, query binding, and sensitive output. |
| Tests | Pin observable behavior and affected callers. Identify removed or weaker tests. Avoid assertions on internal call order. |
| Performance | Read `../performance/SKILL.md`. Use assessment mode. Assign decisions and checks to phases. |
| Migration | Name database dialect, lock scope, lock timeout, index strategy, backfill, revision heads, and recovery. Plan schema/code deployment order. |
| Deployment | Name settings, defaults, config files, tools, and manual steps. Plan activation and rollback or fail-forward. |
| Flags | List every route, task, consumer, and UI entry point. Define enabled, disabled, and missing-flag behavior. |
| API | Read the Rules and Codebase conventions sections of `../review-pr/api-checklist.md`. Record rule numbers, exact response examples, and tests. |

For migrations, check old-code and new-code compatibility with existing rows.
Use checks for the actual database dialect to check lock and index behavior.
Leave database-specific steps blocked until evidence establishes the database dialect.
Treat code smells as prompts for judgment, not reasons to add abstractions.
Keep structures that solve the current requirement with the least complexity.
Name tests or commands that the builder will run.
Distinguish observed baselines from future verification.
