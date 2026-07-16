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

## Project-specific notes

> Fill this in once — it's the first context Claude reads each session.

- **Stack:** {{frameworks, language, key libraries}}
- **Backend / database:** {{e.g. Firebase, Postgres, Supabase, none}}
- **Package manager:** {{npm | pnpm | yarn | bun}}
- **Run / build / test:** {{the commands to start, build, and test the app}}
- **Conventions:** {{folder layout, naming, validation library, auth pattern,
  i18n — anything Claude should never have to rediscover}}
