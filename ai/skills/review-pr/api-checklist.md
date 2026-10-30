# API Checklist

Use this list in the API lens of `review-pr`. The rules are the Zalando RESTful API Guidelines: https://opensource.zalando.com/restful-api-guidelines/.

## How to apply

- Use the diff and the changed files. Do not run git or gh.
- Review only the API changes in the diff. Report old code only when the PR makes it worse.
- Report only a violation that you can show in the code. Give the rule number, the file and line, the problem, and the fix.
- Report each violation, also when it is a codebase convention.

## Codebase conventions

A violation is a convention when 3 or more files outside the diff use the same pattern. Read those files before you tag it.
Tag it with `Convention: yes` and name the pattern, for example "all routers use the `/v1/` prefix".
A convention violation does not count toward FAIL.

## Severity map

| Rule level | Finding severity |
|---|---|
| MUST | high |
| MUST, a break of backward compatibility (#106, #115) | critical |
| SHOULD | medium |
| MAY | low |
| Any rule, tagged as a convention | low, and the body names the convention |

Each finding has category `api` and the rule number in its title.

## Verdict

- PASS: no MUST violation that is not a convention.
- WARN: only SHOULD or MAY violations, not counting conventions.
- FAIL: one or more MUST violations that are not conventions.

Give the verdict and the counts in one row of `# Automated checks`: `| Zalando API guidelines | <PASS, WARN or FAIL> | <n> MUST, <n> SHOULD, <n> MAY, <n> conventions |`.

## Rules

### URLs (Section 8)

**#134 [MUST] Pluralize resource names**
- All resource names in URL paths must be plural: `/orders`, `/products`, `/customers`
- Applies to both collection and single-resource endpoints: `GET /orders` and `GET /orders/{id}`

**#129 [MUST] Use kebab-case for path segments**
- Path segments must use lowercase with hyphens: `/order-items`, NOT `/order_items` or `/orderItems`
- This applies to static path segments only, not path parameters

**#136 [MUST] Use normalized paths without empty segments and trailing slashes**
- No double slashes `//`, no trailing slashes `/products/`
- Paths should be clean: `/products/{id}/orders`

**#141 [MUST] Keep URLs verb-free**
- No action verbs in paths: NOT `/products/create` or `/orders/search`
- Use HTTP methods to express actions: `POST /products`, `GET /products?q=term`

**#138 [MUST] Avoid actions - think about resources**
- Design around resources and state, not RPC-style actions
- NOT `/orders/{id}/calculateTotal` -> use `GET /orders/{id}/total` or model as sub-resource

**#142 [MUST] Use domain-specific resource names**
- Use business domain terms, not generic ones like `/items` or `/entities`

**#143 [MUST] Identify resources and sub-resources via path segments**
- Use hierarchical paths: `/customers/{id}/orders/{order-id}/items`

**#135 [SHOULD] Not use /api as base path**
- Do not use the `/api` prefix in paths. It adds no information

**#145 [MAY] Consider using (non-)nested URLs**
- Flat URLs acceptable when IDs are globally unique: `/orders/{id}` instead of `/customers/{cid}/orders/{id}`

**#146 [SHOULD] Limit number of resource types**
- Keep resource types manageable (aim for 10-20 per API)

**#147 [SHOULD] Limit number of sub-resource levels**
- Avoid exceeding 3 levels of nesting

**#130 [MUST] Use snake_case for query parameters**
- Query params must be snake_case: `?sort_by=price&include_variants=true`

**#137 [MUST] Stick to conventional query parameters**
- Use standard names: `limit`, `cursor`, `sort`, `fields`, `filter`

**#228 [MUST] Use URL-friendly resource identifiers**
- IDs must not need URL encoding. Use simple alphanumeric identifiers

---

### JSON Payload (Section 9)

**#167 [MUST] Use JSON as payload data interchange format**
- Request and response bodies must be JSON

**#118 [MUST] Property names must be snake_case**
- All JSON property names must use snake_case: `order_id`, NOT `orderId` or `OrderId`

**#110 [MUST] Always return JSON objects as top-level data structures**
- Responses must be JSON objects `{}`, never bare arrays `[]`
- Wrap arrays in an object: `{"items": [...]}` not `[...]`

**#120 [SHOULD] Pluralize array names**
- Array properties should use plural names: `"items"`, `"orders"`, `"tags"`

**#122 [MUST] Not use null for boolean properties**
- Booleans must be `true` or `false`, never `null`

**#123 [MUST] Use same semantics for null and absent properties**
- `null` and missing properties must mean the same thing

**#124 [SHOULD] Not use null for empty arrays**
- Empty collections should be `[]`, not `null`

**#240 [SHOULD] Declare enum values using UPPER_SNAKE_CASE string**
- Enum values should be uppercase: `"ACTIVE"`, `"IN_PROGRESS"`, not `"active"` or `"inProgress"`

**#235 [SHOULD] Use naming convention for date/time properties**
- Date/time properties should indicate their temporal nature clearly in the name

**#174 [MUST] Use common field names and semantics**
- Use standard field names consistently across all endpoints (e.g., `id`, `created_at`, `updated_at`)

**#252 [SHOULD] Design single resource schema for reading and writing**
- Use the same schema shape for both request and response when possible

**#216 [SHOULD] Define maps using additionalProperties**
- Dictionary/map structures should use `additionalProperties` in schema definitions

---

### Data Formats (Section 7)

**#238 [MUST] Use standard data formats**
- Use widely recognized formats for all data types

**#169 [MUST] Use standard formats for date and time properties**
- Dates/times must follow RFC 3339: `2024-01-15T10:30:00Z`
- Use `date-time` format for timestamps, `date` for calendar dates

**#171 [MUST] Define format for number and integer types**
- Specify `int32`/`int64` for integers, `float`/`double` for numbers in schema

**#170 [MUST] Use standard formats for country, language and currency**
- Countries: ISO 3166-1 alpha-2 (`DE`, `US`)
- Languages: ISO 639-1 (`de`, `en`)
- Currency: ISO 4217 (`EUR`, `USD`)

**#144 [SHOULD] Only use UUIDs if necessary**
- Use simpler identifiers. Use UUIDs only when distributed generation is necessary

**#127 [SHOULD] Use standard formats for time duration and interval**
- Use ISO 8601 for durations: `P1DT12H` (1 day 12 hours)

**#255 [SHOULD] Select appropriate date or date-time format**
- Use `date` when time component isn't needed, `date-time` when it is

---

### HTTP Methods (Section 10)

**#148 [MUST] Use HTTP methods correctly**
- GET: read (safe, idempotent, no side effects)
- POST: create new resource
- PUT: full replacement of resource
- PATCH: partial update
- DELETE: delete the resource

**#149 [MUST] Fulfill common method properties**
- GET/HEAD/PUT/DELETE must be idempotent
- GET/HEAD/OPTIONS must be safe (no side effects)

**#229 [SHOULD] Consider designing POST and PATCH idempotent**
- Make POST/PATCH idempotent where possible for reliability

**#231 [SHOULD] Use secondary key for idempotent POST design**
- Use idempotency keys for safe retries on POST

**#154 [MUST] Define collection format of header and query parameters**
- Define the format of each collection parameter (comma-separated, repeated, or a different format)

**#226 [MUST] Document implicit response filtering**
- Any automatic filtering must be documented

---

### HTTP Status Codes (Section 11)

**#243 [MUST] Use official HTTP status codes**
- Only use IANA-registered status codes

**#150 [SHOULD] Only use most common HTTP status codes**
- Prefer: 200, 201, 204, 301, 304, 400, 401, 403, 404, 405, 406, 409, 415, 422, 429, 500, 503

**#220 [MUST] Use most specific HTTP status codes**
- Use 409 for conflicts, 422 for validation errors, 429 for rate limits - not generic 400

**#151 [MUST] Specify success and error responses**
- Document both success (2xx) and error (4xx, 5xx) responses for each endpoint

**#152 [MUST] Use code 207 for batch or bulk requests**
- Batch endpoints where items can independently fail must return 207 Multi-Status

**#153 [MUST] Use code 429 with headers for rate limits**
- Rate-limited responses must include rate limit headers

**#176 [MUST] Support problem JSON**
- Error responses must follow RFC 7807 Problem Details format with `type`, `title`, `status`, `detail`

**#177 [MUST] Not expose stack traces**
- Error responses must never include stack traces or internal implementation details

**#251 [SHOULD] Not use redirection codes**
- Minimize 3xx redirects in API responses

---

### HTTP Headers (Section 12)

**#132 [SHOULD] Use kebab-case with uppercase separate words for HTTP headers**
- Custom headers: `X-Flow-Id`, `X-Tenant-Id`

**#178 [MUST] Use Content-* headers correctly**
- `Content-Type` must match the actual payload format

**#180 [SHOULD] Use Location header instead of Content-Location**
- Use `Location` for newly created resources (201 responses)

**#182 [MAY] Consider supporting ETag with If-Match/If-None-Match**
- For optimistic locking and caching

**#230 [MAY] Consider supporting Idempotency-Key header**
- For safe retries on non-idempotent operations

---

### Pagination (Section 15)

**#159 [MUST] Support pagination**
- Collection endpoints must be paginated

**#160 [SHOULD] Prefer cursor-based pagination, avoid offset-based**
- Cursor-based is more performant and consistent than offset-based

**#248 [SHOULD] Use pagination response page object**
- Consistent page object with results, cursors, and metadata

**#161 [SHOULD] Use pagination links**
- Include `next`, `prev` links in pagination responses

**#254 [SHOULD] Avoid total result count**
- A total count is expensive. Signal "has more" instead

---

### Compatibility (Section 16)

**#106 [MUST] Not break backward compatibility**
- No changes that break existing clients

**#107 [SHOULD] Prefer compatible extensions**
- Add new fields and parameters as optional. Do not change existing ones

**#108 [MUST] Prepare clients to accept compatible API extensions**
- Clients should ignore unknown fields

**#110 [MUST] Always return JSON objects as top-level data structures**
- Never return bare arrays (prevents safe extension)

**#112 [SHOULD] Use open-ended list of values for enumerations**
- Use examples rather than strict enum constraints to allow evolution

**#113 [SHOULD] Avoid versioning**
- Evolve through compatible extensions, not version bumps

**#115 [MUST] Not use URL versioning**
- Never use `/v1/` or `/v2/` in URL paths. Use media type versioning if necessary

---

### Performance (Section 14)

**#155 [SHOULD] Reduce bandwidth needs and improve responsiveness**
- Consider compression, filtering, partial responses

**#157 [SHOULD] Support partial responses via filtering**
- Allow clients to request only needed fields

**#158 [SHOULD] Allow optional embedding of sub-resources**
- Support `?embed=` or similar for related resources

**#227 [MUST] Document cacheable GET, HEAD, and POST endpoints**
- Explicitly mark which endpoints support caching
