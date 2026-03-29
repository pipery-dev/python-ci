#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import pathlib
import sys


def env_bool(name: str) -> bool:
    return os.getenv(name, "").lower() == "true"


def env_value(name: str, default: str = "") -> str:
    return os.getenv(name, default)


def main() -> int:
    report_path = pathlib.Path(env_value("BUILD_REPORT_PATH"))
    if not report_path:
        print("BUILD_REPORT_PATH is required", file=sys.stderr)
        return 1

    report_path.parent.mkdir(parents=True, exist_ok=True)

    report = {
        "package_manager": env_value("PACKAGE_MANAGER"),
        "python_version": env_value("MATRIX_PYTHON_VERSION"),
        "project_directory": env_value("PROJECT_DIRECTORY", "."),
        "artifact_name": env_value("ARTIFACT_NAME"),
        "version_management": env_value("VERSION_MANAGEMENT"),
        "cache_enabled": env_bool("CACHE_ENABLED"),
        "tests_enabled": env_bool("TESTS_ENABLED"),
        "lint_enabled": env_bool("LINT_ENABLED"),
        "build_command": env_value("BUILD_COMMAND"),
        "test_command": env_value("TEST_COMMAND"),
        "lint_command": env_value("LINT_COMMAND"),
        "package_version": env_value("PACKAGE_VERSION"),
        "release_tag": env_value("RELEASE_TAG"),
        "stages": {
            "resolve": {
                "status": env_value("RESOLVE_STATUS", "unknown"),
            },
            "cache": {
                "status": env_value("CACHE_STATUS", "unknown"),
            },
            "setup": {
                "status": env_value("SETUP_STATUS", "unknown"),
                "duration": env_value("SETUP_DURATION", "not recorded"),
            },
            "build": {
                "status": env_value("BUILD_STATUS", "unknown"),
                "duration": env_value("BUILD_DURATION", "not recorded"),
            },
            "test": {
                "status": env_value("TEST_STATUS", "unknown"),
                "duration": env_value("TEST_DURATION", "not recorded"),
            },
            "lint": {
                "status": env_value("LINT_STATUS", "unknown"),
                "duration": env_value("LINT_DURATION", "not recorded"),
            },
            "artifact": {
                "status": env_value("ARTIFACT_STATUS", "unknown"),
            },
            "tag": {
                "status": env_value("TAG_STATUS", "unknown"),
                "duration": env_value("TAG_DURATION", "not recorded"),
            },
            "publish": {
                "status": env_value("PUBLISH_STATUS", "unknown"),
                "duration": env_value("PUBLISH_DURATION", "not recorded"),
            },
        },
    }

    report_path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
