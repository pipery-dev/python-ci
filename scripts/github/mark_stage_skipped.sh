#!/usr/bin/env bash
set -euo pipefail

stage_name="${1:?stage name is required}"
upper_stage="$(printf '%s' "${stage_name}" | tr '[:lower:]' '[:upper:]')"
echo "${upper_stage}_DURATION=skipped" >> "${GITHUB_ENV}"
