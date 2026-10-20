#!/usr/bin/env bash
# CRT Terminal Themes - macOS / Linux uninstaller. Removes the include line from Ghostty's config,
# crt-theme, and the installed files. Fonts stay (other apps may use them).
set -euo pipefail
DATA="${XDG_DATA_HOME:-$HOME/.local/share}/crt-terminal"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
for conf in "$CONFIG_HOME/ghostty/config" "$CONFIG_HOME/ghostty/config.ghostty"; do
  [ -f "$conf" ] || continue
  tmp="$(mktemp)"
  grep -vF -e "crt-terminal/current.conf" -e "# CRT Terminal Themes (crt-theme)" "$conf" > "$tmp" || true
  cat "$tmp" > "$conf"; rm -f "$tmp"
  echo "Removed the CRT include from $conf"
done
rm -f "$HOME/.local/bin/crt-theme"
rm -rf "$CONFIG_HOME/crt-terminal" "$DATA"
echo "Removed crt-theme and $DATA. Restart Ghostty."
