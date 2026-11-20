# Bölüm 4 · Patron: Statik. Tasarım: docs/features/bolum-4/design.md (alan 3), D-014
# Aşama 1: yıldırımlardan kaç, üç paratoneri Kaya ile çak.
# Aşama 2: Statik 13 m'ye yükselir; Pervane ile bulut basamaklarına (5 m, 11 m), oradan Balon ile
#          Statik'in sırtındaki şalter bulutuna (10 m) süzül.
# Aşama 3: Statik alçalır; Mıknatıs ile metal tacına çekil, tacın üstünde Yetenek = enerji ver.
# Çalıştırma: python3 tools/level/ch4_d3_patron.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

PI = math.pi
L = Level("ch4_patron", "", "scenes/chapter4/d3_patron.tscn", sky="storm",
          kill_height=-10, water=None, seed=43, extra_props={"cam_distance": 11.0, "cam_pitch": 28.0})

# Giriş bulutu
L.top(0, 0, 22, 8, 14, depth=3, theme="cloud")                  # z[15,29]
L.start(0, 0.1, 26, ry=PI)
L.ent("checkpoint", -2.5, 0, 22, checkpoint_id="giris", ry=PI)
L.battery_line((0, 0, 25), (0, 0, 17), 5)
L.ent("trigger", 0, 0, 16.5, size=(8, 4, 2), method_name="start_boss")
# Arena bulutu
L.top(0, 0, 0, 30, 30, depth=3, theme="cloud")                  # x[-15,15] z[-15,15]
L.ent("statik", 0, 0, 0, name="Statik")
L.battery_ring((0, 0, 0), 11.5, 12)

# --- Aşama 1: Kaya + üç paratoner ---
L.ent("copy", -9, 0, 9, ability="kaya", groups=["boss_phase"], meta={"phase": 1})
L.ent("copy", 9, 0, -9, ability="kaya", groups=["boss_phase"], meta={"phase": 1})
for i, a in enumerate((90, 210, 330)):
    x = math.cos(math.radians(a)) * 8.0; z = math.sin(math.radians(a)) * 8.0
    L.ent("cracked", x, 0.45, z, size=(1.6, 0.9, 1.6), name="Paratoner%d" % (i + 1),
          groups=["boss_rod", "boss_phase"], meta={"phase": 1})
    L.box(0, 1.9, 0, 0.2, 3.0, 0.2, "yellow", name="Direk", parent="Entities/Paratoner%d" % (i + 1))
L.ent("hint", 0, 0, 8, hint="ability", size=(6, 3, 4), groups=["boss_phase"], meta={"phase": 1})

# --- Aşama 2: Pervane + Balon ile sırttaki şaltere ---
L.ent("copy", 9, 0, 9, ability="pervane", groups=["boss_phase"], meta={"phase": 2})
L.top(9.5, 5.0, 3.0, 3.5, 3.5, depth=0.8, theme="cloud")          # bulut basamağı 1 (5 m)
L.top(7.5, 11.0, -4.0, 3.5, 3.5, depth=0.8, theme="cloud")        # bulut basamağı 2 (11 m)
L.ent("copy", 8.5, 11.0, -3.0, ability="balon", groups=["boss_phase"], meta={"phase": 2})
L.top(-3.0, 10.0, -5.5, 4.0, 4.0, depth=0.8, theme="purple")      # Statik'in sırtındaki şalter bulutu
L.ent("trigger", -3.0, 10.0, -5.5, size=(3, 3, 3), method_name="boss_event", arg="switch",
      groups=["boss_phase"], meta={"phase": 2})
L.deco("lever", -3.0, 10.0, -5.5, 1.6, ry=PI / 2)
L.battery_arc((9.5, 5.0, 3.0), (7.5, 11.0, -4.0), 4, 2.0)
L.battery_arc((7.5, 11.0, -4.0), (-3.0, 10.0, -5.5), 5, 1.5)

# --- Aşama 3: Mıknatıs ile taca ---
L.ent("copy", 0, 0, 7.5, ability="miknatis", groups=["boss_phase"], meta={"phase": 3})
L.ent("hint", 0, 0, 5, hint="ability", size=(8, 3, 4), groups=["boss_phase"], meta={"phase": 3})

# Süs
for i in range(10):
    a = random.uniform(0, math.tau); r = random.uniform(32, 44)
    L.deco(random.choice(["cloud", "cloud2", "cloud3"]), math.cos(a) * r, random.uniform(-14, -9), math.sin(a) * r,
           random.uniform(0.8, 1.5), parent="Clouds")
L.ent("prop", 70, -25, -200, kind="dark_tower", size=3.0)
L.clouds(16, avoid=(-40, 40, -40, 40), low=(-14, -8), high=(28, 44))

# Görsel yenileme (2026-11-21): bulutların üstünde kale kuleleri halkası, bayraklar (KayKit Medieval, CC0)
import math as _m
for i in range(6):
    a = _m.tau * i / 6 + 0.3
    x, z = _m.cos(a) * 36, _m.sin(a) * 36
    if abs(x) < 12 and z > 0:
        continue                       # giriş köprüsünün önü açık kalsın
    L.top(x, -4, z, 8, 8, depth=3, theme="cloud")
    L.model("kaykit/medieval/building_tower_B_red.gltf", x, -4, z, a, 6.0)
    L.model("kaykit/medieval/flag_red.gltf", x, 9.2, z, 0, 5.0)

L.write()
