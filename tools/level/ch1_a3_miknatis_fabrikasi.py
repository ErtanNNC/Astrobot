# Bölüm 1 · Alan 3: Mıknatıs Fabrikası. Tasarım: docs/features/bolum-1/design.md
# Öğret: Mıknatıs ile metal duvara çekilmek · Sına: konveyör bantlar, metal zincir atlayışı
# Şaşırt: Yay ile Mıknatıs arasında gidip gelmek · Ustalık: dönen metal çarklar üzerinde tırmanış
# Mıknatıs: menzil 7 m; yapışıkken Yetenek = sıradaki metale geç, Zıpla = üst kenara tırman.
# Çalıştırma: python3 tools/level/ch1_a3_miknatis_fabrikasi.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch1_miknatis", "Mıknatıs Fabrikası", "scenes/chapter1/a3_miknatis_fabrikasi.tscn", sky="factory",
          music="res://assets/audio/opengameart/happy_clappy_loop.mp3", kill_height=-12, water=-8, seed=33)
PI = math.pi
F = "factory"


def metal(x, y, z, sx=2, sy=2, sz=2):
    return L.ent("metal", x, y, z, size=(sx, sy, sz))


def gear_wall(x, y, z, size=1.4, spin=0.5):
    L.ent("prop", x, y, z, kind="gear", size=size, spin=spin, ry=PI / 2)


# Fabrika binaları (arka plan)
for side in (-1, 1):
    for z0, z1, h in [(10, -45, 18), (-45, -100, 24), (-100, -165, 30)]:
        L.box(side * 19, h / 2 - 6, (z0 + z1) / 2, 8, h + 12, abs(z1 - z0), "stone")
        gear_wall(side * 14.9, h - 8, (z0 + z1) / 2, 2.0, 0.3 * side)

# ---------- Başlangıç ----------
L.top(0, 0, -1.5, 14, 17, depth=4, theme=F)                  # x[-7,7] z[7,-10]
L.start(0, 0.1, 4, ry=PI)
L.ent("copy", 3, 0, -2, ability="miknatis")
L.ent("hint", 3, 0, -2, hint="ability", size=(5, 3, 5))
L.battery_line((-3, 0, 4), (-3, 0, -3), 4)
L.ent("crate", -5, 0, 5, batteries=3)
L.deco("pipe", 6.2, 0, 4, 1.0, ry=0); L.deco("pipe90", 6.2, 1.0, 2, 1.0, ry=0)
L.ent("prop", 0, 4, 2, kind="lamp", size=1.2)

# ---------- Öğret: metal tutamağa çekil, üstüne tırman ----------
L.top(0, 5, -16, 14, 12, depth=9, theme=F)                   # C1 z[-10,-22]
metal(0, 6, -11)                                              # kenardaki tutamak (y 5..7)
L.ent("hint", 0, 0, -8, hint="ability", size=(8, 3, 3))
L.battery_line((0, 1.5, -8.8), (0, 4.5, -9.2), 3)
L.guide(0, 4, -9)

# ---------- Sına: metal zincir (her boşluk 5,5 m, normal zıplama yetmez) ----------
for z in (-28.5, -36, -43.5):
    metal(0, 4, z)
    L.battery(0, 5.6, z)
metal(0, 6, -51)                                              # iniş tutamağı
L.top(0, 5, -55, 12, 10, depth=9, theme=F)                   # P1 z[-50,-60]
L.ent("checkpoint", 4, 5, -56, checkpoint_id="zincir", ry=PI)
L.ent("crate", -4, 5, -57.5, batteries=3)
L.guide(0, 7.5, -36)

# Konveyör (geri iter) ve Hurda Goblin
L.ent("platform", 0, 4.75, -66, ry=PI, kind="conveyor", size=(6, 0.5, 12), belt_speed=3.0)
L.ent("enemy", 1.5, 5.2, -68, kind="hurdaci", speed=1.4, batteries=3)
L.battery_line((-1.5, 5, -62), (-1.5, 5, -70), 4)
L.top(0, 5, -73, 14, 2, depth=9, theme=F)                    # duvar dibi çıkıntı z[-72,-74]

# Gizli Altın Vida: konveyörün yanında, boşlukta duran metal blok
metal(9, 9.5, -64)
L.ent("screw", 9, 10.6, -64)

# Dikey metal levhalar: duvara tırmanış
L.top(0, 12, -79, 14, 10, depth=16, theme="stone")           # C2 z[-74,-84]
metal(0, 6.8, -73.5, 2, 1.6, 1)
metal(0, 9.8, -73.5, 2, 1.6, 1)
metal(0, 12.05, -73.5, 2, 1.1, 1)
L.battery_line((1.6, 7, -72.6), (1.6, 11.5, -72.6), 3)
L.ent("checkpoint", 4, 12, -80, checkpoint_id="duvar", ry=PI)
L.ent("enemy", -3, 12, -81, kind="zipzip", batteries=2)
L.guide(0, 9, -72)

# ---------- Şaşırt: Yay ↔ Mıknatıs ----------
L.ent("copy", -3, 12, -82, ability="yay")
L.top(0, 16.5, -89, 12, 6, depth=20, theme=F)                # R z[-86,-92] (4,5 m yukarı)
L.ent("copy", 3, 16.5, -88, ability="miknatis")
metal(0, 15.5, -97.5)
metal(0, 15.5, -105)
metal(0, 17.5, -111)
L.battery_arc((0, 16.5, -92.5), (0, 16.5, -96.5), 3, 1.5)
L.battery_arc((0, 16.5, -98.5), (0, 16.5, -104), 4, 1.5)
L.top(0, 16.5, -113, 12, 6, depth=20, theme=F)               # S z[-110,-116]
L.ent("copy", -3, 16.5, -114, ability="yay")
L.ent("checkpoint", 4, 16.5, -114, checkpoint_id="dongu", ry=PI)
L.top(0, 21, -121, 12, 6, depth=24, theme="stone")           # T z[-118,-124]
L.ent("copy", 3, 21, -122, ability="miknatis")
L.ent("enemy", -3, 21, -121, kind="hurdaci", speed=1.3, batteries=2)
L.guide(0, 19, -100)
L.guide(0, 23, -121)

# ---------- Ustalık: dönen metal çarklar ----------
L.ent("platform", 3, 21.7, -131, kind="spin", size=(5, 0.6, 5), duration=6.0, metal=True)
L.ent("platform", -3, 23.7, -139, kind="spin", size=(5, 0.6, 5), duration=-5.0, metal=True)
L.ent("platform", 3, 25.7, -147, kind="spin", size=(5, 0.6, 5), duration=6.0, metal=True)
L.battery(3, 22, -131); L.battery(-3, 24, -139); L.battery(3, 26, -147)
L.top(0, 26, -156, 12, 8, depth=28, theme=F)                 # U z[-152,-160]
L.ent("exit", 0, 26, -157.5)
L.ent("prop", -4.5, 29, -159, kind="lamp", size=1.2)
L.deco("flag", 4.5, 26, -159, 0.8, ry=PI)
L.guide(0, 25, -139)

for i in range(6):
    L.ent("prop", random.choice((-6.5, 6.5)), random.uniform(6, 20), -20 - i * 22, kind="lamp", size=1.0)

L.clouds(14, xr=(-100, 100), zr=(-220, 60), avoid=(-30, 30, -170, 20), low=(-6, -3), high=(35, 50))
L.write()
