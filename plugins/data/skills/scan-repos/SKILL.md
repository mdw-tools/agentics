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

The script fetches every repository concurrently and prints one tab-separated line per repository:

```
repo  branch  current  ahead  behind  dirty  error
```

- `repo` — absolute path of the repository
- `branch` — the default branch (the `review.branch` git config, else `main`, else `master`)
- `current` — the checked-out branch (empty when HEAD is detached)
- `ahead` / `behind` — commit counts of `<branch>` relative to `origin/<branch>`
- `dirty` — `dirty` when the working tree has uncommitted changes
- `error` — the first line of any fetch or ref error

Repositories with `git config review.skip true` are left out. Below, refer to each repository by its path relative to the scan root.

## Classify

- **Incoming** — `behind` > 0. These are the repositories to review.
- **Errored** — `error` is not empty.
- Ignore every other repository. Do not report on repositories that are only dirty or only ahead.

If nothing is incoming or errored, say so in one line and stop.

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
9. **Diverged** — `ahead` > 0 and `behind` > 0, which can mean local work or rewritten upstream history

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

For each incoming repository where `current` equals `branch` and `ahead` is 0, run:

```
git -C <repo> pull --ff-only origin <branch>
```

Never pull a repository that is diverged, that has a different branch checked out, or whose HEAD is detached. Do not stash, reset, rebase, or merge to make a pull succeed.

Finish with a `## Pull results` section:

- One line with the number of repositories pulled
- One bullet per incoming repository that was not pulled, with the reason (diverged, on branch `<current>`, detached HEAD, or the first line of the pull error)
