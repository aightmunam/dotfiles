---
name: build
description: Use when the user asks to build, implement or ship a feature through The Eye, or asks what a build run needs, wants to answer a run's question, approve a plan, resume or stop a run. A thin wrapper over the eye-build CLI; it starts and steers runs and never does the build work in chat.
---

# Build

Thin chat wrapper around the `eye-build` CLI of The Eye dashboard. One request becomes one `eye-build` call. The run itself happens inside The Eye, not in this chat.

## When to use

- The user wants a feature built, for example "build X in repo Y" or "start a build for ...".
- The user asks what a run needs from them ("what does it need from me", "anything waiting on me").
- The user answers a run's question, approves its plan, or asks to resume or stop a run.

## Steps

1. Start a run. Translate the request into one call:
   `eye-build start [--repo NAME] [--mode brief|interview|decide] [--budget MIN] [--title T] "description"`
   - `--mode`: `brief` (default) when the user gives a goal and wants few questions; `interview` when they want to be asked many questions first; `decide` when they want to be asked only at the big decisions.
   - `--repo` takes a repo NAME under the dev root (for example `work-dashboard`), not a path. Without it, `eye-build` uses the basename of the current directory's git repo.
   - Pass `--budget` (minutes) and `--title` only when the user gives them.
   - `start` keeps streaming events until the run ends. Run it in the background with stdout and stderr redirected to a file, for example `eye-build start ... > /tmp/build-run.log 2>&1 &`, wait a few seconds, then read the file.
   - If the process has already exited, the start failed. Report its exit code: 1 is an HTTP error (show the message from the file), 2 means The Eye is down (see step 4).
   - Otherwise the first line of the file is `run <run_id>  <url>`. Take the run id from it.
2. Print the run id and the page URL: `http://localhost:${PORT:-7777}/build/<run_id>`. Tell the user they can follow the run there.
3. Map later requests to plain commands:
   - "what does it need from me" runs `eye-build needs`. Show each item with its options and recommendation.
   - "answer q3 with ..." runs `eye-build answer RUN q3 "text"`, using the user's words exactly. If the run id is unclear, run `eye-build needs` first and ask.
   - "approve the plan" runs `eye-build approve RUN`.
   - "resume" or "stop" runs `eye-build resume RUN` or `eye-build stop RUN`.
   - "show me the run" or "what is it doing" runs `eye-build tail RUN`.
4. Read the exit code. 0 is ok. 1 is an HTTP error: print the message and stop. 2 means The Eye is down: say so, and tell the user to start the dashboard (the work-dashboard app, on the port in `PORT`, default 7777), then offer to retry. If a run id was already printed, do not run `start` again; reconnect with `eye-build tail RUN`.

## Hard rules

- Use only `eye-build`. Never `curl` or otherwise call The Eye directly.
- Never run the build steps in this chat: no planning, coding, testing or reviewing here. Start the run and report.
- Never answer a question on the user's behalf. Pass on only the text they gave. Never invent an approval.
- Start exactly one run per request. Never run `start` a second time for the same request.
- Do not guess a run id. Ask, or run `eye-build needs`.
- Never change the port. The Eye listens where `PORT` says, default 7777.
