#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${script_dir}/enter_project_directory.sh"

start_time="$(date +%s)"
stage_finished="false"

record_build_failure() {
  local exit_code="$?"
  local duration="$(( $(date +%s) - start_time ))"

  if [[ "${stage_finished}" != "true" ]]; then
    echo "BUILD_DURATION=${duration}" >> "${GITHUB_ENV}"
    echo "BUILD_STATUS=failed" >> "${GITHUB_ENV}"
  fi

  exit "${exit_code}"
}

trap record_build_failure ERR

if [[ -n "${PACKAGE_VERSION}" ]]; then
  export PACKAGE_VERSION
  export SETUPTOOLS_SCM_PRETEND_VERSION="${PACKAGE_VERSION}"
  export POETRY_DYNAMIC_VERSIONING_BYPASS="${PACKAGE_VERSION}"
fi

eval "${BUILD_COMMAND}"

test -d dist

stage_finished="true"
trap - ERR
echo "BUILD_DURATION=$(( $(date +%s) - start_time ))" >> "${GITHUB_ENV}"
echo "BUILD_STATUS=success" >> "${GITHUB_ENV}"
