#!/usr/bin/env python3
"""Measure a reference PNG with connected components and pixel runs.

Usage:
  measure.py image.png                       # components and bounding boxes
  measure.py image.png --rows 520 720 6       # horizontal runs by row
  measure.py image.png --cols 400 700 12      # vertical runs by column
  measure.py image.png --mask mask.png        # save the binary mask

This is an optional helper for investigating image geometry. The UI-slicing
workflow does not depend on it.
"""

import argparse
from typing import cast

import numpy as np
from PIL import Image
from scipy import ndimage


def load_mask(path, threshold=200, dark=False):
    image = np.array(Image.open(path).convert("RGB")).astype(int)
    if dark:
        return image.max(axis=2) < (255 - threshold)
    return image.min(axis=2) > threshold


def runs(values, offset=0):
    indexes = np.where(values)[0] + offset
    if len(indexes) == 0:
        return []

    result = []
    start = previous = indexes[0]
    for value in indexes[1:]:
        if value != previous + 1:
            result.append((int(start), int(previous)))
            start = value
        previous = value
    result.append((int(start), int(previous)))
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("image")
    parser.add_argument("--threshold", type=int, default=200)
    parser.add_argument("--dark", action="store_true")
    parser.add_argument("--min-area", type=int, default=200)
    parser.add_argument("--rows", nargs=3, type=int, metavar=("Y1", "Y2", "STEP"))
    parser.add_argument("--cols", nargs=3, type=int, metavar=("X1", "X2", "STEP"))
    parser.add_argument("--mask")
    args = parser.parse_args()

    mask = load_mask(args.image, args.threshold, args.dark)
    height, width = mask.shape
    print(f"image {width}x{height}")

    labeled = cast(tuple[np.ndarray, int], ndimage.label(mask))
    labels = labeled[0]
    count = labeled[1]
    print("components (area, x0-x1, y0-y1):")
    for index in range(1, count + 1):
        ys, xs = np.where(labels == index)
        if len(xs) < args.min_area:
            continue
        print(
            f"  #{index}: area={len(xs)} x={xs.min()}-{xs.max()} y={ys.min()}-{ys.max()}"
        )

    if args.rows:
        y1, y2, step = args.rows
        print("rows (y: [(x0,x1), ...]):")
        for y in range(y1, y2 + 1, step):
            print(f"  {y}: {runs(mask[y, :])}")

    if args.cols:
        x1, x2, step = args.cols
        print("cols (x: [(y0,y1), ...]):")
        for x in range(x1, x2 + 1, step):
            print(f"  {x}: {runs(mask[:, x])}")

    if args.mask:
        Image.fromarray((mask * 255).astype("uint8")).save(args.mask)
        print("mask ->", args.mask)


if __name__ == "__main__":
    main()
