#!/usr/bin/env bash
#
# Usage: fetch.sh [root]
#
# Finds every git repository under root (default: the current working
# directory) and runs `git fetch` on each one concurrently. Prints a summary
# line, then a fixed-width table of the repositories that are behind their
# upstream, then one line per repository that hit an error (every other
# repository is left out):
#
#   Scanned <root>: <n> repositories, <n> incoming, <n> errored
#
#   BRANCH  CURRENT  AHEAD  BEHIND  DIRTY  REPO
#
#   Errors:
#   <repo>: <error>
#
#   BRANCH   default branch (review.branch config, else main, else master)
#   CURRENT  checked-out branch ("-" when HEAD is detached)
#   AHEAD    commits on <branch> that are not on origin/<branch>
#   BEHIND   commits on origin/<branch> that are not on <branch>
#   DIRTY    "dirty" when the working tree has uncommitted changes, else "-"
#   REPO     path of the repository relative to root
#   error    first line of a fetch or ref error
#
# The table and the error list are each omitted when empty.
#
# Repositories configured with `git config review.skip true` are omitted.

set -u

root="${1:-$PWD}"
if [ ! -d "$root" ]; then
	echo "error: $root is not a directory" >&2
	exit 2
fi
root="$(cd "$root" && pwd -P)"

inspect() {
	local repo="$1" branch current counts ahead behind dirty="" error=""
	cd "$repo" || return
	if [ "$(git config --get review.skip)" = "true" ]; then
		return
	fi
	branch="$(git config --get review.branch)"
	if [ -z "$branch" ]; then
		branch=master
		if git show-ref --quiet --verify refs/heads/main || git show-ref --quiet --verify refs/remotes/origin/main; then
			branch=main
		fi
	fi
	current="$(git symbolic-ref --quiet --short HEAD)"
	if ! error="$(GIT_TERMINAL_PROMPT=0 git fetch --quiet origin </dev/null 2>&1)"; then
		error="fetch: $(printf '%s' "$error" | head -n 1)"
	else
		error=""
	fi
	ahead=0
	behind=0
	if ! git show-ref --quiet --verify "refs/remotes/origin/$branch"; then
		error="${error:-no origin/$branch}"
	elif ! git show-ref --quiet --verify "refs/heads/$branch"; then
		error="${error:-no local $branch}"
	else
		counts="$(git rev-list --left-right --count "$branch...origin/$branch")"
		ahead="${counts%%[[:space:]]*}"
		behind="${counts##*[[:space:]]}"
	fi
	if [ -n "$(git status --porcelain 2>/dev/null | head -n 1)" ]; then
		dirty=dirty
	fi
	# Keep each line short so concurrent writes to the pipe stay atomic.
	error="${error//$'\t'/ }"
	printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$repo" "$branch" "$current" "$ahead" "$behind" "$dirty" "${error:0:200}"
}
export -f inspect

# Print each directory (or symlink to a directory) that contains .git, without
# descending into repositories or symlinks, then resolve symlinks and dedupe.
find "$root" \
	\( -type d -name .git -prune \) -o \
	\( \( -type d -o -type l \) -exec test -e '{}/.git' \; -print -prune \) 2>/dev/null |
	while IFS= read -r path; do
		(cd "$path" && pwd -P)
	done |
	sort -u |
	tr '\n' '\0' |
	xargs -0 -n 1 -P 16 bash -c 'inspect "$1"' _ |
	sort |
	awk -F'\t' -v root="$root" '
		BEGIN {
			prefix = (root == "/") ? "/" : root "/"
			split("BRANCH CURRENT AHEAD BEHIND DIRTY REPO", header, " ")
			for (i = 1; i <= 6; i++) width[i] = length(header[i])
		}
		{
			total++
			if (index($1, prefix) == 1) $1 = substr($1, length(prefix) + 1)
			if ($7 != "") error[++errored] = $1 ": " $7
			if ($5 == 0) next
			incoming++
			split(($2 == "" ? "-" : $2) "\t" ($3 == "" ? "-" : $3) "\t" $4 "\t" $5 "\t" ($6 == "" ? "-" : $6) "\t" $1, values, "\t")
			for (i = 1; i <= 6; i++) {
				cell[incoming, i] = values[i]
				if (length(values[i]) > width[i]) width[i] = length(values[i])
			}
		}
		function emit(values,    i, format) {
			for (i = 1; i <= 6; i++) {
				format = (i == 3 || i == 4) ? "%" width[i] "s  " : "%-" width[i] "s  "
				if (i == 6) format = "%s\n"
				printf format, values[i]
			}
		}
		END {
			printf "Scanned %s: %d repositories, %d incoming, %d errored\n", root, total, incoming, errored
			if (incoming > 0) {
				print ""
				emit(header)
				for (r = 1; r <= incoming; r++) {
					for (i = 1; i <= 6; i++) values[i] = cell[r, i]
					emit(values)
				}
			}
			if (errored > 0) {
				print ""
				print "Errors:"
				for (e = 1; e <= errored; e++) print error[e]
			}
		}
	'
