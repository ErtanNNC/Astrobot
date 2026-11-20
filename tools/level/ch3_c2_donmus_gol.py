# Bölüm 3 · Donmuş Göl: Buz ile göl yolları, Kaya ile buzu kırıp göl altı tüneli, Balon süzülüşü,
# ustalık: Buz + Pervane ile uzun geçiş. Tasarım: docs/features/bolum-3/design.md
import math, os, sys, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch3_gol", "Donmuş Göl", "scenes/chapter3/c2_donmus_gol.tscn", sky="day",
          music="res://assets/audio/opengameart/happy_clappy_loop.mp3", water=-8, kill_height=-10, seed=32)


def lake(cz, length, floor=-3.0, surface=0.0, width=20):
    L.top(0, floor, cz, width, length, depth=1, theme="stone")
    L.ent("water", 0, surface, cz, size=(width, surface - floor, length))
    for sx in (-1, 1):   # alçak buz kenarlar
        L.box(sx * (width / 2 + 0.5), (floor + surface + 0.6) / 2, cz, 1, surface + 0.6 - floor, length, "ice")


# ---------- S1: kıyı ----------
L.top(0, 0, 2, 20, 14, depth=3, theme="snow")                  # z[9,-5]
L.start(0, 0.1, 6, ry=math.pi)
L.ent("copy", -3, 0, 0, ability="buz")
L.battery_line((-3, 0, 4), (-3, 0, 2), 2)
L.tree(-8, 0, 7, 0.9); L.tree(8.5, 0, 5, 0.8); L.rock(7, 0, -3, 0.8); L.bush(-7.5, 0, -3, 0.4)
L.guide(0, 1.8, -5)

# ---------- Göl 1: Buz ile yol aç ----------
lake(-15, 20)                                                  # z[-5,-25]
L.top(-5, 0.3, -12, 2.5, 2.5, depth=0.6, theme="ice")          # buz kütleleri
L.top(5, 0.3, -19, 2.5, 2.5, depth=0.6, theme="ice")
L.battery_line((0, 0.3, -7), (0, 0.3, -23), 7)
L.guide(0, 2.0, -15)

# ---------- S2: Kaya ile buzu kır ----------
L.top(0, 2.15, -30, 20, 10, depth=7, theme="snow")              # z[-25,-35]
L.top(-6, 2.15, -37, 8, 4, depth=7, theme="snow")               # kuyunun batısı
L.top(6, 2.15, -37, 8, 4, depth=7, theme="snow")                # doğusu
L.ent("cracked", 0, 1.85, -37, size=(4, 0.6, 4))                # kırılacak buz
L.top(1.6, 0.9, -37, 0.8, 3, depth=1, theme="stone")           # kuyuya düşen yüzerek çıkar
L.box(0, 0.825, -40, 20, 2.65, 2, "snow")                         # tünel tavanı z[-39,-41]
L.box(0, 5.75, -41.5, 20, 12.5, 1, "ice")                      # aşılamaz buz duvarı
L.ent("checkpoint", -5, 2.15, -28, checkpoint_id="kiyi", ry=math.pi)
L.ent("copy", -3, 2.15, -32, ability="kaya")
L.ent("hint", 0, 2.15, -35, hint="ability", size=(5, 3, 5), delay=6.0)
L.battery_ring((0, 2.15, -30), 1.2, 5)
L.guide(0, 3.5, -37)
# Göl altı tünel (su dolu): Kaya batar, dipte yürür
L.top(1.5, -4, -44.5, 7, 19, depth=1, theme="stone")           # tünel tabanı x[-2,5] z[-35,-54]
L.ent("water", 1.5, 0.5, -44.5, size=(7, 4.5, 19))
L.box(-2.5, -2.75, -44.5, 1, 4.5, 11, "stone")                 # batı duvar z[-39,-50]
L.box(2.5, -2.75, -41.5, 1, 4.5, 5, "stone")                   # doğu duvar z[-39,-44]
L.box(2.5, -2.75, -49, 1, 4.5, 2, "stone")                     # doğu duvar z[-48,-50]
L.box(3.5, -2.75, -43.5, 3, 4.5, 1, "stone"); L.box(3.5, -2.75, -48.5, 3, 4.5, 1, "stone")
L.box(5.5, -2.75, -46, 1, 4.5, 6, "stone")
L.ent("screw", 3.8, -3.9, -46)                                 # gizli girinti
L.battery_line((0, -4, -40), (0, -4, -48), 4)
L.ent("prop", 0, -1.2, -45, kind="lamp", size=0.8)
L.ent("trampoline", 0, -4, -52, height=8.0)                    # çıkış kuyusu
# ---------- S3: buz duvarının ötesi ----------
L.top(0, 2.15, -46, 20, 8, depth=2.65, theme="snow")             # z[-42,-50], altı tünel tavanı
L.top(-6, 2.15, -52, 8, 4, depth=7, theme="snow")
L.top(6, 2.15, -52, 8, 4, depth=7, theme="snow")
L.top(0, 2.15, -58, 20, 8, depth=7, theme="snow")               # z[-54,-62]
L.ent("checkpoint", -5, 2.15, -57, checkpoint_id="duvar", ry=math.pi)
L.ent("copy", 0, 2.15, -60, ability="balon")
L.tree(-8.5, 2.15, -45, 0.7); L.rock(8, 2.15, -59, 0.7)

# ---------- Göl 2: Balon ile süzül, kaybolan buz kütleleri, rüzgâr ----------
lake(-73, 22)                                                  # z[-62,-84]
L.top(-8, 0.9, -63.5, 3, 2, depth=1, theme="ice")              # yüzerek geri çıkış basamağı
for x, z in ((0, -66), (-2.5, -71), (0, -76)):
    L.ent("platform", x, 1.15, z, kind="fall", size=(3, 0.5, 3), color=(0.7, 0.9, 1.0, 1))
L.ent("wind", 6, 0, -73, size=(4, 7, 4), force=(0, 14, 0))
L.battery_arc((0, 2.15, -62.5), (0, 2.15, -83.5), 7, 3.0)
L.top(0, 2.15, -90, 20, 12, depth=5, theme="snow")              # z[-84,-96]
L.top(0, 2.15, -81, 20, 6, depth=5, theme="snow")                # kıyı uzantısı z[-78,-84]
L.guide(0, 4.0, -72)

# ---------- Ustalık: Buz + Pervane ----------
L.ent("checkpoint", -5, 2.15, -88, checkpoint_id="gol3", ry=math.pi)
L.ent("copy", -3, 2.15, -93, ability="buz")
lake(-108, 24)                                                 # z[-96,-120]
L.top(-8, 0.9, -97.5, 3, 2, depth=1, theme="ice")
L.top(0, 2.15, -107, 6, 6, depth=5, theme="snow")               # adacık z[-104,-110]
L.ent("copy", 0, 2.15, -107, ability="pervane")
L.battery_line((0, 0.3, -98), (0, 0.3, -103), 3)
L.battery_arc((0, 2.15, -110.5), (0, 6, -121), 5, 4.0)
L.top(0, 6, -127, 20, 14, depth=9, theme="snow")               # uzak kıyı z[-120,-134]
L.ent("exit", 0, 6, -129)
L.guide(0, 4.0, -107); L.guide(0, 8.5, -118)
L.tree(-7, 6, -131, 0.9); L.tree(7.5, 6, -130, 0.8); L.bush(-4, 6, -133, 0.4)

# =====================================================================================
# Görsel yenileme ve gizli köşeler (2026-11-21)
# =====================================================================================
H = "kenney/holiday/"
KH = "kaykit/holiday/"
# Çevrede karlı tepeler ve çam ormanı (manzara)
for (x, z, w, d, y) in ((-26, -20, 18, 40, 3), (27, -40, 18, 50, 5), (-28, -85, 20, 40, 7), (28, -110, 18, 40, 8), (0, 24, 40, 14, 4)):
    L.top(x, y, z, w, d, depth=y + 10, theme="snow")
    L.scatter([H + "tree-snow-a.glb", H + "tree-snow-b.glb", H + "tree-snow-c.glb"], x - w / 2 + 1, x + w / 2 - 1, z - d / 2 + 1, z + d / 2 - 1, y, int(w * d / 30), 2.4, 3.6)
# Göl yüzeyinde buz parçaları (süs)
for cz, ln in ((-15, 20), (-73, 22), (-108, 24)):
    for _ in range(5):
        L.model(H + "snow-flat.glb", random.choice((-1, 1)) * random.uniform(6.5, 9.0), 0.02, cz + random.uniform(-ln / 2 + 1, ln / 2 - 1), random.uniform(0, 6.28), random.uniform(1.6, 2.6))
# Kıyıda kızak, ren geyiği, kardan adam, fenerler, ışık dizisi
L.model(H + "reindeer.glb", 7.5, 0, 1.0, -2.2, 2.0); L.model(H + "sled.glb", 6.0, 0, 2.4, -1.2, 1.8)
L.model(KH + "snowman_B.gltf", -6.5, 2.15, -30.5, 0.6, 2.2)
for (x, y, z) in ((-9, 0, -4), (9, 0, -4), (-9, 2.15, -84.5), (9, 2.15, -84.5), (-9, 6, -121), (9, 6, -121)):
    L.model(H + "lantern.glb", x, y, z, 0, 1.8)
# Yön işareti: uzak kıyıda dev süslü çam (başlangıçtan görünür)
L.model(KH + "christmas_tree_decorated.gltf", 0, 6, -132, 0, 3.4)
L.kit("star_yellow", 0, 21.5, -132, s=2.0)
L.model(KH + "present_A_red.gltf", -2.6, 6, -131, 0.4, 2.0); L.model(KH + "present_C_blue.gltf", 2.4, 6, -131.5, 1.2, 2.0)

# --- Gizli köşe 1: rüzgârın tepesinden doğudaki buz sütununa (Balon) ---
L.top(12, 6.5, -73, 3.5, 3.5, depth=10, theme="ice")
L.ent("crate", 12, 6.5, -73.8, batteries=5)
L.battery_ring((12, 6.5, -73), 1.0, 6)
L.battery_line((6, 3.5, -73), (6, 6.5, -73), 3)

# --- Gizli köşe 2: başlangıç kıyısının batısında ağaçların ardındaki çukur (keşif ödülü) ---
L.top(-13, -0.6, 2, 5, 6, depth=3, theme="snow")
L.ent("crate", -13, -0.6, 3.5, batteries=5)
L.battery_ring((-13, -0.6, 1.5), 1.2, 6)
L.model(KH + "snowball_pile.gltf", -14.4, -0.6, 0.0, 0, 2.0)

L.scatter([H + "snow-pile.glb", H + "rocks-small.glb"], -9, 9, -4, 8, 0, 6, 1.4, 2.2, clear=(-4, 4))
L.clouds(16, avoid=(-30, 30, -150, 20), low=(-6, -4), high=(14, 26))
L.write()
