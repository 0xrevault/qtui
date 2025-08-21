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

# Prefer rsync when available on both ends; fallback to tar-over-ssh
if command -v rsync >/dev/null 2>&1 && ssh "$HOST" "command -v rsync >/dev/null 2>&1"; then
    echo "Using rsync over SSH (--delete, preserve perms, times, compression)"
    ssh "$HOST" "mkdir -p '$REMOTE_UI_DIR'"
    rsync -az --delete -e "ssh" "$LOCAL_UI_DIR/" "$HOST:$REMOTE_UI_DIR/"
else
    echo "rsync not available on local or remote; falling back to tar stream (binary-safe)"
    # macOS: disable AppleDouble/extended attributes in tar (harmless on Linux)
    export COPYFILE_DISABLE=1
    (cd "$LOCAL_UI_DIR" && tar -cpf - .) | ssh "$HOST" "set -euo pipefail; tar -xpf - -C '$REMOTE_UI_DIR'"
fi

# Verify core binary integrity if present
if [ -x "$LOCAL_UI_DIR/systemui" ]; then
    echo "Verifying checksum of 'systemui' binary..."
    local_sha=$(shasum -a 256 "$LOCAL_UI_DIR/systemui" | awk '{print $1}')
    remote_sha=$(ssh "$HOST" "sha256sum '$REMOTE_UI_DIR/systemui' 2>/dev/null || shasum -a 256 '$REMOTE_UI_DIR/systemui'" | awk '{print $1}')
    if [ -z "${remote_sha:-}" ]; then
        echo "Warning: sha256sum/shasum not found on remote, skipping checksum verification" >&2
    else
        if [ "$local_sha" != "$remote_sha" ]; then
            echo "Error: Checksum mismatch for systemui (local=$local_sha, remote=$remote_sha)" >&2
            exit 2
        fi
    fi
    # Optional: ensure remote file is recognized as ELF
    ssh "$HOST" "command -v file >/dev/null 2>&1 && file '$REMOTE_UI_DIR/systemui' || true"
fi

echo "Deploy completed successfully."

echo "[Post] Verifying all deployed files via SHA-256 checksums"

# Create local manifest (relative paths, sorted)
tmp_local_manifest="$(mktemp)"
(
  cd "$LOCAL_UI_DIR"
  if command -v sha256sum >/dev/null 2>&1; then
    LC_ALL=C find . -type f -print | LC_ALL=C sort | while IFS= read -r f; do sha256sum "$f"; done > "$tmp_local_manifest"
  else
    LC_ALL=C find . -type f -print | LC_ALL=C sort | while IFS= read -r f; do shasum -a 256 "$f"; done > "$tmp_local_manifest"
  fi
)

# Create remote manifest with a single, simple command
tmp_remote_manifest="$(mktemp)"
ssh "$HOST" "set -e; cd '$REMOTE_UI_DIR'; if command -v sha256sum >/dev/null 2>&1; then LC_ALL=C find . -type f -print | LC_ALL=C sort | while IFS= read -r f; do sha256sum \"\$f\"; done; elif command -v shasum >/dev/null 2>&1; then LC_ALL=C find . -type f -print | LC_ALL=C sort | while IFS= read -r f; do shasum -a 256 \"\$f\"; done; else echo NO_SHA_TOOL; fi" > "$tmp_remote_manifest"

if grep -q '^NO_SHA_TOOL$' "$tmp_remote_manifest"; then
  echo "Error: Remote host lacks sha256sum/shasum; cannot verify all files." >&2
  rm -f "$tmp_local_manifest" "$tmp_remote_manifest"
  exit 5
fi

if ! diff -u "$tmp_local_manifest" "$tmp_remote_manifest" >/dev/null; then
  echo "Error: SHA-256 mismatch detected between local and remote file trees." >&2
  echo "Showing first 100 diff lines:" >&2
  diff -u "$tmp_local_manifest" "$tmp_remote_manifest" | head -n 100 >&2 || true
  rm -f "$tmp_local_manifest" "$tmp_remote_manifest"
  exit 6
fi

rm -f "$tmp_local_manifest" "$tmp_remote_manifest"
echo "All files verified (SHA-256) successfully."


