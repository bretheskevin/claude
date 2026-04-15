---
description: Sync commands, skills, agents, hooks, and statusline from ~/.claude into this project with full diff recap and user approval
---

Compare `~/.claude` against this project's root directory. Show full recap — additions, updates, deletion candidates — then let user approve or modify before applying.

**Scope:**
- Dirs: `commands/`, `skills/`, `agents/`, `hooks/`
- Root files: `statusline-command.sh`

**Direction:** `~/.claude` → project. Deletions are opt-in (files exist in project but not in `~/.claude`).

## Steps

1. Run the dry-run script (below) via Bash. It emits TSV lines: `STATUS\tPATH` where STATUS ∈ {ADD, UPDATE, DELETE, UNCHANGED}.
2. Present a recap to the user grouped by category:
   - **ADD** (N) — list each path
   - **UPDATE** (N) — list each path
   - **DELETE** (N) — list each path (project has these, source does not)
   - **UNCHANGED** (N) — count only
3. Use `AskUserQuestion` to collect decisions:
   - Apply all ADD + UPDATE? (default: yes)
   - Apply DELETE? (default: **no** — opt-in)
   - Any specific paths to exclude from the above?
4. Execute approved ops via direct `cp` (ADD/UPDATE) and `rm` (DELETE). Use `mkdir -p` for new parents. Preserve exec bit (`chmod +x`) when source is executable.
5. After applying, check statusline CLI deps (`jq`). Warn with brew install hint if missing.
6. Do **not** commit.

## Dry-run script

```bash
#!/bin/bash
set -euo pipefail
SOURCE="$HOME/.claude"
TARGET="$PWD"

emit() { printf '%s\t%s\n' "$1" "$2"; }

for dir in commands skills agents hooks; do
  src="$SOURCE/$dir"
  tgt="$TARGET/$dir"

  # Source → target comparison
  if [ -d "$src" ]; then
    while IFS= read -r rel; do
      src_file="$src/$rel"
      tgt_file="$tgt/$rel"
      if [ ! -e "$tgt_file" ]; then
        emit ADD "$dir/$rel"
      elif ! cmp -s "$src_file" "$tgt_file"; then
        emit UPDATE "$dir/$rel"
      else
        emit UNCHANGED "$dir/$rel"
      fi
    done < <(cd "$src" && find . -type f | sed 's|^\./||')
  fi

  # Target-only files (deletion candidates)
  if [ -d "$tgt" ]; then
    while IFS= read -r rel; do
      if [ ! -f "$src/$rel" ]; then
        emit DELETE "$dir/$rel"
      fi
    done < <(cd "$tgt" && find . -type f | sed 's|^\./||')
  fi
done

# Root-level files
for f in statusline-command.sh; do
  src_file="$SOURCE/$f"
  tgt_file="$TARGET/$f"
  [ -f "$src_file" ] || continue
  if [ ! -e "$tgt_file" ]; then
    emit ADD "$f"
  elif ! cmp -s "$src_file" "$tgt_file"; then
    emit UPDATE "$f"
  else
    emit UNCHANGED "$f"
  fi
done
```

## Apply (after user approval)

For each approved path:
- **ADD / UPDATE**: `mkdir -p $(dirname target) && cp source target`. If source is executable: `chmod +x target`.
- **DELETE**: `rm target`.

## Dependency check

After applying:
```bash
command -v jq >/dev/null 2>&1 || echo "Missing: jq — brew install jq"
```

Additional user instructions (if any):
"$ARGUMENTS"
