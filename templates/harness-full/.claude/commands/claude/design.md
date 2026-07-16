# Design System

Manages `DESIGN.md` (Google Labs alpha spec) — the source of truth for the project's visual tokens.

## Arguments

- `$ARGUMENTS` — the first token defines the subcommand:
  - `create` — invokes the `design-system-curator` agent to create/update `/DESIGN.md`.
  - `lint` — runs `npx @google/design.md lint DESIGN.md`.
  - `check [files?]` — invokes `design-system-checker` to audit components against `DESIGN.md`.
  - `export [json-tailwind|css-tailwind|dtcg]` — exports a theme.
  - `spec` — shows the active CLI spec (`npx @google/design.md spec --rules`).
  - empty → shows this help.

## Subcommands

### `/claude:design create`

Use the Task tool to invoke the `design-system-curator` agent. It will:

1. Check whether `DESIGN.md` already exists (offers update or replace).
2. Read `ai-docs/PRD.md` for brand hints.
3. Ask the user: name, primary color (hex), typography, corner style, density, dark mode, MVP components.
4. Write `/DESIGN.md` at the root with token frontmatter + 8 mandatory sections.
5. Run `npx @google/design.md lint` to validate.
6. Optionally export a Tailwind theme to `ai-docs/design/`.

**Prerequisite:** `npx` available (Node.js installed). The CLI is downloaded on demand.

### `/claude:design lint`

Run directly:

```bash
npx @google/design.md lint DESIGN.md
```

Report to the user:
- Exit code (0 = pass, 1 = fail).
- List of errors/warnings with categories: `broken-ref`, `missing-primary`, `contrast-ratio`, `orphaned-tokens`, `missing-typography`, `missing-sections`.

If it fails, suggest `/claude:design create` to rewrite or ask for a manual fix.

### `/claude:design check [files?]`

Use the Task tool to invoke the `design-system-checker` agent:

- If `files` are provided (paths separated by spaces), pass them to the agent.
- If empty, the agent discovers them via `git status --short` for modified frontend files.

The agent reports token violations (hardcoded colors, off-scale values, missing `on-*` pairs, components diverging from the spec).

### `/claude:design export [format]`

Formats supported by the official CLI:
- `json-tailwind` — Tailwind v3 theme JSON
- `css-tailwind` — Tailwind v4 `@theme` block
- `dtcg` — W3C Design Tokens Format Module

Create `ai-docs/design/` if it doesn't exist. Default outputs:

| Format | Destination file |
|---|---|
| `json-tailwind` | `ai-docs/design/tailwind.theme.json` |
| `css-tailwind` | `ai-docs/design/theme.css` |
| `dtcg` | `ai-docs/design/tokens.json` |

```bash
npx @google/design.md export --format <format> DESIGN.md > <destination file>
```

### `/claude:design spec`

Shows the CLI's active spec (lint rules, supported formats):

```bash
npx @google/design.md spec --rules
```

Useful for detecting schema drift (the spec is alpha — it may change).

## Notes

- `DESIGN.md` lives **at the project root**, always `/DESIGN.md`.
- The `@google/design.md` CLI **does not have `init`** — creation is handled by the local `design-system-curator` agent.
- The linter runs 7 rules: 1 error (`broken-ref`), 5 warnings, 1 info.
- Alpha status — re-run `/claude:design spec` periodically to detect changes.
