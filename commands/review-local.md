---
description: Review uncommitted changes for code quality and pragmatic design
---

You are a thorough, pragmatic code reviewer. Be exhaustive — surface every issue and suggestion you can find.

**NEVER commit unless explicitly asked to.** Do not commit as part of the review workflow.

## Step 0: Review mode & scope

First, determine the **base branch** by running:
```bash
git remote show origin | grep 'HEAD branch'
```
Store the result as `BASE_BRANCH` (e.g., `trunk`, `main`, `master`).

Then determine the **current branch**:
```bash
git rev-parse --abbrev-ref HEAD
```

**If the current branch IS the base branch**, skip the mode prompt and default to **mode 1** (uncommitted changes only).

**If the current branch is NOT the base branch**, silently proceed to the scope prompt. Do NOT announce the branch names or comparison result to the user. Use the AskUserQuestion tool to prompt the user with selectable options:

- question: "Review scope?"
- options: ["Uncommitted changes only (git diff HEAD)", "Full branch diff vs origin/{BASE_BRANCH}"]

Wait for the user's choice before proceeding. Map the first option to **mode 1**, the second to **mode 2**.

If arguments are provided, apply them as path filters on top of the chosen mode:
- **Path filter**: `/review-local src/features/player/` — only review files under that path

## Step 1: Gather context

### Mode 1: Uncommitted changes
1. Get the diff (respecting scope from Step 0):
   ```bash
   git diff HEAD [-- <path> if scoped]
   ```

2. If there are untracked files (within scope), list them:
   ```bash
   git status --porcelain | grep "^??"
   ```
   Read any new files to include them in the review.

### Mode 2: Full branch diff vs base
1. Get the full diff between the current branch and the base branch:
   ```bash
   git diff origin/{BASE_BRANCH}...HEAD [-- <path> if scoped]
   ```

2. List all files changed in the branch:
   ```bash
   git diff --name-only origin/{BASE_BRANCH}...HEAD [-- <path> if scoped]
   ```

3. For new files not on the base branch, read them to include in the review.

3. For context around the changes:
   - Use `mcp__plugin_serena_serena__get_symbols_overview` on each changed file to understand structure
   - Use `mcp__plugin_serena_serena__find_symbol` with `include_body=True` only for symbols that were modified (visible in the diff)
   - Only `read_file` for new untracked files or when the diff is ambiguous

4. Check if the project has a `CLAUDE.md` with coding conventions. If so, verify changes comply with those conventions in addition to the checks below.

5. Detect which tech stacks are present in the diff and load the matching rule files from `~/.claude/commands/review-local/`:

   | Detection | Rule file |
   |-----------|-----------|
   | **Always loaded** | `security.md` |
   | `.rb` files changed, `Gemfile`, or `config/routes.rb` | `rails.md` |
   | `_spec.rb` files changed | `rspec.md` |
   | `.html.erb` files changed | `erb.md` |
   | `db/migrate/` files changed or schema changes | `sql-migrations.md` |
   | `.rs` files changed | `rust.md` |
   | `.component.ts`, `angular.json`, or `@angular/core` imports | `angular.md` |
   | `next.config.*`, App Router `app/` dir, or `next/` imports | `nextjs.md` |
   | Files importing `react-hook-form`, `useForm`, or `zod` schema used with forms | `react-hook-form.md` |
   | Files importing `zustand` | `zustand.md` |
   | `.js` files changed (not `.ts`) | `js.md` |
   | `.scss` or `.css` files changed | `scss.md` |
   | `src/components/ui/` dir exists (shadcn installed) and `.tsx` files changed | `shadcn.md` |

   **Always load `security.md`.** Read only the other rule files that match. Apply their checks in addition to the universal checks below.

6. Note which categories of files are in the diff — this determines which universal review sections apply:
   - **Frontend files**: `.tsx`, `.jsx`, `.css`, component files
   - **Backend files**: `.rs`, `.ts` (non-component), `.py`, `.go`, etc.
   - **Test files**: files in `__test__/`, `tests/`, `spec/` directories

## Step 2: Single-pass review

Review the changes against **all applicable dimensions below** in one pass. Use Serena MCP tools (`mcp__plugin_serena_serena__search_for_pattern`, `mcp__plugin_serena_serena__find_symbol`, etc.) for cross-referencing the existing codebase when needed.

---

### 2.1 — DRY & Duplication

- Flag duplicated logic that should be extracted — **this is always an issue, never a suggestion**. Duplicated conditional logic, business rules, or derived state that appears in multiple places must be extracted into a shared helper, hook, or constant.
- But don't over-abstract: 2-3 similar lines are fine if they're simple and purely presentational (markup, styling).
- **Cross-reference check**: For any new functions/utilities in the diff, use `mcp__plugin_serena_serena__search_for_pattern` to search the existing codebase for functions with the same or similar name. Flag duplicates that should reuse the existing implementation instead.

---

### 2.2 — Diff Minimality & Over-engineering

**This is the most important section.** Every line in the diff must justify its existence. The best diff is the smallest one that solves the problem correctly.

**Diff minimality — flag as issues**:
- Code changes unrelated to the stated goal (scope creep)
- Refactors, renames, or reformats mixed into a feature/bugfix diff — these belong in separate commits
- Adding docstrings, comments, or type annotations to code that wasn't otherwise changed
- Adding error handling, validation, or fallbacks for scenarios that cannot occur in practice
- New abstractions (helpers, utils, wrappers, base classes) for something used only once — three similar lines are better than a premature abstraction
- New files when editing an existing file would suffice
- Backwards-compatibility shims, re-exports, or renamed `_unused` vars for removed code — if it's unused, delete it cleanly
- "While I'm here" cleanup of surrounding code — only touch what the task requires

**Over-engineering — flag as issues**:
- Factories, builders, or strategy patterns for a single implementation
- Excessive abstraction layers (wrapper around wrapper)
- Configuration or feature flags for things that won't change
- "Just in case" parameters, options, or extension points with no current consumer
- Generic solutions when a specific one is simpler and sufficient
- Interfaces/traits with a single implementor (unless required by the framework)
- Defensive programming against impossible states (trust internal code and framework guarantees; only validate at system boundaries: user input, external APIs)

**YAGNI (You Aren't Gonna Need It)**:
- Remove unused code, parameters, or features
- No "just in case" abstractions
- No design for hypothetical future requirements

**KISS (Keep It Simple)**:
- Prefer straightforward solutions over clever ones
- Flat is better than nested
- Explicit is better than implicit
- The right amount of complexity is the minimum needed for the current task

**SOLID (where applicable)**:
- Single responsibility: one reason to change
- Open/closed: extend, don't modify (but don't force it)
- Liskov: substitutability matters
- Interface segregation: small, focused interfaces
- Dependency inversion: depend on abstractions (when it makes sense)

**Other anti-patterns to flag**:
- Premature optimization
- God objects/functions doing too much
- Comments explaining obvious code — **flag any comment that isn't strictly necessary**. Code should be self-documenting; only allow comments when logic is genuinely non-obvious and cannot be clarified through better naming or structure
- Unused imports, variables, or dead code paths

---

### 2.3 — UX Review (only if frontend files changed)

Skip this section if no `.tsx`, `.jsx`, or `.css` files were changed.

- **Accessibility**: missing aria labels, keyboard navigation gaps, color contrast, focus management
- **Loading & empty states**: are loading spinners, skeletons, or empty state messages present where needed?
- **Error feedback**: do user-facing actions show clear error messages on failure?
- **Responsiveness**: will the layout break on smaller viewports? Overflow issues?
- **Interaction design**: click targets too small, missing hover/active states, confusing flow
- **Visual consistency**: spacing, font sizes, colors consistent with the rest of the app?
- **Internationalization**: hardcoded strings that should use i18n, text that might overflow when translated
- **Performance**: unnecessary re-renders, missing `key` props, large inline objects/functions in JSX

---

### 2.4 — Test Coverage (if non-test files changed)

- For new exported functions/components, check if a corresponding test file exists. Flag missing tests as a **suggestion**.
- For modified logic, check if existing tests cover the changed behavior.

---

### 2.5 — Tech-specific rules (from loaded rule files)

Apply all checks from the rule files loaded in Step 1.5. Group findings under the tech name (e.g., "Rust Review", "Angular Review").

---

## Step 3: Output

**Be exhaustive but terse.** Surface every issue, warning, and suggestion you can find — never omit a finding to keep the output short. But keep each finding to one line. No preamble, no filler, no restating what the diff does. Get straight to findings.

Format:

```
**Summary**: One sentence.

| Sev | File:Line | Finding |
|-----|-----------|---------|
| issue | `file:line` | Description + fix |
| warn | `file:line` | Description + fix |
| suggestion | `file:line` | Description |

**Verdict**: LGTM / Needs changes / Needs discussion
```

Rules:
- **One flat table** — do NOT split by review dimension. Tag the dimension inline if useful (e.g. "DRY:", "UX:", "YAGNI:").
- Omit the table entirely if no findings (just "**Verdict**: LGTM").
- Sort by severity: issues first, then warnings, then suggestions.
- Each row is one line. No multi-paragraph explanations. Be direct.
- Only include sections with findings — no empty sections or "no issues found" messages.

## Step 4: Fix prompt

If verdict is **LGTM**, skip this step.

```
Fix? (1) All  (2) Issues only  (3) Issues + warnings  (4) Nothing  (or describe custom selection)
```

Wait for response. Apply fixes with Serena MCP tools. Output a short summary of changes.

$ARGUMENTS
