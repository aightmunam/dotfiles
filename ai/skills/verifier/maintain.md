# Maintain Pass

Use this pass when `~/.agents/verify/<repo name>/` exists. The goal: each feature file matches the app, and each feature ran live in this pass.

## Edit scope

Edit only the verify skill directory `~/.agents/verify/<repo name>/`: `SKILL.md`, `features/`, and its helper scripts. Do not edit product code. Drive from the checkout under test.

## Steps

1. **Index.** Read `features/README.md`. List its sibling files. Fix missing, extra, duplicate, or dead entries.
2. **Source read.** For each feature file, read the code that serves it. Write the source entry points and each drift with its file and line. With a dispatch tool, give one read-only agent per feature, in one message. The agents do not drive the app and do not edit files.
3. **Missing features.** Read the recent commits for user-facing routes or commands that the map does not list. Name a source path before you call a feature missing.
4. **Live pass.** Do this step also when the source read is clean. Use the launch model in the verify skill. Run doctor before the first drive and after each failed drive. Drive each feature once. Keep the evidence through each cleanup. Clean up after each failed try.
5. **Triage.** A wrong or missing description is doc drift: fix the map. A working behavior that the harness cannot drive is a harness gap: fix the harness, then drive it live again. A broken app behavior is a product gap: report it to the user, and do not change the map to hide it.
6. **Stop.** Read each changed file again. For `changed`, make one commit in `~/.agents/verify`. Its message lists each drift fixed. For `clean` or `blocked`, make no commit.

A feature that you cannot reach is `unreachable` only with its missing precondition and the command that you tried.

## Outcome

Use the report template from `SKILL.md`. Add these lines:

```
Outcome: clean | changed | blocked (<reason>)
Features: <each feature: driven, unreachable (<precondition>), or drift fixed>
Product gaps: <each, with its evidence path, or none>
```
