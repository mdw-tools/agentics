---
name: scan-branches
description: Compare two git branches. Summarizes differences and flags numbered concerns (bugs, security, inconsistencies).
---

The user wants to compare two git branches.

## Parse arguments

- If **one** branch name is provided, use the current branch (`git branch --show-current`) as the **base** and the provided branch as the **compare** branch.
- If **two** branch names are provided, the first is the **base** and the second is the **compare** branch.
- If **no** branch names are provided:
  - If the current branch is `main` or `master`, or HEAD is detached, ask the user which branches to compare.
  - Otherwise, use `main` as the **base** (or `master` if `main` does not exist) and the current branch as the **compare** branch. If neither exists, ask the user.

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

### Major and minor issues

An issue that is low priority, merely stylistic, or a nit is a **minor** issue. Every other issue is a **major** issue.

### Numbering

Number every issue so that the user can reference it in conversation (e.g. "issue 3"). Use one continuous sequence: number the major issues first, then continue the sequence with the minor issues. Use the same numbers in the document and in the conversation. Show each number visibly next to its issue.

### Minor issues

Always list the minor issues in the conversation (see **Minor issues listing** below). Leave them out of the document entirely: do not list them, count them, or mention that they were omitted. Include them in the document only if the user invoking the skill explicitly requests them.

## No major issues

If there are no major issues, do **not** write a document. Instead, emit the summary of changes directly in the conversation, state that no major issues were found, then emit the **Minor issues listing**. Skip the **Output document** and **Design** sections.

## Output document

When there is at least one major issue to report, determine the git repo root (use `git rev-parse --show-toplevel`), then write the review to:

```
<git-repo-root>/doc/work-sessions/<yyyy>/<yyyy-mm-dd_hh-mm-ss>-branch-scan-<base>-vs-<compare>.html
```

- `<yyyy>` — the current four-digit year
- `<yyyy-mm-dd_hh-mm-ss>` — run `date '+%Y-%m-%d_%H-%M-%S'` to get the current date and time
- `<base>` and `<compare>` — the branch names

## Design

Design the document for **light mode** (dark text on a light background) unless the user invoking the skill specifies otherwise.

Tell the user where the file was written. Emit the full path on its own line, then emit a `file://` URL on the next line.

## Minor issues listing

After telling the user where the file was written, emit a `## Minor issues` heading in the conversation, followed by one bullet per minor issue: its number, its location (`file:line`), and a one-sentence description. If there are no minor issues, state that in one line instead.
