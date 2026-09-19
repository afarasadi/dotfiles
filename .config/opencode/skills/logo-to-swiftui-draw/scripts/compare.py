#!/usr/bin/env python3
"""Compara o PNG renderizado do `Shape` (render_shape.sh) com a imagem original do logo.

Uso:
  compare.py logo.png render.png [--ignore-below Y] [--overlay overlay.png]

Imprime o IoU e salva o overlay (branco = os dois, vermelho = só o Shape, verde = só a imagem).
Acima de ~0.95 o que sobra é antialiasing e imperfeição do PNG de origem.
"""
import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from geometry import iou, overlay  # noqa: E402
from measure import load_mask  # noqa: E402


def main():
    p = argparse.ArgumentParser()
    p.add_argument("image")
    p.add_argument("render")
    p.add_argument("--threshold", type=int, default=200)
    p.add_argument("--dark", action="store_true")
    p.add_argument("--ignore-below", type=int)
    p.add_argument("--overlay", default="overlay.png")
    args = p.parse_args()

    m = load_mask(args.image, args.threshold, args.dark)
    if args.ignore_below:
        m[args.ignore_below:, :] = False
    r = np.array(Image.open(args.render).convert("L")) > 128
    if r.shape != m.shape:
        sys.exit(f"tamanhos diferentes: render {r.shape[::-1]} vs imagem {m.shape[::-1]} (use --canvas no render_shape.sh)")
    print(f"IoU: {iou(r, m):.4f}  só-shape={int((r & ~m).sum())}px  só-imagem={int((m & ~r).sum())}px")
    ys, xs = np.where(r | m)
    pad = 20
    crop = (max(0, xs.min() - pad), max(0, ys.min() - pad), min(m.shape[1], xs.max() + pad), min(m.shape[0], ys.max() + pad))
    overlay(r, m, args.overlay, crop=crop)
    print("overlay ->", args.overlay)


if __name__ == "__main__":
    main()
