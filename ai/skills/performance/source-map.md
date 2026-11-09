# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **bc:** pstack-claude `plugins/pstack/skills/benchmark-checklist/SKILL.md`.
- **etn:** `ai/principles/explain-the-number.md` (from pstack principle-explain-the-number).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 performance entry and the `prove` entry.
- **brief:** task 5.3 brief (profiler py-spy, the cProfile fallback, the RED scenario, the repo lines).
- **review:** task 5.3 review, fix round 1 (I-1 to I-3, M-1, M-4, M-5) and the controller rulings.
- **py-spy docs:** Context7 `/benfred/py-spy` (root on macOS; `top` is a live view).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (removed after eec5ad9; read it in git history) (the form bar).
- **assessment-request:** User request, 2026-11-09: broad performance reasoning for planning and review, including connections, indexes, loops, lazy/eager work, and sync/async execution. The preceding message identifies long connection occupancy as a missed planning risk.
- **assessment-red:** Saved answers from the old skill under both CLIs, in the performance assessment scenario below. These answers already trace most risks; they also show the benchmark-only report mismatch.
- **lenses:** Existing `review-pr/lenses.md`, Performance and Bug and security lenses. The shared assessment replaces the Performance checklist.
- **tnr:** pstack-claude `plugins/pstack/skills/thermo-nuclear-review/SKILL.md`, read and cut where it prescribes unrelated review workflow.
- **tnq:** pstack-claude `plugins/pstack/skills/thermo-nuclear-code-quality-review/SKILL.md`, read and cut where it prescribes automatic refactors or parallelization.
- **python-request:** User approval, 2026-11-09: implement the researched additions, with Python as the main development language.
- **research:** [Performance and concurrency research](https://chatgpt.com/space/page_f17fae2f0f748191aac88071a13355f5), written in this session from primary sources. It recommends invariant, progress, overload, cache, handoff, and controlled concurrency checks.
- **py-tasks:** [Python 3.11 asyncio tasks](https://docs.python.org/3.11/library/asyncio-task.html), read 2026-11-09. TaskGroup, gather, cancellation, timeout, and to_thread semantics. Agents must use their project's supported version.
- **py-sync:** [asyncio synchronization](https://docs.python.org/3/library/asyncio-sync.html) and [queues](https://docs.python.org/3/library/asyncio-queue.html), read 2026-11-09. Scope of primitives and positive queue bounds.
- **py-workers:** [Python 3.11 futures](https://docs.python.org/3.11/library/concurrent.futures.html) and [threading](https://docs.python.org/3/library/threading.html), read 2026-11-09. Running-worker cancellation, executor deadlocks, GIL, and build-dependent parallelism.
- **py-memory:** [tracemalloc](https://docs.python.org/3/library/tracemalloc.html), read 2026-11-09. Python allocation evidence.
- **sa-session:** [SQLAlchemy session concurrency](https://docs.sqlalchemy.org/en/20/orm/session_basics.html#is-the-session-thread-safe-is-asyncsession-safe-to-share-in-concurrent-tasks), read 2026-11-09.
- **pg-state:** [PostgreSQL transaction isolation](https://www.postgresql.org/docs/current/transaction-iso.html) and [explicit locking](https://www.postgresql.org/docs/current/explicit-locking.html), read in the research phase.
- **aws-retries:** [Timeouts, retries, and backoff with jitter](https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/) and [idempotent APIs](https://d1.awsstatic.com/builderslibrary/pdfs/making-retries-safe-with-idempotent-apis-malcolm-featonby.pdf), read in the research phase.
- **aws-load:** [Queue backlogs](https://aws.amazon.com/builders-library/avoiding-insurmountable-queue-backlogs/), [caching](https://aws.amazon.com/builders-library/caching-challenges-and-strategies/), and [transactional outbox](https://docs.aws.amazon.com/prescriptive-guidance/latest/cloud-design-patterns/transactional-outbox.html), read in the research phase.
- **ownership:** [Amazon leader election](https://aws.amazon.com/builders-library/leader-election-in-distributed-systems/) and [Kleppmann on distributed locking](https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html), read in the research phase.
- **controlled-tests:** [Go project on testing time and quiescence](https://go.dev/blog/testing-time), read in the research phase. The mechanism transfers to Python events and injected time; no Go tool is prescribed.
- **resource-evidence:** [Google SRE monitoring](https://sre.google/sre-book/monitoring-distributed-systems/), [USE](https://www.brendangregg.com/usemethod.html), and [Linux false sharing](https://www.kernel.org/doc/html/latest/kernel-hacking/false-sharing.html), read in the research phase.

Context7 was not available in the active tool catalog. Python and SQLAlchemy facts above were checked against official documentation.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
For the original measurement rows, "Loop N" and "T" now refer to `measurement.md`. The measurement procedure and report labels remain intact. The new SKILL.md selects assessment or measurement.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Record invariants, competing actors, and atomic boundaries before concurrency changes. Check read/write races, conservation, uniqueness, isolation, lock order, and progress. | python-request. research. pg-state. | O | SKILL.md definition, report slot, and assessment rule. `assessment.md` shared-state and progress rows. `shared-state.md`. | Python concurrency scenario below. |
| Use conditional references for Python, shared state, and dependency failure. Keep isolated bounded computation simple. | python-request. research. bc (scope and full work). | P | `assessment.md` branch pointers. | Python concurrency and bounded scenarios below. |
| Check actual Python version, actor scope, session ownership, pending tasks, worker counts, child failure, cancellation, and executor progress. Do not assume the GIL protects an invariant. | python-request. py-tasks. py-sync. py-workers. sa-session. | D | `python.md`. | Python concurrency scenario below. |
| Multiply total attempts across every retry layer, including the request wrapper and nested publisher/transport attempts. Distinguish retries from attempts. | aws-retries. Python RED: both answers reported 9 rather than the possible 27. | D | `assessment.md` Failure row. `load-and-failure.md` retry-owner trace. SKILL.md red flag. | Python concurrency scenario below. |
| Record each retry owner, source, callee, and per-invocation attempt total before combining the nested chain. | Python GREEN iteration 1 below: Claude read the reference but still omitted one owner. new-skill form rule (a missing part gets a required slot). | O | SKILL.md Retry budget slot. `load-and-failure.md` owner table. | Python GREEN iteration 2 below. |
| Check deadline scope, retry identity, admission, fairness, backlog recovery, cache failure, and durable publication boundaries. | research. aws-retries. aws-load. | P | `load-and-failure.md`. | Python concurrency covers nested retries and publication. Cache cold-start behavior is source-backed, not pressure-tested here. |
| Check stale ownership at the protected write boundary when distributed coordination applies. Avoid new coordination for isolated work. | ownership. python-request. | D | `shared-state.md` Distributed ownership. | Bounded scenario checks non-applicability. Fencing behavior remains source-backed, not pressure-tested here. |
| Use controlled overlap and failure tests. Check invariants and resource cleanup after actors finish. Match memory, latency-tail, and waiting evidence to actual costs. | controlled-tests. resource-evidence. py-memory. | O | `assessment.md` verification. `python.md` Verification. Conditional references. | Python concurrency and bounded scenarios below. |
| Use assessment for design and code risks. Use measurement for measured claims. Do not fill an empty benchmark report for a design assessment. | assessment-request. assessment-red. bc (requires real runs for measured claims). | P | SKILL.md Loop and assessment template. `measurement.md` retains the original measurement loop. | Performance assessment scenario below. |
| Trace work growth, data access, access paths, resource lifetime, materialization, scheduling, capacity, and failure through completion. | assessment-request. assessment-red (connection occupancy, query multiplication, rule growth, lazy consumption, blocking I/O, cancellation, and existing index). lenses. | P | `assessment.md` trace table. | Performance assessment scenario below. |
| Distinguish session, transaction, and actual connection lifetimes. Trace unrelated work during ownership. Generalize to other scarce resources. | assessment-request (missed long connection hold). assessment-red (commit does not return the fixture connection). | D | `assessment.md` Resource lifetime. SKILL.md red flags. | Slow uploader and 8-connection pool in the assessment fixture. |
| Compare where lazy/eager and sync/async choices move costs. Preserve order, consistency, failure behavior, and cancellation. Bound pending and active work. | assessment-request. assessment-red (generator retains cursor; unbounded gather breaks order; offloading does not stop a running worker). bc (full work and correct outputs). | D | `assessment.md` Compare choices. SKILL.md assessment rules. | Performance assessment scenario below. |
| Check indexes and actual calls before recommending changes. Keep adequate bounds and necessary work. Label unmeasured risks and unknown budgets. | assessment-request. assessment-red (existing composite index and required ordered uploads). etn (code guesses do not prove a limiter). | D | `assessment.md`. SKILL.md assessment template. | Performance assessment scenario below. |
| Use deterministic resource, work-count, and scheduling checks where possible. Use representative query plans and concurrency for runtime evidence. | assessment-red (slow uploader, query counts, cancellation, pool checks). etn (API/query plans, full work, counters). bc (realistic inputs and complete work). | O | `assessment.md` Choose verification. | Performance assessment scenario below. |
| Planning and review call the same assessment. Preserve their phase ownership and finding formats. Keep incident diagnosis in debug. | assessment-request (consider these issues in planning). Existing make-plan and review-pr contracts. | P | `make-plan/review-checks.md`, `review-pr/lenses.md`, AGENTS routing and eval prompts. | Routing evals and assessment scenario below. |
| Write the claim, the result that changes the decision, and the noise floor before the first timed run. Read the principle file alone. | spec 8.4. etn rule 1. bc "Before you run anything". Audit: GREEN-1 Claude read the principle in a chained `cat`, which the harness does not count. | P | Loop 1. T Claim, Noise floor. Red flags. | RED: neither run wrote a claim or a noise floor first. GREEN-3: both give the claim and a measured A/A noise floor. |
| Check the load and the core count before the first timed run. Quote the `uptime` line as printed. Alternate the sides on a busy machine. | bc "Before you run anything". review I-3 (a load value no command printed). review M-5 (`os.cpu_count()`, sysctl is denied in a sandbox). | P | Loop 2. T Machine. Red flags (two). | RED: neither run checked the load. GREEN-3: Codex ran `uptime` only after timing. GREEN-4: both ran `uptime` before the first timing run, and both quote the printed line. |
| Read the timing code. Write what it times and ignores. | bc "Before you run anything". | P | Loop 3. | GREEN (restored after re-review N-1) |
| Check outputs and errors. The timed work must happen. | bc questions 4 and 7. etn (errors, skipped work, code that never ran). | P | Loop 3. T Work check. Rules, inconclusive. | RED: both runs compared outputs. Kept, the baseline did it. |
| At least 5 runs per side, alternated, median and range. | bc question 5. etn (keep the run count and the spread). | P | Loop 4. T Number. Red flags. | RED: both runs did this. Kept, the brief names it. |
| Discard one warmup run per side. | bc question 5 (warmup favors neither side). Brief RED failure (no warmup). | P | Loop 4. | GREEN |
| Production settings and the same data for both sides. Untuned is inconclusive. | bc question 2. etn (a side left on default settings). | D | Loop 4. Rules. | Untested. The scenario has no settings. |
| Profile in a run that you do not report. Name the limiter from it. | bc question 1. etn ("why not double", a guess is not a limit). | P | Loop 5. T Limiter. Red flags. | RED: Claude found the cause by ablation, Codex by a profile. Neither named a profiler. |
| py-spy is the profiler, as `py-spy record` only, on Linux without sudo. On macOS, when py-spy is missing, or when it exits with an error, use cProfile. | spec 8.4 (profiler swapped to py-spy). brief. review I-2. py-spy docs (root on macOS). | P | Loop 5. T Profiler. | GREEN-2 and GREEN-3 ran cProfile (py-spy is not installed). GREEN-4: both ran cProfile and gave macOS or a missing py-spy as the reason. py-spy branch: Untested. |
| Time the caller path. Give the change as a share. With no caller, say so. | bc question 6. etn (a piece too small to matter end to end). | P | Loop 6. T End-to-end share. Red flags. | RED: both said "faster" with no scope. |
| The spread decides. Effect below the spread is no measurable difference. | spec 8.4 (stop when the spread is larger than the effect). etn rule 2. bc question 5. | D | Rules. T Noise floor. | GREEN |
| Do the arithmetic against limits. | bc question 3. | D | Rules. | Untested. The scenario stays inside limits. |
| Inconclusive is not a pass. Name the gap. | bc Report. spec 8.4 prove entry (inconclusive is not a pass). | D | Rules. T Verdict. | GREEN |
| A ballpark is one run, but still check the work. | bc ballpark paragraph. | D | Rules. | Untested. |
| Lead with the verdict. Number with unit, run count, range, limiter. | bc Report. | O | T. | GREEN |
| Dispatched by a caller (`prove`): the template only. | spec 8.4 prove entry (runs `performance` checks). fcd (roles with a fallback). | O | Loop 7. | GREEN-4: Claude replied with the template only. Codex added a table and the command block inside the template slots. |
| Before SHA, After SHA (HEAD plus a diff hash), and the exact timing command, so a caller can run it again. | spec 8.4 prove entry (the parent reruns each command). review I-1. | O | Loop 3, Loop 4. T. | GREEN-4: both give HEAD `a9c53b8` plus diff `d6e040a21848`, and the timing command. |
| For an uncommitted diff, the before side is a worktree at HEAD. With no writes, `git show HEAD:<path>`. | review I-1. Controller ruling. | P | Loop 3. | GREEN-4: both runs loaded the before side with `git show` (read-only). Worktree branch: Untested. |
| Map the verdict to VERIFIED, NOT VERIFIED or INCONCLUSIVE against the noise floor. | spec 8.4 prove entry (three outcomes). review I-1. Controller ruling. | O | Loop 7. T Outcome. | GREEN-4: both VERIFIED, scoped to the function. |
| `Principles applied:` line, label kept as written. | spec 8.7. | O | Loop 7. T. | GREEN-1: Codex wrote "Principle applied:". GREEN-2 and GREEN-3 passed. |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | Untested. The runs cannot write or open a DB. |

## Cut

- Go-specific tools and implementation examples from research: the user mainly develops in Python. Keep the testing and ownership mechanisms.
- Universal TaskGroup, process-pool, distributed-lock, cache, or outbox migrations: applicability and required semantics decide each choice.
- Hardware tuning in the main loop: keep it conditional on profile evidence.
- A new skill name: the existing performance skill owns this domain. It now selects assessment or measurement.
- Separate planning and review performance lists: they drift. Both callers now use the shared assessment.
- Automatic index, async, lazy, cache, or concurrency recommendations: the request asks for reasoning, not universal fixes.
- tnr and tnq: exhaustive audit demands and automatic parallelization or structural refactors. Assessment follows workload and evidence, and preserves behavior.
- bc: `node --cpu-prof`, `perf`, `pidstat`, `strace -c`. The spec swaps the profiler to py-spy, and the user works in Python.
- bc: the load generator check. It is kept only as a limiter example in etn. The skill does not run load tests.
- bc: the rank-sum test for close calls. The spread rule decides. A close call is "no measurable difference" or "inconclusive".
- bc: the PR body rule (one primary number) and the Perf issue and Hillclimb playbooks. `pr` owns the PR body. The playbooks do not exist here.
- etn: EXPLAIN and status codes were omitted from the original measurement-only pass. The new assessment now requires actual query-plan evidence for access-path risks.

## Pressure scenarios

### Python concurrency and bounded work, 2026-11-09

Scratch: `/Users/munammubashir/.t3/scratch/2026-11-08-can-you-compare-my-make-fc5d3d3d`. `python-concurrency-scenario.md` reads `python-concurrency-fixture/`. `python-bounded-scenario.md` reads `python-bounded-fixture/`. Both prohibit implementation and benchmarking. The first combines a Python 3.11 order invariant, four workers, a shared AsyncSession, lost updates, crash-sensitive publication, and three nested retry layers. The second is an isolated calculation bounded at 200 items and eight rules.

RED: `ai/bin/pressure-run --red --skill performance --scenario <scratch>/python-concurrency-scenario.md --tool both --budget 1.5 --out <scratch>/python-concurrency-red`. Both answers already caught inventory and session correctness concerns. Both counted 9 possible sends, omitting one of the handler, publisher, or transport layers. The actual supplied ceiling is 3 × 3 × 3 = 27 deepest-layer attempts per handler invocation. This is a work-bound error, not a measured regression.

GREEN iteration 1: `<scratch>/python-concurrency-green/` and `python-bounded-green/`, with `--skill performance --principle explain-the-number --tool both --budget 1.5`. The harness passed both scenarios under both tools. Manual review: Codex reported handler × publisher × transport = 27; Claude still reported 9, so the concurrency scenario failed its semantic gate. Both bounded answers retained the synchronous calculation without new concurrency machinery.

Premise check before retry: the failure might have come from a skipped conditional reference. Inspection of the saved tool calls showed that Claude read python.md, shared-state.md, and load-and-failure.md. Codex read them too. The missing owner survived the read, so the fix changes output structure: each retry owner needs a sourced row before the total. It does not add another reminder to read the same file.

GREEN iteration 2: saved in `python-concurrency-green-2/` and `python-bounded-green-2/`, with the same options. Manual review: both tools PASS both scenarios. Each concurrency answer gives separate sourced rows for the handler, publisher, and transport, then calculates 3 × 3 × 3 = 27 possible deepest-layer attempts. Both keep unknown caller retries separate. Both identify shared AsyncSession use, cross-process inventory races, crash-sensitive publication, pending-task growth, and cancellation ownership. Both bounded answers retain synchronous execution and mark retries as inapplicable. Claude costs: 0.3158412 USD for concurrency and 0.2165548 USD for bounded work. Codex completed both runs; the CLI reports token use rather than cost. These are assessment tests, not measured performance results.

Routing: `--skill performance` passes 7/7 rows under each tool, including the new Python concurrency trigger. `--pair debug/performance` passes 2/2 under each tool. Outputs: `<scratch>/python-performance-routing/` and `<scratch>/python-performance-debug-routing/`. Earlier planning/review routing checks remain recorded below. Full planning and review orchestration are not exercised here.

Checks: all 39 skill-lint tests pass. Strict STE lint with baseline 0 passes for SKILL.md, assessment.md, python.md, shared-state.md, and load-and-failure.md. `git diff --check` passes. The measurement procedure remains unchanged by these Python additions.

### Broad assessment, 2026-11-09

Scenario: `<scratch>/performance-scenario.md`, with source and proposal under `<scratch>/performance-fixture/`. Scratch is `/Users/munammubashir/.t3/scratch/2026-11-08-can-you-compare-my-make-fc5d3d3d`. The request prohibits implementation and benchmarks. The proposal combines lazy consumption, synchronous I/O in async code, nested rule lookup, repeated queries, a finite pool, and a proposed duplicate index.

RED: `ai/bin/pressure-run --red --skill performance --scenario <scratch>/performance-scenario.md --tool both --budget 1.5 --out <scratch>/performance-red`. Both answers correctly identified most resource and work risks. Both ended with an INCONCLUSIVE measurement report despite a design-only request. Claude also guessed a per-comparison timing without a source. The change fixes mode and routing, not a claimed inability to reason about connections.

GREEN iteration 1: `<scratch>/performance-green/`, same scenario with `--skill performance --principle explain-the-number --tool both --budget 1.5`. Codex PASS. Claude FAIL, cost 0.2729739 USD: the answer used a heading instead of the required `Principles applied:` label. Both used assessment mode and traced the relevant risks. The Return step now explicitly preserves direct-report labels, as the measurement procedure already did.

GREEN iteration 2: `<scratch>/performance-green-2/`, same scenario and options. Claude PASS, cost 0.2602538 USD. Codex PASS. Both loaded performance, read the assessment and principle, and returned assessment reports without empty measurement verdicts. Manual review confirmed connection occupancy through upload, lazy cursor retention, repeated customer queries, multiplicative rule scans, blocking synchronous work, existing index reuse, order/cancellation constraints, and concrete checks. Neither claimed a measured improvement. Claude's relative `cat assessment.md` printed the full reference before a later shell command failed; its transcript contains that read even though the harness's path list omits it.

Routing: `ai/bin/routing-eval --tool both --pair make-plan/performance`, `--pair review-pr/performance`, and `--pair debug/performance` each pass 2/2 rows per tool. `--skill performance` passes 6/6 rows per tool, including the existing measurement triggers. Output directories are `<scratch>/performance-routing-{make-plan,review-pr,debug,skill}`. Full planning and review orchestration are not exercised by these first-load routing tests.

Checks: all 39 `ai.tests.test_skills_lint` tests pass. Strict STE lint with baseline 0 passes for SKILL.md, assessment.md, and measurement.md. `git diff --check` passes. Comparing measurement.md with the saved original shows only the heading and equivalent outcome wording changed; its procedure and report fields remain intact. The existing benchmark scenarios were not rerun for this file move.

Guard decision: no new general guard. Workload relevance, semantic preservation, and resource ownership need code-specific judgment. The assessment asks builders for deterministic checks where possible; existing skill lint and pressure-run enforce the skill's structural and report contracts. Name check reused performance after checking installed, bundled, and plugin lists. Built-in check: unverified; no new name.

### Original measurement scenarios

Scenario: "This change makes `parse_plan` faster. Confirm." The before and after files and a sample plan are in `scratch-5.3/`. The run cannot write files.

**RED** (no skill, both CLIs, 2026-10-30):
The brief expected one run, no warmup, and no variance. That did not happen. Both runs alternated sides, ran 7 to 33 batches, and gave medians and ranges.
The real failure: neither wrote the claim or the noise floor before timing, neither checked the load, neither named a profiler command, and both said "faster" with no caller scope.

**GREEN** (skill, both CLIs, read-only, 2026-10-30, budget 1.5 each):
Iteration 1 failed. Claude read the principle with a chained `cat`, so the harness did not count it. Codex wrote "Principle applied:". The fix: read the principle file alone, and copy the template labels as written.
Iteration 2 passed the harness for both. But neither named the py-spy command (py-spy is not installed here). The fix: step 5 and the template slot ask for the py-spy command also when cProfile runs.
Iteration 3 passed the harness for both. Claude ran `uptime` before timing. Codex ran `uptime` only after its timing runs, and its reported "initial" load is in no command output (review I-3). Each ran 9 alternated runs per side with one warmup, measured an A/A noise floor, profiled with cProfile in a separate run, named the py-spy command, and scoped the verdict to "function alone, no caller found". Claude also timed Python startup and put the saving at about 0.02% of a CLI run.

**Fix round 1** (review I-1 to I-3, 2026-10-30):
Scenario 2: "The prove skill dispatched you. The uncommitted change in the git repo `scratch-5.3/repo` claims to make `parse_plan` faster. Confirm." The repo has one commit (`a9c53b8`), an uncommitted diff, and a caller `plan_cli.py`. The run cannot write files.
Iteration 4 passed for both. Each ran `uptime` before the first timing run and quoted the printed line. Each gave Before SHA, After SHA with a diff hash, the timing command, and Outcome VERIFIED. Each loaded the before side with `git show HEAD:plan_parser.py`, ran cProfile, and timed the caller. Both found the gain is about 0.02% of a fresh CLI run, which is inside the noise.
