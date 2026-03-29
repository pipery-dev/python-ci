#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${script_dir}/enter_project_directory.sh"

stage_name="${1:?stage name is required}"
command="${2:-}"

if [[ -z "${command}" ]]; then
  echo "No command provided for stage ${stage_name}." >&2
  exit 1
fi

start_time="$(date +%s)"
stage_finished="false"
upper_stage="$(printf '%s' "${stage_name}" | tr '[:lower:]' '[:upper:]')"

record_stage_failure() {
  local exit_code="$?"
  local duration="$(( $(date +%s) - start_time ))"

  if [[ "${stage_finished}" != "true" ]]; then
    echo "${upper_stage}_DURATION=${duration}" >> "${GITHUB_ENV}"
    echo "${upper_stage}_STATUS=failed" >> "${GITHUB_ENV}"
  fi

  exit "${exit_code}"
}

trap record_stage_failure ERR

eval "${command}"
duration="$(( $(date +%s) - start_time ))"

stage_finished="true"
trap - ERR
echo "${upper_stage}_DURATION=${duration}" >> "${GITHUB_ENV}"
echo "${upper_stage}_STATUS=success" >> "${GITHUB_ENV}"
