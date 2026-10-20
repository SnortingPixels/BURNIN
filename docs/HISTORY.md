# The history behind the themes

BURNIN's themes are small tributes to the screens people actually stared at while computing grew up: video terminals, home computers, workstations, a supercomputer console and even a teleprinter. This page gives a short history of each machine, how its display worked, and what the theme tries to recreate. The last group are styles from the cool-retro-term app rather than specific machines.

## How CRT phosphor displays work

A cathode-ray tube (CRT) fires a beam of electrons from a heated cathode at the back of a vacuum tube. Magnetic coils (or electrostatic plates) steer the beam across the inside of the glass, which is coated with a **phosphor**: a material that glows where electrons hit it. In a **raster** display the beam sweeps the whole screen in horizontal lines many times per second, switching on and off to draw dots; the dark gaps between those lines are the **scanlines** that BURNIN imitates. A **vector** display instead steers the beam directly along the lines of a drawing. Phosphors are catalogued by "P numbers": for example **P1** (green), **P3** (amber), **P4** (white, used in black-and-white TVs) and **P39** (green with long persistence). **Persistence** is how long a phosphor keeps glowing after the beam has passed: a long-persistence phosphor reduces flicker on a slowly refreshed screen, but leaves a ghostly smear when the picture changes. Colour CRTs use dots or stripes of red, green and blue phosphors behind a shadow mask or aperture grille.

Sources: [Cathode-ray tube (Wikipedia)](https://en.wikipedia.org/wiki/Cathode-ray_tube), [Phosphor (Wikipedia)](https://en.wikipedia.org/wiki/Phosphor), [Raster scan (Wikipedia)](https://en.wikipedia.org/wiki/Raster_scan)

---

# Historic machines

<a id="dec-vt100"></a>

## 🖥️ DEC VT100

Digital Equipment Corporation (DEC) introduced the VT100 in August 1978. Inside was an Intel 8080 microprocessor, which let the terminal understand the then-new ANSI X3.64 escape-code standard. Because the VT100 was so widely used, its codes became the de facto standard for video terminals, and almost every terminal emulator today (including the one you are reading this in, probably) still speaks "VT100". It showed 80 columns by 24 rows, with a 132-column mode, smooth scrolling, and double-width and double-height lines. Over six million VT-series terminals were sold, largely on the VT100's success. The 12-inch tube used a white P4-type phosphor (DEC's documentation for the closely related VT102 lists a 12-inch P4 tube).

**The theme:** a cool white P4 glow on near-black, using the Glass TTY VT220 font (no font traced from the VT100's own character ROM exists, so the VT220's close relative stands in).

Sources: [VT100 (Wikipedia)](https://en.wikipedia.org/wiki/VT100), [VT102 User Guide, specifications (vt100.net)](https://vt100.net/docs/vt102-ug/appendixa.html), [VT100 Technical Manual (vt100.net)](https://vt100.net/docs/vt100-tm/)

<a id="dec-vt220-amber"></a>

## 🟠 DEC VT220 Amber

The VT220 arrived in November 1983 as DEC's cheaper, more compact successor to the VT100 line, launched at $1,295 and later cut to $795. It sold extremely well: DEC shipped over a million by 1987, and in 1986 it held about 42% of the terminal market. Buyers could choose a white, green or amber screen. Each character was drawn as an 8 by 10 pixel glyph inside a 10 by 10 cell, on an 80 by 24 text grid, and the terminal added downloadable fonts and the DEC Multinational character set. Amber (P3-type) phosphor became popular in the 1980s because many users found it easier on the eyes than green or white.

**The theme:** a warm P3 amber on dark brown-black, with the Glass TTY VT220 font by Viacheslav Slavinsky, which mimics the VT220's glyphs.

Sources: [VT220 (Wikipedia)](https://en.wikipedia.org/wiki/VT220), [VT220 built-in glyphs (vt100.net)](https://www.vt100.net/dec/vt220/glyphs)

<a id="dec-vt220-green"></a>

## 🟢 DEC VT220 Green

This is the same DEC VT220 (November 1983) as above, in its green-screen version. Green P1-type phosphor was the classic terminal colour of the 1970s and early 80s: it is bright, cheap and the human eye is very sensitive to green light. The VT220 kept the VT100's ANSI command set and added features such as user-definable characters, and it was one of the most common terminals on DEC VAX and PDP-11 systems through the 1980s. Like all VT220s, it drew its text from a character ROM; enthusiasts have dumped and documented that ROM, which is why faithful VT220 fonts exist today.

**The theme:** green P1 glow on near-black with the Glass TTY VT220 font.

Sources: [VT220 (Wikipedia)](https://en.wikipedia.org/wiki/VT220), [VT220 built-in glyphs (vt100.net)](https://www.vt100.net/dec/vt220/glyphs)

<a id="zenith-z-19"></a>

## 🔧 Zenith Z-19

The Z-19 was introduced in June 1979 and was also sold by Heathkit as a build-it-yourself kit, the H19 (Heath was owned by Zenith from 1979). It was a popular, affordable "smart" terminal: a 12-inch screen with 80 columns by 24 lines plus a 25th status line, VT52-compatible escape codes, and 33 extra graphics characters for drawing boxes and lines. A 1979 Datapro report describes its 95 ASCII characters as formed on a 5x7 dot matrix (5x9 for lowercase with descenders) and shown in green on a dark background. Heath later built the same terminal into the H89 all-in-one computer.

**The theme:** green phosphor with a font traced from the H19's character-generator ROM.

Sources: [Datapro report on the Zenith Z19 (bitsavers)](https://ftp.mirrorservice.org/sites/www.bitsavers.org/pdf/datapro/alphanumeric_terminals/Datapro_C25_Zenith.pdf), [Heathkit H8 (Wikipedia)](https://en.wikipedia.org/wiki/Heathkit_H8), [Zenith Z-89 (Wikipedia)](https://en.wikipedia.org/wiki/Zenith_Z-89)

<a id="ibm-5151-mda"></a>

## 💚 IBM 5151 MDA

When IBM launched the PC in 1981, its business display option was the Monochrome Display Adapter (MDA) with the IBM 5151 monitor. The MDA was text-only: 80 by 25 characters, each in a 9 by 14 pixel cell (720 by 350 overall), with attributes for underline, bright, reverse video and blinking. Its design came from IBM's System/23 Datamaster, and it was aimed at word processing and spreadsheets, where sharp text mattered more than graphics. The 5151 used P39 phosphor, a bright green with long persistence. That long glow hid flicker at the MDA's 50 Hz refresh rate, at the cost of a visible smear when text scrolled.

**The theme:** P39 green on black with the PxPlus IBM VGA font from VileR's Ultimate Oldschool PC Font Pack.

Sources: [IBM 5151 (Wikipedia)](https://en.wikipedia.org/wiki/IBM_5151), [Monochrome Display Adapter (Wikipedia)](https://en.wikipedia.org/wiki/Monochrome_Display_Adapter)

<a id="ibm-pc-cga"></a>

## 🌈 IBM PC CGA

The Color Graphics Adapter (CGA) was IBM's first colour card for the PC, introduced in 1981. It produced a 16-colour "RGBI" palette from four digital signals (red, green, blue and an intensity bit), with 40 and 80-column text modes built from 8 by 8 pixel characters. IBM's matching 5153 Color Display only arrived in March 1983; before that, many users plugged CGA into a TV or composite monitor. The 5153 has a famous quirk: it deliberately reduces green in colour 6 so that "dark yellow" shows as brown. Programmers also exploited the composite output to produce extra "artifact" colours in games.

**The theme:** light grey on black (the default DOS text colours) with the IBM 8x8 ROM font.

Sources: [Color Graphics Adapter (Wikipedia)](https://en.wikipedia.org/wiki/Color_Graphics_Adapter), [IBM Personal Computer (Wikipedia)](https://en.wikipedia.org/wiki/IBM_Personal_Computer)

<a id="ibm-3278"></a>

## 🏦 IBM 3278

IBM introduced the 3270 terminal family in 1971 for its mainframes, and the 3278 Display Station arrived in May 1977 as part of the second generation. The 3270 design is "block mode": instead of interrupting the mainframe on every keystroke, the terminal holds a whole screen of fields locally and sends only the changed fields when the user presses Enter or a function key. That made it efficient enough to run thousands of terminals for banks, airlines and governments, and 3270 screens are still emulated today. 3278 models offered 80 by 24, 32 or 43 lines, or 132 by 27. The original monochrome models are why these are called "green screens".

**The theme:** bright green on black with the open-source IBM 3270 font, which recreates the terminal's lettering.

Sources: [IBM 3270 (Wikipedia)](https://en.wikipedia.org/wiki/IBM_3270), [IBM 3278 manuals (bitsavers)](https://www.bitsavers.org/pdf/ibm/3278/)

<a id="ibm-p70-plasma"></a>

## 🔶 IBM P70 Plasma

The IBM PS/2 Model P70 386 was introduced in May 1989 as a "luggable" portable: a 20 MHz Intel 386 machine weighing about 21 pounds (around 9.5 kg), with a fold-down keyboard. Instead of a CRT it had a 10-inch monochrome gas-plasma flat panel showing VGA graphics at 640 by 480. A plasma panel is a grid of tiny gas-filled cells between two sheets of glass; applying a voltage across a cell ionises the gas (neon-based), which glows. That neon glow is why these screens are orange-amber, and why they look crisp and evenly lit compared with the backlit LCDs of the time.

**The theme:** orange plasma glow on a dark red-brown background, flat (no tube curvature), with the IBM VGA ROM font.

Sources: [IBM PS/2 portable computers (Wikipedia)](https://en.wikipedia.org/wiki/IBM_PS/2_portable_computers), [Plasma display (Wikipedia)](https://en.wikipedia.org/wiki/Plasma_display)

<a id="apple"></a>

## 🍏 Apple ][

The Apple II went on sale on June 10, 1977. Steve Wozniak designed it, and unlike most earlier hobby computers it came as a finished product in a plastic case, with colour graphics, BASIC built in and expansion slots. It was one of the "1977 Trinity" (with the Commodore PET and TRS-80), and the VisiCalc spreadsheet (1979) made it a serious business tool. The Apple II generated a TV-style composite video signal, so it could be used with a television or a monitor; text mode was 40 by 24, uppercase only, drawn by a Signetics 2513 character-generator ROM with 64 glyphs. Many owners used green-screen monitors, including Apple's own.

**The theme:** bright green on black with Print Char 21, Kreative Software's recreation of the Apple II 40-column character set.

Sources: [Apple II (Wikipedia)](https://en.wikipedia.org/wiki/Apple_II), [Apple II character set (Wikipedia)](https://en.wikipedia.org/wiki/Apple_II_character_set), [The Ultimate Apple II Font (Kreative)](https://kreativekorp.com/software/fonts/apple2/)

<a id="commodore-pet"></a>

## 🐚 Commodore PET

The Commodore PET 2001 was shown at the January 1977 Consumer Electronics Show and shipped from October 1977. Chuck Peddle, who had designed the KIM-1 board, led the design, and Commodore's founder Jack Tramiel pushed the project. It was an all-in-one machine: a MOS 6502 processor, keyboard, built-in cassette recorder and a roughly 9-inch monochrome monitor in one metal case. Text was 40 by 25 characters from a character ROM holding PETSCII, Commodore's ASCII variant full of graphics characters for drawing simple games. The original 2001 used a white phosphor; the 2001-N of 1979 switched to green.

**The theme:** a white P4-style glow with a font built from the PET's character ROM.

Sources: [Commodore PET (Wikipedia)](https://en.wikipedia.org/wiki/Commodore_PET), [PETSCII (Wikipedia)](https://en.wikipedia.org/wiki/PETSCII)

<a id="commodore-64"></a>

## 🕹️ Commodore 64

The Commodore 64, announced in January 1982, became one of the best-selling single computer models ever. Its graphics came from the VIC-II chip, designed by Albert Charpentier and Charles Winterble at MOS Technology: a 16-colour palette, 320 by 200 pixels, a 40 by 25 text mode, eight hardware sprites and smooth scrolling. Many owners used the Commodore 1702 monitor, a JVC-built set whose separate luminance and chrominance inputs gave a much sharper picture than an RF connection to a TV. The famous power-on screen is light blue text on a dark blue background inside a light blue border.

**The theme:** light blue on blue using the "Pepto" palette (a careful measurement of the VIC-II's colours) and a C64 ROM-style font.

Sources: [Commodore 64 (Wikipedia)](https://en.wikipedia.org/wiki/Commodore_64), [MOS Technology VIC-II (Wikipedia)](https://en.wikipedia.org/wiki/MOS_Technology_VIC-II), [Commodore 1702 (C64-Wiki)](https://www.c64-wiki.com/wiki/1702)

<a id="atari-800"></a>

## 🚀 Atari 800

Atari announced its home computers in December 1978, showed the Atari 400 and 800 at the January 1979 Consumer Electronics Show, and shipped them in November 1979. Jay Miner created their two-chip display design. ANTIC is a small processor of its own that runs a "display list", one instruction per row, fetching screen data from memory by DMA so the main CPU does not have to. It passes a pixel stream to CTIA (in early machines) or GTIA (later), which applies colours and draws sprites ("player/missile graphics"). The text character set lives in ROM, but a register can point it at RAM for custom characters, a trick many games used.

**The theme:** light blue text on Atari's default dark blue, with an Atari ROM-style font.

Sources: [Atari 8-bit computers (Wikipedia)](https://en.wikipedia.org/wiki/Atari_8-bit_computers), [ANTIC (Wikipedia)](https://en.wikipedia.org/wiki/ANTIC)

<a id="amiga-500"></a>

## 💾 Amiga 500

The Amiga 500 launched in Europe in spring 1987 and in North America and the UK that October, at US$699. It was the affordable, keyboard-in-one version of the Amiga, and it became a hugely popular games and creative machine, especially in Europe. Its Original Chip Set (Agnus, Denise and Paula) handled graphics, sound and memory access, leaving the Motorola 68000 free. It plugged into a monitor or, through an adapter, a TV. From October 1988 units shipped with AmigaOS 1.3, whose Workbench desktop used a four-colour palette of blue, white, black and orange, with the Topaz font built into the Kickstart ROM.

**The theme:** white text on Workbench 1.3 blue, in the Topaz font.

Sources: [Amiga 500 (Wikipedia)](https://en.wikipedia.org/wiki/Amiga_500), [Original Chip Set (Wikipedia)](https://en.wikipedia.org/wiki/Original_Chip_Set), [Workbench (AmigaOS) (Wikipedia)](https://en.wikipedia.org/wiki/Workbench_(AmigaOS))

<a id="tektronix-4014"></a>

## 📈 Tektronix 4014

Tektronix introduced the 4014 in 1974 as the top model of its 4010 graphics terminal family (the 4010 itself dates from 1972). Its 19-inch screen was a direct-view bistable storage tube. A "write gun" draws lines on the screen, leaving a charge pattern on the phosphor layer, while a "flood gun" bathes the whole screen in low-energy electrons that keep exactly those charged spots glowing. The picture stays put without the computer redrawing it, which avoided the then-huge cost of display memory; clearing the screen produces a distinctive bright flash. The 4014 drew vectors at 1024 by 1024 addressable points, or 4096 by 4096 with the Enhanced Graphics Module, and was a standard tool in computer-aided design.

**The theme:** green storage-tube glow on dark green, using the colours of the tek4010 emulator.

Sources: [Tektronix 4010 (Wikipedia)](https://en.wikipedia.org/wiki/Tektronix_4010), [Tektronix 4014 (TekWiki)](https://w140.com/tekwiki/wiki/4014), [Tektronix 4014 (UvA Computer Museum)](https://ub.fnwi.uva.nl/computermuseum/tek4014.html)

<a id="xerox-alto"></a>

## 🖱️ Xerox Alto

The Alto was built at Xerox's Palo Alto Research Center (PARC), with the first machines running on March 1, 1973. The idea came from a 1972 memo by Butler Lampson, and Charles P. Thacker designed most of the hardware (he later received the Turing Award). It is regarded as one of the first personal workstations: it pioneered the graphical user interface, the mouse, Ethernet networking, Smalltalk, and WYSIWYG editing, and it strongly influenced the Xerox Star, Apple Lisa and Macintosh. Its black-and-white CRT was mounted in portrait orientation at 606 by 808 pixels, every pixel drawn from main memory: a bitmap display, unusual for the time. About 2,000 were built.

**The theme:** black text on a white page using the ContrAlto emulator's colours and an Alto monospace font.

Sources: [Xerox Alto (Wikipedia)](https://en.wikipedia.org/wiki/Xerox_Alto), [ContrAlto emulator (Living Computers Museum, GitHub)](https://github.com/livingcomputermuseum/ContrAlto)

<a id="sun-sparcstation-20"></a>

## ☀️ Sun SPARCstation 20

Sun Microsystems released the SPARCstation 20 (codename Kodiak) on March 29, 1994. It was a workhorse Unix workstation and server: up to four SuperSPARC or hyperSPARC processors in a low "pizza box" case, running SunOS and Solaris. Graphics came from an SX framebuffer on a video SIMM (up to 1280 by 1024 in 24-bit colour) or from SBus cards. Before the windowing system starts, a Sun's console, including the OpenBoot PROM prompt, is drawn in a large 12 by 22 pixel bitmap font called Gallant. It is black text on a white background, which surprises people who expect terminals to be dark. Gallant's designer is not documented.

**The theme:** the Sun console look: black on white in the Gallant font.

Sources: [SPARCstation 20 (Wikipedia)](https://en.wikipedia.org/wiki/SPARCstation_20), [Gallant font port description (FreeBSD)](https://cgit.freebsd.org/ports/tree/x11-fonts/gallant/pkg-descr)

<a id="sgi-indigo2"></a>

## 🧊 SGI Indigo2

Silicon Graphics' Indigo2 (codename Fullhouse) went on sale in 1992-93 (sources differ on the exact date) and stayed in production until 1997. It was SGI's mainstream 3D workstation of the mid-1990s, built on MIPS processors (R4000 up to R10000) with graphics options from XL and Elan to Extreme and the later IMPACT boards. The standard case was teal and the IMPACT models purple. It ran IRIX, SGI's Unix, whose desktop opened a shell window called winterm. IRIX workstations like this were common in visual-effects studios, scientific visualisation and engineering design.

**The theme:** IRIX winterm colours (pale cream text on deep navy blue).

Sources: [SGI Indigo2 and Challenge M (Wikipedia)](https://en.wikipedia.org/wiki/SGI_Indigo2_and_Challenge_M), [IRIX (Wikipedia)](https://en.wikipedia.org/wiki/IRIX)

<a id="sgi-octane"></a>

## 🔷 SGI Octane

The Octane (codename "Racer") was released in 1997 as the Indigo2's successor and was sold until 2004. It used MIPS R10000, and later R12000 and R14000, processors in single or dual CPU modules. Graphics began with the IMPACT family carried over from the Indigo2 (SI, SSI, MXI and their improved E versions), and later the VPro boards (V6 to V12). It also offered video and audio I/O options that made it popular for media work. Octanes ran IRIX 6.5, the last major IRIX release, whose winterm shell window is what this theme is based on.

**The theme:** IRIX 6.5 winterm colours (pale cream text on deep navy blue).

Sources: [SGI Octane (Wikipedia)](https://en.wikipedia.org/wiki/SGI_Octane), [IRIX (Wikipedia)](https://en.wikipedia.org/wiki/IRIX)

<a id="nextcube"></a>

## ⬛ NeXTcube

NeXT, the company Steve Jobs founded after leaving Apple, launched the NeXTcube in September 1990. Its magnesium cube case was designed by frog design, and inside was a 25 MHz Motorola 68040 plus a Motorola DSP56001 signal processor. It ran NeXTSTEP, an object-oriented Unix system whose ideas later became the base of macOS. Tim Berners-Lee used a NeXT machine at CERN to create and host the first World Wide Web server and browser. The standard MegaPixel Display was a 17-inch greyscale CRT at 1120 by 832 pixels with four shades of grey (2 bits per pixel).

**The theme:** black text on light grey. The exact grey is an estimate.

Sources: [NeXTcube (Wikipedia)](https://en.wikipedia.org/wiki/NeXTcube), [NeXT Computer (Wikipedia)](https://en.wikipedia.org/wiki/NeXT_Computer)

<a id="cray-1"></a>

## ❄️ Cray-1

The Cray-1, designed by Seymour Cray with Lester Davis as chief engineer, was delivered as serial number 001 to Los Alamos National Laboratory in 1976. It became the most famous supercomputer of its era, thanks to its vector processing and its C-shaped tower with a padded bench around the base. It had no screen of its own. A minicomputer, the Maintenance Control Unit, booted the Cray Operating System, monitored the machine and could act as a front end: the first was a Data General SuperNova S/200, and most Cray-1A systems shipped with a Data General Eclipse instead. Operators worked through terminals attached to that minicomputer.

**The theme:** a green console glow with the Glass TTY font. The exact console terminal is not documented, so this look is an estimate.

Sources: [Cray-1 (Wikipedia)](https://en.wikipedia.org/wiki/Cray-1), [Cray-1 (Computer History Museum)](https://www.computerhistory.org/revolution/supercomputers/10/7)

<a id="ibm-system-360"></a>

## 🏛️ IBM System/360

IBM announced the System/360 on April 7, 1964: a family of compatible mainframes, from small to large, that could all run the same software. That idea of a compatible architecture reshaped the industry, and today's IBM Z mainframes can still run System/360 programs. One of its display terminals was the IBM 2260, released in 1964. The Model 1 showed 12 rows of 80 characters on a monochrome text-only CRT. It had no memory of its own: the attached 2848 Display Control kept the screen contents in an acoustic delay line (a coiled wire where data circulates as sound pulses) and continually refreshed the picture from it.

**The theme:** green text in the IBM 3270 font. The 2260's phosphor colour is not documented in our sources, so this is an estimate.

Sources: [IBM System/360 (Wikipedia)](https://en.wikipedia.org/wiki/IBM_System/360), [IBM 2260 (Wikipedia)](https://en.wikipedia.org/wiki/IBM_2260)

<a id="dec-pdp-11"></a>

## 📟 DEC PDP-11

DEC announced the PDP-11 family of 16-bit minicomputers in January 1970. Harold McFarland and Larry McGowan shaped the architecture, and Jim O'Loughlin designed the first processor, the PDP-11/20. Its clean instruction set and its Unibus (an open, memory-mapped bus that made it easy to build peripherals) made it a favourite in labs, universities and industry. Unix was developed on the PDP-11 in the early 1970s, as was the C language. About 600,000 PDP-11s of all models were sold. Consoles ranged from DECwriter printing terminals to video terminals such as the VT52 and VT100.

**The theme:** a VT100-style white glow on black with the Glass TTY font, as if the PDP-11's console were a VT100.

Sources: [PDP-11 (Wikipedia)](https://en.wikipedia.org/wiki/PDP-11), [VT100 (Wikipedia)](https://en.wikipedia.org/wiki/VT100)

<a id="apollo-dn10000"></a>

## 🛰️ Apollo DN10000

Apollo Computer built networked workstations from about 1980 to 1989, running its own operating system, Aegis (later Domain/OS), with a windowing system called the Display Manager built in from the start. The DN10000, introduced in 1988 at $79,900 to $235,900, was its high-end machine: one to four of Apollo's own PRISM RISC processors. It was fast for its day, but only around a thousand were sold. Hewlett-Packard bought Apollo in 1989 and PRISM development stopped.

**The theme:** dark text on a light Display Manager window. The colours are an estimate.

Sources: [Apollo/Domain (Wikipedia)](https://en.wikipedia.org/wiki/Apollo/Domain), [Apollo PRISM (Wikipedia)](https://en.wikipedia.org/wiki/Apollo_PRISM), [HP Apollo Domain 10000 (OpenPA)](https://www.openpa.net/systems/hp_apollo_series_domain_10000_dn10000.html)

<a id="ibm-5100"></a>

## 💼 IBM 5100

IBM's General Systems Division announced the 5100 Portable Computer in September 1975. It grew out of SCAMP, a 1973 prototype built at IBM's Los Gatos and Palo Alto labs with Dr. Paul Friedl leading the engineering team. The 5100 weighed about 55 pounds (25 kg) and cost $8,975 to $19,975. It came with APL, BASIC or both, chosen by a front-panel switch. Rather than rewrite them, IBM ran adapted versions of its System/370 APL and System/3 BASIC on an emulation layer in microcode. Its built-in 5-inch CRT showed 16 lines of 64 characters, and a switch could show only the left or right 32 characters of each line.

**The theme:** pale green-white text on black in the IBM 3270 font. The exact phosphor tint is an estimate.

Sources: [IBM 5100 (Wikipedia)](https://en.wikipedia.org/wiki/IBM_5100)

<a id="altair-8800"></a>

## 💡 Altair 8800

The MITS Altair 8800 was the cover story of the January 1975 issue of Popular Electronics, and it set off the personal computer boom. Ed Roberts' company, MITS, sold it mainly as a kit built around the Intel 8080. Out of the box it had only toggle switches and red LEDs on its front panel. To do anything more you added a serial card and a terminal, very often a Teletype Model 33 ASR. Bill Gates and Paul Allen wrote Altair BASIC for it, Microsoft's first product, and its expansion connector became the S-100 bus standard. The Teletype Model 33 (introduced 1963) was an electromechanical teleprinter: it typed in uppercase only, about 10 characters per second at 110 baud, on rolls of paper about 72 characters wide, and the ASR version had a paper-tape reader and punch for saving programs.

**The theme:** dark ink on cream teletype paper, in a Teletype Model 33-style font.

Sources: [Altair 8800 (Wikipedia)](https://en.wikipedia.org/wiki/Altair_8800), [Teletype Model 33 (Wikipedia)](https://en.wikipedia.org/wiki/Teletype_Model_33)

<a id="imsai-8080"></a>

## 🎛️ IMSAI 8080

The IMSAI 8080 shipped as a kit from December 16, 1975. IMS Associates, founded by William Millard, with Joe Killian as chief engineer, built it as an improved clone of the Altair 8800 using the same S-100 bus and Intel 8080, with a sturdier power supply and a front panel of colourful paddle switches. It is widely considered the first "clone" microcomputer. In 1977 IMSAI licensed Gary Kildall's CP/M operating system and sold a version as IMDOS, making it the first commercial supplier of CP/M. Like the Altair it had no display of its own; a terminal such as the Teletype ASR-33 did the input and output.

**The theme:** dark ink on cream teletype paper, in a Teletype Model 33-style font.

Sources: [IMSAI 8080 (Wikipedia)](https://en.wikipedia.org/wiki/IMSAI_8080), [Teletype Model 33 (Wikipedia)](https://en.wikipedia.org/wiki/Teletype_Model_33)

<a id="amiga-1000"></a>

## ✍️ Amiga 1000

The Amiga 1000 was launched on July 23, 1985, at a Lincoln Center event in New York. It came from Amiga Corporation, a small company with Jay Miner as its lead chip designer, which Commodore bought before the launch. With a Motorola 68000, custom graphics and sound chips, and a pre-emptive multitasking operating system, it was far ahead of most personal computers of its day. Because the operating system was not finished in time, the core of it (Kickstart) was loaded from a floppy disk into protected RAM at power-on instead of being in ROM. The design team's signatures are moulded inside the case lid.

**The theme:** white text on Workbench 1.x blue, in the Topaz font.

Sources: [Amiga 1000 (Wikipedia)](https://en.wikipedia.org/wiki/Amiga_1000), [Jay Miner (Wikipedia)](https://en.wikipedia.org/wiki/Jay_Miner)

<a id="apple-lisa"></a>

## 🍎 Apple Lisa

Apple announced the Lisa on January 19, 1983, and shipped it that June for US$9,995. It was the first mass-market computer to be run through a graphical user interface, with windows, icons and a mouse, following ideas seen at Xerox PARC. John Couch directed the project and Larry Tesler was in charge of system software. Its built-in 12-inch monochrome screen showed 720 by 364 pixels that were rectangular rather than square. The Lisa was a commercial failure because of its price, but much of its work fed into the Macintosh. Its Office System included LisaTerminal, a terminal emulator.

**The theme:** black on white with a font based on LisaTerminal's.

Sources: [Apple Lisa (Wikipedia)](https://en.wikipedia.org/wiki/Apple_Lisa), [Apple Lisa (Computer History Museum)](https://computerhistory.org/blog/the-lisa-apples-most-influential-failure/)

<a id="grid-compass"></a>

## 🛸 GRiD Compass

The GRiD Compass 1101, introduced in April 1982 for US$8,150, is often called the first clamshell laptop: a screen folding flat over the keyboard in a magnesium case. Bill Moggridge designed it for John Ellenby's GRiD Systems Corporation. Instead of a CRT it had a 320 by 240 electroluminescent (EL) flat panel. In an EL panel a thin layer of phosphor (typically zinc sulphide doped with manganese, which glows yellow-orange) sits between electrode grids, and lights up wherever an electric field is applied across it, with no electron beam at all. NASA flew the Compass on the Space Shuttle in the 1980s, including on Discovery's STS-51-G mission in 1985.

**The theme:** amber-orange EL glow on a near-black panel, flat.

Sources: [GRiD Compass (Wikipedia)](https://en.wikipedia.org/wiki/GRiD_Compass), [Electroluminescent display (Wikipedia)](https://en.wikipedia.org/wiki/Electroluminescent_display)

<a id="symbolics-3600"></a>

## λ Symbolics 3600

Symbolics was a spinoff of the MIT AI Lab, set up to build Lisp machines: computers whose hardware and whole operating system were designed around the Lisp language, used for artificial-intelligence research and advanced software development. Its first product, the LM-2 (1981), was a repackaged MIT CADR. The 3600 family followed in 1983 with Symbolics' own design. Its operating system, written entirely in Lisp, was named Genera around 1984. The 3600 used a large bitmapped black-and-white monitor as its console (colour displays were optional). A small footnote: symbolics.com, registered on 15 March 1985, was the first .com domain.

**The theme:** dark text on a pale screen. The exact colours are an estimate.

Sources: [Symbolics (Wikipedia)](https://en.wikipedia.org/wiki/Symbolics), [Genera (Wikipedia)](https://en.wikipedia.org/wiki/Genera_(operating_system))

<a id="thinking-machines-cm-5"></a>

## 🔴 Thinking Machines CM-5

Thinking Machines Corporation was founded in 1983 by Danny Hillis, who invented the Connection Machine, and Sheryl Handler. The CM-5, announced in 1991, was a massively parallel supercomputer, and in June 1993 a 1024-processor CM-5 topped the TOP500 list of the world's fastest computers. The architect and sculptor Maya Lin contributed to its design. Its black towers were covered in panels of red LEDs, which could show random moving patterns for show or reflect what the processing nodes were doing. A CM-5 appears in the control room in the film Jurassic Park.

**The theme:** red LED glow on black, flat (an LED grid rather than a tube).

Sources: [Connection Machine (Wikipedia)](https://en.wikipedia.org/wiki/Connection_Machine), [TOP500 list, June 1993](https://www.top500.org/lists/top500/1993/06/)

---

# More machines

<a id="dec-vt320-amber"></a>

## 🟧 DEC VT320 Amber

DEC introduced the VT300 series, including the VT320, in 1987 as a cheaper follow-up to the VT220, priced at $545. It kept DEC's VT command set and was common on VAX systems into the 1990s, available with amber, green or white screens. The VT320 lives on today through the VT323 font: Peter Hull built it from the VT320 glyphs he used in college, and he even simulated how the CRT's beam smeared the non-square pixels horizontally. VT323 is free on Google Fonts.

**The theme:** P3 amber on dark brown-black with the VT323 font.

Sources: [VT220 (Wikipedia, covers the VT300 series)](https://en.wikipedia.org/wiki/VT220), [VT323 (Google Fonts)](https://fonts.google.com/specimen/VT323/about)

<a id="ms-dos-norton-blue"></a>

## 📁 MS-DOS Norton Blue

Norton Commander was a two-panel file manager for MS-DOS, written by John Socha (who started it in 1984 under the working name "Visual DOS") and released by Peter Norton Computing in 1986. Its layout, two side-by-side file lists with function-key commands along the bottom, created a whole genre of "orthodox" file managers that lives on in Midnight Commander and Far Manager. Its blue panels with cyan text became one of the defining looks of DOS. It ran in text mode, typically on VGA displays by the late 1980s, which drew 80 by 25 characters from a 16-colour palette.

**The theme:** bright cyan on blue from the VGA palette, in the IBM VGA ROM font.

Sources: [Norton Commander (Wikipedia)](https://en.wikipedia.org/wiki/Norton_Commander), [Video Graphics Array (Wikipedia)](https://en.wikipedia.org/wiki/Video_Graphics_Array)

<a id="hercules-amber"></a>

## 🟡 Hercules Amber

The Hercules Graphics Card (1982) was created by Van Suwannukul, who founded Hercules Computer Technology because he wanted to write his doctoral thesis in the Thai alphabet on an IBM PC. Neither IBM card could do it: CGA's resolution was too low and MDA could not draw anything outside its fixed character set. Hercules behaved exactly like an MDA in text mode but added a 720 by 348 graphics mode on the same monochrome monitors, so business users got sharp text and graphics on one screen. It became a de facto standard. Monochrome PC monitors of the period came in green, amber and white.

**The theme:** P3 amber on dark brown-black with the IBM VGA ROM font.

Sources: [Hercules Graphics Card (Wikipedia)](https://en.wikipedia.org/wiki/Hercules_Graphics_Card), [IBM 5151 (Wikipedia)](https://en.wikipedia.org/wiki/IBM_5151)

<a id="zx-spectrum"></a>

## 🌈 ZX Spectrum

Sinclair Research launched the ZX Spectrum on 23 April 1982 at £125 (16 KB) or £175 (48 KB), and it became the defining home computer of 1980s Britain. Richard Altwasser was the chief hardware engineer and designed its custom ULA chip and its colour-attribute system. Steve Vickers of Nine Tiles wrote most of the ROM, including Sinclair BASIC, and Rick Dickinson designed the case and rubber keyboard. The Spectrum connected to a home TV through an RF modulator. Its 256 by 192 picture stored colour separately in 8 by 8 pixel cells, each with one ink and one paper colour, which caused the famous "attribute clash".

**The theme:** black ink on the Spectrum's light grey paper, in a font from its ROM.

Sources: [ZX Spectrum (Wikipedia)](https://en.wikipedia.org/wiki/ZX_Spectrum), [ZX Spectrum graphic modes (Wikipedia)](https://en.wikipedia.org/wiki/ZX_Spectrum_graphic_modes)

<a id="amstrad-cpc-464"></a>

## 💛 Amstrad CPC 464

Alan Sugar's Amstrad launched the CPC 464 in 1984 as an all-in-one package: computer and keyboard with a built-in cassette deck, sold together with either a green-screen monitor (£199) or a colour monitor (£299), with the monitor also supplying power. That "plug it in and it works" approach was a big part of its success. Roland Perry was one of the lead designers of the CPC range, and Locomotive Software supplied its BASIC. Graphics came from a Motorola 6845 CRT controller, with three modes chosen from a 27-colour palette. The power-on screen shows bright yellow text on dark blue.

**The theme:** the firmware's yellow on blue with a font from the CPC ROM.

Sources: [Amstrad CPC (Wikipedia)](https://en.wikipedia.org/wiki/Amstrad_CPC), [Amstrad CPC 464 (Wikipedia)](https://en.wikipedia.org/wiki/Amstrad_CPC_464)

<a id="bbc-micro-teletext"></a>

## 📺 BBC Micro Teletext

Acorn Computers built the BBC Micro for the BBC's Computer Literacy Project, launching it on 1 December 1981. Steve Furber and Sophie Wilson were key members of the design team. It sold over 1.5 million units, and by 1985 about 80% of British schools had one. Mode 7 was a BBC requirement: the BBC ran Ceefax, the teletext service broadcast alongside TV pictures, and Mode 7 used the same Mullard SAA5050 teletext character chip. The screen is 40 by 25 characters stored as codes in just 1 KB of RAM. The SAA5050 designs each letter on a 5 by 9 grid and smooths the diagonals to 10 by 18, which gives teletext its angular, rounded look.

**The theme:** white on black with a font based on the SAA5050 characters.

Sources: [BBC Micro (Wikipedia)](https://en.wikipedia.org/wiki/BBC_Micro), [Mullard SAA5050 (Wikipedia)](https://en.wikipedia.org/wiki/Mullard_SAA5050), [Ceefax (Wikipedia)](https://en.wikipedia.org/wiki/Ceefax)

---

# Looks from cool-retro-term

[cool-retro-term](https://github.com/Swordfish90/cool-retro-term) is a free terminal emulator by Filippo Scognamiglio (Swordfish90) and contributors that imitates old CRT screens, and BURNIN's shader is a port of its code. These themes copy its built-in profiles. They are styles, not specific machines.

<a id="default-amber"></a>

## 🔥 Default Amber

cool-retro-term's default profile: orange-amber text (#ff8100) on black with a strong glow. It is inspired by the amber monochrome monitors of the 1980s, whose P3-type phosphor many people found more restful than green or white. It is not modelled on one particular terminal. BURNIN uses the same colours with the Terminess font and a fairly flat tube.

Source: [cool-retro-term (GitHub)](https://github.com/Swordfish90/cool-retro-term)

<a id="monochrome-green"></a>

## 🌿 Monochrome Green

A generic green-screen look from cool-retro-term (#0ccc68 on black), recalling the P1 and P39 green monochrome monitors and terminals of the 1970s and 80s. As in cool-retro-term, it uses the Departure Mono pixel font. Think of it as "a green terminal" rather than any one model.

Source: [cool-retro-term (GitHub)](https://github.com/Swordfish90/cool-retro-term)

<a id="deep-blue"></a>

## 🔵 Deep Blue

A cool blue-white glow (#7fb4ff on black) with the BigBlue Terminal font, a pixel font in the spirit of the IBM PC's code page 437 characters. It is a stylised look from cool-retro-term rather than a recreation of a real phosphor or machine.

Source: [cool-retro-term (GitHub)](https://github.com/Swordfish90/cool-retro-term)

<a id="neon-cyan"></a>

## 🧪 Neon Cyan

A modern, sci-fi style cyan (#52f7ff) on a very dark blue-black, using the Iosevka font. This one is pure style: a "neon" terminal of the kind seen in films and games, not a historic display. BURNIN renders it flat, without tube curvature.

Source: [cool-retro-term (GitHub)](https://github.com/Swordfish90/cool-retro-term)

<a id="plasma"></a>

## 💗 Plasma

Pink text (#ff9bd6) on a deep violet-black, with the Fira Code font and a strong glow. Despite the name, it does not imitate the orange gas-plasma screens of real 1980s portables (see the IBM P70 Plasma theme for that); it is a colourful stylised look from cool-retro-term.

Source: [cool-retro-term (GitHub)](https://github.com/Swordfish90/cool-retro-term)

<a id="ghost-terminal"></a>

## 👻 Ghost Terminal

A soft blue-grey (#a6b3c0) on dark slate with no flicker, using the JetBrains Mono font. It is a quiet, low-contrast style from cool-retro-term, like a faded or dimmed screen, and not modelled on any particular machine.

Source: [cool-retro-term (GitHub)](https://github.com/Swordfish90/cool-retro-term)

<a id="boring"></a>

## ⬜ Boring

Plain white on black with JetBrains Mono and no flicker: cool-retro-term's "just a terminal" profile, for when you want the clean modern look with only a hint of CRT. It is a style, not a machine.

Source: [cool-retro-term (GitHub)](https://github.com/Swordfish90/cool-retro-term)

<a id="e-ink"></a>

## 📖 E-Ink

Near-black text (#101010) on an off-white paper tone (#f2f2ec) with the Hack font and no glow. It suggests an electronic-paper screen like an e-reader, where tiny charged pigment particles are moved to show an image and reflect room light instead of emitting their own. It is a style from cool-retro-term, not a recreation of a specific device.

Sources: [cool-retro-term (GitHub)](https://github.com/Swordfish90/cool-retro-term), [Electronic paper (Wikipedia)](https://en.wikipedia.org/wiki/Electronic_paper)

---

# Sources

Each section above lists its own sources. Dates and details follow those sources. Where a theme's colours are an estimate, because no reliable record of the original screen exists, the section says so. If you spot a mistake or have a better source (a manual on bitsavers, a museum page, a photo of a real screen), corrections are very welcome: please open an issue.
