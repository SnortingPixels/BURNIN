"""Draws the pixel-art CRT icon (assets/icon.png, assets/icon.ico, assets/icon-1024.png).
Needs Pillow. 32x32 pixel art, scaled up with nearest-neighbour so the pixels stay sharp."""
from pathlib import Path

from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parent.parent
W = H = 32
CASE, CASE_HI, CASE_LO = (214, 205, 182), (236, 230, 212), (150, 140, 118)
BEZEL, GLASS = (60, 56, 50), (14, 9, 2)
AMBER, AMBER_DIM = (255, 154, 31), (150, 80, 12)
OUTLINE = (34, 30, 26)

img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
px = img.load()


def rect(x0, y0, x1, y1, c):
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            px[x, y] = c + (255,)


# monitor case with a little shading, stand and base
rect(2, 3, 29, 24, OUTLINE)
rect(3, 4, 28, 23, CASE)
rect(3, 4, 28, 4, CASE_HI)
rect(3, 4, 3, 23, CASE_HI)
rect(28, 5, 28, 23, CASE_LO)
rect(4, 23, 28, 23, CASE_LO)
rect(12, 25, 19, 26, OUTLINE)
rect(13, 25, 18, 25, CASE_LO)
rect(8, 27, 23, 29, OUTLINE)
rect(9, 27, 22, 28, CASE)
rect(9, 28, 22, 28, CASE_LO)
# bezel and rounded glass
rect(5, 6, 26, 20, BEZEL)
rect(6, 7, 25, 19, GLASS)
for x, y in ((6, 7), (25, 7), (6, 19), (25, 19)):
    px[x, y] = BEZEL + (255,)
# amber prompt "> _" and a line of text
for x, y in ((8, 9), (9, 10), (10, 11), (9, 12), (8, 13)):
    px[x, y] = AMBER + (255,)
rect(12, 13, 15, 13, AMBER)
rect(8, 16, 21, 16, AMBER_DIM)
rect(8, 17, 16, 17, AMBER_DIM)
# power LED
px[25, 22] = AMBER + (255,)


def scaled(size):
    big = img.resize((size, size), Image.NEAREST)
    if size >= 128:
        # soft phosphor glow under the screen pixels
        glow = big.filter(ImageFilter.GaussianBlur(size / 64))
        glow_px = glow.load()
        out = big.copy()
        o = out.load()
        for y in range(size):
            for x in range(size):
                r, g, b, a = o[x, y]
                if (r, g, b) == GLASS:
                    gr, gg, gb, _ = glow_px[x, y]
                    o[x, y] = (max(r, gr // 3), max(g, gg // 3), max(b, gb // 3), a)
        return out
    return big


assets = ROOT / "assets"
assets.mkdir(exist_ok=True)
scaled(256).save(assets / "icon.png")
scaled(1024).save(assets / "icon-1024.png")
scaled(256).save(assets / "icon.ico", sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
print("wrote", ", ".join(p.name for p in sorted(assets.glob("icon*"))))
