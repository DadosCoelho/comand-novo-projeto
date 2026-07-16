---
name: skill-creator
description: Create, edit, evaluate, and optimise Claude Code skill files (.claude/skills/). Covers file format, trigger authoring, eval harnesses, and the tools.yaml registration step.
trigger: >
  TRIGGER when the user asks to create a skill, add a skill, write a new skill, improve an existing
  skill description, benchmark a skill, run evals on a skill, or optimise a skill's trigger text.
  Also trigger when the user says "make a skill for X", "build a skill that does Y", or "the skill
  isn't triggering correctly".
  SKIP when the user is implementing application code, not meta-tooling.
---

# Skill Creator

Author, edit, benchmark, and optimise Claude Code skill files.

---

## Skill file anatomy

Every skill lives in `.claude/skills/<skill-name>/SKILL.md`. The YAML frontmatter controls when the skill loads; the body is pure context injected into the conversation when the skill fires.

```markdown
---
name: <kebab-case>
description: <one sentence — used by the runtime to match the user's intent when deciding which skill fits>
trigger: >
  TRIGGER when <concrete situations, phrasings, file patterns, or import patterns that mean the skill is relevant>.
  Also trigger when <additional patterns>.
  SKIP when <situations where the skill would match but should NOT fire>.
---

# Skill Title

[Body — everything here becomes live context when the skill is invoked]
```

### Frontmatter fields

| Field | Required | Purpose |
|---|---|---|
| `name` | yes | Unique identifier, kebab-case, matches the folder name |
| `description` | yes | One sentence the runtime uses for intent-matching — make it precise |
| `trigger` | recommended | Multi-line instruction for *when* to auto-fire; starts with `TRIGGER when …` |

---

## Writing a high-quality trigger

The `trigger` field is the most important thing to get right. A bad trigger causes two failure modes:
- **False positive** — fires when the skill is irrelevant, polluting context.
- **False negative** — doesn't fire when it should, making the skill invisible.

### Trigger authoring rules

1. **Lead with `TRIGGER when`** — the runtime pattern-matches this prefix.
2. **Be concrete** — name specific file imports, phrases, flag names, or patterns rather than vague intentions.
3. **Add negative examples with `SKIP when`** — this is where most triggers fail. Explicitly list the cases that look similar but shouldn't fire.
4. **Cover surface area** — list 4–8 distinct phrasings/situations rather than one.

**Weak trigger (too vague):**
```yaml
trigger: >
  TRIGGER when the user is working on email.
```

**Strong trigger (specific + negative):**
```yaml
trigger: >
  TRIGGER when code imports from 'resend', '@resend/node', or 'react-email'.
  Also trigger when the user mentions Resend, transactional email, email deliverability, SPF/DKIM,
  DMARC, email webhooks, or building an email template.
  Also trigger when the user asks to send an email, debug email delivery, or configure a mail domain.
  SKIP when the user is discussing Gmail/Outlook as an end-user, or building an email client UI
  (not a sending integration).
```

---

## Skill body: what to include

The body is injected as context, so it should be **dense, reference-grade material** — not a tutorial. Write as if you're briefing an expert who needs quick lookups, not a beginner who needs explanation.

**Good sections for most skills:**
- **Decision tree** — "use X when Y, use Z when W" tables
- **Code templates** — minimal, copy-paste-ready snippets for the most common patterns
- **Anti-patterns** — explicit list of what NOT to do
- **Gotchas / footnotes** — version pins, non-obvious constraints, known bugs
- **Quick-reference table** — API methods, config keys, flags

**Anti-patterns in skill bodies:**
- Long prose explanations of what the skill does (user can read the description)
- Obvious best practices that Claude already knows (no value-add)
- Tutorial-style "step 1, step 2…" walkthroughs (use a command instead)
- Duplicate content from another skill (link to it instead)

---

## Skill size guidelines

| Skill type | Target size |
|---|---|
| Simple reference (a few patterns) | 100–300 lines |
| Standard library / framework guide | 300–600 lines |
| Complex domain (auth, payments, email) | 600–1000 lines |
| Router (dispatches to sub-skills) | 50–150 lines |

If a skill exceeds ~1000 lines, consider splitting it into a **router + sub-skills**: a thin router that reads intent and invokes the right sub-skill.

### Router pattern

```markdown
---
name: my-skill
description: Router for X — dispatches to the right sub-skill based on the task.
trigger: >
  TRIGGER when the user is working with X.
---

# My Skill — Router

Based on what you need:

| Goal | Sub-skill to invoke |
|---|---|
| Build a new X | `Skill(skill: "my-skill-build")` |
| Debug an existing X | `Skill(skill: "my-skill-debug")` |
| Migrate from old X | `Skill(skill: "my-skill-migrate")` |

Invoke the appropriate sub-skill now.
```

---

## Registration in tools.yaml

After creating the skill file, always add an entry to `ai-docs/tools.yaml` under `skills:` so the `task-sequencer` can inject it into relevant task files:

```yaml
- id: <skill-name>
  name: <skill-name>
  scope: project
  path: .claude/skills/<skill-name>/SKILL.md
  purpose: <one sentence — what the skill does>
  use_when: <one sentence — when an implementing agent should reach for it>
  how_to_invoke: 'Skill(skill: "<skill-name>")'
  tags: [<tag1>, <tag2>]
```

---

## Evaluating a skill

Before shipping a skill, run a quick eval:

### Trigger eval (5 prompts)
Write 5 user messages that SHOULD trigger the skill. Invoke the skill manually and check that:
- The right content is injected
- No irrelevant sections pollute the response
- The description in `MEMORY.md` (if applicable) still matches

Write 3 user messages that should NOT trigger the skill. Verify the skill doesn't fire.

### Body eval (3 tasks)
Pick 3 realistic tasks the skill should help with. Run each and check:
- Did the skill improve the output compared to no skill?
- Did Claude follow the patterns in the body, not invent new ones?
- Are there gaps — patterns that come up but aren't covered?

---

## Benchmarking trigger description accuracy

The `description` field is used by the harness runtime for intent-matching when multiple skills are candidates. To optimise it:

1. List the 5 most common user phrasings for the skill's use case.
2. Check that at least 4 of 5 phrasings semantically match the description.
3. Check that the description does NOT match 5 phrasings for a *different* skill.
4. If it fails: rewrite to be more specific (add the library name, the domain, the framework).

**Rule of thumb:** if you removed the `name` field and only had the `description`, would you still know exactly what the skill does? If not, the description is too vague.

---

## Step-by-step: create a new skill

1. **Identify the domain.** What specific library, framework, pattern, or workflow does this skill cover?
2. **Check for overlap.** Read existing skill files and `tools.yaml`. Don't create a skill that duplicates one already present.
3. **Choose the scope.** One focused skill beats a sprawling one. If the domain has 3+ distinct sub-tasks, consider a router.
4. **Draft the trigger.** Write `TRIGGER when` lines and at least one `SKIP when`. Test mentally against 5 real prompts.
5. **Write the body.** Dense reference material: decision trees, templates, anti-patterns, gotchas.
6. **Create the file** at `.claude/skills/<name>/SKILL.md`.
7. **Register in tools.yaml** under `skills:`.
8. **Verify** the skill appears in the system-reminder skills list on the next message.

---

## Editing an existing skill

When improving a skill:
- Always read the current SKILL.md before editing.
- Change the `description` only if the trigger semantics truly changed — runtime caches may need a reload.
- Add to the body rather than replacing working sections.
- Update `tools.yaml` if `purpose` or `use_when` changed.
- Run the trigger eval again after edits.

---

## Multi-file skills

A skill folder can contain multiple files. The runtime loads `SKILL.md` as the entry point. Additional files (examples, templates, snippets) can be placed alongside and referenced from the body:

```
.claude/skills/my-skill/
  SKILL.md          ← entry point (always required)
  examples.md       ← supplementary examples (reference from SKILL.md)
  templates/
    base.html       ← reusable template files
```

Only `SKILL.md` is auto-loaded; other files must be referenced explicitly (e.g., `Read` tool calls in the skill body or invoked by Claude when following skill instructions).
