---
name: scan-repos
description: Fetch every git repo under the current working directory, summarize the new commits on each default branch, open risky or large changes in smerge, then fast-forward the repos that can be pulled cleanly.
disable-model-invocation: true
---

The user wants a daily digest of upstream changes across all of their local git repositories, followed by a pull of each repository that can be updated safely.

## Fetch

Run the `fetch.sh` script that sits beside this SKILL.md (in this skill's base directory) from the session's current working directory, passing along any path the user gave as an argument:

```
bash <skill-base-directory>/fetch.sh [root]
```

Fetching every repository can take a minute or more, so run the script in the background with its output redirected to a file in the scratchpad directory, then read that file once the script finishes.

With no argument, the script scans the current working directory. If it exits with an error (for example, the given path is not a directory), tell the user what it said and stop.

The script fetches every repository concurrently, then prints a summary line, a fixed-width table of the repositories that are behind their upstream, and a list of the repositories that hit an error. Every other repository is left out. Read its output as-is; do not filter or reformat it with other commands.

```
Scanned <root>: <n> repositories, <n> incoming, <n> errored

BRANCH  CURRENT  AHEAD  BEHIND  DIRTY  REPO
main    main         0       4  -      github.com/acme/widgets

Errors:
github.com/acme/gadgets: fetch: fatal: could not read from remote repository
```

- `BRANCH` — the default branch (the `review.branch` git config, else `main`, else `master`)
- `CURRENT` — the checked-out branch (`-` when HEAD is detached)
- `AHEAD` / `BEHIND` — commit counts of `<branch>` relative to `origin/<branch>`
- `DIRTY` — `dirty` when the working tree has uncommitted changes, else `-`
- `REPO` — path of the repository relative to `<root>` (prefix it with `<root>/` in the commands below)
- `Errors:` — one `<REPO>: <error>` line per repository whose fetch or ref lookup failed; omitted when there are none

Repositories with `git config review.skip true` are left out. Below, `<repo>` in a command means `<root>/<REPO>`; everywhere else, refer to each repository by its `REPO` path.

## Classify

- **Incoming** — each row of the table. These are the repositories to review.
- **Errored** — each line under `Errors:`.

If the summary line reports nothing incoming or errored, say so in one line and stop.

## Review each incoming repository

For each incoming repository, gather:

```
git -C <repo> log --format='%h %an %s' <branch>..origin/<branch>
git -C <repo> diff --shortstat <branch>...origin/<branch>
git -C <repo> diff --stat <branch>...origin/<branch>
```

Then read the diff itself, leaving out vendored and lock files:

```
git -C <repo> diff <branch>...origin/<branch> -- . ':(exclude)vendor/**' ':(exclude)go.sum' ':(exclude)*.lock' ':(exclude)package-lock.json'
```

If the shortstat reports more than about 2000 changed lines, do not read the whole diff. Work from the log and stat, and read only the files that look most consequential (`git diff <branch>...origin/<branch> -- <file>`).

If more than 5 repositories are incoming, review them in parallel with one subagent per repository. Give each subagent the commands above, the flag criteria below, and ask it to return only the summary and the flag verdict with its reasons.

Take the position of an unbiased reviewer. Do not gather context from previous sessions or conversations.

### Flag criteria

Flag a repository for human review when any of the following is true:

1. **Large** — more than 500 changed lines (excluding vendored and lock files), more than 25 files, or more than 20 commits
2. **Security-sensitive** — authentication, authorization, cryptography, secrets handling, or input validation changed
3. **Secrets** — credentials, tokens, or private keys appear to be committed
4. **Dependencies** — new dependencies, removed dependencies, or major-version bumps
5. **Build or deploy** — CI/CD pipelines, Dockerfiles, infrastructure, or release configuration changed
6. **Data** — database migrations or schema changes
7. **Breaking** — exported/public APIs removed or changed incompatibly
8. **Suspected bug** — something in the diff looks wrong
9. **Diverged** — `AHEAD` > 0 and `BEHIND` > 0, which can mean local work or rewritten upstream history

Do not flag a repository for nits or style.

## Report

Emit the report in the conversation. Do not write a document.

### Flagged

A heading `## Flagged for review (<n>)`, then for each flagged repository:

- A `### <repo>` heading followed by the commit count, file count, and `+<added>/-<deleted>` lines
- Two to five bullets summarizing what changed
- A **Why flagged** line naming the criteria that applied and the specific files or commits involved

### Routine

A heading `## Routine (<n>)`, then one bullet per unflagged incoming repository: `**<repo>** (<commits> commits, +<added>/-<deleted>): <one-sentence summary>`.

### Errors

A heading `## Errors (<n>)`, then one bullet per errored repository with its error. Omit this section when there are none.

## Open flagged repositories

For each flagged repository, run:

```
smerge <repo>
```

## Pull

For each incoming repository where `CURRENT` equals `BRANCH` and `AHEAD` is 0, run:

```
git -C <repo> pull --ff-only origin <branch>
```

Never pull a repository that is diverged, that has a different branch checked out, or whose HEAD is detached. Do not stash, reset, rebase, or merge to make a pull succeed.

Finish with a `## Pull results` section:

- One line with the number of repositories pulled
- One bullet per incoming repository that was not pulled, with the reason (diverged, on branch `<CURRENT>`, detached HEAD, or the first line of the pull error)
