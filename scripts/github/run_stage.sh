#!/usr/bin/env bash
set -euo pipefail

stage_name="${1:?stage name is required}"
command="${2:-}"

if [[ -z "${command}" ]]; then
  echo "No command provided for stage ${stage_name}." >&2
  exit 1
fi

start_time="$(date +%s)"
eval "${command}"
duration="$(( $(date +%s) - start_time ))"

upper_stage="$(printf '%s' "${stage_name}" | tr '[:lower:]' '[:upper:]')"
echo "${upper_stage}_DURATION=${duration}" >> "${GITHUB_ENV}"
