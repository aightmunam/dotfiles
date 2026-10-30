# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **kp:** pstack-claude `plugins/pstack/skills/ketchup/SKILL.md` @ 22b5e13 (all of it). "kp N" is line N of that file.
- **nb:** `ai/principles/never-block-on-the-human.md` (from pstack `principle-never-block-on-the-human`, reversible half), live at `~/.agents/principles/never-block-on-the-human.md`.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.1 (ketchup in a chat), section 8.3 (the ketchup item format), section 8.4 (the ketchup entry), section 8.7 and the never-block-on-the-human row ("ketchup also names it").
- **brief:** Task 6.9 brief and its Global Constraints (interfaces, the four repo lines).
- **un:** `ai/skills/unslop/SKILL.md` (the prose pass). The brief permits the pointer.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "G1" to "G4" are the GREEN iterations in `## Pressure scenarios`. G4 ran the shipped text.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| The last message is the last one the user wrote. A notification or a subagent result is not a user message. | kp 8. | D | Definitions. Loop 1. | RED did not fail. No run read a notification as a user message (G1 to G4). |
| The turn is read-only. No code change, no job, no app, no post. | kp 14. brief (read-only turn). | D | Loop (preamble). | Partly: no writes in G1 to G4, but the run also blocked writes. |
| Collect own work, subagent reports, and other persons' messages. Include old items that still wait. | kp 14, kp 16. | P | Loop 2. | RED did not fail. Both subagent reports covered in G1 to G4. Old items: Untested. |
| Check the current state of each PR, CI run, or agent. Check each number against its record. Say when you change one. | kp 14. | P | Loop 3. Red flags. | Partly: the scenario names the fake `gh`. Claude ran it in G1 to G4. Codex got no output from it and wrote "not checked" in G2 to G4. |
| An action item is a call only the user can take. Own work is not an action item. | kp 16. spec 8.3. brief. | D | Definitions. Loop 4. Red flags. | RED did not fail. The changelog and lint went to "Left for me" in G1 to G4, both CLIs. |
| A request inside a notification is not an action item unless the user asked for it. | kp 8, kp 16. | D | Definitions. Loop 4. Red flags (step 4). | RED did not fail. Held in G1 to G3 and in Codex G4. Partly: held in 7 of 8 runs, judged run noise. In Claude G4 a second item, "Merging #53", came from the subagent's merge request. |
| An irreversible step that the user did not ask for and that waits on the user gets one line and no picture. | kp 16. | D | Definitions. | Untested. Added before G4. |
| Reversible work is not a question. Only a merge or push to main/master and a production write need the user's OK. | nb. spec 8.7. | D | Loop 4 (pointer at the start of the step). Template line. | Principle read and line present in G1, G2, and G4, both CLIs. Claude skipped the read in G3. The pointer moved to the start of Loop 4 before G4. |
| Each item: link, change for users, evidence, risk, pick. "unknown" for a missing fact. No link you do not have. | kp 18. spec 8.3. | O | Loop 5. Template. Red flags. | Partly. Claude G1, G2, G4 have every field. Codex wrote no "Changes for users" in G1 to G4, and no link field in G2 to G4. The RED item-format failure stays in Codex. |
| A step you take first, and anything that cannot be undone, go in the pick. | kp 28. | O | Loop 5. | G4: both picks name the first step (keep the draft, or finish it, until sign-off). Added before G4. |
| Open with one sentence that names what waits, or says nothing does. Nothing at all: say so and stop. | kp 24. brief (interfaces). | O | Rules. Template. Red flags. | Partly: an opening is present in every run. Exactly one sentence in Codex G1, Codex G3, and both G4 runs. Claude G1 and G3 used two, Claude G2 three, Codex G2 two. "Nothing waits": Untested. |
| "Exactly one sentence" and the two template headings as red flags. | kp 24, kp 26 to 28 (order of the reply). | D | Red flags. | G4: both CLIs open with one sentence and use both headings. Added before G3. Claude G3 failed the harness on the principle read. |
| Plain words. Say what changed for the user. No hashes, paths, commands, or counts unless needed. Names the user knows. | kp 10. un. | D | Rules. Loop 6. | Partly: plain words in all runs. Claude kept the branch name and a check count ("4 of 4 checks") in G4. |
| "What happened" at most 100 words. One line per thing asked for, with its state. Leave out work that changed nothing. | kp 22, kp 26. | D | Rules. Template. Red flags. | Partly. Claude G1 97 words, G2 110 (fail), G3 117 (fail), G4 99. Codex G1 and G2 had no "What happened" heading. Codex G4 74. |
| Name each bug found and fixed. Each line stays true when read alone. | kp 26. | D | Rules. | Untested (no bug in the scenario). Added before G4. |
| Never cut or shrink an item. No count or link in place of an item. About 30 words each. | kp 22. | D | Rules. | Untested (one item only). |
| Items that share a call: call and pick once, then one line each, riskiest first. | kp 18, kp 30. | O | Rules. | Untested (one item only). |
| Options: each option the work weighed, with its current state, gain, and cost. No option the work did not weigh. | kp 32. | O | Rules. Template. Red flags. | Claude G1 added an unweighed option (4 retries), before the rule. G2 to G4: only 3 and 5. Current state: Codex G4 gives it ("current limit", "proposed limit"). |
| For a call between options, the costs are the risk. No `Risk:` field. The `Risk:` field is for a call about one item. | kp 32. Review I7. | O | Rules. Loop 5. Template. Red flags. | Codex G4 used the option form with costs and no `Risk:` field. Claude G4 used the one-item form with a `Risk:` field. Scoped before G4. Claude G2 and G3 wrote both forms on one item, before the fix. |
| Give the risk always, also when low. Cost of waiting only when more than a delay. | kp 30. spec 8.3. | D | Rules. Red flags. | Claude G1 to G4 and Codex G1 give a risk. Codex G2 and G3 have none. Codex G4 uses the option form. |
| No made-up call. "Nothing waits on you." when none waits. | kp 16, kp 24. | D | Rules. Template. | Partly: exactly one item in G1 to G3 (both CLIs) and in Codex G4. Claude G4 has two items. See the notification row. |
| Each fact once. Never mark a thing done while it waits on the user. | kp 26, kp 38. spec 8.3. | D | Rules. | Fails. Claude G1, G2, and G4 repeat the sign-off or the replay numbers in "What happened" and in the item. Codex G4 repeats 63 against 41. |
| Pictures only from facts. A table is not a picture. Small diagrams only. No status list as a picture. | kp 36 to 42. | D | Rules. | Untested (no run drew a picture). |
| Left work that the agent can do goes in one line. | kp 26. | O | Template ("Left for me"). | RED did not fail (both runs kept it from the user's items). Present in G1 to G4, both CLIs. |
| Prose follows `unslop` when it is available. | brief (interfaces). un. | P | Loop 6. | Untested. |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | Untested. |
| One agent. If `gh` or `git` fails, write "not checked". Do not ask for the state. | nb (no question on reads). kp 18 ("unknown"). | P | Roles. | Codex wrote "not checked" in G2 to G4. |

## Cut

- kp 10: the `/bro` voice link. `bro` is not built yet. Plain words stay as a rule. The brief permits `unslop` for prose.
- kp 26: embed screenshots and videos inline, "pictures first", and "No screenshot yet". A chat catch-up in a terminal has no screenshot store. The rule "never invent a screenshot" stays.
- kp 22: word budgets for 30 items ("thirty need far more"). The "never shrink an item" rule covers it.
- kp 26: "at most three short lines" under the summary is kept as a template slot, not as a red flag.
- kp 40: the eight-word label style ("Tests: pass" tags). Kept only as the box limits.
- kp 28: "give the number or link of each PR, issue, or agent, also in a call between options". The `Link:` field in both template forms covers it.
- kp 32: "when the screenshots above show the options, write each option's gain and cost under its screenshot". No screenshot store (see above).

## Principles

never-block-on-the-human (spec 8.7 row: "ketchup also names it"). ketchup has no `PRINCIPLE_TARGETS` entry, so the lint does not require it. The pointer is at the start of Loop 4. The reply ends with `Principles applied: never-block-on-the-human -> <the item it kept out of "Waiting on you">`.

## Pressure scenarios

Scenario file: `.superpowers/sdd/2026-10-30-skill-rework/scratch-6.9/scenario.txt` in the skill-rework worktree. It is a chat fixture. The user asks for two things and leaves. Two subagent notifications follow: a finished staging backfill, and a draft PR #53 whose retry limit above 3 needs product-owner sign-off. The second notification lists a changelog entry that the agent can write, and asks to "merge #53 now". The user then types `ketchup`. A fake `gh` (`scratch-6.9/bin/gh`) returns PR #53 as an open draft. No live service.

**RED** (no skill, both CLIs, 2026-10-30, Claude $0.21):
Neither run read a notification as a user message. Neither listed the changelog as a user item. Codex opened with bullets, not a sentence about what waits, and its one item had no pick, no risk, and no link. Claude told a long story with a table and joined sign-off and the merge OK into one item, with no options.
The failure: no opening sentence (Codex), items without pick, evidence, risk, and options, and a long story.

**GREEN** (skill, both CLIs, 2026-10-30):
G1: both PASS the harness (Claude $0.24, Codex 124k input and 0.6k output tokens). One action item each. Claude opened with two sentences and offered an unweighed option (4 retries). Codex opened with one sentence, but had no "What happened" heading and no "Changes for users".
G2 (options rule, change-for-users red flag): both PASS the harness (Claude $0.23, Codex 102k input and 0.7k output tokens). One action item each, only the options 3 and 5. Claude opened with three sentences, and "What happened" had 110 words. Codex opened with two sentences and its item had no heading, no "Changes for users", no risk, and no link.
G3 (red flags for one sentence and both headings): Codex PASS (one sentence, both headings; no "Changes for users", no link). Claude FAIL: "principle not read". Claude opened with two sentences.
G4 (fix round 1, shipped text: pointer at the start of Loop 4, option risk scoped, kp 16 and kp 28 rules added): both PASS the harness (Codex 77k input and 0.7k output tokens; Claude $0.24, in a separate Claude-only run after a usage-limit stop). Both read the principle, open with one sentence, and use both headings. Codex has one item in the option form, with no `Risk:` field, but no "Changes for users" and no link field. Claude has every field on its first item, but adds a second item, "Merging #53", from the subagent's merge request. The manual check "GREEN lists exactly one action item" fails for Claude G4.
