# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **sp:** superpowers `skills/brainstorming` (SKILL.md, builder-check-prompt.md, visual-companion.md).
- **grill:** mattpocock-skills `skills/productivity/grilling/SKILL.md`.
- **proto:** pstack-claude `plugins/pstack/skills/poteto-mode/playbooks/prototype.md`.
- **pm:** pstack-claude `plugins/pstack/skills/poteto-mode/SKILL.md` line 143 (settle a fork by observing it instead of asking the human).
- **interrogate:** pstack-claude `plugins/pstack/skills/interrogate/SKILL.md` (for a design, run a prototype or probe the current tree).
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 brainstorm entry and the never-block-on-the-human row.
- **ruling:** controller ruling for Task 3.5 (2026-10-30).
- **rs:** `ai/skills/research/SKILL.md` (worktree path and no-write fallback).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Explore the code before the first question. Search `~/Developer` for a named system. | grill (finding facts is your job). sp (current state, build on what exists). | P | Loop 1. Red flags. | RED: see Pressure scenarios. |
| Split open points into facts and decisions. Facts are yours. Ask only for decisions. | grill (facts vs decisions). spec 8.4 (facts are the agent's job). | D | Definitions. Loop 2. Rules. Red flags. | RED |
| If a run can answer it, run it instead of asking. | pm line 143. interrogate (probe the current tree). spec 8.4. ruling. | D | Loop 2. Rules. Red flags. | RED |
| A throwaway script lives in a scratch dir outside the repo. To keep it is a new request. | proto steps 1 and 3 (isolated scratch dir, throwaway). sp hard gate (spike exception). | D | Loop 2. Hard gate. Red flags. | Untested. |
| One question per message. | sp (each message ends with one question). spec 8.4 Keep. ruling. | D | Loop 3. Rules. Template. Red flags. | RED |
| Each question has a recommended answer. Word it so that yes accepts it. | grill (recommended answer, yes accepts). spec 8.4 Add. ruling. | D | Definitions. Loop 3. Rules. Template. Red flags. | RED |
| Ask first the decision that most others depend on. | grill (design tree, frontier). | P | Loop 3. | GREEN |
| Play back each part in 200 to 300 words. Mark guesses. | sp Play It Back. spec 8.4 Keep. | P | Loop 4. | Untested. A headless run stops at the first question. |
| Say your defaults. Each default is your call in the doc. | sp (how it gets made, a choice is your call). | D | Definitions. Rules. Doc template. Red flags. | Untested. |
| Design doc at `thoughts/shared/specs/YYYY-MM-DD-<topic>-design.md`, `status: draft` then `approved`. | spec 8.4 Output. Task 3.5 brief. sp The Written Design (sections). | O | Loop 5. Loop 7. Doc template. | Untested. |
| In a worktree, use the main checkout's `thoughts/`. Cannot write: the doc goes in the answer. | rs Loop 6. | P | Loop 5. | Untested. |
| Builder check by a fresh agent. Three groups. One set of questions only. | sp builder-check-prompt.md and The Written Design. spec 8.4 Keep. | P | Loop 6. `builder-check.md`. | Untested. |
| No dispatch tool: read the doc as the builder yourself. | sp (without a subagent tool). | P | Roles. `builder-check.md`. | Untested. |
| Theirs questions go one per message, each with a recommended answer. Their answers go into the doc. | ruling (one per message). sp (bring them in one message) is overridden. | D | Loop 6. `builder-check.md`. | Untested. |
| Hard gate. Nothing gets built before the user approves the doc. It overrides never-block-on-the-human. | sp HARD-GATE. spec 8.4 Keep. spec never-block-on-the-human row. | D | Definitions (Build). Hard gate. Red flags. | RED |
| Approval covers what the user saw. | sp Red flags ("sounds good"). | D | Rules. | Untested. |
| After approval, hand off to `make-plan`. | sp HARD-GATE (next step is the plan). Task 3.5 brief. | P | Loop 7. | Untested. |
| Several independent projects: say so, agree on an order with a recommended order, then one project at a time. | sp Size the Work (several independent projects). Review I1. | P | Loop 1. | Untested. The scenario is one project. |
| Intent, success, and anti-goals are decisions and the user's. Only a how-it-gets-made choice can be your call. Never write a guessed why into the doc. | sp opening (what they want, and why), Ground to cover (why now, success, anti-goals), How it gets made (your call). Review I2. | D | Definitions. Rules. Red flags. | Untested. A headless run stops at the first question. |
| Before you recommend, think of several options privately. Drop the weak ones and the ones that fight the why. | sp Think wide privately. Review I2. | P | Loop 3. | Untested. |
| A playback invites corrections ("Correct any part of this.") and ends with the next question. | sp Play It Back (ask what is wrong or missing). ruling (one question per message). Review M3. | P | Loop 4. | Untested. |
| Put each builder-check answer from the user into the doc. | sp The Written Design (update the document with their answers). Review M4. | P | Loop 6. `builder-check.md`. | Untested. |
| Cannot write files: do the builder check yourself before you show the doc. | sp (do not hand over the document until the check is back). Review M5. | P | Loop 5. | Untested. |
| Use the `thoughts/` of the repo where the change lands. In a worktree, find the main checkout with `git rev-parse --git-common-dir`. | rs Loop 6. Review M2. | P | Loop 5. | Untested. |
| The design doc and throwaway scripts are not builds. Product code, scaffolds, and installs before approval send you back to the gate. | sp HARD-GATE (building list, reading and exploring are fine). Review I3. | D | Hard gate. Red flags. | GREEN-2: neither run changed the repo. |
| Four repo lines, verbatim. | Brief Global Constraints. | D | Repo Rules. | Untested. |

## Cut

- sp: the opt-out line in the first message ("say so and I just start"). The spec Keep list does not name it, and it adds text before the one question. The gate exception for an opt-out goes with it.
- sp: "open questions, no list of example answers". The ruling overrides it. The spec names a question with no recommended answer as the failure.
- sp: the visual companion and its server. The spec does not keep it. Throwaway HTML goes through Loop 2 as a script outside the repo.
- sp: the size table. The router sends only work that needs a design to this skill.
- sp: `docs/superpowers/specs/` path. The spec puts the doc in `thoughts/shared/specs/`.
- sp: the handoff to the writing-plans skill of superpowers. The handoff is `make-plan`.
- sp: "Offer recon, they decide". Loop 1 explores without an offer. grill and spec 8.4 make facts the agent's job.
- sp: "say a reviewer will read it first". The builder check is short, and a notice adds text before the one question.
- sp: Ground to cover as a list, and "Get them describing" with open questions first. The ruling puts a recommended answer on each question. The why, success, and anti-goals stay as decisions (Definitions).
- sp: match the user's vocabulary and plain language. The writing standard in `ai/AGENTS.md` and STE cover the text.
- grill: the whole frontier in one numbered round. The ruling keeps one question per message.
- grill: sub-agents for each fact. Loop 1 and Loop 2 get facts inline. The spec runs brainstorm in chat.
- proto: variants behind a switcher, screenshots, and the reply shape. They are the prototype playbook's own output, not a design conversation.

## Principles

No principle applies. The spec 8.7 table has no brainstorm row, and the lint has no `PRINCIPLE_TARGETS` entry. The skill has no pointer and no `Principles applied:` line. Since commit 4840ae0, `pressure-run` checks for that line only when the caller gives a `--principle`. The controller judges the questions by hand against the failure from RED.

## Pressure scenarios

Scenario: "I want The Eye to post a Slack message when a review finds a blocker. Help me design it."

**RED** (no skill, both CLIs, read-only, 2026-10-30):
Claude explored the repo, then gave a full design and a plan before any answer from the user. It ended with three decisions in one message. It also wrote a plan file. Codex asked the user where The Eye's code lives. The Codex baseline was not skill-free: it read the superpowers brainstorming SKILL.md from its plugin cache, and still asked the fact. A search of `~/Developer` finds that fact.
The failure: several decisions in one message, and a question about a fact that the agent can find.

**GREEN** (skill, both CLIs, read-only, 2026-10-30):
Iteration 1 passed for both on the manual checks. Claude loaded the skill with the Skill tool. Codex read `.agents/skills/brainstorm/SKILL.md`. Each run found `~/Developer/work-dashboard` and read the review code before it asked. Each answer ends with one decision (fire on `request_changes`), with a recommended answer. Neither run changed the repo. Claude wrote only its plan-mode file under `~/.claude/plans/`.
The harness exit is 1 for both runs, with "answer has no 'Principles applied:' line". Commit 4840ae0 removed that check for runs with no `--principle`.
Iteration 2 ran after the changes from the review (I1 to I3, M2 to M8). The harness passed both runs (exit 0). Claude loaded the skill, read `review.py`, `review_store.py`, and `notifier.py`, and ended with one Decision and a Recommended answer. Codex read the skill, cited `review.py:68` and `notifier.py`, gave a recommendation with a reason, and ended with one question. Codex did not use the template labels. Neither run changed the repo. Claude wrote only its plan-mode file.
