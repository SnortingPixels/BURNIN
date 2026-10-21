"""Renders a screenshot of every theme for the README (Windows only: uses the real Windows Terminal shaders).

For each theme it draws a sample terminal screen the way Windows Terminal hands it to the shader (white text on
black in the theme's font, 12x26 cells, a few coloured words), runs the theme's shader on it with
tools/render_hlsl.exe, and saves docs/screenshots/<slug>.jpg. Fonts come from the build cache (src/build.py).

    python tools/screenshots.py <render_hlsl.exe>
"""
import json
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / ".build-cache"
OUT = ROOT / "docs" / "screenshots"
COLS, ROWS, CW, CH = 64, 16, 12, 26
TIME = 2.4   # seconds into the animation (rolling band part-way down)

# Windows Terminal "Retro Source" scheme colours (what the shader receives)
WHITE, GREY, GREEN, YELLOW, BLUE, RED, CYAN = (255, 255, 255), (204, 204, 204), (19, 161, 14), (193, 156, 0), (59, 120, 255), (197, 15, 31), (58, 150, 221)


def screen(theme):
    """Lines of (text, colour) segments."""
    return [
        [(f"BURNIN - {theme['name']}", WHITE)],
        [(theme["note"][:COLS], GREY)],
        [],
        [("user@retro", GREEN), (":~$ ", WHITE), ("ls", WHITE)],
        [("README.md  ", WHITE), ("dist/  themes/  src/  ", BLUE), ("install.sh", GREEN)],
        [("user@retro", GREEN), (":~$ ", WHITE), ("cat hello.bas", WHITE)],
        [("10 PRINT \"HELLO, WORLD\"", WHITE)],
        [("20 GOTO 10", WHITE)],
        [("user@retro", GREEN), (":~$ ", WHITE), ("git log --oneline -3", WHITE)],
        [("d0cbadd ", YELLOW), ("CRT shader ported from cool-retro-term", WHITE)],
        [("c8e7296 ", YELLOW), ("Initial commit", WHITE)],
        [("user@retro", GREEN), (":~$ ", WHITE), ("make", WHITE)],
        [("error: ", RED), ("phosphor not warmed up", WHITE)],
        [("user@retro", GREEN), (":~$ ", WHITE), ("█", WHITE)],
    ]


def font_file(spec):
    if "build" in spec:
        return CACHE / spec["build"]
    if "member" in spec:
        return CACHE / Path(spec["member"]).name
    return CACHE / Path(spec["url"].split("?")[0]).name


def draw_source(theme, font_path, size_pt):
    img = Image.new("RGBA", (COLS * CW, ROWS * CH), (0, 0, 0, 255))
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(str(font_path), max(6, round(size_pt * 96 / 72)))
    ascent, descent = font.getmetrics()
    y_off = (CH - (ascent + descent)) // 2
    for row, segments in enumerate(screen(theme), start=1):
        col = 1
        for text, colour in segments:
            for ch in text:
                if col < COLS and ch == "\u2588":   # cursor: a filled block, whatever the font has
                    d.rectangle([col * CW, row * CH + 2, col * CW + CW - 1, row * CH + CH - 3], fill=colour + (255,))
                elif col < COLS:
                    d.text((col * CW, row * CH + y_off), ch, font=font, fill=colour + (255,))
                col += 1
    return img


def main():
    renderer = sys.argv[1]
    data = json.loads((ROOT / "themes" / "themes.json").read_text(encoding="utf-8"))
    index = {t["name"]: t for t in json.loads((ROOT / "dist" / "themes-index.json").read_text(encoding="utf-8"))["themes"]}
    OUT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        for t in data["themes"]:
            info = index[t["name"]]
            src = draw_source(t, font_file(data["fonts"][t["font"]]), info["size"])
            raw_in, raw_out = Path(tmp) / "in.rgba", Path(tmp) / "out.rgba"
            raw_in.write_bytes(src.tobytes())
            shader = ROOT / "dist" / "windows-terminal" / "historic" / f"{info['slug']}.hlsl"
            subprocess.run([renderer, str(shader), str(raw_in), str(src.width), str(src.height), str(TIME), str(raw_out)], check=True)
            shot = Image.frombytes("RGBA", src.size, raw_out.read_bytes()).convert("RGB")
            shot.save(OUT / f"{info['slug']}.jpg", quality=88, optimize=True, progressive=True)   # JPEG: CRT noise makes PNGs huge
            print(info["slug"])


if __name__ == "__main__":
    main()
