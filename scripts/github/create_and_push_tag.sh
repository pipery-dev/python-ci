#!/usr/bin/env bash
set -euo pipefail

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

for tag in "${RELEASE_TAG}" "${RELEASE_COMMIT_TAG}"; do
  if git rev-parse "${tag}" >/dev/null 2>&1; then
    echo "Tag ${tag} already exists."
  else
    git tag "${tag}"
    git push origin "${tag}"
  fi
done
