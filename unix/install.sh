#!/usr/bin/env bash
# BURNIN - macOS / Linux installer (Ghostty). Part of BURNIN, GPL-3.0.
# The CRT shader is a port of cool-retro-term's.
#
#   bash unix/install.sh [--theme "Default Amber"] [--yes] [--skip-fonts]
#
# Installs, for the current user only (no sudo):
#   ~/.local/share/crt-terminal       shaders and theme list
#   fonts                             macOS: ~/Library/Fonts   Linux: ~/.local/share/fonts/crt-terminal
#   ~/.local/bin/crt-theme            switch themes / screen bulge
#   one line in Ghostty's config      config-file = ?~/.config/crt-terminal/current.conf
# Works with the bash 3.2 that macOS ships.
set -euo pipefail

THEME="Default Amber"; YES=0; SKIP_FONTS=0
while [ $# -gt 0 ]; do
  case "$1" in
    --theme) THEME="$2"; shift 2 ;;
    -y|--yes) YES=1; shift ;;
    --skip-fonts) SKIP_FONTS=1; shift ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

REPO="$(cd "$(dirname "$0")/.." && pwd)"
OS="${CRT_OS:-$(uname -s)}"
case "$OS" in
  Darwin|Linux) ;;
  *) echo "This installer is for macOS and Linux. On Windows, run install.ps1 or BURNIN-WINDOWS.exe." >&2; exit 1 ;;
esac
DATA="${XDG_DATA_HOME:-$HOME/.local/share}/crt-terminal"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN="$HOME/.local/bin"
if [ "$OS" = Darwin ]; then FONT_DIR="$HOME/Library/Fonts"; else FONT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/crt-terminal"; fi
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36"

say()  { printf '\033[33m==>\033[0m %s\n' "$*"; }
note() { printf '    %s\n' "$*"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "This installer needs '$1'. Please install it and run again." >&2; exit 1; }; }
need curl; need awk; need unzip

[ -f "$REPO/dist/themes.tsv" ] || { echo "dist/themes.tsv not found next to the installer ($REPO)." >&2; exit 1; }
awk -F'\t' -v n="$THEME" '!/^#/ && tolower($1) == tolower(n) { found = 1 } END { exit !found }' "$REPO/dist/themes.tsv" \
  || { echo "Unknown theme '$THEME'. Themes:" >&2; grep -v '^#' "$REPO/dist/themes.tsv" | cut -f1 >&2; exit 2; }

# ------------------------------------------------------------------ Ghostty
have_ghostty() {
  command -v ghostty >/dev/null 2>&1 || [ -d /Applications/Ghostty.app ] || [ -d "$HOME/Applications/Ghostty.app" ]
}
if ! have_ghostty; then
  if [ "$OS" = Darwin ] && command -v brew >/dev/null 2>&1; then
    answer=y
    if [ "$YES" = 0 ] && [ -t 0 ]; then printf 'Ghostty is not installed. Install it with Homebrew now? [Y/n] '; read -r answer || answer=y; fi
    case "$answer" in [nN]*) note "Skipping Ghostty; install it later from https://ghostty.org" ;; *) say "Installing Ghostty"; brew install --cask ghostty ;; esac
  else
    note "Ghostty was not found. Install it from https://ghostty.org/download (or your distribution's package),"
    note "then this setup takes effect the next time it starts."
  fi
fi

# ------------------------------------------------------------------ files
say "Copying files to $DATA"
mkdir -p "$DATA" "$BIN" "$CONFIG_HOME/crt-terminal"
rm -rf "$DATA/dist"
cp -R "$REPO/dist" "$DATA/dist"
cp "$REPO/src/retro_fonts.py" "$REPO/unix/uninstall.sh" "$DATA/"
cp "$REPO/unix/crt-theme" "$BIN/crt-theme"
chmod 755 "$BIN/crt-theme" "$DATA/uninstall.sh"

# ------------------------------------------------------------------ fonts
if [ "$SKIP_FONTS" = 1 ]; then
  say "Skipping fonts (--skip-fonts)"
else
  say "Installing fonts to $FONT_DIR (downloaded from their original sources)"
  mkdir -p "$FONT_DIR"
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  need_rom=0
  while IFS="$(printf '\t')" read -r key file url member agent; do
    case "$key" in \#*|"") continue ;; esac
    [ "$member" = - ] && member=""   # "-" marks an empty field (bash read merges consecutive tabs)
    if [ "$url" = build ]; then [ -f "$FONT_DIR/$file" ] || need_rom=1; continue; fi
    if [ -f "$FONT_DIR/$file" ]; then note "$file (already installed)"; continue; fi
    curl -fsSL -A "$UA" -o "$tmp/download" "$url"
    if [ -n "$member" ]; then unzip -p "$tmp/download" "$member" > "$FONT_DIR/$file"; else cp "$tmp/download" "$FONT_DIR/$file"; fi
    note "$file"
  done < "$REPO/dist/fonts.tsv"

  if [ "$need_rom" = 1 ]; then
    if command -v python3 >/dev/null 2>&1 && python3 -c 'import venv' 2>/dev/null; then
      note "Building the ZX Spectrum, Amstrad CPC, BBC teletext, Virtual Boy and Elektronika fonts from their character data"
      [ -x "$DATA/fontbuild/venv/bin/python" ] || python3 -m venv "$DATA/fontbuild/venv"
      "$DATA/fontbuild/venv/bin/python" -m pip install --quiet --disable-pip-version-check fonttools
      mkdir -p "$DATA/fontbuild/roms" "$DATA/fontbuild/out"
      while IFS="$(printf '\t')" read -r name url; do
        case "$name" in \#*|"") continue ;; esac
        [ -f "$DATA/fontbuild/roms/$name" ] || curl -fsSL -A "$UA" -o "$DATA/fontbuild/roms/$name" "$url"
      done < "$REPO/dist/roms.tsv"
      "$DATA/fontbuild/venv/bin/python" -I "$DATA/retro_fonts.py" "$DATA/fontbuild/roms/48.rom" "$DATA/fontbuild/roms/cpc464.rom" \
        "$DATA/fontbuild/roms/teletext_data.js" "$DATA/fontbuild/roms/vuengine.font" \
        "$DATA/fontbuild/roms/dvk_15ie.draw" "$DATA/fontbuild/out" >/dev/null
      cp "$DATA"/fontbuild/out/*.ttf "$FONT_DIR/"
    else
      note "python3 (with venv) not found: the ZX Spectrum, Amstrad CPC, BBC teletext, Virtual Boy and Elektronika themes use a fallback font."
      note "Install python3 and run this installer again to build them."
    fi
  fi
  if [ "$OS" = Linux ] && command -v fc-cache >/dev/null 2>&1; then fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true; fi
fi

# ------------------------------------------------------------------ Ghostty config
say "Adding the CRT theme to Ghostty's config"
GH_DIR="$CONFIG_HOME/ghostty"
mkdir -p "$GH_DIR"
GH_CONF="$GH_DIR/config"
[ -f "$GH_DIR/config.ghostty" ] && GH_CONF="$GH_DIR/config.ghostty"   # Ghostty 1.2+ name, if the user has one
touch "$GH_CONF"
INCLUDE="config-file = ?$CONFIG_HOME/crt-terminal/current.conf"
if ! grep -qF "crt-terminal/current.conf" "$GH_CONF"; then
  printf '\n# BURNIN (crt-theme): keep this as the last line so the theme wins\n%s\n' "$INCLUDE" >> "$GH_CONF"
fi
note "$GH_CONF"

CRT_TERMINAL_HOME="$DATA" "$BIN/crt-theme" set "$THEME"

say "Done"
note "Switch looks:    crt-theme list | crt-theme set \"Commodore 64\" | crt-theme next | crt-theme prev"
note "Screen bulge:    crt-theme bulge off   (on = historic)"
note "Uninstall:       bash \"$DATA/uninstall.sh\""
case ":$PATH:" in *":$BIN:"*) ;; *) note "Add $BIN to your PATH to run crt-theme by name." ;; esac
note "Restart Ghostty (or reload its config) to see the theme."
