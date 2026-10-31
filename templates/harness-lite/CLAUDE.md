# Project Instructions

A **lightweight** Claude Code kit for quick / small projects — no PRD, no task
graph, no agent fleet. Just solid working conventions plus two self-contained
commands. (For a structured PRD → tasks → branch-per-task flow on a bigger
project, use the **`harness-full`** template instead.)

## Available commands

| Command | What it does |
|---|---|
| `/claude:learning [description]` | Records a lesson in `ai-docs/lessons.md` (date, context, root cause, how to avoid, tags). Use after any avoidable mistake. |
| `/claude:manual-verify [request]` | Runs a free-form verification you describe — browser checks, CLI checks, etc. — and reports anything that needs human action. |
| `/claude:pesquisa [topic]` | Researches a topic and records a structured note in `pesquisa/<slug>.md` (creates the folder + index on first run). |
| `/claude:atualizar-notas [hint]` | Detects stack/backend/package manager/commands/conventions from the repo and syncs the "Project-specific notes" section below. On-demand trigger for the rule right below this table. |
| `/claude:plano [o que construir]` | Plans long work in **measured blocks** in `ai-docs/plano/`: cuts the work into blocks that end green, groups them into session windows by shared context, and tracks the session budget (creates the folder on first run). |

> **Convenção de comandos:** todos os comandos do usuário usam o namespace
> `claude:` — ficam em `.claude/commands/claude/<nome>.md` e são chamados como
> `/claude:<nome>`. Ao criar um comando novo, coloque-o nessa subpasta. Assim,
> digitar `/claude` no chat já lista todos os comandos personalizados.

## How to work on this project

These are the defaults every change should follow:

- **Small, focused changes.** Do the thing asked; don't refactor unrelated code
  along the way unless asked.
- **Read before you write.** Match the surrounding code's style, naming, and
  patterns. Reuse existing helpers/types instead of inventing parallel ones.
- **Use official library types** — look in `node_modules/<lib>/**/*.d.ts` or the
  library's exports before declaring your own `interface`/`type`.
- **Validate external input** at the boundary (request bodies, query params,
  form data, webhook payloads). Never trust client data.
- **Handle errors on async/IO sites** — don't leave promises unhandled or
  swallow exceptions silently.
- **Never commit secrets.** Keys, tokens, service-account JSON → environment
  variables; keep `.env*` gitignored.
- **Confirm before destructive or outward-facing actions** (deleting data,
  pushing, opening PRs, sending email) unless told to proceed.
- **Record lessons.** After any avoidable mistake, run `/claude:learning` so
  `ai-docs/lessons.md` grows into a living guide for this project.
- **Keep "Project-specific notes" current.** Those fields start as
  `{{placeholders}}` because nothing exists yet at scaffold time. The moment
  each one becomes evident — first `package.json`/`requirements.txt`/
  `pyproject.toml` committed, first framework/package manager chosen, first
  working run/build/test command, a convention that would otherwise need
  rediscovering — replace that placeholder yourself, without waiting to be
  asked. Update it again if it changes later (e.g. package manager switched,
  a new convention settles). Treat the section as a living doc you maintain
  as you go, not a form the user fills in upfront. Run
  `/claude:atualizar-notas` to do this on demand instead of inline.
- **Keep this file to rules.** Each item here changes what Claude does. How
  something was built, discarded options, measurements → `ai-docs/<topic>.md`.
  Rules for one area of the code → `.claude/rules/<topic>.md` with `paths:`.
  Leave a one-line pointer under "Where details live" (plain path, never
  `@path` — that imports the whole file into every session).
- **Irreversible commands get an `ask` rule.** When the project gains a
  command that deploys, migrates, or writes to production, add it to
  `permissions.ask` in `.claude/settings.json` — both `Bash(<cmd> *)` and
  `PowerShell(<cmd> *)` — and list it under "Irreversible commands". Text in
  this file is context, not a lock.
- **Keep `.rtk/config.toml` current** — only if this project has one; its
  presence means the RTK hook is enabled here, compressing command output
  before it reaches the context. That is pure gain for `git log` or `tsc`, and
  a loss when the output **is** the product. So the moment a command's output
  becomes something read for its data — a measurement script, a query, a
  benchmark, anything whose numbers drive a decision — add it to
  `exclude_commands` yourself, without waiting to be asked. Exclusion matches
  by prefix, subcommand included: `"pnpm bench"` leaves `pnpm list`
  compressed. Same living-doc rule as the notes above, and for the same
  reason: what to exclude is not knowable at scaffold time, it emerges. If
  this project also uses `ai-docs/plano/`, note the date of any change there —
  RTK moves the budget ruler's denominator, and `medicoes.py` cannot see it.

## Project-specific notes

> Starts empty on purpose — filled in automatically as the project takes
> shape (see "Keep Project-specific notes current" above, or run
> `/claude:atualizar-notas`). A remaining `{{placeholder}}` just means that
> aspect hasn't been decided yet, not that someone forgot to fill it in.

- **Stack:** {{frameworks, language, key libraries}}
- **Backend / database:** {{e.g. Firebase, Postgres, Supabase, none}}
- **Package manager:** {{npm | pnpm | yarn | bun}}
- **Run / build / test:** {{the commands to start, build, and test the app}}
- **Conventions:** {{folder layout, naming, validation library, auth pattern,
  i18n — anything Claude should never have to rediscover}}
- **Irreversible commands:** {{deploy, migrations, scripts that write to
  production — each one has an `ask` rule in `.claude/settings.json`}}
- **Where details live:** {{one line per `.claude/rules/<topic>.md` and
  `ai-docs/<topic>.md` — topic and path}}
