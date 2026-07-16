# Generate Task List from PRD

Generates `ai-docs/todos/task-master.md` with the sequential task list, based on `ai-docs/PRD.md` and an analysis of the existing codebase.

## Prerequisites

- `ai-docs/PRD.md` must exist and be filled in (no remaining `{{placeholders}}`).

## Steps

### Step 1: Validate the PRD

1. Read `ai-docs/PRD.md`.
2. If the file doesn't exist or still contains unfilled `{{placeholders}}`, **stop and tell the user** they need to fill out the PRD first.

### Step 2: Generate the tasks

Use the Task tool to invoke the `task-master-generator` agent. The agent will:

- Read the PRD.
- Spawn parallel sub-agents (Agent Teams) to inspect auth, database, routes, components, and APIs in the existing codebase.
- Avoid creating tasks for features that are already implemented.
- Generate `ai-docs/todos/task-master.md` with sequential tasks and explicit dependencies.

### Step 3: Report

After the agent finishes, show the user:

- Path of the generated file.
- Total number of tasks created.
- Which tasks are **ready to start** (no dependencies).
- Which already-implemented features were detected (and therefore did **not** generate tasks).

Suggest the next step: run `/claude:dev` to start executing the first task.
