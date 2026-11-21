# Bölüm 1 · Uyanış Atölyesi (öğretici). Tasarım: docs/features/bolum-1/design.md
# Çalıştırma: python3 tools/level/ch1_a0_atolye.py
import math, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lvl import Level

L = Level("ch1_atolye", "Uyanış Atölyesi", "scenes/chapter1/a0_atolye.tscn", sky="indoor",
          music="res://assets/audio/opengameart/happy_adventure_loop.mp3", safe=True, water=None, kill_height=-15, seed=3)

W = "wood"   # duvar teması
FL = "floor"


def wall(x0, x1, z0, z1, top, bottom=0.0, theme=W):
    L.box((x0 + x1) / 2, (top + bottom) / 2, (z0 + z1) / 2, abs(x1 - x0), top - bottom, abs(z1 - z0), theme)


# ---------- A: uyanış odası ----------
L.top(2, 0, -10, 17.5, 33.5, depth=1.0, theme=FL)      # A + koridor zemini x[-6.75,10.75] z[6.75,-26.75]
L.start(0, 0.35, 3, ry=math.pi)
L.ent("prop", 0, 0, 3, kind="station")
wall(-6.5, -6.0, 6.5, -6.5, 3.2); wall(6.0, 6.5, 6.5, -6.0, 3.2); wall(-6.5, 6.5, 6.5, 7.0, 3.2)
wall(-6.5, -1.5, -6.0, -6.5, 3.2); wall(1.5, 6.5, -6.0, -6.5, 3.2)
L.ent("prop", -5.8, 2.2, 0, kind="gear", size=1.0, spin=0.6, ry=math.pi / 2)
L.ent("prop", 5.8, 2.0, -3, kind="gear", size=0.7, spin=-0.9, ry=math.pi / 2)
L.ent("prop", 0, 2.6, 0, kind="lamp")
L.ent("prop", 4.5, 1.2, 5.6, kind="screen", color=(0.3, 0.9, 1.0, 1))
L.deco("chest", -4.5, 0, 4.5, 1.0, ry=0.4)
L.ent("crate", 4.5, 0, -4.5, batteries=2)
L.ent("crate", -4.5, 0, -4.5, batteries=2)
L.guide(0, 1.8, -5.5)

# ---------- Koridor (kıvrılan, pil yolu) ----------
wall(-2.0, -1.5, -6.0, -17.5, 3.0); wall(1.5, 2.0, -6.0, -13.5, 3.0)
wall(1.5, 10.5, -13.5, -14.0, 3.0); wall(10.5, 11.0, -13.5, -26.0, 3.0)
wall(-2.0, 6.5, -17.5, -18.0, 3.0); wall(6.5, 7.0, -17.5, -26.0, 3.0)
L.battery_line((0, 0, -7), (0, 0, -13), 4)
L.battery_line((1.5, 0, -15.75), (7, 0, -15.75), 3)
L.battery_line((8.75, 0, -18.5), (8.75, 0, -24), 3)
L.ent("prop", 0, 2.6, -11, kind="lamp", size=0.8)
L.ent("prop", 8.75, 2.6, -21, kind="lamp", size=0.8)
L.guide(4.5, 1.8, -15.7)
L.guide(8.75, 1.8, -24)

# ---------- B: zıplama odası ----------
X0, X1 = 2.0, 16.0
L.top(9, 0, -30.5, 14, 9, depth=1.0, theme=FL)             # z[-26,-35]
L.top(9, -0.6, -35.6, 14, 1.2, depth=0.4, theme="stone")   # 1,2 m'lik sığ hendek
L.top(9, 0, -42.1, 14, 11.8, depth=1.0, theme=FL)          # z[-36.2,-48]
wall(1.5, 2.0, -26.0, -48.5, 3.5); wall(16.0, 16.5, -26.0, -48.5, 3.5)
wall(1.5, 6.5, -25.5, -26.0, 3.5); wall(11.0, 16.5, -25.5, -26.0, 3.5)
wall(1.5, 7.0, -48.0, -48.5, 3.5); wall(11.0, 16.5, -48.0, -48.5, 3.5)
L.top(9, 0.5, -30, 4, 2, depth=0.5, theme="yellow")        # 0,5 m kutu
L.ent("hint", 9, 0, -29, hint="jump", size=(6, 3, 4))
L.battery_line((9, 0.5, -30), (9, 0.5, -30), 1)
L.battery_arc((9, 0, -34.2), (9, 0, -37.2), 4, 1.3)
L.label(9, 2.2, -35.6, "1,2 m")
# Raf: tam zıplama gerekir (1,9 m; kısa zıplama ~1 m)
L.top(14, 1.9, -41, 2.6, 2.6, depth=1.9, theme="wood")
L.battery_ring((14, 1.9, -41), 0.7, 5)
L.ent("hint", 14, 0, -41, hint="hold_jump", size=(5, 3, 5))
L.guide(14, 3.2, -41)
# Kamera: kasanın arkasında saklı pil yığını (isteğe bağlı)
L.top(4.2, 3.0, -45.5, 3.4, 2.4, depth=3.0, theme="wood")
L.battery_ring((3.2, 0, -47.3), 0.5, 5)
L.ent("prop", 3.0, 1.0, -47.4, kind="lamp", size=0.4)
L.ent("prop", 9, 2.8, -38, kind="lamp")
L.ent("prop", 16.2, 2.2, -32, kind="gear", size=1.2, spin=0.5, ry=math.pi / 2)
L.ent("crate", 12, 0, -46.5, batteries=3)
L.ent("crate", 13.2, 0, -46.5, batteries=2)

# ---------- C: Yay çukuru ----------
L.top(9, 0, -48.75, 4, 1.5, depth=1.0, theme=FL)           # çıkıntı z[-48,-49.5]
L.top(9, -4, -62, 12, 25, depth=1.0, theme=FL)             # çukur tabanı x[3,15] z[-49.5,-74.5]
wall(2.5, 3.0, -49.5, -74.5, 3.0, -4); wall(15.0, 15.5, -49.5, -74.5, 3.0, -4)
wall(2.5, 7.0, -49.25, -49.75, 3.0, -4); wall(11.0, 15.5, -49.25, -49.75, 3.0, -4)
wall(2.5, 3.0, -63.5, -74.5, 13.0, 3.0); wall(15.0, 15.5, -63.5, -70.0, 13.0, 3.0)
wall(3.0, 7.0, -60.0, -60.5, 3.0, -4); wall(11.0, 15.0, -60.0, -60.5, 3.0, -4)
L.ent("copy", 9, -4, -55, ability="yay")
L.ent("hint", 9, -4, -55, hint="ability", size=(11, 4, 10))
L.ent("checkpoint", 6, -4, -52, checkpoint_id="cukur", ry=math.pi)
L.guide(9, -1.6, -55)
L.battery_line((9, -4, -51.5), (9, -4, -53.0), 2)
# Yükselen üç yaylı basamak
L.top(9, 0.5, -61.75, 4, 3.5, depth=4.5, theme="grass2")    # P1
L.top(9, 4.5, -66.75, 4, 3.5, depth=8.5, theme="yellow")    # P2
L.top(9, 8.5, -71.75, 4, 3.5, depth=12.5, theme="grass2")   # P3
L.battery_arc((9, 0.5, -61.5), (9, 4.5, -66.5), 4, 3.0)
L.battery_arc((9, 4.5, -66.5), (9, 8.5, -71.5), 4, 3.0)
L.guide(9, 6.5, -66.5)
L.ent("prop", 2.8, 6, -66, kind="gear", size=1.6, spin=0.4, ry=math.pi / 2)
L.ent("prop", 15.2, 6, -60, kind="gear", size=1.3, spin=-0.5, ry=math.pi / 2)
L.ent("prop", 14.6, 5.0, -57, kind="lamp", size=1.2)
# Gizli Altın Vida #1: en üst raf (P3'ten Yay ile, rafların arkasından)
L.top(16.5, 12.5, -72, 2.8, 2.8, depth=1.0, theme="wood")
L.top(16.5, 11.0, -67.5, 2.8, 2.0, depth=0.6, theme="wood")   # ara raf
L.ent("screw", 16.5, 12.6, -72.3)

# ---------- D: üst atölye, ilk düşman ----------
L.top(9, 8.5, -81, 18, 15, depth=1.0, theme=FL)             # x[0,18] z[-73.5,-88.5]
wall(-0.5, 0.0, -73.5, -88.5, 12.5, 8.5); wall(18.0, 18.5, -74.0, -88.5, 12.5, 8.5)
wall(-0.5, 7.0, -73.5, -74.0, 10.0, 8.5); wall(11.0, 18.5, -73.5, -74.0, 10.0, 8.5)
L.ent("checkpoint", 4.5, 8.5, -76, checkpoint_id="ust", ry=math.pi)
L.ent("trigger", 9, 8.5, -77, size=(17, 4, 2), method_name="show_health")
L.ent("enemy", 9, 8.5, -81.5, kind="vidabocek", patrol=3.5, speed=1.2, batteries=4)
L.ent("copy", 2.5, 8.5, -79.5, ability="yay")              # yeni yay hemen yanında
L.ent("crate", 15.5, 8.5, -78, batteries=3)
L.ent("crate", 15.5, 8.5, -85.5, batteries=3)
L.ent("crate", 14.4, 8.5, -85.5, batteries=2)
L.ent("prop", 9, 11.2, -81, kind="lamp", size=1.2)
L.ent("prop", 0.2, 10.5, -84, kind="screen", color=(0.9, 0.5, 1.0, 1), ry=math.pi / 2)
L.guide(9, 10.5, -86)

# ---------- E: kapı ve vadi manzarası ----------
wall(-0.5, 5.0, -88.5, -89.0, 13.0, 8.5); wall(13.0, 18.5, -88.5, -89.0, 13.0, 8.5)
wall(5.0, 13.0, -88.5, -89.0, 13.0, 12.5)
L.ent("gate", 9, 8.5, -88.75, name="BuyukKapi", size=(8, 4, 0.5), open_offset=(0, 4.2, 0))
L.ent("trigger", 9, 8.5, -86, size=(8, 4, 3), method_name="open_door", arg="BuyukKapi")
L.top(9, 8.5, -94, 12, 10, depth=2.0, theme="grass")       # balkon z[-89,-99]
for x in (3.6, 14.4):
    L.box(x, 9.1, -94, 0.3, 1.2, 10, "wood")
L.box(9, 9.1, -98.85, 11, 1.2, 0.3, "wood")
L.ent("checkpoint", 5.5, 8.5, -91.5, checkpoint_id="kapi", ry=math.pi)
L.ent("trigger", 9, 8.5, -90.5, size=(10, 4, 2), method_name="vista")
L.ent("exit", 9, 8.5, -96.5)
L.bush(4.3, 8.5, -97.8, 0.4); L.bush(13.6, 8.5, -97.5, 0.35)
L.grass_patch(4, 14, -98, -90, 8.5, 10, avoid=[(7, 11, -98, -90)])
# Uzakta vadi, karanlık kule ve Statik
L.ent("prop", 60, -30, -260, kind="dark_tower", size=3.0)
L.ent("prop", 65, 30, -250, kind="storm", size=5.0)
for i in range(16):
    import random
    x = random.uniform(-60, 80); z = random.uniform(-230, -120)
    L.tree(x, -20, z, random.uniform(1.5, 2.5))
L.top(10, -20, -180, 200, 140, depth=2.0, theme="grass")   # vadi tabanı (uzakta)
L.clouds(14, xr=(-120, 140), zr=(-300, -110), avoid=(0, 0, 0, 0), low=(-10, -4), high=(15, 35))

# ---------- Balkon manzarası: Dişli Adası'nın bütün bölümleri uzakta görünür (yol haritası) ----------
MD = "kaykit/medieval/"
L.model(MD + "hills_A_trees.gltf", -30, -20, -150, 0.3, 14)          # Bölüm 1: bahçeler
L.model(MD + "hills_B_trees.gltf", 10, -20, -135, 1.2, 12)
for i, (x, z, h) in enumerate(((42, -165, 16), (52, -180, 24), (34, -190, 12))):   # kanyon mesaları
    L.box(x, -20 + h / 2, z, 9, h, 9, "strata")
for x, h in ((-52, 22), (-44, 30)):                                     # fabrika bacaları
    L.box(x, -20 + h / 2, -195, 4, h, 4, "factory")
    L.box(x, -20 + h + 0.4, -195, 4.6, 0.8, 4.6, "red")
L.box(-48, -15, -198, 16, 10, 10, "factory")
L.top(78, -18, -205, 24, 20, depth=4, theme="sand")                    # Bölüm 2: fener adası
L.model(MD + "building_tower_A_red.gltf", 78, -18, -205, 0, 10)
L.model(MD + "mountain_B.gltf", -12, -20, -245, 0.6, 34)               # Bölüm 3: karlı dağ
L.scatter(["kenney/holiday/tree-snow-a.glb", "kenney/holiday/tree-snow-b.glb"], -40, 16, -230, -215, -20, 12, 6, 9)
L.top(28, 34, -280, 34, 26, depth=4, theme="cloud")                    # Bölüm 4: bulutların üstünde kale
L.model(MD + "building_castle_red.gltf", 28, 34, -280, 0.2, 9)

# ---------- Süsler (KayKit Furniture/Restaurant, CC0; Atölye ana menüsüyle aynı eşyalar, çarpışmasız) ----------
FU = "kaykit/furniture/"; RE = "kaykit/restaurant/"
L.model(FU + "rug_oval_A", 0, 0.01, 3, 0, 1.3)
L.model(FU + "shelf_B_large_decorated", -6.0, 1.9, -2.5, math.pi / 2)
L.model(FU + "pictureframe_large_A", 3.5, 1.9, 6.5, math.pi)
L.model(FU + "lamp_standing", 5.4, 0, 5.8)
L.model(FU + "table_medium_long", -4.6, 0, 1.6, math.pi / 2, 0.8)
L.model(FU + "book_set", -4.6, 0.8, 1.3, 0.3, 0.8)
L.model(RE + "jar_A_large", -4.4, 0.8, 2.4, 0, 0.8)
L.model(FU + "cactus_medium_A", 5.6, 0, 0.5)
L.model(RE + "crate", 15.2, 0, -27.0, 0.2, 0.7); L.model(RE + "crate", 15.2, 0.56, -27.0, 0.9, 0.55)
L.model(FU + "shelf_B_small_decorated", 2.0, 2.2, -38, -math.pi / 2)
L.model(FU + "pictureframe_medium", 16.0, 2.2, -44, math.pi / 2)
L.model(FU + "lamp_standing", 3.0, 8.5, -87.5)
L.model(FU + "shelf_B_large_decorated", 18.0, 10.4, -80, -math.pi / 2)
L.model(FU + "rug_rectangle_stripes_A", 9, 8.51, -81.5, 0, 1.4)
L.model(FU + "cactus_small_B", 17.2, 8.5, -74.6)

L.write()
