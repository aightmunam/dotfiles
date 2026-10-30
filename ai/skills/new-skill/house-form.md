# House Form

Check each line. A line that does not apply says why in the handoff.
The model skill is `ai/skills/fact-constrained-debugging/`. Finished examples are `ai/skills/research/`, `ai/skills/brainstorm/`, `ai/skills/make-plan/` and `ai/skills/unslop/`.

## Name check

- [ ] The name is full English words in kebab-case. It has no abbreviation and no prefix.
- [ ] The name is not a Claude Code built-in command. Type `/` in Claude Code, or read the built-in list in the Claude Code docs.
- [ ] The name is not a bundled skill or an installed skill. Read the skill list in your session. Run `ls ~/.agents/skills ~/.claude/skills ~/.codex/skills ~/.codex/skills/.system ai/skills`.
- [ ] The name is not a plugin skill. Run `find ~/.claude/plugins -path '*/skills/<name>/SKILL.md'`.
- [ ] On a collision, use a longer full-word name (`plan` became `make-plan`, `review` became `review-pr`).
- [ ] A rule for one repo only goes in that repo's `AGENTS.md` or a guard. It is not a skill.

## Source rule

- [ ] The primary source is pstack, superpowers or Pocock. You read each source skill in full from `~/Developer/ref/` before you wrote. The pins are in `ai/sources.lock`.
- [ ] You started from the mechanisms of the source, not from an old skill.
- [ ] An old skill gives only fixed contracts (file formats, tool calls), failures seen in an audit, and rules that an audit showed to work.
- [ ] Each rule traces to a source row, an audit finding, or the user's words. A rule with none is cut.
- [ ] Each cut source rule is under `## Cut` in `source-map.md`, with its reason.

## SKILL.md

- [ ] Frontmatter has `name` (equal to the directory name) and `description`.
- [ ] `description` is one line. It starts with `Use when`. It has no `"` and no colon followed by a space.
- [ ] `description` gives triggers only: situations, symptoms, and requests. It does not give steps.
- [ ] `description` matches the skill's row in `## Skill routing` in `ai/AGENTS.md`.
- [ ] `SKILL.md` has about 50 lines and at most 80. Detail is in reference files that a named step tells the agent to read.
- [ ] Definitions come first. They define the terms that the rules depend on, in two or three lines each.
- [ ] The loop is numbered. Each step has one or two lines and names its output or its role.
- [ ] Each step ends on a result that the agent can check.
- [ ] Rules shape the output or the claims. Each rule changes a decision that the model does not make by default.
- [ ] Each red flag sends the agent back to a named step.
- [ ] A required output template has fixed sections. An empty section says why.
- [ ] Each subagent role has its exact prompt contents, sees only its inputs, and has a fallback when no dispatch tool exists.
- [ ] A skill that works in a repo has the four repo lines, verbatim, as in `ai/skills/make-plan/SKILL.md`.
- [ ] The text names no plugin skill and no plugin store path. `ai/tests/test_skills_lint.py` holds the list of forbidden names.

## Writing

- [ ] `SKILL.md` is ASD-STE100 strict: short sentences, one instruction in each sentence, active voice.
- [ ] `python3 ai/vendor/ste-lint.py --baseline 0 ai/skills/<name>/SKILL.md` reports 0 violations.
- [ ] No file has an em dash.
- [ ] One word has one meaning. A leading word repeats as a token, not as a sentence.
- [ ] Each meaning is in one place. A fact that a file or `--help` gives is not copied.

## Principles

- [ ] Each principle for the skill (its `PRINCIPLE_TARGETS` entry in `ai/tests/test_skills_lint.py`) has a pointer at the step it governs.
- [ ] The pointer form is the key sentence inline, then `Read ~/.agents/principles/<name>.md before this step.`
- [ ] The output template has the line `Principles applied: <name> -> <choice it changed>`.
- [ ] It cites only principle files that the run read in this session.
- [ ] A new skill with principles gets an entry in `PRINCIPLE_TARGETS`.

## Routing

- [ ] `## Skill routing` in `ai/AGENTS.md` has one row for the skill. Change the row in the same commit as the triggers.
- [ ] Each skill that overlaps has one tie-break line that names both sides.
- [ ] `ai/tests/routing/prompts.tsv` has one prompt for the skill and one for each side of each new tie-break. If the file does not exist yet, list the prompts in the handoff.

## Tests

- [ ] RED ran before `SKILL.md` existed. The failure line comes from the saved answers.
- [ ] GREEN ran under both CLIs with each principle. Both pass, and you judged the RED failure gone from the saved answers.
- [ ] `source-map.md` has the columns rule, source, form, where enforced, and scenario.
- [ ] `source-map.md` has `## Pressure scenarios` with two to four lines each for RED and GREEN.
- [ ] `python3 -m unittest ai.tests.test_skills_lint -v` passes.
- [ ] For trigger evals on the description, run `skill-creator` when the user asks for it.
