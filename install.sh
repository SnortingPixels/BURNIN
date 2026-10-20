#!/usr/bin/env bash
# BURNIN - one-line macOS / Linux install (Ghostty):
#     curl -fsSL https://raw.githubusercontent.com/SnortingPixels/BURNIN/main/install.sh | bash
#     curl -fsSL https://raw.githubusercontent.com/SnortingPixels/BURNIN/main/install.sh | bash -s -- --theme "Commodore 64"
# From a downloaded copy of the repository it runs unix/install.sh directly.
set -euo pipefail
REPO="SnortingPixels/BURNIN"
here=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; fi
if [ -n "$here" ] && [ -f "$here/unix/install.sh" ]; then exec bash "$here/unix/install.sh" "$@"; fi
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
echo "Downloading $REPO ..."
curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/main" | tar -xz -C "$tmp"
bash "$(ls -d "$tmp"/*/ | head -n1)unix/install.sh" "$@"
