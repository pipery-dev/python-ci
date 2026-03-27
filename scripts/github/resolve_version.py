#!/usr/bin/env python3

from __future__ import annotations

import pathlib
import sys


def load_toml(path: pathlib.Path) -> dict:
    try:
        import tomllib
    except ModuleNotFoundError:
        import tomli as tomllib  # type: ignore

    return tomllib.loads(path.read_text())


def main() -> int:
    pyproject = pathlib.Path("pyproject.toml")
    if not pyproject.exists():
        return 0

    data = load_toml(pyproject)
    project_version = data.get("project", {}).get("version")
    poetry_version = data.get("tool", {}).get("poetry", {}).get("version")

    if isinstance(project_version, str) and project_version.strip():
        print(project_version.strip())
        return 0

    if isinstance(poetry_version, str) and poetry_version.strip():
        print(poetry_version.strip())
        return 0

    return 0


if __name__ == "__main__":
    sys.exit(main())
