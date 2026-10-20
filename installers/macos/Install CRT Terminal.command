#!/bin/bash
# Double-click to install BURNIN for Ghostty (macOS).
# First time: macOS may block an unsigned script; right-click this file, then Open.
cd "$(dirname "$0")" || exit 1
echo "BURNIN - installing for Ghostty..."
echo
if curl -fsSL "https://raw.githubusercontent.com/SnortingPixels/BURNIN/main/install.sh" | bash; then
  echo
  echo "All set. Restart Ghostty, then try:  crt-theme list"
else
  echo
  echo "Something went wrong; the messages above say what. Nothing was changed after the failing step."
fi
echo
read -n 1 -s -r -p "Press any key to close this window..."
echo
