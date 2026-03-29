#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import pathlib
import sys


def expect(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def load_report(path: str) -> dict:
    return json.loads(pathlib.Path(path).read_text())


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--report", required=True)
    parser.add_argument("--package-manager", required=True)
    parser.add_argument("--python-version", required=True)
    parser.add_argument("--project-directory", required=True)
    parser.add_argument("--version-management", required=True)
    parser.add_argument("--tests-enabled", choices=["true", "false"], required=True)
    parser.add_argument("--lint-enabled", choices=["true", "false"], required=True)
    parser.add_argument("--cache-enabled", choices=["true", "false"], required=True)
    parser.add_argument("--build-command-contains", required=True)
    parser.add_argument("--test-command-contains", default="")
    parser.add_argument("--lint-command-contains", default="")
    parser.add_argument("--expect-stage", action="append", default=[])
    args = parser.parse_args()

    report = load_report(args.report)
    stages = report["stages"]
    expected_stages = {}

    for stage_expectation in args.expect_stage:
        if "=" not in stage_expectation:
            raise AssertionError(f"Invalid --expect-stage value: {stage_expectation}")

        stage_name, expected_status = stage_expectation.split("=", 1)
        expected_stages[stage_name] = expected_status

    expect(report["package_manager"] == args.package_manager, "package_manager mismatch")
    expect(report["python_version"] == args.python_version, "python_version mismatch")
    expect(report["project_directory"] == args.project_directory, "project_directory mismatch")
    expect(report["version_management"] == args.version_management, "version_management mismatch")
    expect(report["tests_enabled"] is (args.tests_enabled == "true"), "tests_enabled mismatch")
    expect(report["lint_enabled"] is (args.lint_enabled == "true"), "lint_enabled mismatch")
    expect(report["cache_enabled"] is (args.cache_enabled == "true"), "cache_enabled mismatch")

    if expected_stages:
        for stage_name, expected_status in expected_stages.items():
            expect(stage_name in stages, f"Unknown stage: {stage_name}")
            actual_status = stages[stage_name]["status"]
            expect(actual_status == expected_status, f"{stage_name} stage expected {expected_status} but was {actual_status}")
    else:
        expect(stages["resolve"]["status"] == "success", "resolve stage did not succeed")
        if args.cache_enabled == "true":
          expect(stages["cache"]["status"] in {"hit", "miss"}, "cache stage must be hit or miss")
        else:
          expect(stages["cache"]["status"] == "skipped", "cache stage should be skipped")

        expect(stages["setup"]["status"] == "success", "setup stage did not succeed")
        expect(stages["build"]["status"] == "success", "build stage did not succeed")
        expect(stages["artifact"]["status"] == "success", "artifact stage did not succeed")
        expect(stages["tag"]["status"] == "skipped", "tag stage should be skipped")
        expect(stages["publish"]["status"] == "skipped", "publish stage should be skipped")

        if args.tests_enabled == "true":
          expect(stages["test"]["status"] == "success", "test stage did not succeed")
          expect(args.test_command_contains in report["test_command"], "unexpected test command")
        else:
          expect(stages["test"]["status"] == "skipped", "test stage should be skipped")

        if args.lint_enabled == "true":
          expect(stages["lint"]["status"] == "success", "lint stage did not succeed")
          expect(args.lint_command_contains in report["lint_command"], "unexpected lint command")
        else:
          expect(stages["lint"]["status"] == "skipped", "lint stage should be skipped")

    if args.tests_enabled == "true" and args.test_command_contains:
        expect(args.test_command_contains in report["test_command"], "unexpected test command")

    if args.lint_enabled == "true" and args.lint_command_contains:
        expect(args.lint_command_contains in report["lint_command"], "unexpected lint command")

    expect(args.build_command_contains in report["build_command"], "unexpected build command")

    print(f"Validated report: {args.report}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(1)
