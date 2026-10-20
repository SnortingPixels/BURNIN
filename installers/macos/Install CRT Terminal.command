#!/bin/bash
# Double-click to install CRT Terminal Themes for Ghostty (macOS).
# First time: macOS may block an unsigned script; right-click this file, then Open.
cd "$(dirname "$0")" || exit 1
echo "CRT Terminal Themes - installing for Ghostty..."
echo
if curl -fsSL "https://raw.githubusercontent.com/SnortingPixels/crt-terminal-themes/main/install.sh" | bash; then
  echo
  echo "All set. Restart Ghostty, then try:  crt-theme list"
else
  echo
  echo "Something went wrong; the messages above say what. Nothing was changed after the failing step."
fi
echo
read -n 1 -s -r -p "Press any key to close this window..."
echo
