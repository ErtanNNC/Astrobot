# Bölüm 3 · Patron: Kardan Dev. Tasarım: docs/features/bolum-3/design.md (alan 4)
# Aşama 1: Zıpzıp'ları dondur, buz kütlesinden devin yumruğuna çık (yumruk 3,2 m; zıplama 2,2 m).
# Aşama 2: göl üstünde Buz ile yürü, adadaki şalteri indir (ada 2,15 m: yüzerek çıkılmaz).
# Aşama 3: Pervane ile buz parçasına (5 m), oradan başın yanındaki tüneğe (10,2 m) yüksel, Kaya kopyala, başa çakıl.
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch3_patron", "", "scenes/chapter3/c4_patron.tscn", sky="storm",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", kill_height=-6, water=-8, seed=34,
          extra_props={"cam_distance": 11.0, "cam_pitch": 28.0})

# Kıyı + devin adası (tek parça buz zemin)
L.top(-1, 0, 7, 18, 34, depth=4, theme="snow")                 # x[-10,8] z[24,-10]
L.start(0, 0.1, 20, ry=math.pi)
L.ent("checkpoint", -4, 0, 18, checkpoint_id="giris", ry=math.pi)
L.battery_line((0, 0, 18), (0, 0, 13), 4)
L.ent("trigger", -1, 0, 12, size=(18, 4, 2), method_name="start_boss")
L.ent("giant", 0, 0, 0, name="KardanDev")
# Buz her aşamada var (kıyıda ve adada)
L.ent("copy", -6, 0, 8, ability="buz")
L.ent("copy", -6, 0, -6, ability="buz")
# --- Aşama 1: Zıpzıp'lar (dondurulup basamak olur) ---
for x, z in ((5.0, 4.0), (6.5, -3.5), (2.5, 5.5)):
    L.ent("enemy", x, 0, z, kind="zipzip", batteries=2, groups=["boss_phase"], meta={"phase": 1})
L.battery_ring((4.6, 3.4, 0), 0.7, 4)
# --- Aşama 2: göl ve şalter adası ---
L.top(15, -3, 0, 14, 20, depth=1, theme="stone")               # göl tabanı x[8,22]
L.ent("water", 15, 0, 0, size=(14, 3, 20))
for sz in (-1, 1):
    L.box(15, -1.2, sz * 10.5, 14, 3.6, 1, "ice")
L.top(25, 2.15, 0, 6, 6, depth=5, theme="ice")                  # şalter adası x[22,28]
L.ent("trigger", 25, 2.15, 0, size=(3, 3, 3), method_name="boss_event", arg="switch", groups=["boss_phase"], meta={"phase": 2})
L.deco("lever", 25, 2.15, 0, 1.6, ry=math.pi / 2)
L.battery_line((9.5, 0.3, 0), (20.5, 0.3, 0), 5)
# --- Aşama 3: Pervane (yumruğa ve tüneğe), tünekte Kaya ---
L.ent("copy", 7.0, 0, 3.5, ability="pervane", groups=["boss_phase"], meta={"phase": 3})
L.top(0, 10.2, -3.0, 2.4, 2.4, depth=0.6, theme="ice")          # buz tünek (başın yanında)
L.ent("platform", 3.5, 4.75, -4.0, kind="move", size=(1.8, 0.5, 1.8), offset=(0, 0, 0), color=(0.7, 0.9, 1.0, 1),
      groups=["boss_phase"], meta={"phase": 3})                    # yüzen buz parçası (üstü 5 m)
L.ent("copy", 0.6, 10.2, -3.6, ability="kaya", groups=["boss_phase"], meta={"phase": 3})
# Süs
for i in range(8):
    a = random.uniform(math.pi * 0.6, math.pi * 1.4); r = random.uniform(7.5, 9.5)
    L.rock(math.cos(a) * r, 0, math.sin(a) * r, random.uniform(0.5, 0.9))
L.tree(-8.5, 0, 22, 0.8); L.tree(6, 0, 21, 0.7)
L.ent("prop", -30, 30, -40, kind="storm", size=5.0)
L.clouds(14, avoid=(-35, 40, -35, 40), low=(-8, -5), high=(24, 38))

# Görsel yenileme (2026-11-21): karlı orman halkası, kar yağışı (Kenney Holiday Kit, CC0; çarpışmasız)
for (x, z) in ((-22, 20), (-24, -14), (0, -26), (26, -18), (30, 18)):
    L.top(x, -2, z, 12, 12, depth=6, theme="snow")
    L.scatter(["kenney/holiday/tree-snow-a.glb", "kenney/holiday/tree-snow-b.glb", "kenney/holiday/tree-snow-c.glb"], x - 5, x + 5, z - 5, z + 5, -2, 7, 2.4, 3.4)
L.ent("prop", 0, 22, 0, kind="snow", size=1.4, parent="Decor")

L.write()
