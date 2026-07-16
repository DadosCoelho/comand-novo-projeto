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
└── commands/
    └── claude/               # all user commands live here → /claude:<name>
        ├── learning.md       # /claude:learning — record a lesson in ai-docs/lessons.md
        └── manual-verify.md  # /claude:manual-verify — run a verification you describe
ai-docs/
└── lessons.md            # running log of lessons (grown by /claude:learning)
```

## After “Use this template”

1. Fill the **“Project-specific notes”** in `CLAUDE.md` (stack, package
   manager, run/build/test commands, conventions).
2. Start working. Use `/claude:learning` after any avoidable mistake and
   `/claude:manual-verify` when you want an explicit check run.

## Stack skills & MCPs

This lite kit ships no skills. If you keep your common stack skills **global**
at `~/.claude/skills/` and your MCP servers configured at the user level, they
apply here automatically — no per-project setup needed.

## Commands

| Command | What it does |
|---|---|
| `/claude:learning [description]` | Appends a dated lesson (context, root cause, how to avoid, tags) to `ai-docs/lessons.md`. |
| `/claude:manual-verify [request]` | Runs a free-form verification you describe (browser via Playwright MCP if available, CLI checks, etc.) and reports what needs human action. |
