#!/usr/bin/env bash
set -euo pipefail

config_path="${1:?config path is required}"
python_versions_input="${2:-}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

workflow_version="$(python "${script_dir}/read_workflow_config.py" "${config_path}" workflow_version)"
default_python_versions="$(python "${script_dir}/read_workflow_config.py" "${config_path}" default_python_versions)"
config_default_python_version="$(
  python - "${default_python_versions}" <<'PY'
import json
import sys

versions = json.loads(sys.argv[1])
if not isinstance(versions, list) or not versions:
    raise SystemExit("default_python_versions must be a non-empty JSON array")

print(str(versions[0]))
PY
)"

resolved_python_versions="${python_versions_input}"
if [[ -z "${resolved_python_versions}" ]]; then
  resolved_python_versions="${default_python_versions}"
fi

selected_primary_python_version="$(
  python - "${resolved_python_versions}" <<'PY'
import json
import sys

versions = json.loads(sys.argv[1])
if not isinstance(versions, list) or not versions:
    raise SystemExit("python_versions must be a non-empty JSON array")

print(str(versions[0]))
PY
)"

if git rev-parse --short HEAD >/dev/null 2>&1; then
  git_commit_short_hash="$(git rev-parse --short HEAD)"
elif [[ -n "${GITHUB_SHA:-}" ]]; then
  git_commit_short_hash="${GITHUB_SHA:0:7}"
else
  git_commit_short_hash="unknown"
fi

{
  echo "python_versions=${resolved_python_versions}"
  echo "selected_primary_python_version=${selected_primary_python_version}"
  echo "config_default_python_version=${config_default_python_version}"
  echo "workflow_version=${workflow_version}"
  echo "git_commit_short_hash=${git_commit_short_hash}"
  echo "workflow_release_version=${workflow_version}-${config_default_python_version}"
} >> "${GITHUB_OUTPUT}"
