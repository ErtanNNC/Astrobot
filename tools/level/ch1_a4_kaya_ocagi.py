# Bölüm 1 · Alan 4: Kaya Ocağı. Tasarım: docs/features/bolum-1/design.md
# Öğret: Kaya ile ağır buton, çatlak zemin · Sına: zaman sınırlı kapılar, ezilecek düşmanlar
# Şaşırt: Kaya ile dibe batıp suyun altındaki yolu bulmak · Ustalık: dört yeteneği sırayla isteyen parkur
# Her zorunlu yeteneğin kaynağı gerektiği yerin hemen yanında (soft-lock yok).
# Çalıştırma: python3 tools/level/ch1_a4_kaya_ocagi.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch1_kaya", "Kaya Ocağı", "scenes/chapter1/a4_kaya_ocagi.tscn", sky="quarry",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", kill_height=-14, water=-9, seed=44)
PI = math.pi
Q = "quarry"


def wall(x0, x1, z0, z1, top, bottom=0.0, theme=Q):
    L.box((x0 + x1) / 2, (top + bottom) / 2, (z0 + z1) / 2, abs(x1 - x0), top - bottom, abs(z1 - z0), theme)


def rocks(x0, x1, z0, z1, y, n):
    for _ in range(n):
        L.rock(random.uniform(x0, x1), y, random.uniform(z0, z1), random.uniform(0.5, 0.9))


# Ocak duvarları (arka plan)
for side in (-1, 1):
    for z0, z1, h in [(12, -60, 14), (-60, -120, 18), (-120, -175, 16)]:
        L.box(side * 18, h / 2 - 8, (z0 + z1) / 2, 10, h + 16, abs(z1 - z0), Q if z0 > -100 else "sand")

# ---------- Başlangıç ----------
L.top(0, 0, -0.5, 14, 15, depth=6, theme=Q)                   # x[-7,7] z[7,-8]
L.start(0, 0.1, 4, ry=PI)
L.ent("copy", 3, 0, -3, ability="kaya")
L.ent("hint", 3, 0, -3, hint="ability", size=(5, 3, 5))
L.battery_line((-3, 0, 4), (-3, 0, -4), 4)
rocks(-6, 6, 2, 6, 0, 3)
L.deco("rocktall", -6, 0, -6, 0.5)

# ---------- Öğret: ağır buton → kapı; çatlak zemin ----------
L.top(0, 0, -16.25, 8, 16.5, depth=6, theme=Q)                # koridor z[-8,-24.5]
wall(-4.5, -3.5, -8, -42, 7, -5); wall(3.5, 4.5, -8, -42, 7, -5)
L.ent("button", 0, 0, -10, targets=["../Gate_1"])
L.ent("gate", 0, 0, -13, size=(7, 6, 0.6), open_offset=(0, -6.2, 0))
L.battery_line((0, 0, -15), (0, 0, -22), 4)
L.top(-2.75, 0, -26, 2.5, 3, depth=1, theme=Q); L.top(2.75, 0, -26, 2.5, 3, depth=1, theme=Q)
L.ent("cracked", 0, -0.3, -26, size=(3, 0.6, 3))
L.top(0, 0, -27.75, 8, 0.5, depth=1, theme=Q)
wall(-3.5, 3.5, -28, -29, 7, 0)                                # çıkmaz duvar: yol aşağıda
L.ent("hint", 0, 0, -26, hint="ability", size=(4, 3, 4))
L.guide(0, 2, -11)
L.guide(0, 2, -26)
# Alt mağara ve yukarı rampa
L.top(0, -5, -33, 7, 18, depth=2, theme=Q)                    # z[-24,-42]
L.battery_line((0, -5, -30), (0, -5, -40), 4)
L.ent("prop", 0, -2, -34, kind="lamp", size=1.0)
L.ramp(0, -46, 8, 7, 5, theme=Q, base=-5)
wall(-4.5, -3.5, -42, -50, 2, -5); wall(3.5, 4.5, -42, -50, 2, -5)

# ---------- Sına: zamanlı kapı, ezilecek düşmanlar ----------
L.top(0, 0, -58, 16, 16, depth=6, theme=Q)                    # meydan z[-50,-66]
L.ent("checkpoint", 5, 0, -52, checkpoint_id="ocak", ry=PI)
L.ent("copy", 2, 0, -52, ability="kaya")
L.ent("button", -5, 0, -54, targets=["../Gate_2"], open_time=6.0)
wall(-8, -3, -66, -67, 7, 0); wall(3, 8, -66, -67, 7, 0)
L.ent("gate", 0, 0, -66.5, size=(6, 6, 0.6), open_offset=(0, -6.2, 0))
L.ent("enemy", -3, 0, -60, kind="vidabocek", patrol=3, speed=1.3, batteries=3)
L.ent("enemy", 3, 0, -62, kind="hurdaci", speed=1.2, batteries=3)
L.ent("enemy", 4, 0, -57, kind="zipzip", batteries=2)
L.ent("crate", -6.5, 0, -64.5, batteries=3)
L.battery_ring((0, 0, -59), 2.5, 6)
L.deco("arrow", -5, 0, -56.5, 0.7, ry=PI / 2)
L.guide(-5, 2, -54)

# ---------- Şaşırt: suyun altındaki yol ----------
L.top(0, 0, -73.5, 12, 13, depth=6, theme=Q)                  # Q z[-67,-80]
L.ent("copy", 3.5, 0, -77, ability="kaya")
L.top(0, -5, -87, 12, 14, depth=2, theme="sand")              # havuz tabanı z[-80,-94]
wall(-6.5, -6, -80, -100, 1.5, -5)
wall(6, 6.5, -80, -82, 1.5, -5); wall(6, 6.5, -86, -100, 1.5, -5); wall(6, 6.5, -82, -86, 1.5, -2.6)
L.box(0, 0.7, -88.5, 12, 6.6, 1.0, "stone")                   # bölme duvarı: y[-2.6,4]
L.ent("water", 0, 0, -89, size=(12, 5.2, 18))
L.battery_line((0, -5, -85), (0, -5, -92), 4)
L.ramp(0, -98, 8, 12, 5, theme="sand", base=-5)
L.ent("hint", 0, 0, -82, hint="ability", size=(12, 3, 3))
L.guide(0, -3.5, -88.5)
# Gizli Altın Vida: doğu duvarının altındaki tünelden girilen su altı oyuğu
L.top(8.5, -5, -84, 4, 5, depth=2, theme="sand")
L.box(8.5, -0.55, -84, 4, 4.1, 5, Q)                           # oyuk tavanı y[-2.6,1.5]
wall(10.5, 11, -81.5, -86.5, -2.6, -5)
wall(6.5, 10.5, -81.5, -82, -2.6, -5); wall(6.5, 10.5, -86, -86.5, -2.6, -5)
L.ent("screw", 8.8, -4.8, -84)

# ---------- Ustalık: dört yetenek sırayla ----------
L.top(0, 0, -105, 12, 6, depth=6, theme=Q)                    # R z[-102,-108]
L.ent("copy", -3, 0, -104, ability="yay")
L.top(0, 4.5, -113, 12, 6, depth=10, theme=Q)                 # U1 z[-110,-116] (Yay: 4,5 m)
L.ent("copy", 3, 4.5, -112, ability="balon")
L.battery_arc((0, 4.5, -116.5), (0, 4, -122.5), 5, 2.0)
L.top(0, 4, -126, 12, 6, depth=10, theme="sand")              # U2 z[-123,-129] (Balon: 7 m)
L.ent("copy", -3, 4, -125, ability="miknatis")
L.ent("checkpoint", 4, 4, -127, checkpoint_id="son", ry=PI)
L.ent("metal", 0, 3, -135.5, size=(2, 2, 2))
L.ent("metal", 0, 3, -143, size=(2, 2, 2))
L.ent("metal", 0, 5, -149, size=(2, 2, 2))
L.battery(0, 4.6, -135.5); L.battery(0, 4.6, -143)
L.top(0, 4, -153, 12, 10, depth=10, theme=Q)                  # U3 z[-148,-158]
L.ent("copy", -3, 4, -151, ability="kaya")
L.ent("button", 2.5, 4, -153, targets=["../Gate_3"])
wall(-6, -4, -158, -159, 11, 4); wall(4, 6, -158, -159, 11, 4)
L.ent("gate", 0, 4, -158.5, size=(8, 6, 0.6), open_offset=(0, -6.2, 0))
L.ent("enemy", -1, 4, -155, kind="zipzip", batteries=2)
L.top(0, 4, -163, 12, 8, depth=10, theme="grass")             # U4 z[-159,-167]
L.ent("exit", 0, 4, -164.5)
L.deco("flag", 4.5, 4, -166, 0.8, ry=PI)
L.guide(0, 6.5, -113)
L.guide(0, 6.5, -126)
L.guide(0, 6.5, -143)
rocks(-5, 5, -166, -160, 4, 2)

L.clouds(14, xr=(-100, 100), zr=(-230, 60), avoid=(-30, 30, -175, 20), low=(-7, -5), high=(25, 45))
L.write()
