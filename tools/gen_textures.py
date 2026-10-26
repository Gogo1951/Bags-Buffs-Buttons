"""Regenerates the Spellbook's textures in Includes/Images/.

  Spellbook.tga  the gold book on dark leather: the window portrait and the spellbook tab
  Gear.tga  a gear, white on clear: the category and settings buttons, tinted gold in game

Usage (from anywhere): python tools/gen_textures.py
Needs Pillow. Each glyph is the design's own SVG shape (BUILD SPEC boards), drawn 16x oversize and scaled down so the
edges come out smooth. Then /reload.
"""
import math
import os

from PIL import Image, ImageDraw

here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
out_dir = os.path.join(here, "Includes", "Images")
SUPER = 16
GOLD, WHITE = (201, 164, 74), (255, 255, 255)


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


def save(image, size, name):
    path = os.path.join(out_dir, name)
    image.resize((size, size), Image.LANCZOS).save(path)
    print("wrote", path)


def icon():
    # The book on the 24-unit grid, stroke 1.6: spine curve and title line ride on top of the cover
    size = 64
    big = size * SUPER
    left, top, right, bottom, r = 5.0, 4.5, 17.5, 20.0, 2.0
    cover = [(left, top), (right - r, top)] + arc(right - r, top + r, r, -90, 0) + [(right, bottom), (left + r, bottom)] \
        + arc(left + r, bottom - r, r, 90, 180) + [(left, top)]
    spine = arc(left + r, 18.0, r, 180, 270) + [(right, 16.0)]
    title = [(9.0, 8.0), (14.0, 8.0)]
    scale = big * 0.56 / (bottom - top)  # the book fills 56% of the texture's height

    leather, leather_edge = (42, 32, 22), (22, 16, 10)
    image = Image.new("RGBA", (big, big))
    pixels = image.load()
    # Leather ground, darkening toward the corners like the game's own icons
    for y in range(0, big, SUPER):
        for x in range(0, big, SUPER):
            t = min(1.0, math.hypot(x - big / 2, y - big / 2) / (big / 2 * math.sqrt(2)))
            color = tuple(round(a + (b - a) * t * t) for a, b in zip(leather, leather_edge)) + (255,)
            for dy in range(SUPER):
                for dx in range(SUPER):
                    pixels[x + dx, y + dy] = color
    stroke(ImageDraw.Draw(image), (cover, spine, title), scale, big / 2 - (left + right) / 2 * scale,
           big / 2 - (top + bottom) / 2 * scale, 1.6 * scale, GOLD)
    save(image, size, "Spellbook.tga")


def gear():
    # A ring, a hub and eight spokes on the 20-unit grid, stroke 2
    size = 32
    big = size * SUPER
    lines = [arc(10, 10, 2.4, 0, 360, 48), arc(10, 10, 5.6, 0, 360, 96),
             [(10, 1.8), (10, 4.4)], [(10, 15.6), (10, 18.2)], [(1.8, 10), (4.4, 10)], [(15.6, 10), (18.2, 10)],
             [(4.2, 4.2), (6, 6)], [(14, 14), (15.8, 15.8)], [(4.2, 15.8), (6, 14)], [(14, 6), (15.8, 4.2)]]
    scale = big / 20
    image = Image.new("RGBA", (big, big), WHITE + (0,))
    stroke(ImageDraw.Draw(image), lines, scale, 0, 0, 2 * scale, WHITE)
    save(image, size, "Gear.tga")


os.makedirs(out_dir, exist_ok=True)
icon()
gear()
