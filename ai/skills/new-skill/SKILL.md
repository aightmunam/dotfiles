---
name: new-skill
description: Use when the user asks to create, write, or change a skill, or to edit a SKILL.md or its reference files. Use when reflect hands off a new skill or a substantive skill edit.
---

# New Skill

## Definitions

- **Pressure scenario:** a real task prompt that tempts the failure. It names real paths and asks the agent to act.
- **RED:** the scenario with no skill, or with the old skill for an edit. Its failure line is what the skill must fix.
- **GREEN:** the same scenario with the skill, under Claude and Codex. Both pass, and the RED failure is gone.
- **Source:** a rule in pstack, superpowers or Pocock (pinned in `ai/sources.lock`), an audit finding, or the user's words. A rule with no source is cut.
- **Guard:** a lint, test, hook or script that enforces a rule. A guard is not text.

## The Loop

Run each command from the dotfiles root: the root of your dotfiles worktree, or `cd "$(git -C ~/dotfiles rev-parse --show-toplevel)"`. Put run output in a scratch dir of this session.

1. **Guard first.** If a lint, test, or script can enforce the rule, use only that guard. Read ~/.agents/principles/encode-lessons-in-structure.md before this step, as a read of that file alone. Build the guard, or give it in full when you cannot write. A skill keeps only the part that needs judgment. If no part needs judgment, write no skill and stop at step 9.
2. **Name.** Read `house-form.md`. Your skill must pass each line of it. Do the name check in it. Read the `## Skill routing` table in `ai/AGENTS.md`. If a skill already covers the case, change that skill.
3. **Sources.** Search `~/Developer/ref/` for skills with the same purpose. Read each match in full. List each rule with its source. Apply the filter in the rules below. Cut each rule that fails it.
4. **RED.** Write the scenario to a scratch file. Run `ai/bin/pressure-run --red --skill <name> --scenario <file> --out <scratch>/red --tool both`. Read both saved answers. Write one failure line from them.
5. **Write.** Write `SKILL.md`, the reference files, and `source-map.md` against `house-form.md`. Each rule fixes a RED failure or has a source row.
6. **Route.** Add the row and the tie-break lines in `## Skill routing`. Add the eval prompts (see `house-form.md`).
7. **GREEN.** Run `ai/bin/pressure-run --scenario <file> --skill <name> --principle <p> --tool both --out <scratch>/green-<n>`. Give one `--principle` for each pointer. Read both answers. Change the skill and run again until both pass.
8. **Check.** Run `python3 -m unittest ai.tests.test_skills_lint -v` and `python3 ai/vendor/ste-lint.py --baseline 0 <SKILL.md>`. Record RED and GREEN in `source-map.md` under `## Pressure scenarios`.
9. **Hand off.** Fill the output template, also when you write no skill. The template is the full answer. Its last line is the `Principles applied:` line.

## Rules That Shape the Skill

- **The description gives triggers only.** It starts with "Use when". It names situations, not steps.
- **The filter.** Keep a rule only if it is durable, it changes a decision, no guard can enforce it, and no skill already says it.
- **Match the form to the failure.** A skipped rule gets a red flag. A wrong shape gets a template. A missing part gets a required slot.
- **State the target.** Write what to do. Use a prohibition only as a guardrail, next to its target.
- **Disclose by branch.** Keep in `SKILL.md` what every run needs. Move what only some runs need to a reference file.
- **No test, no status.** Write `green` only from two saved GREEN answers.

## Roles

`ai/bin/pressure-run` runs each scenario in a fresh agent. It shows the agent only the scenario. First go to the dotfiles root. If `ai/bin/pressure-run` does not exist there, give the scenario to a fresh agent with no skill and no hint of the failure. With no dispatch tool, put the scenario and both commands in the handoff. Set the status to `untested`.

## Output Template

```
Skill: `ai/skills/<name>/`. Status: <green | red only | untested>.
Guard: <the guard and its path, or "none" and the judgment that a guard cannot hold>.
Name check: <the lists you read, and each collision or "none">.
RED: <scenario>. Failure: <one line from the saved answers, or "pending" and the command>.
GREEN: claude <PASS or FAIL, cost>. codex <PASS or FAIL>. RED failure gone: <evidence>.
Routing: <row, tie-break lines, eval prompts>. Lint: <result>.
Cut: <each cut rule and its reason>.
<each file in full, only when you cannot write files>
Principles applied: encode-lessons-in-structure -> <choice it changed>
```

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- You wrote a text rule that a guard can enforce. Go back to step 1.
- You wrote or changed skill text before a RED failure line exists. Remove your new text. For an edit, revert only your change. Go back to step 4.
- The description says what the skill does. Go back to step 5.
- The skill has no `## Repo Rules` with the four lines verbatim. Go back to step 5.
- A rule has no source row and fixes no RED failure. Cut it. Go back to step 3.
- One CLI passed, or you judged GREEN from the check line only. Go back to step 7.
- The status says `green` with no saved GREEN answers. Go back to step 7.
- The answer has no `Principles applied:` line, or text after it. Go back to step 9.
