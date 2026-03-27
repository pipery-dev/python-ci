#!/usr/bin/env bash
set -euo pipefail

{
  echo "## Workflow Release"
  echo
  echo "| Key | Value |"
  echo "| --- | --- |"
  echo "| Version | ${RELEASE_VERSION_NORMALIZED:-not set} |"
  echo "| Tag | ${RELEASE_TAG:-not set} |"
  echo "| Commit tag | ${RELEASE_COMMIT_TAG:-not set} |"
  echo "| Commit short hash | ${RELEASE_COMMIT_SHORT_HASH:-not set} |"
  echo "| Target | ${RELEASE_TARGET:-not set} |"
  echo "| Draft | ${RELEASE_DRAFT:-false} |"
  echo "| Prerelease | ${RELEASE_PRERELEASE:-false} |"
  echo "| Zip asset | ${RELEASE_ZIP:-not set} |"
  echo "| Tar asset | ${RELEASE_TAR:-not set} |"
} >> "${GITHUB_STEP_SUMMARY}"
