#!/usr/bin/env python3
"""Turns 3D OBJ models (Quaternius nature kit, voxel buildings) into 3/4-view 2D sprites for the overworld.
Pure numpy + Pillow software renderer (orthographic camera, z-buffer, flat shading, 2x supersampling).
Usage: python3 tools/render_sprites.py <source_dir> [<source_dir> ...]   (searches for the models listed in JOBS)
Output: assets/art/world/<name>.png (transparent background, cropped, feet at the bottom edge)."""
import math, os, sys
import numpy as np
from PIL import Image

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "art", "world")
# name -> (model file stem, output height in px, yaw degrees)
JOBS = {
    "tree_a": ("CommonTree_1", 96, 30), "tree_b": ("CommonTree_3", 90, 80), "tree_c": ("CommonTree_4", 100, 140),
    "pine_a": ("Pine_1", 104, 20), "pine_b": ("Pine_3", 96, 70), "pine_c": ("Pine_5", 110, 120),
    "dead_a": ("DeadTree_1", 80, 40), "dead_b": ("DeadTree_3", 72, 100),
    "twisted_a": ("TwistedTree_2", 84, 60),
    "rock_a": ("Rock_Medium_1", 40, 30), "rock_b": ("Rock_Medium_2", 36, 90),
    "mountain_a": ("Rock_Medium_1", 84, 30), "mountain_b": ("Rock_Medium_3", 92, 110), "mountain_c": ("Rock_Medium_2", 78, 200),
    "keep": ("LargeBuilding01", 110, 40), "house_a": ("SmallBuilding01", 60, 40), "house_b": ("SmallBuilding03", 60, 40),
    "house_c": ("SmallBuilding04", 58, 40), "tower_a": ("TallBuilding01", 100, 40), "tower_b": ("TallBuilding02", 100, 40),
    "tower_c": ("TallBuilding03", 100, 40), "hut": ("TinyBuilding01", 64, 40),
}
PITCH = math.radians(38.0)
SS = 2          # supersampling


def find(stem, roots):
    for r in roots:
        for d, _, files in os.walk(r):
            if stem + ".obj" in files:
                return d
    return None


def load_obj(path, tex_dirs):
    verts, uvs, faces = [], [], []          # faces: (v idx x3, uv idx x3, material)
    mats, cur = {}, ""
    mtl = os.path.splitext(path)[0] + ".mtl"
    if os.path.exists(mtl):
        name = ""
        for line in open(mtl, errors="ignore"):
            p = line.split()
            if len(p) >= 2 and p[0] == "newmtl":
                name = p[1]
            elif len(p) >= 2 and p[0] == "map_Kd":
                base = os.path.basename(p[-1].replace("\\", "/"))
                for d in tex_dirs:
                    f = os.path.join(d, base)
                    if os.path.exists(f):
                        mats[name] = np.asarray(Image.open(f).convert("RGBA"))
                        break
            elif len(p) >= 4 and p[0] == "Kd" and name not in mats:
                c = [int(float(x) * 255) for x in p[1:4]]
                mats[name] = np.array([[[c[0], c[1], c[2], 255]]], dtype=np.uint8)
    for line in open(path, errors="ignore"):
        p = line.split()
        if not p:
            continue
        if p[0] == "v":
            verts.append([float(p[1]), float(p[2]), float(p[3])])
        elif p[0] == "vt":
            uvs.append([float(p[1]), float(p[2])])
        elif p[0] == "usemtl":
            cur = p[1]
        elif p[0] == "f":
            idx = []
            for tok in p[1:]:
                a = tok.split("/")
                vi = int(a[0]) - 1 if int(a[0]) > 0 else len(verts) + int(a[0])
                ti = -1
                if len(a) > 1 and a[1]:
                    ti = int(a[1]) - 1 if int(a[1]) > 0 else len(uvs) + int(a[1])
                idx.append((vi, ti))
            for k in range(1, len(idx) - 1):
                tri = (idx[0], idx[k], idx[k + 1])
                faces.append(([t[0] for t in tri], [t[1] for t in tri], cur))
    return np.array(verts, dtype=np.float64), np.array(uvs, dtype=np.float64) if uvs else np.zeros((1, 2)), faces, mats


def render(path, tex_dirs, out_h, yaw_deg):
    V, UV, faces, mats = load_obj(path, tex_dirs)
    if len(V) == 0:
        raise RuntimeError("no geometry")
    yaw = math.radians(yaw_deg)
    x1 = V[:, 0] * math.cos(yaw) + V[:, 2] * math.sin(yaw)
    z1 = -V[:, 0] * math.sin(yaw) + V[:, 2] * math.cos(yaw)
    sy = V[:, 1] * math.cos(PITCH) - z1 * math.sin(PITCH)       # screen up
    dp = V[:, 1] * math.sin(PITCH) + z1 * math.cos(PITCH)       # depth (bigger = closer)
    P = np.stack([x1, sy, dp, V[:, 1]], axis=1)
    minx, maxx, miny, maxy = P[:, 0].min(), P[:, 0].max(), P[:, 1].min(), P[:, 1].max()
    scale = (out_h * SS) / max(maxy - miny, 1e-6)
    W = int((maxx - minx) * scale) + 3
    H = int((maxy - miny) * scale) + 3
    img = np.zeros((H, W, 4), dtype=np.uint8)
    zb = np.full((H, W), -1e9)
    light = np.array([-0.45, 0.80, 0.40]); light /= np.linalg.norm(light)
    for vi, ti, mname in faces:
        a, b, c = P[vi[0]], P[vi[1]], P[vi[2]]
        sx = np.array([(a[0] - minx) * scale + 1, (b[0] - minx) * scale + 1, (c[0] - minx) * scale + 1])
        sy2 = np.array([(maxy - a[1]) * scale + 1, (maxy - b[1]) * scale + 1, (maxy - c[1]) * scale + 1])
        x0, x1_ = int(max(0, math.floor(sx.min()))), int(min(W - 1, math.ceil(sx.max())))
        y0, y1_ = int(max(0, math.floor(sy2.min()))), int(min(H - 1, math.ceil(sy2.max())))
        if x1_ < x0 or y1_ < y0:
            continue
        den = (sy2[1] - sy2[2]) * (sx[0] - sx[2]) + (sx[2] - sx[1]) * (sy2[0] - sy2[2])
        if abs(den) < 1e-9:
            continue
        gx, gy = np.meshgrid(np.arange(x0, x1_ + 1) + 0.5, np.arange(y0, y1_ + 1) + 0.5)
        l0 = ((sy2[1] - sy2[2]) * (gx - sx[2]) + (sx[2] - sx[1]) * (gy - sy2[2])) / den
        l1 = ((sy2[2] - sy2[0]) * (gx - sx[2]) + (sx[0] - sx[2]) * (gy - sy2[2])) / den
        l2 = 1.0 - l0 - l1
        m = (l0 >= -1e-4) & (l1 >= -1e-4) & (l2 >= -1e-4)
        if not m.any():
            continue
        z = l0 * a[2] + l1 * b[2] + l2 * c[2]
        # world-space normal (before camera) -> shade
        wa, wb, wc = V[vi[0]], V[vi[1]], V[vi[2]]
        n = np.cross(wb - wa, wc - wa)
        ln = np.linalg.norm(n)
        if ln < 1e-12:
            continue
        n /= ln
        nx = n[0] * math.cos(yaw) + n[2] * math.sin(yaw)
        nz1 = -n[0] * math.sin(yaw) + n[2] * math.cos(yaw)
        nv = np.array([nx, n[1], nz1])
        view = np.array([0.0, math.sin(PITCH), math.cos(PITCH)])
        if nv @ view < 0:
            nv = -nv
        lv = np.array([light[0], light[1] * math.cos(PITCH) + light[2] * math.sin(PITCH), -light[1] * math.sin(PITCH) + light[2] * math.cos(PITCH)])
        shade = 0.58 + 0.42 * max(0.0, float(nv @ (lv / np.linalg.norm(lv))))
        tex = mats.get(mname)
        if tex is not None and ti[0] >= 0 and ti[1] >= 0 and ti[2] >= 0 and len(UV) > max(ti):
            u = l0 * UV[ti[0]][0] + l1 * UV[ti[1]][0] + l2 * UV[ti[2]][0]
            v = l0 * UV[ti[0]][1] + l1 * UV[ti[1]][1] + l2 * UV[ti[2]][1]
            th, tw = tex.shape[0], tex.shape[1]
            px = np.clip((u % 1.0) * tw, 0, tw - 1).astype(int)
            py = np.clip((1.0 - (v % 1.0)) * th, 0, th - 1).astype(int)
            col = tex[py, px].astype(np.float64)
        elif tex is not None:
            col = np.broadcast_to(tex[0, 0].astype(np.float64), gx.shape + (4,))
        else:
            col = np.broadcast_to(np.array([150.0, 150.0, 150.0, 255.0]), gx.shape + (4,))
        ok = m & (col[..., 3] > 128)
        sub = zb[y0:y1_ + 1, x0:x1_ + 1]
        win = ok & (z > sub)
        if not win.any():
            continue
        sub[win] = z[win]
        region = img[y0:y1_ + 1, x0:x1_ + 1]
        rgb = np.clip(col[..., :3] * shade, 0, 255).astype(np.uint8)
        region[win, :3] = rgb[win]
        region[win, 3] = 255
    im = Image.fromarray(img, "RGBA")
    bb = im.getbbox()
    if bb:
        im = im.crop(bb)
    w2, h2 = max(1, im.width // SS), max(1, im.height // SS)
    return im.resize((w2, h2), Image.LANCZOS)


def main():
    roots = sys.argv[1:]
    if not roots:
        print(__doc__)
        return 1
    os.makedirs(OUT, exist_ok=True)
    tex_dirs = []
    for r in roots:
        for d, _, _ in os.walk(r):
            tex_dirs.append(d)
    done = 0
    for name, (stem, h, yaw) in JOBS.items():
        d = find(stem, roots)
        if d is None:
            print("skip (model not found):", name, stem)
            continue
        try:
            im = render(os.path.join(d, stem + ".obj"), tex_dirs, h, yaw)
            im.save(os.path.join(OUT, name + ".png"))
            print("ok  %-12s %dx%d" % (name, im.width, im.height))
            done += 1
        except Exception as e:                      # keep going: one bad model must not stop the batch
            print("FAIL", name, e)
    print("rendered", done, "of", len(JOBS))
    return 0


if __name__ == "__main__":
    sys.exit(main())
