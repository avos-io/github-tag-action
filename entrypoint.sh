#!/bin/bash

set -eo pipefail

git config --global --add safe.directory /github/workspace

default_bump="patch"
bump=${BUMP:-$default_bump}

setOutput() {
    echo "${1}=${2}" >> "${GITHUB_OUTPUT}"
}

# this fetch is useful for debugging
git fetch --tags

# Make sure you have the latest changes on the branch.
# Needed for the make-release job which pushes a new commit before this.
# A bit hacky - we'd rather pass in a optional commit hash to tag.
git pull

tagFmt="^v?[0-9]+\.[0-9]+\.[0-9]+$"

git_refs=$(git tag --list --merged HEAD --sort=-committerdate)
matching_tag_refs=$( (grep -E "$tagFmt" <<< "$git_refs") || true)

last_tag=$(head -n 1 <<< "$matching_tag_refs")
last_tag_commit=$(git rev-list -n 1 "$last_tag" || true )
current_commit=$(git rev-parse HEAD)

# skip if there are no new commits for non-pre_release
if [ "$last_tag_commit" == "$current_commit" ]
then
    echo "No new commits since previous tag. Skipping..."
    setOutput "new_tag" "$last_tag"
    setOutput "last_tag" "$last_tag"
    exit 0
fi

# semver accepts "v" prefix, but outputs version without "v" prefix
new_tag=$(semver -i "$bump" "$last_tag")
new_tag="v$new_tag"

setOutput "new_tag" "$new_tag"
setOutput "last_tag" "$last_tag"
setOutput "part" "$bump"

git tag "$new_tag" || exit 1
git push origin "$new_tag" || exit 1