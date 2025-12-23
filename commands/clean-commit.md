---
description: Clean Commit (Conventional Commits + Auto-Ticket)
---

Your task is to prepare a clean, production-ready Git commit that strictly follows the Conventional Commits specification, with automatic ticket extraction from the branch name.

1. Clean the codebase:
    - Remove all debug statements, logs, commented-out code, temporary hacks, and experiments.
    - Delete unused files and ensure no accidental or sensitive artifacts remain.
    - Ensure formatting, linting, and overall consistency are correct.

2. Stage changes:
    - Stage all relevant changes using:
      `git add .`

3. Extract the ticket from the current branch:
    - Get the current branch name: `git rev-parse --abbrev-ref HEAD`
    - If the branch matches the pattern `[A-Z]+-[0-9]+` (e.g., GCO-938), extract it.
    - If no match, proceed without a ticket suffix.

4. Propose a commit message following **Conventional Commits** with ticket:

   Format:
   <type>(optional scope): <short, imperative summary> [TICKET-123]
   [optional detailed description]

   Rules:
    - Allowed types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `ci`, `build`, `style`
    - Summary:
        - Present tense, imperative mood
        - Max ~72 characters (including ticket)
        - No trailing period
        - Ticket appended in brackets at the end (only if detected)
    - Description (required for complex commits):
        - Explain **what** changed
        - Explain **why** it changed
        - Mention side effects, risks, or migrations if relevant

5. Display the full commit message:
    - Show both subject and description exactly as they will be used.

6. Final step:
    - Execute:
      `git commit -am "<message>"`
      (or with `--no-verify` if needed, or use a body if the commit is complex)

Additional user instructions (if any):
"$ARGUMENTS"
