---
name: scan-branches
description: Compare two git branches. Summarizes differences and flags numbered concerns (bugs, security, inconsistencies).
---

The user wants to compare two git branches.

## Parse arguments

- If **one** branch name is provided, use the current branch (`git branch --show-current`) as the **base** and the provided branch as the **compare** branch.
- If **two** branch names are provided, the first is the **base** and the second is the **compare** branch.
- If no branch name is provided, ask the user which branch to compare against.

## Validate

Confirm both branches exist using `git rev-parse --verify <branch>`. If either branch does not exist, tell the user and stop.

## Gather the diff

Run both of the following:

```
git log --oneline <base>...<compare>
git diff <base>...<compare>
```

This uses the three-dot (merge-base) form, which shows changes on the compare branch since it diverged from the base.

## Handle large diffs

If the diff output is very large, do not attempt to review every line. Instead, focus on a high-level summary: which files changed, what kinds of changes were made (new features, refactors, deletions, config changes, etc.), and call out only the most important concerns.

## Summarize

Review the differences between the two branches. Summarize the changes and flag any concerns (bugs, security, inconsistencies). Do NOT try to gather context about the changes from previous sessions/conversations. Take the position of an unbiased reviewer.

### Numbering

Number every issue in the document so that the user can reference it in conversation (e.g. "issue 3"). Use one continuous sequence across the whole document, even when issues appear under different headings. Show each number visibly next to its issue.

### Omissions

Completely disregard any issue that is low priority, merely stylistic, or a nit. Omit these issues from the document entirely: do not list them, count them, or mention that they were omitted. Include them only if the user invoking the skill explicitly requests them.

## Output document

Determine the git repo root (use `git rev-parse --show-toplevel`), then write the review to:

```
<git-repo-root>/doc/work-sessions/<yyyy>/<yyyy-mm-dd_hh-mm-ss>-branch-scan-<base>-vs-<compare>.html
```

- `<yyyy>` — the current four-digit year
- `<yyyy-mm-dd_hh-mm-ss>` — run `date '+%Y-%m-%d_%H-%M-%S'` to get the current date and time
- `<base>` and `<compare>` — the branch names

## Design

Design the document for **light mode** (dark text on a light background) unless the user invoking the skill specifies otherwise.

Tell the user where the file was written. Emit the full path on its own line, then emit a `file://` URL on the next line.
