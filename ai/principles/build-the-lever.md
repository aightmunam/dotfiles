# Build the lever

Source: pstack-claude plugins/pstack/skills/principle-build-the-lever/SKILL.md @ 22b5e137e945cb65dd29dac5fc703c13d83a00aa

Key sentence: When work is not trivial, build the tool that does it or proves it. Do not do it by hand.

## Rules

- A script gives the same result every run. A reviewer can run it again. A hand edit can only be checked by doing it again.
- Do the first unit by hand to learn the recipe. Then build the tool. Run the tool on that unit and compare it with your hand result.
- Use a codemod or ast-grep rule for a wide edit. Use a generator for repeated files.
- Use a SQL query for analysis. Use a pytest case or a script for a check.
- Make the script safe to run again.
- For a comparison tool, add one known-bad change for each thing it claims to compare. Check that it reports each one.
- If input is missing, the tool must refuse. It must never report a match.
- If one script can process every unit, run it yourself. Do not start subagents to hand-apply what a script can do.
- If you must use subagents, write the recipe, the check, and the files they must not touch in one skill file. Keep it outside their write scope.
- If you cite this principle, the diff must contain the script or the generator.
- Build the smallest script that does the job. Do not build a framework.

## When it applies

- Any change that is more than a few obvious edits.
- A data fix, an Alembic backfill check, a wide rename, or an analysis.
