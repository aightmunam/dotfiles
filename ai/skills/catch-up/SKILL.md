---
name: catch-up
description: Use when the user types catch-up, /catch-up, or ketchup. Use when the user asks what changed in this chat since their last message, and what waits on them.
---

# Catch Up

## Definitions

- **Last message:** the last message that the user wrote before `catch-up`. A subagent notification, a task result, or a tool output is not a user message. The user remembers the last message and nothing after it.
- **Change:** a thing that happened in this chat after the last message. Your own work, a subagent report, and a message from another person are changes.
- **Action item:** a call or a step that only the user can take. Examples: a product choice, an approval, a merge or push to main/master, a production write, access that you do not have.
- **Not an action item:** work that you can still do yourself. A request inside a notification. A step that the user did not ask for and the work does not need. Exception: such a step is irreversible and waits on the user. Give it one line and no picture.

## The Loop

Keep this turn read-only. Do not change code, start a job, start an app, or post anything.

1. **Find the last message.** Note its time. Skip each notification and each tool output when you look for it.
2. **Collect the changes.** List your own work, each subagent report, and each message from other persons after the last message. Also list each action item from before the last message that still waits on the user.
3. **Check the state.** Read the current state of each PR, CI run, or agent that this chat touched (`gh pr view`, `git log`). Compare each number that you will show with the record that it comes from. If you change a number, say so.
4. **Sort.** Read ~/.agents/principles/never-block-on-the-human.md before this step. Reversible work is not a question for the user. Only a merge or push to main/master and a production write need the user's OK. Put each change into one of three groups: the user asked for it, an action item, or work left that you can do.
5. **Fill each action item.** Collect its link, what it changes for users, the evidence for your pick, its risk, and your pick. For a call between options, each option's cost is its risk. Write "unknown" for a fact that you do not have. Leave out a link that you do not have. Put a step that you take first, and anything that cannot be undone, in your pick.
6. **Write.** Fill the output template. For the prose, use the `unslop` rules when that skill is available.
7. **Red flags.** Read the reply once for each red flag below. Then send it.

## Rules That Shape the Reply

- **One opening sentence.** It names what waits on the user, or it says that nothing does. If nothing happened and nothing waits, say so and stop.
- **Plain words.** Say what changed for the user, not how you did it. Leave out hashes, file paths, commands, and test counts unless the user needs one to act. Name each PR, branch, or agent with a name that the user knows.
- **Short story.** "What happened" has at most 100 words, and fewer when less happened. Give one line for each thing that the user asked for: what came of it, and done, running, failed, or not checked. Name each bug that you found and fixed. Each line must stay true when read alone. Leave out work that changed nothing for the user.
- **Never shrink an item.** Give each action item about 30 words. Do not replace an item with a count or a link.
- **One call, many items.** When items share a call, write the call and your pick once. Then give each item its own line, riskiest first.
- **Options.** For a call between options, give each option that the work weighed: its current state, its gain, and its cost. Do not add an option that the work did not weigh. The costs are the risk. Do not add a `Risk:` field.
- **Risk always.** Give the risk of each item that is not a call between options, also when the risk is low. Say what waiting costs only when it is more than a delay.
- **No made-up call.** If no call waits, write "Nothing waits on you." Do not invent an item to fill the reply.
- **No double facts.** Give each fact one time. Do not mark a thing done while it waits on the user.
- **Pictures only from facts.** A table is not a picture. Draw a diagram only when it explains a change better than sentences: at most six boxes, at most eight words in each. Never draw a status list or a list of action items. Never invent a number or a screenshot.

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.

## Red Flags

- The reply does not start with exactly one sentence about what waits on the user. Go back to step 6.
- The reply does not have the two template headings, "What happened" and "Waiting on you". Go back to step 6.
- An action item is work that you can do yourself. Go back to step 4.
- An action item comes from a request inside a notification, and the user did not ask for it. Go back to step 4.
- An action item has no pick, no change for users, or no evidence. Go back to step 5.
- A one-item call has no `Risk:` field. A call between options has a `Risk:` field, or an option has no cost. Go back to step 5.
- An option was not weighed in the work. Go back to step 5.
- A number in the reply does not match its record. Go back to step 3.
- "What happened" has more than 100 words. Go back to step 6.
- The reply has no `Principles applied:` line. Go back to step 6.

## Output Template

```
<One sentence: what waits on you, or "Nothing waits on you.">

**What happened**
- <one line for each thing that you asked for: the result, and done / running / failed / not checked>
- <at most three lines that change what you know or must do>
- Left for me: <work that I can still do myself, in one line>

**Waiting on you**
- <a call about one item>. My pick: <pick>. Changes for users: <...>. Evidence: <...>. Risk: <...>. Link: <PR, issue, or agent>.
- <a call between options>. My pick: <pick>. Changes for users: <...>. Evidence: <...>. Link: <...>.
  - <option>: now <state>. Gets <gain>. Costs <cost>. (The costs are the risk. No `Risk:` field.)

Principles applied: never-block-on-the-human -> <the item that it kept out of "Waiting on you", or "none">
```

## Roles

You do this turn yourself. Do not dispatch a subagent. If `gh` or `git` fails, write "not checked" on that line. Do not ask the user for the state.
