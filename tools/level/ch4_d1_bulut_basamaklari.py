# Bölüm 4 · Alan 1: Bulut Basamakları. Tasarım: docs/features/bolum-4/design.md
# Gökyüzünde bulut adaları: Yay ile bulut kulesi, kaybolan bulutlar, Balon ile süzülme (rüzgâr yardımıyla),
# Pervane ile yükseliş. Çalıştırma: python3 tools/level/ch4_d1_bulut_basamaklari.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

PI = math.pi
L = Level("ch4_bulut", "Bulut Basamakları", "scenes/chapter4/d1_bulut_basamaklari.tscn", sky="sunset",
          kill_height=-10, water=None, seed=41)

# ---------- Başlangıç bulutu ----------
L.top(0, 0, 1, 12, 14, depth=3, theme="cloud")                 # x[-6,6] z[8,-6]
L.start(0, 0.1, 5, ry=PI)
L.ent("copy", 0, 0, -2.5, ability="yay")
L.battery_line((0, 0, 4), (0, 0, 0.5), 3)
L.ent("crate", 4.2, 0, 3, batteries=3)
L.deco("cloud", -8.5, -3.0, 2, 0.8)
L.deco("cloud2", 8.5, -3.2, -2, 0.7)
L.guide(0, 2, -4)

L.ent("prop", -9, 5, -3, kind="balloon", size=0.6, color=(0.95, 0.4, 0.4, 1), parent="Decor")
L.ent("prop", 10, 8, -12, kind="balloon", size=0.5, color=(0.4, 0.7, 1.0, 1), parent="Decor")
L.kit("star_yellow", -4.5, 0.9, 5.5, s=1.1); L.kit("flag_C_blue", 5.2, 0, -5.2)

# ---------- Öğret: Yay ile bulut kulesi (4 m yukarı) ----------
L.top(0, 4.0, -11, 7, 4, depth=5, theme="cloud")               # z[-9,-13]
L.battery_arc((0, 0, -5), (0, 4.0, -10), 4, 3.0)
L.ent("enemy", 1.5, 4.0, -11, kind="zipzip", batteries=2)

# ---------- Sına: kaybolan bulutlar ----------
for i, z in enumerate((-15.5, -19.5, -23.5)):
    x = (-1.2, 1.2, -0.6)[i]
    L.ent("platform", x, 3.75, z, kind="fall", size=(3, 0.5, 3), color=(0.95, 0.93, 1.0, 1))
    L.battery(x, 4.0, z)
L.top(0, 4.0, -30.5, 9, 9, depth=5, theme="cloud")             # z[-26,-35]
L.ent("checkpoint", -3, 4.0, -29, checkpoint_id="bulut1", ry=PI)
L.ent("enemy", 2.5, 4.0, -32, kind="zipzip", batteries=2)
L.ent("crate", -3.5, 4.0, -33.5, batteries=3)
L.guide(0, 6, -31)

# ---------- Şaşırt: Balon ile süzülme, ortada yukarı rüzgâr ----------
L.ent("copy", 2.5, 4.0, -33.5, ability="balon")
L.ent("wind", 0, -6, -40, size=(5, 12, 5), force=(0, 9, 0))
L.deco("cloud3", 0, -7, -40, 1.0)
L.top(0, 1.0, -49, 8, 8, depth=3, theme="cloud")               # z[-45,-53] (boşluk 10 m)
L.battery_arc((0, 4.0, -35), (0, 1.0, -45), 6, 2.0)
L.ent("checkpoint", 2.5, 1.0, -47, checkpoint_id="bulut2", ry=PI)
L.deco("plant", -2.5, 1.0, -51, 1.0)

# ---------- Ustalık: Pervane ile yükseliş (6,5 m) ----------
L.ent("copy", -2.5, 1.0, -50.5, ability="pervane")
L.top(0, 7.5, -59.5, 6, 6, depth=4, theme="purple")            # z[-56.5,-62.5]
L.battery_line((0, 2.0, -53), (0, 8.0, -56), 4)
L.ent("crate", 1.8, 7.5, -61, batteries=3)
L.guide(0, 9.5, -59.5)

# Gizli Altın Vida: bulut kulesinin yanında havada (Pervane ile, 3,5 m yukarı + yana)
L.top(7.5, 11.0, -59.5, 2.4, 2.4, depth=0.6, theme="cloud")
L.ent("screw", 7.5, 11.1, -59.5)

# ---------- Dinlenme bulutu ----------
L.top(0, 7.5, -69, 10, 8, depth=4, theme="cloud")              # z[-65,-73] (boşluk 2,5 m)
L.ent("checkpoint", -3.5, 7.5, -66.5, checkpoint_id="varis", ry=PI)
L.battery_ring((0, 7.5, -69), 1.5, 6)
L.ent("copy", 3.0, 7.5, -66.5, ability="yay")

# ---------- Gökkuşağı Köprüsü (2026-11-21): renkli basamaklar, gidip gelen parçalar ----------
RB = ("red", "yellow", "green", "blue", "purple")
for i in range(5):
    z = -76.5 - i * 4.0
    y = 7.5 + (1.0 if i % 2 else 0.0)
    if i == 2:
        L.ent("platform", 0, y - 0.25, z, kind="move", size=(3.5, 0.5, 3.0), offset=(4, 0, 0), duration=2.2, color=(0.4, 0.85, 0.45, 1))
    else:
        L.top(0, y, z, 3.5, 3.0, depth=0.8, theme=RB[i])
    L.battery(0, y, z)
L.ent("enemy", 0, 8.5, -80.5, kind="zipzip", batteries=2)
# gökkuşağı kemeri (süs) ve üstünde gizli sandık (Yay ile kemerin ayağından)
for k in range(17):                                            # süs (çarpışmasız KayKit blokları)
    a = math.pi * k / 16
    if 7 <= k <= 9:
        continue                                               # tepede gizli tabla var
    L.kit("platform_1x1x1_" + ("red", "yellow", "green", "blue")[k % 4], -6.5, 7.0 + math.sin(a) * 9, -84 - math.cos(a) * 9, 0, (2.2, 1.0, 1.0))
L.top(-6.5, 16.5, -84, 2.6, 2.6, depth=0.4, theme="yellow")   # kemerin tepesi (gizli)
L.ent("crate", -6.9, 16.5, -84.6, batteries=5)
L.battery_ring((-6.5, 16.5, -84), 1.0, 6)
L.top(-6.2, 12.0, -80.5, 2.2, 2.2, depth=0.4, theme="red")     # kemere çıkış basamağı (Yay ile 3,5 m, sonra 4,5 m)
L.battery_line((-2.5, 9.0, -80.5), (-5.6, 11.6, -80.5), 2)

# ---------- Balon Merdiveni: süzülen balonlara bağlı trambolin bulutları ----------
L.top(0, 7.5, -100, 8, 6, depth=3, theme="cloud")              # z[-97,-103]
L.ent("checkpoint", -2.5, 7.5, -98.5, checkpoint_id="kopru", ry=PI)
for i, (x, y, z) in enumerate(((3.0, 9.0, -107), (-3.0, 12.5, -112), (3.0, 16.0, -117))):
    L.top(x, y, z, 3.2, 3.2, depth=0.6, theme="cloud")
    L.ent("trampoline", x, y, z, height=5.0)
    L.ent("prop", x, y + 6.5, z, kind="balloon", size=0.45, color=((0.95, 0.35, 0.3, 1), (0.3, 0.6, 0.95, 1), (0.98, 0.78, 0.25, 1))[i], parent="Decor")
    for k in range(3):
        L.box(x + (k - 1) * 0.6, y + 3.2, z, 0.04, 6.4, 0.04, "stone")   # balon ipleri
L.battery_arc((0, 7.5, -103), (3, 9, -107), 3, 2.0)
L.battery_arc((3, 9, -107), (-3, 12.5, -112), 4, 4.0)
L.battery_arc((-3, 12.5, -112), (3, 16, -117), 4, 4.0)
L.guide(0, 11, -110)

# ---------- Kale Manzarası (bitiş) ----------
L.top(0, 16.0, -127, 12, 10, depth=4, theme="cloud")           # z[-122,-132]
L.battery_arc((3, 16, -119), (0, 16, -123), 3, 3.0)
L.ent("checkpoint", -3.5, 16.0, -124, checkpoint_id="manzara", ry=PI)
L.battery_ring((0, 16.0, -127), 2.0, 8)
L.ent("exit", 0, 16.0, -129)
L.deco("flag", 3.5, 16.0, -131, 1.0)
L.label(0, 21, -132, "Kıvılcım Kalesi", 60)

# --- Gizli köşe: başlangıç bulutunun altında saklı bulut (kenardan in, trambolinle dön) ---
L.top(0, -6.0, 13.5, 6, 5, depth=1.0, theme="cloud")            # z[11,16]
L.ent("crate", -1.8, -6.0, 15, batteries=5)
L.battery_ring((0.8, -6.0, 13.8), 1.3, 6)
L.ent("trampoline", 1.6, -6.0, 12.4, height=7.5)
L.battery_line((0, 0.4, 7.6), (0, -4.0, 11.5), 3)

# Uzakta Statik'in kalesi ve fırtına
# Görsel yenileme (2026-11-21): uzakta bulutların üstünde Kıvılcım Kalesi (KayKit Medieval, CC0), yön işareti
L.top(18, 4, -175, 30, 26, depth=4, theme="cloud")
L.model("kaykit/medieval/building_castle_red.gltf", 18, 4, -175, 0.3, 8.0)
for (x, z) in ((6, -165), (30, -165), (6, -187), (30, -187)):
    L.model("kaykit/medieval/building_tower_B_red.gltf", x, 4, z, 0, 6.0)
L.model("kaykit/medieval/flag_red.gltf", 18, 36, -175, 0, 9.0)

L.ent("prop", 30, 34, -200, kind="storm", size=6.0)
L.ent("prop", -50, -20, -180, kind="dark_tower", size=2.5)
for i in range(14):
    L.deco(random.choice(["cloud", "cloud2", "cloud3"]), random.choice([-1, 1]) * random.uniform(16, 34),
           random.uniform(-15, -10), random.uniform(-140, 10), random.uniform(0.8, 1.6), parent="Clouds")
L.clouds(14, xr=(-90, 90), zr=(-200, 40), avoid=(-30, 30, -140, 20), low=(-12, -6), high=(18, 32))

# Gizli köşe tetikleyicileri (ilk girişte "Gizli köşe!" afişi)
L.secret("kemer", -6.5, 16.5, -84, 2.6, 2.6)
L.secret("alt_bulut", 0, -6, 13.5, 6, 5)
L.write()
