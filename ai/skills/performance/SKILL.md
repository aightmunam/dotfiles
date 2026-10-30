---
name: performance
description: Use when a change claims to make code faster or slower. Use when you report a speed-up or a regression that you measured, or when `prove` checks a performance claim.
---

# Performance

## Definitions

- **Claim:** the sentence that you would ship, for example "parse_plan is 2x faster at the median on a 900-line plan".
- **Side:** one version of the code that you time, before or after.
- **Spread:** the range between the fastest and the slowest run of one side.
- **Noise floor:** the spread that you get when both sides run the same code.
- **Limiter:** the resource that stops the code from running twice as fast. A profile or a counter shows it. A guess from the code is not a limiter.
- **Verdict:** faster, slower, no measurable difference, or inconclusive.

## The Loop

1. **Decide.** Do this before any command. Read the principle file alone, with your file read tool when you have one. Then write the claim. Write the result that would change the decision. Write the noise floor that you expect. Key sentence: before you trust, report, or act on a measured number, find what limits it, and rule out that it measured something else. Read ~/.agents/principles/explain-the-number.md before this step.
2. **Check the machine.** Run `uptime` and `sysctl -n hw.ncpu` (Linux: `nproc`). If the load is high, find the cause. If you cannot stop it, alternate the sides and say so. Read the timing code. Write what it times and what it ignores.
3. **Check the work.** Run both sides on the same input. Compare the outputs. Count the errors. The timed region must do the full work, and the code must use the result.
4. **Time.** Run each side at least 5 times, alternated (A, B, A, B). Discard one warmup run per side. Record the median and the range per side. Use the production settings and the same data for both sides.
5. **Profile.** Use a separate run. Do not report its times. Use py-spy: `py-spy record -o profile.svg -- python3 <script>`. With no file writes, use `py-spy top -- python3 <script>`. If `command -v py-spy` finds nothing, use `python3 -m cProfile -s cumtime <script>`. Write the py-spy command in the report, also when you use cProfile. Name the limiter from the profiler output.
6. **Scope.** Find the callers of the changed code. Time the path that a user waits on. Give the change as a share of that path. With no caller, write "function alone, no caller found".
7. **Report.** Copy the template block into your answer. Keep each label as written, also `Principles applied:`. Fill each slot. If a caller dispatched you, reply with the template only.

## Repo Rules

- never touch a prod Salesforce org, not even --help.
- No alembic upgrade or downgrade, and no DB mutation, without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Rules That Shape the Verdict

- **The spread decides.** An effect smaller than the spread is "no measurable difference".
- **Do the arithmetic.** A piece that takes 10% of the run can make the run at most about 11% faster. A result past a limit measured a cache, a no-op, or a bug.
- **Untuned is inconclusive.** If one side ran on default or debug settings, tune it and time again.
- **Inconclusive is not a pass.** Give "inconclusive" when you cannot name the limiter, or when step 3 did not pass. Name the gap.
- **A ballpark is one run.** If the user asks for a quick ballpark, one run is enough. Still do step 3. Write "one run" in the report.

## Red Flags

- Your first timed run came before the claim and the noise floor. Go back to step 1.
- No `uptime` output. Go back to step 2.
- Fewer than 5 runs per side, or no range. Go back to step 4.
- The limiter comes from reading code, not from a profile. Go back to step 5.
- The verdict has no scope. Go back to step 6.

## Report Template

```
Verdict: <faster | slower | no measurable difference | inconclusive>, <scope>
Claim (written before the run): <sentence>
Number: <before> -> <after> <unit>, median of <N> runs per side, range <lo> to <hi>
Noise floor: <value>. Effect: <value>.
Machine: load <uptime values>, <cores> cores
Work check: <outputs equal, error count>
Limiter: <from the profile>
Profiler: py-spy command: <py-spy command for this script>. Ran: <the command that ran>, <why>
End-to-end share: <share of the caller path> | function alone, no caller found
Principles applied: explain-the-number -> <choice it changed>
```
