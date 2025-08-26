#!/usr/bin/env bash

set -euo pipefail

# Build all apps and package the resulting 'ui' directory into ui.zip, then commit ui.zip.
# Usage: ./build_ui.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[0/5] Updating repository from origin/main"
if command -v git >/dev/null 2>&1; then
  git pull --rebase origin main
else
  echo "Error: git is not installed. Please install 'git' and retry." >&2
  exit 3
fi

echo "[1/5] Cleaning previous build artifacts"
bash ./build.sh cleanall

echo "[2/5] Building all projects"
bash ./build.sh all

echo "[3/5] Creating ui.zip"
ARCHIVE_PATH="${SCRIPT_DIR}/ui.zip"
rm -f "$ARCHIVE_PATH"

# Use deterministic zip as much as possible (-X strip extra file attrs)
if command -v zip >/dev/null 2>&1; then
  ( cd "$SCRIPT_DIR" && zip -r -X "${ARCHIVE_PATH}" ui >/dev/null )
else
  echo "Error: zip is not installed. Please install 'zip' and retry." >&2
  exit 2
fi

echo "[4/5] Committing ui.zip to git"
HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
git add -f "$ARCHIVE_PATH"
if git diff --cached --quiet; then
  echo "No changes to commit for ui.zip"
else
  git commit -m "build(ui): ui.zip @ ${HASH}"
fi

echo "[5/5] Build complete: ${ARCHIVE_PATH}"


