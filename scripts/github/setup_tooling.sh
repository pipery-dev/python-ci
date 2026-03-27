#!/usr/bin/env bash
set -euo pipefail

start_time="$(date +%s)"

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
    if [[ -f "pyproject.toml" ]]; then
      python -m pip install -e . || true
    fi
    if [[ "${TESTS_ENABLED}" == "true" && -z "${CUSTOM_TEST_COMMAND}" ]]; then
      python -m pip install pytest || true
    fi
    if [[ "${LINT_ENABLED}" == "true" && -z "${CUSTOM_LINT_COMMAND}" ]]; then
      python -m pip install ruff flake8 || true
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

echo "SETUP_DURATION=$(( $(date +%s) - start_time ))" >> "${GITHUB_ENV}"
