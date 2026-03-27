#!/usr/bin/env python3

from __future__ import annotations

import json
import pathlib
import sys


def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: read_workflow_config.py <config_path> <field>", file=sys.stderr)
        return 1

    config_path = pathlib.Path(sys.argv[1])
    field = sys.argv[2]

    data = json.loads(config_path.read_text())
    if field not in data:
      print(f"Missing field: {field}", file=sys.stderr)
      return 1

    value = data[field]
    if isinstance(value, (list, dict)):
        print(json.dumps(value))
    else:
        print(value)

    return 0


if __name__ == "__main__":
    sys.exit(main())
