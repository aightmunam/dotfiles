# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **bc:** pstack-claude `plugins/pstack/skills/benchmark-checklist/SKILL.md`.
- **etn:** `ai/principles/explain-the-number.md` (from pstack principle-explain-the-number).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 performance entry and the `prove` entry.
- **brief:** task 5.3 brief (profiler py-spy, the cProfile fallback, the RED scenario, the repo lines).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (the form bar).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "T" is the report template.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Write the claim, the result that changes the decision, and the noise floor before the first timed run. Read the principle file alone. | spec 8.4. etn rule 1. bc "Before you run anything". Audit: GREEN-1 Claude read the principle in a chained `cat`, which the harness does not count. | P | Loop 1. T Claim, Noise floor. Red flags. | RED: neither run wrote a claim or a noise floor first. GREEN-3: both give the claim and a measured A/A noise floor. |
| Check the load and the core count. Alternate the sides on a busy machine. | bc "Before you run anything". | P | Loop 2. T Machine. Red flags. | RED: neither run checked the load. |
| Read the timing code. Write what it times and ignores. | bc "Before you run anything". | P | Loop 2. | GREEN |
| Check outputs and errors. The timed work must happen. | bc questions 4 and 7. etn (errors, skipped work, code that never ran). | P | Loop 3. T Work check. Rules, inconclusive. | RED: both runs compared outputs. Kept, the baseline did it. |
| At least 5 runs per side, alternated, median and range. | bc question 5. etn (keep the run count and the spread). | P | Loop 4. T Number. Red flags. | RED: both runs did this. Kept, the brief names it. |
| Discard one warmup run per side. | bc question 5 (warmup favors neither side). Brief RED failure (no warmup). | P | Loop 4. | GREEN |
| Production settings and the same data for both sides. Untuned is inconclusive. | bc question 2. etn (a side left on default settings). | D | Loop 4. Rules. | Untested. The scenario has no settings. |
| Profile in a run that you do not report. Name the limiter from it. | bc question 1. etn ("why not double", a guess is not a limit). | P | Loop 5. T Limiter. Red flags. | RED: Claude found the cause by ablation, Codex by a profile. Neither named a profiler. |
| py-spy is the profiler. cProfile is the fallback when `command -v py-spy` finds nothing. `py-spy top` with no file writes. | spec 8.4 (profiler swapped to py-spy). brief. | P | Loop 5. T Profiler. | GREEN-2 failed: both ran cProfile but named no py-spy command. GREEN-3: both name the py-spy command and ran cProfile. |
| Time the caller path. Give the change as a share. With no caller, say so. | bc question 6. etn (a piece too small to matter end to end). | P | Loop 6. T End-to-end share. Red flags. | RED: both said "faster" with no scope. |
| The spread decides. Effect below the spread is no measurable difference. | spec 8.4 (stop when the spread is larger than the effect). etn rule 2. bc question 5. | D | Rules. T Noise floor. | GREEN |
| Do the arithmetic against limits. | bc question 3. | D | Rules. | Untested. The scenario stays inside limits. |
| Inconclusive is not a pass. Name the gap. | bc Report. spec 8.4 prove entry (inconclusive is not a pass). | D | Rules. T Verdict. | GREEN |
| A ballpark is one run, but still check the work. | bc ballpark paragraph. | D | Rules. | Untested. |
| Lead with the verdict. Number with unit, run count, range, limiter. | bc Report. | O | T. | GREEN |
| Dispatched by a caller (`prove`): the template only. | spec 8.4 prove entry (runs `performance` checks). fcd (roles with a fallback). | O | Loop 7. | Untested. No run was dispatched. |
| `Principles applied:` line, label kept as written. | spec 8.7. | O | Loop 7. T. | GREEN-1: Codex wrote "Principle applied:". GREEN-2 and GREEN-3 passed. |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | Untested. The runs cannot write or open a DB. |

## Cut

- bc: `node --cpu-prof`, `perf`, `pidstat`, `strace -c`. The spec swaps the profiler to py-spy, and the user works in Python.
- bc: the load generator check. It is kept only as a limiter example in etn. The skill does not run load tests.
- bc: the rank-sum test for close calls. The spread rule decides. A close call is "no measurable difference" or "inconclusive".
- bc: the PR body rule (one primary number) and the Perf issue and Hillclimb playbooks. `pr` owns the PR body. The playbooks do not exist here.
- etn: EXPLAIN and status codes for an API or a query. The skill names step 3 (work check) and keeps the general rule. Add it when a scenario needs it.

## Pressure scenarios

Scenario: "This change makes `parse_plan` faster. Confirm." The before and after files and a sample plan are in `scratch-5.3/`. The run cannot write files.

**RED** (no skill, both CLIs, 2026-10-30):
The brief expected one run, no warmup, and no variance. That did not happen. Both runs alternated sides, ran 7 to 33 batches, and gave medians and ranges.
The real failure: neither wrote the claim or the noise floor before timing, neither checked the load, neither named a profiler command, and both said "faster" with no caller scope.

**GREEN** (skill, both CLIs, read-only, 2026-10-30, budget 1.5 each):
Iteration 1 failed. Claude read the principle with a chained `cat`, so the harness did not count it. Codex wrote "Principle applied:". The fix: read the principle file alone, and copy the template labels as written.
Iteration 2 passed the harness for both. But neither named the py-spy command (py-spy is not installed here). The fix: step 5 and the template slot ask for the py-spy command also when cProfile runs.
Iteration 3 passed for both. Each ran `uptime` before timing, ran 9 alternated runs per side with one warmup, measured an A/A noise floor, profiled with cProfile in a separate run, named the py-spy command, and scoped the verdict to "function alone, no caller found". Claude also timed Python startup and put the saving at about 0.02% of a CLI run.
