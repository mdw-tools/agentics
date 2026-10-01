# data

Analysis skills, named after Lt. Commander Data.

## Skills

### scan-branches

Compare two git branches. Summarizes differences and flags concerns (bugs, security, style, inconsistencies). Produces an HTML report in the project's `doc/work-sessions/` directory with semantic `#id` anchors on each finding for easy reference in conversation. Low-priority, stylistic, and nit issues are always listed in the conversation but are left out of the report unless explicitly requested. When there are no other issues to report, the summary is emitted in the conversation instead and no report file is written.

**Usage:**

- `/scan-branches <compare-branch>` — compares the current branch against the specified branch
- `/scan-branches <base-branch> <compare-branch>` — compares two specified branches

### scan-repos

Daily digest of upstream changes across every git repository under the session's current working directory. Fetches all repositories concurrently, summarizes the new commits on each default branch, flags large or risky changes (security, secrets, dependencies, build/deploy, migrations, breaking API changes, suspected bugs, diverged history) and opens those repositories in Sublime Merge (`smerge`), then fast-forwards each repository that has its default branch checked out and no local commits. The report is emitted in the conversation; no file is written.

Per-repository git config (shared with the `gitreview` tool):

- `git config review.skip true` — leave the repository out of the scan
- `git config review.branch <name>` — override default-branch detection (otherwise `main`, else `master`)

**Usage:**

- `/scan-repos` — scans the current working directory
- `/scan-repos <path>` — scans the given directory instead
