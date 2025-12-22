---
description: Clean Commit (Conventional Commits)
---

Your task is to prepare a clean, production-ready Git commit that strictly follows the Conventional Commits specification.

1. Clean the codebase:
   - Remove all debug statements, logs, commented-out code, temporary hacks, and experiments.
   - Delete unused files and ensure no accidental or sensitive artifacts remain.
   - Ensure formatting, linting, and overall consistency are correct.

2. Stage changes:
   - Stage all relevant changes using:
     `git add .`

3. Propose a commit message following **Conventional Commits**:

   Format:
   <type>(optional scope): <short, imperative summary>
   [optional detailed description]
  
   Rules:
   - Allowed types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`, `ci`, `build`, `style`
   - Summary:
     - Present tense, imperative mood
     - Max ~72 characters
     - No trailing period
   - Description (required for complex commits):
     - Explain **what** changed
     - Explain **why** it changed
     - Mention side effects, risks, or migrations if relevant

4. **Do NOT commit yet.**
- Display the full commit message exactly as it will be used.
- Ask the user to confirm, edit, or cancel.

5. Only after explicit user approval:
- Execute:
  `git commit`  
  (use a body if the commit is complex)

Additional user instructions (if any):
"$ARGUMENTS"
