# Bölüm 1 · Alan 2: Balon Kanyonu. Tasarım: docs/features/bolum-1/design.md
# Öğret: Balon ile kısa boşlukları süzülerek geçmek · Sına: uzun boşluklar, kaybolan platformlar
# Şaşırt: rüzgâr akımları balonla Bip'i yukarı taşır · Ustalık: açılıp kapanan pervaneler arasında süzülüş
# Süzülme: 3 sn, 1,5 m/s düşüş, 5 m/s yatay → aynı yükseklikte ~10 m, 3 m aşağıya ~13 m.
# Çalıştırma: python3 tools/level/ch1_a2_balon_kanyonu.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch1_balon", "Balon Kanyonu", "scenes/chapter1/a2_balon_kanyonu.tscn", sky="sunset",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", kill_height=-12, water=-8, seed=22)
PI = math.pi
C = "canyon"


def mesa(cx, top, cz, sx, sz, theme=C):
    """Yerden yükselen kanyon sütunu (üst yüzeyi 'top')."""
    L.top(cx, top, cz, sx, sz, depth=top + 10, theme=theme)


def plants(x0, x1, z0, z1, y, n):
    for _ in range(n):
        L.deco(random.choice(["plant", "plant_small", "grass2"]), random.uniform(x0, x1), y, random.uniform(z0, z1), random.uniform(0.7, 1.1))


# Kanyon duvarları (arka plan, oynanışa girmez)
for side in (-1, 1):
    for i, (z0, z1, h) in enumerate([(12, -40, 34), (-40, -95, 38), (-95, -155, 35)]):
        L.box(side * 20, (h - 10) / 2, (z0 + z1) / 2, 8, h + 10, abs(z1 - z0), C if i % 2 == 0 else "sand")

# ---------- Başlangıç mesası ----------
mesa(0, 20, 0, 12, 14)                                       # x[-6,6] z[7,-7]
L.start(0, 20.1, 4, ry=PI)
L.ent("copy", 2.5, 20, -2.5, ability="balon")
L.ent("hint", 2.5, 20, -2.5, hint="ability", size=(5, 3, 5))
L.ent("hint", 0, 20, -5.5, hint="hold_jump", size=(12, 3, 3))
L.battery_line((-2, 20, 3), (-2, 20, -4), 4)
L.ent("crate", -4, 20, -5, batteries=3)
L.rock(4.5, 20, 5, 0.8); L.deco("rocktall", -5.5, 20, 6, 0.5)
plants(-5, 5, -6, 6, 20, 5)
L.guide(0, 22, -6)

# ---------- Öğret: kısa süzülüşler (6 m, 8 m) ----------
mesa(0, 19, -16.5, 10, 7)                                    # M1 z[-13,-20]
L.battery_arc((0, 20, -7.5), (0, 19, -12.5), 5, 2.0)
plants(-4, 4, -19, -14, 19, 3)
mesa(0, 17, -32, 10, 8)                                      # M2 z[-28,-36]
L.battery_arc((0, 19, -20.5), (0, 17, -27.5), 6, 2.5)
L.ent("checkpoint", 3.5, 17, -34, checkpoint_id="kanyon1", ry=PI)
L.ent("enemy", -2, 17, -31, kind="zipzip", batteries=2)
L.rock(-4, 17, -35, 0.7)
L.guide(0, 19.5, -24)

# ---------- Sına: 12 m'lik uzun süzülüş, sonra kaybolan platformlar ----------
mesa(0, 14, -51.5, 10, 7)                                    # M3 z[-48,-55]
L.battery_arc((0, 17, -36.5), (0, 14, -47.5), 7, 3.0)
L.ent("crate", 3.5, 14, -50, batteries=3)
plants(-4, 4, -54, -49, 14, 3)
L.guide(0, 17, -42)
for i, z in enumerate((-59, -63.5, -68, -72.5)):
    L.ent("platform", 0, 13.75, z, kind="fall", size=(3, 0.5, 3), color=(0.95, 0.7, 0.45, 1))
    L.battery(0, 14, z)
mesa(0, 14, -80, 12, 8)                                      # M4 z[-76,-84]
L.ent("checkpoint", 4, 14, -78, checkpoint_id="dusen", ry=PI)

# Gizli Altın Vida: kanyonun doğu dibinde bir çıkıntı; dönüş rüzgârla
mesa(13, 7, -58, 4, 4, theme="sand")
L.ent("screw", 13, 7.2, -58.5)
L.ent("wind", 13, 7, -62.5, size=(3, 15, 3), force=(0, 14, 0))
L.battery_line((13, 9, -62.5), (13, 16, -62.5), 3)

# ---------- Yay yeniden (kural 4): 4,5 m'lik duvar ----------
L.ent("copy", -3.5, 14, -78.5, ability="yay")
mesa(0, 18.5, -90, 12, 8)                                    # M5 z[-86,-94]
L.battery_line((0, 14.5, -85), (0, 18.0, -85), 3)
L.ent("copy", 3, 18.5, -88, ability="balon")                 # balon yeniden
L.ent("enemy", -3, 18.5, -91, kind="vidabocek", patrol=2.0, speed=1.2, batteries=2)
L.deco("arrow", 0, 18.5, -93.5, 0.9, ry=PI)
L.guide(0, 21, -87)

# ---------- Şaşırt: rüzgâr akımları (Balon ile süzülürken yukarı taşır) ----------
L.ent("wind", 0, 2, -99, size=(5, 26, 5), force=(0, 14, 0))
L.ent("wind", 0, 2, -105, size=(5, 26, 5), force=(0, 14, 0))
L.battery_line((0, 21, -99), (0, 25, -99), 3)
L.battery_line((0, 22, -105), (0, 26, -105), 3)
mesa(0, 22, -114, 12, 8)                                     # M6 z[-110,-118] (kalkıştan 3,5 m yüksek)
L.ent("checkpoint", 4, 22, -112, checkpoint_id="ruzgar", ry=PI)
L.ent("copy", -4, 22, -112, ability="balon")
plants(-5, 5, -117, -111, 22, 4)
L.guide(0, 24, -102)

# ---------- Ustalık: açılıp kapanan pervaneler ----------
mesa(0, 18, -129.5, 3, 3, theme="sand")                      # ara sütun (4 m aşağıda)
L.battery(0, 18, -129.5)
L.ent("wind", 0, 2, -123.5, size=(4, 24, 4), force=(0, 12, 0), cycle=3.0, offset=0.0)
L.ent("wind", 0, 2, -136, size=(4, 26, 4), force=(0, 15, 0), cycle=3.0, offset=1.5)
L.battery_line((0, 21, -136), (0, 25, -136), 3)
mesa(0, 22, -145, 12, 8)                                     # M7 z[-141,-149]
L.ent("exit", 0, 22, -146.5)
L.deco("flag", 4.5, 22, -148, 0.8, ry=PI)
plants(-5, 5, -148.5, -141.5, 22, 4)
L.guide(0, 24, -136)

L.clouds(18, xr=(-100, 100), zr=(-220, 60), avoid=(-30, 30, -160, 20), low=(-6, -3), high=(30, 50))
L.write()
