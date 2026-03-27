#!/usr/bin/env bash
set -euo pipefail

start_time="$(date +%s)"

if [[ -n "${PACKAGE_VERSION}" ]]; then
  export PACKAGE_VERSION
  export SETUPTOOLS_SCM_PRETEND_VERSION="${PACKAGE_VERSION}"
  export POETRY_DYNAMIC_VERSIONING_BYPASS="${PACKAGE_VERSION}"
fi

eval "${BUILD_COMMAND}"

test -d dist

echo "BUILD_DURATION=$(( $(date +%s) - start_time ))" >> "${GITHUB_ENV}"
