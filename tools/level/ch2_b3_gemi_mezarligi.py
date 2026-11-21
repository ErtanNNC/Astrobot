# Bölüm 2 · Alan 3: Gemi Mezarlığı (Mıknatıs, Kaya, su altı yolu, beş yetenekli parkur).
# Tasarım: docs/features/bolum-2/design.md · Çalıştırma: python3 tools/level/ch2_b3_gemi_mezarligi.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch2_gemi", "Gemi Mezarlığı", "scenes/chapter2/b3_gemi_mezarligi.tscn", sky="storm",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", kill_height=-9, water=-12, seed=23)
PI = math.pi


def wall(x0, x1, z0, z1, top, bottom, theme="wood"):
    L.box((x0 + x1) / 2, (top + bottom) / 2, (z0 + z1) / 2, abs(x1 - x0), top - bottom, abs(z1 - z0), theme)


# ---------- Kumsal ----------
L.top(0, 0, 2, 16, 16, depth=6, theme="sand")               # x[-8,8] z[10,-6]
L.start(0, 0.1, 7, ry=PI)
L.ent("copy", 0, 0, -2.5, ability="miknatis")
L.ent("hint", 0, 0, -3, hint="ability", size=(8, 3, 6))
L.battery_line((0, 0, 5), (0, 0, 1), 3)
L.ent("crate", 5, 0, 4, batteries=3)
L.deco("chest", -5.5, 0, 6, 0.9, ry=0.6)
L.rock(6.5, 0, -4.5, 0.8)
L.deco("plant", -6, 0, -3, 1.0)
L.guide(0, 3, -9)
# Batık gövdeler: metal bloklar zinciri (Mıknatıs ile)
# Alçak metal direkler: Mıknatısla yapış, zıpla = üstüne tırman, Yetenek = sıradakine çekil
for x, z, top in ((0, -11.5, 1.0), (1.2, -16.0, 1.4), (-0.8, -20.5, 1.8)):
    L.ent("metal", x, (top - 3.0) / 2, z, size=(2.5, top + 3.0, 2.5))
    L.battery(x, top, z)

# ---------- Gemi 1 (metal gövde, ahşap güverte) ----------
L.ent("metal", 0, -0.75, -29.25, size=(10, 4.5, 10.5))       # gövde y[-3,1.5] z[-24,-34.5]
L.top(0, 2.0, -29.25, 10, 10.5, depth=0.5, theme="wood")      # güverte
L.ent("checkpoint", -3, 2.0, -28.5, checkpoint_id="gemi1", ry=PI)
L.ent("enemy", 1.5, 2.0, -31.5, kind="hurdaci", speed=1.4, batteries=3)
L.ent("crate", 3.8, 2.0, -33.5, batteries=2)
L.battery_ring((-2, 2.0, -32), 1.0, 5)
# Gizli Altın Vida: güvertenin üstünde asılı metal gözcü yuvası
L.ent("metal", 4.0, 7.0, -30.0, size=(1.6, 1.6, 1.6))
L.ent("screw", 4.0, 7.9, -30.0)

# ---------- Gemi 2: Kaya ile çatlak güverteyi kır, ambara in ----------
wall(-5.25, 5.25, -37.5, -38.0, 2.5, -1.0)                    # ön duvar (güverte seviyesi 2,5)
wall(-5.25, -4.75, -38.0, -50.0, 2.5, -1.0); wall(4.75, 5.25, -38.0, -50.0, 2.5, -1.0)
L.top(0, -1.0, -44, 10, 12, depth=1.0, theme="wood")          # ambar tabanı z[-38,-50]
L.top(0, 2.5, -40, 9.5, 4, depth=0.5, theme="wood")           # güverte ön z[-38,-42]
L.top(-3.25, 2.5, -43.5, 3, 3, depth=0.5, theme="wood")       # delik çevresi
L.top(3.25, 2.5, -43.5, 3, 3, depth=0.5, theme="wood")
L.ent("cracked", 0, 2.25, -43.5, size=(3.5, 0.5, 3))          # çatlak güverte
L.top(0, 2.5, -47.5, 9.5, 5, depth=0.5, theme="wood")         # güverte arka z[-45,-50]
wall(-5.25, 5.25, -50.0, -50.5, 9.0, 1.0)                     # kıç duvarı (güverteden geçit yok)
L.ent("copy", -3, 2.5, -40, ability="kaya")
L.ent("hint", 0, 2.5, -42.5, hint="ability", size=(9, 3, 4))
L.guide(0, 4.5, -43.5)
L.battery_line((0, 0, -39.5), (0, 0, -48.5), 5)               # ambarda pil yolu
L.ent("enemy", 2.5, -1.0, -46, kind="vidabocek", patrol=2, batteries=2)
L.ent("crate", -3.5, -1.0, -48.5, batteries=3)
L.ent("prop", 0, 1.3, -45, kind="lamp", size=0.8)
L.ent("checkpoint", 3.2, -1.0, -40, checkpoint_id="ambar", ry=PI)

# ---------- Su altı yolu: kıç kapısından havuza, duvarın altından geç ----------
L.top(0, -1.0, -51.5, 4, 3, depth=1.0, theme="wood")          # geçit z[-50,-53]
L.top(0, -6.0, -61.5, 10, 17, depth=1.0, theme="sand")        # havuz tabanı z[-53,-70]
wall(-5.5, -5.0, -50.5, -70.0, 2.0, -7.0, "stone"); wall(5.0, 5.5, -50.5, -70.0, 2.0, -7.0, "stone")
wall(-5.0, -2.0, -50.5, -53.0, 2.0, -7.0, "stone"); wall(2.0, 5.0, -50.5, -53.0, 2.0, -7.0, "stone")
wall(-2.0, 2.0, -52.5, -53.0, -2.0, -7.0, "stone")            # geçidin altı kapalı
L.ent("water", 0, 0, -61.5, size=(10, 6, 17))                 # yüzey y 0, z[-53,-70]
wall(-5.0, 5.0, -60.0, -60.6, 6.0, -2.6, "stone")             # yüzeyi kesen duvar; altı (-6..-2,6) açık
L.battery_line((0, -6, -57), (0, -6, -64), 4)
# Sudan çıkış merdiveni (1 m basamaklar, Kaya ile çıkılır)
for i in range(6):
    L.top(0, -5.0 + i, -64.5 - i, 10, 1, depth=1.0, theme="stone")
L.top(0, 0.0, -73, 10, 6, depth=6.0, theme="sand")            # iskele z[-70,-76]
L.ent("checkpoint", -3, 0, -72, checkpoint_id="parkur", ry=PI)

# ---------- Ustalık: beş yetenek sırayla ----------
L.ent("copy", 3, 0, -73, ability="yay")
L.top(0, 4.5, -79, 6, 6, depth=5.0, theme="yellow")          # Yay basamağı z[-76,-82]
L.battery_line((0, 1.5, -75), (0, 5, -77), 3)
L.ent("copy", 2, 4.5, -80.5, ability="balon")
L.top(0, 3.0, -97, 6, 6, depth=1.0, theme="red")             # 12 m süzülme z[-94,-100]
L.battery_arc((0, 4.5, -82), (0, 3.0, -94), 6, 1.5)
L.ent("copy", 2, 3.0, -98.5, ability="miknatis")
L.ent("metal", 0, 1.5, -106.3, size=(6, 3, 0.6))              # mavi platformun metal ön yüzü
L.top(0, 3.0, -108, 6, 4, depth=1.0, theme="blue")           # mavi platform z[-106,-110]
L.top(-2.5, 3.0, -111.3, 1, 2.6, depth=1.0, theme="blue")     # çatlağın yanları
L.top(2.5, 3.0, -111.3, 1, 2.6, depth=1.0, theme="blue")
L.top(0, 3.0, -115.3, 6, 5.4, depth=1.0, theme="blue")        # z[-112.6,-118]
L.ent("copy", 2.2, 3.0, -107.6, ability="kaya")
L.ent("cracked", 0, 2.75, -111.3, size=(4, 0.5, 2.6))        # çatlak: alt iskeleye in
wall(-3.0, 3.0, -118.0, -118.5, 12.0, 3.0)                   # platformun sonu: üstten geçit yok
L.top(0, -1.0, -117.5, 6, 17, depth=1.0, theme="wood")       # alt iskele z[-109,-126]
L.ent("copy", -2.0, -1.0, -122, ability="pervane")
L.battery_line((0, -1.0, -113), (0, -1.0, -117), 3)
L.top(0, 5.5, -130, 8, 6, depth=7.0, theme="wood")           # son güverte z[-127,-133] (6,5 m yukarıda)
L.battery_line((0, 0.5, -124.5), (0, 6.0, -127.5), 4)
L.ent("exit", 0, 5.5, -131)
L.deco("flag", 3, 5.5, -132.5, 1.0)

# Süs: batık direkler, borular, kayalar
for x, z in ((-12, -20), (11, -35), (-13, -60), (12, -90), (-11, -110)):
    L.box(x, 3, z, 0.6, 12, 0.6, "wood")
    L.box(x, 7, z, 4, 0.3, 0.3, "wood")
for i in range(8):
    L.rock(random.choice([-1, 1]) * random.uniform(9, 16), -3.5, random.uniform(-130, 0), random.uniform(1.0, 1.8))
# =====================================================================================
# Görsel yenileme (2026-11-21): yağmur, yelkenli batık direkler, toplar, kurukafalar, varil enkazı,
# yön işareti olarak bitişin ardında yan yatmış dev gemi (Quaternius Pirate Pack + KayKit Medieval, CC0)
# =====================================================================================
PR = "quaternius/pirate/"
MD = "kaykit/medieval/"
L.ent("prop", 0, 14, -20, kind="rain", size=1.6, parent="Decor")
L.ent("prop", 0, 14, -75, kind="rain", size=1.6, parent="Decor")
L.ent("prop", 0, 14, -120, kind="rain", size=1.6, parent="Decor")
for x, z in ((-12, -20), (11, -35), (-13, -60), (12, -90), (-11, -110)):
    L.box(x + 0.3, 4.5, z, 0.1, 3.6, 3.4, "stone", rx=0.15)          # yırtık yelken
L.model(PR + "Cannon.fbx", -4.0, 2.0, -26.0, 1.4, 0.35); L.model(PR + "Cannon.fbx", 4.2, 2.5, -48.6, -1.6, 0.35)
L.model(PR + "Cannon.fbx", -3.0, 5.5, -132.2, 0.2, 0.35)
L.model(PR + "Skull.fbx", 6.2, 0, 6.5, 0.6, 0.25); L.model(PR + "Skull.fbx", -4.2, -1.0, -49.2, 2.0, 0.25)
for (x, y, z) in ((-5.6, 0, 3.0), (6.0, 0, 1.0), (3.8, 2.0, -25.2), (-3.4, -1.0, -38.8), (3.6, 0, -74.6), (2.6, 5.5, -128.2)):
    L.model(MD + random.choice(("barrel", "crate_A_big", "crate_B_small", "sack")), x, y, z, random.uniform(0, 6.28), 5.0)
for i in range(10):                                              # suda yüzen variller
    L.model(MD + "barrel", random.choice((-1, 1)) * random.uniform(8, 18), -11.7, random.uniform(-130, 0), random.uniform(0, 6.28), 6.0)
# Yan yatmış dev batık (bitişin ardında, yön işareti)
L.box(12, 0, -148, 9, 8, 28, "wood", rx=0.0, ry=0.35)
L.box(12, 5, -148, 7.5, 2, 26, "red", ry=0.35)
L.box(10.5, 13, -146, 0.8, 18, 0.8, "wood", ry=0.35)
L.box(10.8, 15, -146, 0.12, 7, 6, "stone", ry=0.35)
L.box(13.5, 10, -156, 0.6, 12, 0.6, "wood", ry=0.35)

# --- Gizli köşe: kumsalın batısındaki batık direğin gözcü yuvası (Mıknatıs ile) ---
L.ent("metal", -10.6, 3.0, 1.0, size=(2.0, 2.0, 2.0))         # gözcü yuvasının metal gövdesi (üstü 4)
L.top(-12.6, 4.0, 1.0, 2.0, 2.4, depth=0.4, theme="wood")
L.box(-12.8, -3.0, 1.0, 0.5, 14, 0.5, "wood")                 # direk
L.ent("crate", -12.8, 4.0, 0.3, batteries=5)
L.battery_ring((-11.6, 4.0, 1.0), 1.0, 6)
L.ent("prop", -40, 25, -150, kind="storm", size=4.0)
L.clouds(18, xr=(-90, 90), zr=(-200, 50), avoid=(-25, 25, -150, 20), low=(-10, -6), high=(15, 30))
L.write()
