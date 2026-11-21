# Bölüm 5 (bonus) · Alan 4: Şampiyon Yolu (yeni, 2026-11-21). Tasarım: docs/features/bolum-5/design.md
# Oyunun en zor parkuru: altı yeteneğin hepsi art arda, aralarda kısa nefes alanları. Ölçüler oyunda daha önce
# test edilmiş bölümlerden alındı (Yay terası, 12 m süzülüş, mıknatıs zinciri, meteor çukuru, Buz gölü,
# Pervane kulesi, Dev Yay). Sonda altın kupa platformu (yön işareti, başlangıçtan görünür).
# Çalıştırma: python3 tools/level/ch5_e4_sampiyon_yolu.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

PI = math.pi
L = Level("ch5_sampiyon", "Şampiyon Yolu", "scenes/chapter5/e4_sampiyon_yolu.tscn", sky="sunset",
          music="res://assets/audio/opengameart/superhero.ogg", kill_height=-10, water=None, seed=54)
# Yol köşeli kurulur (tasarım koordinatları dümdüz kalır): pivotlar dinlenme platformlarının ortasında;
# oyuncu platforma varır, orada döner, atlayışlar düz kalır. Bkz. lvl.py TURNS
L.turns([(0, -15, 40), (0, -34.5, -55), (0, -128.5, 35)])
RB = ("red", "yellow", "green", "blue", "purple")

# 0 · Başlangıç                                                     z[6,-6]
L.top(0, 0, 0, 12, 12, depth=3, theme="purple")
L.start(0, 0.1, 3, ry=PI)
L.ent("copy", 3, 0, -3, ability="yay")
L.label(0, 5, -6.5, "Şampiyon Yolu", 64)
L.battery_line((-3, 0, 3), (-3, 0, -3), 3)

# başlangıç süsleri: bayraklar, koniler, kupa heykelcikleri
for (x, z, c) in ((-5.3, 5.3, "red"), (5.3, 5.3, "blue"), (-5.3, -5.3, "yellow"), (5.3, -5.3, "green")):
    L.kit("flag_A_" + c, x, 0, z, ry=0.6)
L.kit("star_yellow", -4.2, 0.9, 1.2, s=1.2); L.kit("diamond_blue", 4.4, 0.9, 1.0, s=1.2)
L.kit("cone_red", 3.8, 0, 4.6); L.kit("cone_yellow", 4.5, 0, 4.0)
L.ent("prop", -9, 6, -2, kind="balloon", size=0.6, color=(0.95, 0.4, 0.8, 1), parent="Decor")

# A · Yay: iki 4 m'lik teras
L.top(0, 4, -9, 8, 6, depth=8, theme="red")                       # z[-6,-12]
L.top(0, 8, -15, 8, 6, depth=12, theme="yellow")                  # z[-12,-18]
L.battery_line((0, 0.6, -5.6), (0, 3.6, -5.8), 3)
L.battery_line((0, 4.6, -11.6), (0, 7.6, -11.8), 3)

# B · Balon: 12,5 m süzülüş, 3 m aşağı
L.ent("copy", 3, 8, -14, ability="balon")
L.battery_arc((0, 8.5, -18.5), (0, 5.5, -30), 6, 2.0)
L.top(0, 5, -34.5, 10, 8, depth=10, theme="green")               # P1 z[-30.5,-38.5]
L.ent("checkpoint", -3, 5, -33, checkpoint_id="sampiyon1", ry=PI)
# Gizli Altın Vida: P1'in doğusunda aşağıda (Balon ile in, trambolinle dön)
L.top(9, 1, -34.5, 3, 3, depth=1, theme="yellow")
L.ent("screw", 9.6, 1.1, -35.2)
L.ent("trampoline", 8.4, 1, -33.8, height=6.0)
L.battery_arc((5.5, 5.5, -34.5), (8.6, 1.5, -34.5), 3, 1.0)

# C · Mıknatıs zinciri (5,5 m aralık)
L.ent("copy", 3, 5, -33, ability="miknatis")
for z in (-44, -51.5, -59):
    L.ent("metal", 0, 4, z)
    L.battery(0, 5.6, z)
L.ent("metal", 0, 6, -66.5)
L.top(0, 5, -70.5, 12, 10, depth=10, theme="blue")               # P2 z[-65.5,-75.5]

# D · Kaya: cam zemini kır, tünelden geç, trambolinle çık
L.ent("copy", 3, 5, -68, ability="kaya")
L.top(-4, 5, -77.5, 4, 4, depth=5, theme="blue")
L.top(4, 5, -77.5, 4, 4, depth=5, theme="blue")
L.ent("cracked", 0, 4.7, -77.5, size=(4, 0.6, 4))
L.box(0, 10.15, -80, 12, 11.4, 1, "ice")                          # aşılamaz duvar
L.box(0, 4.725, -86.5, 12, 0.55, 12, "ice")                       # tünel tavanı z[-80.5,-92.5]
L.top(0, -1.15, -86.5, 4, 20, depth=1, theme="stone")             # tünel tabanı z[-76.5,-96.5]
L.box(-2.5, 1.65, -86.5, 1, 5.6, 20, "castle"); L.box(2.5, 1.65, -86.5, 1, 5.6, 20, "castle")
L.battery_line((0, -1.15, -81), (0, -1.15, -92), 5)
L.ent("prop", 0, 2, -86, kind="lamp", size=0.8)
L.ent("trampoline", 0, -1.15, -94.5, height=9.0)
L.top(0, 5, -101.5, 12, 12, depth=10, theme="purple")            # C z[-95.5,-107.5]
L.ent("checkpoint", -4, 5, -99, checkpoint_id="sampiyon2", ry=PI)

# E · Buz: su havuzu, uzak kıyı 2,15 m yüksek
L.ent("copy", 4, 5, -99, ability="buz")
L.top(0, 2, -115.5, 12, 16, depth=1, theme="stone")
L.ent("water", 0, 5, -115.5, size=(12, 3, 16))
for sx in (-1, 1):
    L.box(sx * 6.5, 3.8, -115.5, 1, 3.6, 16, "ice")
L.battery_line((0, 5.3, -109), (0, 5.3, -121), 5)
L.top(0, 7.15, -128.5, 12, 10, depth=12, theme="red")            # D z[-123.5,-133.5]

# F · Pervane: 6,5 m
L.ent("copy", 4, 7.15, -126, ability="pervane")
L.top(0, 13.65, -139.5, 10, 6, depth=14, theme="yellow")         # E z[-136.5,-142.5]
L.battery_line((0, 8.5, -134), (0, 13.5, -136.5), 4)
L.ent("checkpoint", -3, 13.65, -138, checkpoint_id="sampiyon3", ry=PI)

# G · Dev Yay → altın kupa platformu (bitiş)
L.ent("trampoline", 0, 13.65, -141.0, height=11.0)
L.battery_line((0, 15.5, -141), (0, 23.5, -144.5), 5)
L.top(0, 23.65, -147.5, 7, 6, depth=3, theme="yellow")           # kupa z[-144.5,-150.5]
L.ent("exit", 0, 23.65, -148.5)
L.kit("star_yellow", 0, 29, -149, s=3.0)
L.kit("flag_A_yellow", -3, 23.65, -150), L.kit("flag_A_red", 3, 23.65, -150)

# Manzara: gökkuşağı bloklar, balonlar, bulutlar
for i in range(24):
    a = i / 24 * PI
    L.kit("platform_2x2x1_" + ("red", "yellow", "green", "blue")[i % 4], -30 * math.cos(a), 10 + 40 * math.sin(a), -150, 0, 2.0)
for (x, y, z, c) in ((-16, 22, -40, (0.95, 0.35, 0.3, 1)), (18, 26, -90, (0.3, 0.6, 0.95, 1)), (-18, 30, -130, (0.98, 0.78, 0.25, 1))):
    L.ent("prop", x, y, z, kind="balloon", size=0.9, color=c, parent="Decor")
L.clouds(18, xr=(-90, 90), zr=(-220, 40), avoid=(-20, 20, -160, 20), low=(-12, -6), high=(30, 50))

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("vida_adasi", 9, 1, -34.5, 3, 3)
# Yeni düşman türleri (2026-11-21; docs/features/dusmanlar/design.md)
L.ent("enemy", -4, 5, -72, kind="atici", batteries=3)
L.ent("enemy", 0, 5, -103, kind="dikenli", patrol=3.0, speed=1.3, batteries=3)
L.write()
