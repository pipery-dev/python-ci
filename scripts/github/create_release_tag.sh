#!/usr/bin/env bash
set -euo pipefail

start_time="$(date +%s)"

git config --global --add safe.directory "${GITHUB_WORKSPACE}"
git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

git fetch --tags origin

if git rev-parse "${RELEASE_TAG}" >/dev/null 2>&1; then
  echo "Release tag ${RELEASE_TAG} already exists."
else
  git tag "${RELEASE_TAG}"
  git push origin "${RELEASE_TAG}"
fi

echo "TAG_DURATION=$(( $(date +%s) - start_time ))" >> "${GITHUB_ENV}"
echo "TAG_STATUS=success" >> "${GITHUB_ENV}"
