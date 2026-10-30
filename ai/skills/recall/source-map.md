# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **recall:** pstack-claude `plugins/pstack/skills/recall/SKILL.md`, all of it. Line numbers below are of that file.
- **pw:** `ai/principles/prove-it-works.md` (from pstack `principle-prove-it-works`), live at `~/.agents/principles/prove-it-works.md`.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.4 recall entry, section 8.7 table (recall row), and the never-block-on-the-human row.
- **ho:** `ai/skills/handoff/` (Task 6.6). `capsule-template.md` is the shared contract. This skill points to it and does not copy it.
- **rs:** `ai/skills/research/SKILL.md`, Loop 3 (explorer fallback) and Loop 5 (the History method).
- **rh:** `ai/skills/resume_handoff/SKILL.md`, the old skill that this skill replaces.
- **brief:** Task 6.7 brief, its Global Constraints, and the 6.7 dispatch.

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md. "Template" is `ai/skills/handoff/capsule-template.md`.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| A full capsule from the user: use it and skip the mining. | recall line 20. | P | Loop 1. | Untested. |
| Lock the scope before the search: window (default 7 days), topic, workspace. State it back. | recall line 21. spec 8.4. | D | Definitions. Loop 2. Rules. Red flags. | RED: no run stated a scope. |
| The scope is the first line of the answer. | recall line 21 (state the scope back). Audit: a headless run shows only the answer. | O | Loop 2. Rules. Red flags. | GREEN |
| Never read another workspace's transcripts unless the user asks. | recall line 21. spec 8.4. | D | Loop 2. Red flags. | RED: Claude read the `other-app` chat. |
| Never turn "all" into "recent N" without saying so. | recall line 21. spec 8.4. | D | Loop 2. | Untested. |
| Read order: newest capsule, Claude chats, Codex sessions, git and PRs, plans, build ledger. | spec 8.4 recall. recall line 14 (transcript path). | P | Loop 3. | GREEN |
| `<encoded-cwd>`: each character that is not an ASCII letter or digit becomes `-`. | recall line 14. | P | Loop 3. | GREEN |
| Order chats by `ls -t`, not by name. Grep the topic first. Skip this chat and subagent, eval, and test chats. | recall line 22. spec 8.4. | P | Loop 3. | Untested. The fixture name order and time order agree for the in-scope chats. |
| Codex sessions: keep only the sessions whose `cwd` is the workspace. | recall line 21 (workspace scope). spec 8.4 (Codex sessions). | P | Loop 3. | GREEN |
| One or two chats: read them yourself. More: `explorer` agents, one slice each, one block per chat with the chat ID. | recall line 22. spec 8.4. | P | Loop 3. | Untested. The fixture has two in-scope chats. |
| No `explorer` type: a general-purpose agent. No dispatch tool: do it yourself. | rs Loop 3. | P | Loop 3. | Untested. |
| Sweep the shared record when the topic names a feature, file, subsystem, or bug. Use the History method of `research`. | recall line 23. spec 8.4 (History method in place of `why`). rs Loop 5. | P | Loop 4. | GREEN |
| Ask what is the state now, what failed, and what users still report. | recall line 23. | P | Loop 4. | GREEN |
| Skip an unavailable source and say so. An empty search is a finding. | recall line 23. rs Rules (an empty search is a finding). | D | Loop 4. | GREEN |
| Before "never recorded", search each place the project rules name. | recall line 23. spec 8.4. | D | Loop 4. Red flags. | Untested. |
| Check each PR, branch, and ticket with its tag check before the tag. Read each revert hit. | recall line 25. spec 8.4 (principle prove-it-works). pw. ho Template (Tags). Dispatch (read each grep hit for #N). | D | Loop 5. Red flags. | RED fixture: the capsule says `[open PR #12]`, the fake `gh` says merged. |
| An old capsule is a candidate. The check wins. The difference goes under Problems. | pw (when you read a handoff, check its claims against the repo). ho Template (Tags, last line). | D | Loop 6. Rules. Red flags. | GREEN |
| Output: the capsule contract of `handoff`, in chat. Order, limits, tags, and evidence forms come from the Template. | recall lines 30 to 35. spec 8.4 (same contract). Dispatch (point to it, do not copy). | O | Loop intro. Loop 6. Red flags. | GREEN |
| Each tagged thread has the Command form. | ho Template (Evidence Forms). | D | Loop 6. Red flags. | GREEN |
| Cite chat findings by chat ID, shared-record findings by their source. | recall line 37. ho Template (Evidence Forms). | O | Loop 6. | GREEN |
| Quote a ruling of the user and cite its chat. | recall line 24 (keep the original wording and source of a human ruling). | D | Loop 6. | GREEN (bro length ruling). |
| Adjacent work stays out unless it blocks. | recall line 37. | D | Rules. | GREEN |
| Read-only. Jira, Sentry, Slack, and `gh` are reads only. | spec 8.4 ("Read-only"). Dispatch (live sources are read-only). | D | Rules. | GREEN (scratch repo unchanged). |
| No question to the user. A fact you cannot check is a Problems line. | spec never-block-on-the-human row. Controller ruling. | D | Rules. | GREEN |
| Principle pointer at the check step. `Principles applied:` line at the end. | spec 8.7 (recall row). brief (Principles). | P | Loop 5. Template. Red flags. | GREEN |
| Four repo lines, verbatim. | brief Global Constraints. | D | Repo Rules. | Untested. |

## Cut

- recall lines 8 to 10: the Copilot and Muse platform mappings. This setup has neither platform.
- recall line 14: `claude-project-dir.mjs`. This setup has no pstack plugin. The skill states the encoding rule in one line. The 200-character hash and `CLAUDE_CODE_PROJECT_DIR_NAME` are cut: no workspace path here is that long.
- recall line 20: the `session-pickup` playbook and the "human-readable summary" route. Neither exists here. The routing table in `ai/AGENTS.md` sends a standup summary to `what-did-i-get-done` and this chat to `ketchup`.
- recall line 22: a fast, cheap model and the poteto-mode reasoning levels. The `explorer` agent sets its own model.
- recall line 23: the `why` skill and its investigators. spec 8.4 puts the History method of `research` in its place.
- recall line 24: the rest of the epistemics file (agent interpretations, copied summaries as one chain). The kept rule is to quote the ruling and cite the chat.
- recall line 37: write the brief through `unslop`, and sanitize private context before public output. The answer is skill output in STE in a private chat. It is not public text.
- rh: the interactive start ("Which handoff would you like to resume from?") and "propose a course of action and confirm". spec never-block-on-the-human: reversible work proceeds with no question.
- rh: `humanlayer thoughts sync`, the ticket subdirectory, and the `YYYY-MM-DD_HH-MM-SS` file names. The spec path is `thoughts/shared/handoffs/YYYY-MM-DD-<topic>.md`.
- rh: "read the handoff FULLY with the Read tool" and the free analysis sections (Learnings, Artifacts). The capsule contract sets the sections and the limits.

## Principles

prove-it-works (spec 8.7, lint `PRINCIPLE_TARGETS`). The pointer is at Loop 5. The answer ends with `Principles applied: prove-it-works -> <the tag or claim that a check changed>`.

## Pressure scenarios

Scenario file: `.superpowers/sdd/2026-10-30-skill-rework/scratch-6.7/scenario.txt` in the skill-rework worktree. It uses a scratch git repo (`scratch-6.7/repo`), a fake `gh` (`scratch-6.7/bin/gh`), a stand-in for `~/.claude/projects` (`scratch-6.7/claude-projects`) and one for `~/.codex/sessions` (`scratch-6.7/codex-sessions`). The capsule `thoughts/shared/handoffs/2026-10-27-skill-rework.md` says `[open PR #12]` and `[planned, not started]` for ketchup. The fake `gh` says #12 is merged and #14 (ketchup) is open. Two chats belong to the repo. One chat in `-Users-munammubashir-Developer-other-app` says the skill rework is cancelled and #12 is closed.

**RED** (no skill, both CLIs, read-only, 2026-10-30):
Both runs checked `gh` and caught #12 as merged and #14 as open, because the scenario names the fake `gh`. Neither stated a scope. Claude read the `other-app` chat and put it in the answer. Codex listed it but did not read it. Neither used the capsule contract: no status tags, no capsule limits, no single next move.
The failure: no scope stated, another workspace's chat read, and no capsule contract.

**GREEN** (skill, read-only, 2026-10-30, three iterations):
Iteration 1: Codex PASS. Claude FAIL, "principle not read". Claude did not read the principle file. Its answer was otherwise correct. A red flag for the unread principle and one for a Problems line with no `Source:` were added.
Iteration 2: Codex PASS (203k input, 2.6k output tokens). Claude FAIL ($0.38), "principle not read". The transcript shows `cat ~/.agents/principles/prove-it-works.md` with the file text in its result. The harness splits a shell command only on `;`, `&&`, `||`, and `|`, not on a newline, so it missed the read. Iteration 3 (Claude only, no change, $0.37): Claude read the file again in a compound command whose last `ls` exited non-zero. The harness drops each Bash call with an error result, so it missed the read again. With newline splitting, iteration 2 passes.
All four answers start with the `Scope:` line (topic, 7-day window, workspace). All tag #12 `[merged #12]` with the `gh` command and the revert search, tag #14 `[open PR #14]`, sr/bro `[in flight sr/bro]`, and recall `[planned, not started]` with the searches named. All name the stale capsule under Problems, quote the bro ruling with its chat ID, and say that Jira, Sentry, and Slack were not available. No run read the `other-app` chat. Claude listed it and named it as out of scope. The scratch repo is unchanged.
