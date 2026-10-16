---
name: scan-repos
description: Fetch every git repo under the current working directory, summarize the new commits on each default branch in a markdown checklist the user marks up in $EDITOR, open the marked repos (and every repo with uncommitted changes or unpushed commits) in smerge, then fast-forward the unmarked repos that can be pulled cleanly.
disable-model-invocation: true
---

The user wants a daily digest of upstream changes across all of their local git repositories, followed by a pull of each repository that can be updated safely, and a reminder (via smerge) of every repository holding work that has not been committed or pushed.

## Fetch

Run the `fetch.sh` script that sits beside this SKILL.md (in this skill's base directory) from the session's current working directory, passing along any path the user gave as an argument:

```
bash <skill-base-directory>/fetch.sh [root]
```

Fetching every repository can take a minute or more, so run the script in the background with its output redirected to a file in the scratchpad directory, then read that file once the script finishes.

With no argument, the script scans the current working directory. If it exits with an error (for example, the given path is not a directory), tell the user what it said and stop.

The script fetches every repository concurrently, then prints a summary line, a fixed-width table of the repositories that are behind their upstream or that hold local work, and a list of the repositories that hit an error. Every other repository is left out. Read its output as-is; do not filter or reformat it with other commands.

```
Scanned <root>: <n> repositories, <n> incoming, <n> local, <n> errored

BRANCH  CURRENT  AHEAD  BEHIND  UNPUSHED  DIRTY  REPO
main    main         0       4         0  -      github.com/acme/widgets
main    feature      0       0         3  dirty  github.com/acme/sprockets

Errors:
github.com/acme/gadgets: fetch: fatal: could not read from remote repository
```

- `BRANCH` — the default branch (the `review.branch` git config, else `main`, else `master`)
- `CURRENT` — the checked-out branch (`-` when HEAD is detached)
- `AHEAD` / `BEHIND` — commit counts of `<branch>` relative to `origin/<branch>`
- `UNPUSHED` — commits on any local branch that are not on any remote branch
- `DIRTY` — `dirty` when the working tree has uncommitted changes, else `-`
- `REPO` — path of the repository relative to `<root>` (prefix it with `<root>/` in the commands below)
- `Errors:` — one `<REPO>: <error>` line per repository whose fetch or ref lookup failed; omitted when there are none

Repositories with `git config review.skip true` are left out. Below, `<repo>` in a command means `<root>/<REPO>`; everywhere else, refer to each repository by its `REPO` path.

## Classify

- **Incoming** — each row of the table whose `BEHIND` > 0. These are the repositories to review.
- **Local** — each row of the table whose `UNPUSHED` > 0 or whose `DIRTY` is `dirty`. These are always opened in smerge, whether or not the user selects them.
- **Errored** — each line under `Errors:`.

A repository can be both incoming and local; it then goes through the review and pull steps like any other incoming repository, and is also opened in smerge.

If the summary line reports nothing incoming, local, or errored, say so in one line and stop.

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

If more than 5 repositories are incoming, review them in parallel with one subagent per repository. Give each subagent the commands above, the flag criteria below, and ask it to return only one to five bullets summarizing the changes and the flag verdict with its reasons.

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

If nothing is incoming, skip the file and the editor: emit the errors section below in the conversation (when any repositories errored), then go straight to [Open in smerge](#open-in-smerge) and stop after it.

Otherwise, write the report to a markdown file named `scan-repos-<yyyy-mm-dd_hh-mm-ss>.md` in the session's scratchpad directory (or in `$TMPDIR` when there is none). Do not emit the report in the conversation.

Begin the file with this comment line, followed by a blank line:

```
<!-- Mark [x] beside each repository to review in smerge, then save and close. Unmarked repositories are pulled automatically. ">>>" marks the ones flagged for review. -->
```

Then list every incoming repository as a bulleted outline: a top-level bullet with an empty checkbox (`- [] `, with no space between the brackets, so that marking it takes a single inserted `x`) and its `REPO` path, and beneath it one to five nested bullets that each summarize one change. Leave every checkbox empty; the user decides which repositories to review. Prefix the `REPO` path of each flagged repository with `>>> `. Put the flagged repositories first, then a `---` separator, then the unflagged repositories. For each flagged repository, end its nested bullets with a `Flagged:` bullet naming the criteria that applied and the specific files or commits involved.

```
<!-- Mark [x] beside each repository to review in smerge, then save and close. Unmarked repositories are pulled automatically. ">>>" marks the ones flagged for review. -->

- [] >>> github.com/acme/widgets
  - Replace the session token check with JWT validation
  - Add a migration that drops the legacy_users table
  - Flagged: security-sensitive (auth/jwt.go), data (migrations/0042_drop_legacy_users.sql)

---

- [] github.com/acme/gadgets
  - Fix an off-by-one in pagination

- [] github.com/acme/gizmos
  - Bump the Go toolchain to 1.25
  - Rename the internal retry helper
```

Put a blank line before each repository's top-level bullet, and before and after the separator. Omit the separator when either group is empty.

### Errors

After the outline, a heading `## Errors (<n>)`, then one plain bullet (no checkbox) per errored repository with its error. Omit this section when there are none.

## Choose repositories to review

Tell the user, in one line, that the checklist is open for review and give the file's absolute path. Then open the file in the user's editor:

```
$EDITOR <file>
```

Leave `$EDITOR` unquoted so an editor command with arguments (such as `subl --wait`) splits correctly. Run it in the background, because the user may keep the file open for longer than a foreground command is allowed to run, and wait for it to exit before going on. Do not poll the file while waiting, and do not pull any repository before the user has made their selection: changes are easier to review in smerge before they land on the local branch.

If `$EDITOR` is unset, or names a terminal editor (such as `vi`, `vim`, `nvim`, `nano`, or `emacs` without `-c`) that cannot run without a terminal, do not run it. Instead, give the user the file's absolute path and ask them to reply once they have marked and saved it.

Once the editor exits (or the user replies), read the file. A repository is selected when its top-level line begins with `- [x] ` or `- [X] `. Take the rest of the line, drop a leading `>>> `, and trim surrounding whitespace to get its `REPO` path. Ignore every other line, including the nested bullets and the errors section. If a selected path does not match an incoming repository, skip it and mention it in the conversation.

## Open in smerge

For each selected repository, and for each local repository (selected or not), run once:

```
smerge <repo>
```

Then list the opened repositories in the conversation under a `## Opened in smerge` heading, one bullet per repository with the reason it was opened: `selected`, and/or the local work it holds (`dirty`, `<n> unpushed`). Say in one line that none were opened when there were none.

## Pull

Leave every selected repository unpulled; the user pulls it from smerge after reviewing it.

For each incoming repository that was not selected, where `CURRENT` equals `BRANCH` and `AHEAD` is 0, run:

```
git -C <repo> pull --ff-only origin <branch>
```

Never pull a repository that is diverged, that has a different branch checked out, or whose HEAD is detached. Do not stash, reset, rebase, or merge to make a pull succeed.

Finish with a `## Pull results` section:

- One line with the number of repositories pulled
- One bullet per unselected incoming repository that was not pulled, with the reason (diverged, on branch `<CURRENT>`, detached HEAD, or the first line of the pull error)
