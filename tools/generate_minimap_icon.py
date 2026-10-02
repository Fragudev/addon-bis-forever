#!/usr/bin/env python3
"""Regenerate the inner artwork of ForeverBiSMinimapIcon.tga.

Keeps the existing gold minimap ring untouched and redraws everything inside it:
a navy radial background with a bevelled gold "FB" monogram.
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
GLOW = (90, 150, 230)
GOLD_LIGHT = (255, 236, 160)
GOLD_MID = (230, 186, 84)
GOLD_DARK = (150, 96, 26)
OUTLINE = (24, 14, 6)
WHITE = (255, 255, 250)

CX, CY = 63.5, 63.5
LETTER_TOP, LETTER_BOTTOM = 40.0, 88.0
OUTLINE_WIDTH = 2.6


def box(x, y, x0, y0, x1, y1):
    """Signed distance to an axis-aligned rectangle (negative inside)."""
    dx = max(x0 - x, x - x1)
    dy = max(y0 - y, y - y1)
    outside = math.hypot(max(dx, 0.0), max(dy, 0.0))
    return outside + min(max(dx, dy), 0.0)


def half_ring(x, y, cx, cy, radius, half_thickness):
    """Signed distance to the right half of a ring (the bowl of a B)."""
    ring = abs(math.hypot(x - cx, y - cy) - radius) - half_thickness
    return max(ring, cx - x)


def monogram(x, y):
    """Signed distance to the FB monogram."""
    f = min(
        box(x, y, 32, 40, 41, 88),  # stem
        box(x, y, 32, 40, 61, 48),  # top arm
        box(x, y, 32, 60, 56, 67),  # middle arm
    )
    b = min(
        box(x, y, 66, 40, 75, 88),  # stem
        box(x, y, 66, 40, 82, 48),  # top bar
        box(x, y, 66, 56.5, 83, 64.5),  # middle bar
        box(x, y, 66, 80, 84, 88),  # bottom bar
        half_ring(x, y, 82, 52.25, 7.75, 4.25),  # upper bowl
        half_ring(x, y, 84, 72.25, 11.75, 4.0),  # lower bowl
    )
    return min(f, b)


def shade(x, y):
    dist = math.hypot(x - CX, y - CY)

    # Background: navy radial gradient with an inner shadow under the ring.
    color = mix(NAVY_CENTER, NAVY_EDGE, (dist / RING_INNER_RADIUS) ** 1.4)
    if dist > RING_INNER_RADIUS - 6:
        color = over(color, (0, 0, 0), (dist - (RING_INNER_RADIUS - 6)) / 6 * 0.7)

    # Soft blue glow behind the letters.
    glow = max(0.0, 1 - math.hypot((x - CX) / 46, (y - CY) / 34))
    color = over(color, GLOW, glow**2 * 0.45)

    # Drop shadow, dark outline, then bevelled gold letters.
    if monogram(x - 1.5, y - 2.0) < OUTLINE_WIDTH:
        color = over(color, (0, 0, 0), 0.6)
    d = monogram(x, y)
    if d < OUTLINE_WIDTH:
        color = OUTLINE
    if d < 0:
        vertical = (y - LETTER_TOP) / (LETTER_BOTTOM - LETTER_TOP)
        color = mix(GOLD_LIGHT, GOLD_MID, vertical * 1.6)
        color = mix(color, GOLD_DARK, (vertical - 0.6) * 2)
        # Bevel: light rim on the upper-left edge of every stroke.
        if d > -1.6 and monogram(x - 1.6, y - 1.6) > 0:
            color = over(color, WHITE, 0.45)

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
