#!/usr/bin/env python3
"""Generates the Kindlewake launcher icons into assets/icons/ (needs Pillow: pip install pillow).

Run from the project folder:  python tools/make_icon.py
The PNG files are committed, so you only need this if you want to change the artwork.
Outputs: icon.png (512, project icon), icon_main_192.png (legacy launcher icon),
icon_fg_432.png (adaptive foreground, transparent) and icon_bg_432.png (adaptive background).
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

OUT = Path(__file__).resolve().parent.parent / "assets" / "icons"
SS = 4  # supersampling for smooth edges

SLATE = (22, 27, 30, 255)
SLATE_LIGHT = (38, 46, 50, 255)
PARCHMENT = (214, 196, 150, 255)
STEEL = (178, 186, 190, 255)
STEEL_DARK = (120, 128, 134, 255)
EMBER_OUTER = (196, 72, 30, 255)
EMBER_MID = (236, 140, 42, 255)
EMBER_CORE = (255, 214, 120, 255)


def background(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size), SLATE)
    d = ImageDraw.Draw(img)
    # soft vignette: lighter centre
    for i in range(size // 2, 0, -2):
        t = i / (size / 2)
        c = tuple(int(SLATE[k] + (SLATE_LIGHT[k] - SLATE[k]) * (1 - t)) for k in range(3)) + (255,)
        d.ellipse([size / 2 - i, size / 2 - i, size / 2 + i, size / 2 + i], fill=c)
    return img


def flame(d: ImageDraw.ImageDraw, cx: float, base: float, h: float, w: float, col) -> None:
    # teardrop built from a polygon: wide at the bottom, curling tip at the top
    pts = []
    steps = 40
    for i in range(steps + 1):
        t = i / steps
        y = base - t * h
        half = w * (1 - t) ** 0.8 * (0.6 + 0.4 * (1 - abs(0.35 - t)))
        pts.append((cx - half + (t ** 2) * w * 0.25, y))
    for i in range(steps, -1, -1):
        t = i / steps
        y = base - t * h
        half = w * (1 - t) ** 0.8 * (0.6 + 0.4 * (1 - abs(0.35 - t)))
        pts.append((cx + half + (t ** 2) * w * 0.25, y))
    d.polygon(pts, fill=col)


def foreground(size: int) -> Image.Image:
    s = size * SS
    img = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx = s / 2
    # broken sword: blade pointing up, snapped near the top (the Sundered Vow)
    blade_w = s * 0.075
    top = s * 0.30
    bottom = s * 0.70
    d.polygon([(cx - blade_w, top + s * 0.03), (cx - blade_w * 0.2, top - s * 0.02), (cx + blade_w * 0.5, top + s * 0.05),
               (cx + blade_w, top), (cx + blade_w, bottom), (cx - blade_w, bottom)], fill=STEEL)
    d.polygon([(cx, top + s * 0.01), (cx + blade_w, top), (cx + blade_w, bottom), (cx, bottom)], fill=STEEL_DARK)
    # cross-guard and grip
    d.rectangle([cx - s * 0.20, bottom, cx + s * 0.20, bottom + s * 0.035], fill=PARCHMENT)
    d.rectangle([cx - s * 0.03, bottom + s * 0.035, cx + s * 0.03, bottom + s * 0.14], fill=(96, 66, 40, 255))
    d.ellipse([cx - s * 0.05, bottom + s * 0.13, cx + s * 0.05, bottom + s * 0.19], fill=PARCHMENT)
    # ember flame rising from the break
    flame(d, cx + s * 0.01, top + s * 0.03, s * 0.24, s * 0.12, EMBER_OUTER)
    flame(d, cx + s * 0.01, top + s * 0.03, s * 0.18, s * 0.08, EMBER_MID)
    flame(d, cx + s * 0.01, top + s * 0.03, s * 0.10, s * 0.045, EMBER_CORE)
    return img.resize((size, size), Image.LANCZOS)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    fg432 = foreground(432)
    bg432 = background(432)
    fg432.save(OUT / "icon_fg_432.png")
    bg432.convert("RGB").save(OUT / "icon_bg_432.png")

    def composite(size: int) -> Image.Image:
        base = background(size)
        fg = foreground(size)
        # keep the artwork inside the safe zone like the adaptive icon does
        zoom = int(size * 0.92)
        fg_small = fg.resize((zoom, zoom), Image.LANCZOS)
        base.alpha_composite(fg_small, ((size - zoom) // 2, (size - zoom) // 2))
        return base

    composite(192).save(OUT / "icon_main_192.png")
    composite(512).save(OUT / "icon.png")
    print("icons written to", OUT)


if __name__ == "__main__":
    main()
