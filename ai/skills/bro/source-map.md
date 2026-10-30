# Source Map

`ai/sources.lock` pins the sources. Paths are under `~/Developer/ref/`.

- **pstack:** pstack-claude `plugins/pstack/skills/bro/SKILL.md` (one paragraph).
- **agents:** `ai/AGENTS.md`, the `## Skill routing` row and the bro tie-break lines.
- **spec:** `thoughts/shared/specs/2026-10-30-skill-rework-design.md`, section 8.1 (bro: say it plainly) and section 8.7.
- **brief:** task 6.8 brief (interfaces, the RED scenario, the failures to look for).

Form key. P is a procedure step or a template slot. D is a discipline with a red flag. O is an output.
"Loop N" is a step in SKILL.md.

| Rule | Source | Form | Where enforced | Scenario |
|---|---|---|---|---|
| Restate the last message. | pstack ("Restate your last message"). brief interfaces. agents routing row. | P | Definitions. Loop 1. Loop 2. | GREEN-1 |
| Use fewer words than the last message. | pstack ("more simply and concisely"). brief (failure: a longer answer). | D | Rules. Red flags. | RED: Claude used 152 words for a 142-word message. GREEN-1: Claude 138 words, Codex 74. |
| Use no jargon. Tell what a command or an id does. Do not quote it. | pstack ("Stop using jargon"). brief (failure: the jargon kept). | D | Definitions. Rules. Red flags. | RED: Claude kept `down_revision`, both ids and the merge command. GREEN-1: none in either answer. |
| Plain sentences. No heading, list, bold text or code block. | pstack ("like one human talking to another"). | D | Loop 2. Rules. | RED: Claude used a numbered list, bold and a code block. GREEN-1: plain sentences in both. |
| Add nothing. | brief (failure: new facts added). | D | Rules. Red flags. | RED: Claude added "Pick option 1 unless..." and "safe default". GREEN-1: no advice in either answer. |
| Keep the main point and each choice. | pstack ("Restate"). | D | Loop 1. Rules. Red flags. | GREEN-1: both answers keep both fixes and the shared-environment limit. |
| `Principles applied:` line. | spec 8.7. bro has no principle targets. | O | Output template. | GREEN-1 |
| Run inline. Read no file. Run no command. | pstack ("Restate your last message": nothing new to learn). | O | Roles. | GREEN-1 |

## Cut

- pstack frontmatter description: it is not "Use when" triggers.
- The four repo lines: bro restates a chat message. It does not work in a repo.

## Pressure scenarios

Scenario: the previous message is a dense 142-word paragraph about Alembic multiple heads, `down_revision`, two revision ids and an `alembic merge` command. The user replies "bro". The file is `scratch-6.8/scenario.txt`.

**RED** (no skill, both CLIs, `scratch-6.8/red/`, 2026-10-30):
Claude wrote 152 words, more than the message. It kept `down_revision`, both ids and the command in a code block. It used a numbered list and bold. It added a recommendation ("Pick option 1 unless..."). Codex wrote 51 plain words with no jargon. Its transcript shows no bro skill read. Only Claude failed RED.

**GREEN-1** (skill, both CLIs, `scratch-6.8/green-1/`, 2026-10-30):
Both passed the harness. Claude wrote 138 words and Codex 74. Neither answer has jargon, an id, a command, a list, bold text or a code block. Both keep the two fixes and the shared-environment limit. Neither adds advice. Both end with `Principles applied: none`.
