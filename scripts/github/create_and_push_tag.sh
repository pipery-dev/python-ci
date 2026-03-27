#!/usr/bin/env bash
set -euo pipefail

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

if git rev-parse "${RELEASE_TAG}" >/dev/null 2>&1; then
  echo "Tag ${RELEASE_TAG} already exists."
else
  git tag "${RELEASE_TAG}"
  git push origin "${RELEASE_TAG}"
fi
