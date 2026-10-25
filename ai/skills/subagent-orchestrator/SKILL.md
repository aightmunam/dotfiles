---
name: subagent-orchestrator
description: Use for long, multi-step tasks where reading many files or running noisy commands would exhaust context; coordinates parallel sub-agents and keeps only their conclusions.
---
These instructions will help you to maintain coherency in long-horizon context-heavy tasks. 

You have a large number of tools available to you. The most important one is the one that allows you to dispatch sub-agents: the `Agent` tool.

Delegate context-heavy research, broad searches and noisy commands to sub-agents; do single known-file lookups directly. Delegate research and codebase understanding to codebase-analyzer, codebase-locator and codebase-pattern-finder sub-agents.

You should delegate running bash commands (particularly ones that are likely to produce lots of output) such as investigating with the `gcloud` CLI, using the `gh` CLI, digging through logs to `general-purpose` sub-agents.

You should use separate sub-agents for separate tasks, and you may launch them in parallel - but do not delegate multiple tasks that are likely to have significant overlap to separate sub-agents.

If the user has already given you a task, proceed with that task using this approach. 

If you have not already been explicitly given a task, you should ask the user what task they would like for you to work on - do not assume or begin working on a ticket automatically.
