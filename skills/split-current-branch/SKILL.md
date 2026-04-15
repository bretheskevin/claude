---
name: split-current-branch
description: Split the current branch into multiple clean, reviewable stacked branches for easier code review
---

Split the current branch's changes into multiple smaller, logically grouped stacked branches for easier code review.

**CRITICAL: This skill creates branches and commits as part of its core function. Do NOT commit anything beyond what the split requires.**

## Step 1 — Determine the base branch

Use the `AskUserQuestion` tool to ask the user which base branch to compare against:

- **Question**: "Which branch should I compare against?"
- **Header**: "Base branch"
- **Options**:
  1. Label: `origin/trunk` — Description: "Remote trunk (recommended, always up-to-date)"
  2. Label: `trunk` — Description: "Local trunk branch"
- The user can also select "Other" to type a custom branch name.

Wait for the user's answer before proceeding. Store the answer as `BASE_BRANCH`.

## Step 2 — Analyze the current branch

Record the current branch name — this is `ORIGINAL_BRANCH`.

```bash
git rev-parse --abbrev-ref HEAD
```

**IMPORTANT**: Use two-dot diff (`..`) not three-dot (`...`). Three-dot shows changes from the merge base and can include files that are identical between the two branches (already merged from a common ancestor). Two-dot shows the actual delta.

Compute the full diff against the base branch:

```bash
git diff $BASE_BRANCH..HEAD --name-only
git diff $BASE_BRANCH..HEAD --stat
git diff $BASE_BRANCH..HEAD
```

Also save the diff to a file for later verification:

```bash
git diff $BASE_BRANCH..HEAD > /tmp/split-branch-original.diff
```

Review the list of changed files and the actual code changes. Understand:
- Which files were modified, added, or deleted
- The logical grouping of changes (by feature, by layer, by concern)
- Dependencies between changes (e.g., a model change needed by a controller change)

**Beware of truncated paths in `--stat` output.** Always use `--name-only` to get the full file paths.

## Step 3 — Plan the split

Group changes into logical, reviewable units. Each group should:
- Be self-contained and coherent (a reviewer can understand the "why" without seeing other groups)
- Not break the build when applied on top of the previous group
- Follow a logical ordering (e.g., model/schema changes before controller changes, shared utilities before consumers)

Present the plan to the user:

> Here's how I plan to split the branch:
>
> **Branch 1** (`$ORIGINAL_BRANCH-1`): [description]
> - file1.rb
> - file2.rb
>
> **Branch 2** (`$ORIGINAL_BRANCH-2`): [description]
> - file3.ts
> - file4.ts
>
> ... etc.
>
> Does this look good? Should I adjust anything?

Wait for user approval before proceeding. Adjust if the user requests changes.

**There is no limit on the number of branches.** Create as many as needed for clean, understandable reviews.

## Step 4 — Create the stacked branches

**IMPORTANT**: Before creating branches, stash or reset any untracked/modified files that should NOT be included (e.g., local config, skill files). Only the files from `ORIGINAL_BRANCH` that belong to the split should be committed.

For each group (N = 1, 2, 3, ...):

1. If N == 1, create the branch from `BASE_BRANCH`:
   ```bash
   git checkout $BASE_BRANCH
   git checkout -b $ORIGINAL_BRANCH-1
   ```
2. If N > 1, create the branch from the previous branch:
   ```bash
   git checkout $ORIGINAL_BRANCH-$(N-1)
   git checkout -b $ORIGINAL_BRANCH-$N
   ```

3. Cherry-pick or apply the relevant changes for this group. You have several strategies:
   - **If changes map cleanly to commits**: cherry-pick specific commits from `ORIGINAL_BRANCH`
   - **If changes span commits but map to files**: checkout specific files from `ORIGINAL_BRANCH`:
     ```bash
     git checkout $ORIGINAL_BRANCH -- path/to/file1 path/to/file2
     ```
   - **If changes are partial within files**: checkout the file from `ORIGINAL_BRANCH`, then use `git diff` and manual editing to include only the relevant hunks

4. Commit the changes with a clear, descriptive message:
   ```bash
   git add <specific files>
   git commit -m '<descriptive message for this group>'
   ```

5. Repeat for all groups.

## Step 5 — Verify completeness

This is the most critical step. The cumulative diff of all stacked branches MUST exactly match the original branch's diff.

Compare the last branch against the base by checking that every file is identical between `ORIGINAL_BRANCH` and `$ORIGINAL_BRANCH-$LAST_N`:

```bash
# Compare file-by-file content (most reliable method)
for f in $(git diff $BASE_BRANCH..HEAD --name-only); do
  d1=$(git show $ORIGINAL_BRANCH:"$f" 2>/dev/null | md5)
  d2=$(git show $ORIGINAL_BRANCH-$LAST_N:"$f" 2>/dev/null | md5)
  if [ "$d1" != "$d2" ]; then
    echo "DIFFERS: $f"
  fi
done
```

If **no files differ**: the split is correct.

If there are **differences**:
1. Identify which files/hunks are missing
2. Determine which branch they logically belong to
3. If unclear, add them to the **last branch** as a fallback
4. Cherry-pick or apply the missing changes to that branch
5. Re-run the verification until all files match exactly

**Do NOT proceed until verification passes.**

## Step 6 — Push all branches

Push all the new branches to origin:

```bash
git push -u origin $ORIGINAL_BRANCH-1 $ORIGINAL_BRANCH-2 ... $ORIGINAL_BRANCH-$N
```

## Step 7 — Show PR creation links

Generate Bitbucket PR creation links for each branch. Each PR targets the previous branch (stacked PRs), except the first which targets `BASE_BRANCH`:

Display them like this:

> **Pull Requests to create (in order):**
>
> 1. **$ORIGINAL_BRANCH-1** -> `$BASE_BRANCH`: [description]
>    https://bitbucket.org/kipsoftdev/k3/pull-requests/new?source=$ORIGINAL_BRANCH-1&dest=$BASE_BRANCH
>
> 2. **$ORIGINAL_BRANCH-2** -> `$ORIGINAL_BRANCH-1`: [description]
>    https://bitbucket.org/kipsoftdev/k3/pull-requests/new?source=$ORIGINAL_BRANCH-2&dest=$ORIGINAL_BRANCH-1
>
> ... etc.
>
> **Review order**: Review and merge PR #1 first, then #2, etc.

## Step 8 — Return to original branch

```bash
git checkout $ORIGINAL_BRANCH
```

Inform the user the split is complete and remind them of the merge order.

## Important notes

- **Never delete the original branch.** It serves as the source of truth.
- **Never force-push.** All branches are new, so this should never be needed.
- **Preserve the exact diff.** The sum of all split branches must reproduce the original diff exactly — no missing lines, no extra lines.
- If a file has changes that logically belong to multiple groups, split the file's changes across the corresponding branches (partial file changes are acceptable).
- **Do not include unrelated files.** Only commit files that belong to the split. Watch out for staged files from the working tree leaking into commits.

Additional user instructions (if any):
"$ARGUMENTS"
