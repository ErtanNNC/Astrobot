# Bölüm 2 · Alan 2: Fener Kulesi (Pervane + Yay ile dikey tırmanış). Tasarım: docs/features/bolum-2/design.md
# Çalıştırma: python3 tools/level/ch2_b2_fener.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch2_fener", "Fener Kulesi", "scenes/chapter2/b2_fener.tscn", sky="sunset",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", kill_height=-6, water=-8, seed=22)

PI = math.pi
R = 6.5   # merdiven platformlarının kuleye uzaklığı


def at(angle_deg, r=R):
    a = math.radians(angle_deg)
    return math.cos(a) * r, math.sin(a) * r


# ---------- Taban adası ----------
L.top(0, 0, 0, 32, 32, depth=6, theme="grass")               # x[-16,16] z[16,-16]
L.start(0, 0.1, 13, ry=PI)
# Fener kulesi: kırmızı-beyaz şeritli, tepesi 40 m
for i in range(10):
    L.box(0, i * 4 + 2, 0, 6, 4, 6, "red" if i % 2 == 0 else "stone")
L.ent("copy", 3.2, 0, 10, ability="yay")
L.ent("hint", 3.2, 0, 10, hint="ability", size=(5, 3, 5))
L.ent("enemy", -8, 0, 8, kind="vidabocek", patrol=3, batteries=3)
L.ent("crate", 10, 0, 10, batteries=3)
L.ent("crate", -11, 0, -6, batteries=2)
L.battery_line((0, 0, 11), (0, 0, 8.5), 2)
for x, z in ((-12, 12), (12, -12), (-12, -11), (11, 12)):
    L.tree(x, 0, z, 0.9)
L.grass_patch(-15, 15, -15, 15, 0, 22, avoid=[(-9, 9, -9, 9), (-2, 5, 6, 15)])
L.guide(0, 4.5, 6.5)

# ---------- Öğret: Yay ile spiral basamaklar (her biri 3,5 m) ----------
steps = [(90, 3.5), (45, 7.0), (0, 10.5)]
for ang, y in steps:
    x, z = at(ang)
    L.top(x, y, z, 3.5, 3.5, depth=1.0, theme="wood")
    L.battery(x, y, z)
x, z = at(-45, 7.2)
L.top(x, 14.0, z, 5, 5, depth=1.0, theme="sand")              # balkon (y 14)
L.ent("checkpoint", x, 14.0, z, checkpoint_id="balkon", ry=PI / 4)
L.ent("copy", x - 1.4, 14.0, z - 1.0, ability="pervane")
L.ent("hint", x, 14.0, z, hint="hold_jump", size=(5, 3, 5))
L.ent("enemy", x + 1.2, 14.0, z + 1.2, kind="zipzip", batteries=2)
L.guide(x, 16, z)

# ---------- Sına: Pervane ile 6,5 m'lik basamaklar ----------
for ang, y in ((-90, 20.5), (-135, 27.0)):
    x, z = at(ang)
    L.top(x, y, z, 3.5, 3.5, depth=1.0, theme="wood")
    L.battery_line((x, y, z), (x, y + 2.0, z), 3)
# Gizli Altın Vida: kuleden uzakta yüzen ada (y 20,5 basamağından Pervane + atılma)
L.top(10, 23.0, -6, 2.5, 2.5, depth=0.6, theme="yellow")
L.ent("screw", 10, 23.1, -6)
L.battery_arc((0, 20.5, -6.5), (10, 23.0, -6), 4, 2.5)

# ---------- Şaşırt: yukarı rüzgâr Pervane ile yükselen Bip'i galeriye taşır ----------
x, z = at(180)
L.ent("wind", x, 22, z, size=(4.5, 17, 4.5), force=(0, 20, 0))
L.battery_line((x, 24, z), (x, 34, z), 5)
gx, gz = at(150, 7.5)
L.top(gx, 36.0, gz, 4.5, 4.5, depth=1.0, theme="sand")       # galeri (y 36)
L.ent("checkpoint", gx, 36.0, gz, checkpoint_id="galeri", ry=PI / 2)
L.ent("copy", gx + 0.8, 36.0, gz + 1.0, ability="pervane")
L.guide(gx, 38, gz)

# ---------- Ustalık: dönen platformlarla fenerin tepesine ----------
L.ent("platform", -7.5, 39.25, -6, kind="spin", size=(6, 0.5, 1.4), duration=6.0, color=(0.95, 0.75, 0.3))
L.ent("platform", -2.0, 41.75, -8.5, kind="spin", size=(6, 0.5, 1.4), duration=5.0, color=(0.95, 0.75, 0.3))
L.battery((-7.5, 39.5, -6)[0], 39.5, -6)
L.battery(-2.0, 42.0, -8.5)
# Fener odası (tepe, y 44)
L.top(0, 44.0, 0, 9, 9, depth=4.0, theme="stone")
L.ent("prop", 0, 46.5, 0, kind="lamp", size=2.5)
L.ent("exit", 0, 44.0, 1.5)
L.ent("crate", 3, 44.0, -2.5, batteries=3)
for x in (-4.3, 4.3):
    L.box(x, 44.6, 0, 0.3, 1.2, 9, "wood")
L.box(0, 44.6, 4.35, 9, 1.2, 0.3, "wood")

L.ent("prop", -50, 30, -120, kind="storm", size=4.0)
L.clouds(24, xr=(-90, 90), zr=(-90, 90), avoid=(-25, 25, -25, 25), low=(-6, -3), high=(18, 50))
L.write()
