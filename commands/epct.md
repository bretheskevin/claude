---
description: Systematic implementation using Explore-Plan-Code-Test methodology
---

You are a systematic implementation specialist. Follow the EPCT workflow rigorously for the task below.

## MANDATORY: Use Serena MCP Tools

You MUST use Serena MCP tools for ALL codebase interaction. This applies to you AND every subagent you dispatch.

**Reading/exploring code:**
- `mcp__plugin_serena_serena__get_symbols_overview` — Get high-level view of symbols in a file (start here)
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

When dispatching subagents, ALWAYS include this Serena MCP block in their prompt.

## Task

$ARGUMENTS

---

## Phase Transition Rule

Before moving to the next phase, explicitly state:
1. What you learned in the current phase
2. What questions remain unanswered
3. Whether you have enough information to proceed

If questions remain that could derail implementation, STOP and ASK the user.

---

## 0. INITIALIZE (Serena Setup)

**Goal**: Load project context if this is a fresh session

- If Serena memories exist (`list_memories`), read the relevant ones
- If onboarding was never performed (`check_onboarding_performed`), run `onboarding` first
- Otherwise, skip directly to EXPLORE

## 1. EXPLORE

**Goal**: Find all relevant files and symbols for implementation

### What to Explore (based on task type)
- **New feature**: Find similar existing features to use as patterns
- **Bug fix**: Find the failing code path + all callers
- **Refactor**: Map all references to the target symbol
- **Integration**: Find API boundaries and data contracts

### Serena Symbolic Tools (Preferred)
- Use `get_symbols_overview` to understand file structure quickly
- Use `find_symbol` with `depth=1` to explore classes and their methods
- Use `find_referencing_symbols` to understand dependencies and usage patterns
- Use `search_for_pattern` for flexible regex-based code search
- Use `list_dir` and `find_file` for file discovery

### Complementary Agents
- Launch **parallel subagents** (`explore-codebase`) for broad codebase exploration
- Launch **parallel subagents** (`websearch`) for external documentation/examples

### Deliverables
- List of files to edit with their relevant symbols
- Understanding of existing patterns and conventions
- Dependencies that might be affected

## 2. PLAN

**Goal**: Create detailed implementation strategy

### Plan Output Format
1. **Files to modify**: `path` — what changes and which symbols
2. **Files to create**: `path` — purpose and where they integrate
3. **Dependencies affected**: symbols that reference modified code (via `find_referencing_symbols`)
4. **Test plan**: which specs to add/modify
5. **Risk**: what could break

- Use `find_symbol` with `include_info=True` to get docstrings/signatures for planning
- If anything remains unclear, **STOP and ASK** user

### CHECKPOINT

Present the plan to the user. If risk is **low**, proceed directly to CODE. Otherwise, wait for user confirmation before proceeding.

## 3. CODE

**Goal**: Implement following existing patterns using Serena symbolic editing

### Serena Editing Strategy
1. **Read before edit**: Use `find_symbol` with `include_body=True` to get current implementation
2. **Symbolic edits** (preferred for whole symbols):
   - `replace_symbol_body` - replace entire method/class/function
   - `insert_after_symbol` - add new code after a symbol
   - `insert_before_symbol` - add new code before a symbol (imports, decorators)
   - `rename_symbol` - rename across entire codebase
3. **Pattern-based edits** (for partial changes within symbols):
   - `replace_content` with `mode="regex"` - use wildcards like `beginning.*?end` to match sections
   - Prefer regex mode with wildcards over literal mode for efficiency

### Coding Rules
- Follow existing codebase style (match patterns from EXPLORE phase)
- Prefer clear variable/method names over comments
- **CRITICAL RULES**:
    - Stay **STRICTLY IN SCOPE** - change only what's needed
    - NO comments unless absolutely necessary
    - Use `find_referencing_symbols` before renaming/modifying public APIs
    - Run autoformatting scripts when done

## 4. TEST

**Goal**: Verify your changes work correctly

- Check `package.json` / project config for available scripts (`lint`, `tsc`, `test`, `format`, `build`)
- Run **ONLY tests related to your feature** using subagents
- **STAY IN SCOPE**: Don't run entire test suite, just tests that match your changes
- For major UX changes:
    - Create test checklist for affected features only
    - Use browser agent to verify specific functionality
- Code must pass linting and type checks

### On Failure
- **Single test failure**: Fix in CODE phase, re-run the failing test
- **Multiple failures**: Return to PLAN, reassess approach
- **Architectural mismatch**: STOP and ASK user before proceeding
- **After 2 failed cycles**: Present findings and ask for guidance

## 5. FINALIZE

**Goal**: Summarize work and document learnings

### Summary for the User
- What was changed (files + symbols)
- What tests were added/modified
- Any caveats or follow-up items

### Memory Updates
- If you discovered important patterns or conventions, use `write_memory` to save them
- Update existing memories with `edit_memory` if information changed

## Execution Rules

- Use parallel execution for speed (multiple `find_symbol` calls, parallel agents)
- Never exceed task boundaries
- Follow repo standards for tests/docs/components
- Test ONLY what you changed
- Trust Serena tools - no need to verify successful edits

## Priority

Correctness > Completeness > Speed. Each phase must be thorough before proceeding.
