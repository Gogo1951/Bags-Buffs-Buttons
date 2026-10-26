"""Regenerates Includes/Images/Restocker.tga: the gold bag on dark leather, the Restock List and Staples portrait.

Drawn in the Spell Book portrait's style (tools/gen_textures.py, whose output this does not touch): the same
leather ground, gold and stroke weight on the 24-unit grid, drawn 16x oversize and scaled down so the edges come
out smooth. Needs Pillow.

Usage (from anywhere): python tools/gen_bag_texture.py
"""
import math
import os

from PIL import Image, ImageDraw

here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out_dir = os.path.join(here, "Includes", "Images")
SUPER = 16
GOLD = (201, 164, 74)
LEATHER, LEATHER_EDGE = (42, 32, 22), (22, 16, 10)
OPTICAL_LIFT = 1.25  # grid units the glyph rides above its outline's centre


def stroke(draw, lines, scale, offset_x, offset_y, width, color):
    """Draws polylines on a unit grid with round joins and caps."""
    for line in lines:
        points = [(offset_x + px * scale, offset_y + py * scale) for px, py in line]
        draw.line(points, fill=color + (255,), width=round(width))
        for px, py in points:
            draw.ellipse((px - width / 2, py - width / 2, px + width / 2, py + width / 2), fill=color + (255,))


def arc(cx, cy, r, start, end, steps=24):
    return [(cx + r * math.cos(math.radians(a)), cy + r * math.sin(math.radians(a)))
            for a in (start + (end - start) * i / steps for i in range(steps + 1))]


def bag():
    # A shopping bag on the 24-unit grid, stroke 1.6: the body, its handle, and a fold across the top
    size = 64
    big = size * SUPER
    left, top, right, bottom, r = 5.0, 9.0, 19.0, 20.5, 2.0
    body = [(left, top), (right, top), (right, bottom - r)] + arc(right - r, bottom - r, r, 0, 90) \
        + [(left + r, bottom)] + arc(left + r, bottom - r, r, 90, 180) + [(left, top)]
    handle = arc(12.0, top, 3.5, 180, 360)
    fold = [(left, 12.5), (right, 12.5)]
    height = bottom - (top - 3.5)
    scale = big * 0.56 / height  # the bag fills 56% of the texture's height, as the book does

    image = Image.new("RGBA", (big, big))
    pixels = image.load()
    # Leather ground, darkening toward the corners like the game's own icons
    for y in range(0, big, SUPER):
        for x in range(0, big, SUPER):
            t = min(1.0, math.hypot(x - big / 2, y - big / 2) / (big / 2 * math.sqrt(2)))
            color = tuple(round(a + (b - a) * t * t) for a, b in zip(LEATHER, LEATHER_EDGE)) + (255,)
            for dy in range(SUPER):
                for dx in range(SUPER):
                    pixels[x + dx, y + dy] = color
    # Centred on its weight rather than its outline: the body carries the mass, so the outline's centre reads low.
    center_y = (top - 3.5 + bottom) / 2 + OPTICAL_LIFT
    stroke(ImageDraw.Draw(image), (body, handle, fold), scale, big / 2 - (left + right) / 2 * scale,
           big / 2 - center_y * scale, 1.6 * scale, GOLD)
    path = os.path.join(out_dir, "Restocker.tga")
    small = image.resize((size, size), Image.LANCZOS)
    small.save(path)
    print("wrote", path)
    return small


if __name__ == "__main__":
    bag()
