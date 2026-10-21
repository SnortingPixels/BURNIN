"""Builds pixel-exact TrueType fonts from original character data:

  ZX Spectrum ROM   - 48K ROM character set at 0x3D00 (96 chars, 8x8)
  Amstrad CPC ROM   - CPC 464 OS ROM character set at 0x3800 (8x8)
  BBC Teletext      - SAA5050 teletext characters (6x10) from jsbeeb's teletext_data.js (via b-em)
  Virtual Boy       - VUEngine's default 8x8 font (Default.font, JSON; MIT); the console has no built-in font
  Elektronika 15IE  - the Soviet DVK terminal's 8x8 character generator (hoard-of-bitfonts dvk_15ie.draw), KOI-8

Each lit pixel row becomes a solid rectangle, so the font draws exactly the original bitmaps.
Usage: python retro_fonts.py <48.rom> <cpc464.rom> <teletext_data.js> [<vuengine.font>] [<dvk_15ie.draw>] <out dir>
"""
import re
import sys
from pathlib import Path

from fontTools.fontBuilder import FontBuilder
from fontTools.pens.ttGlyphPen import TTGlyphPen

PX = 128  # font units per original pixel


def build(family, out, glyphs, w, h):
    """glyphs: {codepoint: rows (top to bottom, each a list of 0/1 of length w)}"""
    names = {cp: f"uni{cp:04X}" for cp in glyphs}
    order = [".notdef"] + [names[cp] for cp in sorted(glyphs)]
    fb = FontBuilder(unitsPerEm=h * PX, isTTF=True)
    fb.setupGlyphOrder(order)
    fb.setupCharacterMap({cp: names[cp] for cp in glyphs})

    def draw(rows):
        pen = TTGlyphPen(None)
        for y, row in enumerate(rows):
            top, bottom = (h - y) * PX, (h - y - 1) * PX
            x = 0
            while x < w:
                if not row[x]:
                    x += 1
                    continue
                x0 = x
                while x < w and row[x]:
                    x += 1
                # clockwise rectangle (TrueType outer contour)
                pen.moveTo((x0 * PX, bottom))
                pen.lineTo((x0 * PX, top))
                pen.lineTo((x * PX, top))
                pen.lineTo((x * PX, bottom))
                pen.closePath()
        return pen.glyph()

    glyf = {".notdef": draw([[0] * w for _ in range(h)])}
    for cp, rows in glyphs.items():
        glyf[names[cp]] = draw(rows)
    fb.setupGlyf(glyf)
    advance = w * PX
    fb.setupHorizontalMetrics({g: (advance, 0) for g in order})
    fb.setupHorizontalHeader(ascent=h * PX, descent=0)
    ps = family.replace(" ", "")
    fb.setupNameTable({
        "familyName": family,
        "styleName": "Regular",
        "uniqueFontIdentifier": f"{family} Regular",
        "fullName": family,
        "psName": f"{ps}-Regular",
        "version": "Version 1.0",
        "typographicFamily": family,
        "typographicSubfamily": "Regular",
    })
    fb.setupOS2(sTypoAscender=h * PX, sTypoDescender=0, sTypoLineGap=0,
                usWinAscent=h * PX, usWinDescent=0, usWeightClass=400,
                xAvgCharWidth=advance, fsSelection=0x40, achVendID="RTRO")
    fb.setupPost(isFixedPitch=1)
    fb.save(out)
    print(f"{out}: {len(glyphs)} glyphs, {w}x{h}")


def rom_chars(path, base, codes, mapping=None):
    data = Path(path).read_bytes()
    glyphs = {}
    for i, code in enumerate(codes):
        rows = []
        for r in range(8):
            byte = data[base + 8 * i + r]
            rows.append([(byte >> (7 - b)) & 1 for b in range(8)])
        glyphs[(mapping or {}).get(code, code)] = rows
    return glyphs


def teletext_chars(path):
    text = Path(path).read_text(encoding="utf-8")
    body = text[text.index("new Uint8Array(["):]
    body = re.sub(r"//[^\n]*", "", body)  # drop comments (they contain hex codes)
    values = [int(v) for v in re.findall(r"\b[01]\b", body[: body.index("])")])]
    # UK teletext (SAA5050) positions that differ from ASCII -> their real Unicode characters
    uk = {0x23: 0xA3, 0x5B: 0x2190, 0x5C: 0xBD, 0x5D: 0x2192, 0x5E: 0x2191, 0x5F: 0x23,
          0x60: 0x2014, 0x7B: 0xBC, 0x7C: 0x2016, 0x7D: 0xBE, 0x7E: 0xF7, 0x7F: 0x25A0}
    glyphs = {}
    for i, code in enumerate(range(0x20, 0x80)):
        cell = values[i * 60:(i + 1) * 60]
        if len(cell) < 60:
            break
        glyphs[uk.get(code, code)] = [cell[r * 6:(r + 1) * 6] for r in range(10)]
    return glyphs


def vuengine_chars(path):
    import json
    chars = json.loads(Path(path).read_text(encoding="utf-8"))["characters"]
    glyphs = {}
    for code in range(0x20, 0x7F):
        rows = [(r or []) + [None] * 8 for r in (chars[code] or [])] + [[None] * 8] * 8
        glyphs[code] = [[1 if v else 0 for v in r[:8]] for r in rows[:8]]
    return glyphs


def draw_chars(path):
    """hoard-of-bitfonts .draw: "xx:" then rows of # and -. Codes above 0x7F are KOI-8 (Cyrillic)."""
    glyphs, code, rows = {}, None, []
    for line in Path(path).read_text(encoding="utf-8").splitlines() + [""]:
        m = re.match(r"^([0-9a-fA-F]{2}):", line)
        if m or not line.strip():
            if code is not None and rows:
                cp = code if code < 0x80 else ord(bytes([code]).decode("koi8_r"))
                if code >= 0x20 and code != 0x7F:
                    glyphs[cp] = rows
            code, rows = (int(m.group(1), 16), []) if m else (None, [])
        elif code is not None:
            rows.append([1 if c == "#" else 0 for c in line.strip()])
    return glyphs


def build_all(files, out_dir):
    """files: {'48.rom': path, 'cpc464.rom': path, 'teletext_data.js': path, 'vuengine.font': path}"""
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    # Spectrum: 0x60 is the pound sign, 0x7F the copyright sign
    build("ZX Spectrum ROM", str(out / "ZXSpectrumROM.ttf"),
          rom_chars(files["48.rom"], 0x3D00, range(0x20, 0x80), {0x60: 0xA3, 0x7F: 0xA9}), 8, 8)
    build("Amstrad CPC ROM", str(out / "AmstradCPCROM.ttf"),
          rom_chars(files["cpc464.rom"], 0x3800 + 8 * 0x20, range(0x20, 0x7F)), 8, 8)
    build("BBC Teletext SAA5050", str(out / "BBCTeletextSAA5050.ttf"), teletext_chars(files["teletext_data.js"]), 6, 10)
    if "vuengine.font" in files:
        build("Virtual Boy VUEngine", str(out / "VirtualBoyVUEngine.ttf"), vuengine_chars(files["vuengine.font"]), 8, 8)
    if "dvk_15ie.draw" in files:
        build("Elektronika 15IE", str(out / "Elektronika15IE.ttf"), draw_chars(files["dvk_15ie.draw"]), 8, 8)


def main():
    # retro_fonts.py <48.rom> <cpc464.rom> <teletext_data.js> [<vuengine.font>] [<dvk_15ie.draw>] <out dir>
    files = {Path(a).name: a for a in sys.argv[1:-1]}
    build_all(files, sys.argv[-1])


if __name__ == "__main__":
    main()