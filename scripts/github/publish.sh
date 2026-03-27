#!/usr/bin/env bash
set -euo pipefail

start_time="$(date +%s)"

if [[ -z "${RELEASE_TOKEN}" && ( -z "${RELEASE_USERNAME}" || -z "${RELEASE_PASSWORD}" ) ]]; then
  echo "Release credentials were not provided; skipping publish."
  echo "PUBLISH_DURATION=skipped" >> "${GITHUB_ENV}"
  exit 0
fi

if [[ -n "${RELEASE_TOKEN}" ]]; then
  export TWINE_USERNAME="__token__"
  export TWINE_PASSWORD="${RELEASE_TOKEN}"
else
  export TWINE_USERNAME="${RELEASE_USERNAME}"
  export TWINE_PASSWORD="${RELEASE_PASSWORD}"
fi

if [[ "${RELEASE_REPOSITORY}" =~ ^https?:// ]]; then
  python -m twine upload --repository-url "${RELEASE_REPOSITORY}" dist/*
else
  python -m twine upload -r "${RELEASE_REPOSITORY}" dist/*
fi

echo "PUBLISH_DURATION=$(( $(date +%s) - start_time ))" >> "${GITHUB_ENV}"
