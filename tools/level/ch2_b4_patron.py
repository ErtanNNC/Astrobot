# Bölüm 2 · Patron: Paslı Kaptan. Tasarım: docs/features/bolum-2/design.md (alan 4)
# Çalıştırma: python3 tools/level/ch2_b4_patron.py
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch2_patron", "", "scenes/chapter2/b4_patron.tscn", sky="storm",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", kill_height=-6, water=-8, seed=24,
          extra_props={"cam_distance": 11.0, "cam_pitch": 30.0})
PI = math.pi

# İskele (güneyden giriş)
L.top(0, 0, 20, 6, 16, depth=6, theme="wood")              # z[12,28]
L.start(0, 0.1, 25, ry=PI)
L.ent("checkpoint", -2, 0, 21, checkpoint_id="giris", ry=PI)
L.battery_line((0, 0, 24), (0, 0, 16), 5)
L.ent("trigger", 0, 0, 13.5, size=(6, 4, 2), method_name="start_boss")
for x in (-2.8, 2.8):
    L.box(x, 0.5, 20, 0.3, 1.0, 16, "wood")
# Güverte (arena)
L.top(0, 0, 0, 32, 24, depth=6, theme="wood")              # x[-16,16] z[-12,12]
for x in (-16.2, 16.2):
    L.box(x, 0.6, 0, 0.4, 1.2, 24, "red")
L.box(-9, 0.6, -12.2, 14, 1.2, 0.4, "red"); L.box(9, 0.6, -12.2, 14, 1.2, 0.4, "red")
L.box(-10, 0.6, 12.2, 12, 1.2, 0.4, "red"); L.box(10, 0.6, 12.2, 12, 1.2, 0.4, "red")
L.ent("captain", 0, 0, 0, name="PasliKaptan")
L.battery_ring((0, 0, 0), 12.5, 12)
for x, z in ((-14, -10), (14, 10), (-14, 10)):
    L.ent("prop", x, 2.5, z, kind="lamp", size=1.2)

# --- Aşama 1: direğin tepesindeki çana Pervane ile ---
L.ent("copy", 7, 0, 6, ability="pervane")
L.top(9.0, 2.0, -8, 2, 2, depth=2.0, theme="wood")         # sandık yığını (2 m)
L.deco("qblock", 9.0, 2.0, -9.5, 0.6)
L.box(12.0, 4.0, -8, 0.8, 8.0, 0.8, "wood")                # direk
L.top(12.0, 8.5, -8, 3, 3, depth=0.5, theme="yellow")       # gözcü yeri (8,5 m)
L.ent("prop", 12.0, 9.6, -8, kind="lamp", size=0.8)
L.ent("trigger", 12.0, 8.5, -8, size=(3, 3, 3), method_name="boss_event", arg="mast", groups=["boss_phase"], meta={"phase": 1})
L.ent("hint", 9.0, 0, -8, hint="hold_jump", size=(5, 3, 5), groups=["boss_phase"], meta={"phase": 1})
L.battery_line((9.0, 2.5, -8), (12.0, 8.5, -8), 4)

# --- Aşama 2: Kaya ile fıçıları ez ---
L.ent("copy", -7, 0, 7, ability="kaya", groups=["boss_phase"], meta={"phase": 2})

# --- Aşama 3: Mıknatıs ile şapkaya, tepede Kaya ---
L.ent("copy", 0, 0, 9.5, ability="miknatis", groups=["boss_phase"], meta={"phase": 3})
L.ent("copy", 0, 7.2, -0.8, ability="kaya", groups=["boss_phase"], meta={"phase": 3})

# Süs: deniz, fırtına, batık direkler
for x, z in ((-28, -20), (30, -10), (-25, 25), (26, 30)):
    L.box(x, 1, z, 0.6, 14, 0.6, "wood")
L.ent("prop", 30, 28, -40, kind="storm", size=5.0)
L.clouds(16, avoid=(-35, 35, -30, 40), low=(-8, -4), high=(25, 40))
L.write()
