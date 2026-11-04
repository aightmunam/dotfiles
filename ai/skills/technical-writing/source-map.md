# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **pstack:** pstack-claude `plugins/pstack/skills/technical-writing/SKILL.md`. The user gave the cursor/plugins copy. That copy differs only by `disable-model-invocation: true` in its frontmatter.
- **agents:** `ai/AGENTS.md`, the `## Writing standard` section.
- **user:** the request of 2026-11-04 to add the pstack skill and to rewrite the dotfiles README with it.
- **red:** the RED answers (see `## Pressure scenarios`).

Form key. P is a procedure step. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "L" is `layers.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Pick one mode for each section (Diátaxis). | pstack "Pick the mode first". | P, D | Loop 2. Rules. Red flags. L. | RED: both answers mix steps, tables and reasons in one section. |
| A heading states the point. | pstack Google layer. | D | Rules. Red flags. L. | RED: both use "Setup", "Secrets" and other topic headings. |
| Common case first. Condition before the step. | pstack Google and STE layers. | D | Rules. L. | Untested. |
| Each fact has a source path. Remove a claim that you cannot check. | pstack "Make every count or tree claim true". agents writing standard. | P, D | Loop 1. Rules. Red flags. | RED: both checked facts with no skill. Kept as a guard against regression. |
| Give the command for each live count. | pstack "include the command that regenerates it". | P, D | Loop 4. Red flags. L. | RED: Claude wrote "29 skills" and "15 files" with no command. |
| Each pronoun points at one noun. Other Global English items. | pstack Global English layer. | D | Rules. L. | Untested. |
| Vary the rhythm. Reference stays dry. | pstack "Vary the rhythm". | D | Rules. | Untested. |
| Use the codebase words. Make no new jargon. | pstack intro. agents writing standard. | D | Loop 3. L. | Untested. |
| Run `ste-lint` on the doc. | Guard. ste-lint enforces the semicolon, passive voice, and word-list rules of the pstack STE layer. | P | Loop 5. | RED: Codex wrote "is copied" and "are generated". |
| Run `unslop` on the draft. | pstack "Apply the unslop skill to every doc". | P | Loop 6. Red flags. | Untested. |
| Output template with modes, removed facts and lint. | new-skill house form. | O | Output template. | GREEN. |

## Cut

- pstack description: it is not "Use when" triggers.
- pstack "Cut every word" and "Use the short, everyday word": `unslop` rules 23 and 31 and the ste-lint word list enforce them.
- pstack STE layer (one instruction for each sentence, 20 words, one word for one meaning, active voice): ste-lint and the agents writing standard hold them.
- pstack "Use periods, not semicolons" and "Replace an em dash": ste-lint and `unslop` rule 13 enforce them.
- pstack "Skip idioms and metaphors", "no buzzwords": `unslop` rules 26 and 32 hold them. L keeps "no idioms" as one line.
- pstack "Propose a new offender to unslop": it changes no decision in a doc run.
- pstack "PR descriptions and commit messages": `pr` and `commit` own those texts.
- pstack "Product UI strings": no repo here has a copy guide.
- pstack "Indent code snippets with tabs": a rule of the Cursor repo. It is not durable here.
- Pocock `writing-shape`, `writing-fragments` and `writing-beats`: article writing, not technical docs. Pocock `writing-for-agents`: `new-skill` covers agent docs.
- superpowers `writing-plans` and `writing-skills`: `make-plan` and `new-skill` cover them.

## Pressure scenarios

RED (2026-11-04, `--red --tool both`, scenario: rewrite `~/dotfiles/README.md`, print it, edit no file). Both answers fixed the stale paths and counts with no skill.
Failure: both mix how-to steps, reference tables and "why" paragraphs in one section, and both use topic headings ("Setup", "Secrets", "AI toolchain").
Claude gives live counts ("29 skills", "15 files") with no command. Codex uses the passive voice ("is copied", "are generated").

GREEN-1 (2026-11-04, same scenario, `--tool both`). claude PASS (0.77 USD). codex PASS.
RED failure gone. Both split the steps, the tables and the "why" text into separate sections. Both use point headings ("Set up a new machine", "Keep secrets out of the repo").
Claude replaced each live count with a command (`ls ai/skills`, `git ls-files ai/claude/hooks`). Neither printed the output template, because the scenario asked for its own five-line list.
