# Boundary discipline

Source: pstack-claude plugins/pstack/skills/principle-boundary-discipline/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: Validate at the system boundary. Trust typed data inside. Keep business logic in pure functions and keep the shell thin.

## Rules

- Boundaries are HTTP requests, config, queue messages, and calls to other services. Validate there and return errors there.
- In FastAPI, a Pydantic model parses the request at the route. Code below the route trusts the typed value. Do not validate it again.
- Do not validate for None again deep in a call chain when the boundary did it.
- Do not return SQLAlchemy models or wire payloads through your public interface. Return domain types.
- Put business rules in pure functions. A route, a task, or a repository function only calls them.
- A pure function needs no database session and no client in its test.
- Keep general mechanism inside. Keep special-purpose policy at the edge.

## Two questions

- Does this data cross a system boundary right now? If not, the validation is not needed.
- Can this be a pure function that the shell calls? If yes, extract it.

## When it applies

- You add validation, error handling, or an adapter.
- You write a test and the logic needs a database only because it sits in the route.
