# Test card: dotfiles

Repo: `git -C ~/.agents/bin rev-parse --show-toplevel` (`~/dotfiles` by default). Work in a worktree under `~/wt/dotfiles/<name>`. Run every command from the worktree root. There is no justfile and no pyproject, so commit-gate does not gate commits here. Run the tests anyway.

## Touched tests

`python3 -m unittest ai.tests.<module> -v`
Modules: `test_skills_lint`, `test_plan_lint`, `test_commit_gate`, `test_rewrite_refs`.

## Full suite

`python3 -m unittest discover -s ai/tests -t . -v`
Run it once before each merge point.

## Lint

- Skills and agents: `python3 ai/vendor/ste-lint.py --baseline 0 <file> ...`
- Structure of skills and agents: `python3 -m unittest ai.tests.test_skills_lint -v`

## Types

None configured.

## Prerequisites

- Python 3 standard library only.
- Never run `ai/generate.sh`, `setup.sh`, or `make` from the worktree. They link into the live `~/.agents` and `~/.claude` stores.
- Worktree changes are not live. A subagent that tests a skill reads it from `~/wt/dotfiles/<name>/ai/skills/<skill>/`.
- checked 2026-10-30: touched-test exit 0 (`ai.tests.test_plan_lint`), lint exit 0 (`ste-lint.py --baseline 0` on `ai/agents/explorer.md` and `ai/agents/reviewer.md`).

## Docker

Not used. If a future test needs it, use the OrbStack socket `unix://$HOME/.orbstack/run/docker.sock` with preflight `docker -H unix://$HOME/.orbstack/run/docker.sock info >/dev/null`.

## Async mode

None. Tests use `unittest`, not pytest.
