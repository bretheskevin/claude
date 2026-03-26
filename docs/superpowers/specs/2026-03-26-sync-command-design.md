# /sync Command Design

## Purpose

Pull `commands/`, `agents/`, and `hooks/` from `~/.claude` into the project directory so changes can be tracked in git.

## Behavior

- **Direction**: `~/.claude` → project (one-way)
- **Scope**: Three directories only: `commands/`, `agents/`, `hooks/`
- **Additions/Updates**: Files are copied, overwriting existing content
- **Deletions**: Not performed — files in the project that no longer exist in `~/.claude` are left untouched
- **Output**: Minimal one-line summary: `"Synced X new, Y updated, Z unchanged"`

## Implementation

A project command file at `.claude/commands/sync.md` containing a prompt that instructs Claude to run a shell script via the Bash tool.

### Shell Script Logic

1. **Snapshot before**: For each of the three directories, collect a list of files with checksums (`find` + `md5`) in the project
2. **Copy**: `cp -r ~/.claude/{commands,agents,hooks}/ .` overwriting existing files, creating directories as needed
3. **Snapshot after**: Collect file list with checksums again
4. **Compare**: Classify each file as:
   - **New**: present in "after" but not "before"
   - **Updated**: present in both but checksum differs
   - **Unchanged**: present in both with same checksum
5. **Report**: Print `"Synced X new, Y updated, Z unchanged"`

### Constraints

- Native shell commands only (`cp`, `find`, `md5`, `diff`, `mkdir`)
- No `rsync`, no external dependencies
- No deletions of project files
- Operates relative to the project root directory
