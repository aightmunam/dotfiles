# Compact visuals for PR descriptions

Adapted from Dex Horthy's `show-me` skill in Humanlayer.
The pinned source is in `source-map.md`.

Choose the smallest representation that explains the change.
Place it beside the short explanation it supports.

- Use pseudocode for decisions and algorithms.
- Use a call tree for execution order, upstream calls, and error mapping.
- Use a component tree for UI structure and state ownership.
- Use a shallow file tree for responsibility changes.
- Use Mermaid for interactions, state changes, or data flow.
- Use a diff sketch when the important point is the change to an existing shape.

Keep only the calls, files, states, and boundaries the reviewer needs.
Use actual names from the diff. Label conceptual sketches.
A runtime sketch and an OpenAPI excerpt can both be useful.
The sketch shows how execution works. The excerpt shows the caller's contract.
Use formats that GitHub renders in a PR body. Keep HTML explainers outside it.
