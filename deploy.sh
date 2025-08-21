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

echo "[3/4] Recreating remote directory: $HOST:$REMOTE_UI_DIR"
ssh "$HOST" "set -e; rm -rf '$REMOTE_UI_DIR'; mkdir -p '$REMOTE_UI_DIR'"

echo "[4/4] Deploying 'ui' to $HOST:$REMOTE_UI_DIR"
# Copy all contents (including hidden files) into the remote directory
scp -r -C "$LOCAL_UI_DIR/." "$HOST:$REMOTE_UI_DIR/"

echo "Deploy completed successfully."


