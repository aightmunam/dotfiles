# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **bc:** pstack-claude `plugins/pstack/skills/benchmark-checklist/SKILL.md`.
- **etn:** `ai/principles/explain-the-number.md` (from pstack principle-explain-the-number).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 performance entry and the `prove` entry.
- **brief:** task 5.3 brief (profiler py-spy, the cProfile fallback, the RED scenario, the repo lines).
- **review:** task 5.3 review, fix round 1 (I-1 to I-3, M-1, M-4, M-5) and the controller rulings.
- **py-spy docs:** Context7 `/benfred/py-spy` (root on macOS; `top` is a live view).
- **fcd:** `ai/skills/fact-constrained-debugging/SKILL.md` (removed after eec5ad9; read it in git history) (the form bar).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "T" is the report template.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
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
Iteration 3 passed the harness for both. Claude ran `uptime` before timing. Codex ran `uptime` only after its timing runs, and its reported "initial" load is in no command output (review I-3). Each ran 9 alternated runs per side with one warmup, measured an A/A noise floor, profiled with cProfile in a separate run, named the py-spy command, and scoped the verdict to "function alone, no caller found". Claude also timed Python startup and put the saving at about 0.02% of a CLI run.

**Fix round 1** (review I-1 to I-3, 2026-10-30):
Scenario 2: "The prove skill dispatched you. The uncommitted change in the git repo `scratch-5.3/repo` claims to make `parse_plan` faster. Confirm." The repo has one commit (`a9c53b8`), an uncommitted diff, and a caller `plan_cli.py`. The run cannot write files.
Iteration 4 passed for both. Each ran `uptime` before the first timing run and quoted the printed line. Each gave Before SHA, After SHA with a diff hash, the timing command, and Outcome VERIFIED. Each loaded the before side with `git show HEAD:plan_parser.py`, ran cProfile, and timed the caller. Both found the gain is about 0.02% of a fresh CLI run, which is inside the noise.
