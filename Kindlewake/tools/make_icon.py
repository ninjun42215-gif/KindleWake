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
    # Layered heraldic sun and engraved frame.
    d.rounded_rectangle([s*.055,s*.055,s*.945,s*.945], radius=s*.17, outline=(106,91,65,255), width=max(2,int(s*.018)))
    d.rounded_rectangle([s*.085,s*.085,s*.915,s*.915], radius=s*.145, outline=(204,166,94,255), width=max(1,int(s*.007)))
    for i in range(16):
        a = i * 3.14159265 / 8
        r1, r2 = s*.285, s*.405
        p1=(cx+__import__("math").cos(a)*r1, cx+__import__("math").sin(a)*r1)
        p2=(cx+__import__("math").cos(a)*r2, cx+__import__("math").sin(a)*r2)
        d.line([p1,p2], fill=(177,132,62,255), width=max(2,int(s*.018)))
        d.ellipse([p2[0]-s*.012,p2[1]-s*.012,p2[0]+s*.012,p2[1]+s*.012], fill=PARCHMENT)
    d.ellipse([s*.20,s*.20,s*.80,s*.80], fill=(38,43,43,255), outline=(205,165,91,255), width=max(3,int(s*.025)))
    d.ellipse([s*.245,s*.245,s*.755,s*.755], outline=(104,82,52,255), width=max(2,int(s*.012)))
    # Broken, rune-cut sword with a bright ember seam.
    blade_w, top, bottom = s*.082, s*.275, s*.705
    d.polygon([(cx-blade_w, bottom),(cx-blade_w*.78,top+s*.055),(cx-s*.018,top-s*.035),
               (cx+blade_w*.78,top+s*.025),(cx+blade_w,bottom)], fill=STEEL, outline=PARCHMENT)
    d.polygon([(cx,bottom-s*.02),(cx+blade_w, bottom),(cx+blade_w*.78,top+s*.025),(cx,top+s*.012)], fill=STEEL_DARK)
    d.line([(cx,top+s*.09),(cx,top+s*.34)], fill=(245,135,48,255), width=max(3,int(s*.024)))
    d.line([(cx,top+s*.12),(cx,top+s*.31)], fill=EMBER_CORE, width=max(1,int(s*.009)))
    # Ornate swept crossguard, wrapped grip and sun pommel.
    d.polygon([(cx-s*.235,bottom-s*.005),(cx-s*.18,bottom-s*.055),(cx-s*.055,bottom+s*.015),
               (cx+s*.055,bottom+s*.015),(cx+s*.18,bottom-s*.055),(cx+s*.235,bottom-s*.005),
               (cx+s*.19,bottom+s*.055),(cx,bottom+s*.075),(cx-s*.19,bottom+s*.055)], fill=(180,143,80,255), outline=(239,207,133,255))
    d.rounded_rectangle([cx-s*.038,bottom+s*.045,cx+s*.038,bottom+s*.19], radius=s*.018, fill=(71,48,35,255), outline=PARCHMENT, width=max(1,int(s*.009)))
    for k in range(4):
        y=bottom+s*(.07+k*.027)
        d.line([(cx-s*.035,y),(cx+s*.035,y-s*.018)], fill=(184,145,83,255), width=max(1,int(s*.009)))
    d.ellipse([cx-s*.075,bottom+s*.17,cx+s*.075,bottom+s*.32], fill=(100,76,43,255), outline=PARCHMENT, width=max(2,int(s*.014)))
    d.ellipse([cx-s*.035,bottom+s*.21,cx+s*.035,bottom+s*.28], fill=EMBER_MID, outline=EMBER_CORE, width=max(1,int(s*.008)))
    # Ember glow at the fracture.
    flame(d, cx, top+s*.12, s*.18, s*.075, EMBER_OUTER)
    flame(d, cx, top+s*.12, s*.13, s*.05, EMBER_MID)
    flame(d, cx, top+s*.12, s*.075, s*.027, EMBER_CORE)
    # Small corner studs catch light at launcher size.
    for x in (s*.15,s*.85):
        for y in (s*.15,s*.85):
            d.ellipse([x-s*.018,y-s*.018,x+s*.018,y+s*.018], fill=PARCHMENT, outline=(74,58,39,255), width=max(1,int(s*.006)))
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
