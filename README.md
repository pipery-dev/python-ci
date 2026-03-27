# python-ci

A reusable GitHub Actions workflow for Python projects that builds inside Docker, supports matrix testing across Python versions, and can be consumed by other repositories with almost no configuration.

The workflow lives at [`.github/workflows/python-ci.yml`](/Users/hamed/Project/pipery-dev/python-ci/.github/workflows/python-ci.yml) and supports both:

- `workflow_call` for reuse from another workflow or repository
- `workflow_dispatch` for manual runs in this repository

## What It Does

- Runs the CI job inside a Docker container based on `python:<version>-slim`
- Supports matrix builds from the `python_versions` input
- Supports `pip`, `poetry`, and `uv`
- Can run build, test, lint, artifact upload, and optional release publishing
- Records timing for each stage and writes the results to the GitHub Actions job summary page
- Works with sensible defaults so consumers can start with a minimal configuration

## Inputs

All inputs are optional.

| Input | Type | Default | Description |
| --- | --- | --- | --- |
| `python_versions` | string | `""` | JSON array used to create the matrix, for example `["3.11", "3.12", "3.13"]`. When empty, the workflow uses the configured defaults from `workflow-config.json`. |
| `package_manager` | string | `pip` | Package manager to use: `pip`, `poetry`, or `uv`. |
| `tests_enabled` | boolean | `true` | Enables the test stage. |
| `lint_enabled` | boolean | `true` | Enables the lint stage. |
| `cache_enabled` | boolean | `true` | Enables dependency cache restore/save for `pip`, `poetry`, and `uv`. |
| `artifact_name` | string | `python-package` | Base name for uploaded artifacts. |
| `version_management` | string | `project` | Version strategy: `project`, `git-tag`, `timestamp`, or `none`. `project` resolves the version from project metadata when available. |
| `release_repository` | string | `""` | Optional package repository name or URL used when publishing on tag builds. |
| `custom_build_command` | string | `""` | Overrides the default build command. |
| `custom_test_command` | string | `""` | Overrides the default test command. |
| `custom_lint_command` | string | `""` | Overrides the default lint command. |

## Secrets

These are only needed if you want to publish on tag builds.

| Secret | Required | Description |
| --- | --- | --- |
| `release_token` | No | Token-based publishing secret. For PyPI this is typically the preferred option. |
| `release_username` | No | Username for repository publishing when token-based auth is not used. |
| `release_password` | No | Password for repository publishing when token-based auth is not used. |

## Default Behavior

If no custom commands are provided, the workflow uses these defaults:

| Package manager | Install behavior | Default build command |
| --- | --- | --- |
| `pip` | Installs `build` and `twine`, then uses `requirements.txt`, `requirements-dev.txt`, and attempts editable install from `pyproject.toml` if present | `python -m build` |
| `poetry` | Installs Poetry and runs `poetry install --with dev` with a fallback to `poetry install` | `poetry build` |
| `uv` | Installs `uv` and runs `uv sync --all-extras --dev` with a fallback to `uv sync` | `uv build` |

Additional defaults:

- Tests default to `python -m pytest`
- Lint defaults to `ruff check .`, with `flake8 .` used when classic flake8 config files are detected first
- Cache is enabled by default and stores package-manager caches keyed by Python version and dependency files
- The build must produce a `dist/` directory so artifacts can be uploaded
- Publishing only runs when `release_repository` is set

## Minimal Usage

The simplest possible consumer workflow can be just this:

```yaml
name: CI

on:
  push:
  pull_request:

jobs:
  python-ci:
    uses: OWNER/python-ci/.github/workflows/python-ci.yml@main
```

That will:

- run on the default Python version configured in [`workflow-config.json`](/Users/hamed/Project/pipery-dev/python-ci/workflow-config.json)
- use `pip`
- run build, tests, and lint
- upload a `python-package-py3.12` artifact
- write a stage timing summary to the Actions page

## Example With Custom Inputs

```yaml
name: CI

on:
  push:
  pull_request:
  workflow_dispatch:

jobs:
  python-ci:
    uses: OWNER/python-ci/.github/workflows/python-ci.yml@main
    with:
      python_versions: '["3.11", "3.12", "3.13"]'
      package_manager: poetry
      artifact_name: my-library
      version_management: git-tag
      release_repository: pypi
      custom_test_command: poetry run pytest -q
      custom_lint_command: poetry run ruff check .
    secrets:
      release_token: ${{ secrets.PYPI_TOKEN }}
```

## Example For `uv`

```yaml
name: CI

on:
  push:
  pull_request:

jobs:
  python-ci:
    uses: OWNER/python-ci/.github/workflows/python-ci.yml@main
    with:
      package_manager: uv
      custom_test_command: uv run pytest
      custom_lint_command: uv run ruff check .
```

## Version Management

The `version_management` input controls the optional `PACKAGE_VERSION` environment value exposed to build commands:

- `project`: resolve the version from `pyproject.toml` using `project.version` or `tool.poetry.version`
- `git-tag`: when the workflow runs on a tag, strip a leading `v` and expose that version
- `timestamp`: generate a UTC timestamp version
- `none`: do not inject any version override

When a version is resolved, the workflow exports `PACKAGE_VERSION`. For project-derived or generated versions it also exports:

- `SETUPTOOLS_SCM_PRETEND_VERSION`
- `POETRY_DYNAMIC_VERSIONING_BYPASS`

That gives common versioning plugins a useful default without forcing a specific build backend.

## Stage Timing And Reporting

Each job records the duration of these stages and publishes them in the GitHub Actions job summary:

- setup
- build
- test
- lint
- publish

This makes it easy to see where time is being spent without opening raw logs.

## Caching

Dependency caching is enabled by default through the `cache_enabled` input.

- `pip` caches `${HOME}/.cache/pip`
- `poetry` caches `${HOME}/.cache/pip` and `${HOME}/.cache/pypoetry`
- `uv` caches `${HOME}/.cache/pip` and `${HOME}/.cache/uv`

The cache key includes:

- operating system
- package manager
- Python version
- dependency files such as `pyproject.toml`, `poetry.lock`, `uv.lock`, and `requirements*.txt`

In reusable runs, the workflow checks out its own helper scripts into `.python-ci-workflow/` so the caller repository does not need to copy any support files.

## Workflow Config

Shared workflow metadata lives in [`workflow-config.json`](/Users/hamed/Project/pipery-dev/python-ci/workflow-config.json).

It currently defines:

- `workflow_version`
- `default_python_versions`

The reusable CI workflow uses `default_python_versions` whenever `python_versions` is not provided.

## Release Publishing

Publishing is intentionally conservative:

- it only runs when `release_repository` is set
- it runs only once for the first Python version in the matrix
- if the workflow is not already running from a Git tag and `PACKAGE_VERSION` was resolved, it creates and pushes `v<resolved-version>` before publishing
- if the workflow is already running from a Git tag, that tag must match the resolved version
- it uses `twine` for upload
- it supports either `release_token` or `release_username` plus `release_password`

Tag creation requires `contents: write` permission so the workflow can push the generated release tag.
If a release is requested and the workflow cannot resolve a version, the workflow fails instead of publishing an untagged release.

`release_repository` can be either:

- a repository alias known to `twine`, such as `pypi`
- a full repository URL

## Notes For Consumers

- If your project has custom dependency groups or non-standard tooling, prefer using `custom_build_command`, `custom_test_command`, and `custom_lint_command`.
- For the smoothest reuse experience, make sure your build produces files in `dist/`.
- `python_versions` must be a valid JSON array string because it is consumed directly by the GitHub Actions matrix.

## Files

- [`.github/workflows/python-ci.yml`](/Users/hamed/Project/pipery-dev/python-ci/.github/workflows/python-ci.yml)
- [`.github/workflows/release-workflow.yml`](/Users/hamed/Project/pipery-dev/python-ci/.github/workflows/release-workflow.yml)
- [`workflow-config.json`](/Users/hamed/Project/pipery-dev/python-ci/workflow-config.json)
- [`README.md`](/Users/hamed/Project/pipery-dev/python-ci/README.md)

## Releasing This Repository

This repository also includes a separate release workflow at [`.github/workflows/release-workflow.yml`](/Users/hamed/Project/pipery-dev/python-ci/.github/workflows/release-workflow.yml).

Use it from the Actions tab with these inputs:

| Input | Default | Description |
| --- | --- | --- |
| `target` | `main` | Branch, commit SHA, or existing ref to release from. |
| `prerelease` | `false` | Marks the GitHub Release as a prerelease. |
| `draft` | `false` | Creates the GitHub Release as a draft. |

What it does:

- checks out the requested target
- reads `workflow_version` and the configured default Python version from [`workflow-config.json`](/Users/hamed/Project/pipery-dev/python-ci/workflow-config.json)
- derives the release version as `<workflow_version>-<default_python_version>`
- creates and pushes that Git tag if it does not already exist
- creates or updates a GitHub Release for that tag
- uploads a zip and tar.gz bundle containing the reusable workflow, helper scripts, and README
