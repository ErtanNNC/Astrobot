# Bölüm 1 · Patron: Hurdacı Vinç. Tasarım: docs/features/bolum-1/design.md (alan 5)
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch1_patron", "", "scenes/chapter1/a5_patron.tscn", sky="storm",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", kill_height=-10, water=-8, seed=9,
          extra_props={"cam_distance": 10.0, "cam_pitch": 30.0})

# Giriş yolu (güneyden)
L.top(0, 0, 24, 8, 18, depth=4, theme="quarry")            # z[15,33]
L.start(0, 0.1, 30, ry=math.pi)
L.ent("checkpoint", -2.5, 0, 26, checkpoint_id="giris", ry=math.pi)
L.battery_line((0, 0, 29), (0, 0, 19), 6)
L.ent("trigger", 0, 0, 16.5, size=(8, 4, 2), method_name="start_boss")
# Arena
L.top(0, 0, 0, 30, 30, depth=4, theme="factory")            # x[-15,15] z[-15,15]
for x, z in ((-14, -14), (14, -14), (-14, 14), (14, 14)):
    L.ent("prop", x, 0, z, kind="lamp", size=1.5)
L.ent("boss", 0, 0, 0, name="HurdaciVinc")
# Her zaman: Yay kaynakları (kanca ve fırlatma rampası için)
L.ent("copy", -8, 0, 8, ability="yay")
L.ent("copy", 8, 0, -8, ability="yay")
L.battery_ring((0, 0, 0), 9.5, 12)
# --- Aşama 2: fırlatma platformu + Balon, rüzgâr kolları, şalter adası ---
L.top(12.5, 4.5, 0, 5, 6, depth=8.5, theme="yellow")        # x[10,15] üst 4,5
L.ent("copy", 13.5, 4.5, 0, ability="balon", groups=["boss_phase"], meta={"phase": 2})
L.ent("wind", 19.5, -8, 0, size=(4, 14, 5), force=(0, 9, 0), groups=["boss_phase"], meta={"phase": 2})
L.ent("wind", 19.5, -2, 3.5, size=(9, 6, 2), force=(0, 0, 9), cycle=3.0, groups=["boss_phase"], meta={"phase": 2})
L.top(27, 1.0, 0, 6, 6, depth=6, theme="red")               # şalter adası x[24,30]
L.ent("trigger", 27, 1.0, 0, size=(3, 3, 3), method_name="boss_event", arg="switch", groups=["boss_phase"], meta={"phase": 2})
L.deco("lever", 27, 1.0, 0, 1.6, ry=math.pi / 2)
L.battery_arc((15, 4.5, 0), (24, 1.0, 0), 6, 2.0)
# --- Aşama 3: Mıknatıs ile kuleye tırmanış, tepede Kaya ---
L.ent("copy", -9, 0, 5, ability="miknatis", groups=["boss_phase"], meta={"phase": 3})
for i, (r, a, y) in enumerate(((5.0, 180, 3.0), (5.0, 120, 7.5), (5.0, 60, 12.0), (4.6, 0, 16.5))):
    x = math.cos(math.radians(a)) * r; z = math.sin(math.radians(a)) * r
    L.ent("metal", x, y, z, size=(1.6, 1.6, 1.6), groups=["boss_phase", "metal_phase"], meta={"phase": 3})
L.ent("metal", 3.0, 19.2, 0.5, size=(2.4, 0.6, 2.4), name="Tunek", groups=["boss_phase", "metal_phase"], meta={"phase": 3})
L.ent("copy", 3.4, 19.5, 0.5, ability="kaya", groups=["boss_phase"], meta={"phase": 3})
L.ent("platform", 20.5, 1.0, 0, kind="move", size=(3, 0.5, 3), offset=(-7, 0, 0), duration=3.0, groups=["boss_phase"], meta={"phase": 3})
# Süs: hurda yığınları, fırtına
for i in range(10):
    a = random.uniform(0, math.tau); r = random.uniform(11, 14)
    L.deco(random.choice(["bricks", "pipe", "bomb"]), math.cos(a) * r, 0, math.sin(a) * r, random.uniform(0.6, 1.0))
L.ent("prop", -30, 30, -40, kind="storm", size=5.0)
L.ent("prop", 70, -30, -200, kind="dark_tower", size=3.0)
L.clouds(16, avoid=(-35, 35, -35, 40), low=(-8, -4), high=(25, 40))

# Görsel yenileme (2026-11-21): hurdalık manzarası (Kenney Factory Kit + KayKit Space Base, CC0; çarpışmasız)
import random as _r
_r.seed(15)
for (x, z) in ((-26, -20), (-30, 12), (0, -32), (24, -26), (-14, 34)):
    L.top(x, -3, z, 12, 12, depth=6, theme="quarry")
    for k in range(4):
        L.model("kaykit/spacebase/" + _r.choice(("cargo_A_stacked", "containers_C", "cargo_B", "structure_low")), x + _r.uniform(-4, 4), -3, z + _r.uniform(-4, 4), _r.uniform(0, 6.28), _r.uniform(1.6, 2.6))
    L.model("kenney/factory/" + _r.choice(("crane", "robot-arm-a", "hopper-high-round")) + ".glb", x, -3, z, _r.uniform(0, 6.28), 3.0)
for (x, z) in ((-13.5, -13.5), (13.5, -13.5), (-13.5, 13.5)):
    L.model("kenney/factory/warning-orange.glb", x, 0, z, 0, 1.8)
L.model("kenney/factory/cone.glb", -12, 0, 10, 0, 2.0); L.model("kenney/factory/box-large.glb", -12.5, 0, -11, 0.4, 2.2)

L.write()
