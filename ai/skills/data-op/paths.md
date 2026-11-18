# Paths

Fact: the user has no direct write access to prod. Every prod write goes through a deployed path. The agent never opens a write connection to a prod DB and never writes to SF prod.

Reads: prod DB read access exists. Read prod data with pure reads through a read-only DB connection (psql with the GCP IAM role), a read endpoint, or Metabase. Any of them is fine.

## Path table

Step 2 picks the path. The user decides. Recommend one row and go on with it. Go down the rows and stop at the first match.

First, search the service routers for an endpoint that makes the change. An endpoint for a migration or a backfill counts.

| The change | Path |
|---|---|
| An API makes the change | A: a throwaway script that runs locally and calls the API |
| No API makes it, and other services, events or SF must see it | Tell the user. Recommend a new endpoint, then path A |
| No API makes it, DB only (the default) | Alembic data migration, runs with the release |
| No API makes it, DB only, and the migration may be too long or too big for the release job | B: one-off script in the release Cloud Run job, the user runs it off-peak |

Reason for B: an Alembic migration runs when the release deploys, so its timing is not in the user's control. A long or big migration holds the deploy and its locks in peak hours. Path B lets the user run it off-peak.

Pick B only from a fact: the row count from step 1, or a timing from a staging or prod-snapshot run. A busy table alone is not that fact. It makes lock waits longer, so time the change on the snapshot. With no count and no timing, recommend Alembic and name the fact that would change the pick.

## Alembic data migration

- Data before DDL.
- `lock_timeout`.
- A row-count assertion.
- A stated downgrade or fail-forward path.

## Path A: API-driven throwaway CLI

Model: the path A model in `~/.agents/local/work.md`, a backfill CLI.

- It runs locally. It writes only through the API. It fetches the target rows with pure reads, through the prod DB read connection or a read endpoint.
- Commands `snapshot` (read-only), `run` (dry run unless `--execute`), `verify`, `status`, `restore`.
- Writes a JSONL ledger and a revert file before each write.
- `--limit` and wave files.
- Idempotent: skip rows already in the target state.
- Halt on the first error.
- Order: staging full run, then a prod canary wave, then the remaining waves. The user runs each prod wave with the CLI. The agent builds the tool, runs it on staging, and checks prod only with pure reads (DB read connection, read endpoints, Metabase).

For Salesforce prod (the orgs in `~/.agents/local/work.md`), the Repo Rules line in `SKILL.md` stays in force: give the user the read query, and run no command against that org.

## Path B: one-off script, run off-peak as the release Cloud Run job

Model: the Path B model in `~/.agents/local/work.md`. One PR added the script, a later PR deleted it.

- A standalone script outside the Alembic chain, so it can be deleted without touching migration history. Target IDs inline.
- One transaction (`engine.begin()`). Snapshot an invariant first, assert it at the end, so any failure rolls back everything. `--dry-run` runs the same work and rolls back. `--yes` skips the prompt for headless runs. Idempotent: a re-run reports 0 changes.
- Integration tests against a Postgres testcontainer. Validate against a local prod snapshot.
- No new job: run it in the existing release job image, for example `gcloud beta run jobs execute <release-job> --args=python,scripts/<name>.py,--dry-run,--yes --wait`. `~/.agents/local/work.md` names the release job. Staging dry run, then prod dry run, then the real run. Read the output with `gcloud logging read` by execution name.
- The PR body is the runbook: exact commands, the log query, verify SQL for Metabase, the expected counts, and follow-ups.
- A follow-up PR deletes the script and its test after the run.

### Busy tables

These rules replace the `--dry-run` rule and the one-transaction rule above.

- The dry run on prod is a pure read (counts only), because a rolled-back dry run takes the same row locks. On a busy table, `--dry-run` runs only `SELECT` counts. It runs no `DELETE`, no `UPDATE`, and no `FOR UPDATE`.
- Batch large changes, with a ledger so a run can resume.
- Copy the affected rows to a backup table before the change, so a revert after commit is a script, not a database restore.
- Set `lock_timeout`.
