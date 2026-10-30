# Test card: grimoire

Repo: `~/Developer/grimoire`. Run every command from the repo root. Source: `Makefile`, `pytest.ini`, `requirements.txt`. There is no justfile, pyproject, CI config, or CLAUDE.md.

## Touched tests

`.venv/bin/python -m pytest -q <path/to/test_file.py>`

## Full suite

`make test`, which runs `.venv/bin/python -m pytest -q`. `make check` runs `compileall` and then the same suite. Run it once before a merge point.

## Lint

No linter is configured. The nearest check is `.venv/bin/python -m compileall -q app tests` (the first step of `make check`).

## Types

None configured.

## Prerequisites

- `.venv` exists (`make setup` creates it and copies `.env.example` to `.env`). Do not read `.env`.
- Tests need no running service. Run `make` targets only for `test` and `check`, never `setup` on an existing venv.
- checked 2026-10-30: touched-test exit 0 (`tests/test_review_format.py`, 22 passed), lint exit 0 (`compileall`, a syntax check only, no real linter).

## Docker

Not used. No test needs Docker. If a future test does, use the OrbStack socket `unix://$HOME/.orbstack/run/docker.sock` with preflight `docker -H unix://$HOME/.orbstack/run/docker.sock info >/dev/null`.

## Async mode

`pytest-asyncio` is in `requirements.txt`. `pytest.ini` sets no `asyncio_mode`, so it uses the default strict mode. Mark async tests with `@pytest.mark.asyncio`.
