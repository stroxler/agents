#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills"
TARGET_DIR="$HOME/.llms/skills"

mkdir -p "$TARGET_DIR"

for item in "$SOURCE_DIR"/*/; do
    name="$(basename "$item")"
    target="$TARGET_DIR/$name"

    if [ -L "$target" ]; then
        existing="$(readlink "$target")"
        if [ "$existing" = "$item" ] || [ "$existing" = "${item%/}" ]; then
            echo "ok: $name (already linked)"
        else
            echo "skip: $name (symlink exists -> $existing)"
        fi
    elif [ -e "$target" ]; then
        echo "skip: $name (already exists and is not a symlink)"
    else
        ln -s "${item%/}" "$target"
        echo "linked: $name -> ${item%/}"
    fi
done
