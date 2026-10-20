#!/usr/bin/env bash
# Install BURNIN for Ghostty (Linux). Run it, or choose "Run as a program" in your file manager.
# If your file manager starts it without a terminal window, it reopens itself in one so you can see progress.
if [ ! -t 1 ] && [ -z "${CRT_IN_TERMINAL:-}" ]; then
  for term in ghostty x-terminal-emulator gnome-terminal konsole xfce4-terminal xterm; do
    if command -v "$term" >/dev/null 2>&1; then
      case "$term" in
        gnome-terminal) exec env CRT_IN_TERMINAL=1 "$term" -- bash "$0" "$@" ;;
        *)              exec env CRT_IN_TERMINAL=1 "$term" -e bash "$0" "$@" ;;
      esac
    fi
  done
fi
echo "BURNIN - installing for Ghostty..."
echo
if curl -fsSL "https://raw.githubusercontent.com/SnortingPixels/BURNIN/main/install.sh" | bash -s -- "$@"; then
  echo
  echo "All set. Restart Ghostty, then try:  crt-theme list"
else
  echo
  echo "Something went wrong; the messages above say what."
fi
if [ -n "${CRT_IN_TERMINAL:-}" ]; then echo; read -r -p "Press Enter to close this window..." _; fi
