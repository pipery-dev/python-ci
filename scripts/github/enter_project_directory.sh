#!/usr/bin/env bash
set -euo pipefail

project_directory="${PROJECT_DIRECTORY:-.}"

if [[ ! -d "${project_directory}" ]]; then
  echo "Project directory does not exist: ${project_directory}" >&2
  exit 1
fi

cd "${project_directory}"
