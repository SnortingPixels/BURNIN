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
an Apple ][, a Commodore 64, an IBM 3278 mainframe terminal, a Teletype on paper, a ZX Spectrum on a TV, a radar scope, a Game Boy and 47 more.

* **Windows:** [Windows Terminal](https://aka.ms/terminal), with a CRT pixel shader, matching window colours,
  theme switching from Settings, and optional CRT-styled menus.
* **macOS and Linux:** [Ghostty](https://ghostty.org), with the same shader in GLSL and a `crt-theme` command.
* **🔥 Burn-in:** text fades out the way each machine's phosphor really did (optional on Windows; the cursor on Ghostty).

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
crt-theme list                 # all 55 themes
crt-theme set "Commodore 64"   # pick one
crt-theme next                 # or prev
crt-theme bulge off            # flat screen (bulge on = historic)
```

`crt-theme` asks running Ghostty windows to reload their config. If one doesn't change, use Ghostty's
*Reload Configuration* (macOS: Cmd+Shift+, ; Linux: Ctrl+Shift+,).

## 🔥 Burn-in

A CRT's phosphor keeps glowing for a moment after the beam has moved on, so changing text can leave a fading trail.
How long, and how it fades, depends on the phosphor, so each theme uses its machine's own:

| Phosphor | Themes | Afterglow |
|---|---|---|
| **P39** green (Zn₂SiO₄:Mn,As) | IBM 5151 MDA | 10 % after 150 ms, then a long dim 1/t tail: the famous MDA smear |
| **P1** green (Zn₂SiO₄:Mn) | DEC VT220 Green, and the green screens whose phosphor isn't documented | exponential, 10 % after 24.5 ms |
| **P3** amber (Zn₈BeSi₅O₁₉:Mn) | Hercules Amber, Default Amber | exponential, 10 % after 13 ms |
| **P4** white, **P31** green, colour CRTs | DEC VT100, Commodore PET, Apple ][, the home computers and workstations | gone within about a millisecond: no visible trail |
| **P134** DEC amber | DEC VT220 and VT320 Amber | decay undocumented, so none is modelled |
| **P7** cascade ((Zn,Cd)S:Cu) | Radar Scope P7, SAGE Console | blue-white flash, then a yellow-green afterglow: 10 % after 400 ms, then a 1/t tail lasting seconds |
| none | storage tube, plasma, VFD, EL, LED, paper, LCD, e-ink | nothing glows on |

Brightness decays in linear light: exponentially for the manganese-activated silicates (the Mn²⁺ glow has a fixed
lifetime) and as 1/(1+t/τ)ⁿ for trap-limited phosphors like P39. Times are from RCA's *Phosphors* (TPM-1508A, 1961),
decay laws from Dyall (MIT RLE TR-56, 1948). The cool-retro-term looks borrow P1 or P3 timing. The table is
`PHOSPHORS` in `src/build.py`, and each theme's `"phosphor"` is in `themes/themes.json`.

* **Windows:** terminal shaders never see the previous frame, so this needs the optional
  **BURNIN Phosphor Burn-in** [Windhawk](https://windhawk.net) mod (`windows/windhawk/burnin-phosphor.wh.cpp`).
  It hands each BURNIN shader the previous frame and the time since it. Install it with the setup wizard's
  checkbox or `$env:CRT_BURNIN='1'`. It starts working after the next theme switch (Ctrl+Alt+T) or Windows Terminal
  restart. Without the mod the shaders work as before, just without burn-in.
* **macOS / Linux (Ghostty 1.2 or newer):** Ghostty tells shaders where the cursor is and where it just was, so the
  cell the cursor leaves fades by the same law. Text itself can't leave trails there.

<p align="center"><img src="docs/burn-in.jpg" width="520" alt="IBM 5151 MDA theme scrolled up three lines, the old lines still glowing"><br>
<i>IBM 5151 MDA, one 60 Hz frame after scrolling three lines: the P39 phosphor is still at half brightness.</i></p>

### 📺 Refresh and scan lines

Where the real screen's numbers are documented, the theme uses them:

* **Scan lines per text row:** 10 on the DEC terminals, 14 on the IBM MDA and Hercules, 16 in VGA text mode, 8 on the
  home computers and CGA. The ~240-line screens show the dark gaps between scan lines that DEC's own documentation
  mentions.
* **Refresh rates** (50 Hz for the MDA, Hercules and European home computers, 60 Hz for the DEC terminals and
  American machines, 70 Hz for VGA, interlace for BBC teletext, the Alto and the Lisa) are recorded in
  `themes/themes.json`, but the flicker itself is **off**. A real CRT flashes each spot for microseconds and your eye
  smooths that out; an LCD can only show it as a whole-frame brightness pulse with uneven frame timing, which looks far
  harsher than the real thing. `REFRESH_FLICKER` in `src/build.py` turns it on, if you want to see it anyway.

Screen brightness and tube curvature are not documented for these machines, so those stay as cool-retro-term-style
estimates.

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

## 🖼️ Themes

Historic themes use each machine's documented phosphor or palette colours where a source exists (MAME's phosphor
tables, emulator palettes, manufacturer documentation), and fonts traced from the machine's own character ROM
wherever one exists. Values that could only be estimated are marked "estimate" in `themes/themes.json`.
The cool-retro-term themes copy that app's own built-in profiles.

📚 **[The history behind the themes](docs/HISTORY.md):** where each machine came from, the people who made it,
and how its screen worked.

Every theme, rendered with its real shader. Click a picture for full size, a name for the machine's history.

<table>
<tr><td align="center" valign="top"><a href="docs/screenshots/default-amber.jpg"><img src="docs/screenshots/default-amber.jpg" width="260" alt="Default Amber"></a><br><b><a href="docs/HISTORY.md#default-amber">Default Amber</a></b><br><sub>cool-retro-term profile<br>Terminess Nerd Font Mono<br><code>#ff8100</code> on <code>#000000</code> · bulge 0.2</sub></td><td align="center" valign="top"><a href="docs/screenshots/monochrome-green.jpg"><img src="docs/screenshots/monochrome-green.jpg" width="260" alt="Monochrome Green"></a><br><b><a href="docs/HISTORY.md#monochrome-green">Monochrome Green</a></b><br><sub>cool-retro-term profile<br>DepartureMono Nerd Font Mono<br><code>#0ccc68</code> on <code>#000000</code> · bulge 0.3</sub></td><td align="center" valign="top"><a href="docs/screenshots/deep-blue.jpg"><img src="docs/screenshots/deep-blue.jpg" width="260" alt="Deep Blue"></a><br><b><a href="docs/HISTORY.md#deep-blue">Deep Blue</a></b><br><sub>cool-retro-term profile<br>BigBlueTerm437 Nerd Font Mono<br><code>#7fb4ff</code> on <code>#000000</code> · bulge 0.4</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/neon-cyan.jpg"><img src="docs/screenshots/neon-cyan.jpg" width="260" alt="Neon Cyan"></a><br><b><a href="docs/HISTORY.md#neon-cyan">Neon Cyan</a></b><br><sub>cool-retro-term profile<br>IosevkaTerm Nerd Font Mono<br><code>#52f7ff</code> on <code>#001018</code> · bulge flat</sub></td><td align="center" valign="top"><a href="docs/screenshots/plasma.jpg"><img src="docs/screenshots/plasma.jpg" width="260" alt="Plasma"></a><br><b><a href="docs/HISTORY.md#plasma">Plasma</a></b><br><sub>cool-retro-term profile<br>FiraCode Nerd Font Mono<br><code>#ff9bd6</code> on <code>#070014</code> · bulge flat</sub></td><td align="center" valign="top"><a href="docs/screenshots/ghost-terminal.jpg"><img src="docs/screenshots/ghost-terminal.jpg" width="260" alt="Ghost Terminal"></a><br><b><a href="docs/HISTORY.md#ghost-terminal">Ghost Terminal</a></b><br><sub>cool-retro-term profile<br>JetBrainsMono Nerd Font Mono<br><code>#a6b3c0</code> on <code>#0b1014</code> · bulge flat</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/boring.jpg"><img src="docs/screenshots/boring.jpg" width="260" alt="Boring"></a><br><b><a href="docs/HISTORY.md#boring">Boring</a></b><br><sub>cool-retro-term profile<br>JetBrainsMono Nerd Font Mono<br><code>#ffffff</code> on <code>#000000</code> · bulge flat</sub></td><td align="center" valign="top"><a href="docs/screenshots/e-ink.jpg"><img src="docs/screenshots/e-ink.jpg" width="260" alt="E-Ink"></a><br><b><a href="docs/HISTORY.md#e-ink">E-Ink</a></b><br><sub>cool-retro-term profile<br>Hack Nerd Font Mono<br><code>#101010</code> on <code>#f2f2ec</code> · bulge flat</sub></td><td align="center" valign="top"><a href="docs/screenshots/dec-vt100.jpg"><img src="docs/screenshots/dec-vt100.jpg" width="260" alt="DEC VT100"></a><br><b><a href="docs/HISTORY.md#dec-vt100">DEC VT100</a></b><br><sub>P4 white, Glass TTY VT220 font<br>Glass TTY VT220<br><code>#b4d8ff</code> on <code>#05070a</code> · bulge 0.3</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/dec-vt220-amber.jpg"><img src="docs/screenshots/dec-vt220-amber.jpg" width="260" alt="DEC VT220 Amber"></a><br><b><a href="docs/HISTORY.md#dec-vt220-amber">DEC VT220 Amber</a></b><br><sub>P3 amber, Glass TTY VT220 font<br>Glass TTY VT220<br><code>#ffa700</code> on <code>#0a0600</code> · bulge 0.3</sub></td><td align="center" valign="top"><a href="docs/screenshots/dec-vt220-green.jpg"><img src="docs/screenshots/dec-vt220-green.jpg" width="260" alt="DEC VT220 Green"></a><br><b><a href="docs/HISTORY.md#dec-vt220-green">DEC VT220 Green</a></b><br><sub>P1 green, Glass TTY VT220 font<br>Glass TTY VT220<br><code>#33ff66</code> on <code>#020a04</code> · bulge 0.3</sub></td><td align="center" valign="top"><a href="docs/screenshots/zenith-z-19.jpg"><img src="docs/screenshots/zenith-z-19.jpg" width="260" alt="Zenith Z-19"></a><br><b><a href="docs/HISTORY.md#zenith-z-19">Zenith Z-19</a></b><br><sub>green, Heathkit-H19 ROM font<br>Heathkit-H19 Regular<br><code>#33ff66</code> on <code>#020a04</code> · bulge 0.3</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/ibm-5151-mda.jpg"><img src="docs/screenshots/ibm-5151-mda.jpg" width="260" alt="IBM 5151 MDA"></a><br><b><a href="docs/HISTORY.md#ibm-5151-mda">IBM 5151 MDA</a></b><br><sub>P39 green, IBM VGA ROM font<br>PxPlus IBM VGA 8x16<br><code>#33ff66</code> on <code>#020803</code> · bulge 0.3</sub></td><td align="center" valign="top"><a href="docs/screenshots/ibm-pc-cga.jpg"><img src="docs/screenshots/ibm-pc-cga.jpg" width="260" alt="IBM PC CGA"></a><br><b><a href="docs/HISTORY.md#ibm-pc-cga">IBM PC CGA</a></b><br><sub>5153 colour, IBM 8x8 ROM font<br>PxPlus IBM EGA 8x8<br><code>#aaaaaa</code> on <code>#000000</code> · bulge 0.3</sub></td><td align="center" valign="top"><a href="docs/screenshots/ibm-3278.jpg"><img src="docs/screenshots/ibm-3278.jpg" width="260" alt="IBM 3278"></a><br><b><a href="docs/HISTORY.md#ibm-3278">IBM 3278</a></b><br><sub>green, IBM 3270 font<br>3270 Nerd Font Mono<br><code>#3cff7a</code> on <code>#000000</code> · bulge 0.2</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/ibm-p70-plasma.jpg"><img src="docs/screenshots/ibm-p70-plasma.jpg" width="260" alt="IBM P70 Plasma"></a><br><b><a href="docs/HISTORY.md#ibm-p70-plasma">IBM P70 Plasma</a></b><br><sub>orange gas plasma, VGA ROM font<br>PxPlus IBM VGA 8x16<br><code>#ff6a1a</code> on <code>#140500</code> · bulge flat</sub></td><td align="center" valign="top"><a href="docs/screenshots/apple.jpg"><img src="docs/screenshots/apple.jpg" width="260" alt="Apple ]["></a><br><b><a href="docs/HISTORY.md#apple">Apple ][</a></b><br><sub>green monitor, Apple II ROM font<br>Print Char 21<br><code>#33ff66</code> on <code>#010a03</code> · bulge 0.5</sub></td><td align="center" valign="top"><a href="docs/screenshots/commodore-pet.jpg"><img src="docs/screenshots/commodore-pet.jpg" width="260" alt="Commodore PET"></a><br><b><a href="docs/HISTORY.md#commodore-pet">Commodore PET</a></b><br><sub>P4 white, PET ROM font<br>Pet Me<br><code>#b4d8ff</code> on <code>#04060a</code> · bulge 0.7</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/commodore-64.jpg"><img src="docs/screenshots/commodore-64.jpg" width="260" alt="Commodore 64"></a><br><b><a href="docs/HISTORY.md#commodore-64">Commodore 64</a></b><br><sub>Pepto palette, C64 ROM font<br>Pet Me 64<br><code>#6c5eb5</code> on <code>#352879</code> · bulge 0.5</sub></td><td align="center" valign="top"><a href="docs/screenshots/atari-800.jpg"><img src="docs/screenshots/atari-800.jpg" width="260" alt="Atari 800"></a><br><b><a href="docs/HISTORY.md#atari-800">Atari 800</a></b><br><sub>default blue, Atari ROM font<br>Atari Classic<br><code>#8ed6ff</code> on <code>#0f1f5a</code> · bulge 0.4</sub></td><td align="center" valign="top"><a href="docs/screenshots/amiga-500.jpg"><img src="docs/screenshots/amiga-500.jpg" width="260" alt="Amiga 500"></a><br><b><a href="docs/HISTORY.md#amiga-500">Amiga 500</a></b><br><sub>Workbench 1.3 palette, Topaz font<br>Topaz a500a1000a2000<br><code>#ffffff</code> on <code>#0055aa</code> · bulge 0.3</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/tektronix-4014.jpg"><img src="docs/screenshots/tektronix-4014.jpg" width="260" alt="Tektronix 4014"></a><br><b><a href="docs/HISTORY.md#tektronix-4014">Tektronix 4014</a></b><br><sub>storage tube, tek4010 emulator colours<br>DepartureMono Nerd Font Mono<br><code>#24b324</code> on <code>#001400</code> · bulge 0.15</sub></td><td align="center" valign="top"><a href="docs/screenshots/xerox-alto.jpg"><img src="docs/screenshots/xerox-alto.jpg" width="260" alt="Xerox Alto"></a><br><b><a href="docs/HISTORY.md#xerox-alto">Xerox Alto</a></b><br><sub>ContrAlto colours, Alto Mono font<br>Alto Mono<br><code>#000000</code> on <code>#ffffff</code> · bulge 0.2</sub></td><td align="center" valign="top"><a href="docs/screenshots/sun-sparcstation-20.jpg"><img src="docs/screenshots/sun-sparcstation-20.jpg" width="260" alt="Sun SPARCstation 20"></a><br><b><a href="docs/HISTORY.md#sun-sparcstation-20">Sun SPARCstation 20</a></b><br><sub>Sun console, Gallant font<br>Gallant Raster Term<br><code>#000000</code> on <code>#ffffff</code> · bulge 0.1</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/sgi-indigo2.jpg"><img src="docs/screenshots/sgi-indigo2.jpg" width="260" alt="SGI Indigo2"></a><br><b><a href="docs/HISTORY.md#sgi-indigo2">SGI Indigo2</a></b><br><sub>IRIX winterm colours<br>DepartureMono Nerd Font Mono<br><code>#feffdd</code> on <code>#00004d</code> · bulge 0.1</sub></td><td align="center" valign="top"><a href="docs/screenshots/sgi-octane.jpg"><img src="docs/screenshots/sgi-octane.jpg" width="260" alt="SGI Octane"></a><br><b><a href="docs/HISTORY.md#sgi-octane">SGI Octane</a></b><br><sub>IRIX 6.5 winterm colours<br>DepartureMono Nerd Font Mono<br><code>#feffdd</code> on <code>#00004d</code> · bulge 0.1</sub></td><td align="center" valign="top"><a href="docs/screenshots/nextcube.jpg"><img src="docs/screenshots/nextcube.jpg" width="260" alt="NeXTcube"></a><br><b><a href="docs/HISTORY.md#nextcube">NeXTcube</a></b><br><sub>MegaPixel greyscale (estimate)<br>DepartureMono Nerd Font Mono<br><code>#000000</code> on <code>#e6e6e6</code> · bulge 0.15</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/cray-1.jpg"><img src="docs/screenshots/cray-1.jpg" width="260" alt="Cray-1"></a><br><b><a href="docs/HISTORY.md#cray-1">Cray-1</a></b><br><sub>DG maintenance console (estimate)<br>Glass TTY VT220<br><code>#33ff66</code> on <code>#001000</code> · bulge 0.3</sub></td><td align="center" valign="top"><a href="docs/screenshots/ibm-system-360.jpg"><img src="docs/screenshots/ibm-system-360.jpg" width="260" alt="IBM System/360"></a><br><b><a href="docs/HISTORY.md#ibm-system-360">IBM System/360</a></b><br><sub>IBM 2260 display (estimate)<br>3270 Nerd Font Mono<br><code>#40ff40</code> on <code>#001400</code> · bulge 0.4</sub></td><td align="center" valign="top"><a href="docs/screenshots/dec-pdp-11.jpg"><img src="docs/screenshots/dec-pdp-11.jpg" width="260" alt="DEC PDP-11"></a><br><b><a href="docs/HISTORY.md#dec-pdp-11">DEC PDP-11</a></b><br><sub>VT100 console, Glass TTY font<br>Glass TTY VT220<br><code>#e8f0ff</code> on <code>#050505</code> · bulge 0.3</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/apollo-dn10000.jpg"><img src="docs/screenshots/apollo-dn10000.jpg" width="260" alt="Apollo DN10000"></a><br><b><a href="docs/HISTORY.md#apollo-dn10000">Apollo DN10000</a></b><br><sub>Display Manager pads (estimate)<br>DepartureMono Nerd Font Mono<br><code>#000000</code> on <code>#f0f0f0</code> · bulge 0.15</sub></td><td align="center" valign="top"><a href="docs/screenshots/ibm-5100.jpg"><img src="docs/screenshots/ibm-5100.jpg" width="260" alt="IBM 5100"></a><br><b><a href="docs/HISTORY.md#ibm-5100">IBM 5100</a></b><br><sub>built-in 5-inch CRT (estimate)<br>3270 Nerd Font Mono<br><code>#e0ffe8</code> on <code>#000000</code> · bulge 0.6</sub></td><td align="center" valign="top"><a href="docs/screenshots/altair-8800.jpg"><img src="docs/screenshots/altair-8800.jpg" width="260" alt="Altair 8800"></a><br><b><a href="docs/HISTORY.md#altair-8800">Altair 8800</a></b><br><sub>ASR-33 teletype paper<br>Teletype33<br><code>#1a1a1a</code> on <code>#f3ecd2</code> · bulge flat</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/imsai-8080.jpg"><img src="docs/screenshots/imsai-8080.jpg" width="260" alt="IMSAI 8080"></a><br><b><a href="docs/HISTORY.md#imsai-8080">IMSAI 8080</a></b><br><sub>ASR-33 teletype paper<br>Teletype33<br><code>#1a1a1a</code> on <code>#f3ecd2</code> · bulge flat</sub></td><td align="center" valign="top"><a href="docs/screenshots/amiga-1000.jpg"><img src="docs/screenshots/amiga-1000.jpg" width="260" alt="Amiga 1000"></a><br><b><a href="docs/HISTORY.md#amiga-1000">Amiga 1000</a></b><br><sub>Workbench 1.x palette, Topaz font<br>Topaz a500a1000a2000<br><code>#ffffff</code> on <code>#0055aa</code> · bulge 0.3</sub></td><td align="center" valign="top"><a href="docs/screenshots/apple-lisa.jpg"><img src="docs/screenshots/apple-lisa.jpg" width="260" alt="Apple Lisa"></a><br><b><a href="docs/HISTORY.md#apple-lisa">Apple Lisa</a></b><br><sub>LisaTerminal font<br>LisaTerminal Paper 2X3Y<br><code>#000000</code> on <code>#ffffff</code> · bulge 0.2</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/grid-compass.jpg"><img src="docs/screenshots/grid-compass.jpg" width="260" alt="GRiD Compass"></a><br><b><a href="docs/HISTORY.md#grid-compass">GRiD Compass</a></b><br><sub>amber EL panel<br>DepartureMono Nerd Font Mono<br><code>#ff9a1f</code> on <code>#140800</code> · bulge flat</sub></td><td align="center" valign="top"><a href="docs/screenshots/symbolics-3600.jpg"><img src="docs/screenshots/symbolics-3600.jpg" width="260" alt="Symbolics 3600"></a><br><b><a href="docs/HISTORY.md#symbolics-3600">Symbolics 3600</a></b><br><sub>Genera console (estimate)<br>DepartureMono Nerd Font Mono<br><code>#000000</code> on <code>#e8eee8</code> · bulge 0.15</sub></td><td align="center" valign="top"><a href="docs/screenshots/thinking-machines-cm-5.jpg"><img src="docs/screenshots/thinking-machines-cm-5.jpg" width="260" alt="Thinking Machines CM-5"></a><br><b><a href="docs/HISTORY.md#thinking-machines-cm-5">Thinking Machines CM-5</a></b><br><sub>red LED panel<br>DepartureMono Nerd Font Mono<br><code>#ff2a1a</code> on <code>#0a0000</code> · bulge flat</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/dec-vt320-amber.jpg"><img src="docs/screenshots/dec-vt320-amber.jpg" width="260" alt="DEC VT320 Amber"></a><br><b><a href="docs/HISTORY.md#dec-vt320-amber">DEC VT320 Amber</a></b><br><sub>P3 amber, VT323 font<br>VT323<br><code>#ffa700</code> on <code>#0a0600</code> · bulge 0.3</sub></td><td align="center" valign="top"><a href="docs/screenshots/ms-dos-norton-blue.jpg"><img src="docs/screenshots/ms-dos-norton-blue.jpg" width="260" alt="MS-DOS Norton Blue"></a><br><b><a href="docs/HISTORY.md#ms-dos-norton-blue">MS-DOS Norton Blue</a></b><br><sub>VGA palette, IBM VGA ROM font<br>PxPlus IBM VGA 8x16<br><code>#55ffff</code> on <code>#0000aa</code> · bulge 0.3</sub></td><td align="center" valign="top"><a href="docs/screenshots/hercules-amber.jpg"><img src="docs/screenshots/hercules-amber.jpg" width="260" alt="Hercules Amber"></a><br><b><a href="docs/HISTORY.md#hercules-amber">Hercules Amber</a></b><br><sub>P3 amber, IBM VGA ROM font<br>PxPlus IBM VGA 8x16<br><code>#ffa700</code> on <code>#0a0600</code> · bulge 0.3</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/zx-spectrum.jpg"><img src="docs/screenshots/zx-spectrum.jpg" width="260" alt="ZX Spectrum"></a><br><b><a href="docs/HISTORY.md#zx-spectrum">ZX Spectrum</a></b><br><sub>TV, ROM character set<br>ZX Spectrum ROM<br><code>#000000</code> on <code>#cdcdcd</code> · bulge 0.4</sub></td><td align="center" valign="top"><a href="docs/screenshots/amstrad-cpc-464.jpg"><img src="docs/screenshots/amstrad-cpc-464.jpg" width="260" alt="Amstrad CPC 464"></a><br><b><a href="docs/HISTORY.md#amstrad-cpc-464">Amstrad CPC 464</a></b><br><sub>firmware colours, ROM character set<br>Amstrad CPC ROM<br><code>#ffff80</code> on <code>#000080</code> · bulge 0.3</sub></td><td align="center" valign="top"><a href="docs/screenshots/bbc-micro-teletext.jpg"><img src="docs/screenshots/bbc-micro-teletext.jpg" width="260" alt="BBC Micro Teletext"></a><br><b><a href="docs/HISTORY.md#bbc-micro-teletext">BBC Micro Teletext</a></b><br><sub>Mode 7, SAA5050 characters<br>BBC Teletext SAA5050<br><code>#ffffff</code> on <code>#000000</code> · bulge 0.35</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/radar-scope-p7.jpg"><img src="docs/screenshots/radar-scope-p7.jpg" width="260" alt="Radar Scope P7"></a><br><b><a href="docs/HISTORY.md#radar-scope-p7">Radar Scope P7</a></b><br><sub>P7 cascade phosphor PPI, 15 rpm sweep (colours estimate)<br>B612 Mono<br><code>#c8d4ff</code> on <code>#050805</code> · bulge 0.5</sub></td><td align="center" valign="top"><a href="docs/screenshots/nintendo-virtual-boy.jpg"><img src="docs/screenshots/nintendo-virtual-boy.jpg" width="260" alt="Nintendo Virtual Boy"></a><br><b><a href="docs/HISTORY.md#nintendo-virtual-boy">Nintendo Virtual Boy</a></b><br><sub>red LED column + 50 Hz mirror, VUEngine font<br>Virtual Boy VUEngine<br><code>#ff0000</code> on <code>#000000</code> · bulge 0</sub></td><td align="center" valign="top"><a href="docs/screenshots/nintendo-game-boy.jpg"><img src="docs/screenshots/nintendo-game-boy.jpg" width="260" alt="Nintendo Game Boy"></a><br><b><a href="docs/HISTORY.md#nintendo-game-boy">Nintendo Game Boy</a></b><br><sub>SameBoy DMG palette, STN LCD ghosting (response estimate)<br>Early GameBoy<br><code>#081810</code> on <code>#c6de8c</code> · bulge 0</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/plato-iv.jpg"><img src="docs/screenshots/plato-iv.jpg" width="260" alt="PLATO IV"></a><br><b><a href="docs/HISTORY.md#plato-iv">PLATO IV</a></b><br><sub>orange neon plasma panel, PLATO character set<br>PlatoAscii<br><code>#ffa500</code> on <code>#000000</code> · bulge 0</sub></td><td align="center" valign="top"><a href="docs/screenshots/sage-console.jpg"><img src="docs/screenshots/sage-console.jpg" width="260" alt="SAGE Console"></a><br><b><a href="docs/HISTORY.md#sage-console">SAGE Console</a></b><br><sub>Charactron, blue flash with orange afterglow (colours estimate)<br>B612 Mono<br><code>#b0c4ff</code> on <code>#070605</code> · bulge 0.6</sub></td><td align="center" valign="top"><a href="docs/screenshots/minitel-1.jpg"><img src="docs/screenshots/minitel-1.jpg" width="260" alt="Minitel 1"></a><br><b><a href="docs/HISTORY.md#minitel-1">Minitel 1</a></b><br><sub>9-inch monochrome CRT, Minitel font (phosphor tint estimate)<br>Minitel<br><code>#e8e8e8</code> on <code>#000000</code> · bulge 0.5</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/elektronika-15ie.jpg"><img src="docs/screenshots/elektronika-15ie.jpg" width="260" alt="Elektronika 15IE"></a><br><b><a href="docs/HISTORY.md#elektronika-15ie">Elektronika 15IE</a></b><br><sub>Soviet DVK terminal, MAME colours, KOI-8 ROM font<br>Elektronika 15IE<br><code>#00c000</code> on <code>#000000</code> · bulge 0.4</sub></td><td align="center" valign="top"><a href="docs/screenshots/green-bar-printout.jpg"><img src="docs/screenshots/green-bar-printout.jpg" width="260" alt="Green-Bar Printout"></a><br><b><a href="docs/HISTORY.md#green-bar-printout">Green-Bar Printout</a></b><br><sub>line-printer paper, 3-line green bars (colours estimate)<br>NearlyQMono<br><code>#2b2b33</code> on <code>#f4f1e6</code> · bulge 0</sub></td><td align="center" valign="top"><a href="docs/screenshots/vacuum-fluorescent.jpg"><img src="docs/screenshots/vacuum-fluorescent.jpg" width="260" alt="Vacuum Fluorescent"></a><br><b><a href="docs/HISTORY.md#vacuum-fluorescent">Vacuum Fluorescent</a></b><br><sub>ZnO:Zn 505 nm glow behind a wire mesh<br>Doto Black<br><code>#00ffb8</code> on <code>#0a1412</code> · bulge 0</sub></td></tr>
<tr><td align="center" valign="top"><a href="docs/screenshots/vectrex.jpg"><img src="docs/screenshots/vectrex.jpg" width="260" alt="Vectrex"></a><br><b><a href="docs/HISTORY.md#vectrex">Vectrex</a></b><br><sub>vector CRT with a coloured overlay (overlay colours estimate)<br>Relief SingleLine Outline<br><code>#eef2ff</code> on <code>#050505</code> · bulge 0.3</sub></td></tr>
</table>

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
  * The Virtual Boy font from [VUEngine Core](https://github.com/VUEngine/VUEngine-Core)'s default font (MIT).
  * The Elektronika 15IE character generator from Rob Hagemans'
    [hoard-of-bitfonts](https://github.com/robhagemans/hoard-of-bitfonts).
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
  * [B612 Mono](https://github.com/polarsys/b612) (Airbus, Intactile Design, ENAC).
  * [Early GameBoy](https://www.dafont.com/early-gameboy.font) (Jimmy Campbell).
  * [PlatoAscii](https://github.com/kej715/DtCyber) (the DtCyber / Cyber1 PLATO project).
  * [Minitel](https://github.com/zigazou/minitel-canvas) (Frédéric Bisson, CC0).
  * [NearlyQ Mono](https://github.com/scruss/nearlyq) (Stewart Russell).
  * [Doto](https://github.com/google/fonts/tree/main/ofl/doto) (Óliver Lalan).
  * [Relief SingleLine](https://github.com/isdat-type/Relief-SingleLine) (isdaT type).

## 📜 License

[GPL-3.0](LICENSE), like cool-retro-term, whose shader code this is derived from. Fonts and ROM data are not part of
this repository; they keep their own licences.
