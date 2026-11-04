# Work overlay (example)

Copy `ai/local.example/` to `ai/local/` and fill in the values. Git ignores `ai/local/`.
`ai/generate.sh` links `ai/local` to `~/.agents/local`. Skills read `~/.agents/local/work.md`.

## Salesforce

The hook `ai/claude/hooks/sf-prod-guard.sh` reads the next line. It blocks each `sf` or `sfdx` command that names one of these orgs.

- Prod Salesforce orgs: `<prod-org-alias>`

## Services

- Main service repo: `~/Developer/<service-repo>` (GitHub `<owner>/<service-repo>`).
- Deploy workflow: `.github/workflows/<deploy-workflow>.yml`.
- Release job (Cloud Run, runs the migrations): `<release-job>`.
- Prod read paths: `<BI tool>`, read APIs, `<workflow engine>` read tools.

## Model data ops

- Path A model: `~/Developer/<backfill-tool>/<backfill>.py`, a backfill CLI.
- Path B model: `<service-repo>` PR `<n>` added a one-off script, PR `<m>` deleted it.

## Test cards

Test cards for work repos go in `ai/test-cards/<repo>.md`, the same path as the other cards. Add each work card to `.git/info/exclude`, so that the repo name stays out of the tracked `.gitignore`.
