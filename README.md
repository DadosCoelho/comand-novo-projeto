# Claude Code Harness — Lite

A **minimal** Claude Code starter for quick / small projects: a good
`CLAUDE.md` with working conventions, plus two self-contained slash commands.
No PRD, no task graph, no sub-agents, no hooks — none of the ceremony (or token
cost) of the full harness.

This repo is a **GitHub template**: click **“Use this template” → Create a new
repository** and start coding.

> Building something bigger with a real roadmap? Use the **`harness-full`**
> template instead — it adds the PRD → `/claude:create-tasks` → `/claude:dev` flow with
> branch-per-task isolation and automatic audits.

## What's inside

```
CLAUDE.md                 # project conventions + the 2 commands (fill in the notes)
.gitignore                # sensible defaults
.claude/
├── README.md              # what's below, plus how to install it globally on another machine
├── commands/
│   └── claude/               # all user commands live here → /claude:<name>
│       ├── learning.md       # /claude:learning — record a lesson in ai-docs/lessons.md
│       ├── manual-verify.md  # /claude:manual-verify — run a verification you describe
│       ├── pesquisa.md       # /claude:pesquisa — research a topic, record it in pesquisa/
│       └── novo-projeto.md   # /claude:novo-projeto — scaffold a new project from a template
└── skills/
    ├── git-workflow/          # practical Git knowledge + automatic local-versioning rules
    └── pesquisa-workflow/      # automatic research-recording rules (opt-in via pesquisa/)
ai-docs/
└── lessons.md            # running log of lessons (grown by /claude:learning)
pesquisa/
└── *.md                   # organized research notes on Git (concepts, commands, workflows...)
templates/                  # bundled harness templates that /claude:novo-projeto copies
├── harness-lite/
└── harness-full/
```

> `commands/claude/novo-projeto.md`, `commands/claude/pesquisa.md`,
> `skills/git-workflow/`, `skills/pesquisa-workflow/` and `templates/` are
> extras on top of the base `harness-lite` template — see
> [`.claude/README.md`](.claude/README.md) for what they do and how to
> install them globally on another machine.

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
apply here automatically — no per-project setup needed.

## Commands

| Command | What it does |
|---|---|
| `/claude:learning [description]` | Appends a dated lesson (context, root cause, how to avoid, tags) to `ai-docs/lessons.md`. |
| `/claude:manual-verify [request]` | Runs a free-form verification you describe (browser via Playwright MCP if available, CLI checks, etc.) and reports what needs human action. |
| `/claude:pesquisa [topic]` | Researches a topic and records a structured note in `pesquisa/<slug>.md`, updating the index in `pesquisa/README.md`. First run bootstraps the folder and, with the global `pesquisa-workflow` skill installed, turns on automatic research-recording for future non-trivial investigations. |
