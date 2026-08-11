"""Generates the original layered avatar SVG art for VEYRA.

Every layer shares a common 300x300 canvas and head anchor so any combination
of skin + hair + eyes + outfit + accessory composites cleanly. Run once to
(re)materialize assets/avatar/**. Pure stdlib — no image libraries involved,
this is hand-parameterized vector art, not photography or generated imagery.
"""

from __future__ import annotations

import os

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "avatar")
W = H = 300
HEAD_CX, HEAD_CY, HEAD_R = 150, 128, 68


def write(path: str, content: str) -> None:
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as f:
        f.write(content.strip() + "\n")
    print("wrote", path)


def svg(body: str) -> str:
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}">\n{body}\n</svg>'


# ---------------------------------------------------------------------------
# Skin (head + neck + ears shape, shared silhouette across all tones)
# ---------------------------------------------------------------------------

SKIN_TONES = [
    ("skin_01", "#F7D9C4"),
    ("skin_02", "#F0C39E"),
    ("skin_03", "#D8A377"),
    ("skin_04", "#A9714F"),
    ("skin_05", "#6B4630"),
]


def skin_body(fill: str, shade: str) -> str:
    return f"""
  <ellipse cx="{HEAD_CX}" cy="228" rx="26" ry="34" fill="{fill}" />
  <circle cx="{HEAD_CX - 44}" cy="{HEAD_CY}" r="10" fill="{fill}" />
  <circle cx="{HEAD_CX + 44}" cy="{HEAD_CY}" r="10" fill="{fill}" />
  <circle cx="{HEAD_CX}" cy="{HEAD_CY}" r="{HEAD_R}" fill="{fill}" />
  <ellipse cx="{HEAD_CX}" cy="{HEAD_CY + 40}" rx="30" ry="14" fill="{shade}" opacity="0.35" />
""".strip()


def gen_skin():
    for name, hex_color in SKIN_TONES:
        shade = hex_color
        write(f"skin/{name}.svg", svg(skin_body(hex_color, shade)))


# ---------------------------------------------------------------------------
# Eyes (shape varies, sits on the shared head anchor)
# ---------------------------------------------------------------------------

EYE_Y = HEAD_CY - 4
EYE_DX = 26
IRIS = "#3C2A20"


def eyes_round() -> str:
    return f"""
  <ellipse cx="{HEAD_CX - EYE_DX}" cy="{EYE_Y}" rx="9" ry="10" fill="#FFFFFF" />
  <ellipse cx="{HEAD_CX + EYE_DX}" cy="{EYE_Y}" rx="9" ry="10" fill="#FFFFFF" />
  <circle cx="{HEAD_CX - EYE_DX}" cy="{EYE_Y}" r="4.5" fill="{IRIS}" />
  <circle cx="{HEAD_CX + EYE_DX}" cy="{EYE_Y}" r="4.5" fill="{IRIS}" />
""".strip()


def eyes_almond() -> str:
    return f"""
  <path d="M {HEAD_CX - EYE_DX - 10} {EYE_Y} Q {HEAD_CX - EYE_DX} {EYE_Y - 8} {HEAD_CX - EYE_DX + 10} {EYE_Y} Q {HEAD_CX - EYE_DX} {EYE_Y + 6} {HEAD_CX - EYE_DX - 10} {EYE_Y} Z" fill="#FFFFFF" />
  <path d="M {HEAD_CX + EYE_DX - 10} {EYE_Y} Q {HEAD_CX + EYE_DX} {EYE_Y - 8} {HEAD_CX + EYE_DX + 10} {EYE_Y} Q {HEAD_CX + EYE_DX} {EYE_Y + 6} {HEAD_CX + EYE_DX - 10} {EYE_Y} Z" fill="#FFFFFF" />
  <circle cx="{HEAD_CX - EYE_DX}" cy="{EYE_Y}" r="4" fill="{IRIS}" />
  <circle cx="{HEAD_CX + EYE_DX}" cy="{EYE_Y}" r="4" fill="{IRIS}" />
""".strip()


def eyes_sleepy() -> str:
    return f"""
  <path d="M {HEAD_CX - EYE_DX - 10} {EYE_Y} Q {HEAD_CX - EYE_DX} {EYE_Y + 6} {HEAD_CX - EYE_DX + 10} {EYE_Y}" stroke="{IRIS}" stroke-width="3" fill="none" stroke-linecap="round" />
  <path d="M {HEAD_CX + EYE_DX - 10} {EYE_Y} Q {HEAD_CX + EYE_DX} {EYE_Y + 6} {HEAD_CX + EYE_DX + 10} {EYE_Y}" stroke="{IRIS}" stroke-width="3" fill="none" stroke-linecap="round" />
""".strip()


def eyes_wide() -> str:
    return f"""
  <circle cx="{HEAD_CX - EYE_DX}" cy="{EYE_Y}" r="11" fill="#FFFFFF" />
  <circle cx="{HEAD_CX + EYE_DX}" cy="{EYE_Y}" r="11" fill="#FFFFFF" />
  <circle cx="{HEAD_CX - EYE_DX}" cy="{EYE_Y}" r="5.5" fill="{IRIS}" />
  <circle cx="{HEAD_CX + EYE_DX}" cy="{EYE_Y}" r="5.5" fill="{IRIS}" />
  <circle cx="{HEAD_CX - EYE_DX + 2}" cy="{EYE_Y - 2}" r="1.6" fill="#FFFFFF" />
  <circle cx="{HEAD_CX + EYE_DX + 2}" cy="{EYE_Y - 2}" r="1.6" fill="#FFFFFF" />
""".strip()


EYE_SHAPES = {
    "round": eyes_round,
    "almond": eyes_almond,
    "sleepy": eyes_sleepy,
    "wide": eyes_wide,
}


def gen_eyes():
    for i, (name, fn) in enumerate(EYE_SHAPES.items(), start=1):
        write(f"eyes/eyes_{name}_{i:02d}.svg", svg(fn()))


# ---------------------------------------------------------------------------
# Hair (style silhouette x color)
# ---------------------------------------------------------------------------

HAIR_COLORS = [
    ("black", "#1B1B1F"),
    ("brown", "#5A3825"),
    ("blonde", "#D9B26A"),
]


def hair_short(fill: str) -> str:
    return f"""
  <path d="M {HEAD_CX - HEAD_R - 4} {HEAD_CY - 6}
           Q {HEAD_CX - HEAD_R - 6} {HEAD_CY - 66} {HEAD_CX} {HEAD_CY - 70}
           Q {HEAD_CX + HEAD_R + 6} {HEAD_CY - 66} {HEAD_CX + HEAD_R + 4} {HEAD_CY - 6}
           Q {HEAD_CX + HEAD_R - 6} {HEAD_CY - 30} {HEAD_CX} {HEAD_CY - 34}
           Q {HEAD_CX - HEAD_R + 6} {HEAD_CY - 30} {HEAD_CX - HEAD_R - 4} {HEAD_CY - 6} Z"
        fill="{fill}" />
""".strip()


def hair_long(fill: str) -> str:
    return f"""
  <path d="M {HEAD_CX - HEAD_R - 6} {HEAD_CY - 4}
           Q {HEAD_CX - HEAD_R - 10} {HEAD_CY - 68} {HEAD_CX} {HEAD_CY - 72}
           Q {HEAD_CX + HEAD_R + 10} {HEAD_CY - 68} {HEAD_CX + HEAD_R + 6} {HEAD_CY - 4}
           Q {HEAD_CX + HEAD_R + 2} {HEAD_CY + 90} {HEAD_CX + HEAD_R - 14} {HEAD_CY + 96}
           L {HEAD_CX + HEAD_R - 22} {HEAD_CY + 10}
           Q {HEAD_CX + HEAD_R - 8} {HEAD_CY - 26} {HEAD_CX} {HEAD_CY - 30}
           Q {HEAD_CX - HEAD_R + 8} {HEAD_CY - 26} {HEAD_CX - HEAD_R + 22} {HEAD_CY + 10}
           L {HEAD_CX - HEAD_R + 14} {HEAD_CY + 96}
           Q {HEAD_CX - HEAD_R - 2} {HEAD_CY + 90} {HEAD_CX - HEAD_R - 6} {HEAD_CY - 4} Z"
        fill="{fill}" />
""".strip()


def hair_curly(fill: str) -> str:
    circles = []
    import math

    for i in range(10):
        angle = math.pi * (0.15 + 0.7 * i / 9)
        cx = HEAD_CX + (HEAD_R + 6) * math.cos(math.pi - angle)
        cy = HEAD_CY - 8 - (HEAD_R + 2) * math.sin(angle) * 0.95
        circles.append(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="16" fill="{fill}" />')
    return "\n  ".join(circles)


def hair_wavy(fill: str) -> str:
    return f"""
  <path d="M {HEAD_CX - HEAD_R - 8} {HEAD_CY}
           Q {HEAD_CX - HEAD_R - 12} {HEAD_CY - 70} {HEAD_CX} {HEAD_CY - 74}
           Q {HEAD_CX + HEAD_R + 12} {HEAD_CY - 70} {HEAD_CX + HEAD_R + 8} {HEAD_CY}
           Q {HEAD_CX + HEAD_R + 16} {HEAD_CY + 34} {HEAD_CX + HEAD_R} {HEAD_CY + 60}
           Q {HEAD_CX + HEAD_R - 10} {HEAD_CY + 34} {HEAD_CX + HEAD_R - 4} {HEAD_CY + 4}
           Q {HEAD_CX + HEAD_R - 10} {HEAD_CY - 28} {HEAD_CX} {HEAD_CY - 32}
           Q {HEAD_CX - HEAD_R + 10} {HEAD_CY - 28} {HEAD_CX - HEAD_R + 4} {HEAD_CY + 4}
           Q {HEAD_CX - HEAD_R + 10} {HEAD_CY + 34} {HEAD_CX - HEAD_R} {HEAD_CY + 60}
           Q {HEAD_CX - HEAD_R - 16} {HEAD_CY + 34} {HEAD_CX - HEAD_R - 8} {HEAD_CY} Z"
        fill="{fill}" />
""".strip()


def hair_straight(fill: str) -> str:
    return f"""
  <path d="M {HEAD_CX - HEAD_R - 4} {HEAD_CY - 2}
           Q {HEAD_CX - HEAD_R - 8} {HEAD_CY - 72} {HEAD_CX} {HEAD_CY - 76}
           Q {HEAD_CX + HEAD_R + 8} {HEAD_CY - 72} {HEAD_CX + HEAD_R + 4} {HEAD_CY - 2}
           L {HEAD_CX + HEAD_R - 2} {HEAD_CY + 82}
           L {HEAD_CX + HEAD_R - 16} {HEAD_CY + 4}
           Q {HEAD_CX + HEAD_R - 6} {HEAD_CY - 30} {HEAD_CX} {HEAD_CY - 34}
           Q {HEAD_CX - HEAD_R + 6} {HEAD_CY - 30} {HEAD_CX - HEAD_R + 16} {HEAD_CY + 4}
           L {HEAD_CX - HEAD_R + 2} {HEAD_CY + 82}
           Z"
        fill="{fill}" />
""".strip()


def hair_braided(fill: str, shade: str) -> str:
    return f"""
  <path d="M {HEAD_CX - HEAD_R - 4} {HEAD_CY - 4}
           Q {HEAD_CX - HEAD_R - 8} {HEAD_CY - 68} {HEAD_CX} {HEAD_CY - 72}
           Q {HEAD_CX + HEAD_R + 8} {HEAD_CY - 68} {HEAD_CX + HEAD_R + 4} {HEAD_CY - 4}
           Q {HEAD_CX + HEAD_R - 6} {HEAD_CY - 28} {HEAD_CX} {HEAD_CY - 32}
           Q {HEAD_CX - HEAD_R + 6} {HEAD_CY - 28} {HEAD_CX - HEAD_R - 4} {HEAD_CY - 4} Z"
        fill="{fill}" />
  <rect x="{HEAD_CX + HEAD_R - 10}" y="{HEAD_CY - 10}" width="14" height="70" rx="7" fill="{fill}" />
  <rect x="{HEAD_CX + HEAD_R - 8}" y="{HEAD_CY - 2}" width="10" height="4" fill="{shade}" opacity="0.5" />
  <rect x="{HEAD_CX + HEAD_R - 8}" y="{HEAD_CY + 14}" width="10" height="4" fill="{shade}" opacity="0.5" />
  <rect x="{HEAD_CX + HEAD_R - 8}" y="{HEAD_CY + 30}" width="10" height="4" fill="{shade}" opacity="0.5" />
  <rect x="{HEAD_CX + HEAD_R - 8}" y="{HEAD_CY + 46}" width="10" height="4" fill="{shade}" opacity="0.5" />
""".strip()


HAIR_STYLES = {
    "short": lambda fill, shade: hair_short(fill),
    "long": lambda fill, shade: hair_long(fill),
    "curly": lambda fill, shade: hair_curly(fill),
    "wavy": lambda fill, shade: hair_wavy(fill),
    "straight": lambda fill, shade: hair_straight(fill),
    "braided": lambda fill, shade: hair_braided(fill, shade),
}


def gen_hair():
    idx = 1
    for style, fn in HAIR_STYLES.items():
        for color_name, hex_color in HAIR_COLORS:
            write(f"hair/hair_{style}_{color_name}_{idx:02d}.svg", svg(fn(hex_color, "#000000")))
            idx += 1


# ---------------------------------------------------------------------------
# Outfits (torso/shoulders, sits below the head)
# ---------------------------------------------------------------------------

def torso_path(fill: str, collar: str | None = None, accent: str | None = None) -> str:
    body = f"""
  <path d="M {HEAD_CX - 92} {H}
           Q {HEAD_CX - 92} {HEAD_CY + 92} {HEAD_CX - 40} {HEAD_CY + 78}
           Q {HEAD_CX} {HEAD_CY + 94} {HEAD_CX + 40} {HEAD_CY + 78}
           Q {HEAD_CX + 92} {HEAD_CY + 92} {HEAD_CX + 92} {H} Z"
        fill="{fill}" />
""".strip()
    extra = ""
    if collar:
        extra += f'\n  <path d="M {HEAD_CX - 22} {HEAD_CY + 82} L {HEAD_CX} {HEAD_CY + 106} L {HEAD_CX + 22} {HEAD_CY + 82} Z" fill="{collar}" />'
    if accent:
        extra += f'\n  <rect x="{HEAD_CX - 92}" y="{HEAD_CY + 130}" width="184" height="10" fill="{accent}" opacity="0.85" />'
    return body + extra


OUTFITS = {
    "casual": lambda: torso_path("#3E5C8A"),
    "formal": lambda: torso_path("#20222A", collar="#F5F5F5"),
    "streetwear": lambda: torso_path("#141416", accent="#B7A2F3"),
    "cozy": lambda: torso_path("#C79A6B"),
    "romantic": lambda: torso_path("#B05C74", collar="#F3D9E0"),
    "sport": lambda: torso_path("#1E6B62", accent="#7FD9A8"),
    "minimal": lambda: torso_path("#1A1A1D"),
}


def gen_outfits():
    for i, (name, fn) in enumerate(OUTFITS.items(), start=1):
        write(f"outfits/outfit_{name}_{i:02d}.svg", svg(fn()))


# ---------------------------------------------------------------------------
# Accessories (small overlays)
# ---------------------------------------------------------------------------

def accessory_glasses() -> str:
    return f"""
  <circle cx="{HEAD_CX - EYE_DX}" cy="{EYE_Y}" r="14" fill="none" stroke="#1A1A1D" stroke-width="3" />
  <circle cx="{HEAD_CX + EYE_DX}" cy="{EYE_Y}" r="14" fill="none" stroke="#1A1A1D" stroke-width="3" />
  <line x1="{HEAD_CX - EYE_DX + 14}" y1="{EYE_Y}" x2="{HEAD_CX + EYE_DX - 14}" y2="{EYE_Y}" stroke="#1A1A1D" stroke-width="3" />
""".strip()


def accessory_earrings() -> str:
    return f"""
  <circle cx="{HEAD_CX - HEAD_R - 2}" cy="{HEAD_CY + 18}" r="5" fill="#D9B26A" />
  <circle cx="{HEAD_CX + HEAD_R + 2}" cy="{HEAD_CY + 18}" r="5" fill="#D9B26A" />
""".strip()


def accessory_necklace() -> str:
    return f"""
  <path d="M {HEAD_CX - 26} {HEAD_CY + 84} Q {HEAD_CX} {HEAD_CY + 110} {HEAD_CX + 26} {HEAD_CY + 84}"
        stroke="#D9B26A" stroke-width="3" fill="none" />
  <circle cx="{HEAD_CX}" cy="{HEAD_CY + 106}" r="4" fill="#D9B26A" />
""".strip()


def accessory_hat() -> str:
    return f"""
  <ellipse cx="{HEAD_CX}" cy="{HEAD_CY - 62}" rx="60" ry="12" fill="#1A1A1D" />
  <path d="M {HEAD_CX - 40} {HEAD_CY - 62} Q {HEAD_CX - 40} {HEAD_CY - 104} {HEAD_CX} {HEAD_CY - 106}
           Q {HEAD_CX + 40} {HEAD_CY - 104} {HEAD_CX + 40} {HEAD_CY - 62} Z" fill="#26262C" />
""".strip()


ACCESSORIES = {
    "glasses": accessory_glasses,
    "earrings": accessory_earrings,
    "necklace": accessory_necklace,
    "hat": accessory_hat,
}


def gen_accessories():
    for i, (name, fn) in enumerate(ACCESSORIES.items(), start=1):
        write(f"accessories/accessory_{name}_{i:02d}.svg", svg(fn()))


if __name__ == "__main__":
    gen_skin()
    gen_eyes()
    gen_hair()
    gen_outfits()
    gen_accessories()
    print("Avatar asset generation complete.")
