#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${script_dir}/enter_project_directory.sh"

resolve_finished="false"

record_resolve_failure() {
  local exit_code="$?"

  if [[ "${resolve_finished}" != "true" ]]; then
    echo "RESOLVE_STATUS=failed" >> "${GITHUB_ENV}"
  fi

  exit "${exit_code}"
}

trap record_resolve_failure ERR

case "${PACKAGE_MANAGER}" in
  pip|poetry|uv) ;;
  *)
    echo "Unsupported package_manager: ${PACKAGE_MANAGER}" >&2
    exit 1
    ;;
esac

case "${VERSION_MANAGEMENT}" in
  project|git-tag|timestamp|none) ;;
  *)
    echo "Unsupported version_management: ${VERSION_MANAGEMENT}" >&2
    exit 1
    ;;
esac

build_command="${CUSTOM_BUILD_COMMAND}"
if [[ -z "${build_command}" ]]; then
  case "${PACKAGE_MANAGER}" in
    poetry) build_command="poetry build" ;;
    uv) build_command="uv build" ;;
    pip) build_command="python -m build" ;;
  esac
fi

test_command="${CUSTOM_TEST_COMMAND}"
if [[ -z "${test_command}" ]]; then
  test_command="python -m pytest"
fi

lint_command="${CUSTOM_LINT_COMMAND}"
if [[ -z "${lint_command}" ]]; then
  if [[ -f "ruff.toml" ]] || [[ -f ".ruff.toml" ]] || [[ -f "pyproject.toml" ]]; then
    lint_command="ruff check ."
  elif [[ -f ".flake8" ]] || [[ -f "setup.cfg" ]] || [[ -f "tox.ini" ]]; then
    lint_command="flake8 ."
  else
    lint_command="ruff check ."
  fi
fi

package_version=""
if [[ "${VERSION_MANAGEMENT}" == "project" ]]; then
  package_version="$(python "${script_dir}/resolve_version.py")"
elif [[ "${VERSION_MANAGEMENT}" == "git-tag" && "${GITHUB_REF_TYPE:-}" == "tag" ]]; then
  package_version="${GITHUB_REF_NAME#v}"
elif [[ "${VERSION_MANAGEMENT}" == "timestamp" ]]; then
  package_version="$(date -u +%Y.%m.%d.%H%M%S)"
fi

{
  echo "BUILD_COMMAND=${build_command}"
  echo "TEST_COMMAND=${test_command}"
  echo "LINT_COMMAND=${lint_command}"
  echo "PACKAGE_VERSION=${package_version}"
  echo "RELEASE_TAG=v${package_version}"
  echo "CACHE_KEY_PREFIX=${PACKAGE_MANAGER}-py${MATRIX_PYTHON_VERSION:-unknown}"
  echo "CACHE_PATHS<<EOF"
  case "${PACKAGE_MANAGER}" in
    pip)
      echo "${HOME}/.cache/pip"
      ;;
    poetry)
      echo "${HOME}/.cache/pip"
      echo "${HOME}/.cache/pypoetry"
      ;;
    uv)
      echo "${HOME}/.cache/pip"
      echo "${HOME}/.cache/uv"
      ;;
  esac
  echo "EOF"
  echo "RESOLVE_STATUS=success"
} >> "${GITHUB_ENV}"

resolve_finished="true"
trap - ERR
