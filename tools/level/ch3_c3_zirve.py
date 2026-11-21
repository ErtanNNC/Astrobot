# Bölüm 3 · Kar Zirvesi: Yay ile kar tepeleri, Mıknatıs ile teleferik direkleri, çığ kaçışı,
# ustalık: altı yeteneğin hepsini sırayla isteyen zirve parkuru. Tasarım: docs/features/bolum-3/design.md
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch3_zirve", "Kar Zirvesi", "scenes/chapter3/c3_zirve.tscn", sky="storm",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", water=None, kill_height=-14, seed=33)
# Yol köşeli kurulur (tasarım koordinatları dümdüz kalır): pivotlar dinlenme platformlarının ortasında;
# oyuncu platforma varır, orada döner, atlayışlar düz kalır. Bkz. lvl.py TURNS
L.turns([(0, -24, 40), (0, -99, -50)])

# ---------- S1: etek, Yay ile kar tepeleri ----------
L.top(0, 0, 0, 16, 16, depth=3, theme="snow")                  # z[8,-8]
L.start(0, 0.1, 5, ry=math.pi)
L.ent("copy", 0, 0, -2, ability="yay")
L.top(0, 4.5, -11, 10, 6, depth=8, theme="snow")               # tepe 1 z[-8,-14]
L.top(0, 9.0, -17, 10, 6, depth=12, theme="snow")              # tepe 2 z[-14,-20]
L.top(0, 13.5, -24, 10, 8, depth=16, theme="snow")             # tepe 3 z[-20,-28]
L.battery_arc((0, 0, -5), (0, 4.5, -10), 4, 3.0)
L.battery_arc((0, 4.5, -12), (0, 9.0, -16), 4, 3.0)
L.battery_arc((0, 9.0, -18), (0, 13.5, -22), 4, 3.0)
# Gizli Altın Vida: tepe 1'in yanındaki kar sütunu (Yay ile yana sıçrayarak)
L.top(8, 9.0, -12, 2, 2, depth=12, theme="snow")
L.ent("screw", 8, 9.1, -12)
L.tree(-6, 0, 6, 0.8); L.tree(6.5, 0, 4, 0.7); L.rock(-6, 0, -5, 0.8); L.rock(6, 0, -6, 0.6)
L.guide(0, 6.5, -11); L.guide(0, 15.5, -24)

# ---------- S2: teleferik direkleri (Mıknatıs) ----------
L.ent("checkpoint", -3, 13.5, -23, checkpoint_id="tepe", ry=math.pi)
L.ent("copy", 2.5, 13.5, -25.5, ability="miknatis")
L.ent("hint", 0, 13.5, -26, hint="ability", size=(10, 3, 4), delay=6.0)
# Direkler küçük ve her biri bir öncekinden 1,2 m yüksek: zıplayıp Mıknatıs'a basınca Bip
# geridekine değil sıradakinin üstüne yapışır.
for i, (z, top) in enumerate(((-33, 13.0), (-38.5, 14.2), (-44, 15.4), (-49.5, 16.6))):
    L.ent("metal", 0, top - 0.5, z, size=(1.0, 1.0, 1.0))
    L.box(0, (top - 1.0) / 2 - 6, z, 0.5, top - 1.0 + 12, 0.5, "stone")     # direk
    L.battery(0, top + 0.6, z)
L.top(0, 16.0, -57, 14, 10, depth=9, theme="snow")             # iniş z[-52,-62]
L.ramp(0, -67, 10, 6, 5.0, theme="snow", ry=math.pi, base=11.0)   # çığ vadisine iniş rampası
L.guide(0, 16.0, -42)

# ---------- S3: çığ kaçışı (yuvarlanan dişli kayalar) ----------
L.top(0, 11.0, -79, 14, 30, depth=6, theme="snow")             # z[-64,-94]
L.ent("checkpoint", -4.5, 16.0, -56, checkpoint_id="direk", ry=math.pi)
for x, period in ((-5.0, 3.0), (-1.7, 3.7), (1.7, 4.4), (5.0, 3.4)):
    L.ent("hazard", x, 11.0, -75, ry=math.pi / 2, kind="saw", move=(0, 0, -14), period=period)
for z in (-73, -83):   # kenarlarda saklanılacak kaya cepleri
    L.rock(-6.2, 11.0, z, 0.8); L.rock(6.2, 11.0, z + 4, 0.8)
L.battery_line((-3.35, 11.0, -75), (-3.35, 11.0, -89), 5)
L.ent("checkpoint", -4.5, 11.0, -92, checkpoint_id="cig", ry=math.pi)
L.guide(0, 13.0, -80)

# ---------- S4: zirve parkuru — altı yetenek sırayla ----------
# a) Yay: 4,5 m duvar
L.ent("copy", 3, 11.0, -92.5, ability="yay")
L.top(0, 15.5, -99, 8, 6, depth=10, theme="snow")              # z[-96,-102]
L.battery_line((0, 15.5, -97.5), (0, 15.5, -100.5), 2)
# b) Balon: 12 m boşluk
L.ent("copy", 2.5, 15.5, -100.5, ability="balon")
L.battery_arc((0, 15.5, -103), (0, 13.0, -113), 5, 2.5)
L.top(0, 13.0, -117, 8, 6, depth=4, theme="ice")               # z[-114,-120]
# c) Mıknatıs: iki metal blok
L.ent("copy", 2.5, 13.0, -118.5, ability="miknatis")
L.ent("metal", 0, 11.7, -125, size=(1.6, 1.6, 1.6))
L.ent("metal", 0, 11.2, -131, size=(1.6, 1.6, 1.6))
# d) Kaya: çatlak buzu kır, alttaki geçide in
L.top(0, 11.5, -135.75, 8, 3.5, depth=3, theme="snow")         # z[-134,-137.5]
L.top(-3, 11.5, -139.5, 2, 4, depth=3, theme="snow")
L.top(3, 11.5, -139.5, 2, 4, depth=3, theme="snow")
L.top(0, 11.5, -141.75, 8, 0.5, depth=3, theme="snow")
L.ent("cracked", 0, 11.2, -139.5, size=(4, 0.6, 4))
L.ent("copy", 2.8, 11.5, -135.5, ability="kaya")
L.box(0, 14.25, -142.5, 10, 11.5, 1, "ice")                    # yolu kesen buz duvarı (8,5–20)
# Alt geçit
L.box(0, 7.0, -136.75, 8, 3, 0.5, "stone")                     # geçidin güney ucu kapalı
L.top(0, 7.0, -143.5, 8, 13, depth=3, theme="stone")           # z[-137,-150]
L.box(-4.5, 8.5, -155, 1, 6, 36, "stone"); L.box(4.5, 8.5, -155, 1, 6, 36, "stone")
# e) Buz: havuz
L.ent("copy", 0, 7.0, -146, ability="buz")
L.top(0, 4.0, -155, 8, 10, depth=1, theme="stone")             # havuz tabanı z[-150,-160]
L.ent("water", 0, 7.0, -155, size=(8, 3, 10))
L.ramp(3.25, -153, 6, 1.5, 3.0, theme="stone", ry=math.pi, base=4.0)   # Kaya ile batan için çıkış
L.top(0, 9.15, -166, 8, 12, depth=5, theme="snow")              # z[-160,-172]
L.battery_line((0, 7.3, -151), (0, 7.3, -159), 4)
# f) Pervane: son yamaç
L.ent("copy", 2.6, 9.15, -164, ability="pervane")
L.ent("checkpoint", -3, 9.15, -162, checkpoint_id="gecit", ry=math.pi)
L.top(0, 15.0, -179, 14, 14, depth=12, theme="snow")           # zirve z[-172,-186]
L.battery_arc((0, 9.15, -169), (0, 15.0, -175), 4, 3.5)
L.ent("exit", 0, 15.0, -181)
L.deco("flag", 4.5, 15.0, -183, 1.6, ry=0.3)
L.ent("prop", -20, 38, -200, kind="storm", size=5.0)
L.guide(0, 17.5, -99); L.guide(0, 16.0, -117); L.guide(0, 13.5, -136); L.guide(0, 9.0, -146); L.guide(0, 11.0, -165)

# ---------- Çevre: karlı kayalıklar ----------
for i in range(14):
    z = random.uniform(-185, 0); x = random.choice([-1, 1]) * random.uniform(14, 24)
    L.box(x, -4 + i % 3 * 2, z, random.uniform(5, 9), random.uniform(18, 34), random.uniform(6, 10), "snow")
L.tree(-5, 11.0, -95, 0.7); L.tree(5.5, 15.0, -184, 0.7)
# =====================================================================================
# Görsel yenileme (2026-11-21): kar yağışı, teleferik halatı ve kabini, zirvede kulübe ve fener (yön işareti)
# =====================================================================================
H = "kenney/holiday/"
for z in (-10, -60, -110, -160):
    L.ent("prop", 0, 24, z, kind="snow", size=1.0, parent="Decor")
# Teleferik: direklerin üstünden geçen halat ve asılı kabin (süs)
for (z0, y0, z1, y1) in ((-28, 19, -60, 22.5),):
    n = 16
    for i in range(n):
        t0 = i / n; t1 = (i + 1) / n
        za = z0 + (z1 - z0) * t0; zb = z0 + (z1 - z0) * t1
        ya = y0 + (y1 - y0) * t0 - math.sin(t0 * math.pi) * 1.2; yb = y0 + (y1 - y0) * t1 - math.sin(t1 * math.pi) * 1.2
        L.box(2.2, (ya + yb) / 2, (za + zb) / 2, 0.08, 0.08, abs(zb - za) + 0.05, "stone")
L.box(2.2, 18.2, -41, 1.6, 1.4, 2.0, "red"); L.box(2.2, 19.25, -41, 0.1, 0.8, 0.1, "stone")
L.box(2.2, 18.4, -40.0, 1.3, 0.6, 0.05, "blue")
# Zirve: kulübe, fenerler, kardan adam, bayrak direği
L.model("kaykit/holiday/gingerbread_house_decorated.gltf", -4.0, 15.0, -184.0, 0.3, 3.0)
L.model(H + "lantern.glb", 4.8, 15.0, -174.5, 0, 2.0); L.model(H + "lantern.glb", -4.8, 15.0, -174.5, 0, 2.0)
L.model("kaykit/holiday/snowman_A.gltf", 5.6, 15.0, -184.0, -0.8, 1.5)
L.kit("star_yellow", 0, 23, -181, s=2.4)
L.box(0, 19, -186.2, 0.3, 8, 0.3, "stone")
# Etekte çam ormanı
L.scatter([H + "tree-snow-a.glb", H + "tree-snow-b.glb", H + "tree-snow-c.glb"], -7.5, 7.5, 2, 7.5, 0, 6, 1.6, 2.4, clear=(-3, 3))

L.clouds(18, avoid=(-30, 30, -200, 20), low=(-12, -6), high=(26, 40))
# Yeni düşman türleri (2026-11-21; docs/features/dusmanlar/design.md)
L.ent("enemy", 4.5, 16.0, -58, kind="atici", batteries=3)
L.ent("enemy", -3, 11.0, -91.5, kind="dikenli", patrol=1.5, speed=1.0, batteries=3)
# "Vay" anları (2026-11-22; docs/features/vay-anlari/design.md)
L.setpiece("aurora", 0, 9.15, -164, (0, 48, -205), size=(12, 5, 3), big=1.5)
L.write()
