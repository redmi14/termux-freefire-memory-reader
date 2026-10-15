#!/bin/bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

files=(
    "$SCRIPT_DIR/config.sh"
    "$SCRIPT_DIR/core/common.sh"
    "$SCRIPT_DIR/freefire_reader.sh"
    "$SCRIPT_DIR/freefire_tui.sh"
    "$SCRIPT_DIR/install.sh"
    "$SCRIPT_DIR/quick_start.sh"
)

for file in "${files[@]}"; do
    echo "Checking syntax: $file"
    bash -n "$file" || exit 1
done

echo "All shell scripts passed syntax validation."

