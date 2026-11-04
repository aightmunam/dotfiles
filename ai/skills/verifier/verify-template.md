# Verify Skill Template

Fill each section with what step 2 found. Each command must run as written in this repo.

## `~/.agents/verify/<repo name>/SKILL.md`

```
---
name: verify
description: Use when you must prove that <app> works through its <surface>. <one line: what it launches and drives>.
---

# Verify <app>

**Location.** This skill lives in `~/.agents/verify/<repo name>/`, outside every repo, and is never committed. Run its commands from the root of the <repo name> checkout under test, main or any worktree. Evidence goes to `~/.cache/rig/<repo name>/`.

## Launch
<the exact command, with a free port and scratch data and state dirs as env vars>
<migrations and seed data, so that launch works from an empty data dir>
Ready when: <a read that shows the app is usable, not only that the process answers>
Record the PID that you started.

## Doctor
<one read-only check: process up, right build, port owned by this run, auth valid>
Run it before the first drive and after each failed drive.

## Drive
<the harness: curl, a test client, a PTY, or a browser, with real routes and selectors>
Read `features/README.md`, then the file of the feature that you prove.

## Evidence
Save to `~/.cache/rig/<repo name>/evidence/<run>/`, one file per proof.
- Save the action and the result: the request, then the response body.
- For a change: also save a second read of the stored state (row, file, or event).
- A status code, a log line, or a "saved" message alone is not proof.
- Mocks only where a production boundary already isolates the external system.
- For a dry-run mode: observe what it skips (files, network). Do not trust its name.

## Cleanup
<stop the recorded PID, remove the scratch data and state dirs>
Never kill by process name. Never remove the evidence dir.
Then check: the port is free, and the evidence files exist.

## Helpers
<each script: its path, chmod +x, and its exact call. Or: none>
```

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

## Driving it with <harness>
Preconditions:
- <state that the recipe needs>
- **<step>.** <user action>. Run `<exact command>`. <the observable result in the body or state>.
- **Proof.** Run `<command that saves the body>`. <what the saved file must contain>.

## Gotchas
- <traps that waste or spoil a run>
```
