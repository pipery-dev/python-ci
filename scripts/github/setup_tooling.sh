#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/enter_project_directory.sh"

start_time="$(date +%s)"
stage_finished="false"

record_setup_failure() {
  local exit_code="$?"
  local duration="$(( $(date +%s) - start_time ))"

  if [[ "${stage_finished}" != "true" ]]; then
    echo "SETUP_DURATION=${duration}" >> "${GITHUB_ENV}"
    echo "SETUP_STATUS=failed" >> "${GITHUB_ENV}"
  fi

  exit "${exit_code}"
}

trap record_setup_failure ERR

python -m pip install --upgrade pip setuptools wheel

case "${PACKAGE_MANAGER}" in
  pip)
    python -m pip install build twine
    if [[ -f "requirements.txt" ]]; then
      python -m pip install -r requirements.txt
    fi
    if [[ -f "requirements-dev.txt" ]]; then
      python -m pip install -r requirements-dev.txt
    fi
    if [[ -f "pyproject.toml" || -f "setup.cfg" || -f "setup.py" ]]; then
      python -m pip install -e .
    fi
    if [[ "${TESTS_ENABLED}" == "true" && -z "${CUSTOM_TEST_COMMAND}" ]]; then
      python -m pip install pytest
    fi
    if [[ "${LINT_ENABLED}" == "true" && -z "${CUSTOM_LINT_COMMAND}" ]]; then
      python -m pip install ruff flake8
    fi
    ;;
  poetry)
    python -m pip install poetry twine
    poetry config virtualenvs.create false
    poetry install --no-interaction --with dev || poetry install --no-interaction
    ;;
  uv)
    python -m pip install uv twine
    uv sync --all-extras --dev || uv sync
    ;;
esac

stage_finished="true"
trap - ERR
echo "SETUP_DURATION=$(( $(date +%s) - start_time ))" >> "${GITHUB_ENV}"
echo "SETUP_STATUS=success" >> "${GITHUB_ENV}"
