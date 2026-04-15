---
name: clean-commit
description: Use when ready to commit current work following Conventional Commits with auto-extracted ticket from branch name
model: claude-haiku-4-5
---

Your task is to prepare a clean, production-ready Git commit following Conventional Commits, with automatic ticket extraction from the branch name.

## 1. Clean the codebase

Review changed files for obvious debug artifacts and remove them:
- `console.log`, `debugger`, `binding.pry`, `byebug`, `puts` used for debugging
- `TODO`/`FIXME`/`HACK` comments added during this work session
- Commented-out code blocks that are clearly leftover experiments

**Do NOT remove:** intentional logging, error handling, or comments that explain non-obvious logic.

If unsure whether something is intentional, leave it.

## 2. Stage changes

- Run `git diff` and `git status` to review all changes.
- Stage relevant files **by name** — never use `git add .` or `git add -A`.
- **Include deleted files in the stage list.** `git status` shows them as `D`. Pass their paths to `git add <path>` (this stages the deletion) or use `git rm <path>`. Forgetting them leaves dangling `D` entries after the commit.
- Exclude sensitive files (`.env`, credentials, secrets) and unrelated changes.
- **Verify after staging:** run `git status` and confirm every intended change (modifications, additions, deletions, renames) appears under "Changes to be committed" and nothing intended remains under "Changes not staged". Do this before composing the commit message.

## 3. Extract ticket from branch name

- Get branch: `git rev-parse --abbrev-ref HEAD`
- If it matches `[A-Z]+-[0-9]+` (e.g. GCO-1299), extract it for the commit message.
- If no match, proceed without a ticket suffix.

## 4. Compose commit message

Format:
```
<type>(scope): <short imperative summary> [TICKET-123]
```

### Quick Reference — Commit Types

| Type | Use when |
|------|----------|
| `feat` | Adding new user-facing functionality |
| `fix` | Fixing a bug |
| `refactor` | Restructuring code without behavior change |
| `chore` | Maintenance tasks (deps, config, tooling) |
| `docs` | Documentation only |
| `test` | Adding or updating tests only |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes |
| `build` | Build system or external dependency changes |
| `style` | Formatting, whitespace, semicolons (no logic change) |

### Rules

- **Summary:** present tense, imperative mood, max ~72 chars including ticket, no trailing period
- **Scope:** the module, component, or area affected (e.g. `auth`, `idp`, `api`). Omit if change spans many areas.
- **Ticket:** appended in brackets at end of summary line, only if detected from branch.
- **Body (optional):** explain **why**, not what. Skip if the summary is self-explanatory.

## 5. Commit

Always use a HEREDOC for the commit message:
```bash
git commit -m "$(cat <<'EOF'
type(scope): summary [TICKET-123]

Optional body explaining why.
EOF
)"
```

Never use `--no-verify` unless the user explicitly requested it.

## Common Mistakes

- **Wrong type:** `refactor` means no behavior change. If you're fixing a bug during a refactor, it's `fix`.
- **Scope too broad:** if you can't name a single area, the commit may need splitting.
- **Summary too long:** the ticket eats ~10 chars. Keep the description under 60 chars.
- **Staging everything:** always review `git status` and stage files individually.
- **Missing deletions:** `git add <modified-files-only>` leaves deleted files unstaged. Always include `D` entries from `git status` in the stage list, then re-check `git status` before committing.

## Additional user instructions (if any)

"$ARGUMENTS"
