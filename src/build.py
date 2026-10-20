"""Builds dist/ from themes/themes.json:

  dist/windows-terminal/{historic,flat}/<slug>.hlsl   Windows Terminal pixel shaders
  dist/ghostty/{historic,flat}/<slug>.glsl            Ghostty custom shaders
  dist/themes-index.json                              per theme: names, colours, cursor, font family per platform, fitted size

Font metrics (family names, fitted sizes) need the fonts, so the build downloads them into a cache
(the same sources the installers use; nothing is redistributed). ROM fonts are built with retro_fonts.py.

Usage:  python src/build.py [--cache DIR]
Needs:  fonttools  (pip install fonttools)
"""
import argparse
import io
import json
import math
import re
import sys
import urllib.request
import zipfile
from pathlib import Path

from fontTools.ttLib import TTFont

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "src"))
import retro_fonts  # noqa: E402

UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36"
STANDARD_STYLES = {"regular", "medium", "book", "normal", "roman"}


def slug(name):
    return re.sub(r"[^A-Za-z0-9]+", "-", name).strip("-").lower()


def num(v):
    s = f"{float(v):.4f}".rstrip("0")
    return s + "0" if s.endswith(".") else s


def colour(hexstr, ctor):
    h = hexstr.lstrip("#")
    parts = [num(round(int(h[i:i + 2], 16) / 255.0, 3)) for i in (0, 2, 4)]
    return f"{ctor}({', '.join(parts)})"


def set_define(src, name, value, comment=None):
    rx = re.compile(rf"^(#define {name}\s+)(.*?)(\s+//.*)?$", re.M)
    if not rx.search(src):
        raise SystemExit(f"define {name} not found")
    return rx.sub(lambda m: m.group(1) + value + (f"   // {comment}" if comment else (m.group(3) or "")), src, count=1)


def shader(template, t, ctor, curvature):
    x = template.replace("__NAME__", f"{t['name']} - {t['note']}")
    x = set_define(x, "FONT_COLOR", colour(t["fg"], ctor), t["fg"])
    x = set_define(x, "BACK_COLOR", colour(t["bg"], ctor), t["bg"])
    x = set_define(x, "CHROMA", num(t["chroma"]))
    x = set_define(x, "KEEP_ACCENTS", num(t["accents"]))
    x = set_define(x, "ACCENT_SCALE", num(0.55 if t.get("light") else 1.0))
    x = set_define(x, "BLOOM_GAIN", num(t["bloom"] * 2.5))
    x = set_define(x, "STATIC_NOISE", num(t["noise"]))
    x = set_define(x, "GLOWING_LINE", num(t["line"]))
    x = set_define(x, "FLICKERING", num(t["flicker"]))
    x = set_define(x, "JITTER", num(t["jitter"]))
    x = set_define(x, "HORIZONTAL_SYNC", num(t["hSync"]))
    x = set_define(x, "AMBIENT_LIGHT", num(t["ambient"]))
    x = set_define(x, "RGB_SHIFT", num(t["rgbShift"] * 3 * t["pixel"]))
    x = set_define(x, "RASTER", str(int(t["raster"])))
    x = set_define(x, "PIXEL_SIZE", num(t["pixel"]))
    x = set_define(x, "RASTER_STRENGTH", num(t["scanStrength"]))
    x = set_define(x, "BURN_IN", num(t.get("burn", 0.0 if t.get("light") else 0.35)))   # paper/LCD looks: no phosphor
    # cool-retro-term curvature * its 0.6 size factor, in this shader's units (* 0.25)
    return set_define(x, "CURVATURE", num(curvature))


def fetch(url, user_agent=False):
    req = urllib.request.Request(url, headers={"User-Agent": UA})   # some font sites refuse urllib's default agent
    with urllib.request.urlopen(req, timeout=120) as r:
        return r.read()


def font_file(key, spec, cache, roms):
    """Returns the path of the font in the cache, downloading or building it if needed."""
    if "build" in spec:
        path = cache / spec["build"]
        if not path.exists():
            rom_dir = cache / "roms"
            rom_dir.mkdir(exist_ok=True)
            files = {}
            for name, url in roms.items():
                p = rom_dir / name
                if not p.exists():
                    p.write_bytes(fetch(url))
                files[name] = p
            retro_fonts.build_all(files, cache)
        return path
    url = spec["url"]
    name = Path(spec["member"]).name if "member" in spec else Path(urllib.request.url2pathname(url.split("?")[0])).name
    path = cache / name
    if not path.exists():
        data = fetch(url, spec.get("userAgent", False))
        if "member" in spec:
            with zipfile.ZipFile(io.BytesIO(data)) as z:
                data = z.read(spec["member"])
        path.write_bytes(data)
    return path


def families(path, override):
    """(Windows/DirectWrite family, macOS/Linux family) for a font file."""
    if override:
        return override["windows"], override["unix"]
    names = TTFont(str(path), lazy=True)["name"]
    fam = names.getDebugName(16) or names.getDebugName(1)
    sub = names.getDebugName(17)
    win = f"{fam} {sub}" if sub and sub.lower() not in STANDARD_STYLES else fam
    return win, fam


def fit_size(path, cell_w, cell_h, preferred_pt):
    """Largest point size (0.25 pt steps, at 96 dpi) whose '0' advance and line height fit the cell."""
    f = TTFont(str(path), lazy=True)
    upm = f["head"].unitsPerEm
    glyph = f.getBestCmap().get(ord("0"))
    adv = f["hmtx"][glyph][0] / upm
    height = (f["hhea"].ascent - f["hhea"].descent) / upm
    em_px = min(cell_w * 1.04 / adv, cell_h * 1.05 / height)   # slack: terminals round advances; glyphs rarely fill the line
    return min(math.floor(em_px * 0.75 * 4) / 4, preferred_pt)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", default=str(ROOT / ".build-cache"))
    args = ap.parse_args()
    cache = Path(args.cache)
    cache.mkdir(parents=True, exist_ok=True)

    data = json.loads((ROOT / "themes" / "themes.json").read_text(encoding="utf-8"))
    hlsl = (ROOT / "src" / "template.hlsl").read_text(encoding="utf-8").replace("\r\n", "\n")
    glsl = (ROOT / "src" / "template.glsl").read_text(encoding="utf-8").replace("\r\n", "\n")
    cell = data["cell"]

    fonts = {}
    for key, spec in data["fonts"].items():
        path = font_file(key, spec, cache, data["roms"])
        win, unix = families(path, spec.get("families"))
        if "family" in spec:   # explicit name the terminals look up (e.g. Atari Classic Chunky on Windows)
            win = spec["family"]
        fonts[key] = {"path": path, "windows": win, "unix": unix}

    out = ROOT / "dist"
    for sub in ("windows-terminal/historic", "windows-terminal/flat", "ghostty/historic", "ghostty/flat"):
        d = out / sub
        d.mkdir(parents=True, exist_ok=True)
        for old in d.glob("*.*"):
            old.unlink()

    index = []
    for t in data["themes"]:
        s = slug(t["name"])
        curve = float(t.get("curve", 0)) * 0.15
        for kind, k in (("historic", curve), ("flat", 0.0)):
            (out / f"windows-terminal/{kind}/{s}.hlsl").write_text(shader(hlsl, t, "float3", k), encoding="utf-8", newline="\n")
            (out / f"ghostty/{kind}/{s}.glsl").write_text(shader(glsl, t, "vec3", k), encoding="utf-8", newline="\n")
        f = fonts[t["font"]]
        index.append({
            "name": t["name"], "slug": s, "note": t["note"], "fg": t["fg"], "bg": t["bg"],
            "light": bool(t.get("light")), "cursor": t["cursor"], "font": t["font"],
            "fontWindows": f["windows"], "fontUnix": f["unix"],
            "size": fit_size(f["path"], cell["width"], cell["height"], float(t["size"])),
        })
    (out / "themes-index.json").write_text(json.dumps({"cell": cell, "themes": index}, indent=2), encoding="utf-8", newline="\n")

    # Tab-separated copies for the macOS/Linux shell installer and crt-theme (no JSON parser needed there).
    with open(out / "themes.tsv", "w", encoding="utf-8", newline="\n") as tsv:
        tsv.write("# name\tslug\tfont (macOS/Linux)\tsize (pt at 96 dpi)\tcursor\tlight\n")
        for e in index:
            tsv.write(f"{e['name']}\t{e['slug']}\t{e['fontUnix']}\t{e['size']}\t{e['cursor']}\t{int(e['light'])}\n")
    with open(out / "fonts.tsv", "w", encoding="utf-8", newline="\n") as tsv:
        tsv.write("# key\tfile\turl (or 'build')\tzip member (- = none)\tneeds browser user agent\n")
        for key, spec in data["fonts"].items():
            if "build" in spec:
                tsv.write(f"{key}\t{spec['build']}\tbuild\t-\t0\n")
            else:
                name = Path(spec["member"]).name if "member" in spec else Path(spec["url"].split("?")[0]).name
                tsv.write(f"{key}\t{name}\t{spec['url']}\t{spec.get('member') or '-'}\t{int(bool(spec.get('userAgent')))}\n")
    with open(out / "roms.tsv", "w", encoding="utf-8", newline="\n") as tsv:
        tsv.write("# file\turl\n")
        for name, url in data["roms"].items():
            tsv.write(f"{name}\t{url}\n")
    print(f"built {len(index)} themes x 2 bulge settings x 2 terminals = {len(index) * 4} shaders")


if __name__ == "__main__":
    main()
