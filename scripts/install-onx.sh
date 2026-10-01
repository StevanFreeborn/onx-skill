#!/usr/bin/env bash
set -euo pipefail

if command -v onx >/dev/null 2>&1; then
  echo "onx is already installed at: $(command -v onx)"
  onx --version
  exit 0
fi

echo "onx CLI not found in PATH. Installing via official installer..."

INSTALLER_URL="https://raw.githubusercontent.com/StevanFreeborn/onx/main/scripts/install.sh"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "${INSTALLER_URL}" | bash -s -- "$@"
elif command -v wget >/dev/null 2>&1; then
  wget -qO- "${INSTALLER_URL}" | bash -s -- "$@"
else
  echo "Error: Neither curl nor wget was found." >&2
  exit 1
fi
