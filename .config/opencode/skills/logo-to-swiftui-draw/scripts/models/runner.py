"""Modelo paramétrico do exemplo (corredor): cabeça + chevron do tronco + gancho da perna.

Cada peça é construída exatamente como o `RunnerLogoShape.swift` constrói o `Path`,
com os mesmos parâmetros. Os valores em PARAMS são os que saíram do tune.py.
"""
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from geometry import arc, at_y, circle, fillet, intersect, offset, unit  # noqa: E402

PARAMS = {
    "w": 70,
    "head": [754.5, 491.5], "headR": 50.5,
    "apex": [636, 527], "thetaL": 49.0, "thetaR": 50.0,
    "Ro": 99, "Ri": 54, "Rcut": 8, "cut": 701, "capY": 686,
    "hookY": 775.5, "hookLeftX": 453, "hookKx": 557, "hookTop": [640, 688], "hookR": 63,
}

# Passo de cada parâmetro na busca do tune.py (escalares) e vetores (pares x,y).
STEPS = {"w": 1, "headR": 0.5, "thetaL": 0.5, "thetaR": 0.5, "Ro": 4, "Ri": 4, "Rcut": 3,
         "cut": 1, "capY": 2, "hookY": 1, "hookLeftX": 2, "hookKx": 3, "hookR": 4}
VEC_STEPS = {"apex": 2, "head": 1, "hookTop": 2}


def build(P):
    w = P["w"]; h = w / 2
    polys = []

    # --- chevron (tronco): corte reto à esquerda, ponta redonda à direita
    ax, ay = P["apex"]
    tl, tr = math.radians(P["thetaL"]), math.radians(P["thetaR"])
    dL = (-math.cos(tl), math.sin(tl)); dR = (math.cos(tr), math.sin(tr))
    nL = (-math.sin(tl), -math.cos(tl)); nR = (math.sin(tr), -math.cos(tr))
    apex = (ax, ay)
    outer_apex = intersect(offset(apex, nL, h), dL, offset(apex, nR, h), dR)
    inner_apex = intersect(offset(apex, nL, -h), dL, offset(apex, nR, -h), dR)
    left_outer = at_y(outer_apex, dL, P["cut"])
    left_inner = at_y(inner_apex, dL, P["cut"])
    right_cap = at_y(apex, dR, P["capY"])
    right_outer = offset(right_cap, nR, h)
    right_inner = offset(right_cap, nR, -h)
    a_r = math.degrees(math.atan2(nR[1], nR[0]))
    pts = [left_outer]
    pts += fillet(left_outer, outer_apex, right_outer, P["Ro"])
    pts += [right_outer]
    pts += arc(right_cap, h, a_r, a_r + 180)
    pts += [right_inner]
    pts += fillet(right_inner, inner_apex, left_inner, P["Ri"])
    pts += fillet(inner_apex, left_inner, left_outer, P["Rcut"])
    polys.append(pts)

    # --- gancho (perna): traço uniforme, eixo capLeft -> knee -> capTop
    yc = P["hookY"]
    cap_left = (P["hookLeftX"], yc); knee = (P["hookKx"], yc); cap_top = tuple(P["hookTop"])
    R = P["hookR"]
    d2 = unit(cap_top[0] - knee[0], cap_top[1] - knee[1])
    n2 = (d2[1], -d2[0])
    right = (1, 0)
    top_start = (cap_left[0], yc - h); bot_start = (cap_left[0], yc + h)
    top_knee = intersect(top_start, right, offset(cap_top, n2, h), d2)
    bot_knee = intersect(bot_start, right, offset(cap_top, n2, -h), d2)
    top_end = offset(cap_top, n2, h); bot_end = offset(cap_top, n2, -h)
    a_t = math.degrees(math.atan2(n2[1], n2[0]))
    pts = [top_start]
    pts += fillet(top_start, top_knee, top_end, R - h)
    pts += [top_end]
    pts += arc(cap_top, h, a_t, a_t + 180)
    pts += [bot_end]
    pts += fillet(bot_end, bot_knee, bot_start, R + h)
    pts += [bot_start]
    pts += arc(cap_left, h, 90, 270)
    polys.append(pts)

    # --- cabeça
    polys.append(circle(tuple(P["head"]), P["headR"]))
    return polys
