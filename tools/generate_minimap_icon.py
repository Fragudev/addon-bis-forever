#!/usr/bin/env python3
"""Regenerate the inner artwork of ForeverBiSMinimapIcon.tga.

Keeps the existing gold minimap ring untouched and redraws everything inside it:
a navy radial background with an epic-purple heater shield and a gold sparkle.
Pure Python (no Pillow) so it runs anywhere; 4x4 supersampling for anti-aliasing.

Usage: python3 tools/generate_minimap_icon.py [path/to/ForeverBiSMinimapIcon.tga]
"""

import math
import struct
import sys

ICON_PATH = sys.argv[1] if len(sys.argv) > 1 else "ForeverBiS/ForeverBiSMinimapIcon.tga"
RING_INNER_RADIUS = 54.0
SUPERSAMPLE = 4


def read_tga(path):
    with open(path, "rb") as f:
        data = f.read()
    id_len, cmap_type, img_type = data[0], data[1], data[2]
    width, height = struct.unpack("<HH", data[12:16])
    bpp, desc = data[16], data[17]
    if cmap_type != 0 or img_type != 2 or bpp != 32:
        raise ValueError("expected an uncompressed 32-bit truecolor TGA")
    raw = data[18 + id_len : 18 + id_len + width * height * 4]
    top_down = bool(desc & 0x20)
    pixels = [[None] * width for _ in range(height)]
    for row in range(height):
        y = row if top_down else height - 1 - row
        for x in range(width):
            b, g, r, a = raw[(row * width + x) * 4 : (row * width + x) * 4 + 4]
            pixels[y][x] = (r, g, b, a)
    return width, height, pixels


def write_tga(path, width, height, pixels):
    header = struct.pack("<BBBHHBHHHHBB", 0, 0, 2, 0, 0, 0, 0, 0, width, height, 32, 8)
    body = bytearray()
    for y in range(height - 1, -1, -1):  # bottom-up, matching the original file
        for x in range(width):
            r, g, b, a = pixels[y][x]
            body += bytes((b, g, r, a))
    with open(path, "wb") as f:
        f.write(header + bytes(body))


def mix(c1, c2, t):
    t = max(0.0, min(1.0, t))
    return tuple(a + (b - a) * t for a, b in zip(c1, c2))


def over(dst, src, alpha):
    return mix(dst, src, alpha)


# Palette
NAVY_CENTER = (34, 62, 112)
NAVY_EDGE = (8, 16, 34)
EPIC_TOP = (190, 110, 255)
EPIC_BOTTOM = (78, 22, 128)
GOLD_LIGHT = (255, 228, 140)
GOLD_MID = (225, 187, 92)
GOLD_DARK = (120, 82, 24)
OUTLINE = (24, 14, 6)
WHITE = (255, 255, 250)

CX, CY = 63.5, 63.5
SHIELD_TOP = CY - 33
SHIELD_SHOULDER = CY + 2
SHIELD_TIP = CY + 40
SHIELD_HALF_WIDTH = 31


def shield_half_width(y, scale):
    """Half width of a heater shield at height y, scaled around the shield center."""
    mid = (SHIELD_TOP + SHIELD_TIP) / 2
    top = mid + (SHIELD_TOP - mid) * scale
    shoulder = mid + (SHIELD_SHOULDER - mid) * scale
    tip = mid + (SHIELD_TIP - mid) * scale
    hw = SHIELD_HALF_WIDTH * scale
    if y < top or y > tip:
        return -1.0
    if y <= shoulder:
        # Slightly rounded top corners.
        corner = 5 * scale
        if y < top + corner:
            k = (top + corner - y) / corner
            return hw - corner * (1 - math.sqrt(max(0.0, 1 - k * k)))
        return hw
    t = (y - shoulder) / (tip - shoulder)
    return hw * math.cos(t * math.pi / 2) ** 0.75


def in_shield(x, y, scale):
    return abs(x - CX) <= shield_half_width(y, scale)


def sparkle(x, y, cx, cy, radius, angle):
    """Astroid-shaped four-point star; returns 0..1 depth (1 at the center)."""
    dx, dy = x - cx, y - cy
    ca, sa = math.cos(angle), math.sin(angle)
    u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    s = math.sqrt(abs(u)) + math.sqrt(abs(v))
    limit = math.sqrt(radius)
    return 1 - s / limit if s < limit else 0.0


def shade(x, y):
    dist = math.hypot(x - CX, y - CY)

    # Background: navy radial gradient with an inner shadow under the ring.
    color = mix(NAVY_CENTER, NAVY_EDGE, (dist / RING_INNER_RADIUS) ** 1.4)
    if dist > RING_INNER_RADIUS - 6:
        color = over(color, (0, 0, 0), (dist - (RING_INNER_RADIUS - 6)) / 6 * 0.7)

    # Soft purple glow behind the shield.
    glow = max(0.0, 1 - math.hypot((x - CX) / 44, (y - CY - 3) / 50))
    color = over(color, (150, 70, 230), glow**2 * 0.55)

    star_center_y = CY + 1
    if in_shield(x, y, 1.08):
        # Dark outline, then gold rim, then epic-purple field.
        color = OUTLINE
        if in_shield(x, y, 1.02):
            vertical = (y - SHIELD_TOP) / (SHIELD_TIP - SHIELD_TOP)
            color = mix(GOLD_LIGHT, GOLD_DARK, vertical * 0.9 + (x - CX) / 120)
        if in_shield(x, y, 0.87):
            color = OUTLINE
        if in_shield(x, y, 0.83):
            vertical = (y - SHIELD_TOP) / (SHIELD_TIP - SHIELD_TOP)
            color = mix(EPIC_TOP, EPIC_BOTTOM, vertical)
            # Diagonal sheen across the upper-left half of the field.
            if (x - CX) + (y - SHIELD_TOP) * 0.9 < 18:
                color = over(color, WHITE, 0.12)

            halo = max(0.0, 1 - math.hypot(x - CX, y - star_center_y) / 24)
            color = over(color, GOLD_LIGHT, halo**2 * 0.45)

    # Gold sparkle (a large upright star plus a small diagonal one).
    main = sparkle(x, y, CX, star_center_y, 21, 0)
    minor = sparkle(x, y, CX, star_center_y, 15, math.pi / 4)
    depth = max(main, minor)
    if depth > 0:
        color = mix(GOLD_MID, GOLD_LIGHT, depth * 2.2)
        color = over(color, WHITE, max(0.0, depth - 0.45) * 2)
    elif sparkle(x, y, CX, star_center_y, 24, 0) > 0 or sparkle(x, y, CX, star_center_y, 17, math.pi / 4) > 0:
        color = over(color, OUTLINE, 0.8)

    return color


def main():
    width, height, pixels = read_tga(ICON_PATH)
    step = 1 / SUPERSAMPLE
    offsets = [(i + 0.5) * step for i in range(SUPERSAMPLE)]
    for y in range(height):
        for x in range(width):
            if math.hypot(x + 0.5 - (CX + 0.5), y + 0.5 - (CY + 0.5)) >= RING_INNER_RADIUS:
                continue  # keep the original gold ring and transparent corners
            acc = [0.0, 0.0, 0.0]
            for oy in offsets:
                for ox in offsets:
                    c = shade(x + ox - 0.5, y + oy - 0.5)
                    acc[0] += c[0]
                    acc[1] += c[1]
                    acc[2] += c[2]
            n = SUPERSAMPLE * SUPERSAMPLE
            pixels[y][x] = (round(acc[0] / n), round(acc[1] / n), round(acc[2] / n), 255)
    write_tga(ICON_PATH, width, height, pixels)


if __name__ == "__main__":
    main()
