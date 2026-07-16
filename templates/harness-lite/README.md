# Claude Code Harness — Lite

A **minimal** Claude Code starter for quick / small projects: a good
`CLAUDE.md` with working conventions, plus three self-contained slash
commands. No PRD, no task graph, no sub-agents, no hooks — none of the
ceremony (or token cost) of the full harness.

This repo is a **GitHub template**: click **“Use this template” → Create a new
repository** and start coding.

> Building something bigger with a real roadmap? Use the **`harness-full`**
> template instead — it adds the PRD → `/claude:create-tasks` → `/claude:dev` flow with
> branch-per-task isolation and automatic audits.

## What's inside

```
CLAUDE.md                 # project conventions + the 3 commands (fill in the notes)
.gitignore                # sensible defaults
.claude/
├── commands/
│   └── claude/               # all user commands live here → /claude:<name>
│       ├── learning.md       # /claude:learning — record a lesson in ai-docs/lessons.md
│       ├── manual-verify.md  # /claude:manual-verify — run a verification you describe
│       └── pesquisa.md       # /claude:pesquisa — research a topic, record it in pesquisa/
└── scripts/
    └── arvore-de-commits.ps1 / .sh  # generates .claude/arvore-de-commits.md
ai-docs/
└── lessons.md            # running log of lessons (grown by /claude:learning)
```

> A `pesquisa/` folder appears once `/claude:pesquisa` runs for the first
> time (or if it was pre-created for you) — it's not part of the initial
> scaffold. `.claude/arvore-de-commits.md` similarly only appears once
> `arvore-de-commits.sh`/`.ps1` runs (manually, or automatically if the
> optional `Stop` checkpoint hook from `/claude:novo-projeto` is enabled).

## After “Use this template”

1. Fill the **“Project-specific notes”** in `CLAUDE.md` (stack, package
   manager, run/build/test commands, conventions).
2. Start working. Use `/claude:learning` after any avoidable mistake,
   `/claude:manual-verify` when you want an explicit check run, and
   `/claude:pesquisa` when you want to research a topic and record it in
   `pesquisa/`.

## Stack skills & MCPs

This lite kit ships no skills. If you keep your common stack skills **global**
at `~/.claude/skills/` and your MCP servers configured at the user level, they
apply here automatically — no per-project setup needed. That includes the
optional `pesquisa-workflow` skill: without it installed globally,
`/claude:pesquisa` still works for explicit research, it just won't trigger
automatically on its own.

## Commands

| Command | What it does |
|---|---|
| `/claude:learning [description]` | Appends a dated lesson (context, root cause, how to avoid, tags) to `ai-docs/lessons.md`. |
| `/claude:manual-verify [request]` | Runs a free-form verification you describe (browser via Playwright MCP if available, CLI checks, etc.) and reports what needs human action. |
| `/claude:pesquisa [topic]` | Researches a topic and records a structured note in `pesquisa/<slug>.md`, updating the index in `pesquisa/README.md`. First run bootstraps the folder. |
