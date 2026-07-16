# Claude Code Task-Driven Harness — Template

A reusable Claude Code harness for building software with a **PRD → tasks →
implementation** workflow. Drop a filled-in PRD into `ai-docs/PRD.md`, run
`/claude:create-tasks` to generate a sequenced task list, then run `/claude:dev` to
implement tasks one branch at a time — each with an automatic design-system
audit and quality-checklist verification.

This repo is a **GitHub template**: click **“Use this template” → Create a new
repository**, then fill in a few placeholders and start building. (`harness-full`
is the complete flow — for small/quick projects, use the lighter
**`harness-lite`** template instead.)

### After “Use this template”

1. Fill every `{{placeholder}}` in `ai-docs/PRD.md` and the “Project-specific
   notes” in `CLAUDE.md`.
2. Add the skills your stack needs under `.claude/skills/` (or keep them global
   at `~/.claude/skills/`), and add matching rows to `ai-docs/tools.yaml`.
3. (Optional) `/claude:design create` to generate `DESIGN.md`; add a package-manager
   hook in `.claude/settings.json` if you want one.
4. Run `/claude:create-tasks`, then `/claude:dev`.

---

## How it works

This harness turns a single document — your PRD — into a stream of small,
precisely-scoped tasks, each implemented and audited on its own branch.

**1. The PRD becomes a task graph.** `/claude:create-tasks` runs the
`task-master-generator` agent: it reads `ai-docs/PRD.md`, fans out parallel
sub-agents to inspect your existing code (auth, database, routes, components,
APIs), and writes `ai-docs/todos/task-master.md` — a numbered task list. Every
task carries a **priority**, a **complexity score**, a **phase**, and explicit
**`dependencies`**, so a task only unlocks once everything it needs is `done`.
Features that already exist in the codebase generate no task.

**2. Each task gets its own researched brief — with its own tools.** `/claude:dev`
runs the `task-sequencer` agent for the next pending task. It researches the
codebase for relevant examples, then consults `ai-docs/tools.yaml` — the
catalog of every Skill, MCP server, command, agent, script, and CLI the
project ships. It **scores every tool against that specific task** (keyword
overlap plus hard rules — e.g. a UI task always pulls in the design-system
agents) and injects the top matches into an `## Available Tools` block right
inside the task file. The implementer never has to rediscover which tool to
reach for — the task already tells it.

**3. Implementation is isolated and audited.** Each task runs on its own
`task/<NN>-<slug>` branch. When it touches frontend files, the
`design-system-checker` audits it against `DESIGN.md` and the
`quality-checklist-verifier` runs concrete code checks — a failed audit blocks
the task from being marked `done`. Then `/claude:dev` offers to open a PR.

> **A note on token cost.** This precision is not free. Spawning research
> sub-agents, writing a detailed brief for *every* task, and running audit
> agents on each one means the harness **uses noticeably more tokens** than
> asking Claude to "just build the whole app". That is the deliberate
> trade-off: you spend tokens to get small, well-scoped, individually-verified
> tasks instead of one large, hard-to-review change. When a task is trivial,
> `/claude:dev --quick` skips the specialist research and the design audit to save
> the cost.

---

## What's inside

```
README.md                   # this file
CLAUDE.md                    # project instructions the agents always read
.gitignore                   # sensible defaults for a fresh repo

ai-docs/
├── PRD.md                   # ← YOU fill this in (skeleton with {{placeholders}})
├── lessons.md               # running log of lessons (grown by /claude:learning)
├── tools.yaml               # catalog of tools the agents may use
├── todos/                   # task-master.md lands here after /claude:create-tasks
│   └── .gitkeep
└── actual-todo/             # the task currently in flight lives here
    └── .gitkeep

.claude/
├── agents/                  # 6 subagents that power the workflow
├── commands/                # 6 slash commands (/claude:create-tasks, /claude:dev, …)
├── skills/                  # skill-creator (the one bundled skill — add your own)
└── settings.json            # agent-teams env var (add hooks here if you want any)
```

> A `pesquisa/` folder appears once `/claude:pesquisa` runs for the first
> time — it's not part of the initial scaffold. With the optional
> `pesquisa-workflow` skill installed globally (`~/.claude/skills/`), once
> that folder exists, non-trivial research gets recorded there automatically
> too — no need to call the command every time.

---

## Quick start

1. **Clone the repo.**

   ```bash
   git clone <repo-url> my-project && cd my-project
   ```

2. **Curate the skills & MCP servers.** Decide what your project actually
   needs: **delete** the `.claude/skills/` folders you won't use, **add** any
   Skills your stack requires, and register your MCP servers in `.mcp.json`.
   Then ask Claude to refresh the tools catalog — *"Update `ai-docs/tools.yaml`
   to match the skills in `.claude/skills/` and the MCP servers in
   `.mcp.json`."* That catalog is the single source of truth `task-sequencer`
   reads when picking a tool for each task.

3. **Write the PRD.** Use the template in `ai-docs/PRD.md` as the structure
   and fill in **every** `{{placeholder}}` — `/claude:create-tasks` refuses to run
   while any placeholder remains.

4. **Drop the PRD in.** Replace the contents of `ai-docs/PRD.md` with your
   finished PRD.

5. **Run the workflow.**

   ```
   /claude:create-tasks   # PRD → ai-docs/todos/task-master.md
   /claude:dev            # implement the next pending task
   ```

   Then keep running `/claude:dev`:

   ```
   /claude:dev --task 5                 # a specific task
   /claude:dev "fix the login button"   # an off-roadmap ad-hoc task
   ```

   Each `/claude:dev` run claims a `task/<NN>-<slug>` branch, prepares a detailed
   task file, implements it, runs the design + quality audits, and offers to
   open a PR.

> **Optional:** run `/claude:design create` to generate `DESIGN.md` before
> implementing — without it the design audit only warns, never blocks. For
> one-time stack configuration, see [Make it yours](#make-it-yours) below.

---

## Commands

| Command | What it does |
|---|---|
| `/claude:create-tasks` | Reads `ai-docs/PRD.md` and generates `ai-docs/todos/task-master.md`. |
| `/claude:dev [description \| --task <selector>] [--test] [--worktree] [--no-branch] [--list] [--dry-run] [--quick] [--ship]` | Selects, prepares, implements, and audits a task on its own branch. |
| `/claude:design [create\|lint\|check\|export\|spec]` | Manages `DESIGN.md` (Google Labs alpha spec). |
| `/claude:learning [description]` | Records a lesson in `ai-docs/lessons.md`. |
| `/claude:manual-verify [request]` | Runs a free-form verification you describe and reports what needs human action. |
| `/claude:pesquisa [topic]` | Researches a topic and records a structured note in `pesquisa/<slug>.md`, bootstrapping the folder on first run. |

See `CLAUDE.md` for the full `/claude:dev` flag reference and the multi-tab /
worktree workflow.

## Agents

All in `.claude/agents/` — invoked automatically by the commands, never by
hand:

- **task-master-generator** — turns the PRD into `task-master.md`.
- **task-sequencer** — claims a branch and prepares the next PRD task file.
- **ad-hoc-task-creator** — same, for free-form off-roadmap tasks.
- **design-system-curator** — authors/updates `DESIGN.md`.
- **design-system-checker** — audits frontend changes against `DESIGN.md` (auto in `/claude:dev`).
- **quality-checklist-verifier** — verifies each task's quality checklist against the diff (auto in `/claude:dev`).

---

## Make it yours

The harness itself (agents, commands, the workflow) is stack-agnostic. A few
spots carry the source project's assumptions — review these once when you
adopt the template:

| File | What to do |
|---|---|
| `ai-docs/PRD.md` | Fill in every `{{placeholder}}` (or replace the file with your own PRD). |
| `CLAUDE.md` → "Project-specific notes" | Describe your stack, backend, package manager, and conventions. |
| `.claude/agents/quality-checklist-verifier.md` → `## Project configuration` | Fill the YAML block so the quality checks match your stack. If left blank, the agent auto-detects conservatively. |
| `ai-docs/tools.yaml` | Add rows for your project's scripts / skills / MCP servers / CLIs. Fastest way: ask Claude to regenerate it from `.claude/skills/` and `.mcp.json` (see Quick start step 2). |
| `.claude/skills/` | Only `skill-creator` ships. Add the skills your stack needs (or keep stack skills **global** at `~/.claude/skills/` so they apply to every project) and add matching rows to `tools.yaml`. |
| `.claude/settings.json` | No hooks ship — the template is package-manager-agnostic. Add a `PreToolUse(Bash)` hook here if you want to pin one PM, and catalog it under `hooks:` in `tools.yaml`. |

---

## Requirements

- **git** — required; the whole `/claude:dev` workflow is branch-based.
- **Node.js** — only for `/claude:design *`, which downloads `@google/design.md` on demand.
- **Playwright MCP** — only for `/claude:dev --test`. Register it in `.mcp.json` or `.claude/settings.json` first.
- **Agent Teams** — `.claude/settings.json` sets `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` so the planning agents can spawn parallel research sub-agents.

## How the branch claim works

`/claude:dev` always isolates a task on its own `task/<NN>-<slug>` branch. The branch
**is** the claim: any session that sees an existing `task/<NN>-*` branch
(local or remote) skips that task. That is what makes multiple tabs / worktrees
safe to run in parallel. Full details — including `--worktree` — are in
`CLAUDE.md` under "Multi-tab workflow".

## Notes

- The agents match the **language of your PRD**. Write the PRD in Portuguese
  and the whole project is generated in Portuguese; English is the default.
- `actual-todo/` should be empty (just `.gitkeep`) between tasks — each `/claude:dev`
  archives its own task file into `todos/` on the final commit.
- **Package-manager-agnostic.** No PM hook ships. If you want to pin the
  project to npm / pnpm / yarn / bun, add a `PreToolUse(Bash)` hook in
  `.claude/settings.json` that blocks the others and catalog it in `tools.yaml`.
- `lessons.md` is a single shared file; grow it with `/claude:learning` after any
  avoidable mistake so the project keeps a living guide of what not to repeat.
