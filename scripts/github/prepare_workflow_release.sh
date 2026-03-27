#!/usr/bin/env bash
set -euo pipefail

version="${RELEASE_VERSION:?RELEASE_VERSION is required}"
tag="${version}"
release_name="python-ci ${tag}"
bundle_dir="dist/workflow-release"
bundle_base="python-ci-${tag}"
zip_path="dist/${bundle_base}.zip"
tar_path="dist/${bundle_base}.tar.gz"

mkdir -p "${bundle_dir}"
rm -rf "${bundle_dir:?}"/*

mkdir -p "${bundle_dir}/.github/workflows"
mkdir -p "${bundle_dir}/scripts"

cp .github/workflows/python-ci.yml "${bundle_dir}/.github/workflows/python-ci.yml"
cp -R scripts/github "${bundle_dir}/scripts/github"
cp README.md "${bundle_dir}/README.md"

(
  cd dist
  zip -qr "${bundle_base}.zip" workflow-release
  tar -czf "${bundle_base}.tar.gz" workflow-release
)

{
  echo "RELEASE_VERSION_NORMALIZED=${version}"
  echo "RELEASE_TAG=${tag}"
  echo "RELEASE_NAME=${release_name}"
  echo "RELEASE_ZIP=${zip_path}"
  echo "RELEASE_TAR=${tar_path}"
} >> "${GITHUB_ENV}"
