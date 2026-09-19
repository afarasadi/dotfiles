"""Primitivas pra modelar um logo geométrico em Python com a MESMA construção
que o `Path` do SwiftUI vai usar depois:

  fillet(prev, corner, nxt, r)  == Path.addArc(tangent1End:tangent2End:radius:)
  arc(center, r, a1, a2)        == Path.addRelativeArc(center:radius:startAngle:delta:)
  circle(center, r)             == círculo completo

Coordenadas em pixels da imagem (y cresce pra baixo, como no SwiftUI). Ângulos em
graus, crescendo no sentido horário na tela (também como no SwiftUI com y pra baixo).

Um "modelo" é uma função `build(P) -> [polígono, ...]` onde cada polígono é um
subpath fechado (lista de pontos). Veja models/runner.py.
"""
import math
import numpy as np
from PIL import Image, ImageDraw


def unit(dx, dy):
    l = math.hypot(dx, dy)
    return dx / l, dy / l


def offset(p, n, d):
    return (p[0] + n[0] * d, p[1] + n[1] * d)


def intersect(p, d, q, e):
    """Interseção das retas p + d*t e q + e*s."""
    det = d[0] * (-e[1]) - d[1] * (-e[0])
    rx, ry = q[0] - p[0], q[1] - p[1]
    t = (rx * (-e[1]) - ry * (-e[0])) / det
    return (p[0] + d[0] * t, p[1] + d[1] * t)


def at_y(p, d, y):
    t = (y - p[1]) / d[1]
    return (p[0] + d[0] * t, y)


def fillet(prev, corner, nxt, r, n=24):
    """Pontos do arco de concordância entre as retas prev→corner e corner→nxt."""
    ux, uy = unit(corner[0] - prev[0], corner[1] - prev[1])
    vx, vy = unit(nxt[0] - corner[0], nxt[1] - corner[1])
    phi = math.acos(max(-1, min(1, ux * vx + uy * vy)))
    t = r * math.tan(phi / 2)
    p1 = (corner[0] - ux * t, corner[1] - uy * t)
    p2 = (corner[0] + vx * t, corner[1] + vy * t)
    s = 1 if (ux * vy - uy * vx) > 0 else -1
    nx, ny = -uy * s, ux * s
    c = (p1[0] + nx * r, p1[1] + ny * r)
    a1 = math.atan2(p1[1] - c[1], p1[0] - c[0])
    a2 = math.atan2(p2[1] - c[1], p2[0] - c[0])
    d = a2 - a1
    while d > math.pi:
        d -= 2 * math.pi
    while d < -math.pi:
        d += 2 * math.pi
    return [(c[0] + r * math.cos(a1 + d * i / n), c[1] + r * math.sin(a1 + d * i / n)) for i in range(n + 1)]


def arc(c, r, a1, a2, n=32):
    """Arco de a1 até a2 (graus, horário na tela)."""
    return [
        (c[0] + r * math.cos(math.radians(a1 + (a2 - a1) * i / n)),
         c[1] + r * math.sin(math.radians(a1 + (a2 - a1) * i / n)))
        for i in range(n + 1)
    ]


def circle(c, r, n=96):
    return arc(c, r, 0, 360, n)


def render(polys, size):
    """Rasteriza os polígonos numa máscara booleana (size = (w, h))."""
    im = Image.new("1", size, 0)
    d = ImageDraw.Draw(im)
    for poly in polys:
        d.polygon(poly, fill=1)
    return np.array(im).astype(bool)


def iou(a, b):
    return (a & b).sum() / (a | b).sum()


def overlay(model_mask, image_mask, path, crop=None, scale=2):
    """Branco = os dois, vermelho = só o modelo, verde = só a imagem."""
    h, w = image_mask.shape
    out = np.zeros((h, w, 3), np.uint8)
    out[model_mask & image_mask] = (255, 255, 255)
    out[model_mask & ~image_mask] = (255, 60, 60)
    out[image_mask & ~model_mask] = (60, 255, 60)
    if crop:
        x0, y0, x1, y1 = crop
        out = out[y0:y1, x0:x1]
    im = Image.fromarray(out)
    im = im.resize((im.width * scale, im.height * scale), Image.NEAREST)
    im.save(path)
