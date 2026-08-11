"""Generates the original vector wallpaper art for VEYRA's companion
environments. Abstract/gradient-based rather than photographic — matches the
brand's "cinematic, minimal, premium" direction and avoids any copyright risk
since nothing is sourced externally. Run once to (re)materialize
assets/wallpapers/**.
"""

from __future__ import annotations

import os

ROOT = os.path.join(os.path.dirname(__file__), "..", "assets", "wallpapers")
W, H = 400, 800


def write(category: str, name: str, content: str) -> None:
    full = os.path.join(ROOT, category, f"wallpaper_{category}_{name}.svg")
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as f:
        f.write(content.strip() + "\n")
    print("wrote", full.replace(ROOT + "/", ""))


def svg(defs: str, body: str) -> str:
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}">
<defs>
{defs}
</defs>
{body}
</svg>"""


def bg_gradient(id_: str, stops: list[tuple[str, str]], angle: str = "vertical") -> str:
    x2, y2 = ("0", "1") if angle == "vertical" else ("1", "0")
    stop_tags = "\n".join(f'<stop offset="{off}" stop-color="{color}" />' for off, color in stops)
    return f'<linearGradient id="{id_}" x1="0" y1="0" x2="{x2}" y2="{y2}">\n{stop_tags}\n</linearGradient>'


def stars(count: int, seed: int) -> str:
    import random

    rnd = random.Random(seed)
    dots = []
    for _ in range(count):
        x = rnd.uniform(10, W - 10)
        y = rnd.uniform(10, H * 0.55)
        r = rnd.uniform(0.6, 1.8)
        o = rnd.uniform(0.3, 0.9)
        dots.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="{r:.1f}" fill="#FFFFFF" opacity="{o:.2f}" />')
    return "\n".join(dots)


def moon(cx: float, cy: float, r: float, fill: str = "#F5F1E6") -> str:
    return f"""
  <circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}" opacity="0.95" />
  <circle cx="{cx + r * 0.35}" cy="{cy - r * 0.15}" r="{r * 0.88}" fill="url(#bg)" />
""".strip()


def hills(color: str, base_y: float, amp: float) -> str:
    return (
        f'<path d="M0 {base_y} '
        f'Q {W * 0.25} {base_y - amp} {W * 0.5} {base_y} '
        f'T {W} {base_y} L {W} {H} L 0 {H} Z" fill="{color}" />'
    )


def city_skyline(color: str, base_y: float, seed: int) -> str:
    import random

    rnd = random.Random(seed)
    x = 0.0
    rects = []
    while x < W:
        bw = rnd.uniform(28, 60)
        bh = rnd.uniform(60, 220)
        rects.append(f'<rect x="{x:.0f}" y="{base_y - bh:.0f}" width="{bw:.0f}" height="{bh + (H - base_y):.0f}" fill="{color}" />')
        # windows
        wins = []
        wy = base_y - bh + 12
        while wy < base_y - 10:
            wx = x + 6
            while wx < x + bw - 8:
                if rnd.random() > 0.45:
                    wins.append(f'<rect x="{wx:.0f}" y="{wy:.0f}" width="4" height="6" fill="#F3D98B" opacity="{rnd.uniform(0.4, 0.9):.2f}" />')
                wx += 10
            wy += 14
        rects.extend(wins)
        x += bw + rnd.uniform(4, 10)
    return "\n".join(rects)


def trees(color: str, base_y: float, seed: int) -> str:
    import random

    rnd = random.Random(seed)
    shapes = []
    x = -20.0
    while x < W + 20:
        th = rnd.uniform(90, 200)
        tw = rnd.uniform(40, 80)
        shapes.append(
            f'<path d="M{x:.0f} {base_y} L{x + tw / 2:.0f} {base_y - th:.0f} L{x + tw:.0f} {base_y} Z" fill="{color}" />'
        )
        x += tw * rnd.uniform(0.5, 0.9)
    return "\n".join(shapes)


def glow(cx: float, cy: float, r: float, color: str, id_: str) -> tuple[str, str]:
    d = f'<radialGradient id="{id_}" cx="50%" cy="50%" r="50%"><stop offset="0%" stop-color="{color}" stop-opacity="0.55" /><stop offset="100%" stop-color="{color}" stop-opacity="0" /></radialGradient>'
    b = f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#{id_})" />'
    return d, b


# ---------------------------------------------------------------------------
# NIGHT
# ---------------------------------------------------------------------------

def night_moonlit_bedroom():
    d = bg_gradient("bg", [("0%", "#0B0B14"), ("100%", "#1B1B2E")])
    g_def, g_body = glow(300, 140, 220, "#B7A2F3", "glow1")
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{g_body}
{moon(300, 130, 46)}
{stars(40, 1)}
{hills("#141420", H * 0.62, 30)}
{hills("#0E0E18", H * 0.72, 20)}
"""
    write("night", "01_moonlit_bedroom", svg(d + "\n" + g_def, body))


def night_city_at_night():
    d = bg_gradient("bg", [("0%", "#0A0A12"), ("100%", "#1A1424")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{stars(30, 2)}
{moon(90, 110, 30)}
{city_skyline("#15121E", H * 0.62, 7)}
"""
    write("night", "02_city_at_night", svg(d, body))


def night_starry_sky():
    d = bg_gradient("bg", [("0%", "#05050A"), ("100%", "#14101F")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{stars(90, 3)}
{hills("#0D0B14", H * 0.8, 24)}
"""
    write("night", "03_starry_sky", svg(d, body))


# ---------------------------------------------------------------------------
# COZY
# ---------------------------------------------------------------------------

def cozy_warm_bedroom():
    d = bg_gradient("bg", [("0%", "#2A2016"), ("100%", "#1A140E")])
    g_def, g_body = glow(320, 200, 260, "#F3B96B", "glow2")
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{g_body}
{hills("#20180F", H * 0.7, 20)}
"""
    write("cozy", "01_warm_bedroom", svg(d + "\n" + g_def, body))


def cozy_soft_lamp():
    d = bg_gradient("bg", [("0%", "#241C14"), ("100%", "#150F0A")])
    g_def, g_body = glow(200, 260, 180, "#F7C98A", "glow3")
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{g_body}
<rect x="180" y="240" width="10" height="120" fill="#3A2C1D" />
<path d="M140 240 L240 240 L220 190 L160 190 Z" fill="#5A4530" opacity="0.9" />
"""
    write("cozy", "02_soft_lamp", svg(d + "\n" + g_def, body))


def cozy_rainy_window():
    d = bg_gradient("bg", [("0%", "#1B1E22"), ("100%", "#11141A")])
    lines = "\n".join(
        f'<line x1="{20 + i * 22}" y1="{-20}" x2="{5 + i * 22}" y2="{H + 20}" stroke="#3A4650" stroke-width="1.4" opacity="0.35" />'
        for i in range(20)
    )
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{lines}
{hills("#171B20", H * 0.75, 16)}
"""
    write("cozy", "03_rainy_window", svg(d, body))


# ---------------------------------------------------------------------------
# ROMANTIC
# ---------------------------------------------------------------------------

def romantic_candlelit():
    d = bg_gradient("bg", [("0%", "#241019"), ("100%", "#160A10")])
    g_def, g_body = glow(200, 500, 220, "#E8899E", "glow4")
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{g_body}
<ellipse cx="200" cy="560" rx="10" ry="16" fill="#F3B96B" opacity="0.9" />
<rect x="192" y="576" width="16" height="30" rx="3" fill="#3A1E22" />
"""
    write("romantic", "01_candlelit", svg(d + "\n" + g_def, body))


def romantic_sunset_apartment():
    d = bg_gradient("bg", [("0%", "#3A1B2E"), ("50%", "#7A3B4A"), ("100%", "#E8895F")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
<circle cx="{W / 2}" cy="520" r="90" fill="#F3D08A" opacity="0.85" />
{city_skyline("#2A1522", H * 0.72, 11)}
"""
    write("romantic", "02_sunset_apartment", svg(d, body))


def romantic_soft_pink_night():
    d = bg_gradient("bg", [("0%", "#2A1622"), ("100%", "#160B14")])
    g_def, g_body = glow(300, 160, 240, "#F3A6C1", "glow5")
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{g_body}
{stars(25, 5)}
"""
    write("romantic", "03_soft_pink_night", svg(d + "\n" + g_def, body))


# ---------------------------------------------------------------------------
# MINIMAL
# ---------------------------------------------------------------------------

def minimal_dark_studio():
    d = bg_gradient("bg", [("0%", "#161618"), ("100%", "#0B0B0D")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
<rect x="0" y="{H * 0.62}" width="{W}" height="2" fill="#26262C" />
"""
    write("minimal", "01_dark_studio", svg(d, body))


def minimal_modern_apartment():
    d = bg_gradient("bg", [("0%", "#1D1D22"), ("100%", "#101013")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
<rect x="40" y="120" width="140" height="220" fill="#25252C" opacity="0.6" />
<rect x="220" y="90" width="120" height="250" fill="#1A1A20" opacity="0.6" />
"""
    write("minimal", "02_modern_apartment", svg(d, body))


def minimal_gray_interior():
    d = bg_gradient("bg", [("0%", "#232326"), ("100%", "#18181B")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{hills("#1E1E22", H * 0.78, 10)}
"""
    write("minimal", "03_gray_interior", svg(d, body))


# ---------------------------------------------------------------------------
# NATURE
# ---------------------------------------------------------------------------

def nature_forest_night():
    d = bg_gradient("bg", [("0%", "#0C1712"), ("100%", "#08100D")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{stars(20, 6)}
{moon(320, 110, 34)}
{trees("#0E1D16", H * 0.72, 9)}
"""
    write("nature", "01_forest_night", svg(d, body))


def nature_beach_sunset():
    d = bg_gradient("bg", [("0%", "#3A2A4A"), ("55%", "#C15B5B"), ("100%", "#F3B96B")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
<circle cx="{W / 2}" cy="480" r="80" fill="#FCE3B0" opacity="0.9" />
{hills("#2A2035", H * 0.68, 14)}
"""
    write("nature", "02_beach_sunset", svg(d, body))


def nature_mountain_evening():
    d = bg_gradient("bg", [("0%", "#1A2233"), ("100%", "#0E1420")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{moon(90, 110, 26)}
<path d="M0 {H * 0.6} L120 {H * 0.42} L200 {H * 0.55} L300 {H * 0.36} L{W} {H * 0.58} L{W} {H} L0 {H} Z" fill="#141B28" />
<path d="M0 {H * 0.68} L160 {H * 0.55} L{W} {H * 0.68} L{W} {H} L0 {H} Z" fill="#0F1522" />
"""
    write("nature", "03_mountain_evening", svg(d, body))


# ---------------------------------------------------------------------------
# CITY
# ---------------------------------------------------------------------------

def city_neon_street():
    d = bg_gradient("bg", [("0%", "#12071A"), ("100%", "#1A0E2A")])
    g_def, g_body = glow(320, 300, 200, "#B7A2F3", "glow6")
    g2_def, g2_body = glow(80, 500, 180, "#5FD3E8", "glow7")
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{g_body}
{g2_body}
{city_skyline("#0F0A18", H * 0.64, 21)}
"""
    write("city", "01_neon_street", svg(d + "\n" + g_def + "\n" + g2_def, body))


def city_rooftop():
    d = bg_gradient("bg", [("0%", "#0E1420"), ("100%", "#171029")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{stars(15, 8)}
{city_skyline("#101828", H * 0.74, 33)}
<rect x="0" y="{H * 0.72}" width="{W}" height="10" fill="#0B111B" />
"""
    write("city", "02_rooftop", svg(d, body))


def city_skyline_view():
    d = bg_gradient("bg", [("0%", "#0D1420"), ("100%", "#141024")])
    body = f"""
<rect width="{W}" height="{H}" fill="url(#bg)" />
{city_skyline("#111826", H * 0.5, 44)}
{city_skyline("#0C1119", H * 0.62, 45)}
"""
    write("city", "03_skyline_view", svg(d, body))


if __name__ == "__main__":
    night_moonlit_bedroom()
    night_city_at_night()
    night_starry_sky()
    cozy_warm_bedroom()
    cozy_soft_lamp()
    cozy_rainy_window()
    romantic_candlelit()
    romantic_sunset_apartment()
    romantic_soft_pink_night()
    minimal_dark_studio()
    minimal_modern_apartment()
    minimal_gray_interior()
    nature_forest_night()
    nature_beach_sunset()
    nature_mountain_evening()
    city_neon_street()
    city_rooftop()
    city_skyline_view()
    print("Wallpaper asset generation complete.")
