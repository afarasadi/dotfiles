#!/usr/bin/env python3
"""Mede um logo num PNG: componentes conexos, bounding boxes e "runs" por linha/coluna.

Uso:
  measure.py logo.png                       # componentes + bboxes
  measure.py logo.png --rows 520 720 6      # runs horizontais entre y=520 e 720, passo 6
  measure.py logo.png --cols 400 700 12     # runs verticais
  measure.py logo.png --mask mask.png       # salva a máscara binária (pra conferir o threshold)

O glifo é considerado "claro sobre escuro" por padrão (min(R,G,B) > --threshold).
Use --dark se o logo for escuro sobre claro.
"""
import argparse
import numpy as np
from PIL import Image
from scipy import ndimage


def load_mask(path, threshold=200, dark=False):
    a = np.array(Image.open(path).convert("RGB")).astype(int)
    if dark:
        return a.max(axis=2) < (255 - threshold)
    return a.min(axis=2) > threshold


def runs(vec, offset=0):
    idx = np.where(vec)[0] + offset
    if len(idx) == 0:
        return []
    out, start, prev = [], idx[0], idx[0]
    for x in idx[1:]:
        if x != prev + 1:
            out.append((int(start), int(prev)))
            start = x
        prev = x
    out.append((int(start), int(prev)))
    return out


def main():
    p = argparse.ArgumentParser()
    p.add_argument("image")
    p.add_argument("--threshold", type=int, default=200)
    p.add_argument("--dark", action="store_true")
    p.add_argument("--min-area", type=int, default=200, help="ignora componentes menores que isso (ruído)")
    p.add_argument("--rows", nargs=3, type=int, metavar=("Y1", "Y2", "STEP"))
    p.add_argument("--cols", nargs=3, type=int, metavar=("X1", "X2", "STEP"))
    p.add_argument("--mask")
    args = p.parse_args()

    m = load_mask(args.image, args.threshold, args.dark)
    h, w = m.shape
    print(f"image {w}x{h}")
    labels, n = ndimage.label(m)
    print("components (area, x0-x1, y0-y1):")
    for i in range(1, n + 1):
        ys, xs = np.where(labels == i)
        if len(xs) < args.min_area:
            continue
        print(f"  #{i}: area={len(xs)} x={xs.min()}-{xs.max()} y={ys.min()}-{ys.max()}")

    if args.rows:
        y1, y2, step = args.rows
        print("rows (y: [(x0,x1), ...]):")
        for y in range(y1, y2 + 1, step):
            print(f"  {y}: {runs(m[y, :])}")
    if args.cols:
        x1, x2, step = args.cols
        print("cols (x: [(y0,y1), ...]):")
        for x in range(x1, x2 + 1, step):
            print(f"  {x}: {runs(m[:, x])}")
    if args.mask:
        Image.fromarray((m * 255).astype("uint8")).save(args.mask)
        print("mask ->", args.mask)


if __name__ == "__main__":
    main()
