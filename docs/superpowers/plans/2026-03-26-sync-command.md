# /sync Command Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a `/sync` project command that copies `commands/`, `agents/`, and `hooks/` from `~/.claude` into the project directory.

**Architecture:** Single markdown command file at `.claude/commands/sync.md` that instructs Claude to run a shell script comparing checksums before/after copy, then reporting a summary.

**Tech Stack:** Shell (`cp`, `find`, `md5`), Claude Code command format

---

### Task 1: Create the /sync command file

**Files:**
- Create: `.claude/commands/sync.md`

- [ ] **Step 1: Create the command file**

Create `.claude/commands/sync.md` with the following content:

```markdown
---
description: Sync commands, agents, and hooks from ~/.claude into this project
---

Sync the following directories from `~/.claude` into this project's root directory:
- `commands/`
- `agents/`
- `hooks/`

**Direction:** `~/.claude` → project (one-way, add/update only — never delete project files).

Run this shell script via the Bash tool to perform the sync:

```bash
#!/bin/bash
set -euo pipefail

SOURCE="$HOME/.claude"
TARGET="$PWD"
DIRS="commands agents hooks"

new=0
updated=0
unchanged=0

for dir in $DIRS; do
  src="$SOURCE/$dir"
  [ -d "$src" ] || continue

  # Find all files in the source directory
  while IFS= read -r rel; do
    src_file="$src/$rel"
    tgt_file="$TARGET/$dir/$rel"

    if [ ! -f "$tgt_file" ]; then
      mkdir -p "$(dirname "$tgt_file")"
      cp "$src_file" "$tgt_file"
      new=$((new + 1))
    elif ! cmp -s "$src_file" "$tgt_file"; then
      cp "$src_file" "$tgt_file"
      updated=$((updated + 1))
    else
      unchanged=$((unchanged + 1))
    fi
  done < <(cd "$src" && find . -type f | sed 's|^\./||')
done

echo "Synced $new new, $updated updated, $unchanged unchanged"
```

After running the script, report the output summary to the user. Do not commit — let the user decide.

Additional user instructions (if any):
"$ARGUMENTS"
```

- [ ] **Step 2: Verify the command file is recognized**

Run: `ls -la .claude/commands/sync.md`
Expected: File exists with the content above.

- [ ] **Step 3: Test the sync command manually**

Run the shell script portion directly via Bash to verify it works:

```bash
set -euo pipefail
SOURCE="$HOME/.claude"
TARGET="$PWD"
DIRS="commands agents hooks"
new=0; updated=0; unchanged=0
for dir in $DIRS; do
  src="$SOURCE/$dir"
  [ -d "$src" ] || continue
  while IFS= read -r rel; do
    src_file="$src/$rel"
    tgt_file="$TARGET/$dir/$rel"
    if [ ! -f "$tgt_file" ]; then
      mkdir -p "$(dirname "$tgt_file")"
      cp "$src_file" "$tgt_file"
      new=$((new + 1))
    elif ! cmp -s "$src_file" "$tgt_file"; then
      cp "$src_file" "$tgt_file"
      updated=$((updated + 1))
    else
      unchanged=$((unchanged + 1))
    fi
  done < <(cd "$src" && find . -type f | sed 's|^\./||')
done
echo "Synced $new new, $updated updated, $unchanged unchanged"
```

Expected: Output like `Synced X new, Y updated, Z unchanged` with files copied into the project.

- [ ] **Step 4: Verify synced files**

Run: `diff <(cd ~/.claude/commands && find . -type f | sort) <(cd commands && find . -type f | sort)`
Expected: No differences (all source files now exist in the project).

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/sync.md
git commit -m "feat: add /sync command to pull config from ~/.claude"
```
