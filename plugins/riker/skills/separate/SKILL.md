---
name: separate
description: Split a branch with many changes into a sequence of smaller branches that build on each other, suitable for stacked pull requests.
---

The user wants to split a branch with many changes into multiple, sequenced branches. Each new branch builds on the one before it. The sequence can then be submitted as stacked pull requests.

## Parse arguments

- If **no** branch name is provided, split the current branch (`git branch --show-current`) against the inferred base branch.
- If **one** branch name is provided, use it as the **base** and split the current branch.
- If **two** branch names are provided, the first is the **base** and the second is the **branch to split**.
- Treat any other words as grouping guidance (for example, a desired number of parts, or which changes belong together). Honor this guidance in the plan.

To infer the base branch, run `git symbolic-ref refs/remotes/origin/HEAD` and take the last path segment. If that fails, try `main`, then `master`. If none resolves, ask the user.

## Validate

- Confirm each branch exists with `git rev-parse --verify <branch>`. If a branch does not exist, tell the user and stop.
- Require a clean working tree (`git status --porcelain` emits nothing). If the tree is dirty, tell the user and stop.
- Record the branch the user is on now. Return to it when the work is done.

## Safety rules

- Never modify the branch being split. It stays intact as the reference.
- Never push, never delete branches, and never force any git operation.
- If a planned branch name already exists, stop and ask the user before you continue.

## Study the changes

Run all of the following:

```
git log --oneline <base>...<branch>
git diff --stat <base>...<branch>
git diff <base>...<branch>
```

This task is not a review. You must understand **every** change to partition the diff safely. If the diff is too large to read at once, read it file by file. Do not skim.

## Plan the separation

Partition the full set of changes into stages — usually 2 to 5. Each stage must:

- compile and pass tests on its own
- be safe to deploy on its own
- be a reviewable size

Order the stages with these heuristics:

- Put preparatory refactors and mechanical changes first.
- Put new code that nothing calls yet ("dark" code) early. It is safe to deploy.
- Put behavior changes, wiring, and switch-flips last.

Choose one of two strategies:

- **Cherry-pick**: when the existing commits map cleanly onto stages, plan each stage as an ordered list of commits.
- **Diff partition**: when the commits are tangled, plan each stage as a set of files (or hunks within files) taken from the final diff.

Name the branches `<branch>-1-<desc>`, `<branch>-2-<desc>`, and so on, where `<desc>` is a short, hyphen-separated description of the stage.

## Present the plan and wait

Present the plan in chat as a table with fixed-width columns: stage number, branch name, contents, and why the stage is safe to deploy. State the chosen strategy and the verification you will run.

**Do not create any branches until the user approves the plan.** The user may adjust the groupings, the order, the number of stages, or the branch names. Apply the feedback and present the plan again. Repeat until the user approves.

## Execute

For each stage *n*, in order:

1. Create the stage branch from the previous stage branch. Create stage 1 from the base branch.
2. Apply the stage's changes:
   - **Cherry-pick**: run `git cherry-pick <commits>` for the planned commits.
   - **Diff partition**: for whole files, run `git checkout <branch> -- <paths>`. For partial files, build and apply a filtered patch. Then commit with a message that follows the rules below.
3. If the project has a test command (for example, `make test`), run it on the new branch. If the tests fail, stop. Report the failure and propose a regrouping. Do not continue past a failing stage.

### Commit messages

A stage commit often combines the work of several original commits. The new commit must keep all important information from those original commits. Read the full message of each original commit with `git log --format=full <base>...<branch>` before you write the new messages.

- Start the subject line with a clear description of the stage.
- In the body, carry forward from the original commits:
  - the reasoning and context ("why") recorded in commit bodies
  - references to tickets, issues, and pull requests
  - trailers such as `Co-authored-by:`, `Fixes:`, and `Breaking-change:` notes
- Do not invent information. Omit an item only when no original commit contains it.

## Verify

The tree of the final stage branch must equal the tree of the branch being split. Run:

```
git diff <branch> <final-stage-branch>
```

The output must be empty. If it is not, find the missing changes, add them to the correct stage, and verify again.

When verification passes, return to the branch the user started on.

## Report

Summarize the result in chat:

- List the branches in order. State what each contains and its test result.
- Explain the stacked PR sequence: the PR for stage 1 targets the base branch; the PR for stage *n* targets the branch for stage *n−1*.
- Note the maintenance rule: after the PR for stage *n* merges, retarget the PR for stage *n+1* to the base branch. If a lower branch changes during review, rebase each branch above it, in order.

### Output document

Also write a separation report as an HTML file. Determine the git repo root (use `git rev-parse --show-toplevel`), then write to:

```
<git-repo-root>/doc/work-sessions/<yyyy>/<yyyy-mm-dd_hh-mm-ss>-separation-<terse-description>.html
```

- `<yyyy>` — the current four-digit year
- `<yyyy-mm-dd_hh-mm-ss>` — run `date '+%Y-%m-%d_%H-%M-%S'` to get the current date and time
- `<terse-description>` — a short, hyphen-separated description of the branch that was split

The report records the stages, the contents of each, the reasoning behind the grouping, and the stacked PR instructions.

### Design

Design the document for **light mode** (dark text on a light background) unless the user invoking the skill specifies otherwise.

Tell the user where the file was written. Emit the full path on its own line, then emit a `file://` URL on the next line.
