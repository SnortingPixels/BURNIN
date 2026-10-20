<p align="center"><img src="assets/icon.png" width="128" alt="BURNIN icon"></p>

# 📺 BURNIN

**⚡ Install in one line:**

```sh
# macOS / Linux (Ghostty)
curl -fsSL https://raw.githubusercontent.com/SnortingPixels/BURNIN/main/install.sh | bash
```

```powershell
# Windows (Windows Terminal), in PowerShell
irm https://raw.githubusercontent.com/SnortingPixels/BURNIN/main/install.ps1 | iex
```

Or download the double-click installer for your system from [Releases](https://github.com/SnortingPixels/BURNIN/releases/latest).

Turn your everyday terminal into a glowing CRT, and pick the screen of a real historic machine: a DEC VT100,
an Apple ][, a Commodore 64, an IBM 3278 mainframe terminal, a Teletype on paper, a ZX Spectrum on a TV and 39 more.

* **Windows:** [Windows Terminal](https://aka.ms/terminal), with a CRT pixel shader, matching window colours,
  theme switching from Settings, and optional CRT-styled menus.
* **macOS and Linux:** [Ghostty](https://ghostty.org), with the same shader in GLSL and a `crt-theme` command.
* **🔥 Burn-in:** text leaves a fading phosphor glow, like a real tube (optional on Windows; the cursor on Ghostty).

The CRT effect is a port of **[cool-retro-term](https://github.com/Swordfish90/cool-retro-term)**'s shaders
(glow, scan lines, static noise, flicker, the rolling bright band, rasterisation, RGB fringing and the screen bulge),
so the looks are cool-retro-term's, running inside the terminal you already use. See [Credits](#-credits).

## 📦 Install

### 🖱️ Download and double-click

From the [latest release](https://github.com/SnortingPixels/BURNIN/releases/latest):

| System | File | First run |
|---|---|---|
| 🪟 Windows 10/11 | `BURNIN-WINDOWS.exe` | Windows SmartScreen may warn about an unknown publisher (the installer isn't code-signed): **More info, then Run anyway**. |
| 🍎 macOS | `BURNIN-MACOS.zip`, then `Install CRT Terminal.command` inside it | macOS may block an unsigned script: **right-click it, then Open**. |
| 🐧 Linux | `BURNIN-LINUX.sh` | Run it, or in your file manager choose *Run as a program*. |

### ⌨️ One line in a terminal

Windows (PowerShell):

```powershell
irm https://raw.githubusercontent.com/SnortingPixels/BURNIN/main/install.ps1 | iex
```

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/SnortingPixels/BURNIN/main/install.sh | bash
```

Everything installs for your user only. Nothing needs admin rights except the optional Windows menu styling and
burn-in.

### 🧰 What gets installed

* **Shaders and theme list:** `%LOCALAPPDATA%\CRT-Terminal` on Windows, `~/.local/share/crt-terminal` on macOS/Linux.
* **Fonts**, for your user only. They are downloaded from their authors' original sources and never bundled here.
  The ZX Spectrum, Amstrad CPC and BBC teletext fonts are **built on your machine** from each computer's own
  character data (ROM / character-generator data from emulator projects), which needs Python 3. Without Python
  those three themes fall back to another font.
* **Windows Terminal:** one colour scheme, one window theme per CRT theme, the default-profile settings, and a small
  hidden helper that starts with Windows. A backup of `settings.json` is made first.
* **Ghostty:** one line at the end of your Ghostty config (`config-file = ?~/.config/crt-terminal/current.conf`)
  and the `crt-theme` command in `~/.local/bin`.
* **Optional on Windows: CRT-styled menus.** The new-tab dropdown, right-click menus and tooltips are recoloured
  to match the theme by a [Windhawk](https://windhawk.net) mod. Tick the box in the setup wizard, or use
  `$env:CRT_MENUS='1'` with the one-liner. It installs Windhawk and asks for admin.
* **Optional on Windows: phosphor burn-in.** See [Burn-in](#-burn-in). Tick the box in the setup wizard, or use
  `$env:CRT_BURNIN='1'` with the one-liner. It installs Windhawk and asks for admin.

## 🎛️ Use

### 🪟 Windows

* **Settings, Appearance, Theme, "Retro · …"** switches everything: shader, colours, font, cursor and window colours.
* While Windows Terminal is in front:
  * **Ctrl+Alt+T** next theme, **Ctrl+Alt+Shift+T** previous theme.
  * **Ctrl+Alt+B** historic screen bulge on/off. A bulge moves text slightly away from where Terminal places the mouse
    and selection, so turn it off when you need exact selection.
* Picking a normal theme (Dark, Light, System) turns the CRT look off.
* Restart Windows Terminal once after installing so it loads the new fonts.

### 🍎🐧 macOS / Linux (Ghostty)

```sh
crt-theme list                 # all 45 themes
crt-theme set "Commodore 64"   # pick one
crt-theme next                 # or prev
crt-theme bulge off            # flat screen (bulge on = historic)
```

`crt-theme` asks running Ghostty windows to reload their config. If one doesn't change, use Ghostty's
*Reload Configuration* (macOS: Cmd+Shift+, ; Linux: Ctrl+Shift+,).

## 🔥 Burn-in

A real CRT's phosphor keeps glowing for a moment after the beam has moved on, so scrolling or changing text leaves a
fading trail. cool-retro-term calls this burn-in. Terminal shaders normally can't do it, because they never see the
previous frame.

* **Windows:** the optional **BURNIN Phosphor Burn-in** [Windhawk](https://windhawk.net) mod
  (`windows/windhawk/burnin-phosphor.wh.cpp`) hands each BURNIN shader the previous frame, so all text fades out
  over about half a second. Install it with the setup wizard's checkbox or `$env:CRT_BURNIN='1'`.
  It starts working after the next theme switch (Ctrl+Alt+T) or Windows Terminal restart.
  Without the mod the shaders work as before, just without burn-in.
* **macOS / Linux (Ghostty 1.2 or newer):** Ghostty tells shaders where the cursor is and where it just was, so the
  cell the cursor leaves keeps glowing and fades. Text itself can't leave trails there.
* Paper, LCD, plasma and e-ink looks have no burn-in. Set `"burn"` (0 to 1) on a theme in `themes/themes.json`
  to change its length, then rebuild.

<p align="center"><img src="docs/burn-in.jpg" width="520" alt="Text scrolled up three lines, the old lines still glowing faintly"><br>
<i>One frame after scrolling three lines: the old text is still glowing.</i></p>

## 🤖 Using Claude Code?

Claude Code and other full-screen terminal apps can look garbled for a moment after you switch sessions or tabs.
On Windows, BURNIN's theme helper notices the window title changing and nudges Windows Terminal to redraw, so it
fixes itself within a fraction of a second. These Claude Code settings (`~/.claude/settings.json`) make it redraw
cleanly as well:

```json
{
  "tui": "fullscreen",
  "env": { "CLAUDE_CODE_ALT_SCREEN_FULL_REPAINT": "1" }
}
```

## 🖼️ Gallery

Every theme, rendered with its real shader (click a picture for full size, a name for the machine's history):

<table>
<tr><td align="center"><a href="docs/screenshots/default-amber.jpg"><img src="docs/screenshots/default-amber.jpg" width="260" alt="Default Amber"></a><br><b><a href="docs/HISTORY.md#default-amber">Default Amber</a></b></td><td align="center"><a href="docs/screenshots/monochrome-green.jpg"><img src="docs/screenshots/monochrome-green.jpg" width="260" alt="Monochrome Green"></a><br><b><a href="docs/HISTORY.md#monochrome-green">Monochrome Green</a></b></td><td align="center"><a href="docs/screenshots/deep-blue.jpg"><img src="docs/screenshots/deep-blue.jpg" width="260" alt="Deep Blue"></a><br><b><a href="docs/HISTORY.md#deep-blue">Deep Blue</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/neon-cyan.jpg"><img src="docs/screenshots/neon-cyan.jpg" width="260" alt="Neon Cyan"></a><br><b><a href="docs/HISTORY.md#neon-cyan">Neon Cyan</a></b></td><td align="center"><a href="docs/screenshots/plasma.jpg"><img src="docs/screenshots/plasma.jpg" width="260" alt="Plasma"></a><br><b><a href="docs/HISTORY.md#plasma">Plasma</a></b></td><td align="center"><a href="docs/screenshots/ghost-terminal.jpg"><img src="docs/screenshots/ghost-terminal.jpg" width="260" alt="Ghost Terminal"></a><br><b><a href="docs/HISTORY.md#ghost-terminal">Ghost Terminal</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/boring.jpg"><img src="docs/screenshots/boring.jpg" width="260" alt="Boring"></a><br><b><a href="docs/HISTORY.md#boring">Boring</a></b></td><td align="center"><a href="docs/screenshots/e-ink.jpg"><img src="docs/screenshots/e-ink.jpg" width="260" alt="E-Ink"></a><br><b><a href="docs/HISTORY.md#e-ink">E-Ink</a></b></td><td align="center"><a href="docs/screenshots/dec-vt100.jpg"><img src="docs/screenshots/dec-vt100.jpg" width="260" alt="DEC VT100"></a><br><b><a href="docs/HISTORY.md#dec-vt100">DEC VT100</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/dec-vt220-amber.jpg"><img src="docs/screenshots/dec-vt220-amber.jpg" width="260" alt="DEC VT220 Amber"></a><br><b><a href="docs/HISTORY.md#dec-vt220-amber">DEC VT220 Amber</a></b></td><td align="center"><a href="docs/screenshots/dec-vt220-green.jpg"><img src="docs/screenshots/dec-vt220-green.jpg" width="260" alt="DEC VT220 Green"></a><br><b><a href="docs/HISTORY.md#dec-vt220-green">DEC VT220 Green</a></b></td><td align="center"><a href="docs/screenshots/zenith-z-19.jpg"><img src="docs/screenshots/zenith-z-19.jpg" width="260" alt="Zenith Z-19"></a><br><b><a href="docs/HISTORY.md#zenith-z-19">Zenith Z-19</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/ibm-5151-mda.jpg"><img src="docs/screenshots/ibm-5151-mda.jpg" width="260" alt="IBM 5151 MDA"></a><br><b><a href="docs/HISTORY.md#ibm-5151-mda">IBM 5151 MDA</a></b></td><td align="center"><a href="docs/screenshots/ibm-pc-cga.jpg"><img src="docs/screenshots/ibm-pc-cga.jpg" width="260" alt="IBM PC CGA"></a><br><b><a href="docs/HISTORY.md#ibm-pc-cga">IBM PC CGA</a></b></td><td align="center"><a href="docs/screenshots/ibm-3278.jpg"><img src="docs/screenshots/ibm-3278.jpg" width="260" alt="IBM 3278"></a><br><b><a href="docs/HISTORY.md#ibm-3278">IBM 3278</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/ibm-p70-plasma.jpg"><img src="docs/screenshots/ibm-p70-plasma.jpg" width="260" alt="IBM P70 Plasma"></a><br><b><a href="docs/HISTORY.md#ibm-p70-plasma">IBM P70 Plasma</a></b></td><td align="center"><a href="docs/screenshots/apple.jpg"><img src="docs/screenshots/apple.jpg" width="260" alt="Apple ]["></a><br><b><a href="docs/HISTORY.md#apple">Apple ][</a></b></td><td align="center"><a href="docs/screenshots/commodore-pet.jpg"><img src="docs/screenshots/commodore-pet.jpg" width="260" alt="Commodore PET"></a><br><b><a href="docs/HISTORY.md#commodore-pet">Commodore PET</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/commodore-64.jpg"><img src="docs/screenshots/commodore-64.jpg" width="260" alt="Commodore 64"></a><br><b><a href="docs/HISTORY.md#commodore-64">Commodore 64</a></b></td><td align="center"><a href="docs/screenshots/atari-800.jpg"><img src="docs/screenshots/atari-800.jpg" width="260" alt="Atari 800"></a><br><b><a href="docs/HISTORY.md#atari-800">Atari 800</a></b></td><td align="center"><a href="docs/screenshots/amiga-500.jpg"><img src="docs/screenshots/amiga-500.jpg" width="260" alt="Amiga 500"></a><br><b><a href="docs/HISTORY.md#amiga-500">Amiga 500</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/tektronix-4014.jpg"><img src="docs/screenshots/tektronix-4014.jpg" width="260" alt="Tektronix 4014"></a><br><b><a href="docs/HISTORY.md#tektronix-4014">Tektronix 4014</a></b></td><td align="center"><a href="docs/screenshots/xerox-alto.jpg"><img src="docs/screenshots/xerox-alto.jpg" width="260" alt="Xerox Alto"></a><br><b><a href="docs/HISTORY.md#xerox-alto">Xerox Alto</a></b></td><td align="center"><a href="docs/screenshots/sun-sparcstation-20.jpg"><img src="docs/screenshots/sun-sparcstation-20.jpg" width="260" alt="Sun SPARCstation 20"></a><br><b><a href="docs/HISTORY.md#sun-sparcstation-20">Sun SPARCstation 20</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/sgi-indigo2.jpg"><img src="docs/screenshots/sgi-indigo2.jpg" width="260" alt="SGI Indigo2"></a><br><b><a href="docs/HISTORY.md#sgi-indigo2">SGI Indigo2</a></b></td><td align="center"><a href="docs/screenshots/sgi-octane.jpg"><img src="docs/screenshots/sgi-octane.jpg" width="260" alt="SGI Octane"></a><br><b><a href="docs/HISTORY.md#sgi-octane">SGI Octane</a></b></td><td align="center"><a href="docs/screenshots/nextcube.jpg"><img src="docs/screenshots/nextcube.jpg" width="260" alt="NeXTcube"></a><br><b><a href="docs/HISTORY.md#nextcube">NeXTcube</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/cray-1.jpg"><img src="docs/screenshots/cray-1.jpg" width="260" alt="Cray-1"></a><br><b><a href="docs/HISTORY.md#cray-1">Cray-1</a></b></td><td align="center"><a href="docs/screenshots/ibm-system-360.jpg"><img src="docs/screenshots/ibm-system-360.jpg" width="260" alt="IBM System/360"></a><br><b><a href="docs/HISTORY.md#ibm-system-360">IBM System/360</a></b></td><td align="center"><a href="docs/screenshots/dec-pdp-11.jpg"><img src="docs/screenshots/dec-pdp-11.jpg" width="260" alt="DEC PDP-11"></a><br><b><a href="docs/HISTORY.md#dec-pdp-11">DEC PDP-11</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/apollo-dn10000.jpg"><img src="docs/screenshots/apollo-dn10000.jpg" width="260" alt="Apollo DN10000"></a><br><b><a href="docs/HISTORY.md#apollo-dn10000">Apollo DN10000</a></b></td><td align="center"><a href="docs/screenshots/ibm-5100.jpg"><img src="docs/screenshots/ibm-5100.jpg" width="260" alt="IBM 5100"></a><br><b><a href="docs/HISTORY.md#ibm-5100">IBM 5100</a></b></td><td align="center"><a href="docs/screenshots/altair-8800.jpg"><img src="docs/screenshots/altair-8800.jpg" width="260" alt="Altair 8800"></a><br><b><a href="docs/HISTORY.md#altair-8800">Altair 8800</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/imsai-8080.jpg"><img src="docs/screenshots/imsai-8080.jpg" width="260" alt="IMSAI 8080"></a><br><b><a href="docs/HISTORY.md#imsai-8080">IMSAI 8080</a></b></td><td align="center"><a href="docs/screenshots/amiga-1000.jpg"><img src="docs/screenshots/amiga-1000.jpg" width="260" alt="Amiga 1000"></a><br><b><a href="docs/HISTORY.md#amiga-1000">Amiga 1000</a></b></td><td align="center"><a href="docs/screenshots/apple-lisa.jpg"><img src="docs/screenshots/apple-lisa.jpg" width="260" alt="Apple Lisa"></a><br><b><a href="docs/HISTORY.md#apple-lisa">Apple Lisa</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/grid-compass.jpg"><img src="docs/screenshots/grid-compass.jpg" width="260" alt="GRiD Compass"></a><br><b><a href="docs/HISTORY.md#grid-compass">GRiD Compass</a></b></td><td align="center"><a href="docs/screenshots/symbolics-3600.jpg"><img src="docs/screenshots/symbolics-3600.jpg" width="260" alt="Symbolics 3600"></a><br><b><a href="docs/HISTORY.md#symbolics-3600">Symbolics 3600</a></b></td><td align="center"><a href="docs/screenshots/thinking-machines-cm-5.jpg"><img src="docs/screenshots/thinking-machines-cm-5.jpg" width="260" alt="Thinking Machines CM-5"></a><br><b><a href="docs/HISTORY.md#thinking-machines-cm-5">Thinking Machines CM-5</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/dec-vt320-amber.jpg"><img src="docs/screenshots/dec-vt320-amber.jpg" width="260" alt="DEC VT320 Amber"></a><br><b><a href="docs/HISTORY.md#dec-vt320-amber">DEC VT320 Amber</a></b></td><td align="center"><a href="docs/screenshots/ms-dos-norton-blue.jpg"><img src="docs/screenshots/ms-dos-norton-blue.jpg" width="260" alt="MS-DOS Norton Blue"></a><br><b><a href="docs/HISTORY.md#ms-dos-norton-blue">MS-DOS Norton Blue</a></b></td><td align="center"><a href="docs/screenshots/hercules-amber.jpg"><img src="docs/screenshots/hercules-amber.jpg" width="260" alt="Hercules Amber"></a><br><b><a href="docs/HISTORY.md#hercules-amber">Hercules Amber</a></b></td></tr>
<tr><td align="center"><a href="docs/screenshots/zx-spectrum.jpg"><img src="docs/screenshots/zx-spectrum.jpg" width="260" alt="ZX Spectrum"></a><br><b><a href="docs/HISTORY.md#zx-spectrum">ZX Spectrum</a></b></td><td align="center"><a href="docs/screenshots/amstrad-cpc-464.jpg"><img src="docs/screenshots/amstrad-cpc-464.jpg" width="260" alt="Amstrad CPC 464"></a><br><b><a href="docs/HISTORY.md#amstrad-cpc-464">Amstrad CPC 464</a></b></td><td align="center"><a href="docs/screenshots/bbc-micro-teletext.jpg"><img src="docs/screenshots/bbc-micro-teletext.jpg" width="260" alt="BBC Micro Teletext"></a><br><b><a href="docs/HISTORY.md#bbc-micro-teletext">BBC Micro Teletext</a></b></td></tr>
</table>

## 🗂️ Themes

Historic themes use each machine's documented phosphor or palette colours where a source exists (MAME's phosphor
tables, emulator palettes, manufacturer documentation), and fonts traced from the machine's own character ROM
wherever one exists. Values that could only be estimated are marked "estimate" in `themes/themes.json`.
The cool-retro-term themes copy that app's own built-in profiles.

📚 **[The history behind the themes](docs/HISTORY.md):** where each machine came from, the people who made it,
and how its screen worked.

| Theme | Look / source | Font | Colours | Bulge |
|---|---|---|---|---|
| [Default Amber](docs/HISTORY.md#default-amber) | cool-retro-term profile | Terminess Nerd Font Mono | `#ff8100` on `#000000` | 0.2 |
| [Monochrome Green](docs/HISTORY.md#monochrome-green) | cool-retro-term profile | DepartureMono Nerd Font Mono | `#0ccc68` on `#000000` | 0.3 |
| [Deep Blue](docs/HISTORY.md#deep-blue) | cool-retro-term profile | BigBlueTerm437 Nerd Font Mono | `#7fb4ff` on `#000000` | 0.4 |
| [Neon Cyan](docs/HISTORY.md#neon-cyan) | cool-retro-term profile | IosevkaTerm Nerd Font Mono | `#52f7ff` on `#001018` | flat |
| [Plasma](docs/HISTORY.md#plasma) | cool-retro-term profile | FiraCode Nerd Font Mono | `#ff9bd6` on `#070014` | flat |
| [Ghost Terminal](docs/HISTORY.md#ghost-terminal) | cool-retro-term profile | JetBrainsMono Nerd Font Mono | `#a6b3c0` on `#0b1014` | flat |
| [Boring](docs/HISTORY.md#boring) | cool-retro-term profile | JetBrainsMono Nerd Font Mono | `#ffffff` on `#000000` | flat |
| [E-Ink](docs/HISTORY.md#e-ink) | cool-retro-term profile | Hack Nerd Font Mono | `#101010` on `#f2f2ec` | flat |
| [DEC VT100](docs/HISTORY.md#dec-vt100) | P4 white, Glass TTY VT220 font | Glass TTY VT220 | `#b4d8ff` on `#05070a` | 0.3 |
| [DEC VT220 Amber](docs/HISTORY.md#dec-vt220-amber) | P3 amber, Glass TTY VT220 font | Glass TTY VT220 | `#ffa700` on `#0a0600` | 0.3 |
| [DEC VT220 Green](docs/HISTORY.md#dec-vt220-green) | P1 green, Glass TTY VT220 font | Glass TTY VT220 | `#33ff66` on `#020a04` | 0.3 |
| [Zenith Z-19](docs/HISTORY.md#zenith-z-19) | green, Heathkit-H19 ROM font | Heathkit-H19 Regular | `#33ff66` on `#020a04` | 0.3 |
| [IBM 5151 MDA](docs/HISTORY.md#ibm-5151-mda) | P39 green, IBM VGA ROM font | PxPlus IBM VGA 8x16 | `#33ff66` on `#020803` | 0.3 |
| [IBM PC CGA](docs/HISTORY.md#ibm-pc-cga) | 5153 colour, IBM 8x8 ROM font | PxPlus IBM EGA 8x8 | `#aaaaaa` on `#000000` | 0.3 |
| [IBM 3278](docs/HISTORY.md#ibm-3278) | green, IBM 3270 font | 3270 Nerd Font Mono | `#3cff7a` on `#000000` | 0.2 |
| [IBM P70 Plasma](docs/HISTORY.md#ibm-p70-plasma) | orange gas plasma, VGA ROM font | PxPlus IBM VGA 8x16 | `#ff6a1a` on `#140500` | flat |
| <a href="docs/HISTORY.md#apple">Apple ][</a> | green monitor, Apple II ROM font | Print Char 21 | `#33ff66` on `#010a03` | 0.5 |
| [Commodore PET](docs/HISTORY.md#commodore-pet) | P4 white, PET ROM font | Pet Me | `#b4d8ff` on `#04060a` | 0.7 |
| [Commodore 64](docs/HISTORY.md#commodore-64) | Pepto palette, C64 ROM font | Pet Me 64 | `#6c5eb5` on `#352879` | 0.5 |
| [Atari 800](docs/HISTORY.md#atari-800) | default blue, Atari ROM font | Atari Classic | `#8ed6ff` on `#0f1f5a` | 0.4 |
| [Amiga 500](docs/HISTORY.md#amiga-500) | Workbench 1.3 palette, Topaz font | Topaz a500a1000a2000 | `#ffffff` on `#0055aa` | 0.3 |
| [Tektronix 4014](docs/HISTORY.md#tektronix-4014) | storage tube, tek4010 emulator colours | DepartureMono Nerd Font Mono | `#24b324` on `#001400` | 0.15 |
| [Xerox Alto](docs/HISTORY.md#xerox-alto) | ContrAlto colours, Alto Mono font | Alto Mono | `#000000` on `#ffffff` | 0.2 |
| [Sun SPARCstation 20](docs/HISTORY.md#sun-sparcstation-20) | Sun console, Gallant font | Gallant Raster Term | `#000000` on `#ffffff` | 0.1 |
| [SGI Indigo2](docs/HISTORY.md#sgi-indigo2) | IRIX winterm colours | DepartureMono Nerd Font Mono | `#feffdd` on `#00004d` | 0.1 |
| [SGI Octane](docs/HISTORY.md#sgi-octane) | IRIX 6.5 winterm colours | DepartureMono Nerd Font Mono | `#feffdd` on `#00004d` | 0.1 |
| [NeXTcube](docs/HISTORY.md#nextcube) | MegaPixel greyscale (estimate) | DepartureMono Nerd Font Mono | `#000000` on `#e6e6e6` | 0.15 |
| [Cray-1](docs/HISTORY.md#cray-1) | DG maintenance console (estimate) | Glass TTY VT220 | `#33ff66` on `#001000` | 0.3 |
| [IBM System/360](docs/HISTORY.md#ibm-system-360) | IBM 2260 display (estimate) | 3270 Nerd Font Mono | `#40ff40` on `#001400` | 0.4 |
| [DEC PDP-11](docs/HISTORY.md#dec-pdp-11) | VT100 console, Glass TTY font | Glass TTY VT220 | `#e8f0ff` on `#050505` | 0.3 |
| [Apollo DN10000](docs/HISTORY.md#apollo-dn10000) | Display Manager pads (estimate) | DepartureMono Nerd Font Mono | `#000000` on `#f0f0f0` | 0.15 |
| [IBM 5100](docs/HISTORY.md#ibm-5100) | built-in 5-inch CRT (estimate) | 3270 Nerd Font Mono | `#e0ffe8` on `#000000` | 0.6 |
| [Altair 8800](docs/HISTORY.md#altair-8800) | ASR-33 teletype paper | Teletype33 | `#1a1a1a` on `#f3ecd2` | flat |
| [IMSAI 8080](docs/HISTORY.md#imsai-8080) | ASR-33 teletype paper | Teletype33 | `#1a1a1a` on `#f3ecd2` | flat |
| [Amiga 1000](docs/HISTORY.md#amiga-1000) | Workbench 1.x palette, Topaz font | Topaz a500a1000a2000 | `#ffffff` on `#0055aa` | 0.3 |
| [Apple Lisa](docs/HISTORY.md#apple-lisa) | LisaTerminal font | LisaTerminal Paper 2X3Y | `#000000` on `#ffffff` | 0.2 |
| [GRiD Compass](docs/HISTORY.md#grid-compass) | amber EL panel | DepartureMono Nerd Font Mono | `#ff9a1f` on `#140800` | flat |
| [Symbolics 3600](docs/HISTORY.md#symbolics-3600) | Genera console (estimate) | DepartureMono Nerd Font Mono | `#000000` on `#e8eee8` | 0.15 |
| [Thinking Machines CM-5](docs/HISTORY.md#thinking-machines-cm-5) | red LED panel | DepartureMono Nerd Font Mono | `#ff2a1a` on `#0a0000` | flat |
| [DEC VT320 Amber](docs/HISTORY.md#dec-vt320-amber) | P3 amber, VT323 font | VT323 | `#ffa700` on `#0a0600` | 0.3 |
| [MS-DOS Norton Blue](docs/HISTORY.md#ms-dos-norton-blue) | VGA palette, IBM VGA ROM font | PxPlus IBM VGA 8x16 | `#55ffff` on `#0000aa` | 0.3 |
| [Hercules Amber](docs/HISTORY.md#hercules-amber) | P3 amber, IBM VGA ROM font | PxPlus IBM VGA 8x16 | `#ffa700` on `#0a0600` | 0.3 |
| [ZX Spectrum](docs/HISTORY.md#zx-spectrum) | TV, ROM character set | ZX Spectrum ROM | `#000000` on `#cdcdcd` | 0.4 |
| [Amstrad CPC 464](docs/HISTORY.md#amstrad-cpc-464) | firmware colours, ROM character set | Amstrad CPC ROM | `#ffff80` on `#000080` | 0.3 |
| [BBC Micro Teletext](docs/HISTORY.md#bbc-micro-teletext) | Mode 7, SAA5050 characters | BBC Teletext SAA5050 | `#ffffff` on `#000000` | 0.35 |

*Bulge* is the screen curvature on cool-retro-term's 0 to 1 scale: strong for small 1970s/80s tubes, slight for flat
Trinitron screens, none for flat panels, LEDs and paper.

All themes share one character cell (12×26 px at 100 % scaling), so switching themes never changes the number of
columns and rows. Running programs keep their layout. Fonts that are wider than they are tall, like the 8×8 home
computer fonts, are drawn smaller to fit.

## ⚠️ Limits

* **Burn-in needs the Windhawk mod on Windows**, and on Ghostty only the cursor leaves a trail.
* **The CRT effect applies to the terminal text only.** Windows Terminal's Settings page is a normal Windows window.
  It is left as it is; the optional menu styling covers the menus, tooltips and tab bar.
* **The installers aren't code-signed** (signing certificates cost money), hence the first-run warnings above.
* **Ghostty** is tested by compiling every shader with glslang, the compiler Ghostty uses, and by running the
  installer, `crt-theme` and the uninstaller. Reports from real macOS and Linux machines are very welcome.

## 🧹 Uninstall

* **Windows:** Settings, Apps, *BURNIN*, Uninstall. Or run
  `%LOCALAPPDATA%\CRT-Terminal\uninstall.ps1`. Windows Terminal's settings are restored from the install backup.
* **macOS / Linux:** `bash ~/.local/share/crt-terminal/uninstall.sh`

Fonts stay installed, because other apps may use them. Remove them from your system's font settings if you like.

## 🔧 Build it yourself

```sh
pip install fonttools
python src/build.py          # themes/themes.json + src/template.{hlsl,glsl}  ->  dist/
```

`dist/` is committed, so the installers need no build step. The release workflow rebuilds it, checks every shader
(HLSL with the Windows shader compiler, GLSL with glslang) and builds the downloadable installers.

To add or change a theme, edit `themes/themes.json` and run the build.

## 🙏 Credits

* **[cool-retro-term](https://github.com/Swordfish90/cool-retro-term)** by **Filippo Scognamiglio (Swordfish90)
  and the cool-retro-term contributors**, GPL-3.0. The CRT shader here is a port of its `terminal_dynamic.frag` and
  `terminal_static.frag`, and eight of the themes are its built-in profiles. Without their work none of this would exist.
  The idea of bringing it to Windows came from
  [cool-retro-term-windows](https://github.com/pushingpandas/cool-retro-term-windows) by pushingpandas.
* **Windows menu styling:** built on the
  [Windows 11 Settings Styler](https://github.com/ramensoftware/windhawk-mods) engine by **m417z** (Windhawk, GPL-3.0).
* **Phosphor colours:** [MAME](https://github.com/mamedev/mame)'s phosphor profiles.
* **Character data for the built fonts:**
  * The ZX Spectrum 48K and Amstrad CPC 464 ROMs, as distributed with emulators. Amstrad allows the distribution of
    its ROMs for emulation.
  * The SAA5050 teletext characters from [jsbeeb](https://github.com/mattgodbolt/jsbeeb) /
    [b-em](https://github.com/stardot/b-em).
* **Fonts**, downloaded from their authors and used under their own licences:
  * Terminus/Terminess, Departure Mono, BigBlue Terminal, Iosevka, Fira Code, JetBrains Mono, Hack (Nerd Font builds).
  * [Print Char 21, Pet Me, LisaTerminal](https://www.kreativekorp.com/software/fonts/) (Kreative Software).
  * Atari Classic (Mark Simonson).
  * [Px437/PxPlus IBM fonts](https://int10h.org/oldschool-pc-fonts/) (VileR, int10h.org).
  * [IBM 3270](https://github.com/rbanffy/3270font) (Ricardo Bánffy).
  * [Glass TTY VT220](https://github.com/svofski/glasstty) (svofski).
  * [Heathkit-H19](https://github.com/scruss/HeathkitH19Font) (Stewart Russell).
  * [Topaz](https://github.com/rewtnull/amigafonts) (rewtnull).
  * [Gallant](https://github.com/NanoBillion/gallant) (Sun console font).
  * [Teletype33](https://github.com/progs-n-things/Teletype33-Font).
  * [Alto Mono](https://damieng.com/typography/) (Damien Guard).
  * [VT323](https://github.com/google/fonts/tree/main/ofl/vt323) (Peter Hull).

## 📜 License

[GPL-3.0](LICENSE), like cool-retro-term, whose shader code this is derived from. Fonts and ROM data are not part of
this repository; they keep their own licences.
