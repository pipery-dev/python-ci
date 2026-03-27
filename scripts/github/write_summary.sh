#!/usr/bin/env bash
set -euo pipefail

{
  echo "## Python CI summary"
  echo
  echo "| Key | Value |"
  echo "| --- | --- |"
  echo "| Python version | ${PYTHON_VERSION:-${MATRIX_PYTHON_VERSION:-unknown}} |"
  echo "| Package manager | ${PACKAGE_MANAGER} |"
  echo "| Version management | ${VERSION_MANAGEMENT} |"
  echo "| Build command | \`${BUILD_COMMAND}\` |"
  echo "| Test command | \`${TEST_COMMAND}\` |"
  echo "| Lint command | \`${LINT_COMMAND}\` |"
  echo "| Artifact | ${ARTIFACT_NAME}-py${MATRIX_PYTHON_VERSION:-unknown} |"
  echo "| Release repository | ${RELEASE_REPOSITORY:-not configured} |"
  echo "| Release tag | ${RELEASE_TAG:-not resolved} |"
  echo "| Resolved package version | ${PACKAGE_VERSION:-not resolved} |"
  echo
  echo "### Stage durations"
  echo
  echo "| Stage | Duration |"
  echo "| --- | --- |"
  echo "| Setup | ${SETUP_DURATION:-not recorded}s |"
  echo "| Build | ${BUILD_DURATION:-not recorded}s |"
  echo "| Tag | ${TAG_DURATION:-not recorded} |"
  echo "| Test | ${TEST_DURATION:-not recorded} |"
  echo "| Lint | ${LINT_DURATION:-not recorded} |"
  echo "| Publish | ${PUBLISH_DURATION:-not recorded} |"
} >> "${GITHUB_STEP_SUMMARY}"
