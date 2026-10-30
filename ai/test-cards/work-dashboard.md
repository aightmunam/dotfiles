# Test card: work-dashboard

Repo: `~/Developer/work-dashboard`. Run every command from the repo root. Source: `pytest.ini`, `README.md`, `requirements.txt`. There is no justfile, Makefile, CI config, or pyproject.

## Touched tests

`PATH="$PWD/.venv/bin:$PATH" python -m pytest -q <path/to/test_file.py>`
Use a bare `python -m pytest`. The commit-gate hook counts only a bare `python -m pytest` or `pytest`. `.venv/bin/python -m pytest` does not count.

## Full suite

`DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock PATH="$PWD/.venv/bin:$PATH" python -m pytest -q`
- Run it once before a merge point.
- Flaky: `tests/build/test_steps.py::test_reap_kills_children_that_outlive_the_step_leader` depends on timing and can fail under the full suite. It passes alone. Rerun it alone before you call it a real failure.

## Lint

No linter is configured. No ruff, flake8, or pre-commit file exists. Use a syntax check: `.venv/bin/python -m compileall -q eye computah tests`.

## Types

None configured.

## Prerequisites

- `.venv` exists (`./setup.sh` creates it). Do not run `setup.sh` on a repo that already has a venv.
- Do not read `.env`.
- Touched tests need no running service, except the Docker tests below.
- checked 2026-10-30: touched-test exit 0 (`tests/test_cache.py`, 8 passed), lint exit 0 (`compileall`, a syntax check only, no real linter).

## Docker

`tests/firefighter/test_ff_postgres_container.py` (11 tests) starts a Postgres container. It defaults `DOCKER_HOST` to the Colima socket, which this machine does not have, so set it first.
- Socket (OrbStack): `unix://$HOME/.orbstack/run/docker.sock`
- Preflight: `docker -H unix://$HOME/.orbstack/run/docker.sock info >/dev/null`
- Without `DOCKER_HOST`, these tests error with `FileNotFoundError`.
- The checked run above did not need Docker.

## Async mode

`pytest-asyncio` with `asyncio_mode = auto` in `pytest.ini`. Async tests need no marker.
