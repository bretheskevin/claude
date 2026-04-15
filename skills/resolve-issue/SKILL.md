---
name: resolve-issue
description: Resolve the first open GitHub issue using EPCT workflow
---

You are a systematic implementation specialist. Your job is to pick up the first open GitHub issue and resolve it autonomously.

## Step 0: Initialize Serena

**Goal**: Load project context if this is a fresh session

- If Serena memories exist (`list_memories`), read the relevant ones
- If onboarding was never performed (`check_onboarding_performed`), run `onboarding` first
- Otherwise, skip directly to Step 1

## Step 1: Fetch the Issue

Run this command to get the first open issue:

```bash
gh issue list --state open --limit 1 -S "sort:created-asc" --json number,title,body,labels,assignees
```

Then read full details:

```bash
gh issue view <number> --json number,title,body,labels,comments
```

## Step 2: Check if Already Resolved

Before implementing, verify whether the issue's requirements are already satisfied by the current codebase. Check the relevant files, symbols, and tests mentioned in the issue. If **all** acceptance criteria are already met:

1. Close the issue with a comment explaining it's already resolved:
   ```bash
   gh issue close <number> --comment "Closing: this feature is already implemented in the current codebase. All acceptance criteria are met."
   ```
2. **Skip to Step 5** (next issue loop).

## Step 3: Resolve with EPCT

Use the /epct command with the issue content as the task. Apply these overrides:

**IMPORTANT OVERRIDES to the EPCT workflow:**
- In the PLAN phase, do **NOT** stop for user confirmation. Proceed directly to CODE regardless of risk level.
- The user will test manually after you finish. Present a clear summary of changes at the end.
- Do **NOT** commit any changes. The user will commit when ready.

Invoke /epct with the issue title and body as the $ARGUMENTS.

## Step 4: Review and Fix (MANDATORY — DO NOT SKIP)

⛔ **BLOCKING REQUIREMENT**: You MUST launch the review agent after EPCT completes. Do NOT present results to the user, do NOT summarize changes, do NOT proceed to Step 5 until the review agent has run and returned LGTM. Skipping this step is a workflow violation.

Launch an **Agent** (subagent_type: `general-purpose`) to run the review-and-fix loop. This protects the main context from the review's verbose output.

Use this prompt for the agent:

````
You are a code reviewer and fixer. Your job is to run /review-local on the uncommitted changes and fix all findings until the review is clean.

**NEVER commit unless explicitly asked to.** Do not commit as part of the review workflow.

## MANDATORY: Use Serena MCP Tools

This project uses Serena MCP for all codebase interaction. You MUST use these tools:

**Reading/exploring code:**
- `mcp__plugin_serena_serena__get_symbols_overview` — Get high-level view of symbols in a file
- `mcp__plugin_serena_serena__find_symbol` — Find symbols by name path, optionally include body/info
- `mcp__plugin_serena_serena__find_referencing_symbols` — Find references to a symbol
- `mcp__plugin_serena_serena__search_for_pattern` — Regex search across codebase
- `mcp__plugin_serena_serena__list_dir` — List directory contents
- `mcp__plugin_serena_serena__find_file` — Find files by name/mask
- `mcp__plugin_serena_serena__read_file` — Read file contents (use sparingly, prefer symbolic tools)

**Editing code:**
- `mcp__plugin_serena_serena__replace_symbol_body` — Replace an entire symbol's body
- `mcp__plugin_serena_serena__insert_after_symbol` — Insert code after a symbol
- `mcp__plugin_serena_serena__insert_before_symbol` — Insert code before a symbol
- `mcp__plugin_serena_serena__replace_content` — Regex-based content replacement in files
- `mcp__plugin_serena_serena__rename_symbol` — Rename a symbol across the codebase
- `mcp__plugin_serena_serena__create_text_file` — Create new files

**DO NOT use basic Read/Grep/Glob/Edit tools for code interaction. Use Serena MCP equivalents.**

## Workflow

1. Invoke the `/review-local` skill (use the Skill tool with skill: "review-local").
2. **IMPORTANT OVERRIDE to /review-local:** When it reaches Step 0 (scope prompt), select "Uncommitted changes only (git diff HEAD)". When it reaches Step 4 (Fix? prompt), do NOT ask the user. Automatically fix **all** findings — issues, warnings, and suggestions alike — immediately.
3. After fixing all findings, run `/review-local` again.
4. Repeat until the review passes completely clean with **no findings at any severity level** (verdict: LGTM).
5. When clean, return a short summary of what was fixed across all review rounds.
````

Wait for the agent to complete. Include its summary in your final output to the user.

## Step 5: Next Issue (only if already resolved)

If the issue was **already resolved** (closed in Step 2), loop back to **Step 1** to fetch the next open issue. Repeat until there are no open issues left. When `gh issue list` returns an empty list, tell the user: **"All open issues have been resolved."**

If you **implemented code** (Steps 3–4), **stop here**. The user needs to review, commit, and push before moving on.
