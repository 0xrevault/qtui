#!/usr/bin/env bash

set -euo pipefail

# Usage: ./deploy.sh [user@host]
# Default target device
HOST="${1:-root@192.168.1.43}"
REMOTE_UI_DIR="/opt/ui"

# Directory of this script (repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/4] Cleaning previous build artifacts"
bash ./build.sh cleanall

echo "[2/4] Building all projects"
bash ./build.sh all

LOCAL_UI_DIR="$SCRIPT_DIR/ui"
if [ ! -d "$LOCAL_UI_DIR" ]; then
    echo "Error: Local 'ui' directory not found at: $LOCAL_UI_DIR" >&2
    exit 1
fi

echo "[3/4] Packaging local 'ui' into archive"
ARCHIVE_PATH="$(mktemp -t ui-archive-XXXXXX.tar.gz)"
# macOS xattrs guard (harmless on Linux)
export COPYFILE_DISABLE=1
# Create archive with deterministic order
( cd "$SCRIPT_DIR" && LC_ALL=C tar -czf "$ARCHIVE_PATH" ui )

echo "[4/4] Upload archive, verify checksum, and extract on remote"
if command -v sha256sum >/dev/null 2>&1; then
  LOCAL_SHA=$(sha256sum "$ARCHIVE_PATH" | awk '{print $1}')
else
  LOCAL_SHA=$(shasum -a 256 "$ARCHIVE_PATH" | awk '{print $1}')
fi

scp "$ARCHIVE_PATH" "$HOST:/tmp/ui_deploy.tar.gz"

ssh "$HOST" "set -euo pipefail; \
  FILE=/tmp/ui_deploy.tar.gz; \
  # Compute remote sha256 (prefer sha256sum)
  ACT=\"\$( (sha256sum \"$FILE\" 2>/dev/null || shasum -a 256 \"$FILE\") | awk '{print \$1}')\"; \
  if [ -z \"$ACT\" ]; then echo 'Error: no sha256 tool on remote' >&2; exit 10; fi; \
  if [ \"$ACT\" != \"$LOCAL_SHA\" ]; then echo \"Error: checksum mismatch (remote=$ACT, local=$LOCAL_SHA)\" >&2; exit 11; fi; \
  rm -rf '$REMOTE_UI_DIR'; mkdir -p /opt; tar -xzf \"$FILE\" -C /opt; rm -f \"$FILE\"; \
  if [ -f '$REMOTE_UI_DIR/systemui' ]; then chmod +x '$REMOTE_UI_DIR/systemui' || true; fi; \
  true"

rm -f "$ARCHIVE_PATH"

echo "Deploy completed successfully."


