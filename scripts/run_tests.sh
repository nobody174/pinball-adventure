#!/usr/bin/env bash
# Runs the GUT unit test suite headlessly. Used locally and in CI.
# Requires the plain (non-Mono) Godot 4.7 binary — see docs/PROGRESS.md for
# why the Mono build must not be used for this project.
set -euo pipefail

cd "$(dirname "$0")/.."

GODOT_BIN="${GODOT_BIN:-godot4}"

"$GODOT_BIN" --headless --path . --import >/dev/null

"$GODOT_BIN" --headless --path . -s addons/gut/gut_cmdln.gd -gconfig=.gutconfig.json
