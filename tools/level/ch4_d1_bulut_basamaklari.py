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

# ---------- Varış bulutu ----------
L.top(0, 7.5, -69, 10, 8, depth=4, theme="cloud")              # z[-65,-73] (boşluk 2,5 m)
L.ent("checkpoint", -3.5, 7.5, -66.5, checkpoint_id="varis", ry=PI)
L.battery_ring((0, 7.5, -69), 1.5, 6)
L.ent("exit", 0, 7.5, -71)
L.deco("flag", 3.5, 7.5, -72, 1.0)

# Uzakta Statik'in kalesi ve fırtına
# Görsel yenileme (2026-11-21): uzakta bulutların üstünde Kıvılcım Kalesi (KayKit Medieval, CC0), yön işareti
L.top(18, -6, -150, 30, 26, depth=4, theme="cloud")
L.model("kaykit/medieval/building_castle_red.gltf", 18, -6, -150, 0.3, 8.0)
for (x, z) in ((6, -140), (30, -140), (6, -162), (30, -162)):
    L.model("kaykit/medieval/building_tower_B_red.gltf", x, -6, z, 0, 6.0)
L.model("kaykit/medieval/flag_red.gltf", 18, 26, -150, 0, 9.0)

L.ent("prop", 10, 18, -140, kind="storm", size=6.0)
L.ent("prop", -50, -20, -180, kind="dark_tower", size=2.5)
for i in range(14):
    L.deco(random.choice(["cloud", "cloud2", "cloud3"]), random.choice([-1, 1]) * random.uniform(16, 34),
           random.uniform(-15, -10), random.uniform(-80, 10), random.uniform(0.8, 1.6), parent="Clouds")
L.clouds(14, xr=(-90, 90), zr=(-180, 40), avoid=(-30, 30, -90, 20), low=(-12, -6), high=(18, 32))
L.write()
