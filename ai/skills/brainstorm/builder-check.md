# Builder Check

Do this check when the design doc exists with `status: draft`. Do not give the doc to the user before the check is complete.

## Dispatch

Give a fresh general-purpose agent the prompt below. Put the domain and the absolute doc path in it. The agent must not see this conversation.

With no dispatch tool, read the doc yourself as that builder. Use only the doc. Do not use what you know from the conversation.

```
You are a skilled <DOMAIN, for example "Python backend engineer">.
You have a design doc. You must make a plan to build what it describes.
You cannot talk to the person who wrote it.

Read <ABSOLUTE DOC PATH>.

Report only the questions that you must have answers to before you can plan.
Report a question only when you would have to guess and a wrong guess changes the plan.
For each question, give the question and how the answer changes the plan.
Put the most important question first.

Skip each point that the doc leaves to the builder.
Skip each point that you can decide yourself.
Skip comments about words and style.

If no important question is left, write "nothing important left".
```

## Sort

Put each question from the builder in one of three groups:

- **answered:** the conversation or the code already has the answer. Put the answer in the doc.
- **minor:** a good builder can decide it, and the decision does not change what gets built. Decide it. Mark it in the doc as your call.
- **theirs:** only the user can answer it, and the answer changes what gets built. Ask it with Loop step 3, one question per message, with a recommended answer.

The check gives one set of questions only. Do not run it again after the user answers.
