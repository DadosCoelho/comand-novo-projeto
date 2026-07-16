# Execute Next Task

Prepares and implements the next pending task. Without arguments, picks the next task from `ai-docs/todos/task-master.md`. With `--task <selector>`, picks one or more specific tasks. With a free-form description, creates an ad-hoc task that doesn't touch `task-master.md`. Each task is implemented on its own `task/<NN>-<slug>` (PRD tasks) or `task/adhoc-<slug>` (ad-hoc tasks) branch — or worktree.

## Arguments

`$ARGUMENTS` — optional. May contain any combination of:

### Selection (mutually exclusive)

- `--task <selector>` — pick a specific task / range / batch from `task-master.md`. Smart parser:
  - `--task 5` → task 5 only.
  - `--task 5-10` → tasks 5, 6, 7, 8, 9, 10 (in that order, sequentially).
  - `--task 5,7,9` → tasks 5, 7, 9 (in that order).
  - `--task next` → same as omitting the flag (next pending task).
- **Free-form description** (anything left after stripping flags) — routes to the `ad-hoc-task-creator` agent. Branch: `task/adhoc-<slug>`, file: `ai-docs/actual-todo/adhoc-<slug>.md`. **Does NOT touch `task-master.md`.**
- *(neither flag nor description)* → next pending task from `task-master.md` (current default behaviour).

### Modifiers

- `--worktree` — create the task branch inside a fresh git worktree at `../<repo>-task-<NN>-<slug>` (or `../<repo>-task-adhoc-<slug>`) and switch the current session into it (uses `EnterWorktree`).
- `--no-branch` — skip branch/worktree creation entirely. Pick the task and prepare its file on the current branch (legacy/hotfix mode). **Cannot be combined with batch selection.**
- `--list` — read-only. Print pending + blocked tasks (id, title, status, deps) and exit. **Ignores all other flags.**
- `--dry-run` — stop after the task file is written. Branch is created, file is written, but implementation is skipped. **Single task only** (errors on `--task 5-10`).
- `--quick` — skip Step 3 specialist research (in the agent) AND Step 5 design-system audit. For trivial fixes.
- `--test` — at the end of the task, run an end-to-end test via **Playwright MCP**. In batch mode, runs once per task.
- `--ship` — at the end of each task (and only if Steps 3, 4, 4.5 all passed), automatically push, open a PR with `gh`, queue auto-merge with squash + delete branch, and return the session to `BASE_BRANCH`. **No prompt.** Without this flag, the run ends asking the user whether to merge.

### Examples

```
/claude:dev                              → next pending task (current default)
/claude:dev --task 5                     → task 5 specifically
/claude:dev --task 5-10                  → tasks 5 through 10 (sequential)
/claude:dev --task 5,7,9                 → tasks 5, 7, 9 (sequential, in order)
/claude:dev "fix login button"           → ad-hoc task (uses ad-hoc-task-creator)
/claude:dev --list                       → list pending/blocked tasks and exit
/claude:dev --task 5 --dry-run           → prepare task 5 file, don't implement
/claude:dev --quick "tweak header"       → ad-hoc, skip research + design audit
/claude:dev --task 5 --worktree --test   → task 5 in a worktree, with Playwright at end
/claude:dev --worktree                   → next pending task in a new worktree
/claude:dev --no-branch                  → next pending task on the current branch (legacy)
/claude:dev --ship                       → next task; auto-push + auto-PR + auto-merge at the end
/claude:dev --task 5,7 --ship            → batch tasks 5 and 7; each auto-merges if checks pass
```

### Parsing precedence

Parse `$ARGUMENTS` once at the top:

1. **Strip the modifier flags first**: `--worktree`, `--no-branch`, `--list`, `--dry-run`, `--quick`, `--test`, `--ship`.
2. **Strip `--task <selector>`** (the value comes immediately after the flag, no `=`).
3. Whatever text remains = free-form description (may be empty).

Then validate:

- `--list` → ignore everything else, run the list-only path (Step 0.3) and exit.
- `--task` set AND description present → **error**: "Pass either `--task` or a description, not both."
- `--task <range or batch>` AND `--dry-run` → **error**: "`--dry-run` only works with a single task."
- `--task <range or batch>` AND `--no-branch` → **error**: "Batch mode requires creating branches."
- `--no-branch` AND `--worktree` → **error**: "`--no-branch` and `--worktree` are mutually exclusive."
- `--ship` AND `--no-branch` → **error**: "`--ship` requires a real task branch (push + PR target)."
- `--ship` AND `--dry-run` → **error**: "`--dry-run` stops before any commit; `--ship` has nothing to ship."

Pass the parsed values to whichever agent is chosen in Step 1.A.

## Step 0: Pre-flight check

### 0.1 — Confirm we're inside a git repo

```bash
git rev-parse --is-inside-work-tree
```

If this fails, abort and tell the user: "This command requires a git repo. Run `git init && git add -A && git commit -m 'initial'` first, then try again."

### 0.2 — Auto-detect the base branch

```bash
git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null | sed 's|^origin/||'
```

If empty, fall back to `main`. Remember as `BASE_BRANCH` for the rest of the run.

### 0.3 — `--list` short-circuit

**If `--list` was passed:**

1. Read `ai-docs/todos/task-master.md`. If it doesn't exist, tell the user to run `/claude:create-tasks` first and stop.
2. Print a Markdown table summarising every task, sorted by id:

   ```
   | ID | Title | Status | Priority | Phase | Deps | Branch claim |
   |----|-------|--------|----------|-------|------|--------------|
   | 01 | …     | done   | high     | 0     | —    | merged       |
   | 02 | …     | pending| high     | 0     | [01] | available    |
   | 03 | …     | blocked| medium   | 1     | [02] | waiting on 02|
   ```

   For the `Branch claim` column, run `git branch --list "task/<NN>-*"` (and `git ls-remote --heads origin "task/<NN>-*"` if a remote exists) to detect whether each task has been claimed.
3. Below the table, print a one-line summary: `<X> done · <Y> pending · <Z> blocked · <W> in-progress`.
4. **Stop here.** Do not invoke any agent. Do not create branches.

## Step 1: Prepare the task file (and claim a branch)

### Step 1.A — Choose the agent and build the task list

Decide based on the parsed arguments:

| Condition | Agent | `task_ids` to iterate over |
|---|---|---|
| `--list` was passed | (already exited in Step 0.3) | — |
| Free-form description present | `ad-hoc-task-creator` | `[null]` (single iteration; the description carries the identity) |
| `--task <selector>` set | `task-sequencer` | `parse_selector(--task)` — list of NN ints |
| Neither | `task-sequencer` | `[null]` (next pending task — current default) |

**Selector parsing for `--task`:**
- `next` → `[null]`.
- `5` → `[5]`.
- `5-10` → `[5, 6, 7, 8, 9, 10]`.
- `5,7,9` → `[5, 7, 9]`.

### Step 1.B — Loop over `task_ids`

For each `id` in `task_ids` (length 1 in the single/ad-hoc case; length N in the batch case):

1. **Sync to `BASE_BRANCH` between iterations.** Skip on the first iteration. From the second iteration onward, before invoking the agent:
   ```bash
   git checkout $BASE_BRANCH
   ```
   This guarantees each task starts from the base branch, not from the previous task's branch. (If `--no-branch` was used we wouldn't be in batch mode at all, so this is safe.)

2. **Invoke the chosen agent** via the Task tool, passing:
   - For `task-sequencer`: `forced_task_ids: [id]` (or `[]` if id is null), `worktree_requested`, `no_branch`, `skip_research: --quick`.
   - For `ad-hoc-task-creator`: `description: "<text>"`, `worktree_requested`, `no_branch`, `skip_research: --quick`.

3. **Wait for the structured output** (`mode`, `branch`, `worktree_path`, `task_id`, `task_title`, `task_file`, `next_action`).

4. **Branch on `next_action`:**

   - **`implement`** — task file is ready. Continue to Step 2 for THIS iteration.

   - **`enter_worktree`** — branch + worktree were created but the task file is NOT yet written. Do this:
     1. Call `EnterWorktree({ path: "<worktree_path>" })`. The session's CWD switches into the new worktree.
     2. Verify the switch with `pwd`.
     3. **Re-invoke the SAME agent** with no flags (it will detect Mode B inside the worktree and create the task file there).
     4. After the second invocation returns `next_action: implement`, continue to Step 2 for THIS iteration.

   - **`abort`** — Mode C (unrelated branch), or `task-sequencer` rejected a forced id (already done / blocked / not found). The agent already explained why.
     - If `task_ids` length == 1: stop the whole run.
     - If we're inside a batch (length > 1): ask the user "Continue with the next id in the batch, or abort the whole batch?". Default abort.

5. **After the iteration's Step 2 / Step 3 / Step 4 / Step 4.5 / Conclusion-per-task complete**, return here and continue with the next id in `task_ids`.

When `task_ids` is exhausted, jump to **Step 5: Final batch report**.

## Step 2: Execute the task

(For the current iteration's task file in `ai-docs/actual-todo/`.)

1. **Read the task file**. Understand objectives, guidelines, and acceptance criteria.

2. **Implement the task**:
   - Follow the implementation guidelines in the file.
   - Use the key files and code examples provided.
   - Make sure every item in the quality checklist is addressed.

3. **🔒 RULE: Use the official framework/library types — do NOT invent your own**

   Before declaring an `interface` or `type` of your own, **look for the official type first**. AIs tend to invent type definitions to solve problems, and this causes drift between the code and the library's actual API.

   Mandatory procedure before creating any type:

   1. **Check the library's own exports**: `import type { X } from 'next'`, `import type { ButtonProps } from '@/components/ui/button'`, `import type { Doc, Id } from '../convex/_generated/dataModel'`.
   2. **Inspect `node_modules/<lib>/dist/**/*.d.ts`** or the `.d.ts` files declared in the library's `package.json` (`"types"` or `"typings"`). Use `Grep` in `node_modules/<lib>` to find the definition.
   3. **For Next.js**: `PageProps`, `LayoutProps`, `Metadata`, `NextRequest`, `NextResponse` come from `next` or `next/server`. NEVER redeclare them.
   4. **For React**: `ReactNode`, `FC<Props>`, `ComponentProps<typeof X>`, `ComponentPropsWithoutRef<'button'>` — use the native helpers.
   5. **For libraries with code generation** (Convex, Prisma, Drizzle, tRPC, Zod): use the **generated** types, don't redeclare them.
   6. **For form libraries** (react-hook-form): use `useForm<z.infer<typeof schema>>()` with Zod, don't define the form's shape twice.

   **When defining your own type IS acceptable:** when the domain is project-specific (not a library) and no official type exists. Even then, **derive** from existing types (`Pick`, `Omit`, `z.infer`) whenever possible.

   If you catch yourself about to write `interface ButtonProps {…}` for a shadcn component that already exports `ButtonProps`, **STOP** and use what already exists.

4. **Track progress**:
   - Use TaskCreate/TaskUpdate to track each objective as you work.
   - Mark as `in_progress` when starting and `completed` when done.

5. **Update the task file as you go**:
   - Change `- [ ]` to `- [x]` for completed objectives, acceptance criteria, and quality checklist items.

## Step 2.5: `--dry-run` short-circuit

**If `--dry-run` was passed:**

After the task file has been written by the agent (and after any `--worktree` re-entry has resolved), but **before** entering Step 2's implementation work:

1. Print:
   ```
   ✅ Dry-run complete.
     Task file: <absolute path to task file>
     Branch:    <branch name>
     Worktree:  <path or "none">
   ```
2. **Stop.** Do not implement (Step 2 work). Do not run Playwright (Step 3). Do not run the design audit (Step 4). Do not run the conclusion. The branch and file remain on disk so the user can review and run `/claude:dev --task <id>` (without `--dry-run`) later to actually implement.

## Step 3 (optional): E2E test with Playwright MCP

**Run this step ONLY if the `--test` flag was passed.** In batch mode, this runs once per task.

### 🔒 RULE: Do NOT regress framework / API to "make a test pass"

If a test fails, it is **forbidden** to "fix" the problem with:
- An older framework version (e.g., using React 18 when the project is on React 19, Next 14 when it's on 16, Tailwind v3 when it's on v4).
- A legacy/deprecated API you remember ("I think `getInitialProps` solves this").
- An unofficial workaround (CDN script, obscure polyfill, third-party library that duplicates native functionality).
- Monkey-patching `node_modules`.

**Common root cause:** the AI knows an old version well and tries to force the familiar solution instead of learning the new way. Don't do this.

**Procedure when a test fails:**

1. **Don't modify** the version, runtime, or underlying framework.
2. **Identify** the real cause (use console errors, network tab via Playwright MCP).
3. **STOP and warn the user** with this format:
   ```
   ⚠️ Test failed in [flow]
   - **Real error:** [description]
   - **Current official solution** (in this project's version): [how it should be done]
   - **Why it looks complex:** [if applicable]
   - **I will NOT:** downgrade, use a deprecated API, or apply a workaround.
   - **Your call:** want me to implement the official solution, open an issue, or mark as blocked?
   ```
4. **Only proceed** once the user decides.

### Test execution

1. **Verify Playwright MCP**:
   - Confirm tools with the `mcp__playwright__*` prefix are available.
   - If NOT, **stop** and tell the user: "Playwright MCP is not configured. Add the MCP server to `.mcp.json` or `.claude/settings.json` before using `--test`."

2. **Make sure the app is running**:
   - Check whether the dev server is already active (the project framework's default port).
   - If not, start it in the background (e.g., `npm run dev`) and wait until it's ready.

3. **Define what to test**:
   - Re-read the **acceptance criteria** from the task file.
   - Identify the **route(s) and flow(s)** affected by the task.
   - For each UI-testable criterion, write a Playwright action sequence (navigate, click, fill, assert).

4. **Run the test via Playwright MCP**:
   - Navigate to the relevant URL.
   - Reproduce the implemented flow's golden path.
   - Verify expected elements appear (text, state, navigation).
   - Capture screenshot(s) of the final state as evidence.
   - Test at least one relevant error/edge case (invalid input, no permission, etc.).

5. **Report the test result**:
   - ✅ **Passed:** list what was verified and attach screenshots.
   - ❌ **Failed:** follow the RULE above — stop, describe, ask for a decision. **Do not** mark the task as `done`. Consider recording a lesson with `/claude:learning` if the failure was caused by an avoidable mistake.

## Step 4: Design System audit (automatic)

**Skip entirely if `--quick` was passed.** Otherwise: **always run, at the end of any task with frontend changes.**

1. **Detect whether any frontend file was created/modified** during the task:
   - Run `git status --short` and `git diff --name-only HEAD`.
   - Filter for: `**/*.tsx`, `**/*.jsx`, `**/*.css`, `**/*.scss`, `app/**/page.tsx`, `app/**/layout.tsx`, `components/**`, `tailwind.config.*`, `app/globals.css`.

2. **If NO frontend file was touched:** skip this step.

3. **If YES:** use the Task tool to invoke the `design-system-checker` agent, passing the list of modified frontend files. It will:
   - Read `/DESIGN.md` (if absent, warn and continue without blocking).
   - Audit each file for: hardcoded colors, off-scale `rounded`/`spacing` values, missing `on-*` pairs, components diverging from the spec.
   - Report with `file:line` and a verdict of `APPROVED / ATTENTION / REJECTED`.

4. **Act on the verdict:**
   - **✅ APPROVED:** proceed to Step 4.5.
   - **⚠️ ATTENTION** (minor violations): show the report, ask if the user wants to fix now or proceed.
   - **❌ REJECTED** (serious violations): **DO NOT** mark the task as `done`. Fix the listed violations (replace hardcoded hex with tokens, adjust arbitrary values to the scale) and re-run the checker. Only then proceed to Step 4.5.

## Step 4.5: Quality checklist auto-verification (automatic)

**Skip entirely if `--quick` was passed.** Otherwise: **always run, at the end of every task — UI or backend.**

This step exists because the quality checklist in the task file used to get rubber-stamped. We now run real checks on the diff. Items that the AI can verify get verified; items that genuinely need a human get surfaced to the user.

1. **Invoke the `quality-checklist-verifier` agent** via the Task tool, passing:
   - `task_file_path`: absolute path to the current task file in `ai-docs/actual-todo/`.
   - `base_branch`: `$BASE_BRANCH` (computed in Step 0.2).
   - `staged_only: false` (use the full branch range).

2. **Wait for its structured report** (per-item PASS / FAIL / N/A / USER-ONLY table + summary block + optional Action-required and Manual-verification-TODO sections).

3. **Act on the report:**

   - **No FAILs** → for each PASS item, edit the task file to change `[ ]` → `[x]`. For each N/A item, change `[ ]` → `[N/A]` and append the agent's reason as an italic note. For USER-ONLY items, **leave `[ ]`** and capture them for the final report (Step 5.3).

   - **Any FAIL** → **DO NOT mark the task as done.** Fix every FAIL by editing the relevant code, then re-invoke the verifier. Loop until all AI-verifiable items are PASS / N/A. If you can't fix a FAIL after 3 attempts, stop and ask the user.

4. **Bookkeeping for the run summary:**
   - Save the list of USER-ONLY items + their suggested manual-action strings to surface in **Step 5.3** at the end of the run (or the end of this single task in non-batch mode).
   - The user-only items are NOT a blocker — they don't prevent commit. They're a clear TODO for the human reviewer.

## Per-task Conclusion

Run **once per iteration of the Step 1.B loop**, when all objectives for the current task are complete (and Steps 3 and 4 passed, when applicable):

### 1. Sync with base branch (skip if `--no-branch` was used)

```bash
git fetch origin 2>/dev/null    # silent if no remote
git rebase $BASE_BRANCH          # silent if already up to date
```

This pulls in `task-master.md` updates from parallel branches that already merged. If a rebase conflict happens on `task-master.md`, resolve it by keeping BOTH sides (each parallel task only edits its own row).

### 2. Update `task-master.md`

(For PRD tasks only — skip for ad-hoc tasks since they don't appear in `task-master.md`.)

Make BOTH edits to the row for THIS task. Do NOT touch other rows (dependency cascading is computed lazily by `task-sequencer` next time).

1. **Status field** — change the `| **Status** | ... |` line to `done`.
2. **Acceptance criteria** — flip every `- [ ]` to `- [x]` in this task's `**Acceptance criteria:**` block. If a criterion was actually skipped or invalidated, mark it `- [N/A]` with a one-line italic reason.

**Verify before staging:**

```bash
git diff --cached ai-docs/todos/task-master.md
# You MUST see BOTH:
#   - the Status line flipped to `done`
#   - every `- [ ]` under this task's Acceptance criteria flipped to
#     `- [x]` (or `- [N/A]` with reason)
# If only the Status line shows up: STOP and go back to edit the
# acceptance criteria block before staging.
```

### 3. Archive the task file (`actual-todo/` → `todos/`)

Each task is responsible for archiving its own task file. Before staging, move it:

```bash
# PRD task
git mv ai-docs/actual-todo/<NN>-<slug>.md ai-docs/todos/<NN>-<slug>.md
# Ad-hoc task
git mv ai-docs/actual-todo/adhoc-<slug>.md ai-docs/todos/adhoc-<slug>.md
```

This is what keeps `actual-todo/` empty when no task is in flight, and lets `task-sequencer`'s pre-flight (Step 0.4.0b) treat a non-empty `actual-todo/` as a real bug. Never skip this step.

### 4. Stage and commit

```bash
git add -A
git commit -m "feat(<scope>): <task title>"
```

The commit MUST include: code changes + `task-master.md` row update + the `git mv` archive (detected by git as a rename). Verify with `git show --stat HEAD` — you should see `R ai-docs/actual-todo/<NN>-<slug>.md → ai-docs/todos/<NN>-<slug>.md`.

Use a conventional commit prefix matching the task type (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`). For ad-hoc tasks, default to `chore` unless the description suggests otherwise.

### 5. Branch on `--ship` and batch mode

- **`--ship` was passed** (single or batch): immediately do the per-task ship sequence (Step 5.A below), then return to Step 1.B for the next iteration in batch mode.
- **No `--ship`, single-task run**: jump to Step 5 (Final report) which prompts the user.
- **No `--ship`, batch run** (more ids remaining): record `<task_id, branch, commit_sha>` in an in-memory summary; return to Step 1.B. Steps 5.A / 5.B run AFTER the loop exits.

### 5.A. Per-task ship (only when `--ship` was passed)

Pre-flight before any network action:

1. Steps 3 (Playwright, if `--test`) and 4 (design audit, unless `--quick`) and 4.5 (quality checklist) all PASSED. If anything REJECTED/FAIL: **NEVER push or merge**. Stop and surface to the user.
2. `git remote get-url origin` returns a URL. If empty: degrade — print the suggested commands (Step 5.B style) and skip the network actions.
3. `gh auth status` exits 0. If not: same degradation as above.

Then:

```bash
git push -u origin task/<NN>-<slug>
gh pr create --base $BASE_BRANCH \
  --title "<task title>" \
  --body "$(cat <<'EOF'
## Summary
- <bullet of what changed>

Closes task <NN>.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
gh pr merge --squash --delete-branch --auto
git checkout $BASE_BRANCH
git pull --ff-only
```

Notes:
- `gh pr merge --auto` queues the merge to fire when CI passes (or fires immediately if no required checks). The session does not wait for the actual merge.
- If `gh pr create` fails because a PR already exists (re-run scenario), recover with `gh pr view --json url -q .url`, then call `gh pr merge` against that PR.
- If `gh pr merge` fails (conflicts, CI red), print the error and the PR URL, leave the branch in place. Never use `--admin`.
- If `git push` fails non-fast-forward, stop and tell the user to `git pull --rebase`. Never force-push.

Record `<task_id, branch, pr_url, merge_status>` in the in-memory summary for Step 5.

## Step 5: Final batch report (per-run, after Step 1.B loop exits)

When `task_ids` has been fully iterated:

### 5.1 — Push + PR + merge prompt (only when `--ship` was NOT passed)

(With `--ship`, this already happened per-task in Step 5.A — skip and go to 5.2.)

For each completed task in this run, do — sequentially, NOT in parallel:

1. **Pre-flight** (same as Step 5.A): Steps 3/4/4.5 passed, remote present, `gh auth status` OK. If any fail, fall back to printing suggested commands as a code block (no execution).

2. **Push and open PR:**
   ```bash
   git push -u origin task/<NN>-<slug>
   gh pr create --base $BASE_BRANCH \
     --title "<task title>" \
     --body "$(cat <<'EOF'
   ## Summary
   - <bullet of what changed>

   Closes task <NN>.

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   EOF
   )"
   ```
   Print the returned PR URL.

3. **Single prompt to the user** (one per task, not per batch):
   ```
   PR aberto: <url>
   Posso mergear (squash + delete branch + voltar para <BASE_BRANCH>)? [y/N]
   ```

4. **On `y` / `yes` / `s` / `sim`:**
   ```bash
   gh pr merge <url> --squash --delete-branch
   git checkout $BASE_BRANCH
   git pull --ff-only
   ```
   Record `merge_status: merged` for this task.

5. **On any other answer (default):** record `merge_status: pending-user-decision` and move on. Do NOT delete the branch.

Errors handled the same as Step 5.A (recover existing PR, no force-push, no `--admin`).

### 5.2 — Worktree cleanup hint

Only if we entered a worktree this session via `EnterWorktree`:

- Suggest `ExitWorktree({ action: "keep" })` to return to the original working directory in this session — the worktree directory and branch stay on disk so the user can finish the PR.
- Tell the user: "After the PR merges, remove the worktree with `git worktree remove ../<repo>-task-<NN>-<slug>`."

### 5.3 — Print the run summary

Three blocks, in this exact order:

#### 5.3.a — Run table

```
| Task ID        | Title                       | Branch                          | Status     | Commit  |
|----------------|-----------------------------|---------------------------------|------------|---------|
| 05             | Add user settings page      | task/05-add-user-settings-page  | done       | a1b2c3d |
| 06             | Wire up profile mutation    | task/06-wire-up-profile-mutation| done       | e4f5g6h |
| 07             | Add settings tests          | task/07-add-settings-tests      | aborted    | —       |
| adhoc-fix-…    | Fix login button styling    | task/adhoc-fix-login-button-…   | done       | i7j8k9l |
```

#### 5.3.b — 🤖 Automated quality checks

Summarise the `quality-checklist-verifier` results across all completed tasks in this run. One line per task:

```
🤖 Automated quality checks
  Task 05: ✅ 8/8 AI-verified items pass.
  Task 06: ✅ 7/8 AI-verified items pass · 1 N/A (no UI changes).
  Task adhoc-fix-…: ✅ 8/8 AI-verified items pass.
```

If any task had FAILs that were auto-fixed during Step 4.5, mention how many fix-iterations it took:
> `Task 05: ✅ 8/8 pass (after 1 fix-iteration: added Zod validation to apps/api/src/routes/orders.ts).`

#### 5.3.c — 👤 Manual verification TODO

The user-only items that the verifier flagged for human checking, aggregated across all completed tasks. ONE numbered list, deduplicated, with concrete actions:

```
👤 Please verify these manually before merging:
  1. [Task 05 + adhoc-fix-…] Open `/settings` and `/login` in a browser, resize 320 → 1280px, confirm the layout adapts cleanly at sm/md/lg breakpoints.
  2. [Task 05] Open DevTools device toolbar (Cmd-Shift-M), pick iPhone 14, tap each <Button> on `/settings` — confirm each hit area is comfortable.
  3. [All tasks] Read the diff and confirm the business logic matches your intent (the AI verified syntax, not semantics).
  4. [adhoc-fix-…] Confirm the new login button color matches the rest of your app's primary actions visually.
```

If a USER-ONLY item has no UI implication (e.g. backend-only task), it gets dropped from this block (only "business logic matches intent" remains).

#### 5.3.d — Standard tail

- Files created or modified (per task).
- Official types used (cite relevant imports — proof that you didn't redeclare).
- Playwright tests (if `--test` was used — including screenshots/evidence).
- `design-system-checker` verdict (if there were frontend changes).
- Suggested next action: open the PRs, or run `/claude:dev --task <next>` for further work.

## Execution notes

- Finish one objective before moving to the next within a task.
- Within a batch, finish one task fully (Steps 2 → 3 → 4 → 4.5 → per-task Conclusion) before moving to the next id.
- If you hit blockers, document them and ask the user for guidance.
- Always run relevant tests after implementing.
- Follow patterns already established in the code.
- If you make an avoidable mistake during execution, record it with `/claude:learning` so it doesn't repeat.
- The branch claim (existence of `task/<NN>-*` or `task/adhoc-*`) prevents two tabs from picking the same task. If you see a "branch already exists" error during Step 1, the agent should handle it (collision recovery for ad-hoc, abort-and-resume for PRD); re-run if it doesn't.
