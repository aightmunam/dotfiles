# API contract check

Apply this check when an endpoint implementation changes.
Compare the old and new contract, even when no schema file changed.

1. Inspect methods, paths, parameters, request bodies, response bodies, status codes, errors, and authorization requirements.
2. Find the repository contract source, schema generator, and contract checks.
3. Use an existing schema check or CI guard when available. Read its result.
4. If the contract changed, update its source and regenerate tracked OpenAPI artifacts with the repository command.
5. Update related examples, client artifacts, or API documentation when the repository requires them.
6. Check the generated diff against the endpoint behavior. Run the relevant contract checks.
7. Refresh `prove` after any edit. The old diff hash no longer proves the branch.

Use the repository generator. Do not hand-edit a generated schema.
A changed schema file alone does not prove that it describes the new behavior.
An internal endpoint edit can leave the contract unchanged. Record the reason outside the PR body.

If the generator or source is unknown, inspect repository scripts and CI configuration.
If the contract cannot be synchronized, report the exact gap before the push step.
Stop the normal PR flow until the contract matches the behavior.
If the user explicitly requests a draft with the gap, disclose it in the body.
If the repository has no OpenAPI contract, state that limit. Use its actual API documentation and checks.
Do not introduce a new schema system during PR preparation.

## Present the contract change

Compare the base and head OpenAPI operations before writing the API section.
Use the generated contract as the source. Do not reconstruct schema details from memory.

- Existing endpoint: show a focused OpenAPI diff with removed and added values.
- New endpoint: give a brief overview of the added operation.
- Removed endpoint: show the removed operation and state the effect on callers.
- No contract change: omit the API section. Keep the reason outside the body.

For an existing endpoint, keep only changed fields and enough context to locate them.
Keep the method, path, and schema name when they identify the change.
Show both old and new types, defaults, limits, required fields, errors, or auth rules when they change.
Include changed shared schemas and identify affected operations.
Omit a list of unchanged parameters, responses, and auth rules.
Ignore key ordering. Keep changed operation IDs and schema references.
State the effect on callers when the diff alone does not explain it.

For a new endpoint, state its method, path, and purpose.
Summarize the main inputs and the success response.
Mention auth, constraints, or important errors when callers need them.
Use bullets or a small contract sketch.
Keep full schema dumps and exhaustive field lists outside the PR body.
Point to the OpenAPI spec for full details when it is accessible to reviewers.
Expand a schema detail only when it explains an important caller decision.

Keep the runtime call tree when useful. It does not replace the contract diff.

## Existing endpoint example

The only changes are the default and maximum of the `limit` query parameter on `GET /orders`.

```diff
 paths:
   /orders:
     get:
       parameters:
         - name: limit
           in: query
           schema:
-            default: 20
+            default: 50
-            maximum: 100
+            maximum: 200
```


## New endpoint example

`GET /orders/{order_id}` reads one order by UUID. `include_history` optionally includes its history.
It requires bearer authentication and returns `Order`. A missing order returns `404`.
The generated OpenAPI spec includes the new operation.
