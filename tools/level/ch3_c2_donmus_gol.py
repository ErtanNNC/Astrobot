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
L.ent("wind", 6, 0, -73, size=(4, 7, 4), force=(0, 9, 0))
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

L.grass_patch(-9, 9, -4, 8, 0, 6, avoid=[(-4, 4, -5, 9)])
L.clouds(16, avoid=(-30, 30, -150, 20), low=(-6, -4), high=(14, 26))
L.write()
