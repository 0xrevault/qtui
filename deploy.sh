#!/usr/bin/env bash

set -euo pipefail

# Usage: ./deploy.sh [user@host]
# Default target device
HOST="${1:-root@192.168.1.43}"
REMOTE_UI_DIR="/opt/ui"

# Directory of this script (repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/3] Using prebuilt ui.zip"
ARCHIVE_PATH="$SCRIPT_DIR/ui.zip"
if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "Error: ui.zip not found at: $ARCHIVE_PATH" >&2
    echo "Tip: Run ./build_ui.sh to produce ui.zip, or place it at project root." >&2
    exit 1
fi

echo "[2/3] Upload archive, verify checksum, and extract on remote"
if command -v sha256sum >/dev/null 2>&1; then
  LOCAL_SHA=$(sha256sum "$ARCHIVE_PATH" | awk '{print $1}')
else
  LOCAL_SHA=$(shasum -a 256 "$ARCHIVE_PATH" | awk '{print $1}')
fi

scp "$ARCHIVE_PATH" "$HOST:/tmp/ui_deploy.zip"

# Compute remote checksum in clear, split form
REMOTE_FILE="/tmp/ui_deploy.zip"
REMOTE_SHA=$(ssh "$HOST" "sha256sum $REMOTE_FILE 2>/dev/null || shasum -a 256 $REMOTE_FILE" | awk '{print $1}' || true)

if [ -z "${REMOTE_SHA:-}" ]; then
  echo "Error: no sha256 tool on remote or failed to compute checksum" >&2
  rm -f "$ARCHIVE_PATH"
  exit 10
fi

if [ "$REMOTE_SHA" != "$LOCAL_SHA" ]; then
  echo "Error: checksum mismatch (remote=$REMOTE_SHA, local=$LOCAL_SHA)" >&2
  rm -f "$ARCHIVE_PATH"
  exit 11
fi

# Extract on remote in separate, clear steps
ssh "$HOST" "set -e; rm -rf '$REMOTE_UI_DIR'"
ssh "$HOST" "set -e; mkdir -p /opt"
# Try unzip; fallback to busybox unzip if available
ssh "$HOST" "set -e; (unzip -o $REMOTE_FILE -d /opt >/dev/null 2>&1 || busybox unzip -o $REMOTE_FILE -d /opt >/dev/null)"
ssh "$HOST" "set -e; rm -f $REMOTE_FILE"
ssh "$HOST" "set -e; [ -f '$REMOTE_UI_DIR/systemui' ] && chmod +x '$REMOTE_UI_DIR/systemui' || true"
ssh "$HOST" "set -e; sync"

# Keep local ui.zip as it is a build artifact tracked by the repo

echo "[3/3] Deploy completed successfully."


