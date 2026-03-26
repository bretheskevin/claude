---
description: Create a well-structured GitHub issue with codebase context
---

# Create GitHub Issue

Create a well-structured, actionable GitHub issue enriched with codebase context gathered via Serena MCP.

## Instructions

### 1. Parse user input

The user provides a description of the issue via `$ARGUMENTS`.
If `$ARGUMENTS` is empty, ask the user to describe the issue (bug, feature, improvement, etc.).

### 2. Classify the issue type

Based on the description, determine the type:
- **bug** — Something is broken or behaving unexpectedly
- **feature** — New functionality request
- **improvement** — Enhancement to existing functionality
- **chore** — Maintenance, refactoring, tech debt
- **docs** — Documentation-related

### 3. Gather codebase context with Serena MCP

Use Serena MCP tools to find relevant code context:

- `mcp__plugin_serena_serena__search_for_pattern` — Search for keywords from the description across the codebase
- `mcp__plugin_serena_serena__find_symbol` — Find specific functions/components mentioned or implied
- `mcp__plugin_serena_serena__get_symbols_overview` — Get an overview of relevant files
- `mcp__plugin_serena_serena__find_referencing_symbols` — Trace references to understand scope of impact

Collect:
- **Relevant files** — Which files are involved or would need changes
- **Key symbols** — Functions, components, types related to the issue
- **Current behavior** (for bugs) — What the code currently does
- **Integration points** (for features) — Where new code would hook in

### 4. Build the issue

Structure the issue with the following template, adapting sections based on issue type:

**For bugs:**

```markdown
## Description

[Clear, concise description of the bug]

## Steps to Reproduce

1. [Step 1]
2. [Step 2]
3. ...

## Expected Behavior

[What should happen]

## Actual Behavior

[What happens instead]

## Codebase Context

**Relevant files:**
- `path/to/file.ts` — [why it's relevant]

**Key symbols:**
- `functionName` in `file.ts` — [what it does in this context]

## Possible Fix

[If the investigation suggests a fix direction, describe it here]
```

**For features / improvements:**

```markdown
## Description

[Clear description of what is needed and why]

## Proposed Solution

[High-level approach]

## Codebase Context

**Relevant files:**
- `path/to/file.ts` — [why it's relevant]

**Key symbols:**
- `functionName` in `file.ts` — [integration point or related logic]

**Integration points:**
- [Where new code hooks into existing architecture]

## Alternatives Considered

[If applicable, briefly note other approaches]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
```

**For chores / docs:**

```markdown
## Description

[What needs to be done and why]

## Scope

**Affected files:**
- `path/to/file.ts` — [what needs changing]

## Tasks

- [ ] [Task 1]
- [ ] [Task 2]
```

### 5. Apply labels

Select appropriate labels from the repo. Use `gh label list` to check available labels.
Map to common labels:
- bug → `bug`
- feature → `enhancement`
- improvement → `enhancement`
- chore → `chore` or `maintenance`
- docs → `documentation`

### 6. Create the issue

Create the issue immediately without asking for confirmation:

```bash
gh issue create --title "<title>" --body "<body>" --label "<labels>"
```

Display the issue URL when done.

## Writing Rules

- **Title**: Imperative mood, concise (<70 chars), prefixed with type when helpful (e.g., "fix: ...", "feat: ...")
- **Description**: Written for a developer picking this up fresh — enough context to start without asking questions
- **Code references**: Use backtick formatting for all file paths and symbol names
- **No speculation**: Only include codebase context that was actually verified via Serena MCP tools
- **Concise**: Be thorough but not verbose. Every line should add information

## Arguments

$ARGUMENTS - Description of the issue to create. Can be a brief summary; the skill will research and expand it.

## Example Usage

- `/create-issue search results don't persist when navigating back`
- `/create-issue add keyboard shortcut to pause/resume downloads`
- `/create-issue refactor pipeline.rs to reduce nesting depth`
