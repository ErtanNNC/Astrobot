# Bölüm 1 · Alan 1: Yay Bahçesi. Tasarım: docs/features/bolum-1/design.md
# Öğret: yaylarla basamaklar, ilk gerçek çukurlar · Sına: hareketli platformlarda yaylar
# Şaşırt: yaylar (trambolinler) platformla birlikte hareket eder; Yay ile düşman ezmek
# Ustalık: Vidaböcek'lerle dolu dönen yay kulesi
# Çalıştırma: python3 tools/level/ch1_a1_yay_bahcesi.py
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch1_yay", "Yay Bahçesi", "scenes/chapter1/a1_yay_bahcesi.tscn", sky="day",
          music="res://assets/audio/opengameart/happy_clappy_loop.mp3", kill_height=-12, water=-8, seed=11)
PI = math.pi

# ---------- Başlangıç adası ----------
L.top(0, 0, 0, 16, 16, depth=4, theme="grass")             # x[-8,8] z[8,-8]
L.start(0, 0.1, 5, ry=PI)
L.ent("copy", 2.5, 0, -3, ability="yay")
L.ent("hint", 2.5, 0, -3, hint="ability", size=(5, 3, 5))
L.battery_line((0, 0, 3), (0, 0, -5), 4)
L.ent("crate", -5, 0, -5, batteries=3)
L.tree(-6.3, 0, 6.3, 1.0, True); L.tree(6.5, 0, 6.0, 0.9)
L.bush(-6.5, 0, -1, 0.9); L.bush(6.6, 0, -6.2, 0.8)
L.grass_patch(-7.5, 7.5, -7.5, 7.5, 0, 14, avoid=[(-2, 4, -8, 8)])
L.deco("arrow", 0, 0, -6.8, 1.0, ry=PI)
L.guide(0, 2.2, -6.5)

# ---------- Öğret: yaylı teraslar (4 m'lik basamaklar, Yay şart) ----------
L.top(0, 4, -12, 12, 7, depth=8, theme="grass2")            # T1 z[-8.5,-15.5]
L.top(0, 8, -19.5, 12, 7, depth=12, theme="grass")          # T2 z[-16,-23]
L.battery_line((-2, 0.5, -7.5), (-2, 3.8, -7.5), 3)          # yukarı doğru pil sütunu
L.battery_line((2, 4.5, -15.0), (2, 7.8, -15.0), 3)
L.ent("checkpoint", 4, 8, -21, checkpoint_id="teras", ry=PI)
L.bush(-4.5, 4, -10, 0.7); L.bush(-4.8, 8, -18, 0.8)
L.grass_patch(-5.5, 5.5, -22.5, -16.5, 8, 8, avoid=[(-2, 2, -23, -16), (3, 5, -22, -20)])
L.guide(0, 6.5, -12)

# ---------- İlk gerçek çukurlar (4 m ve 5 m) ----------
L.top(0, 8, -29, 6, 4, depth=5, theme="grass2")             # I1 z[-27,-31]
L.top(0, 8, -38.5, 6, 5, depth=5, theme="grass")            # I2 z[-36,-41]
L.battery_arc((0, 8, -23.5), (0, 8, -27.5), 4, 2.5)
L.battery_arc((0, 8, -31.5), (0, 8, -35.5), 4, 3.0)
L.grass_patch(-2.5, 2.5, -40.5, -36.5, 8, 3)

# ---------- Sına: hareketli platform ve asansör ----------
L.ent("platform", 0, 7.75, -44.5, kind="move", size=(4, 0.5, 4), offset=(0, 0, -8), duration=3.0)
L.battery_line((0, 8.6, -45), (0, 8.6, -51), 3)
L.top(0, 11, -59.5, 10, 7, depth=6, theme="grass")          # I3 z[-56,-63]
L.ent("enemy", 0, 11, -59.5, kind="vidabocek", patrol=3.0, speed=1.4, batteries=3)
L.ent("crate", 4, 11, -57, batteries=3)
L.ent("crate", -4, 11, -61.8, batteries=2)
L.tree(-4, 11, -57, 0.6)
L.ent("platform", 0, 10.75, -65.5, kind="move", size=(3, 0.5, 3), offset=(0, 6, 0), duration=3.0, color=(0.95, 0.75, 0.3, 1))
L.battery_line((0, 12.5, -65.5), (0, 16.5, -65.5), 3)
L.top(0, 17, -72, 12, 6, depth=8, theme="grass2")           # I4 z[-69,-75]
L.ent("checkpoint", 4, 17, -73, checkpoint_id="asansor", ry=PI)
L.tree(-5, 17, -74, 0.7, True); L.bush(5.2, 17, -70, 0.6)
L.guide(0, 13.5, -59)
L.guide(0, 19, -72)

# ---------- Şaşırt: trambolinler platformlarla birlikte gidip gelir ----------
pa = L.ent("platform", -4, 16.75, -79.5, kind="move", size=(4, 0.5, 4), offset=(8, 0, 0), duration=2.5, color=(0.45, 0.8, 1.0, 1))
L.ent("trampoline", 0, 0.25, 0, parent="Entities/" + pa, height=6.0)
pb = L.ent("platform", 4, 19.75, -87, kind="move", size=(4, 0.5, 4), offset=(-8, 0, 0), duration=2.5, color=(0.45, 0.8, 1.0, 1))
L.ent("trampoline", 0, 0.25, 0, parent="Entities/" + pb, height=6.0)
pc = L.ent("platform", -4, 22.75, -94.5, kind="move", size=(4, 0.5, 4), offset=(8, 0, 0), duration=2.5, color=(0.45, 0.8, 1.0, 1))
L.ent("trampoline", 0, 0.25, 0, parent="Entities/" + pc, height=6.0)
L.battery_arc((0, 17, -80), (0, 20, -87), 5, 5.5)
L.battery_arc((0, 20, -87), (0, 23, -94.5), 5, 5.5)
L.guide(0, 21, -80)
# Gizli Altın Vida: platform B'nin sağında yüksek ada (şarjlı Yay gerekir)
L.top(11.5, 26, -87, 3, 3, depth=1.5, theme="yellow")
L.ent("screw", 11.5, 26.2, -87)
L.deco("flag", 12.6, 26, -88, 0.6, ry=PI)

# ---------- Yay ile düşman ezme alanı ----------
L.top(0, 23, -103.5, 14, 9, depth=6, theme="grass")         # I5 z[-99,-108]
L.ent("checkpoint", 5, 23, -101, checkpoint_id="kule", ry=PI)
L.ent("copy", -5, 23, -101, ability="yay")
for i, x in enumerate((-3, 0, 3)):
    L.ent("enemy", x, 23, -104 - (i % 2), kind="vidabocek", patrol=1.5, speed=1.0 + 0.3 * i, batteries=2)
L.ent("crate", 6, 23, -106.5, batteries=3)
L.battery_ring((0, 23, -104), 2.2, 6)
L.tree(-6, 23, -107.3, 0.6); L.bush(6.3, 23, -100, 0.6)

# ---------- Ustalık: dönen yay kulesi ----------
s1 = L.ent("platform", 0, 22.75, -114, kind="spin", size=(8, 0.5, 8), duration=10.0, color=(0.55, 0.85, 0.35, 1))
L.ent("enemy", 2, 23.1, -114, kind="vidabocek", patrol=1.5, speed=1.0, batteries=2)
s2 = L.ent("platform", 5, 27.25, -121, kind="spin", size=(6, 0.5, 6), duration=-8.0, color=(0.98, 0.84, 0.32, 1))
L.ent("trampoline", 1.6, 0.25, 1.6, parent="Entities/" + s2, height=5.5)
s3 = L.ent("platform", -1, 31.75, -127, kind="spin", size=(6, 0.5, 6), duration=7.0, color=(0.55, 0.85, 0.35, 1))
L.ent("enemy", -1, 32.1, -127, kind="vidabocek", patrol=1.2, speed=1.0, batteries=2)
L.battery_line((0, 23, -112), (0, 23, -116), 3)
L.battery_arc((1, 23.5, -116), (5, 27.5, -120), 4, 3.0)
L.battery_arc((4, 27.5, -122), (-1, 32, -126), 4, 3.0)
L.guide(2.5, 27.5, -117)

# ---------- Çıkış ----------
L.top(0, 32, -136, 10, 8, depth=6, theme="grass2")          # I6 z[-132,-140]
L.ent("exit", 0, 32, -137.5)
L.tree(-4, 32, -139, 0.7, True); L.tree(4.2, 32, -139, 0.6)
L.grass_patch(-4.5, 4.5, -139.5, -132.5, 32, 6, avoid=[(-2, 2, -140, -132)])
L.guide(0, 34, -133)

L.clouds(26, xr=(-90, 90), zr=(-200, 60), avoid=(-20, 20, -150, 20), low=(-6, -2), high=(8, 40))
L.write()
