# Bölüm 3 · Buz Mağarası: Buz yeteneğini öğretir. Tasarım: docs/features/bolum-3/design.md
# Kural: uzak kıyılar yüzerek çıkılamayacak kadar yüksek (yüzme ~1,75 m), buz karosundan çıkılır (~2,2 m).
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch3_magara", "Buz Mağarası", "scenes/chapter3/c1_buz_magarasi.tscn", sky="indoor",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", water=None, kill_height=-12, seed=31)


def wall(x0, x1, z0, z1, top, bottom=0.0, theme="stone"):
    L.box((x0 + x1) / 2, (top + bottom) / 2, (z0 + z1) / 2, abs(x1 - x0), top - bottom, abs(z1 - z0), theme)


# ---------- S1: giriş salonu, Buz kristali ----------
L.top(0, 0, -1, 12, 18, depth=2, theme="snow")                 # z[8,-10]
L.start(0, 0.1, 5, ry=math.pi)
L.ent("copy", 0, 0, -3, ability="buz")
L.ent("hint", 0, 0, -3, hint="ability", size=(7, 3, 6))
L.battery_line((0, 0, 3), (0, 0, 0), 2)
L.ent("crate", -4.5, 0, 5, batteries=3)
L.ent("crate", 4.5, 0, 5, batteries=2)
wall(-7, -6, 8.5, -10, 7, -3); wall(6, 7, 8.5, -10, 7, -3); wall(-7, 7, 8.5, 9, 7, 0)
L.guide(0, 1.8, -4)

# ---------- Havuz 1: Buz ile suyun üstünde yürümek ----------
L.top(0, -3, -15, 12, 10, depth=1, theme="stone")               # havuz tabanı z[-10,-20]
L.ent("water", 0, 0, -15, size=(12, 3, 10))
L.top(0, 2.15, -26, 12, 12, depth=5, theme="ice")                # uzak kıyı z[-20,-32] (yüksek: yüzerek çıkılmaz)
L.battery_arc((0, 0.3, -11), (0, 2.15, -19), 5, 1.6)
L.guide(0, 2.0, -15)
wall(-7, -6, -10, -32, 9, -3); wall(6, 7, -10, -25, 9, -3); wall(6, 7, -31, -38, 9, -3)
L.ent("checkpoint", -4, 2.15, -22, checkpoint_id="havuz1", ry=math.pi)

# Gizli Altın Vida: yan mağaradaki havuzun ortasında, yalnızca buzdan çıkılan adacık
L.top(10, -0.85, -28, 8, 6, depth=1, theme="stone")
L.ent("water", 10, 2.15, -28, size=(8, 3, 6))
L.top(12.5, 4.3, -28, 2, 2, depth=6, theme="ice")
L.ent("screw", 12.5, 4.4, -28)
wall(14, 15, -24.5, -31.5, 9, -0.85); wall(6.5, 15, -24.5, -25, 9, -0.85); wall(6.5, 15, -31, -31.5, 9, -0.85)
L.deco("gem", 13.8, 2.15, -25.6, 1.8); L.deco("gem_pink", 13.6, 2.15, -30.4, 1.6)

# ---------- S3: donmuş düşman basamak olur ----------
L.top(0, 2.15, -35, 12, 6, depth=5, theme="ice")                 # z[-32,-38]
L.ent("copy", -4, 2.15, -27.5, ability="buz")                    # yedek kristal
L.ent("enemy", 0, 2.15, -36.6, kind="vidabocek", patrol=3.0, speed=1.0, batteries=3)
L.ent("hint", 0, 2.15, -35, hint="ability", size=(11, 3, 5), delay=5.0)
L.top(0, 5.35, -41, 12, 6, depth=8, theme="snow")                # +3,2 m çıkıntı z[-38,-44]
L.label(0, 4.3, -37.6, "3,2 m", 40)
L.guide(0, 4.0, -36)

# ---------- Havuz 2: uzun su geçişi ----------
L.top(0, 2.35, -51, 12, 14, depth=4, theme="stone")              # z[-44,-58]
L.ent("water", 0, 5.35, -51, size=(12, 3, 14))
L.top(0, 7.5, -64, 12, 12, depth=8, theme="ice")                # z[-58,-70]
L.battery_line((0, 5.65, -45.5), (0, 5.65, -56.5), 6)
L.ent("checkpoint", -4, 7.5, -61, checkpoint_id="havuz2", ry=math.pi)
L.guide(0, 7.0, -51)
wall(-7, -6, -32, -98, 20, -3); wall(6, 7, -38, -98, 20, -3); wall(-7, 7, -98, -99, 20, 0)

# ---------- Ustalık: düşmanları sırayla dondurup merdiven yap ----------
L.top(0, 7.5, -72, 12, 4, depth=8, theme="ice")                 # z[-70,-74]
L.ent("copy", 4, 7.5, -63, ability="buz")
L.ent("enemy", 0, 7.5, -72.6, kind="vidabocek", patrol=3.0, speed=1.1, batteries=3)
L.ent("enemy", -3, 7.5, -66, kind="zipzip", batteries=2)
L.ent("enemy", 3, 7.5, -67.5, kind="zipzip", batteries=2)
L.top(0, 10.7, -78, 12, 8, depth=4, theme="snow")               # z[-74,-82]
L.ent("enemy", 0, 10.7, -80.6, kind="vidabocek", patrol=3.0, speed=1.1, batteries=3)
L.battery_ring((-3.5, 10.7, -77), 0.8, 4)
L.top(0, 13.9, -90, 12, 16, depth=4, theme="ice")               # z[-82,-98]
L.battery_line((-3, 13.9, -85), (3, 13.9, -85), 4)
L.ent("exit", 0, 13.9, -93)
L.guide(0, 10.2, -73); L.guide(0, 13.5, -80)

# ---------- Süs: buz kristalleri, lambalar, kayalar ----------
for z in (-2, -18, -34, -50, -66, -84):
    L.ent("prop", -5.6, 4.5 + max(0, -z) * 0.13, z, kind="lamp", size=1.1)
    L.ent("prop", 5.6, 4.5 + max(0, -z) * 0.13, z - 6, kind="lamp", size=1.1)
for x, y, z, s in ((-5, 0, 6, 1.6), (5, 0, -7, 1.4), (-5.2, 2.15, -30, 1.5), (5.2, 7.5, -60, 1.8), (-5, 13.9, -96, 2.0), (5, 13.9, -95, 1.5), (-5, 10.7, -76, 1.3)):
    L.deco(random.choice(["gem", "gem_pink"]), x, y, z, s)
L.rock(-4.8, 0, -8.5, 0.6); L.rock(4.3, 7.5, -71, 0.5)
L.write()
