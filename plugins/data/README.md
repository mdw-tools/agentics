# data

Analysis skills, named after Lt. Commander Data.

## Skills

### scan-branches

Compare two git branches. Summarizes differences and flags concerns (bugs, security, style, inconsistencies). Produces an HTML report in the project's `doc/work-sessions/` directory with semantic `#id` anchors on each finding for easy reference in conversation.

**Usage:**

- `/scan-branches <compare-branch>` — compares the current branch against the specified branch
- `/scan-branches <base-branch> <compare-branch>` — compares two specified branches
