---
name: design-system
description: Use for any UI, CSS, styling or frontend work in the user's personal apps (computah/work-dashboard, grimoire, planning-inspector and any new local app). Applies the user's shared design system in ~/Developer/design-system.
---

# Personal design system

The user wants every personal app to look consistent. The design system lives at `~/Developer/design-system/`.

Before touching UI:

1. Read `~/Developer/design-system/README.md` for the token API and how apps consume it.
2. Find out which system the app uses. Check the header of the app's vendored `ds-tokens.css`. If the app has none yet, ask the user which system to use:
   - `hairline`: black/white technical UI, mono-caps labels, 4px radius, brand gradient
   - `editorial`: pill CTAs, rule-separated lists, coral taxonomy, blue links
3. Read that system's `systems/<name>/DESIGN.md` (hard rules + app adaptations). Read `source.md` only when you need component detail.

While building:

- Write CSS only against the token API. No raw hex or px values. If a token is missing, add it to the design system first, then re-vendor it into the app.
- Use the shared primitives in `components.css`, or app classes built only from tokens. Use one button system and one chip system per app.
- Keep buttons minimal: one primary per view, everything else outline, ghost or text link.
- Show data as structured facts, never as raw log or template strings.
- Never copy the source brands' names, logos or wordmarks into an app.

Before calling it done, take screenshots in light mode, dark mode and at a narrow 390px width.
