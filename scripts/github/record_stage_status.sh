#!/usr/bin/env bash
set -euo pipefail

stage_name="${1:?stage name is required}"
stage_status="${2:?stage status is required}"
upper_stage="$(printf '%s' "${stage_name}" | tr '[:lower:]' '[:upper:]')"

echo "${upper_stage}_STATUS=${stage_status}" >> "${GITHUB_ENV}"
