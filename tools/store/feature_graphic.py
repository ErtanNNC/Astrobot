# Google Play öne çıkan görseli (1024×500) → build/magaza/one_cikan_<dil>.png
# Kullanım: python3 tools/store/feature_graphic.py ["Oyun Adı"]   (önce tools/store/make_shots.sh çalışmış olmalı)
import os, sys
from PIL import Image, ImageDraw, ImageFont, ImageFilter

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
NAME = sys.argv[1] if len(sys.argv) > 1 else "Bip"
FONT = os.path.join(ROOT, "assets/fonts/nunito/Nunito.ttf")
TAGS = {"tr": "Kopyala, zıpla, adayı aydınlat!", "en": "Copy, jump, light up the island!"}


def font(size, weight=900):
    f = ImageFont.truetype(FONT, size)
    try:
        f.set_variation_by_axes([weight])
    except Exception:
        pass
    return f


def outlined(d, xy, text, f, fill, stroke, w):
    d.text(xy, text, font=f, fill=fill, stroke_width=w, stroke_fill=stroke)


for lang, tag in TAGS.items():
    bg = Image.open(os.path.join(ROOT, "build/magaza/01_yay_bahcesi_0.png")).convert("RGB")
    bg = bg.crop((0, 150, 1920, 150 + 937)).resize((1024, 500), Image.LANCZOS).filter(ImageFilter.GaussianBlur(2.5))
    shade = Image.new("RGBA", (1024, 500), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shade)
    for x in range(1024):                                   # solda yazı okunaklı olsun: yumuşak koyu geçiş
        a = int(150 * max(0.0, 1.0 - x / 760.0))
        sd.line([(x, 0), (x, 500)], fill=(20, 40, 80, a))
    img = Image.alpha_composite(bg.convert("RGBA"), shade)
    bip = Image.open(os.path.join(ROOT, "assets/ui/icon_fg_432.png")).convert("RGBA").resize((520, 520), Image.LANCZOS)
    glow = Image.new("RGBA", (1024, 500), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse((560, 20, 1020, 480), fill=(255, 240, 150, 150))
    img = Image.alpha_composite(img, glow.filter(ImageFilter.GaussianBlur(40)))
    img.alpha_composite(bip, (530, -10))
    d = ImageDraw.Draw(img)
    size = 190
    while font(size).getlength(NAME) > 470 and size > 60:
        size -= 6
    outlined(d, (60, 250 - size - 10), NAME, font(size), (255, 214, 60), (120, 50, 20), 10)
    outlined(d, (64, 290), tag, font(40, 800), (255, 255, 255), (30, 50, 90), 5)
    out = os.path.join(ROOT, "build/magaza/one_cikan_%s.png" % lang)
    img.convert("RGB").save(out)
    print(out)
