# Record a Lesson Learned

Adds a new entry to `ai-docs/lessons.md` with a lesson learned — typically after making a mistake, discovering a pitfall, or solving a non-obvious problem.

## Arguments

- `$ARGUMENTS` — optional. Free-form description of the lesson. If empty, **ask the user** for the fields below before writing.

## When to use

- After fixing a bug that could have been avoided.
- After realizing an assumption about a library/API was wrong.
- After discovering a project convention that wasn't documented.
- Whenever the user says "remember this", "write this down", "so we don't forget".

## Steps

### Step 1: Collect the fields

You need:

- **Context:** what was being done (task, file, feature).
- **What went wrong:** description of the problem/error.
- **Root cause:** why it happened (not just the symptom).
- **How to avoid:** an actionable rule for the future.
- **Tags:** 1-5 keywords in kebab-case (e.g., `auth`, `convex-validators`, `tailwind-dark`).

If `$ARGUMENTS` was provided, extract those fields from the text. If anything is missing, **ask the user** before writing.

### Step 2: Add the entry

1. Read `ai-docs/lessons.md`.
2. Create the file if it doesn't exist (use the standard template header).
3. Add the new lesson **above the existing lessons** (most recent first), right after the comment `<!-- New lessons will be added below this comment by the /claude:learning command -->`.

### Format of each entry

```markdown
### [YYYY-MM-DD] Short lesson title

- **Context:** [what was being done]
- **What went wrong:** [problem description]
- **Root cause:** [why it happened]
- **How to avoid:** [actionable rule for the future]
- **Tags:** `tag1`, `tag2`, `tag3`

---
```

### Step 3: Confirm

After saving, show the user:

- Title and date of the recorded lesson.
- Path to the file (`ai-docs/lessons.md`).
- Current total of lessons in the file.

## Rules

- Use today's date (YYYY-MM-DD format) — ask the user if you don't know.
- Match the language of the PRD (default: English).
- Be **concise and actionable** — a vague lesson is useless. "Always validate input" is bad. "Always validate `id` as `string` in Convex `args` — `v.string()` accepts any IDs, `v.id('table')` rejects legacy IDs without prefix" is useful.
- If a lesson on the same topic already exists, **update it** instead of duplicating.
