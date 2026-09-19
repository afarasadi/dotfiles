#!/usr/bin/env python3
"""Compara um modelo paramétrico com a imagem do logo (IoU) e, opcionalmente,
ajusta os parâmetros por coordinate descent.

Uso:
  tune.py logo.png models/runner.py                    # só mede IoU e salva overlay.png
  tune.py logo.png models/runner.py --tune             # ajusta e salva params.json
  tune.py logo.png models/runner.py --params p.json    # parte de outros parâmetros
  tune.py logo.png models/runner.py --ignore-below 1000  # ignora ruído abaixo de y=1000 (ex.: wordmark)

O módulo do modelo precisa expor: PARAMS (dict), STEPS, VEC_STEPS e build(P) -> [polígonos].
"""
import argparse
import copy
import importlib.util
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from geometry import iou, overlay, render  # noqa: E402
from measure import load_mask  # noqa: E402


def load_model(path):
    spec = importlib.util.spec_from_file_location("model", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def main():
    p = argparse.ArgumentParser()
    p.add_argument("image")
    p.add_argument("model")
    p.add_argument("--params")
    p.add_argument("--tune", action="store_true")
    p.add_argument("--iters", type=int, default=6)
    p.add_argument("--threshold", type=int, default=200)
    p.add_argument("--dark", action="store_true")
    p.add_argument("--ignore-below", type=int)
    p.add_argument("--out", default="params.json")
    p.add_argument("--overlay", default="overlay.png")
    args = p.parse_args()

    mod = load_model(args.model)
    m = load_mask(args.image, args.threshold, args.dark)
    if args.ignore_below:
        m[args.ignore_below:, :] = False
    size = (m.shape[1], m.shape[0])
    P = json.load(open(args.params)) if args.params else copy.deepcopy(mod.PARAMS)

    def score(Q):
        return iou(render(mod.build(Q), size), m)

    best = score(P)
    print(f"IoU inicial: {best:.4f}")

    if args.tune:
        for it in range(args.iters):
            improved = False
            for k, s in mod.STEPS.items():
                for sign in (1, -1):
                    Q = copy.deepcopy(P); Q[k] += sign * s
                    v = score(Q)
                    if v > best:
                        best, P, improved = v, Q, True
            for k, s in mod.VEC_STEPS.items():
                for i in (0, 1):
                    for sign in (1, -1):
                        Q = copy.deepcopy(P); Q[k][i] += sign * s
                        v = score(Q)
                        if v > best:
                            best, P, improved = v, Q, True
            print(f"iter {it}: IoU {best:.4f}")
            if not improved:
                break
        json.dump(P, open(args.out, "w"), indent=1)
        print("params ->", args.out)
        print(json.dumps(P))

    r = render(mod.build(P), size)
    ys, xs = np.where(r | m)
    pad = 20
    crop = (max(0, xs.min() - pad), max(0, ys.min() - pad), min(size[0], xs.max() + pad), min(size[1], ys.max() + pad))
    overlay(r, m, args.overlay, crop=crop)
    print(f"só-modelo={int((r & ~m).sum())}px  só-imagem={int((m & ~r).sum())}px  overlay -> {args.overlay}")


if __name__ == "__main__":
    main()
