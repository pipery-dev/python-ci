#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${PACKAGE_VERSION}" ]]; then
  echo "Release flow requires a resolved package version, but PACKAGE_VERSION is empty." >&2
  exit 1
fi

if [[ "${GITHUB_REF_TYPE:-}" == "tag" && "${GITHUB_REF_NAME:-}" != "${RELEASE_TAG}" ]]; then
  echo "Release tag ${GITHUB_REF_NAME} does not match resolved version tag ${RELEASE_TAG}." >&2
  exit 1
fi
