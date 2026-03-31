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
new=0
updated=0
unchanged=0

for dir in commands agents hooks; do
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
