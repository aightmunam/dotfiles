---
name: sharpen
description: Use when the user asks to sharpen a task or a prompt, or to make it deeper, not bigger. Use when the user wants a prompt rewritten before another agent or session starts the work.
---

# Sharpen

## Definitions

- **Deeper:** the same goal and the same scope, aimed better. It starts from better material, uses better methods, and has a check that is not the agent.
- **Bigger:** more scope. Examples are a new feature, a new file to change, a fixed answer, or a long list of rules for the worker.
- **Outside check:** a thing other than you or the user that shows the result is right. Examples are a measurement on the real system, a test against real data, a vendor doc, or a person who owns the result.
- **User choice:** a choice that only the user can make. Examples are a limit, a trade-off, a scope edge, or a value such as a timeout.

## The Loop

1. **Read.** Read the prompt and each file or system that it names. Write the facts that change the task, each with its path.
2. **Pro move.** Write what a top professional in this field does here that the prompt does not ask for. Write one or two moves.
3. **Material.** Name the rawest material that the professional starts from. Prefer the real system, logs, data or source over a summary of them.
4. **Methods.** Name the methods and tools that the professional uses on that material.
5. **Check.** Name the outside check that shows the result is right.
6. **Choices.** List each user choice that the task touches. Do not answer a user choice. Write it as an open question in the prompt.
7. **Rewrite.** Rewrite the prompt to ask for steps 2 to 5. Keep the goal and the scope of the original prompt. Leave the design to the worker.
8. **Stop.** Fill the output template. Do not do the task.

## Rules That Shape the Prompt

- **Deeper, not bigger.** Each new line in the prompt comes from steps 2 to 6. Do not add a feature, a file, or a test list that no step named.
- **Ask for the material and the check.** The worker gets the material, the methods and the outside check. The worker picks the design.
- **A pro move that adds scope is a user choice.** Put it in step 6, not in the prompt.

## Red Flags

- The rewritten prompt fixes a value, a key, a library, or a test list that no step named. Go back to step 7.
- The rewritten prompt answers a user choice. Go back to step 6.
- The outside check is your own test run or your own count. Go back to step 5.
- You changed a file or started the task. Stop. Go back to step 8.
- Text after the `Principles applied:` line. Go back to step 8.

## Output Template

```
<1 to 3 facts from step 1, with paths>

Pro move: <step 2>
Material: <step 3>
Methods: <step 4>
Outside check: <step 5>
Open choices: <each user choice, or "none">

<the rewritten prompt, in a fence>

Principles applied: none
```

## Roles

Run inline. Do not dispatch an agent.

## Repo Rules

- never touch a prod Salesforce org, not even --help. `~/.agents/local/work.md` names the prod orgs.
- No alembic upgrade or downgrade, and no DB mutation, on a production database without in-the-moment user confirmation.
- Do not read .env files.
- Worktrees only under ~/wt/<repo>/<name>.
