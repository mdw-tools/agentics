#!/usr/bin/env bash
#
# Usage: fetch.sh [root]
#
# Finds every git repository under root (default: the current working
# directory), runs `git fetch` on each one concurrently, and prints one
# tab-separated line per repository:
#
#   repo  branch  current  ahead  behind  dirty  error
#
#   repo     absolute path of the repository
#   branch   default branch (review.branch config, else main, else master)
#   current  checked-out branch (empty when HEAD is detached)
#   ahead    commits on <branch> that are not on origin/<branch>
#   behind   commits on origin/<branch> that are not on <branch>
#   dirty    "dirty" when the working tree has uncommitted changes
#   error    first line of any error (empty on success)
#
# Repositories configured with `git config review.skip true` are omitted.

set -u

root="${1:-$PWD}"
if [ ! -d "$root" ]; then
	echo "error: $root is not a directory" >&2
	exit 2
fi

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
	sort
