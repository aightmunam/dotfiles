# Write a verify skill with rig

Fill each section with what step 2 found. Each command must run as written in this repo.

## Write `~/.agents/verify/<repo name>/rig.toml`

1. Read `rig --help` and the help for each command that the recipes need.
2. Fill this configuration with the repo's command and a free local port.
3. Replace each angle-bracket value before writing the final file.
4. Add only the optional keys that the repo needs from the reference below.
5. Run `rig check` from the checkout under test before the live proof.

```toml
base_url = "http://127.0.0.1:{port.app}"
ports = { app = <free-port> }
env = { <name> = "<value>" }
app = { name = "api", cmd = ["<executable>", "<entry-point>"], cwd = "{tree}" }
ready = { name = "usable", url = "{base}/<ready-path>", contains = "<body-value>" }
doctor = [{ name = "usable", url = "{base}/<ready-path>", contains = "<body-value>" }]
```

## Configuration reference

`rig.toml` holds launch and drive configuration. `rig` owns process state and cleanup.
The configuration has these keys:

- `app` and each `setup` entry have `name`, an argv list `cmd`, and optional `cwd`.
- `venv` is a checkout-relative path, or `poetry` for the checkout's Poetry environment.
- `deps` has argv lists `check` and `sync`, and optional `cwd` (default `{tree}`). `rig up` runs `check`, and runs `sync` when `check` fails. `rig check` runs only `check`. These commands cannot use `{venv}`.
- `compose` has `project`, `file`, and optional `services`. The file is relative to the skill directory.
- `env` holds explicit app and setup values. Hosts in URLs are `127.0.0.1` or `localhost`.
- `ready` is a probe or an array of probes. `doctor` is an array of probes.
- Each probe has `name`, `contains`, and either `url` or `cmd`. A single `ready` probe can have `timeout`.
- `db` and `queues` have step fields. Their `cmd` lists contain arguments after the scratch compose command.
- `publish` has step fields. Its host command receives the payload file as its last argument.
- `settle_queues` lists watched queue names. `settle_timeout` sets the wait limit in seconds.
- `call.header_cmd` is an argv list. Its helper prints default request headers.
- Each `modes.<name>` table can set `env` and `app`. `default_mode` selects the mode.

`{tree}` is the checkout under test. `{skill}` is the private skill directory.
`{run}` and `{evidence}` are the run and evidence directories.
`{venv}`, `{mode}`, `{base}`, and `{port.<name>}` supply configured values.
The default run directory is `~/.cache/rig/<repo name>/run/`.
The default evidence directory is `~/.cache/rig/<repo name>/evidence/<run>/`.
`RIG_VERIFY_DIR` and `RIG_CACHE_DIR` select isolated roots for temporary fixtures.

## `~/.agents/verify/<repo name>/SKILL.md`

```
---
name: verify
description: Use when you must prove that <app> works through its <surface>. <one line: what it launches and drives>.
---

# Verify <app>

**Location.** This skill lives in `~/.agents/verify/<repo name>/`, outside the product repo.
Run its commands from the root of the checkout under test, main or any worktree.
`rig.toml` holds the launch and drive configuration.

## Launch
Run `rig check`.
Run `rig up`.
<the exact --mode option, when needed>
<the migrations and seeds configured in rig.toml that make empty scratch data usable>
Ready when: <a read that shows the app is usable, not only that the process answers>
Run `EVIDENCE=$(rig info evidence)` before cleanup.

## Doctor
Run `rig doctor`.
<the configured probes and the body values that they require>
Run it before the first drive and after each failed drive.

## Drive
Read `features/README.md`, then the file of the feature that you prove.
Run its rig commands with the real routes, SQL, and payloads.

## Evidence
Save to `~/.cache/rig/<repo name>/evidence/<run>/`, one file per proof.
- `rig call <proof> <method> <path> [body]` saves the request and response.
- `rig db <sql> --proof <proof>` saves the SQL and its result.
- `rig publish <file> --proof <proof>` saves the message. Run `rig wait-settle` before the second read.
- `rig queues` and `rig logs` show queues and app logs.
- Save the action and the result: the request, then the response body.
- For a change: also save a second read of the stored state (row, file, or event).
- A status code, a log line, or a "saved" message alone is not proof.
- Mocks only where a production boundary already isolates the external system.
- For a dry-run mode: observe what it skips (files, network). Do not trust its name.

## Cleanup
Run `rig cleanup` after success or failure.
Never kill by process name. Never remove the evidence dir.
Verify that the scratch ports are free.
Read each proof file from "$EVIDENCE" after cleanup.

## Helpers
<each helper: its path, executable mode, configuration key, and the behavior that configuration cannot express. Or: none>
```

## Select helpers

Keep launch and drive configuration in `rig.toml`.
Add a helper only for behavior that configuration cannot express, such as a dependency override or an auth header.
Call the helper from `rig.toml` with a `{skill}` path.
Use `{tree}` to pass the checkout under test when the helper needs it.
Keep raw curl and lifecycle scripts out of the generated recipes.

## `~/.agents/verify/<repo name>/features/README.md`

```
# <app> verification map

## Baseline preconditions
<launch env, seed data, doctor result that each recipe needs>

## Proof rules
<what proof each surface needs, as in Evidence above>
Report a path that you could not reach with the command that you tried and the missing precondition.

## Features
- [<feature>](./<feature>.md) <one line>
```

## One file per feature: `features/<feature>.md`

Seed 3 to 5 features from routes, commands, menus, or docs. Each file has an H1, one paragraph about what the user sees, and these four H2s in this order.

```
# <feature>
<one paragraph: the behavior that the user sees>

## Sub-features
- `<id>` <one line each>

## How to get to it (user POV)
- <each entry point: route, command, button>

## Driving it with rig
Preconditions:
- <state that the recipe needs>
- **<step>.** <user action>. Run `<exact rig command>`. <the observable result in the body or state>.
- **Proof.** Run `<rig call or rig db --proof command for the second read>`. <what the saved file must contain>.

## Gotchas
- <traps that waste or spoil a run>
```
